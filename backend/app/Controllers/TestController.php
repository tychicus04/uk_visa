<?php
require_once __DIR__ . '/../Core/BaseController.php';
require_once __DIR__ . '/../Models/Test.php';
require_once __DIR__ . '/../Models/User.php';
require_once __DIR__ . '/../../middleware/SimpleAuthMiddleware.php';
require_once __DIR__ . '/../../middleware/CacheMiddleware.php';

class TestController extends BaseController {
    private $testModel;
    private $userModel;
    
    public function __construct() {
        $this->testModel = new Test();
        $this->userModel = new User();
    }
    
    // 🆕 UPDATED: Add Vietnamese support
    public function getAvailableTests() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            // 🔧 FIX: Get fresh Vietnamese preference
            $includeVietnamese = $this->shouldIncludeVietnamese($user);
            
            // 🔧 FIX: Better cache key with user ID
            $cacheKey = $this->generateCacheKey(
                "available_tests",
                $user['user_id'],
                $includeVietnamese
            );
            
            $cachedTests = CacheMiddleware::get($cacheKey, 300); // 5 minutes cache
            
            if ($cachedTests !== null) {
                $this->success($cachedTests, 'Tests retrieved from cache');
                return;
            }
            
            $tests = $this->testModel->getAvailableTests($user['user_id']);
            
            // Group tests by type
            $groupedTests = [
                'chapter' => [],
                'comprehensive' => [],
                'exam' => []
            ];
            
            foreach ($tests as $test) {
                $groupedTests[$test['test_type']][] = $test;
            }
            
            // 🔧 FIX: Get fresh user language from database
            $userLanguageSql = "SELECT language_code FROM users WHERE id = :user_id";
            $userLangResult = $this->userModel->query($userLanguageSql, [':user_id' => $user['user_id']]);
            $currentUserLanguage = !empty($userLangResult) ? $userLangResult[0]['language_code'] : 'en';
            
            $response = [
                'tests' => $groupedTests,
                'vietnamese_enabled' => $includeVietnamese,
                'user_language' => $currentUserLanguage, // Fresh from database
                'cache_key' => $cacheKey, // For debugging
                'fresh_language_check' => true
            ];
            
            // Cache the result
            CacheMiddleware::set($cacheKey, $response, 300);
            
            $this->success($response);
            
        } catch (Exception $e) {
            logError('Get available tests error: ' . $e->getMessage(), ['user_id' => $user['user_id']]);
            $this->error('Failed to retrieve tests', 500);
        }
    }
    
    // 🆕 UPDATED: Add Vietnamese parameter support
    public function getTest($testId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            // Check if user can access this test
            if (!$this->userModel->canAccessTest($user['user_id'], $testId)) {
                $this->error('Access denied. Premium subscription required or free test limit reached.', 403);
            }
            
            // 🔧 FIX: Get fresh Vietnamese preference (not from JWT)
            $includeVietnamese = $this->shouldIncludeVietnamese($user);
            $includeCorrectAnswers = isset($_GET['include_answers']) && $_GET['include_answers'] === 'true';
            
            // 🔧 FIX: Better cache key that includes user ID
            $cacheKey = $this->generateCacheKey(
                "test_content_{$testId}",
                $user['user_id'],
                $includeVietnamese,
                ['answers' => $includeCorrectAnswers ? '1' : '0']
            );
            
            $test = CacheMiddleware::get($cacheKey, 1800); // 30 minutes cache
            
            if ($test === null) {
                // Get fresh data with current Vietnamese preference
                $test = $this->testModel->getTestWithQuestions($testId, $includeCorrectAnswers, $includeVietnamese);
                if (!$test) {
                    $this->error('Test not found', 404);
                }
                CacheMiddleware::set($cacheKey, $test, 1800);
            }
            
            // 🔧 FIX: Get fresh user language from database for response
            $userLanguageSql = "SELECT language_code FROM users WHERE id = :user_id";
            $userLangResult = $this->userModel->query($userLanguageSql, [':user_id' => $user['user_id']]);
            $currentUserLanguage = !empty($userLangResult) ? $userLangResult[0]['language_code'] : 'en';
            
            $response = [
                'test' => $test,
                'vietnamese_enabled' => $includeVietnamese,
                'user_language' => $currentUserLanguage, // Fresh from database
                'include_correct_answers' => $includeCorrectAnswers,
                'cache_key' => $cacheKey, // For debugging
                'fresh_language_check' => true // Indicates we checked database
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            logError('Get test error: ' . $e->getMessage(), ['user_id' => $user['user_id'], 'test_id' => $testId]);
            $this->error('Failed to retrieve test', 500);
        }
    }
    
    // 🆕 UPDATED: Add Vietnamese support
    public function getTestsByType($type) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        $allowedTypes = ['chapter', 'comprehensive', 'exam'];
        if (!in_array($type, $allowedTypes)) {
            $this->error('Invalid test type', 400);
        }
        
        try {
            // 🆕 VIETNAMESE SUPPORT
            $includeVietnamese = $user ? $this->shouldIncludeVietnamese($user) : false;
            $tests = $this->testModel->getTestsByType($type);
            
            $response = [
                'tests' => $tests,
                'test_type' => $type,
                'vietnamese_enabled' => $includeVietnamese,
                'user_language' => $user['language_code'] ?? 'en'
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve tests', 500);
        }
    }
    
    // 🆕 UPDATED: Add Vietnamese support
    public function getTestsByChapter($chapterId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        try {
            // 🆕 VIETNAMESE SUPPORT
            $includeVietnamese = $user ? $this->shouldIncludeVietnamese($user) : false;
            $tests = $this->testModel->getTestsByChapter($chapterId);
            
            $response = [
                'tests' => $tests,
                'chapter_id' => $chapterId,
                'vietnamese_enabled' => $includeVietnamese,
                'user_language' => $user['language_code'] ?? 'en'
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve tests', 500);
        }
    }
    
    // 🆕 UPDATED: Add Vietnamese support
    public function getFreeTests() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        try {
            // 🆕 VIETNAMESE SUPPORT
            $includeVietnamese = $user ? $this->shouldIncludeVietnamese($user) : false;
            $tests = $this->testModel->getFreeTests();
            
            $response = [
                'tests' => $tests,
                'vietnamese_enabled' => $includeVietnamese,
                'user_language' => $user['language_code'] ?? 'en'
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve free tests', 500);
        }
    }
    
    // 🆕 ENHANCED: Use new search method with Vietnamese support
    public function searchTests() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        $query = $_GET['q'] ?? '';
        $type = $_GET['type'] ?? '';
        $chapter = $_GET['chapter'] ?? '';
        $query = trim($query);
        
        if (empty($query)) {
            $this->error('Search query is required', 400);
        }
        
        try {
            // 🆕 VIETNAMESE SEARCH SUPPORT
            $includeVietnamese = $user ? $this->shouldIncludeVietnamese($user) : false;
            $tests = $this->testModel->searchTests($query, $type, $chapter, $includeVietnamese);
            
            $response = [
                'tests' => $tests,
                'search_query' => $query,
                'search_type' => $type,
                'search_chapter' => $chapter,
                'vietnamese_enabled' => $includeVietnamese,
                'user_language' => $user['language_code'] ?? 'en',
                'results_count' => count($tests)
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            logError('Search tests error: ' . $e->getMessage(), [
                'query' => $query, 
                'type' => $type, 
                'chapter' => $chapter,
                'user_id' => $user['user_id'] ?? null
            ]);
            $this->error('Search failed', 500);
        }
    }
    
    // 🆕 NEW ENDPOINT: Get single question with Vietnamese
    public function getQuestion($questionId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            $includeVietnamese = $this->shouldIncludeVietnamese($user);
            $includeCorrectAnswers = isset($_GET['include_answers']) && $_GET['include_answers'] === 'true';
            
            $question = $this->testModel->getQuestionWithAnswers($questionId, $includeCorrectAnswers, $includeVietnamese);
            
            if (!$question) {
                $this->error('Question not found', 404);
            }
            
            $response = [
                'question' => $question,
                'vietnamese_enabled' => $includeVietnamese,
                'user_language' => $user['language_code'] ?? 'en',
                'include_correct_answers' => $includeCorrectAnswers
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            logError('Get question error: ' . $e->getMessage(), ['question_id' => $questionId, 'user_id' => $user['user_id']]);
            $this->error('Failed to retrieve question', 500);
        }
    }
    
    // 🆕 NEW ENDPOINT: Update language preference
    public function updateLanguagePreference() {
        $this->validateMethod(['POST', 'PUT']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            $data = $this->getJsonInput();
            
            if (!isset($data['language_code'])) {
                $this->error('Language code is required', 400);
            }
            
            $allowedLanguages = ['en', 'vi'];
            if (!in_array($data['language_code'], $allowedLanguages)) {
                $this->error('Invalid language code. Allowed: ' . implode(', ', $allowedLanguages), 400);
            }
            
            // Get current language for comparison
            $currentLangSql = "SELECT language_code FROM users WHERE id = :user_id";
            $currentResult = $this->userModel->query($currentLangSql, [':user_id' => $user['user_id']]);
            $currentLanguage = !empty($currentResult) ? $currentResult[0]['language_code'] : 'en';
            
            // Only update if language actually changed
            if ($currentLanguage !== $data['language_code']) {
                // Update user's language preference in database
                $sql = "UPDATE users SET language_code = :language_code, updated_at = NOW() WHERE id = :user_id";
                $updateResult = $this->userModel->query($sql, [
                    ':language_code' => $data['language_code'],
                    ':user_id' => $user['user_id']
                ]);
                
                // Clear ALL related caches immediately
                $this->clearUserTestCaches($user['user_id']);
                
                // Also clear any general caches that might be affected
                CacheMiddleware::delete("user_profile_{$user['user_id']}");
                
                logError("Language preference updated successfully", [
                    'user_id' => $user['user_id'],
                    'old_language' => $currentLanguage,
                    'new_language' => $data['language_code']
                ]);
            }
            
            $response = [
                'language_code' => $data['language_code'],
                'vietnamese_enabled' => $data['language_code'] === 'vi',
                'previous_language' => $currentLanguage,
                'cache_cleared' => $currentLanguage !== $data['language_code'],
                'message' => 'Language preference updated successfully'
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            logError('Update language preference error: ' . $e->getMessage(), ['user_id' => $user['user_id']]);
            $this->error('Failed to update language preference', 500);
        }
    }
    
    // 🆕 NEW ENDPOINT: Get translation statistics
    public function getTranslationStats() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth(); // Optional auth for admin stats
        
        try {
            $stats = $this->testModel->getTranslationStats();
            
            $response = [
                'translation_stats' => $stats,
                'supported_languages' => ['en', 'vi'],
                'default_language' => 'en'
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            logError('Get translation stats error: ' . $e->getMessage());
            $this->error('Failed to retrieve translation statistics', 500);
        }
    }
    
    // 🆕 HELPER METHODS
    private function shouldIncludeVietnamese($user) {
        // Priority 1: URL parameter override (always takes precedence)
        if (isset($_GET['include_vietnamese'])) {
            return $_GET['include_vietnamese'] === 'true';
        }
        
        // Priority 2: Get FRESH language preference from database
        try {
            $sql = "SELECT language_code FROM users WHERE id = :user_id LIMIT 1";
            $result = $this->userModel->query($sql, [':user_id' => $user['user_id']]);
            
            if (!empty($result)) {
                $latestUser = $result[0];
                return $latestUser['language_code'] === 'vi';
            }
        } catch (Exception $e) {
            // Log error but don't break the flow
            logError('Failed to get user language preference: ' . $e->getMessage(), ['user_id' => $user['user_id']]);
        }
        
        // Priority 3: Fallback to JWT token data (if database query fails)
        if (isset($user['language_code'])) {
            return $user['language_code'] === 'vi';
        }
        
        // Priority 4: Check Accept-Language header
        if (isset($_SERVER['HTTP_ACCEPT_LANGUAGE']) && 
            strpos($_SERVER['HTTP_ACCEPT_LANGUAGE'], 'vi') !== false) {
            return true;
        }
        
        // Default: No Vietnamese
        return false;
    }
    
    private function clearUserTestCaches($userId) {
        // Clear all possible cache combinations for this user
        $cachePatterns = [
            "available_tests_user_{$userId}_vi_0",
            "available_tests_user_{$userId}_vi_1",
            "user_language_preference_{$userId}",
        ];
        
        // Also clear test content caches that might include user-specific language
        try {
            // Get all test IDs to clear their caches
            $tests = $this->testModel->query("SELECT id FROM tests");
            foreach ($tests as $test) {
                $testId = $test['id'];
                $cachePatterns[] = "test_content_{$testId}_vi_0_answers_false";
                $cachePatterns[] = "test_content_{$testId}_vi_1_answers_false";
                $cachePatterns[] = "test_content_{$testId}_vi_0_answers_true";
                $cachePatterns[] = "test_content_{$testId}_vi_1_answers_true";
            }
        } catch (Exception $e) {
            logError('Failed to clear test caches: ' . $e->getMessage());
        }
        
        // Clear all patterns
        foreach ($cachePatterns as $pattern) {
            CacheMiddleware::delete($pattern);
        }
        
        // Log cache clearing for debugging
        logError("Cleared caches for user language update", [
            'user_id' => $userId,
            'cleared_patterns' => count($cachePatterns)
        ]);
    }
    
    private function getJsonInput() {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception('Invalid JSON input: ' . json_last_error_msg());
        }
        
        return $data;
    }

    private function generateCacheKey($baseKey, $userId, $includeVietnamese, $additionalParams = []) {
        $keyParts = [
            $baseKey,
            "user_{$userId}",
            "vi_" . ($includeVietnamese ? '1' : '0')
        ];
        
        foreach ($additionalParams as $key => $value) {
            $keyParts[] = "{$key}_{$value}";
        }
        
        return implode('_', $keyParts);
    }
}