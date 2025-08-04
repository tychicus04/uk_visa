<?php
/**
 * UK Visa Test API Router - Clean Version v1.0
 * Professional routing system with auto-loading
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);
ob_start();

// Include core files
require_once 'includes/functions.php';
require_once 'config/database.php';

// Load environment variables
loadEnv(__DIR__ . '/.env');

// Check if core files exist
if (!file_exists('app/Core/BaseController.php')) {
    jsonResponse(['error' => 'Core BaseController class not found'], 500);
    exit;
}

if (!file_exists('app/Core/BaseModel.php')) {
    jsonResponse(['error' => 'Core BaseModel class not found'], 500);
    exit;
}

require_once 'app/Core/BaseController.php';
require_once 'app/Core/BaseModel.php';

// Auto-loader for classes
function autoload($className) {
    $paths = [
        'app/Controllers/' . $className . '.php',
        'app/Models/' . $className . '.php',
        'services/' . $className . '.php',
        'middleware/' . $className . '.php'
    ];
    
    foreach ($paths as $path) {
        if (file_exists($path)) {
            require_once $path;
            return;
        }
    }
}
spl_autoload_register('autoload');

// Set CORS headers
corsHeaders();

// Error handling
set_error_handler(function($severity, $message, $file, $line) {
    if (error_reporting() & $severity) {
        logError("PHP Error: $message in $file:$line");
        if ($_ENV['APP_DEBUG'] ?? false) {
            jsonResponse(['error' => 'Internal server error', 'debug' => $message], 500);
        } else {
            jsonResponse(['error' => 'Internal server error'], 500);
        }
    }
});

// Get request info
$requestMethod = $_SERVER['REQUEST_METHOD'];
$requestUri = $_SERVER['REQUEST_URI'];

// Parse URI with better handling
$uri = parse_url($requestUri, PHP_URL_PATH);

// Remove script name if accessing via index.php
if (strpos($uri, '/index.php') !== false) {
    $uri = str_replace('/index.php', '', $uri);
}

// Handle the exact path pattern: /UKVisa/backend/ (case insensitive)
$possibleBasePaths = [
    '/UKVisa/backend/',
    '/UKVisa/Backend/',
    '/UK_Visa/Backend/',
    '/UK_Visa/backend/',
    '/UKVisa/backend',
    '/UKVisa/Backend',
    '/UK_Visa/Backend',
    '/UK_Visa/backend',
    '/Backend/',
    '/backend/',
    '/Backend',
    '/backend'
];

$originalUri = $uri;
foreach ($possibleBasePaths as $basePath) {
    if (stripos($uri, $basePath) === 0) { // case insensitive comparison
        $uri = substr($uri, strlen($basePath));
        break;
    }
}

// Ensure leading slash for route matching
$uri = '/' . trim($uri, '/');
if ($uri === '/') {
    // Keep as root
} else {
    // Remove double slashes if any
    $uri = preg_replace('#/+#', '/', $uri);
}

// Debug logging
if ($_ENV['APP_DEBUG'] ?? false) {
    error_log("UK_Visa_API_Debug - Method: $requestMethod, URI: $uri");
}

/**
 * =============================================================================
 * ROUTES - UK VISA TEST API ENDPOINTS
 * =============================================================================
 */

$routes = [
    
    // ==========================================================================
    // SYSTEM & TEST ROUTES
    // ==========================================================================
    'GET /' => function() {
        jsonResponse([
            'name' => 'UK Visa Test API',
            'version' => '1.0.0',
            'status' => 'active',
            'timestamp' => time(),
            'server_time' => date('Y-m-d H:i:s'),
            'endpoints' => [
                'auth' => '/auth/{register|login|profile|refresh|logout}',
                'tests' => '/tests/{available|{id}|free|search}',
                'attempts' => '/attempts/{start|submit|history|{id}}',
                'chapters' => '/chapters',
                'subscriptions' => '/subscriptions/{plans|subscribe|status}'
            ],
            'documentation' => 'Add ?debug=1 for debug info',
            'test_endpoint' => '/test'
        ]);
    },
    
    'GET /health' => function() {
        try {
            $database = new Database();
            $db = $database->getConnection();
            
            $dbStatus = 'connected';
            $dbInfo = 'Connection successful';
            
            if ($db) {
                try {
                    $stmt = $db->query("SELECT COUNT(*) as count FROM users LIMIT 1");
                    $result = $stmt->fetch();
                    $dbInfo = "Database accessible - Users: " . ($result['count'] ?? 0);
                } catch (Exception $e) {
                    $dbInfo = "Connected but table error: " . $e->getMessage();
                }
            }
            
        } catch (Exception $e) {
            $dbStatus = 'error';
            $dbInfo = $e->getMessage();
        }
        
        jsonResponse([
            'status' => 'healthy',
            'api_version' => '1.0.0',
            'database' => $dbStatus,
            'database_info' => $dbInfo,
            'server_time' => date('Y-m-d H:i:s'),
            'timestamp' => time(),
            'php_version' => PHP_VERSION,
            'environment' => $_ENV['APP_ENV'] ?? 'unknown'
        ]);
    },

    // ==========================================================================
    // AUTHENTICATION ROUTES
    // ==========================================================================
    'POST /auth/register' => 'AuthController@register',
    'POST /auth/login' => 'AuthController@login',
    'GET /auth/profile' => 'AuthController@profile',
    'PUT /auth/profile' => 'AuthController@profile',
    'POST /auth/refresh' => 'AuthController@refresh',
    'POST /auth/change-password' => 'AuthController@changePassword',
    'POST /auth/logout' => 'AuthController@logout',
    
    // ==========================================================================
    // TEST ROUTES
    // ==========================================================================
    'GET /tests/available' => 'TestController@getAvailableTests',
    'GET /tests/free' => 'TestController@getFreeTests',
    'GET /tests/search' => 'TestController@searchTests',
    'GET /tests/type/([a-zA-Z]+)' => 'TestController@getTestsByType',
    'GET /tests/chapter/(\d+)' => 'TestController@getTestsByChapter',
    'GET /tests/(\d+)' => 'TestController@getTest',
    
    // ==========================================================================
    // TEST ATTEMPT ROUTES
    // ==========================================================================
    'POST /attempts/start' => 'AttemptController@startAttempt',
    'POST /attempts/submit' => 'AttemptController@submitAttempt',
    'GET /attempts/history' => 'AttemptController@getHistory',
    'POST /attempts/retake' => 'AttemptController@retakeTest',
    'GET /attempts/leaderboard' => 'AttemptController@getLeaderboard',
    'GET /attempts/(\d+)' => 'AttemptController@getAttemptDetails',
    
    // ==========================================================================
    // CHAPTER ROUTES
    // ==========================================================================
    'GET /chapters' => 'ChapterController@getAllChapters',
    'GET /chapters/(\d+)' => 'ChapterController@getChapter',
    
    // ==========================================================================
    // SUBSCRIPTION ROUTES
    // ==========================================================================
    'GET /subscriptions/plans' => 'SubscriptionController@getPlans',
    'POST /subscriptions/subscribe' => 'SubscriptionController@subscribe',
    'GET /subscriptions/status' => 'SubscriptionController@getStatus',
    'POST /subscriptions/cancel' => 'SubscriptionController@cancel'
];

/**
 * =============================================================================
 * ROUTE PROCESSING
 * =============================================================================
 */

try {
    $matched = false;
    
    foreach ($routes as $pattern => $handler) {
        list($routeMethod, $routePath) = explode(' ', $pattern, 2);
        
        // Skip if HTTP method doesn't match
        if ($requestMethod !== $routeMethod) {
            continue;
        }
        
        // Convert route pattern to regex
        $regex = '#^' . str_replace(['(\d+)', '([a-zA-Z]+)'], ['(\d+)', '([a-zA-Z]+)'], $routePath) . '$#';
        
        if (preg_match($regex, $uri, $matches)) {
            array_shift($matches); // Remove full match
            
            if (is_callable($handler)) {
                // Direct function call
                call_user_func($handler);
                $matched = true;
                break;
            } else {
                // Controller method call
                list($controller, $method) = explode('@', $handler);
                
                // Check if controller file exists
                if (!class_exists($controller)) {
                    jsonResponse([
                        'error' => 'Controller not implemented',
                        'controller' => $controller,
                        'message' => "Controller $controller is not yet implemented or file missing",
                        'endpoint' => $routeMethod . ' ' . $routePath,
                        'suggestion' => "Create app/Controllers/$controller.php",
                        'debug_info' => [
                            'file_path' => "app/Controllers/$controller.php",
                            'exists' => file_exists("app/Controllers/$controller.php")
                        ]
                    ], 501);
                    $matched = true;
                    break;
                }
                
                $instance = new $controller();
                
                if (!method_exists($instance, $method)) {
                    jsonResponse([
                        'error' => 'Method not implemented',
                        'controller' => $controller,
                        'method' => $method,
                        'message' => "Method $method not found in $controller",
                        'available_methods' => get_class_methods($instance)
                    ], 501);
                    $matched = true;
                    break;
                }
                
                // Execute the method with parameters
                call_user_func_array([$instance, $method], $matches);
                $matched = true;
                break;
            }
        }
    }
    
    if (!$matched) {
        // Show helpful 404 with suggestions
        $suggestions = [];
        foreach ($routes as $pattern => $handler) {
            list($routeMethod, $routePath) = explode(' ', $pattern, 2);
            if ($routeMethod === $requestMethod) {
                $suggestions[] = $routePath;
            }
        }
        
        jsonResponse([
            'error' => 'Endpoint not found',
            'method' => $requestMethod,
            'uri' => $uri,
            'message' => 'The requested endpoint does not exist',
            'debug_info' => [
                'original_uri' => $requestUri,
                'processed_uri' => $uri,
                'method' => $requestMethod,
                'base_path' => '/UK_Visa/Backend/'
            ],
            'suggestions' => array_slice($suggestions, 0, 5),
            'help' => 'Visit / for API information or /test for testing'
        ], 404);
    }
    
} catch (Exception $e) {
    // Enhanced error logging
    $errorDetails = [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'uri' => $uri,
        'method' => $requestMethod
    ];
    
    logError("UK_Visa_API_Error: " . json_encode($errorDetails));
    
    $response = [
        'error' => 'Internal server error',
        'message' => 'An error occurred while processing your request',
        'timestamp' => time()
    ];
    
    if ($_ENV['APP_DEBUG'] ?? false) {
        $response['debug'] = [
            'error' => $e->getMessage(),
            'file' => basename($e->getFile()),
            'line' => $e->getLine(),
            'trace' => explode("\n", $e->getTraceAsString())
        ];
    }
    
    jsonResponse($response, 500);
}

ob_end_flush();
?>