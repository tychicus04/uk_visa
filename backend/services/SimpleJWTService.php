<?php
require_once __DIR__ . '/../config/jwt.php';

class SimpleJWTService {
    
    public static function encode($payload) {
        $header = json_encode(['typ' => 'JWT', 'alg' => JWTConfig::getAlgorithm()]);
        
        $payload['iat'] = time();
        $payload['exp'] = time() + JWTConfig::getExpiration();
        $payload = json_encode($payload);
        
        $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
        
        $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, JWTConfig::getSecret(), true);
        $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
        
        return $base64Header . "." . $base64Payload . "." . $base64Signature;
    }
    
    public static function decode($jwt) {
        if (empty($jwt)) {
            throw new Exception('Token is required');
        }
        
        $tokenParts = explode('.', $jwt);
        if (count($tokenParts) !== 3) {
            throw new Exception('Invalid token format');
        }
        
        $header = base64_decode(str_replace(['-', '_'], ['+', '/'], $tokenParts[0]));
        $payload = base64_decode(str_replace(['-', '_'], ['+', '/'], $tokenParts[1]));
        $signatureProvided = $tokenParts[2];
        
        // Verify signature
        $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
        $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, JWTConfig::getSecret(), true);
        $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
        
        if (!hash_equals($base64Signature, $signatureProvided)) {
            throw new Exception('Invalid token signature');
        }
        
        $decodedPayload = json_decode($payload, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception('Invalid token payload');
        }
        
        // Check expiration
        if (isset($decodedPayload['exp']) && $decodedPayload['exp'] < time()) {
            throw new Exception('Token has expired');
        }
        
        return $decodedPayload;
    }
    
    public static function generateForUser($user) {
        // Validate required user fields
        $requiredFields = ['id', 'email'];
        foreach ($requiredFields as $field) {
            if (!isset($user[$field]) || empty($user[$field])) {
                throw new Exception("User data is missing required field: $field");
            }
        }
        
        $payload = [
            'user_id' => $user['id'],
            'email' => $user['email'],
            'is_premium' => isset($user['is_premium']) ? (bool)$user['is_premium'] : false,
            'language_code' => $user['language_code'] ?? 'en'
        ];
        
        return self::encode($payload);
    }
    
    public static function refreshToken($token) {
        try {
            // Decode the existing token
            $payload = self::decode($token);
            
            // Validate that we have the minimum required data
            if (!isset($payload['user_id']) || !isset($payload['email'])) {
                throw new Exception('Token payload is missing required user data');
            }
            
            // Remove timing claims to generate fresh ones
            unset($payload['iat'], $payload['exp']);
            
            // Generate new token with same payload
            return self::encode($payload);
            
        } catch (Exception $e) {
            throw new Exception('Cannot refresh token: ' . $e->getMessage());
        }
    }
    
    public static function validateToken($token) {
        try {
            $payload = self::decode($token);
            return [
                'valid' => true,
                'payload' => $payload
            ];
        } catch (Exception $e) {
            return [
                'valid' => false,
                'error' => $e->getMessage()
            ];
        }
    }
    
    public static function getUserFromToken($token) {
        try {
            $payload = self::decode($token);
            
            return [
                'id' => $payload['user_id'] ?? null,
                'email' => $payload['email'] ?? null,
                'is_premium' => $payload['is_premium'] ?? false,
                'language_code' => $payload['language_code'] ?? 'en'
            ];
        } catch (Exception $e) {
            throw new Exception('Cannot extract user from token: ' . $e->getMessage());
        }
    }
    
    public static function isTokenExpired($token) {
        try {
            $payload = self::decode($token);
            return false; // If decode succeeds, token is not expired
        } catch (Exception $e) {
            if (strpos($e->getMessage(), 'expired') !== false) {
                return true;
            }
            throw $e; // Re-throw other exceptions
        }
    }
}
?>