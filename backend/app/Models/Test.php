<?php
require_once __DIR__ . '/../Core/BaseModel.php';

class Test extends BaseModel {
    protected $table = 'tests';
    protected $fillable = ['chapter_id', 'test_number', 'test_type', 'title', 'url', 'is_free', 'is_premium'];
    
    public function getAvailableTests($userId) {
        $sql = "SELECT t.*, c.name as chapter_name,
                       CASE 
                          WHEN t.is_free = 1 AND u.free_tests_used < u.free_tests_limit THEN 1
                          WHEN t.is_premium = 1 AND u.is_premium = 1 AND 
                               (u.premium_expires_at IS NULL OR u.premium_expires_at > NOW()) THEN 1
                          ELSE 0
                       END as can_access,
                       COUNT(uta.id) as attempt_count,
                       MAX(uta.percentage) as best_score
                FROM {$this->table} t
                LEFT JOIN chapters c ON t.chapter_id = c.id
                CROSS JOIN users u 
                LEFT JOIN user_test_attempts uta ON t.id = uta.test_id AND uta.user_id = u.id AND uta.completed_at IS NOT NULL
                WHERE u.id = :user_id
                GROUP BY t.id
                ORDER BY t.test_type, t.chapter_id, t.test_number";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        
        return $stmt->fetchAll();
    }
    
    public function getTestWithQuestions($testId, $includeCorrectAnswers = false) {
        // Get test info
        $test = $this->query(
            "SELECT t.*, c.name as chapter_name FROM {$this->table} t 
             LEFT JOIN chapters c ON t.chapter_id = c.id 
             WHERE t.id = :test_id",
            [':test_id' => $testId]
        );
        
        if (empty($test)) {
            return null;
        }
        
        $test = $test[0];
        
        // Get questions with answers - Use simpler approach for MariaDB compatibility
        $sql = "SELECT q.id, q.question_id, q.question_text, q.question_type, q.explanation
                FROM questions q
                WHERE q.test_id = :test_id
                ORDER BY q.id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':test_id', $testId);
        $stmt->execute();
        
        $questions = $stmt->fetchAll();
        
        // Get answers for each question separately (more compatible)
        foreach ($questions as &$question) {
            $answerSql = "SELECT id, answer_id, answer_text" . 
                        ($includeCorrectAnswers ? ", is_correct" : "") . 
                        " FROM answers WHERE question_id = :question_id ORDER BY id";
            
            $answerStmt = $this->db->prepare($answerSql);
            $answerStmt->bindParam(':question_id', $question['id']);
            $answerStmt->execute();
            
            $question['answers'] = $answerStmt->fetchAll();
        }
        
        $test['questions'] = $questions;
        $test['question_count'] = count($questions);
        
        return $test;
    }
    
    public function getFreeTests() {
        return $this->query("SELECT * FROM {$this->table} WHERE is_free = 1 ORDER BY test_number");
    }
    
    public function getPremiumTests() {
        return $this->query("SELECT * FROM {$this->table} WHERE is_premium = 1 ORDER BY test_number");
    }
    
    public function getTestsByChapter($chapterId) {
        return $this->query(
            "SELECT * FROM {$this->table} WHERE chapter_id = :chapter_id ORDER BY test_number",
            [':chapter_id' => $chapterId]
        );
    }
    
    public function getTestsByType($type) {
        return $this->query(
            "SELECT * FROM {$this->table} WHERE test_type = :type ORDER BY test_number",
            [':type' => $type]
        );
    }
}