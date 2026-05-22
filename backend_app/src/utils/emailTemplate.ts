/**
 * Generates a professional, mobile-responsive HTML email template for Bitesmart OTP / Forgot Password.
 * @param code The 6-digit verification code.
 */
export const getForgotEmailTemplate = (code: string): string => {
    return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Your Bitesmart Password</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      background-color: #f8fafc;
      color: #1e293b;
      margin: 0;
      padding: 0;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }
    .wrapper {
      width: 100%;
      background-color: #f8fafc;
      padding: 40px 20px;
      box-sizing: border-box;
    }
    .container {
      max-width: 500px;
      margin: 0 auto;
      background-color: #ffffff;
      border-radius: 16px;
      border: 1px solid #e2e8f0;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
      overflow: hidden;
    }
    .header {
      background-color: #0f172a;
      padding: 32px 24px;
      text-align: center;
    }
    .header-title {
      color: #f8fafc;
      font-size: 20px;
      font-weight: 700;
      margin: 0;
      letter-spacing: 0.5px;
    }
    .content {
      padding: 40px 32px;
    }
    .greeting {
      font-size: 18px;
      font-weight: 600;
      color: #0f172a;
      margin-top: 0;
      margin-bottom: 16px;
    }
    .description {
      font-size: 15px;
      line-height: 1.6;
      color: #475569;
      margin-bottom: 32px;
    }
    .code-container {
      background-color: #f1f5f9;
      border-radius: 12px;
      padding: 24px;
      text-align: center;
      margin-bottom: 32px;
      border: 1px solid #e2e8f0;
    }
    .code-label {
      font-size: 12px;
      text-transform: uppercase;
      letter-spacing: 1.5px;
      color: #64748b;
      font-weight: 700;
      margin-bottom: 12px;
    }
    .code-value {
      font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, Courier, monospace;
      font-size: 38px;
      font-weight: 800;
      color: #0f172a;
      letter-spacing: 6px;
      margin: 0;
      padding-left: 6px; /* balanced letter spacing offset */
    }
    .expiry-note {
      font-size: 13px;
      color: #94a3b8;
      text-align: center;
      margin-top: 0;
      margin-bottom: 32px;
    }
    .divider {
      height: 1px;
      background-color: #e2e8f0;
      margin-bottom: 24px;
    }
    .warning {
      font-size: 13px;
      line-height: 1.5;
      color: #64748b;
    }
    .footer {
      background-color: #f8fafc;
      padding: 24px 32px;
      text-align: center;
      font-size: 12px;
      color: #94a3b8;
      border-top: 1px solid #e2e8f0;
    }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="container">
      <div class="header">
        <h1 class="header-title">BITESMART</h1>
      </div>
      <div class="content">
        <p class="greeting">Hello,</p>
        <p class="description">We received a request to reset the password for your Bitesmart account. Please use the verification code below to complete the password reset process:</p>
        
        <div class="code-container">
          <div class="code-label">Verification PIN Code</div>
          <div class="code-value">${code}</div>
        </div>
        
        <p class="expiry-note">This code will expire in 15 minutes. For security reasons, do not share this code with anyone.</p>
        
        <div class="divider"></div>
        
        <p class="warning"><strong>Didn't request this?</strong> If you didn't ask to reset your password, you can safely ignore this email. Your account remains secure.</p>
      </div>
      <div class="footer">
        <p>&copy; ${new Date().getFullYear()} Bitesmart. All rights reserved.</p>
        <p>This is an automated message, please do not reply directly to this email.</p>
      </div>
    </div>
  </div>
</body>
</html>`;
};
