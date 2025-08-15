<?php
require_once __DIR__ . '/../Core/BaseModel.php';

class Test extends BaseModel {
    protected $table = 'tests';
    protected $fillable = ['chapter_id', 'test_number', 'test_type', 'title', 'url', 'is_free', 'is_premium'];
    
    // 🆕 UPDATED: Add Vietnamese support parameter
    public function getAvailableTests($userId) {
        $sql = "SELECT t.*, c.name as chapter_name,
                       COUNT(uta.id) as attempt_count,
                       MAX(uta.percentage) as best_score
                FROM {$this->table} t
                LEFT JOIN chapters c ON t.chapter_id = c.id
                LEFT JOIN user_test_attempts uta ON t.id = uta.test_id AND uta.user_id = :user_id AND uta.completed_at IS NOT NULL
                GROUP BY t.id
                ORDER BY t.test_type, t.chapter_id, t.test_number";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        
        return $stmt->fetchAll();
    }
    
    // 🆕 UPDATED: Add Vietnamese support parameter
    public function getTestWithQuestions($testId, $includeCorrectAnswers = false, $includeVietnamese = true) {
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
        
        // 🆕 DYNAMIC QUERY: Build question fields based on Vietnamese support
        $questionFields = "q.id, q.question_id, q.question_text, q.question_type, q.explanation";
        if ($includeVietnamese) {
            $questionFields .= ", q.question_text_vi, q.explanation_vi";
        }
        
        $sql = "SELECT {$questionFields}
                FROM questions q
                WHERE q.test_id = :test_id
                ORDER BY q.id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':test_id', $testId);
        $stmt->execute();
        
        $questions = $stmt->fetchAll();
        
        // 🆕 DYNAMIC QUERY: Build answer fields based on Vietnamese support
        foreach ($questions as &$question) {
            $answerFields = "id, answer_id, answer_text";
            if ($includeVietnamese) {
                $answerFields .= ", answer_text_vi";
            }
            if ($includeCorrectAnswers) {
                $answerFields .= ", is_correct";
            }
            
            $answerSql = "SELECT {$answerFields} FROM answers WHERE question_id = :question_id ORDER BY id";
            
            $answerStmt = $this->db->prepare($answerSql);
            $answerStmt->bindParam(':question_id', $question['id']);
            $answerStmt->execute();
            
            $question['answers'] = $answerStmt->fetchAll();
        }
        
        $test['questions'] = $questions;
        $test['question_count'] = count($questions);
        
        // 🆕 ADD METADATA: Include Vietnamese support info
        $test['vietnamese_enabled'] = $includeVietnamese;
        
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
    
    // 🆕 NEW METHOD: Enhanced search with Vietnamese support
    public function searchTests($query, $type = null, $chapter = null, $includeVietnamese = true) {
        $searchFields = "t.title LIKE :query OR t.test_number LIKE :query OR c.name LIKE :query";
        
        if ($includeVietnamese) {
            // Also search in Vietnamese question and answer text
            $searchFields .= " OR EXISTS (
                SELECT 1 FROM questions q 
                WHERE q.test_id = t.id 
                AND (q.question_text_vi LIKE :query OR q.question_text LIKE :query)
            ) OR EXISTS (
                SELECT 1 FROM questions q2
                JOIN answers a ON a.question_id = q2.id
                WHERE q2.test_id = t.id 
                AND (a.answer_text_vi LIKE :query OR a.answer_text LIKE :query)
            )";
        }
        
        $sql = "SELECT DISTINCT t.*, c.name as chapter_name 
                FROM {$this->table} t 
                LEFT JOIN chapters c ON t.chapter_id = c.id 
                WHERE ({$searchFields})";
        
        $params = [':query' => "%{$query}%"];
        
        if ($type) {
            $sql .= " AND t.test_type = :type";
            $params[':type'] = $type;
        }
        
        if ($chapter) {
            $sql .= " AND t.chapter_id = :chapter";
            $params[':chapter'] = $chapter;
        }
        
        $sql .= " ORDER BY t.test_type, t.test_number LIMIT 50";
        
        return $this->query($sql, $params);
    }
    
    // 🆕 NEW METHOD: Get single question with Vietnamese support
    public function getQuestionWithAnswers($questionId, $includeCorrectAnswers = false, $includeVietnamese = true) {
        // Build question query
        $questionFields = "q.id, q.question_id, q.question_text, q.question_type, q.explanation";
        if ($includeVietnamese) {
            $questionFields .= ", q.question_text_vi, q.explanation_vi";
        }
        
        $questionSql = "SELECT {$questionFields} FROM questions q WHERE q.id = :question_id";
        $question = $this->query($questionSql, [':question_id' => $questionId]);
        
        if (empty($question)) {
            return null;
        }
        
        $question = $question[0];
        
        // Build answers query
        $answerFields = "a.id, a.answer_id, a.answer_text";
        if ($includeVietnamese) {
            $answerFields .= ", a.answer_text_vi";
        }
        if ($includeCorrectAnswers) {
            $answerFields .= ", a.is_correct";
        }
        
        $answersSql = "SELECT {$answerFields}
                       FROM answers a 
                       WHERE a.question_id = :question_id 
                       ORDER BY a.id";
        
        $answers = $this->query($answersSql, [':question_id' => $questionId]);
        $question['answers'] = $answers;
        
        return $question;
    }
    
    // 🆕 NEW METHOD: Get Vietnamese translation statistics
    public function getTranslationStats() {
        $questionStats = $this->query("
            SELECT 
                COUNT(*) as total_questions,
                COUNT(question_text_vi) as translated_questions,
                COUNT(explanation_vi) as translated_explanations
            FROM questions
        ");
        
        $answerStats = $this->query("
            SELECT 
                COUNT(*) as total_answers,
                COUNT(answer_text_vi) as translated_answers
            FROM answers
        ");
        
        $qStats = $questionStats[0];
        $aStats = $answerStats[0];
        
        return [
            'questions' => [
                'total' => (int)$qStats['total_questions'],
                'translated' => (int)$qStats['translated_questions'],
                'explanations_translated' => (int)$qStats['translated_explanations'],
                'coverage_percent' => $qStats['total_questions'] > 0 ? 
                    round(($qStats['translated_questions'] / $qStats['total_questions']) * 100, 2) : 0
            ],
            'answers' => [
                'total' => (int)$aStats['total_answers'],
                'translated' => (int)$aStats['translated_answers'],
                'coverage_percent' => $aStats['total_answers'] > 0 ? 
                    round(($aStats['translated_answers'] / $aStats['total_answers']) * 100, 2) : 0
            ]
        ];
    }
}