const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
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

// 2. Quando um agendamento é atualizado -> confirmado / cancelado / reagendado
exports.onAgendamentoAtualizado = onDocumentUpdated(
  { document: 'agendamentos/{agendamentoId}', region: REGIAO, secrets: SECRETS },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!after.clienteEmail) return;

    const foiCancelado = before.status !== 'cancelado' && after.status === 'cancelado';
    const foiConfirmado = before.status !== 'confirmado' && after.status === 'confirmado';
    const dataMudou = before.data.toMillis() !== after.data.toMillis();
    const horaMudou = before.horaInicio !== after.horaInicio;
    const foiReagendado = (dataMudou || horaMudou) && after.status !== 'cancelado' && !foiConfirmado;

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
      // Lê os horários ocupados desse dia DENTRO da transação — se outro
      // pedido escrever entretanto, a transação repete automaticamente.
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
// 3. Callable — admin pede avaliação a um cliente
// Verifica admin através da coleção 'clientes', campo 'role' === 'admin'
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