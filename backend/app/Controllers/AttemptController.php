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
            // Check if user can access this test
            if (!$this->userModel->canAccessTest($user['user_id'], $data->test_id)) {
                $this->error('Access denied. Premium subscription required or free test limit reached.', 403);
            }
            
            // Check if test exists
            $test = $this->testModel->find($data->test_id);
            if (!$test) {
                $this->error('Test not found', 404);
            }
            
            $attemptId = $this->attemptModel->startAttempt($user['user_id'], $data->test_id);
            
            if ($attemptId) {
                // Increment free test usage if it's a free test
                if ($test['is_free']) {
                    $this->userModel->incrementFreeTestUsage($user['user_id']);
                }
                
                $this->success([
                    'attempt_id' => $attemptId,
                    'test' => $test,
                    'started_at' => date('Y-m-d H:i:s')
                ], 'Test attempt started', 201);
            } else {
                $this->error('Failed to start test attempt', 500);
            }
            
        } catch (Exception $e) {
            logError('Start attempt error: ' . $e->getMessage(), [
                'user_id' => $user['user_id'], 
                'test_id' => $data->test_id
            ]);
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
            logError('Submit attempt error: ' . $e->getMessage(), [
                'user_id' => $user['user_id'], 
                'attempt_id' => $data->attempt_id ?? 'unknown'
            ]);
            $this->error($e->getMessage(), 500);
        }
    }
    
    public function getHistory() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        $pagination = $this->getPaginationParams();
        
        try {
            $history = $this->attemptModel->getUserHistory(
                $user['user_id'], 
                $pagination['limit'], 
                $pagination['offset']
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
            
            $this->success($response);
            
        } catch (Exception $e) {
            logError('Get history error: ' . $e->getMessage(), ['user_id' => $user['user_id']]);
            $this->error('Failed to retrieve test history', 500);
        }
    }
    
    public function getAttemptDetails($attemptId) {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            $attempt = $this->attemptModel->getAttemptDetails($attemptId, $user['user_id']);
            
            if (!$attempt) {
                $this->error('Test attempt not found', 404);
            }
            
            $this->success($attempt);
            
        } catch (Exception $e) {
            logError('Get attempt details error: ' . $e->getMessage(), [
                'user_id' => $user['user_id'], 
                'attempt_id' => $attemptId
            ]);
            $this->error('Failed to retrieve attempt details', 500);
        }
    }
    
    public function getLeaderboard() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::optionalAuth();
        
        $testId = $_GET['test_id'] ?? null;
        $limit = min(50, max(5, intval($_GET['limit'] ?? 10)));
        
        try {
            $leaderboard = $this->attemptModel->getLeaderboard($testId, $limit);
            $this->success($leaderboard);
            
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
            logError('Retake test error: ' . $e->getMessage(), [
                'user_id' => $user['user_id'], 
                'test_id' => $data->test_id
            ]);
            $this->error('Failed to start test retake', 500);
        }
    }
}