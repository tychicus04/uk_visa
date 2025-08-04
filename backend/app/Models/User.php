<?php
require_once __DIR__ . '/../Core/BaseModel.php';
require_once __DIR__ . '/../../services/SimpleJWTService.php';

class User extends BaseModel {
    protected $table = 'users';
    protected $fillable = ['email', 'password_hash', 'full_name', 'language_code', 'is_premium', 'premium_expires_at'];
    protected $hidden = ['password_hash'];

    public function __construct() {
        parent::__construct();
    }
    
    public function register($userData) {
        // Check if email exists
        if ($this->findBy('email', $userData['email'])) {
            throw new Exception('Email already exists');
        }
        
        // Hash password
        $userData['password_hash'] = password_hash($userData['password'], PASSWORD_DEFAULT);
        unset($userData['password']);
        
        return $this->create($userData);
    }
    
    public function login($email, $password) {
        $sql = "SELECT * FROM {$this->table} WHERE email = :email LIMIT 1";
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        
        $user = $stmt->fetch();
        
        if ($user && password_verify($password, $user['password_hash'])) {
            return $this->hideFields($user);
        }
        
        return false;
    }
    
    public function canAccessTest($userId, $testId) {
        $sql = "SELECT t.is_free, t.is_premium, u.free_tests_used, u.free_tests_limit, 
                       u.is_premium, u.premium_expires_at
                FROM tests t
                CROSS JOIN users u 
                WHERE t.id = :test_id AND u.id = :user_id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':test_id', $testId);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        
        $result = $stmt->fetch();
        
        if (!$result) return false;
        
        // Free test check
        if ($result['is_free']) {
            return $result['free_tests_used'] < $result['free_tests_limit'];
        }
        
        // Premium test check
        if ($result['is_premium']) {
            return $result['is_premium'] && 
                   (is_null($result['premium_expires_at']) || 
                    strtotime($result['premium_expires_at']) > time());
        }
        
        return false;
    }
    
    public function incrementFreeTestUsage($userId) {
        $sql = "UPDATE {$this->table} SET free_tests_used = free_tests_used + 1 WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':id', $userId);
        return $stmt->execute();
    }
    
    public function getUserStats($userId) {
        $sql = "SELECT 
                    COUNT(uta.id) as total_attempts,
                    COUNT(CASE WHEN uta.is_passed = 1 THEN 1 END) as passed_attempts,
                    AVG(uta.percentage) as average_score,
                    MAX(uta.percentage) as best_score,
                    u.free_tests_used,
                    u.free_tests_limit,
                    u.is_premium
                FROM users u
                LEFT JOIN user_test_attempts uta ON u.id = uta.user_id AND uta.completed_at IS NOT NULL
                WHERE u.id = :user_id
                GROUP BY u.id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        
        return $stmt->fetch();
    }
    
    public function updateProfile($userId, $data) {
        $allowedFields = ['full_name', 'language_code'];
        $updateData = array_intersect_key($data, array_flip($allowedFields));
        
        if (empty($updateData)) {
            return false;
        }
        
        return $this->update($userId, $updateData);
    }
    
    public function changePassword($userId, $oldPassword, $newPassword) {
        $user = $this->query("SELECT password_hash FROM {$this->table} WHERE id = :id", [':id' => $userId]);
        
        if (empty($user) || !password_verify($oldPassword, $user[0]['password_hash'])) {
            throw new Exception('Current password is incorrect');
        }
        
        $newHash = password_hash($newPassword, PASSWORD_DEFAULT);
        return $this->update($userId, ['password_hash' => $newHash]);
    }
}