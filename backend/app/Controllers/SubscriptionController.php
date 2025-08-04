<?php
require_once __DIR__ . '/../Core/BaseController.php';
require_once __DIR__ . '/../Models/Subscription.php';
require_once __DIR__ . '/../../middleware/SimpleAuthMiddleware.php';

class SubscriptionController extends BaseController {
    private $subscriptionModel;
    
    public function __construct() {
        $this->subscriptionModel = new Subscription();
    }
    
    public function getPlans() {
        $this->validateMethod(['GET']);
        
        $plans = [
            [
                'id' => 'monthly',
                'name' => 'Monthly Premium',
                'price' => 9.99,
                'currency' => 'USD',
                'duration' => 30,
                'features' => [
                    'Unlimited test attempts',
                    'All premium tests',
                    'Detailed explanations',
                    'Progress tracking',
                    'Priority support'
                ]
            ],
            [
                'id' => 'yearly',
                'name' => 'Yearly Premium',
                'price' => 79.99,
                'currency' => 'USD',
                'duration' => 365,
                'discount' => '33% OFF',
                'features' => [
                    'All monthly features',
                    'Save $40 per year',
                    'Bonus practice materials',
                    'Early access to new tests'
                ]
            ],
            [
                'id' => 'lifetime',
                'name' => 'Lifetime Access',
                'price' => 199.99,
                'currency' => 'USD',
                'duration' => null,
                'popular' => true,
                'features' => [
                    'All premium features',
                    'Lifetime updates',
                    'No recurring fees',
                    'Best value option'
                ]
            ]
        ];
        
        $this->success($plans);
    }
    
    public function subscribe() {
        $this->validateMethod(['POST']);
        $user = SimpleAuthMiddleware::authenticate();
        $data = $this->getRequestData();
        
        $required = ['plan_id', 'payment_method'];
        $missing = validateRequired($data, $required);
        
        if (!empty($missing)) {
            $this->error('Missing required fields: ' . implode(', ', $missing), 400);
        }
        
        try {
            // In a real app, you would integrate with payment processors like Stripe
            // This is a simplified example
            $result = $this->subscriptionModel->createSubscription(
                $user['user_id'],
                $data->plan_id,
                $data->payment_method,
                $data->payment_token ?? null
            );
            
            if ($result) {
                $this->success($result, 'Subscription created successfully', 201);
            } else {
                $this->error('Failed to create subscription', 500);
            }
            
        } catch (Exception $e) {
            logError('Subscription error: ' . $e->getMessage(), [
                'user_id' => $user['user_id'],
                'plan_id' => $data->plan_id
            ]);
            $this->error($e->getMessage(), 400);
        }
    }
    
    public function getStatus() {
        $this->validateMethod(['GET']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            $status = $this->subscriptionModel->getUserSubscriptionStatus($user['user_id']);
            $this->success($status);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve subscription status', 500);
        }
    }
    
    public function cancel() {
        $this->validateMethod(['POST']);
        $user = SimpleAuthMiddleware::authenticate();
        
        try {
            $result = $this->subscriptionModel->cancelSubscription($user['user_id']);
            
            if ($result) {
                $this->success([], 'Subscription cancelled successfully');
            } else {
                $this->error('Failed to cancel subscription', 500);
            }
            
        } catch (Exception $e) {
            $this->error($e->getMessage(), 400);
        }
    }
}
