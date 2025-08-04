<?php
require_once __DIR__ . '/../Core/BaseModel.php';

class Subscription extends BaseModel {
    protected $table = 'subscriptions';
    protected $fillable = ['user_id', 'subscription_type', 'amount', 'currency', 'payment_method', 'payment_id', 'starts_at', 'expires_at', 'status'];
    
    public function __construct() {
        parent::__construct();
    }
    
    public function createSubscription($userId, $planId, $paymentMethod, $paymentToken = null) {
        $plans = [
            'monthly' => ['amount' => 9.99, 'duration' => 30],
            'yearly' => ['amount' => 79.99, 'duration' => 365],
            'lifetime' => ['amount' => 199.99, 'duration' => null]
        ];
        
        if (!isset($plans[$planId])) {
            throw new Exception('Invalid plan selected');
        }
        
        $plan = $plans[$planId];
        
        // In production, process payment here with Stripe/PayPal etc.
        $paymentId = 'demo_' . uniqid(); // Mock payment ID
        
        $subscriptionData = [
            'user_id' => $userId,
            'subscription_type' => $planId,
            'amount' => $plan['amount'],
            'currency' => 'USD',
            'payment_method' => $paymentMethod,
            'payment_id' => $paymentId,
            'starts_at' => date('Y-m-d H:i:s'),
            'expires_at' => $plan['duration'] ? date('Y-m-d H:i:s', strtotime("+{$plan['duration']} days")) : null,
            'status' => 'active'
        ];
        
        $subscription = $this->create($subscriptionData);
        
        if ($subscription) {
            // Update user premium status
            $this->updateUserPremiumStatus($userId, true, $subscription['expires_at']);
        }
        
        return $subscription;
    }
    
    public function getUserSubscriptionStatus($userId) {
        $sql = "SELECT s.*, 
                       CASE 
                           WHEN s.expires_at IS NULL THEN 'lifetime'
                           WHEN s.expires_at > NOW() THEN 'active'
                           ELSE 'expired'
                       END as current_status
                FROM {$this->table} s
                WHERE s.user_id = :user_id 
                ORDER BY s.created_at DESC 
                LIMIT 1";
        
        $result = $this->query($sql, [':user_id' => $userId]);
        
        return !empty($result) ? $result[0] : ['current_status' => 'none'];
    }
    
    public function cancelSubscription($userId) {
        $sql = "UPDATE {$this->table} 
                SET status = 'cancelled' 
                WHERE user_id = :user_id AND status = 'active'";
        
        $stmt = $this->db->prepare($sql);
        $result = $stmt->execute([':user_id' => $userId]);
        
        if ($result) {
            // Update user premium status
            $this->updateUserPremiumStatus($userId, false, null);
        }
        
        return $result;
    }
    
    private function updateUserPremiumStatus($userId, $isPremium, $expiresAt) {
        $sql = "UPDATE users 
                SET is_premium = :is_premium, premium_expires_at = :expires_at 
                WHERE id = :user_id";
        
        $stmt = $this->db->prepare($sql);
        return $stmt->execute([
            ':is_premium' => $isPremium ? 1 : 0,
            ':expires_at' => $expiresAt,
            ':user_id' => $userId
        ]);
    }
    
    public function getActiveSubscriptions() {
        return $this->query(
            "SELECT s.*, u.email, u.full_name 
             FROM {$this->table} s 
             JOIN users u ON s.user_id = u.id 
             WHERE s.status = 'active' 
             ORDER BY s.created_at DESC"
        );
    }
}