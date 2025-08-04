<?php
class CacheMiddleware {
    private static $cacheDir = __DIR__ . '/../logs/cache/';
    
    public static function init() {
        if (!is_dir(self::$cacheDir)) {
            mkdir(self::$cacheDir, 0755, true);
        }
    }
    
    public static function get($key, $ttl = 3600) {
        self::init();
        $file = self::$cacheDir . md5($key) . '.cache';
        
        if (!file_exists($file)) {
            return null;
        }
        
        $data = json_decode(file_get_contents($file), true);
        
        if ($data['expires'] < time()) {
            unlink($file);
            return null;
        }
        
        return $data['content'];
    }
    
    public static function set($key, $content, $ttl = 3600) {
        self::init();
        $file = self::$cacheDir . md5($key) . '.cache';
        
        $data = [
            'content' => $content,
            'expires' => time() + $ttl
        ];
        
        file_put_contents($file, json_encode($data));
    }
    
    public static function delete($key) {
        self::init();
        $file = self::$cacheDir . md5($key) . '.cache';
        
        if (file_exists($file)) {
            unlink($file);
        }
    }
    
    public static function clear() {
        self::init();
        $files = glob(self::$cacheDir . '*.cache');
        foreach ($files as $file) {
            unlink($file);
        }
    }
}