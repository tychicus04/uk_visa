<?php
require_once __DIR__ . '/../Core/BaseController.php';
require_once __DIR__ . '/../Models/TestAttempt.php';
require_once __DIR__ . '/../Models/User.php';
require_once __DIR__ . '/../Models/Test.php';
require_once __DIR__ . '/../../middleware/SimpleAuthMiddleware.php';
require_once __DIR__ . '/../../middleware/ValidationMiddleware.php';

class AttemptController extends BaseController {
    private $attemptModel;
    private $userModel;
    private $testModel;

    // Enhanced multi-language support (matches TestController)
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
        $this->attemptModel = new TestAttempt();
        $this->userModel = new User();
        $this->testModel = new Test();
    }
    
    public function startAttempt() {
        $this->validateMethod(['POST']);
        $user = SimpleAuthMiddleware::authenticate();
        $data = $this->getRequestData();
        
        if (!isset($data->test_id)) {
            $this->error('Test ID is required', 400);
        }
        
        try {
            // Check if test exists
            $test = $this->testModel->find($data->test_id);
            if (!$test) {
                $this->error('Test not found', 404);
            }
            
            $attemptId = $this->attemptModel->startAttempt($user['user_id'], $data->test_id);
            
            if ($attemptId) {
                $this->success([
                    'attempt_id' => $attemptId,
                    'test' => $test,
                    'started_at' => date('Y-m-d H:i:s')
                ], 'Test attempt started', 201);
            } else {
                $this->error('Failed to start test attempt', 500);
            }
            
        } catch (Exception $e) {
            $this->error('Failed to start test attempt', 500);
        }
    }
    
    public function submitAttempt() {
        $this->validateMethod(['POST']);
        $user = SimpleAuthMiddleware::authenticate();
        $data = $this->getRequestData();
        
        try {
            ValidationMiddleware::validateTestSubmission($data);
            
            // Verify attempt belongs to user
            $attempt = $this->attemptModel->query(
                "SELECT * FROM user_test_attempts WHERE id = :id AND user_id = :user_id",
                [':id' => $data->attempt_id, ':user_id' => $user['user_id']]
            );
            
            if (empty($attempt)) {
                $this->error('Test attempt not found or access denied', 404);
            }
            $attempt = $attempt[0];
            
            // Check if already completed
            if ($attempt['completed_at']) {
                $this->error('Test attempt already completed', 400);
            }
            
            // Process answers
            $answers = [];
            foreach ($data->answers as $answer) {
                $answers[] = [
                    'question_id' => $answer->question_id,
                    'selected_answer_ids' => $answer->selected_answer_ids
                ];
            }
            
            $result = $this->attemptModel->submitAttempt(
                $data->attempt_id, 
                $answers, 
                $data->time_taken ?? null
            );
            
            // Get test details for response
            $test = $this->testModel->find($attempt['test_id']);
            
            $this->success([
                'result' => $result,
                'test' => [
                    'title' => $test['title'],
                    'test_number' => $test['test_number']
                ],
                'completed_at' => date('Y-m-d H:i:s')
            ], 'Test submitted successfully');
            
        } catch (Exception $e) {
            $this->error($e->getMessage(), 500);
        }
    }
    
    // ✅ ENHANCED: Multi-language support for user history
    public function getHistory() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        $pagination = $this->getPaginationParams();
        
        try {
            $includeLanguage = $this->getIncludeLanguage($user);
            
            $history = $this->attemptModel->getUserHistory(
                $user['user_id'], 
                $pagination['limit'], 
                $pagination['offset'],
                $includeLanguage
            );
            
            // Get total count for pagination
            $totalResult = $this->attemptModel->query(
                "SELECT COUNT(*) as total FROM user_test_attempts 
                 WHERE user_id = :user_id AND completed_at IS NOT NULL",
                [':user_id' => $user['user_id']]
            );
            $total = $totalResult[0]['total'];
            
            $response = $this->paginate(
                $history, 
                $total, 
                $pagination['page'], 
                $pagination['limit']
            );
            
            // Add language metadata
            $response['language_info'] = [
                'language_enabled' => $includeLanguage !== null,
                'include_language' => $includeLanguage,
                'user_language' => $user['language_code'] ?? 'en',
                'supported_languages' => self::SUPPORTED_LANGUAGES
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve test history', 500);
        }
    }
    
    // ✅ ENHANCED: Full multi-language support for attempt details
    public function getAttemptDetails($attemptId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            $includeLanguage = $this->getIncludeLanguage($user);
            
            $attempt = $this->attemptModel->getAttemptDetails($attemptId, $user['user_id'], $includeLanguage);
            
            if (!$attempt) {
                $this->error('Test attempt not found', 404);
            }
            
            // Get fresh user language preference for response metadata
            $userLanguageSql = "SELECT language_code FROM users WHERE id = :user_id";
            $userLangResult = $this->userModel->query($userLanguageSql, [':user_id' => $user['user_id']]);
            $currentUserLanguage = !empty($userLangResult) ? $userLangResult[0]['language_code'] : 'en';
            
            // Add enhanced metadata
            $attempt['language_info'] = [
                'language_enabled' => $includeLanguage !== null,
                'include_language' => $includeLanguage,
                'user_language' => $currentUserLanguage,
                'supported_languages' => self::SUPPORTED_LANGUAGES,
                'total_answers' => count($attempt['answers'] ?? []),
                'language_name' => $includeLanguage ? (self::SUPPORTED_LANGUAGES[$includeLanguage] ?? 'Unknown') : 'English'
            ];
            
            // Add debug information in development
            if ($_ENV['APP_DEBUG'] ?? false) {
                $attempt['debug_info'] = [
                    'language_requested' => $includeLanguage,
                    'backward_compatibility' => isset($_GET['include_vietnamese']),
                    'query_params' => $_GET,
                    'request_time' => date('Y-m-d H:i:s')
                ];
            }
            
            $this->success($attempt);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve attempt details', 500);
        }
    }
    
    // ✅ ENHANCED: Multi-language support for leaderboard
    public function getLeaderboard() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        $testId = $_GET['test_id'] ?? null;
        $limit = min(50, max(5, intval($_GET['limit'] ?? 10)));
        
        try {
            $includeLanguage = $user ? $this->getIncludeLanguage($user) : null;
            
            $leaderboard = $this->attemptModel->getLeaderboard($testId, $limit, $includeLanguage);
            
            $response = [
                'leaderboard' => $leaderboard,
                'language_info' => [
                    'language_enabled' => $includeLanguage !== null,
                    'include_language' => $includeLanguage,
                    'user_language' => $user['language_code'] ?? 'en',
                    'supported_languages' => self::SUPPORTED_LANGUAGES
                ]
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve leaderboard', 500);
        }
    }
    
    public function retakeTest() {
        $this->validateMethod(['POST']);
        $user = SimpleAuthMiddleware::authenticate();
        $data = $this->getRequestData();
        
        if (!isset($data->test_id)) {
            $this->error('Test ID is required', 400);
        }
        
        try {
            // Check if user can retake (premium users can retake unlimited, free users have restrictions)
            if (!$user['is_premium']) {
                // Check how many attempts user has made today for this test
                $todayAttempts = $this->attemptModel->query(
                    "SELECT COUNT(*) as count FROM user_test_attempts 
                     WHERE user_id = :user_id AND test_id = :test_id 
                     AND DATE(started_at) = CURDATE()",
                    [':user_id' => $user['user_id'], ':test_id' => $data->test_id]
                );
                
                if ($todayAttempts[0]['count'] >= 3) { // Limit 3 retakes per day for free users
                    $this->error('Daily retake limit reached. Upgrade to premium for unlimited retakes.', 403);
                }
            }
            
            // Start new attempt
            $attemptId = $this->attemptModel->startAttempt($user['user_id'], $data->test_id);
            
            if ($attemptId) {
                $test = $this->testModel->find($data->test_id);
                $this->success([
                    'attempt_id' => $attemptId,
                    'test' => $test,
                    'started_at' => date('Y-m-d H:i:s')
                ], 'Test retake started', 201);
            } else {
                $this->error('Failed to start test retake', 500);
            }
            
        } catch (Exception $e) {
            $this->error('Failed to start test retake', 500);
        }
    }

    // ✅ ENHANCED: Dynamic multi-language detection (same as TestController)
    private function getIncludeLanguage($user) {
        // Priority 1: URL parameter override (always takes precedence)
        if (isset($_GET['include_language'])) {
            $requestedLang = $_GET['include_language'];
            
            // Validate requested language
            if ($requestedLang === 'en' || $requestedLang === '') {
                return null; // English doesn't need additional columns
            }
            
            if (array_key_exists($requestedLang, self::SUPPORTED_LANGUAGES)) {
                return $requestedLang;
            }
            
            // Invalid language requested, log and fallback
            error_log("Invalid language requested: $requestedLang");
            return null;
        }
        
        // Priority 2: Backward compatibility with include_vietnamese
        if (isset($_GET['include_vietnamese'])) {
            return $_GET['include_vietnamese'] === 'true' ? 'vi' : null;
        }
        
        // Priority 3: Get FRESH language preference from database
        try {
            $sql = "SELECT language_code FROM users WHERE id = :user_id LIMIT 1";
            $result = $this->userModel->query($sql, [':user_id' => $user['user_id']]);
            
            if (!empty($result)) {
                $userLang = $result[0]['language_code'];
                
                // English doesn't need additional columns
                if ($userLang === 'en') {
                    return null;
                }
                
                // Check if it's a supported language
                if (array_key_exists($userLang, self::SUPPORTED_LANGUAGES)) {
                    return $userLang;
                }
                
                // Unsupported language, fallback to English
                return null;
            }
        } catch (Exception $e) {
            // Log error but don't break the flow
            error_log("Error getting user language: " . $e->getMessage());
        }
        
        // Priority 4: Fallback to JWT token data (if database query fails)
        if (isset($user['language_code'])) {
            $jwtLang = $user['language_code'];
            
            if ($jwtLang === 'en') {
                return null;
            }
            
            if (array_key_exists($jwtLang, self::SUPPORTED_LANGUAGES)) {
                return $jwtLang;
            }
        }
        
        // Priority 5: Check Accept-Language header for supported languages
        if (isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])) {
            $acceptLanguage = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
            
            foreach (self::SUPPORTED_LANGUAGES as $langCode => $langName) {
                if (strpos($acceptLanguage, $langCode) !== false) {
                    return $langCode;
                }
            }
        }
        
        // Default: No additional language (English only)
        return null;
    }
}
?>