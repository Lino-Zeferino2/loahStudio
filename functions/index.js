const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { logger } = require('firebase-functions');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
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

// 1. Quando um agendamento é criado -> email "recebido"
exports.onAgendamentoCriado = onDocumentCreated(
  { document: 'agendamentos/{agendamentoId}', region: REGIAO, secrets: SECRETS },
  async (event) => {
    const ag = event.data.data();
    if (!ag.clienteEmail) return;

    await enviarEmail({
      para: ag.clienteEmail,
      assunto: 'Recebemos o teu agendamento — Loah Stúdio',
      html: agendamentoRecebidoEmail(ag),
    });
  }
);

// 2. Quando um agendamento é atualizado -> confirmado / cancelado / reagendado / concluído
exports.onAgendamentoAtualizado = onDocumentUpdated(
  { document: 'agendamentos/{agendamentoId}', region: REGIAO, secrets: SECRETS },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!after.clienteEmail) return;

    const foiCancelado = before.status !== 'cancelado' && after.status === 'cancelado';
    const foiConfirmado = before.status !== 'confirmado' && after.status === 'confirmado';
    const foiConcluido = before.status !== 'concluido' && after.status === 'concluido';
    const dataMudou = before.data.toMillis() !== after.data.toMillis();
    const horaMudou = before.horaInicio !== after.horaInicio;
    const foiReagendado = (dataMudou || horaMudou) && after.status !== 'cancelado' && !foiConfirmado;

    // 'expirado' (pendente vencido) é silencioso de propósito — não é um
    // evento que o cliente precise de saber, é só limpeza interna. Nenhuma
    // das flags acima fica true para essa transição, por isso não é preciso
    // nenhum 'if' extra a bloqueá-la.

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
);
// 5. Quando um pedido é criado -> email "recebido, pendente de confirmação"
exports.onPedidoCriado = onDocumentCreated(
  { document: 'pedidos/{pedidoId}', region: REGIAO, secrets: SECRETS },
  async (event) => {
    const pedido = event.data.data();
    if (!pedido.clienteEmail) return;

    await enviarEmail({
      para: pedido.clienteEmail,
      assunto: 'Recebemos o teu pedido — Loah Stúdio',
      html: pedidoRecebidoEmail(pedido),
    });
  }
);

// 6. Quando um pedido é atualizado -> confirmado / entregue
exports.onPedidoAtualizado = onDocumentUpdated(
  { document: 'pedidos/{pedidoId}', region: REGIAO, secrets: SECRETS },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!after.clienteEmail) return;

    const foiConfirmado = before.status !== 'confirmado' && after.status === 'confirmado';
    const foiEntregue = before.status !== 'entregue' && after.status === 'entregue';

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

// 4. Agendado — a cada 15 minutos: (a) 'confirmado' vencido -> 'concluido'
// (dispara o email de avaliação via onAgendamentoAtualizado acima), e
// (b) 'pendente' vencido -> 'expirado' (silencioso, sem email nenhum).

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
 * nunca chegou a ser confirmado nem cancelado a tempo. Sem email: é
 * limpeza interna, não um evento que o cliente precise de saber.
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

exports.processarAgendamentosVencidos = onSchedule(
  { schedule: 'every 15 minutes', region: REGIAO, timeZone: 'Europe/Lisbon' },
  async () => {
    const db = getFirestore();
    const agora = new Date();

    const [concluidos, expirados] = await Promise.all([
      concluirConfirmadosVencidos(db, agora),
      expirarPendentesVencidos(db, agora),
    ]);

    logger.info(`Processamento de agendamentos vencidos: ${concluidos} concluído(s), ${expirados} expirado(s).`);
  }
);