<?php
require_once __DIR__ . '/../Core/BaseModel.php';

class Test extends BaseModel {
    protected $table = 'tests';
    protected $fillable = ['chapter_id', 'test_number', 'test_type', 'title', 'url'];
    
    // Language field mappings for dynamic queries
    private const LANGUAGE_FIELDS = [
        'questions' => [
            'text' => 'question_text',
            'explanation' => 'explanation'
        ],
        'answers' => [
            'text' => 'answer_text'
        ]
    ];
    
    // Supported language codes (matches TestController)
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
    
    // ✅ ENHANCED: Dynamic language support for available tests
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
    
    // ✅ ENHANCED: Dynamic language support for test with questions
    public function getTestWithQuestions($testId, $includeCorrectAnswers = false, $includeLanguage = null) {
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
        
        // Build dynamic question fields based on language
        $questionFields = $this->buildQuestionFields($includeLanguage);
        
        $sql = "SELECT {$questionFields}
                FROM questions q
                WHERE q.test_id = :test_id
                ORDER BY q.id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':test_id', $testId);
        $stmt->execute();
        
        $questions = $stmt->fetchAll();
        
        // Get answers for each question with dynamic language support
        foreach ($questions as &$question) {
            $answerFields = $this->buildAnswerFields($includeCorrectAnswers, $includeLanguage);
            
            $answerSql = "SELECT {$answerFields} FROM answers WHERE question_id = :question_id ORDER BY id";
            
            $answerStmt = $this->db->prepare($answerSql);
            $answerStmt->bindParam(':question_id', $question['id']);
            $answerStmt->execute();
            
            $question['answers'] = $answerStmt->fetchAll();
        }
        
        $test['questions'] = $questions;
        $test['question_count'] = count($questions);
        
        // Add metadata
        $test['language_enabled'] = $includeLanguage !== null;
        $test['include_language'] = $includeLanguage;
        $test['supported_language'] = $includeLanguage ? self::SUPPORTED_LANGUAGES[$includeLanguage] ?? 'Unknown' : null;
        
        return $test;
    }
    
    // ✅ ENHANCED: Dynamic language support for single question
    public function getQuestionWithAnswers($questionId, $includeCorrectAnswers = false, $includeLanguage = null) {
        // Build dynamic question query
        $questionFields = $this->buildQuestionFields($includeLanguage);
        
        $questionSql = "SELECT {$questionFields} FROM questions q WHERE q.id = :question_id";
        $question = $this->query($questionSql, [':question_id' => $questionId]);
        
        if (empty($question)) {
            return null;
        }
        
        $question = $question[0];
        
        // Build dynamic answers query
        $answerFields = $this->buildAnswerFields($includeCorrectAnswers, $includeLanguage);
        
        $answersSql = "SELECT {$answerFields}
                       FROM answers a 
                       WHERE a.question_id = :question_id 
                       ORDER BY a.id";
        
        $answers = $this->query($answersSql, [':question_id' => $questionId]);
        $question['answers'] = $answers;
        
        // Add metadata
        $question['language_enabled'] = $includeLanguage !== null;
        $question['include_language'] = $includeLanguage;
        $question['supported_language'] = $includeLanguage ? self::SUPPORTED_LANGUAGES[$includeLanguage] ?? 'Unknown' : null;
        
        return $question;
    }
    
    // ✅ Existing methods with same interface (backward compatibility)
    public function getFreeTests() {
        return $this->query("SELECT * FROM {$this->table} ORDER BY test_number");
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
    
    // ✅ NEW: Get comprehensive multi-language translation statistics
    public function getMultiLanguageStats() {
        $stats = [];
        
        // Get question statistics for each language
        foreach (self::SUPPORTED_LANGUAGES as $langCode => $langName) {
            $questionStats = $this->query("
                SELECT 
                    COUNT(*) as total_questions,
                    COUNT(question_text_{$langCode}) as translated_questions,
                    COUNT(explanation_{$langCode}) as translated_explanations
                FROM questions
            ");
            
            $answerStats = $this->query("
                SELECT 
                    COUNT(*) as total_answers,
                    COUNT(answer_text_{$langCode}) as translated_answers
                FROM answers
            ");
            
            $qStats = $questionStats[0];
            $aStats = $answerStats[0];
            
            $stats[$langCode] = [
                'language_name' => $langName,
                'language_code' => $langCode,
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
                ],
                'overall_coverage' => $this->calculateOverallCoverage($qStats, $aStats)
            ];
        }
        
        // Add summary statistics
        $summary = $this->calculateSummaryStats($stats);
        
        return [
            'languages' => $stats,
            'summary' => $summary,
            'total_supported_languages' => count(self::SUPPORTED_LANGUAGES),
            'last_updated' => date('Y-m-d H:i:s')
        ];
    }
    
    // ✅ NEW: Check if a language is supported
    public function isLanguageSupported($languageCode) {
        return array_key_exists($languageCode, self::SUPPORTED_LANGUAGES);
    }
    
    // ✅ NEW: Get supported languages list
    public function getSupportedLanguages() {
        return self::SUPPORTED_LANGUAGES;
    }
    
    // ✅ NEW: Get language field name for dynamic queries
    public function getLanguageFieldName($baseField, $languageCode) {
        if ($languageCode === 'en' || $languageCode === null) {
            return $baseField; // English uses base field names
        }
        
        if (!$this->isLanguageSupported($languageCode)) {
            return $baseField; // Fallback to English if unsupported
        }
        
        return $baseField . '_' . $languageCode;
    }
    
    // ✅ PRIVATE: Build dynamic question fields for queries
    private function buildQuestionFields($includeLanguage) {
        $baseFields = "q.id, q.question_id, q.question_text, q.question_type, q.explanation";
        
        if ($includeLanguage && $this->isLanguageSupported($includeLanguage)) {
            $languageFields = ", q.question_text_{$includeLanguage}, q.explanation_{$includeLanguage}";
            return $baseFields . $languageFields;
        }
        
        return $baseFields;
    }
    
    // ✅ PRIVATE: Build dynamic answer fields for queries
    private function buildAnswerFields($includeCorrectAnswers, $includeLanguage) {
        $baseFields = "id, answer_id, answer_text";
        
        if ($includeLanguage && $this->isLanguageSupported($includeLanguage)) {
            $baseFields .= ", answer_text_{$includeLanguage}";
        }
        
        if ($includeCorrectAnswers) {
            $baseFields .= ", is_correct";
        }
        
        return $baseFields;
    }
    
    // ✅ PRIVATE: Calculate overall coverage for a language
    private function calculateOverallCoverage($questionStats, $answerStats) {
        $totalItems = (int)$questionStats['total_questions'] + (int)$answerStats['total_answers'];
        $translatedItems = (int)$questionStats['translated_questions'] + (int)$answerStats['translated_answers'];
        
        if ($totalItems === 0) {
            return 0;
        }
        
        return round(($translatedItems / $totalItems) * 100, 2);
    }
    
    // ✅ PRIVATE: Calculate summary statistics across all languages
    private function calculateSummaryStats($languageStats) {
        if (empty($languageStats)) {
            return [
                'best_coverage_language' => null,
                'worst_coverage_language' => null,
                'average_coverage' => 0,
                'total_translations' => 0
            ];
        }
        
        $coverages = [];
        $totalTranslations = 0;
        $bestLang = null;
        $worstLang = null;
        $bestCoverage = -1;
        $worstCoverage = 101;
        
        foreach ($languageStats as $langCode => $stats) {
            $coverage = $stats['overall_coverage'];
            $coverages[] = $coverage;
            
            $totalTranslations += $stats['questions']['translated'] + $stats['answers']['translated'];
            
            if ($coverage > $bestCoverage) {
                $bestCoverage = $coverage;
                $bestLang = [
                    'code' => $langCode,
                    'name' => $stats['language_name'],
                    'coverage' => $coverage
                ];
            }
            
            if ($coverage < $worstCoverage) {
                $worstCoverage = $coverage;
                $worstLang = [
                    'code' => $langCode,
                    'name' => $stats['language_name'],
                    'coverage' => $coverage
                ];
            }
        }
        
        return [
            'best_coverage_language' => $bestLang,
            'worst_coverage_language' => $worstLang,
            'average_coverage' => round(array_sum($coverages) / count($coverages), 2),
            'total_translations' => $totalTranslations,
            'languages_with_full_coverage' => count(array_filter($coverages, fn($c) => $c >= 100)),
            'languages_with_good_coverage' => count(array_filter($coverages, fn($c) => $c >= 80)),
            'languages_needing_improvement' => count(array_filter($coverages, fn($c) => $c < 50))
        ];
    }
    
    // ✅ BACKWARD COMPATIBILITY: Keep old method signature
    public function getTranslationStats() {
        // Return Vietnamese-only stats for backward compatibility
        $multiStats = $this->getMultiLanguageStats();
        
        if (isset($multiStats['languages']['vi'])) {
            return $multiStats['languages']['vi'];
        }
        
        // Fallback if Vietnamese not available
        return [
            'questions' => [
                'total' => 0,
                'translated' => 0,
                'explanations_translated' => 0,
                'coverage_percent' => 0
            ],
            'answers' => [
                'total' => 0,
                'translated' => 0,
                'coverage_percent' => 0
            ]
        ];
    }
}