<?php
require_once __DIR__ . '/../Core/BaseController.php';
require_once __DIR__ . '/../Models/Test.php';
require_once __DIR__ . '/../Models/User.php';
require_once __DIR__ . '/../../middleware/SimpleAuthMiddleware.php';
require_once __DIR__ . '/../../middleware/CacheMiddleware.php';

class TestController extends BaseController {
    private $testModel;
    private $userModel;
    
    // Supported language mappings
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
        $this->testModel = new Test();
        $this->userModel = new User();
    }
    
    // ✅ UPDATED: Dynamic multi-language support
    public function getAvailableTests() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            // Get language preference - supports both old and new parameters
            $includeLanguage = $this->getIncludeLanguage($user);
            
            // Generate cache key with language support
            $cacheKey = $this->generateCacheKey(
                "available_tests",
                $user['user_id'],
                $includeLanguage
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
            
            // Get fresh user language from database
            $userLanguageSql = "SELECT language_code FROM users WHERE id = :user_id";
            $userLangResult = $this->userModel->query($userLanguageSql, [':user_id' => $user['user_id']]);
            $currentUserLanguage = !empty($userLangResult) ? $userLangResult[0]['language_code'] : 'en';
            
            $response = [
                'tests' => $groupedTests,
                'language_enabled' => $includeLanguage !== null,
                'include_language' => $includeLanguage,
                'user_language' => $currentUserLanguage,
                'supported_languages' => self::SUPPORTED_LANGUAGES,
                'cache_key' => $cacheKey,
                'fresh_language_check' => true
            ];
            
            // Cache the result
            CacheMiddleware::set($cacheKey, $response, 300);
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve tests', 500);
        }
    }
    
    // ✅ UPDATED: Dynamic language support for single test
    public function getTest($testId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            // Check if user can access this test
            if (!$this->userModel->canAccessTest($user['user_id'], $testId)) {
                $this->error('Access denied. Premium subscription required or free test limit reached.', 403);
            }
            
            $includeLanguage = $this->getIncludeLanguage($user);
            $includeCorrectAnswers = isset($_GET['include_answers']) && $_GET['include_answers'] === 'true';
            
            // Generate cache key with language support
            $cacheKey = $this->generateCacheKey(
                "test_content_{$testId}",
                $user['user_id'],
                $includeLanguage,
                ['answers' => $includeCorrectAnswers ? '1' : '0']
            );
            
            $test = CacheMiddleware::get($cacheKey, 1800); // 30 minutes cache
            
            if ($test === null) {
                // Get fresh data with current language preference
                $test = $this->testModel->getTestWithQuestions($testId, $includeCorrectAnswers, $includeLanguage);
                if (!$test) {
                    $this->error('Test not found', 404);
                }
                CacheMiddleware::set($cacheKey, $test, 1800);
            }
            
            // Get fresh user language from database for response
            $userLanguageSql = "SELECT language_code FROM users WHERE id = :user_id";
            $userLangResult = $this->userModel->query($userLanguageSql, [':user_id' => $user['user_id']]);
            $currentUserLanguage = !empty($userLangResult) ? $userLangResult[0]['language_code'] : 'en';
            
            $response = [
                'test' => $test,
                'language_enabled' => $includeLanguage !== null,
                'include_language' => $includeLanguage,
                'user_language' => $currentUserLanguage,
                'include_correct_answers' => $includeCorrectAnswers,
                'supported_languages' => self::SUPPORTED_LANGUAGES,
                'cache_key' => $cacheKey,
                'fresh_language_check' => true
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve test', 500);
        }
    }
    
    // ✅ UPDATED: Dynamic language support for test types
    public function getTestsByType($type) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        $allowedTypes = ['chapter', 'comprehensive', 'exam'];
        if (!in_array($type, $allowedTypes)) {
            $this->error('Invalid test type', 400);
        }
        
        try {
            $includeLanguage = $user ? $this->getIncludeLanguage($user) : null;
            $tests = $this->testModel->getTestsByType($type);
            
            $response = [
                'tests' => $tests,
                'test_type' => $type,
                'language_enabled' => $includeLanguage !== null,
                'include_language' => $includeLanguage,
                'user_language' => $user['language_code'] ?? 'en',
                'supported_languages' => self::SUPPORTED_LANGUAGES
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve tests', 500);
        }
    }
    
    // ✅ UPDATED: Dynamic language support for chapter tests
    public function getTestsByChapter($chapterId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        try {
            $includeLanguage = $user ? $this->getIncludeLanguage($user) : null;
            $tests = $this->testModel->getTestsByChapter($chapterId);
            
            $response = [
                'tests' => $tests,
                'chapter_id' => $chapterId,
                'language_enabled' => $includeLanguage !== null,
                'include_language' => $includeLanguage,
                'user_language' => $user['language_code'] ?? 'en',
                'supported_languages' => self::SUPPORTED_LANGUAGES
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve tests', 500);
        }
    }
    
    // ✅ UPDATED: Dynamic language support for free tests
    public function getFreeTests() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        try {
            $includeLanguage = $user ? $this->getIncludeLanguage($user) : null;
            $tests = $this->testModel->getFreeTests();
            
            $response = [
                'tests' => $tests,
                'language_enabled' => $includeLanguage !== null,
                'include_language' => $includeLanguage,
                'user_language' => $user['language_code'] ?? 'en',
                'supported_languages' => self::SUPPORTED_LANGUAGES
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve free tests', 500);
        }
    }
    
    // ✅ UPDATED: Dynamic language support for single question
    public function getQuestion($questionId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            $includeLanguage = $this->getIncludeLanguage($user);
            $includeCorrectAnswers = isset($_GET['include_answers']) && $_GET['include_answers'] === 'true';
            
            $question = $this->testModel->getQuestionWithAnswers($questionId, $includeCorrectAnswers, $includeLanguage);
            
            if (!$question) {
                $this->error('Question not found', 404);
            }
            
            $response = [
                'question' => $question,
                'language_enabled' => $includeLanguage !== null,
                'include_language' => $includeLanguage,
                'user_language' => $user['language_code'] ?? 'en',
                'include_correct_answers' => $includeCorrectAnswers,
                'supported_languages' => self::SUPPORTED_LANGUAGES
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve question', 500);
        }
    }
    
    // ✅ NEW: Get supported languages endpoint
    public function getSupportedLanguages() {
        $this->validateMethod(['GET']);
        
        try {
            $stats = $this->testModel->getMultiLanguageStats();
            
            $response = [
                'supported_languages' => self::SUPPORTED_LANGUAGES,
                'default_language' => 'en',
                'translation_stats' => $stats,
                'total_languages' => count(self::SUPPORTED_LANGUAGES) + 1 // +1 for English
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve supported languages', 500);
        }
    }
    
    // ✅ UPDATED: Enhanced translation statistics
    public function getTranslationStats() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth(); // Optional auth for admin stats
        
        try {
            $stats = $this->testModel->getMultiLanguageStats();
            
            $response = [
                'translation_stats' => $stats,
                'supported_languages' => self::SUPPORTED_LANGUAGES,
                'default_language' => 'en',
                'total_languages' => count(self::SUPPORTED_LANGUAGES) + 1
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve translation statistics', 500);
        }
    }
    
    // ✅ UPDATED: Enhanced language preference update
    public function updateLanguagePreference() {
        $this->validateMethod(['POST', 'PUT']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            $data = $this->getJsonInput();
            
            if (!isset($data['language_code'])) {
                $this->error('Language code is required', 400);
            }
            
            $allowedLanguages = array_merge(['en'], array_keys(self::SUPPORTED_LANGUAGES));
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
                $this->clearUserCaches($user['user_id']);
            }
            
            $response = [
                'language_code' => $data['language_code'],
                'language_enabled' => $data['language_code'] !== 'en',
                'language_name' => self::SUPPORTED_LANGUAGES[$data['language_code']] ?? 'English',
                'previous_language' => $currentLanguage,
                'cache_cleared' => $currentLanguage !== $data['language_code'],
                'supported_languages' => self::SUPPORTED_LANGUAGES,
                'message' => 'Language preference updated successfully'
            ];
            
            $this->success($response);
            
        } catch (Exception $e) {
            $this->error('Failed to update language preference', 500);
        }
    }
    
    // ✅ NEW: Core method to determine include language dynamically
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
    
    // ✅ UPDATED: Enhanced cache clearing for multiple languages
    private function clearUserCaches($userId) {
        // Clear all possible cache combinations for this user
        $cachePatterns = [
            "user_language_preference_{$userId}",
        ];
        
        // Generate cache patterns for all supported languages
        foreach (self::SUPPORTED_LANGUAGES as $langCode => $langName) {
            $cachePatterns[] = "available_tests_user_{$userId}_{$langCode}";
        }
        
        // Add English (null language) patterns
        $cachePatterns[] = "available_tests_user_{$userId}_null";
        
        // Also clear test content caches for all languages
        try {
            // Get all test IDs to clear their caches
            $tests = $this->testModel->query("SELECT id FROM tests");
            foreach ($tests as $test) {
                $testId = $test['id'];
                
                // Clear for all supported languages
                foreach (self::SUPPORTED_LANGUAGES as $langCode => $langName) {
                    $cachePatterns[] = "test_content_{$testId}_{$langCode}_answers_false";
                    $cachePatterns[] = "test_content_{$testId}_{$langCode}_answers_true";
                }
                
                // Clear for English (null language)
                $cachePatterns[] = "test_content_{$testId}_null_answers_false";
                $cachePatterns[] = "test_content_{$testId}_null_answers_true";
            }
        } catch (Exception $e) {
            error_log("Error generating cache patterns: " . $e->getMessage());
        }
        
        // Clear all patterns
        foreach ($cachePatterns as $pattern) {
            CacheMiddleware::delete($pattern);
        }
    }
    
    // ✅ UPDATED: Enhanced cache key generation
    private function generateCacheKey($baseKey, $userId, $includeLanguage, $additionalParams = []) {
        $keyParts = [
            $baseKey,
            "user_{$userId}",
            "lang_" . ($includeLanguage ?? 'en')
        ];
        
        foreach ($additionalParams as $key => $value) {
            $keyParts[] = "{$key}_{$value}";
        }
        
        return implode('_', $keyParts);
    }
    
    // ✅ Helper method to get JSON input
    private function getJsonInput() {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception('Invalid JSON input: ' . json_last_error_msg());
        }
        
        return $data;
    }
}