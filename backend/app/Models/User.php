<?php
require_once __DIR__ . '/../Core/BaseModel.php';

class User extends BaseModel {
    protected $table = 'users';
    protected $fillable = ['email', 'password_hash', 'language_code'];
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
    
    public function getUserStats($userId) {
        $sql = "SELECT 
                    COUNT(uta.id) as total_attempts,
                    COUNT(CASE WHEN uta.is_passed = 1 THEN 1 END) as passed_attempts,
                    COALESCE(AVG(uta.percentage), 0) as average_score,
                    COALESCE(MAX(uta.percentage), 0) as best_score,
                    COUNT(DISTINCT uta.test_id) as unique_tests_attempted
                FROM users u
                LEFT JOIN user_test_attempts uta ON u.id = uta.user_id AND uta.completed_at IS NOT NULL
                WHERE u.id = :user_id
                GROUP BY u.id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        
        $result = $stmt->fetch();
        
        // Return default values if no attempts found
        return $result ?: [
            'total_attempts' => 0,
            'passed_attempts' => 0,
            'average_score' => 0,
            'best_score' => 0,
            'unique_tests_attempted' => 0
        ];
    }
    
    public function updateProfile($userId, $data) {
        $allowedFields = ['language_code'];
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
    
    // Simplified method - all tests are now free
    public function canAccessTest($userId, $testId) {
        // All tests are free now
        return true;
    }
}