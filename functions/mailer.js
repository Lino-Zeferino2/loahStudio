const nodemailer = require('nodemailer');
const { defineSecret } = require('firebase-functions/params');
const { logger } = require('firebase-functions');

const gmailEmail = defineSecret('GMAIL_EMAIL');
const gmailAppPassword = defineSecret('GMAIL_APP_PASSWORD');

// IMPORTANTE: substitui pelo domínio real do teu site quando o tiveres
const SITE_URL = 'https://myloahstudio.web.app';

let transporter = null;

function getTransporter() {
  if (!transporter) {
    transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: gmailEmail.value(),
        pass: gmailAppPassword.value(),
      },
    });
  }
  return transporter;
}

async function enviarEmail({ para, assunto, html }) {
  try {
    await getTransporter().sendMail({
      from: `"Loah Stúdio" <${gmailEmail.value()}>`,
      to: para,
      subject: assunto,
      html,
    });
    logger.info(`Email enviado para ${para}: ${assunto}`);
    return true;
  } catch (e) {
    logger.error(`Erro ao enviar email para ${para}:`, e);
    return false;
  }
}

module.exports = { enviarEmail, gmailEmail, gmailAppPassword, SITE_URL };