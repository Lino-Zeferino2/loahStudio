const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { logger } = require('firebase-functions');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { initializeApp } = require('firebase-admin/app');
const { enviarEmail, gmailEmail, gmailAppPassword } = require('./mailer');
const {
  agendamentoRecebidoEmail,
  agendamentoConfirmadoEmail,
  agendamentoCanceladoEmail,
  agendamentoAtualizadoEmail,
  pedidoAvaliacaoEmail,
  pedidoRecebidoEmail,
  pedidoConfirmadoEmail,
  pedidoEntregueEmail,
} = require('./emailTemplates');
initializeApp();

const REGIAO = 'europe-west1';
const SECRETS = [gmailEmail, gmailAppPassword];

// ---------------------------------------------------------------------
// NOTIFICAÇÕES — helpers partilhados
// ---------------------------------------------------------------------

/**
 * Formata um Timestamp de Firestore como 'dd/mm/aaaa', usando os
 * componentes UTC — o campo 'data' é sempre guardado como meia-noite UTC
 * do dia-calendário de Lisboa, por isso usar getUTC* evita off-by-one.
 */
function formatarDataPt(timestamp) {
  const d = timestamp.toDate();
  const dia = String(d.getUTCDate()).padStart(2, '0');
  const mes = String(d.getUTCMonth() + 1).padStart(2, '0');
  return `${dia}/${mes}/${d.getUTCFullYear()}`;
}

// Só há uma conta admin — guardamos o uid em memória entre invocações
// (cold start) para não repetir a query em todas as notificações.
let _adminUidCache = null;
async function getAdminUid(db) {
  if (_adminUidCache) return _adminUidCache;
  const snap = await db.collection('clientes').where('role', '==', 'admin').limit(1).get();
  if (snap.empty) {
    logger.warn('Nenhuma conta admin encontrada — notificações para admin não serão criadas.');
    return null;
  }
  _adminUidCache = snap.docs[0].id;
  return _adminUidCache;
}

/**
 * Escreve um documento em 'notificacoes'. O push (FCM) NÃO é enviado
 * aqui — é despoletado automaticamente pelo trigger 'onNotificacaoCriada'
 * abaixo, que corre sempre que um documento desta coleção é criado. Isto
 * mantém um único ponto de envio de push, em vez de repetir a lógica em
 * cada sítio que cria uma notificação.
 */
async function criarNotificacao(db, { destinatarioId, tipo, titulo, corpo, referenciaId, referenciaTipo }) {
  if (!destinatarioId) return;
  try {
    await db.collection('notificacoes').add({
      destinatarioId,
      tipo,
      titulo,
      corpo,
      referenciaId,
      referenciaTipo,
      lida: false,
      criadoEm: FieldValue.serverTimestamp(),
    });
  } catch (e) {
    logger.error(`Erro ao criar notificação (${tipo}):`, e);
  }
}

/**
 * Trigger único que envia o push FCM sempre que uma notificação é criada
 * em Firestore — seja pelos triggers de agendamento/pedido, seja pelo
 * job de lembretes agendado. Remove tokens inválidos/expirados do array
 * do utilizador para não voltarmos a tentar enviar-lhes para sempre.
 */
exports.onNotificacaoCriada = onDocumentCreated(
  { document: 'notificacoes/{notificacaoId}', region: REGIAO },
  async (event) => {
    const notif = event.data.data();
    const db = getFirestore();

    try {
      const userRef = db.collection('clientes').doc(notif.destinatarioId);
      const userDoc = await userRef.get();
      const tokens = userDoc.exists ? (userDoc.data().fcmTokens || []) : [];
      if (tokens.length === 0) return;

      const resposta = await getMessaging().sendEachForMulticast({
        tokens,
        notification: { title: notif.titulo, body: notif.corpo },
        data: {
          tipo: notif.tipo || '',
          referenciaId: notif.referenciaId || '',
          referenciaTipo: notif.referenciaTipo || '',
          notificacaoId: event.params.notificacaoId,
        },
      });

      const tokensInvalidos = [];
      resposta.responses.forEach((r, i) => {
        if (!r.success) {
          const codigo = r.error && r.error.code;
          if (
            codigo === 'messaging/invalid-registration-token' ||
            codigo === 'messaging/registration-token-not-registered'
          ) {
            tokensInvalidos.push(tokens[i]);
          }
        }
      });

      if (tokensInvalidos.length > 0) {
        await userRef.update({ fcmTokens: FieldValue.arrayRemove(...tokensInvalidos) });
      }
    } catch (e) {
      logger.error('Erro ao enviar push da notificação:', e);
    }
  }
);

// ---------------------------------------------------------------------
// AGENDAMENTOS
// ---------------------------------------------------------------------

// 1. Quando um agendamento é criado -> email "recebido" + notificar admin
exports.onAgendamentoCriado = onDocumentCreated(
  { document: 'agendamentos/{agendamentoId}', region: REGIAO, secrets: SECRETS },
  async (event) => {
    const ag = event.data.data();
    const db = getFirestore();

    if (ag.clienteEmail) {
      await enviarEmail({
        para: ag.clienteEmail,
        assunto: 'Recebemos o teu agendamento — Loah Stúdio',
        html: agendamentoRecebidoEmail(ag),
      });
    }

    const adminUid = await getAdminUid(db);
    if (adminUid) {
      await criarNotificacao(db, {
        destinatarioId: adminUid,
        tipo: 'agendamento_criado',
        titulo: 'Novo agendamento',
        corpo: `${ag.clienteNome} marcou ${ag.servicoNome} para ${formatarDataPt(ag.data)} às ${ag.horaInicio}.`,
        referenciaId: event.params.agendamentoId,
        referenciaTipo: 'agendamento',
      });
    }
  }
);

// 2. Quando um agendamento é atualizado -> confirmado / cancelado / reagendado / concluído
exports.onAgendamentoAtualizado = onDocumentUpdated(
  { document: 'agendamentos/{agendamentoId}', region: REGIAO, secrets: SECRETS },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    const db = getFirestore();
    const agendamentoId = event.params.agendamentoId;

    const foiCancelado = before.status !== 'cancelado' && after.status === 'cancelado';
    const foiConfirmado = before.status !== 'confirmado' && after.status === 'confirmado';
    const foiConcluido = before.status !== 'concluido' && after.status === 'concluido';
    const dataMudou = before.data.toMillis() !== after.data.toMillis();
    const horaMudou = before.horaInicio !== after.horaInicio;
    const foiReagendado = (dataMudou || horaMudou) && after.status !== 'cancelado' && !foiConfirmado;

    // Emails (comportamento já existente, inalterado)
    if (after.clienteEmail) {
      try {
        if (foiCancelado) {
          await enviarEmail({
            para: after.clienteEmail,
            assunto: 'O teu agendamento foi cancelado — Loah Stúdio',
            html: agendamentoCanceladoEmail(after),
          });
        } else if (foiConfirmado) {
          await enviarEmail({
            para: after.clienteEmail,
            assunto: 'Agendamento confirmado! — Loah Stúdio',
            html: agendamentoConfirmadoEmail(after),
          });
        } else if (foiConcluido) {
          await enviarEmail({
            para: after.clienteEmail,
            assunto: 'Que tal deixar uma avaliação? — Loah Stúdio',
            html: pedidoAvaliacaoEmail({ clienteNome: after.clienteNome, servicoNome: after.servicoNome }),
          });
        } else if (foiReagendado) {
          await enviarEmail({
            para: after.clienteEmail,
            assunto: 'O teu agendamento foi atualizado — Loah Stúdio',
            html: agendamentoAtualizadoEmail(before, after),
          });
        }
      } catch (e) {
        logger.error('Erro ao processar email de atualização de agendamento:', e);
      }
    }

    // Notificações in-app + push
    try {
      const adminUid = await getAdminUid(db);

      if (foiCancelado) {
        await criarNotificacao(db, {
          destinatarioId: after.clienteId,
          tipo: 'agendamento_cancelado',
          titulo: 'Agendamento cancelado',
          corpo: `O teu agendamento de ${after.servicoNome} no dia ${formatarDataPt(after.data)} foi cancelado.`,
          referenciaId: agendamentoId,
          referenciaTipo: 'agendamento',
        });
        if (adminUid) {
          await criarNotificacao(db, {
            destinatarioId: adminUid,
            tipo: 'agendamento_cancelado',
            titulo: 'Agendamento cancelado',
            corpo: `O agendamento de ${after.clienteNome} (${after.servicoNome}) foi cancelado.`,
            referenciaId: agendamentoId,
            referenciaTipo: 'agendamento',
          });
        }
      } else if (foiConfirmado) {
        await criarNotificacao(db, {
          destinatarioId: after.clienteId,
          tipo: 'agendamento_confirmado',
          titulo: 'Agendamento confirmado!',
          corpo: `O teu agendamento de ${after.servicoNome} no dia ${formatarDataPt(after.data)} às ${after.horaInicio} foi confirmado.`,
          referenciaId: agendamentoId,
          referenciaTipo: 'agendamento',
        });
      } else if (foiConcluido) {
        await criarNotificacao(db, {
          destinatarioId: after.clienteId,
          tipo: 'agendamento_concluido',
          titulo: 'Serviço concluído',
          corpo: `Esperamos que tenhas gostado do teu ${after.servicoNome}! Que tal deixares uma avaliação?`,
          referenciaId: agendamentoId,
          referenciaTipo: 'agendamento',
        });
      } else if (foiReagendado) {
        await criarNotificacao(db, {
          destinatarioId: after.clienteId,
          tipo: 'agendamento_reagendado',
          titulo: 'Agendamento atualizado',
          corpo: `O teu agendamento foi atualizado para ${formatarDataPt(after.data)} às ${after.horaInicio}.`,
          referenciaId: agendamentoId,
          referenciaTipo: 'agendamento',
        });
        if (adminUid) {
          await criarNotificacao(db, {
            destinatarioId: adminUid,
            tipo: 'agendamento_reagendado',
            titulo: 'Agendamento atualizado',
            corpo: `O agendamento de ${after.clienteNome} foi atualizado para ${formatarDataPt(after.data)} às ${after.horaInicio}.`,
            referenciaId: agendamentoId,
            referenciaTipo: 'agendamento',
          });
        }
      }
    } catch (e) {
      logger.error('Erro ao criar notificações de atualização de agendamento:', e);
    }
  }
);

// ---------------------------------------------------------------------
// PEDIDOS
// ---------------------------------------------------------------------

// 5. Quando um pedido é criado -> email "recebido" + notificar admin
exports.onPedidoCriado = onDocumentCreated(
  { document: 'pedidos/{pedidoId}', region: REGIAO, secrets: SECRETS },
  async (event) => {
    const pedido = event.data.data();
    const db = getFirestore();

    if (pedido.clienteEmail) {
      await enviarEmail({
        para: pedido.clienteEmail,
        assunto: 'Recebemos o teu pedido — Loah Stúdio',
        html: pedidoRecebidoEmail(pedido),
      });
    }

    const adminUid = await getAdminUid(db);
    if (adminUid) {
      const valor = (pedido.valorTotal || 0).toFixed(2).replace('.', ',');
      await criarNotificacao(db, {
        destinatarioId: adminUid,
        tipo: 'pedido_criado',
        titulo: 'Nova encomenda',
        corpo: `${pedido.clienteNome} fez uma encomenda no valor de €${valor}.`,
        referenciaId: event.params.pedidoId,
        referenciaTipo: 'pedido',
      });
    }
  }
);

// 6. Quando um pedido é atualizado -> confirmado / preparando / entregue / cancelado
exports.onPedidoAtualizado = onDocumentUpdated(
  { document: 'pedidos/{pedidoId}', region: REGIAO, secrets: SECRETS },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    const db = getFirestore();
    const pedidoId = event.params.pedidoId;

    const foiConfirmado = before.status !== 'confirmado' && after.status === 'confirmado';
    const foiPreparando = before.status !== 'preparando' && after.status === 'preparando';
    const foiEntregue = before.status !== 'entregue' && after.status === 'entregue';
    const foiCancelado = before.status !== 'cancelado' && after.status === 'cancelado';

    // Emails (comportamento já existente, inalterado)
    if (after.clienteEmail) {
      try {
        if (foiConfirmado) {
          await enviarEmail({
            para: after.clienteEmail,
            assunto: 'Pagamento confirmado! — Loah Stúdio',
            html: pedidoConfirmadoEmail(after),
          });
        } else if (foiEntregue) {
          await enviarEmail({
            para: after.clienteEmail,
            assunto: 'O teu pedido foi entregue — Loah Stúdio',
            html: pedidoEntregueEmail(after),
          });
        }
      } catch (e) {
        logger.error('Erro ao processar email de atualização de pedido:', e);
      }
    }

    // Notificações in-app + push
    try {
      if (foiConfirmado) {
        await criarNotificacao(db, {
          destinatarioId: after.clienteId,
          tipo: 'pedido_confirmado',
          titulo: 'Pagamento confirmado!',
          corpo: 'Recebemos o pagamento da tua encomenda. Vamos já prepará-la.',
          referenciaId: pedidoId,
          referenciaTipo: 'pedido',
        });
      } else if (foiPreparando) {
        await criarNotificacao(db, {
          destinatarioId: after.clienteId,
          tipo: 'pedido_preparando',
          titulo: 'Encomenda em preparação',
          corpo: 'A tua encomenda está a ser preparada.',
          referenciaId: pedidoId,
          referenciaTipo: 'pedido',
        });
      } else if (foiEntregue) {
        await criarNotificacao(db, {
          destinatarioId: after.clienteId,
          tipo: 'pedido_entregue',
          titulo: 'Encomenda entregue',
          corpo: 'A tua encomenda foi entregue. Esperamos que gostes!',
          referenciaId: pedidoId,
          referenciaTipo: 'pedido',
        });
      } else if (foiCancelado) {
        await criarNotificacao(db, {
          destinatarioId: after.clienteId,
          tipo: 'pedido_cancelado',
          titulo: 'Encomenda cancelada',
          corpo: 'A tua encomenda foi cancelada.',
          referenciaId: pedidoId,
          referenciaTipo: 'pedido',
        });
        const adminUid = await getAdminUid(db);
        if (adminUid) {
          await criarNotificacao(db, {
            destinatarioId: adminUid,
            tipo: 'pedido_cancelado',
            titulo: 'Encomenda cancelada',
            corpo: `A encomenda de ${after.clienteNome} foi cancelada.`,
            referenciaId: pedidoId,
            referenciaTipo: 'pedido',
          });
        }
      }
    } catch (e) {
      logger.error('Erro ao criar notificações de atualização de pedido:', e);
    }
  }
);

// 3. Callable — admin pede avaliação a um cliente (envio manual, à parte
// do envio automático que já acontece em onAgendamentoAtualizado)
exports.enviarPedidoAvaliacao = onCall(
  { region: REGIAO, secrets: SECRETS },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'É preciso estar autenticado.');
    }

    const uid = request.auth.uid;
    const clienteDoc = await getFirestore().collection('clientes').doc(uid).get();
    const role = clienteDoc.exists ? clienteDoc.data().role : null;

    if (role !== 'admin') {
      throw new HttpsError('permission-denied', 'Apenas administradores podem enviar este email.');
    }

    const { clienteEmail, clienteNome, servicoNome } = request.data;
    if (!clienteEmail || !clienteNome) {
      throw new HttpsError('invalid-argument', 'clienteEmail e clienteNome são obrigatórios.');
    }

    const enviado = await enviarEmail({
      para: clienteEmail,
      assunto: 'Que tal deixar uma avaliação? — Loah Stúdio',
      html: pedidoAvaliacaoEmail({ clienteNome, servicoNome }),
    });

    return { sucesso: enviado };
  }
);

exports.criarAgendamento = onCall({ region: REGIAO }, async (request) => {
  const uid = request.auth?.uid ?? null;
  const {
    clienteNome, clienteEmail, clienteTelefone, observacao,
    servicoId, servicoNome, servicoPreco, servicoDuracaoMinutos,
    data, horaInicio, horaFim,
  } = request.data;

  if (!clienteNome || !clienteEmail || !clienteTelefone || !servicoId ||
      !data || !horaInicio || !horaFim) {
    throw new HttpsError('invalid-argument', 'Faltam dados obrigatórios do agendamento.');
  }

  const db = getFirestore();
  const dataObj = new Date(data); // o cliente envia um ISO string
  const inicioDoDia = new Date(Date.UTC(dataObj.getUTCFullYear(), dataObj.getUTCMonth(), dataObj.getUTCDate()));
  const fimDoDia = new Date(inicioDoDia.getTime() + 24 * 60 * 60 * 1000);

  const parseHora = (h) => {
    const [hh, mm] = h.split(':').map(Number);
    return hh * 60 + mm;
  };
  const inicioNovoMin = parseHora(horaInicio);
  const fimNovoMin = parseHora(horaFim);

  const agendamentoRef = db.collection('agendamentos').doc();
  const ocupadoRef = db.collection('horariosOcupados').doc();

  try {
    await db.runTransaction(async (tx) => {
      const ocupadosSnap = await tx.get(
        db.collection('horariosOcupados')
          .where('data', '>=', Timestamp.fromDate(inicioDoDia))
          .where('data', '<', Timestamp.fromDate(fimDoDia))
      );

      const conflita = ocupadosSnap.docs.some((doc) => {
        const o = doc.data();
        const oInicio = parseHora(o.horaInicio);
        const oFim = parseHora(o.horaFim);
        return inicioNovoMin < oFim && fimNovoMin > oInicio;
      });

      if (conflita) {
        throw new HttpsError('already-exists', 'Este horário acabou de ser reservado por outra pessoa.');
      }

      tx.set(agendamentoRef, {
        clienteId: uid,
        clienteNome,
        clienteEmail: clienteEmail.toLowerCase(),
        clienteTelefone,
        observacao: observacao || null,
        servicoId,
        servicoNome,
        servicoPreco,
        servicoDuracaoMinutos,
        data: Timestamp.fromDate(inicioDoDia),
        horaInicio,
        horaFim,
        status: 'pendente',
        lembrete24hEnviado: false,
        lembrete1hEnviado: false,
        criadoEm: FieldValue.serverTimestamp(),
      });

      tx.set(ocupadoRef, {
        agendamentoId: agendamentoRef.id,
        data: Timestamp.fromDate(inicioDoDia),
        horaInicio,
        horaFim,
      });
    });

    return { sucesso: true, agendamentoId: agendamentoRef.id };
  } catch (e) {
    if (e instanceof HttpsError) throw e;
    logger.error('Erro ao criar agendamento:', e);
    throw new HttpsError('internal', 'Não foi possível criar o agendamento. Tenta novamente.');
  }
});

// ---------------------------------------------------------------------
// AGENDADO — a cada 15 minutos
// ---------------------------------------------------------------------

/**
 * Devolve o offset (em minutos) de Europe/Lisbon para uma data UTC dada,
 * já considerando horário de verão (WEST, +1h) vs inverno (WET, +0h).
 */
function offsetLisboaMinutos(dataUtc) {
  const partes = new Intl.DateTimeFormat('en-US', {
    timeZone: 'Europe/Lisbon',
    timeZoneName: 'shortOffset',
    hour: '2-digit',
  }).formatToParts(dataUtc);

  const nomeOffset = partes.find((p) => p.type === 'timeZoneName')?.value || 'GMT+0';
  const match = nomeOffset.match(/GMT([+-]\d+)(?::(\d+))?/);
  if (!match) return 0;

  const horas = parseInt(match[1], 10);
  const minutos = match[2] ? parseInt(match[2], 10) : 0;
  return horas * 60 + (horas < 0 ? -minutos : minutos);
}

/**
 * Calcula o instante UTC real de um horário ('horaFim' ou 'horaInicio') de
 * um agendamento, combinando o dia guardado em 'data' (meia-noite UTC do
 * dia-calendário de Lisboa) com a hora local de Lisboa fornecida.
 */
function calcularInstante(ag, campoHora) {
  const dataBase = ag.data.toDate();
  const [hh, mm] = ag[campoHora].split(':').map(Number);
  const offsetMin = offsetLisboaMinutos(dataBase);

  const utcMillis = Date.UTC(
    dataBase.getUTCFullYear(),
    dataBase.getUTCMonth(),
    dataBase.getUTCDate(),
    hh,
    mm
  ) - offsetMin * 60000;

  return new Date(utcMillis);
}

/**
 * Marca como 'concluido' todo o 'confirmado' cuja hora de FIM já passou.
 */
async function concluirConfirmadosVencidos(db, agora) {
  const snap = await db.collection('agendamentos')
    .where('status', '==', 'confirmado')
    .where('data', '<=', Timestamp.fromDate(agora))
    .get();

  if (snap.empty) return 0;

  const batch = db.batch();
  let count = 0;

  for (const doc of snap.docs) {
    const ag = doc.data();
    if (!ag.horaFim || !ag.data) continue;

    const fim = calcularInstante(ag, 'horaFim');
    if (fim <= agora) {
      batch.update(doc.ref, {
        status: 'concluido',
        atualizadoEm: FieldValue.serverTimestamp(),
      });
      count++;
    }
  }

  if (count > 0) await batch.commit();
  return count;
}

/**
 * Marca como 'expirado' todo o 'pendente' cuja hora de INÍCIO já passou —
 * nunca chegou a ser confirmado nem cancelado a tempo. Sem email/notificação:
 * é limpeza interna, não um evento que o cliente precise de saber.
 */
async function expirarPendentesVencidos(db, agora) {
  const snap = await db.collection('agendamentos')
    .where('status', '==', 'pendente')
    .where('data', '<=', Timestamp.fromDate(agora))
    .get();

  if (snap.empty) return 0;

  const batch = db.batch();
  let count = 0;

  for (const doc of snap.docs) {
    const ag = doc.data();
    if (!ag.horaInicio || !ag.data) continue;

    const inicio = calcularInstante(ag, 'horaInicio');
    if (inicio <= agora) {
      batch.update(doc.ref, {
        status: 'expirado',
        atualizadoEm: FieldValue.serverTimestamp(),
      });
      count++;
    }
  }

  if (count > 0) await batch.commit();
  return count;
}

/**
 * Envia lembretes de 24h e de 1h antes do início, só para agendamentos
 * 'confirmado'. Usa 'lembrete24hEnviado'/'lembrete1hEnviado' no próprio
 * documento para nunca enviar duas vezes o mesmo lembrete. A janela de
 * 48h na query é só para reduzir os documentos lidos — a decisão real
 * (24h vs 1h) é feita com o instante exato calculado em memória.
 */
async function enviarLembretesAgendamentos(db, agora) {
  const inicioDeHoje = new Date(Date.UTC(agora.getUTCFullYear(), agora.getUTCMonth(), agora.getUTCDate()));
  const em48h = new Date(agora.getTime() + 48 * 60 * 60 * 1000);

  const snap = await db.collection('agendamentos')
    .where('status', '==', 'confirmado')
    .where('data', '>=', Timestamp.fromDate(inicioDeHoje))
    .where('data', '<=', Timestamp.fromDate(em48h))
    .get();

  if (snap.empty) return { lembretes24h: 0, lembretes1h: 0 };

  let count24 = 0;
  let count1 = 0;
  const batch = db.batch();

  for (const doc of snap.docs) {
    const ag = doc.data();
    if (!ag.horaInicio || !ag.data || !ag.clienteId) continue;

    const inicio = calcularInstante(ag, 'horaInicio');
    const diffHoras = (inicio.getTime() - agora.getTime()) / (60 * 60 * 1000);

    if (!ag.lembrete24hEnviado && diffHoras <= 24 && diffHoras > 1) {
      batch.set(db.collection('notificacoes').doc(), {
        destinatarioId: ag.clienteId,
        tipo: 'agendamento_lembrete_24h',
        titulo: 'O teu agendamento é amanhã',
        corpo: `Não te esqueças: ${ag.servicoNome} amanhã às ${ag.horaInicio}.`,
        referenciaId: doc.id,
        referenciaTipo: 'agendamento',
        lida: false,
        criadoEm: FieldValue.serverTimestamp(),
      });
      batch.update(doc.ref, { lembrete24hEnviado: true });
      count24++;
    }

    if (!ag.lembrete1hEnviado && diffHoras <= 1 && diffHoras > 0) {
      batch.set(db.collection('notificacoes').doc(), {
        destinatarioId: ag.clienteId,
        tipo: 'agendamento_lembrete_1h',
        titulo: 'O teu agendamento é já daqui a 1 hora',
        corpo: `${ag.servicoNome} às ${ag.horaInicio}. Até já!`,
        referenciaId: doc.id,
        referenciaTipo: 'agendamento',
        lida: false,
        criadoEm: FieldValue.serverTimestamp(),
      });
      batch.update(doc.ref, { lembrete1hEnviado: true });
      count1++;
    }
  }

  if (count24 + count1 > 0) await batch.commit();
  return { lembretes24h: count24, lembretes1h: count1 };
}

exports.processarAgendamentosVencidos = onSchedule(
  { schedule: 'every 15 minutes', region: REGIAO, timeZone: 'Europe/Lisbon' },
  async () => {
    const db = getFirestore();
    const agora = new Date();

    const [concluidos, expirados, lembretes] = await Promise.all([
      concluirConfirmadosVencidos(db, agora),
      expirarPendentesVencidos(db, agora),
      enviarLembretesAgendamentos(db, agora),
    ]);

    logger.info(
      `Processamento de agendamentos: ${concluidos} concluído(s), ${expirados} expirado(s), ` +
      `${lembretes.lembretes24h} lembrete(s) 24h, ${lembretes.lembretes1h} lembrete(s) 1h.`
    );
  }
);