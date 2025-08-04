<?php
class ValidationMiddleware {
    
    public static function validateRegistration($data) {
        $errors = [];
        
        // Required fields
        $required = ['email', 'password', 'full_name'];
        $missing = validateRequired($data, $required);
        if (!empty($missing)) {
            $errors['required'] = 'Missing required fields: ' . implode(', ', $missing);
        }
        
        // Email validation
        if (isset($data->email) && !validateEmail($data->email)) {
            $errors['email'] = 'Invalid email format';
        }
        
        // Password strength
        if (isset($data->password)) {
            if (strlen($data->password) < 6) {
                $errors['password'] = 'Password must be at least 6 characters';
            }
        }
        
        // Name validation
        if (isset($data->full_name) && strlen(trim($data->full_name)) < 2) {
            $errors['full_name'] = 'Full name must be at least 2 characters';
        }
        
        if (!empty($errors)) {
            jsonResponse(['errors' => $errors], 400);
        }
        
        return true;
    }
    
    public static function validateLogin($data) {
        $required = ['email', 'password'];
        $missing = validateRequired($data, $required);
        
        if (!empty($missing)) {
            jsonResponse(['error' => 'Email and password are required'], 400);
        }
        
        if (!validateEmail($data->email)) {
            jsonResponse(['error' => 'Invalid email format'], 400);
        }
        
        return true;
    }
    
    public static function validateTestSubmission($data) {
        $required = ['attempt_id', 'answers'];
        $missing = validateRequired($data, $required);
        
        if (!empty($missing)) {
            jsonResponse(['error' => 'Missing required fields: ' . implode(', ', $missing)], 400);
        }
        
        if (!is_array($data->answers) || empty($data->answers)) {
            jsonResponse(['error' => 'Answers must be a non-empty array'], 400);
        }
        
        foreach ($data->answers as $answer) {
            if (!isset($answer->question_id) || !isset($answer->selected_answer_ids)) {
                jsonResponse(['error' => 'Each answer must have question_id and selected_answer_ids'], 400);
            }
        }
        
        return true;
    }
}