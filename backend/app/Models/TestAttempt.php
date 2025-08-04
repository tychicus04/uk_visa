<?php
require_once __DIR__ . '/../Core/BaseModel.php';

class TestAttempt extends BaseModel {
    protected $table = 'user_test_attempts';
    protected $fillable = ['user_id', 'test_id', 'score', 'total_questions', 'percentage', 'time_taken', 'is_passed', 'started_at', 'completed_at'];

    public function __construct() {
        parent::__construct();
    }
    
    public function startAttempt($userId, $testId) {
        $data = [
            'user_id' => $userId,
            'test_id' => $testId,
            'started_at' => date('Y-m-d H:i:s')
        ];
        
        $sql = "INSERT INTO {$this->table} (user_id, test_id, started_at) VALUES (:user_id, :test_id, :started_at)";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($data);
        
        return $this->db->lastInsertId();
    }
    
    public function submitAttempt($attemptId, $userAnswers, $timeTaken = null) {
        // Calculate score
        $correctCount = 0;
        $totalQuestions = count($userAnswers);
        
        // Process each answer
        foreach ($userAnswers as $userAnswer) {
            $isCorrect = $this->checkAnswer($userAnswer['question_id'], $userAnswer['selected_answer_ids']);
            
            // Save individual answer
            $answerData = [
                'attempt_id' => $attemptId,
                'question_id' => $userAnswer['question_id'],
                'selected_answer_ids' => json_encode($userAnswer['selected_answer_ids']),
                'is_correct' => $isCorrect ? 1 : 0
            ];
            
            $sql = "INSERT INTO user_answers (attempt_id, question_id, selected_answer_ids, is_correct) 
                    VALUES (:attempt_id, :question_id, :selected_answer_ids, :is_correct)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute($answerData);
            
            if ($isCorrect) {
                $correctCount++;
            }
        }
        
        // Calculate final score
        $percentage = $totalQuestions > 0 ? ($correctCount / $totalQuestions) * 100 : 0;
        $isPassed = $percentage >= 75 ? 1 : 0;
        $completedAt = date('Y-m-d H:i:s');
        
        // Update attempt record
        $updateData = [
            'score' => $correctCount,
            'total_questions' => $totalQuestions,
            'percentage' => round($percentage, 2),
            'time_taken' => $timeTaken,
            'is_passed' => $isPassed,
            'completed_at' => $completedAt
        ];
        
        $this->update($attemptId, $updateData);
        
        return [
            'score' => $correctCount,
            'total_questions' => $totalQuestions,
            'percentage' => round($percentage, 2),
            'is_passed' => $isPassed,
            'time_taken' => $timeTaken,
            'completed_at' => $completedAt
        ];
    }
    
    private function checkAnswer($questionId, $selectedAnswerIds) {
        // Get correct answers for the question
        $sql = "SELECT answer_id FROM answers WHERE question_id = :question_id AND is_correct = 1";
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':question_id', $questionId);
        $stmt->execute();
        
        $correctAnswers = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        // Compare selected answers with correct answers
        sort($selectedAnswerIds);
        sort($correctAnswers);
        
        return $selectedAnswerIds === $correctAnswers;
    }
    
    public function getUserHistory($userId, $limit = 20, $offset = 0) {
        $sql = "SELECT uta.*, t.title, t.test_number, t.test_type, c.name as chapter_name
                FROM {$this->table} uta
                JOIN tests t ON uta.test_id = t.id
                LEFT JOIN chapters c ON t.chapter_id = c.id
                WHERE uta.user_id = :user_id AND uta.completed_at IS NOT NULL
                ORDER BY uta.completed_at DESC
                LIMIT :limit OFFSET :offset";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll();
    }
    
    public function getAttemptDetails($attemptId, $userId) {
        $sql = "SELECT uta.*, t.title, t.test_number, c.name as chapter_name
                FROM {$this->table} uta
                JOIN tests t ON uta.test_id = t.id
                LEFT JOIN chapters c ON t.chapter_id = c.id
                WHERE uta.id = :attempt_id AND uta.user_id = :user_id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':attempt_id', $attemptId);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        
        $attempt = $stmt->fetch();
        
        if ($attempt) {
            // Get detailed answers
            $sql = "SELECT ua.*, q.question_text, q.question_type,
                           GROUP_CONCAT(
                               JSON_OBJECT(
                                   'answer_id', a.answer_id,
                                   'answer_text', a.answer_text,
                                   'is_correct', a.is_correct,
                                   'was_selected', CASE WHEN JSON_CONTAINS(ua.selected_answer_ids, JSON_QUOTE(a.answer_id)) THEN 1 ELSE 0 END
                               ) SEPARATOR '|||'
                           ) as answer_details
                    FROM user_answers ua
                    JOIN questions q ON ua.question_id = q.id
                    JOIN answers a ON q.id = a.question_id
                    WHERE ua.attempt_id = :attempt_id
                    GROUP BY ua.id, q.id
                    ORDER BY q.id";
            
            $stmt = $this->db->prepare($sql);
            $stmt->bindParam(':attempt_id', $attemptId);
            $stmt->execute();
            
            $answers = $stmt->fetchAll();
            
            // Process answer details
            foreach ($answers as &$answer) {
                $details = [];
                if ($answer['answer_details']) {
                    $detailStrings = explode('|||', $answer['answer_details']);
                    foreach ($detailStrings as $detailStr) {
                        $details[] = json_decode($detailStr, true);
                    }
                }
                $answer['answer_details'] = $details;
                $answer['selected_answer_ids'] = json_decode($answer['selected_answer_ids'], true);
            }
            
            $attempt['answers'] = $answers;
        }
        
        return $attempt;
    }
    
    public function getLeaderboard($testId = null, $limit = 10) {
        $whereClause = $testId ? "WHERE uta.test_id = :test_id" : "";
        
        $sql = "SELECT u.full_name, uta.percentage, uta.time_taken, uta.completed_at,
                       t.title as test_title
                FROM {$this->table} uta
                JOIN users u ON uta.user_id = u.id
                JOIN tests t ON uta.test_id = t.id
                {$whereClause}
                ORDER BY uta.percentage DESC, uta.time_taken ASC
                LIMIT :limit";
        
        $stmt = $this->db->prepare($sql);
        if ($testId) {
            $stmt->bindParam(':test_id', $testId);
        }
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll();
    }
}