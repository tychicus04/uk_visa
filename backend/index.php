<?php
/**
 * UK Visa Test API Router - Enhanced Multi-Language Support v2.0
 * Professional routing system with dynamic language support
 * ✅ UPDATED: Added comprehensive multi-language support
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
 * ROUTES - UK VISA TEST API ENDPOINTS WITH MULTI-LANGUAGE SUPPORT
 * =============================================================================
 */

$routes = [
    
    // ==========================================================================
    // SYSTEM & TEST ROUTES
    // ==========================================================================
    'GET /' => function() {
        jsonResponse([
            'name' => 'UK Visa Test API',
            'version' => '2.0.0',
            'status' => 'active',
            'timestamp' => time(),
            'server_time' => date('Y-m-d H:i:s'),
            'endpoints' => [
                'auth' => '/auth/{register|login|profile|refresh|logout|language}',
                'tests' => '/tests/{available|{id}|free|search}',
                'attempts' => '/attempts/{start|submit|history|{id}}',
                'chapters' => '/chapters',
                'subscriptions' => '/subscriptions/{plans|subscribe|status}',
                'questions' => '/questions/{id}',
                'languages' => '/languages/{supported|stats}',
                'stats' => '/stats/translations'
            ],
            'multi_language_support' => true,
            'supported_languages' => ['en', 'vi', 'pl', 'pa', 'ur', 'ro', 'es', 'pt', 'ar'],
            'language_parameters' => [
                'include_language' => 'Specify language code (vi, es, fr, etc.)',
                'include_vietnamese' => 'Legacy parameter - use include_language=vi instead'
            ],
            'examples' => [
                'vietnamese_test' => '/tests/1?include_language=vi',
                'spanish_test' => '/tests/1?include_language=es',
                'legacy_vietnamese' => '/tests/1?include_vietnamese=true',
                'supported_languages' => '/languages/supported'
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
            'api_version' => '2.0.0',
            'database' => $dbStatus,
            'database_info' => $dbInfo,
            'server_time' => date('Y-m-d H:i:s'),
            'timestamp' => time(),
            'php_version' => PHP_VERSION,
            'environment' => $_ENV['APP_ENV'] ?? 'unknown',
            'multi_language_support' => true,
            'supported_languages' => 9 // 8 + English
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
    
    // ✅ ENHANCED: Language preference endpoints
    'POST /auth/language' => 'TestController@updateLanguagePreference',
    'PUT /auth/language' => 'TestController@updateLanguagePreference',
    
    // ==========================================================================
    // TEST ROUTES (ENHANCED with dynamic multi-language support)
    // ==========================================================================
    'GET /tests/available' => 'TestController@getAvailableTests',
    'GET /tests/free' => 'TestController@getFreeTests',
    'GET /tests/type/([a-zA-Z]+)' => 'TestController@getTestsByType',
    'GET /tests/chapter/(\d+)' => 'TestController@getTestsByChapter',
    'GET /tests/(\d+)' => 'TestController@getTest',
    
    // ✅ ENHANCED: Single question endpoint with multi-language
    'GET /questions/(\d+)' => 'TestController@getQuestion',
    
    // ✅ NEW: Language management endpoints
    'GET /languages/supported' => 'TestController@getSupportedLanguages',
    'GET /languages/stats' => 'TestController@getTranslationStats',
    
    // ✅ ENHANCED: Translation statistics (now supports all languages)
    'GET /stats/translations' => 'TestController@getTranslationStats',
    
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
    'POST /subscriptions/cancel' => 'SubscriptionController@cancel',
    
    // ✅ NEW: Language testing and demonstration endpoints
    'GET /demo/multilang' => function() {
        if (!($_ENV['APP_DEBUG'] ?? false)) {
            jsonResponse(['error' => 'Demo endpoints only available in debug mode'], 403);
            return;
        }
        
        $supportedLanguages = [
            'vi' => 'Vietnamese',
            'pl' => 'Polish', 
            'pa' => 'Punjabi',
            'ur' => 'Urdu',
            'ro' => 'Romanian',
            'es' => 'Spanish',
            'pt' => 'Portuguese',
            'ar' => 'Arabic'
        ];
        
        $examples = [];
        foreach ($supportedLanguages as $code => $name) {
            $examples[] = [
                'language_code' => $code,
                'language_name' => $name,
                'test_endpoint' => "/tests/1?include_language={$code}",
                'question_endpoint' => "/questions/1?include_language={$code}",
                'available_tests' => "/tests/available?include_language={$code}"
            ];
        }
        
        jsonResponse([
            'demo' => 'Multi-Language API Endpoints',
            'description' => 'These endpoints demonstrate how to request content in different languages',
            'parameter_info' => [
                'include_language' => 'Use this parameter to get translated content',
                'supported_values' => array_keys($supportedLanguages),
                'default_behavior' => 'Without parameter, returns English content only',
                'backward_compatibility' => 'include_vietnamese=true still works (maps to include_language=vi)'
            ],
            'examples' => $examples,
            'note' => 'Language availability depends on translation coverage in database'
        ]);
    },
    
    // ✅ NEW: Language parameter validation endpoint
    'GET /validate/language/([a-zA-Z]{2})' => function($languageCode) {
        if (!($_ENV['APP_DEBUG'] ?? false)) {
            jsonResponse(['error' => 'Validation endpoints only available in debug mode'], 403);
            return;
        }
        
        $supportedLanguages = [
            'en' => 'English (Default)',
            'vi' => 'Vietnamese',
            'pl' => 'Polish', 
            'pa' => 'Punjabi',
            'ur' => 'Urdu',
            'ro' => 'Romanian',
            'es' => 'Spanish',
            'pt' => 'Portuguese',
            'ar' => 'Arabic'
        ];
        
        $isSupported = array_key_exists($languageCode, $supportedLanguages);
        $isDefault = $languageCode === 'en';
        
        jsonResponse([
            'language_code' => $languageCode,
            'is_supported' => $isSupported,
            'is_default' => $isDefault,
            'language_name' => $supportedLanguages[$languageCode] ?? 'Unknown',
            'requires_translation_columns' => $isSupported && !$isDefault,
            'example_usage' => $isSupported ? "/tests/1?include_language={$languageCode}" : null,
            'message' => $isSupported ? 
                ($isDefault ? 'Default language - no additional columns needed' : 'Supported language with translation columns') : 
                'Unsupported language code',
            'all_supported' => $supportedLanguages
        ]);
    },
    
    // ✅ NEW: Debug endpoint for routes (development only)
    'GET /debug/routes' => function() {
        if (!($_ENV['APP_DEBUG'] ?? false)) {
            jsonResponse(['error' => 'Debug mode disabled'], 403);
            return;
        }
        
        global $routes;
        $routeList = [];
        foreach ($routes as $pattern => $handler) {
            $routeList[] = [
                'pattern' => $pattern,
                'handler' => is_callable($handler) ? 'function' : $handler,
                'supports_multi_language' => strpos($pattern, 'tests') !== false || 
                                           strpos($pattern, 'language') !== false ||
                                           strpos($pattern, 'questions') !== false ||
                                           strpos($pattern, 'stats') !== false ||
                                           strpos($pattern, 'demo') !== false,
                'new_in_v2' => strpos($pattern, 'languages') !== false ||
                              strpos($pattern, 'demo') !== false ||
                              strpos($pattern, 'validate') !== false
            ];
        }
        
        $multiLangRoutes = array_filter($routeList, function($r) { return $r['supports_multi_language']; });
        $newRoutes = array_filter($routeList, function($r) { return $r['new_in_v2']; });
        
        jsonResponse([
            'total_routes' => count($routeList),
            'multi_language_routes' => count($multiLangRoutes),
            'new_routes_v2' => count($newRoutes),
            'supported_languages' => 9,
            'backward_compatible' => true,
            'routes_by_category' => [
                'multi_language_supported' => array_values($multiLangRoutes),
                'new_in_v2' => array_values($newRoutes),
                'all_routes' => $routeList
            ],
            'usage_examples' => [
                'vietnamese_test' => 'GET /tests/1?include_language=vi',
                'spanish_question' => 'GET /questions/1?include_language=es',
                'legacy_vietnamese' => 'GET /tests/1?include_vietnamese=true',
                'language_stats' => 'GET /languages/stats',
                'supported_langs' => 'GET /languages/supported'
            ]
        ]);
    },
];

/**
 * =============================================================================
 * ROUTE PROCESSING WITH ENHANCED ERROR HANDLING
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
        $regex = '#^' . str_replace(['(\d+)', '([a-zA-Z]+)', '([a-zA-Z]{2})'], ['(\d+)', '([a-zA-Z]+)', '([a-zA-Z]{2})'], $routePath) . '$#';
        
        if (preg_match($regex, $uri, $matches)) {
            array_shift($matches); // Remove full match
            
            if (is_callable($handler)) {
                // Direct function call
                call_user_func_array($handler, $matches);
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
                        'multi_language_note' => strpos($routePath, 'language') !== false ? 
                            'This endpoint supports multi-language functionality' : null,
                        'v2_features' => [
                            'dynamic_language_support' => true,
                            'backward_compatibility' => true,
                            'supported_languages' => 9
                        ],
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
                        'available_methods' => get_class_methods($instance),
                        'multi_language_note' => strpos($method, 'Language') !== false ? 
                            'This method handles multi-language functionality' : null,
                        'v2_enhancement' => strpos($method, 'Supported') !== false ||
                                          strpos($method, 'Multi') !== false
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
        // Enhanced 404 with multi-language suggestions
        $suggestions = [];
        $multiLangSuggestions = [];
        
        foreach ($routes as $pattern => $handler) {
            list($routeMethod, $routePath) = explode(' ', $pattern, 2);
            if ($routeMethod === $requestMethod) {
                $suggestions[] = $routePath;
                
                // Highlight multi-language endpoints
                if (strpos($routePath, 'language') !== false || 
                    strpos($routePath, 'stats') !== false ||
                    strpos($routePath, 'questions') !== false ||
                    strpos($routePath, 'tests') !== false) {
                    $multiLangSuggestions[] = $routePath . ' (Multi-language support)';
                }
            }
        }
        
        jsonResponse([
            'error' => 'Endpoint not found',
            'method' => $requestMethod,
            'uri' => $uri,
            'message' => 'The requested endpoint does not exist',
            'api_version' => '2.0.0',
            'multi_language_support' => true,
            'debug_info' => [
                'original_uri' => $requestUri,
                'processed_uri' => $uri,
                'method' => $requestMethod,
                'base_path' => '/UK_Visa/Backend/'
            ],
            'suggestions' => array_slice($suggestions, 0, 5),
            'multi_language_endpoints' => $multiLangSuggestions,
            'language_examples' => [
                'vietnamese_test' => '/tests/1?include_language=vi',
                'spanish_test' => '/tests/1?include_language=es',
                'legacy_vietnamese' => '/tests/1?include_vietnamese=true',
                'supported_languages' => '/languages/supported'
            ],
            'help' => 'Visit / for API information, /test for testing, or /demo/multilang for language examples'
        ], 404);
    }
    
} catch (Exception $e) {
    // Enhanced error logging with multi-language context
    $errorDetails = [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'uri' => $uri,
        'method' => $requestMethod,
        'language_param' => $_GET['include_language'] ?? $_GET['include_vietnamese'] ?? null
    ];
    
    $response = [
        'error' => 'Internal server error',
        'message' => 'An error occurred while processing your request',
        'timestamp' => time(),
        'api_version' => '2.0.0'
    ];
    
    if ($_ENV['APP_DEBUG'] ?? false) {
        $response['debug'] = [
            'error' => $e->getMessage(),
            'file' => basename($e->getFile()),
            'line' => $e->getLine(),
            'trace' => explode("\n", $e->getTraceAsString()),
            'context' => $errorDetails
        ];
    }
    
    jsonResponse($response, 500);
}

ob_end_flush();
?>