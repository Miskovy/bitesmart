import nodemailer from 'nodemailer';
import 'dotenv/config';

const isEmailConfigured = !!(
  process.env.EMAIL_USER &&
  process.env.EMAIL_PASS &&
  process.env.EMAIL_USER !== 'your_email@gmail.com' &&
  process.env.EMAIL_PASS !== 'your_gmail_app_password'
);

const transporter = isEmailConfigured
  ? nodemailer.createTransport({
      service: 'gmail', // You can change this to your email provider
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    })
  : null;

export const sendEmail = async (to: string, subject: string, text: string, html?: string) => {
  const mailOptions = {
    from: `"Bitesmart Support" <${process.env.EMAIL_USER || 'no-reply@bitesmart.com'}>`,
    to,
    subject,
    text,
    html,
  };

  if (!isEmailConfigured || !transporter) {
    console.log("\n==================================================");
    console.log("📨 EMAIL SMTP NOT CONFIGURRED (Add EMAIL_USER & EMAIL_PASS to .env)");
    console.log(`To: ${to}`);
    console.log(`Subject: ${subject}`);
    console.log(`Text Body: ${text}`);
    if (html) {
      console.log(`HTML Template: [Ready & Rendered]`);
    }
    console.log("==================================================\n");
    return;
  }

  try {
    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error('Error sending email:', error);
    throw new Error('Could not send email');
  }
};
