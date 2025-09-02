<?php
// backend/app/Controllers/PasswordResetController.php - FIXED VERSION
require_once __DIR__ . '/../Core/BaseController.php';
require_once __DIR__ . '/../Models/User.php';
require_once __DIR__ . '/../Models/PasswordResetToken.php';
require_once __DIR__ . '/../../services/EmailService.php';

class PasswordResetController extends BaseController {
    private $userModel;
    private $resetTokenModel;
    private $emailService;
    
    public function __construct() {
        $this->userModel = new User();
        $this->resetTokenModel = new PasswordResetToken();
        $this->emailService = EmailService::getInstance();
    }
    
    /**
     * POST /auth/forgot-password
     * Send password reset email
     */
    public function forgotPassword() {
        $this->validateMethod(['POST']);
        $data = $this->getRequestData();
        
        try {
            // Validate input
            if (!isset($data->email) || empty($data->email)) {
                $this->error('Email is required', 400);
                return;
            }
            
            $email = sanitizeInput($data->email);
            
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $this->error('Invalid email format', 400);
                return;
            }
            
            // Check if user exists
            $user = $this->userModel->findBy('email', $email);
            
            if (!$user) {
                // Return success even if user doesn't exist (security practice)
                $this->success([], 'If an account with that email exists, we have sent a password reset link');
                return;
            }
            
            // Check rate limiting (max 3 requests per hour per email)
            if ($this->resetTokenModel->checkRateLimit($email, 1, 3)) {
                $this->error('Too many password reset requests. Please try again later.', 429);
                return;
            }
            
            // Generate reset token
            $resetToken = $this->generateResetToken();
            $expiresAt = date('Y-m-d H:i:s', time() + 3600); // 1 hour from now
            
            // Save reset token to database
            $tokenRecord = $this->resetTokenModel->createToken($email, $resetToken, $expiresAt);
            
            if (!$tokenRecord) {
                $this->error('Failed to create reset token', 500);
                return;
            }
            
            // Send email
            $emailSent = $this->emailService->sendPasswordResetEmail(
                $email, 
                $resetToken, 
                $user['full_name'] ?? ''
            );
            
            if ($emailSent) {
                $this->success([], 'If an account with that email exists, we have sent a password reset link');
            } else {
                $this->error('Failed to send reset email. Please try again later.', 500);
            }
            
        } catch (Exception $e) {
            $this->error('An error occurred. Please try again later.', 500);
        }
    }
    
    /**
     * POST /auth/reset-password
     * Reset password with token
     */
    public function resetPassword() {
        $this->validateMethod(['POST']);
        $data = $this->getRequestData();
        
        try {
            // Validate input
            $required = ['token', 'new_password'];
            $missing = validateRequired($data, $required);
            
            if (!empty($missing)) {
                $this->error('Missing required fields: ' . implode(', ', $missing), 400);
                return;
            }
            
            $token = sanitizeInput($data->token);
            $newPassword = $data->new_password;
            
            if (strlen($newPassword) < 6) {
                $this->error('Password must be at least 6 characters long', 400);
                return;
            }
            
            // Verify token
            $resetRecord = $this->resetTokenModel->findValidToken($token);
            
            if (!$resetRecord) {
                $this->error('Invalid or expired reset token', 400);
                return;
            }
            
            // Check if user still exists
            $user = $this->userModel->findBy('email', $resetRecord['email']);
            if (!$user) {
                $this->error('User not found', 404);
                return;
            }
            
            // Update password
            $passwordHash = password_hash($newPassword, PASSWORD_DEFAULT);
            $updated = $this->userModel->update($user['id'], [
                'password_hash' => $passwordHash
            ]);
            
            if (!$updated) {
                $this->error('Failed to update password', 500);
                return;
            }
            
            // Mark token as used
            $this->resetTokenModel->markAsUsed($token);
            
            // Clean up old tokens for this email
            $this->resetTokenModel->cleanupOldTokens($resetRecord['email']);
            
            $this->success([], 'Password has been successfully reset');
            
        } catch (Exception $e) {
            $this->error('An error occurred. Please try again later.', 500);
        }
    }
    
    /**
     * POST /auth/verify-reset-token
     * Verify if reset token is valid (for frontend validation)
     */
    public function verifyToken() {
        $this->validateMethod(['POST']);
        $data = $this->getRequestData();
        
        try {
            if (!isset($data->token) || empty($data->token)) {
                $this->error('Token is required', 400);
                return;
            }
            
            $token = sanitizeInput($data->token);
            $resetRecord = $this->resetTokenModel->findValidToken($token);
            
            if ($resetRecord) {
                $this->success([
                    'valid' => true,
                    'email' => $resetRecord['email'],
                    'expires_at' => $resetRecord['expires_at']
                ], 'Token is valid');
            } else {
                $this->success([
                    'valid' => false
                ], 'Token is invalid or expired');
            }
            
        } catch (Exception $e) {
            $this->error('An error occurred', 500);
        }
    }
    
    /**
     * Clean up expired tokens (can be called by cron job)
     */
    public function cleanupExpiredTokens() {
        $this->validateMethod(['POST']);
        
        try {
            $deletedCount = $this->resetTokenModel->cleanupExpiredTokens();
            
            
            $this->success(['deleted_count' => $deletedCount], 'Cleanup completed');
            
        } catch (Exception $e) {
            $this->error('Cleanup failed', 500);
        }
    }
    
    /**
     * Generate secure reset token
     */
    private function generateResetToken() {
        return bin2hex(random_bytes(32)) . '_' . time();
    }
}