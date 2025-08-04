<?php
require_once __DIR__ . '/../../includes/functions.php';

abstract class BaseController {
    
    protected function getRequestData() {
        $input = file_get_contents('php://input');
        return json_decode($input);
    }
    
    protected function validateMethod($allowedMethods) {
        $method = $_SERVER['REQUEST_METHOD'];
        if (!in_array($method, $allowedMethods)) {
            jsonResponse(['error' => 'Method not allowed'], 405);
        }
        return $method;
    }
    
    protected function getPaginationParams() {
        $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
        $limit = isset($_GET['limit']) ? min(100, max(1, intval($_GET['limit']))) : 20;
        $offset = ($page - 1) * $limit;
        
        return compact('page', 'limit', 'offset');
    }
    
    protected function success($data = [], $message = 'Success', $status = 200) {
        jsonResponse([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $status);
    }
    
    protected function error($message = 'An error occurred', $status = 400, $errors = []) {
        jsonResponse([
            'success' => false,
            'message' => $message,
            'errors' => $errors
        ], $status);
    }
    
    protected function paginate($data, $total, $page, $limit) {
        return [
            'items' => $data,
            'pagination' => [
                'current_page' => $page,
                'per_page' => $limit,
                'total' => $total,
                'total_pages' => ceil($total / $limit),
                'has_next' => $page * $limit < $total,
                'has_prev' => $page > 1
            ]
        ];
    }
}
