const { SITE_URL } = require('./mailer');

const CORES = {
  brown: '#5A4A42',
  brownLight: '#7A6A62',
  pink: '#D48A99',
  pinkNude: '#F3D9DE',
  bg: '#FDF8F6',
  white: '#FFFFFF',
};

function formatarData(timestampOrDate) {
  const date = timestampOrDate.toDate ? timestampOrDate.toDate() : new Date(timestampOrDate);
  const dias = ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
  const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
  return `${dias[date.getDay()]}, ${date.getDate()} de ${meses[date.getMonth()]} de ${date.getFullYear()}`;
}

function formatarDuracao(minutos) {
  const h = Math.floor(minutos / 60);
  const m = minutos % 60;
  if (h === 0) return `${m} min`;
  if (m === 0) return `${h}h`;
  return `${h}h ${m}min`;
}

function formatarPreco(valor) {
  return `${valor.toFixed(2).replace('.', ',')} €`;
}

function emailBase({ preheader, tituloTopo, subtitulo, corTopo, conteudoHtml, cta }) {
  return `<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Loah Stúdio</title>
</head>
<body style="margin:0; padding:0; background-color:${CORES.bg}; font-family: 'Helvetica Neue', Arial, sans-serif;">
  <div style="display:none; max-height:0; overflow:hidden;">${preheader}</div>
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:${CORES.bg}; padding: 32px 16px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" style="max-width:560px; background-color:${CORES.white}; border-radius:16px; overflow:hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.06);">

          <tr>
            <td style="background-color:${corTopo || CORES.pink}; padding: 36px 32px; text-align:center;">
              <p style="margin:0 0 4px; color:${CORES.white}; font-size:13px; letter-spacing:4px; font-weight:600; opacity:0.9;">LOAH STÚDIO</p>
              <h1 style="margin:0; color:${CORES.white}; font-size:22px; font-weight:700;">${tituloTopo}</h1>
              ${subtitulo ? `<p style="margin:8px 0 0; color:${CORES.white}; font-size:14px; opacity:0.9;">${subtitulo}</p>` : ''}
            </td>
          </tr>

          <tr>
            <td style="padding: 32px;">
              ${conteudoHtml}
            </td>
          </tr>

          ${cta ? `
          <tr>
            <td style="padding: 0 32px 32px; text-align:center;">
              <a href="${cta.url}" style="display:inline-block; background-color:${CORES.pink}; color:${CORES.white}; text-decoration:none; font-weight:600; font-size:14px; padding: 14px 32px; border-radius:24px;">${cta.texto}</a>
            </td>
          </tr>` : ''}

          <tr>
            <td style="background-color:${CORES.bg}; padding: 24px 32px; text-align:center; border-top: 1px solid #F0E8E5;">
              <p style="margin:0 0 8px; color:${CORES.brownLight}; font-size:12px;">Loah Stúdio · Cuidados de beleza</p>
              <a href="${SITE_URL}" style="color:${CORES.pink}; font-size:12px; text-decoration:none; font-weight:600;">${SITE_URL.replace('https://', '')}</a>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

function resumoAgendamentoHtml(ag) {
  const linha = (label, valor) => `
    <tr>
      <td style="padding: 10px 0; border-bottom: 1px solid #F0E8E5; color:${CORES.brownLight}; font-size:13px;">${label}</td>
      <td style="padding: 10px 0; border-bottom: 1px solid #F0E8E5; color:${CORES.brown}; font-size:13px; font-weight:600; text-align:right;">${valor}</td>
    </tr>`;

  return `
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:${CORES.bg}; border-radius:12px; padding: 4px 20px; margin: 20px 0;">
    ${linha('Serviço', ag.servicoNome)}
    ${linha('Data', formatarData(ag.data))}
    ${linha('Hora', `${ag.horaInicio} — ${ag.horaFim}`)}
    ${linha('Duração', formatarDuracao(ag.servicoDuracaoMinutos))}
    ${linha('Valor', formatarPreco(ag.servicoPreco))}
    ${linha('Nome', ag.clienteNome)}
  </table>`;
}

function agendamentoRecebidoEmail(ag) {
  const conteudo = `
    <p style="margin:0 0 4px; color:${CORES.brown}; font-size:15px;">Olá, <strong>${ag.clienteNome}</strong> 👋</p>
    <p style="margin:12px 0 0; color:${CORES.brownLight}; font-size:14px; line-height:1.6;">
      Recebemos o teu pedido de agendamento! Neste momento está <strong>pendente de confirmação</strong> —
      vamos rever a disponibilidade e enviamos-te outro email assim que for confirmado.
    </p>
    ${resumoAgendamentoHtml(ag)}
    <p style="margin:20px 0 0; color:${CORES.brownLight}; font-size:13px; line-height:1.6;">
      Não precisas de fazer mais nada por agora. Se tiveres alguma dúvida, contacta-nos através do site.
    </p>`;

  return emailBase({
    preheader: 'Recebemos o teu agendamento — a aguardar confirmação.',
    tituloTopo: 'Agendamento recebido ✓',
    subtitulo: 'A aguardar confirmação',
    corTopo: CORES.brown,
    conteudoHtml: conteudo,
    cta: { texto: 'Ver o site', url: SITE_URL },
  });
}

function agendamentoConfirmadoEmail(ag) {
  const conteudo = `
    <p style="margin:0 0 4px; color:${CORES.brown}; font-size:15px;">Boas notícias, <strong>${ag.clienteNome}</strong>! 🎉</p>
    <p style="margin:12px 0 0; color:${CORES.brownLight}; font-size:14px; line-height:1.6;">
      O teu agendamento foi <strong>confirmado</strong>. Aqui está o resumo:
    </p>
    ${resumoAgendamentoHtml(ag)}
    <p style="margin:20px 0 0; color:${CORES.brownLight}; font-size:13px; line-height:1.6;">
      Aguardamos por ti! Se precisares de reagendar ou cancelar, entra em contacto connosco com antecedência.
    </p>`;

  return emailBase({
    preheader: 'O teu agendamento foi confirmado!',
    tituloTopo: 'Agendamento confirmado ✓',
    subtitulo: 'Vemo-nos em breve',
    corTopo: CORES.pink,
    conteudoHtml: conteudo,
    cta: { texto: 'Ver os meus agendamentos', url: SITE_URL },
  });
}

function agendamentoCanceladoEmail(ag, motivo) {
  const conteudo = `
    <p style="margin:0 0 4px; color:${CORES.brown}; font-size:15px;">Olá, <strong>${ag.clienteNome}</strong></p>
    <p style="margin:12px 0 0; color:${CORES.brownLight}; font-size:14px; line-height:1.6;">
      Informamos que o teu agendamento abaixo foi <strong>cancelado</strong>.
      ${motivo ? `Motivo: ${motivo}` : 'Pedimos desculpa pelo incómodo.'}
    </p>
    ${resumoAgendamentoHtml(ag)}
    <p style="margin:20px 0 0; color:${CORES.brownLight}; font-size:13px; line-height:1.6;">
      Podes fazer um novo agendamento a qualquer momento através do nosso site.
    </p>`;

  return emailBase({
    preheader: 'O teu agendamento foi cancelado.',
    tituloTopo: 'Agendamento cancelado',
    subtitulo: null,
    corTopo: '#B5726B',
    conteudoHtml: conteudo,
    cta: { texto: 'Fazer novo agendamento', url: SITE_URL },
  });
}

function agendamentoAtualizadoEmail(agAntigo, agNovo) {
  const conteudo = `
    <p style="margin:0 0 4px; color:${CORES.brown}; font-size:15px;">Olá, <strong>${agNovo.clienteNome}</strong></p>
    <p style="margin:12px 0 0; color:${CORES.brownLight}; font-size:14px; line-height:1.6;">
      O teu agendamento foi <strong>atualizado</strong>. Repara nos novos dados:
    </p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin: 16px 0;">
      <tr>
        <td style="padding: 12px; background-color:#FBEDEC; border-radius:10px 0 0 10px; width:50%; text-align:center;">
          <p style="margin:0; color:${CORES.brownLight}; font-size:11px; text-transform:uppercase; letter-spacing:1px;">Antes</p>
          <p style="margin:6px 0 0; color:${CORES.brown}; font-size:13px; text-decoration:line-through;">${formatarData(agAntigo.data)}<br>${agAntigo.horaInicio}</p>
        </td>
        <td style="padding: 12px; background-color:${CORES.pinkNude}; border-radius:0 10px 10px 0; width:50%; text-align:center;">
          <p style="margin:0; color:${CORES.brownLight}; font-size:11px; text-transform:uppercase; letter-spacing:1px;">Agora</p>
          <p style="margin:6px 0 0; color:${CORES.brown}; font-size:13px; font-weight:700;">${formatarData(agNovo.data)}<br>${agNovo.horaInicio}</p>
        </td>
      </tr>
    </table>
    ${resumoAgendamentoHtml(agNovo)}`;

  return emailBase({
    preheader: 'O teu agendamento foi atualizado.',
    tituloTopo: 'Agendamento atualizado',
    subtitulo: 'Novos data e hora',
    corTopo: CORES.brown,
    conteudoHtml: conteudo,
    cta: { texto: 'Ver detalhes', url: SITE_URL },
  });
}

function pedidoAvaliacaoEmail({ clienteNome, servicoNome }) {
  const conteudo = `
    <p style="margin:0 0 4px; color:${CORES.brown}; font-size:15px;">Olá, <strong>${clienteNome}</strong> 💛</p>
    <p style="margin:12px 0 0; color:${CORES.brownLight}; font-size:14px; line-height:1.6;">
      Esperamos que tenhas gostado do teu ${servicoNome ? `<strong>${servicoNome}</strong>` : 'atendimento'} connosco!
      A tua opinião ajuda-nos imenso a crescer e ajuda outras pessoas a confiar no nosso trabalho.
    </p>
    <div style="background-color:${CORES.bg}; border-radius:12px; padding: 20px; margin: 20px 0;">
      <p style="margin:0 0 10px; color:${CORES.brown}; font-size:13px; font-weight:700;">Como deixar a tua avaliação:</p>
      <p style="margin:0 0 6px; color:${CORES.brownLight}; font-size:13px;">1. Entra no nosso site</p>
      <p style="margin:0 0 6px; color:${CORES.brownLight}; font-size:13px;">2. Vai até à secção <strong>"O que dizem os nossos clientes"</strong> na página inicial</p>
      <p style="margin:0; color:${CORES.brownLight}; font-size:13px;">3. Deixa a tua opinião — demora menos de 1 minuto!</p>
    </div>
    <p style="margin:0; color:${CORES.brownLight}; font-size:13px; line-height:1.6;">
      Obrigado por confiares na Loah Stúdio. 🌸
    </p>`;

  return emailBase({
    preheader: 'A tua opinião é muito importante para nós!',
    tituloTopo: 'Que tal deixar uma avaliação?',
    subtitulo: null,
    corTopo: CORES.pink,
    conteudoHtml: conteudo,
    cta: { texto: 'Deixar a minha avaliação', url: `${SITE_URL}/#avaliacoes` },
  });
}

module.exports = {
  agendamentoRecebidoEmail,
  agendamentoConfirmadoEmail,
  agendamentoCanceladoEmail,
  agendamentoAtualizadoEmail,
  pedidoAvaliacaoEmail,
};