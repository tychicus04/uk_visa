<?php
require_once __DIR__ . '/../Core/BaseModel.php';

class TestAttempt extends BaseModel {
    protected $table = 'user_test_attempts';
    protected $fillable = ['user_id', 'test_id', 'score', 'total_questions', 'percentage', 'time_taken', 'is_passed', 'started_at', 'completed_at'];

    // Enhanced multi-language support (matches TestController and AttemptController)
    private const SUPPORTED_LANGUAGES = [
        'vi' => 'Vietnamese',
        'pl' => 'Polish', 
        'pa' => 'Punjabi',
        'ur' => 'Urdu',
        'ro' => 'Romanian',
        'es' => 'Spanish',
        'pt' => 'Portuguese',
        'ar' => 'Arabic'
    ];

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
    
    // ✅ ENHANCED: Multi-language support for user history
    public function getUserHistory($userId, $limit = 20, $offset = 0, $includeLanguage = null) {
        // Build dynamic test title fields if language is specified
        $titleFields = "t.title";
        $chapterFields = "c.name as chapter_name";
        
        if ($includeLanguage && $this->isLanguageSupported($includeLanguage)) {
            // Add language-specific title if available (for future when test titles are translated)
            $titleFields .= ", t.title_{$includeLanguage}";
            $chapterFields .= ", c.name_{$includeLanguage} as chapter_name_{$includeLanguage}";
        }
        
        $sql = "SELECT uta.*, {$titleFields}, t.test_number, t.test_type, {$chapterFields}
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
        
        $history = $stmt->fetchAll();
        
        // Add language metadata to each history item
        if ($includeLanguage) {
            foreach ($history as &$item) {
                $item['language_enabled'] = true;
                $item['include_language'] = $includeLanguage;
                $item['supported_language'] = self::SUPPORTED_LANGUAGES[$includeLanguage] ?? 'Unknown';
            }
        }
        
        return $history;
    }
    
    // ✅ COMPLETELY REWRITTEN: Full multi-language support for attempt details
    public function getAttemptDetails($attemptId, $userId, $includeLanguage = null) {
        // Get basic attempt information
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
        
        if (!$attempt) {
            return null;
        }
        
        // Build dynamic question and answer fields based on language
        $questionFields = $this->buildQuestionFields($includeLanguage);
        $answerFields = $this->buildAnswerFields($includeLanguage);
        
        // Get detailed answers with multi-language support
        $answerSql = "SELECT ua.*, 
                             {$questionFields},
                             GROUP_CONCAT(
                                 JSON_OBJECT(
                                     'answer_id', a.answer_id,
                                     'answer_text', a.answer_text,
                                     " . $this->buildAnswerJsonFields($includeLanguage) . "
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
        
        $stmt = $this->db->prepare($answerSql);
        $stmt->bindParam(':attempt_id', $attemptId);
        $stmt->execute();
        
        $answers = $stmt->fetchAll();
        
        // Process answer details with enhanced language support
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
            
            // Add language availability indicators
            if ($includeLanguage && $this->isLanguageSupported($includeLanguage)) {
                $questionLangField = "question_text_{$includeLanguage}";
                $explanationLangField = "explanation_{$includeLanguage}";
                
                $answer['has_translation'] = [
                    'question' => !empty($answer[$questionLangField]),
                    'explanation' => !empty($answer[$explanationLangField]),
                    'language_code' => $includeLanguage,
                    'language_name' => self::SUPPORTED_LANGUAGES[$includeLanguage]
                ];
                
                // Backward compatibility
                if ($includeLanguage === 'vi') {
                    $answer['has_vietnamese'] = $answer['has_translation']['question'];
                }
            }
        }
        
        $attempt['answers'] = $answers;
        
        // Add comprehensive response metadata
        $attempt['response_metadata'] = [
            'language_enabled' => $includeLanguage !== null,
            'include_language' => $includeLanguage,
            'language_name' => $includeLanguage ? (self::SUPPORTED_LANGUAGES[$includeLanguage] ?? 'Unknown') : 'English',
            'total_answers' => count($answers),
            'translation_coverage' => $this->calculateTranslationCoverage($answers, $includeLanguage),
            'backward_compatibility' => [
                'vietnamese_supported' => $includeLanguage === 'vi', // For old clients
                'include_vietnamese_param' => isset($_GET['include_vietnamese']) // Legacy parameter detection
            ],
            'generated_at' => date('Y-m-d H:i:s')
        ];
        
        return $attempt;
    }
    
    // ✅ ENHANCED: Multi-language support for leaderboard
    public function getLeaderboard($testId = null, $limit = 10, $includeLanguage = null) {
        $whereClause = $testId ? "WHERE uta.test_id = :test_id" : "";
        
        // Build dynamic test title field
        $titleField = "t.title as test_title";
        if ($includeLanguage && $this->isLanguageSupported($includeLanguage)) {
            $titleField .= ", t.title_{$includeLanguage} as test_title_{$includeLanguage}";
        }
        
        $sql = "SELECT u.email, uta.percentage, uta.time_taken, uta.completed_at,
                       {$titleField}
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
        
        $leaderboard = $stmt->fetchAll();
        
        // Add language metadata to each leaderboard entry
        if ($includeLanguage) {
            foreach ($leaderboard as &$entry) {
                $entry['language_enabled'] = true;
                $entry['include_language'] = $includeLanguage;
                $entry['supported_language'] = self::SUPPORTED_LANGUAGES[$includeLanguage] ?? 'Unknown';
            }
        }
        
        return $leaderboard;
    }
    
    // ✅ NEW: Check if a language is supported
    private function isLanguageSupported($languageCode) {
        return array_key_exists($languageCode, self::SUPPORTED_LANGUAGES);
    }
    
    // ✅ NEW: Build dynamic question fields for queries
    private function buildQuestionFields($includeLanguage) {
        $baseFields = "q.question_text, q.question_type, q.explanation";
        
        if ($includeLanguage && $this->isLanguageSupported($includeLanguage)) {
            $baseFields .= ", q.question_text_{$includeLanguage}, q.explanation_{$includeLanguage}";
        }
        
        return $baseFields;
    }
    
    // ✅ NEW: Build dynamic answer fields for queries
    private function buildAnswerFields($includeLanguage) {
        $baseFields = "a.answer_text";
        
        if ($includeLanguage && $this->isLanguageSupported($includeLanguage)) {
            $baseFields .= ", a.answer_text_{$includeLanguage}";
        }
        
        return $baseFields;
    }
    
    // ✅ NEW: Build dynamic JSON fields for answer details
    private function buildAnswerJsonFields($includeLanguage) {
        if (!$includeLanguage || !$this->isLanguageSupported($includeLanguage)) {
            return "";
        }
        
        return "'answer_text_{$includeLanguage}', a.answer_text_{$includeLanguage},";
    }
    
    // ✅ NEW: Calculate translation coverage for response metadata
    private function calculateTranslationCoverage($answers, $includeLanguage) {
        if (!$includeLanguage || !$this->isLanguageSupported($includeLanguage) || empty($answers)) {
            return [
                'questions_translated' => 0,
                'questions_total' => count($answers),
                'coverage_percentage' => 0
            ];
        }
        
        $totalQuestions = count($answers);
        $translatedQuestions = 0;
        $questionLangField = "question_text_{$includeLanguage}";
        
        foreach ($answers as $answer) {
            if (!empty($answer[$questionLangField])) {
                $translatedQuestions++;
            }
        }
        
        return [
            'questions_translated' => $translatedQuestions,
            'questions_total' => $totalQuestions,
            'coverage_percentage' => $totalQuestions > 0 ? round(($translatedQuestions / $totalQuestions) * 100, 2) : 0,
            'language_code' => $includeLanguage,
            'language_name' => self::SUPPORTED_LANGUAGES[$includeLanguage]
        ];
    }
    
    // ✅ NEW: Get user attempt statistics with language support
    public function getUserAttemptStats($userId, $includeLanguage = null) {
        $sql = "SELECT 
                    COUNT(*) as total_attempts,
                    COUNT(CASE WHEN completed_at IS NOT NULL THEN 1 END) as completed_attempts,
                    COUNT(CASE WHEN is_passed = 1 THEN 1 END) as passed_attempts,
                    AVG(CASE WHEN completed_at IS NOT NULL THEN percentage END) as average_score,
                    MAX(percentage) as best_score,
                    MIN(percentage) as worst_score,
                    AVG(CASE WHEN completed_at IS NOT NULL THEN time_taken END) as average_time
                FROM {$this->table}
                WHERE user_id = :user_id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        
        $stats = $stmt->fetch();
        
        // Add language metadata
        if ($includeLanguage) {
            $stats['language_enabled'] = true;
            $stats['include_language'] = $includeLanguage;
            $stats['supported_language'] = self::SUPPORTED_LANGUAGES[$includeLanguage] ?? 'Unknown';
        }
        
        // Format numbers
        $stats['average_score'] = $stats['average_score'] ? round($stats['average_score'], 2) : 0;
        $stats['average_time'] = $stats['average_time'] ? round($stats['average_time']) : 0;
        $stats['pass_rate'] = $stats['completed_attempts'] > 0 ? 
            round(($stats['passed_attempts'] / $stats['completed_attempts']) * 100, 2) : 0;
        
        return $stats;
    }
    
    // ✅ NEW: Get recent attempts with language support
    public function getRecentAttempts($userId, $limit = 5, $includeLanguage = null) {
        $titleFields = "t.title, t.test_number";
        if ($includeLanguage && $this->isLanguageSupported($includeLanguage)) {
            $titleFields .= ", t.title_{$includeLanguage}";
        }
        
        $sql = "SELECT uta.id, uta.percentage, uta.is_passed, uta.completed_at, uta.time_taken,
                       {$titleFields}
                FROM {$this->table} uta
                JOIN tests t ON uta.test_id = t.id
                WHERE uta.user_id = :user_id AND uta.completed_at IS NOT NULL
                ORDER BY uta.completed_at DESC
                LIMIT :limit";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        $attempts = $stmt->fetchAll();
        
        // Add language metadata
        if ($includeLanguage) {
            foreach ($attempts as &$attempt) {
                $attempt['language_enabled'] = true;
                $attempt['include_language'] = $includeLanguage;
                $attempt['supported_language'] = self::SUPPORTED_LANGUAGES[$includeLanguage] ?? 'Unknown';
            }
        }
        
        return $attempts;
    }
}
?>