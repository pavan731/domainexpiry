const axios = require('axios');
const { getCertificate } = require('ssl-certificate-expiration-date');

async function sendSlackNotification(domain, daysLeft) {
  const slackWebhook = process.env.https://hooks.slack.com/services/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;
  const message = `SSL Expiry Alert\n` +
    `   * Domain: ${domain}\n` +
    `   * Warning: The SSL certificate for ${domain} will expire in ${daysLeft} days.`;

  await axios.post(slackWebhook, { text: message });
}

async function main() {
  try {
    const domain = 'google.com';
    
    const certificateInfo = await getCertificate(domain);
    const currentDate = new Date();
    const daysLeft = Math.floor((certificateInfo.validTo - currentDate) / (1000 * 60 * 60 * 24));

    if (daysLeft <= 30000) {
      await sendSlackNotification(domain, daysLeft);
    }
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
