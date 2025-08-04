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
    
    public function getAvailableTests() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            // Check cache first
            $cacheKey = "available_tests_user_{$user['user_id']}";
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
            
            // Cache the result
            CacheMiddleware::set($cacheKey, $groupedTests, 300);
            
            $this->success($groupedTests);
            
        } catch (Exception $e) {
            logError('Get available tests error: ' . $e->getMessage(), ['user_id' => $user['user_id']]);
            $this->error('Failed to retrieve tests', 500);
        }
    }
    
    public function getTest($testId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            // Check if user can access this test
            if (!$this->userModel->canAccessTest($user['user_id'], $testId)) {
                $this->error('Access denied. Premium subscription required or free test limit reached.', 403);
            }
            
            // Check cache
            $cacheKey = "test_content_{$testId}";
            $test = CacheMiddleware::get($cacheKey, 1800); // 30 minutes cache
            
            if ($test === null) {
                $test = $this->testModel->getTestWithQuestions($testId, false); // Don't include correct answers
                if (!$test) {
                    $this->error('Test not found', 404);
                }
                CacheMiddleware::set($cacheKey, $test, 1800);
            }
            
            $this->success($test);
            
        } catch (Exception $e) {
            logError('Get test error: ' . $e->getMessage(), ['user_id' => $user['user_id'], 'test_id' => $testId]);
            $this->error('Failed to retrieve test', 500);
        }
    }
    
    public function getTestsByType($type) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        $allowedTypes = ['chapter', 'comprehensive', 'exam'];
        if (!in_array($type, $allowedTypes)) {
            $this->error('Invalid test type', 400);
        }
        
        try {
            $tests = $this->testModel->getTestsByType($type);
            $this->success($tests);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve tests', 500);
        }
    }
    
    public function getTestsByChapter($chapterId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        try {
            $tests = $this->testModel->getTestsByChapter($chapterId);
            $this->success($tests);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve tests', 500);
        }
    }
    
    public function getFreeTests() {
        $this->validateMethod(['GET']);
        
        try {
            $tests = $this->testModel->getFreeTests();
            $this->success($tests);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve free tests', 500);
        }
    }
    
    public function searchTests() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        $query = $_GET['q'] ?? '';
        $type = $_GET['type'] ?? '';
        $chapter = $_GET['chapter'] ?? '';
        $query = trim($query);
        
        try {
            $sql = "SELECT t.*, c.name as chapter_name 
                    FROM tests t 
                    LEFT JOIN chapters c ON t.chapter_id = c.id 
                    WHERE (t.title LIKE :query OR t.test_number LIKE :query OR c.name LIKE :query)";
            
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
            
            $tests = $this->testModel->query($sql, $params);
            $this->success($tests);
            
        } catch (Exception $e) {
            $this->error('Search failed', 500);
        }
    }
}