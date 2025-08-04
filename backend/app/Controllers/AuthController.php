<?php
require_once __DIR__ . '/../Core/BaseController.php';
require_once __DIR__ . '/../Models/User.php';
require_once __DIR__ . '/../../services/SimpleJWTService.php';
require_once __DIR__ . '/../../middleware/ValidationMiddleware.php';

class AuthController extends BaseController {
    private $userModel;
    
    public function __construct() {
        $this->userModel = new User();
    }
    
    public function register() {
        $this->validateMethod(['POST']);
        $data = $this->getRequestData();
        
        try {
            ValidationMiddleware::validateRegistration($data);
            
            $userData = [
                'email' => sanitizeInput($data->email),
                'password' => $data->password,
                'full_name' => sanitizeInput($data->full_name),
                'language_code' => isset($data->language_code) ? sanitizeInput($data->language_code) : 'en'
            ];
            
            $user = $this->userModel->register($userData);
            
            if ($user) {
                $token = SimpleJWTService::generateForUser($user);
                
                $this->success([
                    'user' => $user,
                    'token' => $token,
                    'token_type' => 'Bearer'
                ], 'Registration successful', 201);
            } else {
                $this->error('Registration failed', 500);
            }
            
        } catch (Exception $e) {
            logError('Registration error: ' . $e->getMessage(), ['email' => $data->email ?? 'unknown']);
            $this->error($e->getMessage(), 400);
        }
    }
    
    public function login() {
        $this->validateMethod(['POST']);
        $data = $this->getRequestData();
        
        try {
            ValidationMiddleware::validateLogin($data);
            
            $user = $this->userModel->login($data->email, $data->password);
            
            if ($user) {
                $token = SimpleJWTService::generateForUser($user);
                
                $this->success([
                    'user' => $user,
                    'token' => $token,
                    'token_type' => 'Bearer',
                    'expires_in' => JWTConfig::getExpiration()
                ], 'Login successful');
            } else {
                $this->error('Invalid credentials', 401);
            }
            
        } catch (Exception $e) {
            logError('Login error: ' . $e->getMessage(), ['email' => $data->email ?? 'unknown']);
            $this->error('Login failed', 500);
        }
    }
    
    public function refresh() {
        $this->validateMethod(['POST']);
        
        try {
            $currentUser = SimpleAuthMiddleware::authenticate();
            $token = getBearerToken();
            $currentUser = SimpleJWTService::getUserFromToken($token);
            $newToken = SimpleJWTService::generateForUser($currentUser);
            
            $this->success([
                'token' => $newToken,
                'token_type' => 'Bearer',
                'expires_in' => JWTConfig::getExpiration()
            ], 'Token refreshed');
            
        } catch (Exception $e) {
            $this->error('Token refresh failed', 401);
        }
    }
    
    public function profile() {
        $method = $this->validateMethod(['GET', 'PUT']);
        $user = SimpleAuthMiddleware::authenticate();
        
        if ($method === 'GET') {
            $userStats = $this->userModel->getUserStats($user['user_id']);
            $userProfile = $this->userModel->find($user['user_id']);
            
            $this->success([
                'profile' => $userProfile,
                'stats' => $userStats
            ]);
        }
        
        if ($method === 'PUT') {
            $data = $this->getRequestData();
            
            try {
                $updateData = [];
                if (isset($data->full_name)) {
                    $updateData['full_name'] = sanitizeInput($data->full_name);
                }
                if (isset($data->language_code)) {
                    $updateData['language_code'] = sanitizeInput($data->language_code);
                }
                
                if ($this->userModel->updateProfile($user['user_id'], $updateData)) {
                    $updatedUser = $this->userModel->find($user['user_id']);
                    $this->success($updatedUser, 'Profile updated successfully');
                } else {
                    $this->error('Failed to update profile', 500);
                }
                
            } catch (Exception $e) {
                $this->error($e->getMessage(), 400);
            }
        }
    }
    
    public function changePassword() {
        $this->validateMethod(['POST']);
        $user = SimpleAuthMiddleware::authenticate();
        $data = $this->getRequestData();
        
        $required = ['current_password', 'new_password'];
        $missing = validateRequired($data, $required);
        
        if (!empty($missing)) {
            $this->error('Missing required fields: ' . implode(', ', $missing), 400);
        }
        
        if (strlen($data->new_password) < 6) {
            $this->error('New password must be at least 6 characters', 400);
        }
        
        try {
            $this->userModel->changePassword(
                $user['user_id'], 
                $data->current_password, 
                $data->new_password
            );
            
            $this->success([], 'Password changed successfully');
            
        } catch (Exception $e) {
            $this->error($e->getMessage(), 400);
        }
    }
    
    public function logout() {
        $this->validateMethod(['POST']);
        // For stateless JWT, logout is handled client-side
        // In production, you might want to implement token blacklisting
        $this->success([], 'Logged out successfully');
    }
}