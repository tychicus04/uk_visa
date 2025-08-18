<?php
// backend/app/Models/PasswordResetToken.php
require_once __DIR__ . '/../Core/BaseModel.php';

class PasswordResetToken extends BaseModel {
    protected $table = 'password_reset_tokens';
    protected $fillable = ['email', 'token', 'expires_at', 'used_at'];
    
    public function __construct() {
        parent::__construct();
    }
    
    /**
     * Create a new reset token
     */
    public function createToken($email, $token, $expiresAt) {
        return $this->create([
            'email' => $email,
            'token' => $token,
            'expires_at' => $expiresAt
        ]);
    }
    
    /**
     * Find valid token
     */
    public function findValidToken($token) {
        $sql = "SELECT * FROM {$this->table} 
                WHERE token = :token 
                AND expires_at > NOW() 
                AND used_at IS NULL 
                LIMIT 1";
        
        $result = $this->query($sql, [':token' => $token]);
        return !empty($result) ? $result[0] : null;
    }
    
    /**
     * Mark token as used
     */
    public function markAsUsed($token) {
        $sql = "UPDATE {$this->table} 
                SET used_at = NOW() 
                WHERE token = :token";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':token', $token);
        return $stmt->execute();
    }
    
    /**
     * Check rate limiting for email
     */
    public function checkRateLimit($email, $hours = 1, $maxAttempts = 3) {
        $sql = "SELECT COUNT(*) as count 
                FROM {$this->table} 
                WHERE email = :email 
                AND created_at > DATE_SUB(NOW(), INTERVAL :hours HOUR)";
        
        $result = $this->query($sql, [
            ':email' => $email,
            ':hours' => $hours
        ]);
        
        $count = !empty($result) ? intval($result[0]['count']) : 0;
        return $count >= $maxAttempts;
    }
    
    /**
     * Clean up old tokens for an email
     */
    public function cleanupOldTokens($email) {
        $sql = "DELETE FROM {$this->table} 
                WHERE email = :email 
                AND (expires_at < NOW() OR used_at IS NOT NULL)";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':email', $email);
        return $stmt->execute();
    }
    
    /**
     * Clean up all expired tokens
     */
    public function cleanupExpiredTokens() {
        $sql = "DELETE FROM {$this->table} 
                WHERE expires_at < DATE_SUB(NOW(), INTERVAL 24 HOUR)";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute();
        return $stmt->rowCount();
    }
}