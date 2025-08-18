<?php
// backend/services/EmailService.php
class EmailService {
    private static $instance = null;
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    /**
     * Send password reset email
     */
    public function sendPasswordResetEmail($email, $resetToken, $userFullName = '') {
        $subject = "Đặt lại mật khẩu - Life in the UK Test";
        $resetUrl = $this->generateResetUrl($resetToken);
        
        // Bilingual email template
        $htmlBody = $this->getPasswordResetEmailTemplate($email, $resetToken, $userFullName, $resetUrl);
        
        // For development, log email instead of sending
        if ($this->isDevelopmentMode()) {
            $this->logEmailForDevelopment($email, $subject, $htmlBody, $resetUrl);
            return true;
        }
        
        // In production, use proper email service (SMTP, SendGrid, etc.)
        return $this->sendActualEmail($email, $subject, $htmlBody);
    }
    
    /**
     * Generate reset URL
     */
    private function generateResetUrl($token) {
        $baseUrl = $_ENV['FRONTEND_URL'] ?? 'http://localhost:3000';
        return $baseUrl . '/reset-password?token=' . urlencode($token);
    }
    
    /**
     * Bilingual email template for password reset
     */
    private function getPasswordResetEmailTemplate($email, $token, $fullName, $resetUrl) {
        $displayName = !empty($fullName) ? $fullName : $email;
        
        return "
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset='UTF-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <title>Password Reset - Life in the UK</title>
            <style>
                body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f8f9ff; }
                .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
                .header { background: linear-gradient(135deg, #2B7CE9, #4A94FF); padding: 30px; text-align: center; }
                .header h1 { color: white; margin: 0; font-size: 24px; font-weight: 600; }
                .content { padding: 40px 30px; }
                .greeting { font-size: 18px; font-weight: 600; color: #1F2937; margin-bottom: 20px; }
                .message { color: #6B7280; line-height: 1.6; margin-bottom: 30px; }
                .reset-button { display: inline-block; background: #2B7CE9; color: white; padding: 15px 30px; text-decoration: none; border-radius: 12px; font-weight: 600; margin: 20px 0; }
                .reset-button:hover { background: #1E5AA8; }
                .alternative-link { background: #F3F4F6; padding: 20px; border-radius: 12px; margin: 20px 0; word-break: break-all; }
                .footer { background: #F9FAFB; padding: 20px 30px; border-top: 1px solid #E5E7EB; color: #6B7280; font-size: 14px; }
                .divider { height: 1px; background: #E5E7EB; margin: 30px 0; }
                .flag-icon { width: 40px; height: 30px; margin: 0 auto 15px; display: block; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <div class='flag-icon'>🇬🇧</div>
                    <h1>Life in the UK Test</h1>
                </div>
                
                <div class='content'>
                    <!-- English Section -->
                    <div class='greeting'>Hello {$displayName},</div>
                    <div class='message'>
                        We received a request to reset your password for your Life in the UK Test account. 
                        Click the button below to set a new password:
                    </div>
                    
                    <center>
                        <a href='{$resetUrl}' class='reset-button'>Reset My Password</a>
                    </center>
                    
                    <div class='message' style='font-size: 14px;'>
                        This link will expire in 1 hour for security reasons. If you didn't request this password reset, 
                        please ignore this email and your password will remain unchanged.
                    </div>
                    
                    <div class='divider'></div>
                    
                    <!-- Vietnamese Section -->
                    <div class='greeting'>Xin chào {$displayName},</div>
                    <div class='message'>
                        Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản Life in the UK Test của bạn.
                        Vui lòng nhấp vào nút bên dưới để tạo mật khẩu mới:
                    </div>
                    
                    <center>
                        <a href='{$resetUrl}' class='reset-button'>Đặt lại mật khẩu</a>
                    </center>
                    
                    <div class='message' style='font-size: 14px;'>
                        Liên kết này sẽ hết hạn sau 1 giờ vì lý do bảo mật. Nếu bạn không yêu cầu đặt lại mật khẩu,
                        vui lòng bỏ qua email này và mật khẩu của bạn sẽ không thay đổi.
                    </div>
                    
                    <div class='alternative-link'>
                        <strong>Alternative link / Liên kết thay thế:</strong><br>
                        {$resetUrl}
                    </div>
                </div>
                
                <div class='footer'>
                    <p>
                        <strong>Life in the UK Test Team</strong><br>
                        If you have any questions, please contact our support team.<br>
                        Nếu bạn có bất kỳ câu hỏi nào, vui lòng liên hệ đội ngũ hỗ trợ của chúng tôi.
                    </p>
                </div>
            </div>
        </body>
        </html>";
    }
    
    /**
     * Check if we're in development mode
     */
    private function isDevelopmentMode() {
        return ($_ENV['APP_ENV'] ?? 'development') === 'development' || 
               ($_ENV['EMAIL_DEBUG'] ?? false);
    }
    
    /**
     * Log email for development purposes
     */
    private function logEmailForDevelopment($email, $subject, $body, $resetUrl) {
        $logMessage = "
=== PASSWORD RESET EMAIL (DEVELOPMENT MODE) ===
To: {$email}
Subject: {$subject}
Reset URL: {$resetUrl}
Token: " . basename(parse_url($resetUrl, PHP_URL_QUERY)) . "
Time: " . date('Y-m-d H:i:s') . "
===============================================
";
        
        // Log to error log
        error_log($logMessage);
        
        // Also save to file if possible
        $logFile = __DIR__ . '/../logs/email_debug.log';
        if (is_writable(dirname($logFile))) {
            file_put_contents($logFile, $logMessage . "\n", FILE_APPEND | LOCK_EX);
        }
        
        return true;
    }
    
    /**
     * Send actual email (implement with your preferred email service)
     */
    private function sendActualEmail($to, $subject, $htmlBody) {
        // Example using PHP's built-in mail function
        // In production, use a proper email service like SendGrid, AWS SES, etc.
        
        $headers = [
            'MIME-Version: 1.0',
            'Content-type: text/html; charset=UTF-8',
            'From: Life in the UK Test <noreply@lifeintheuk.com>',
            'Reply-To: support@lifeintheuk.com',
            'X-Mailer: PHP/' . phpversion()
        ];
        
        return mail($to, $subject, $htmlBody, implode("\r\n", $headers));
    }
    
    /**
     * Send test email to verify email service is working
     */
    public function sendTestEmail($email) {
        $subject = "Test Email - Life in the UK";
        $body = "
        <h2>Email Service Test</h2>
        <p>If you receive this email, the email service is working correctly.</p>
        <p>Time: " . date('Y-m-d H:i:s') . "</p>
        ";
        
        if ($this->isDevelopmentMode()) {
            $this->logEmailForDevelopment($email, $subject, $body, 'N/A');
            return true;
        }
        
        return $this->sendActualEmail($email, $subject, $body);
    }
}