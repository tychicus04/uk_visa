<?php
class JWTConfig {
    public static function getSecret() {
        return $_ENV['JWT_SECRET'] ?? 'default_secret_change_this';
    }
    
    public static function getExpiration() {
        return $_ENV['JWT_EXPIRE'] ?? 86400; // 24 hours
    }
    
    public static function getAlgorithm() {
        return 'HS256';
    }
}