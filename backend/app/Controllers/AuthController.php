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
            // Validation - chỉ cần email và password
            $required = ['email', 'password'];
            $missing = validateRequired($data, $required);
            
            if (!empty($missing)) {
                $this->error('Missing required fields: ' . implode(', ', $missing), 400);
            }
            
            // Validate email format
            if (!filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
                $this->error('Invalid email format', 400);
            }
            
            // Validate password strength
            if (strlen($data->password) < 6) {
                $this->error('Password must be at least 6 characters', 400);
            }
            
            $userData = [
                'email' => sanitizeInput($data->email),
                'password' => $data->password,
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
            $this->error($e->getMessage(), 400);
        }
    }
    
    public function login() {
        $this->validateMethod(['POST']);
        $data = $this->getRequestData();
        
        try {
            // Validation
            $required = ['email', 'password'];
            $missing = validateRequired($data, $required);
            
            if (!empty($missing)) {
                $this->error('Missing required fields: ' . implode(', ', $missing), 400);
            }
            
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
            $this->error('Login failed', 500);
        }
    }
    
    public function profile() {
        $method = $this->validateMethod(['GET', 'PUT']);
        $user = SimpleAuthMiddleware::authenticate();
        
        if ($method === 'GET') {
            $userStats = $this->userModel->getUserStats($user['id']);
            $userProfile = $this->userModel->find($user['id']);
            
            $this->success([
                'profile' => $userProfile,
                'stats' => $userStats
            ]);
        }
        
        if ($method === 'PUT') {
            $data = $this->getRequestData();
            
            try {
                $updateData = [];
                if (isset($data->language_code)) {
                    $updateData['language_code'] = sanitizeInput($data->language_code);
                }
                
                if (!empty($updateData)) {
                    if ($this->userModel->updateProfile($user['id'], $updateData)) {
                        $updatedUser = $this->userModel->find($user['id']);
                        $this->success($updatedUser, 'Profile updated successfully');
                    } else {
                        $this->error('Failed to update profile', 500);
                    }
                } else {
                    $this->error('No valid fields to update', 400);
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
                $user['id'], 
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
        $this->success([], 'Logged out successfully');
    }
}