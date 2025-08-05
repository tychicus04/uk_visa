-- Database: uk_visa_test
-- Enhanced schema for UK Visa Test mobile app

-- ========================================
-- EXISTING TABLES (keep as is)
-- ========================================

-- Table: chapters
CREATE TABLE `chapters` (
  `id` int(11) NOT NULL,
  `chapter_number` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: tests (modified to add premium features)
CREATE TABLE `tests` (
  `id` int(11) NOT NULL,
  `chapter_id` int(11) DEFAULT NULL,
  `test_number` varchar(10) NOT NULL,
  `test_type` enum('chapter','comprehensive','exam') NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `is_free` tinyint(1) DEFAULT 0 COMMENT 'Free users can access if 1',
  `is_premium` tinyint(1) DEFAULT 1 COMMENT 'Premium required if 1',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: questions
CREATE TABLE `questions` (
  `id` int(11) NOT NULL,
  `test_id` int(11) NOT NULL,
  `question_id` varchar(50) NOT NULL,
  `question_text` text NOT NULL,
  `question_type` enum('radio','checkbox') NOT NULL,
  `explanation` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: answers
CREATE TABLE `answers` (
  `id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `answer_id` varchar(50) NOT NULL,
  `answer_text` text NOT NULL,
  `is_correct` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ========================================
-- NEW TABLES FOR USER MANAGEMENT
-- ========================================

-- Table: users
CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `is_premium` tinyint(1) DEFAULT 0,
  `premium_expires_at` timestamp NULL DEFAULT NULL,
  `language_code` varchar(5) DEFAULT 'en' COMMENT 'vi, en, etc.',
  `free_tests_used` int(11) DEFAULT 0,
  `free_tests_limit` int(11) DEFAULT 5 COMMENT 'Number of free tests allowed',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: user_test_attempts
CREATE TABLE `user_test_attempts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `test_id` int(11) NOT NULL,
  `score` int(11) DEFAULT NULL COMMENT 'Correct answers count',
  `total_questions` int(11) DEFAULT NULL,
  `percentage` decimal(5,2) DEFAULT NULL,
  `time_taken` int(11) DEFAULT NULL COMMENT 'Seconds taken to complete',
  `is_passed` tinyint(1) DEFAULT 0 COMMENT '1 if score >= 75%',
  `started_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: user_answers (detailed answers for each attempt)
CREATE TABLE `user_answers` (
  `id` int(11) NOT NULL,
  `attempt_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `selected_answer_ids` text NOT NULL COMMENT 'JSON array of selected answer IDs',
  `is_correct` tinyint(1) DEFAULT 0,
  `answered_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: subscriptions (simple payment tracking)
CREATE TABLE `subscriptions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `subscription_type` enum('monthly','yearly','lifetime') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `payment_method` varchar(50) DEFAULT NULL COMMENT 'stripe, paypal, etc.',
  `payment_id` varchar(255) DEFAULT NULL COMMENT 'External payment ID',
  `starts_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  `status` enum('active','expired','cancelled') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ========================================
-- INDEXES
-- ========================================

-- Existing indexes
ALTER TABLE `chapters` ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `unique_chapter_number` (`chapter_number`);

ALTER TABLE `tests` ADD PRIMARY KEY (`id`), ADD KEY `chapter_id` (`chapter_id`), 
ADD KEY `idx_test_type` (`test_type`), ADD KEY `idx_test_number` (`test_number`),
ADD KEY `idx_is_free` (`is_free`), ADD KEY `idx_is_premium` (`is_premium`);

ALTER TABLE `questions` ADD PRIMARY KEY (`id`), ADD KEY `test_id` (`test_id`), 
ADD KEY `idx_question_id` (`question_id`), ADD KEY `idx_question_type` (`question_type`);

ALTER TABLE `answers` ADD PRIMARY KEY (`id`), ADD KEY `question_id` (`question_id`), 
ADD KEY `idx_answer_id` (`answer_id`), ADD KEY `idx_is_correct` (`is_correct`);

-- New indexes
ALTER TABLE `users` ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `unique_email` (`email`),
ADD KEY `idx_is_premium` (`is_premium`), ADD KEY `idx_language_code` (`language_code`);

ALTER TABLE `user_test_attempts` ADD PRIMARY KEY (`id`), ADD KEY `user_id` (`user_id`), 
ADD KEY `test_id` (`test_id`), ADD KEY `idx_is_passed` (`is_passed`);

ALTER TABLE `user_answers` ADD PRIMARY KEY (`id`), ADD KEY `attempt_id` (`attempt_id`), 
ADD KEY `question_id` (`question_id`);

ALTER TABLE `subscriptions` ADD PRIMARY KEY (`id`), ADD KEY `user_id` (`user_id`), 
ADD KEY `idx_status` (`status`);

-- ========================================
-- AUTO INCREMENT
-- ========================================
ALTER TABLE `chapters` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `tests` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `questions` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `answers` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `users` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `user_test_attempts` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `user_answers` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `subscriptions` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

-- ========================================
-- FOREIGN KEY CONSTRAINTS
-- ========================================
ALTER TABLE `tests` ADD CONSTRAINT `tests_ibfk_1` 
FOREIGN KEY (`chapter_id`) REFERENCES `chapters` (`id`) ON DELETE SET NULL;

ALTER TABLE `questions` ADD CONSTRAINT `questions_ibfk_1` 
FOREIGN KEY (`test_id`) REFERENCES `tests` (`id`) ON DELETE CASCADE;

ALTER TABLE `answers` ADD CONSTRAINT `answers_ibfk_1` 
FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE;

ALTER TABLE `user_test_attempts` ADD CONSTRAINT `user_test_attempts_ibfk_1` 
FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `user_test_attempts` ADD CONSTRAINT `user_test_attempts_ibfk_2` 
FOREIGN KEY (`test_id`) REFERENCES `tests` (`id`) ON DELETE CASCADE;

ALTER TABLE `user_answers` ADD CONSTRAINT `user_answers_ibfk_1` 
FOREIGN KEY (`attempt_id`) REFERENCES `user_test_attempts` (`id`) ON DELETE CASCADE;

ALTER TABLE `user_answers` ADD CONSTRAINT `user_answers_ibfk_2` 
FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE;

ALTER TABLE `subscriptions` ADD CONSTRAINT `subscriptions_ibfk_1` 
FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

-- ========================================
-- SAMPLE DATA
-- ========================================

-- Insert sample chapters (existing data)
INSERT INTO `chapters` (`id`, `chapter_number`, `name`, `description`) VALUES
(1, 1, 'Chapter 1: The Values and Principles of the UK', NULL),
(2, 2, 'Chapter 2: What is the UK?', NULL),
(3, 3, 'Chapter 3: A Long and Illustrious History', NULL),
(4, 4, 'Chapter 4: A Modern, Thriving Society', NULL),
(5, 5, 'Chapter 5: The UK Government, the Law and Your Role', NULL);

-- Insert sample tests with free/premium flags
INSERT INTO `tests` (`chapter_id`, `test_number`, `test_type`, `title`, `is_free`, `is_premium`) VALUES
(1, 'T1.1', 'chapter', 'Chapter 1 - Basic Test', 1, 0),
(1, 'T1.2', 'chapter', 'Chapter 1 - Advanced Test', 0, 1),
(2, 'T2.1', 'chapter', 'Chapter 2 - Basic Test', 1, 0),
(2, 'T2.2', 'chapter', 'Chapter 2 - Advanced Test', 0, 1),
(NULL, 'COMP1', 'comprehensive', 'Comprehensive Test 1', 1, 0),
(NULL, 'COMP2', 'comprehensive', 'Comprehensive Test 2', 0, 1),
(NULL, 'EXAM1', 'exam', 'Practice Exam 1', 0, 1),
(NULL, 'EXAM2', 'exam', 'Practice Exam 2', 0, 1);