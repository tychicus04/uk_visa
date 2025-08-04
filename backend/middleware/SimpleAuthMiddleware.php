<?php
require_once __DIR__ . '/../services/SimpleJWTService.php';
require_once __DIR__ . '/../includes/functions.php';

class SimpleAuthMiddleware {
    
    public static function authenticate() {
        $token = getBearerToken();
        
        if (!$token) {
            jsonResponse(['error' => 'Token required'], 401);
        }
        
        try {
            $payload = SimpleJWTService::decode($token);
            return $payload;
        } catch (Exception $e) {
            jsonResponse(['error' => 'Invalid token: ' . $e->getMessage()], 401);
        }
    }
    
    public static function requirePremium() {
        $user = self::authenticate();
        
        if (!$user['is_premium']) {
            jsonResponse(['error' => 'Premium subscription required'], 403);
        }
        
        return $user;
    }
    
    public static function optionalAuth() {
        $token = getBearerToken();
        
        if (!$token) {
            return null;
        }
        
        try {
            return SimpleJWTService::decode($token);
        } catch (Exception $e) {
            return null;
        }
    }
    
    public static function rateLimiting($maxRequests = 100, $timeWindow = 3600) {
        $ip = $_SERVER['REMOTE_ADDR'];
        $key = "rate_limit_" . md5($ip);
        $cacheFile = __DIR__ . "/../logs/rate_limit_$key.json";
        
        $data = [];
        if (file_exists($cacheFile)) {
            $data = json_decode(file_get_contents($cacheFile), true);
        }
        
        $now = time();
        $windowStart = $now - $timeWindow;
        
        // Clean old requests
        $data = array_filter($data, function($timestamp) use ($windowStart) {
            return $timestamp > $windowStart;
        });
        
        if (count($data) >= $maxRequests) {
            jsonResponse(['error' => 'Rate limit exceeded'], 429);
        }
        
        $data[] = $now;
        file_put_contents($cacheFile, json_encode($data));
    }
}