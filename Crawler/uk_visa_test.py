import requests
from bs4 import BeautifulSoup
import mysql.connector
import json
import time
import re
from typing import List, Dict, Optional
from dataclasses import dataclass
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class Answer:
    id: str
    text: str
    is_correct: bool = False

@dataclass
class Question:
    id: str
    chapter: str | None
    test_number: str
    question_text: str
    question_type: str  # 'radio' or 'checkbox'
    answers: List[Answer]
    explanation: str
    correct_answers: List[str]  # List of correct answer IDs

class UKVisaTestCrawler:
    def __init__(self, db_config: Optional[Dict] = None):
        self.base_url = "https://lifeintheuktestweb.co.uk"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36'
        })
        self.db_config = db_config
        self.questions_data = []
        
        # Test URLs organized 
        self.test_urls = {
            f"test-3-{i}" for i in range(1, 11)
        }

    def extract_question_data(self, html_content: str, chapter: str | None, test_number: str) -> List[Question]:
        """Extract question data from HTML content"""
        soup = BeautifulSoup(html_content, 'html.parser')
        questions = []
        
        # Find all question containers
        question_containers = soup.find_all('div', class_='container_question')
        
        for container in question_containers:
            try:
                question_id = container.get('data-id_question', '')
                
                # Extract question text
                question_element = container.find('div', class_='question')
                if not question_element:
                    continue
                    
                question_text = question_element.get_text(strip=True)
                
                # Extract answers
                answers = []
                answer_container = container.find('ul', class_='container_answer')
                if not answer_container:
                    continue
                
                answer_items = answer_container.find_all('li')
                question_type = 'radio'  # default
                
                for item in answer_items:
                    input_element = item.find('input')
                    if not input_element:
                        continue
                        
                    answer_id = input_element.get('data-id_answer', '')
                    input_type = input_element.get('type', 'radio')
                    if input_type == 'checkbox':
                        question_type = 'checkbox'
                    
                    # Get answer text (remove the input element)
                    label = item.find('label')
                    if label:
                        # Clone the label and remove input to get clean text
                        label_copy = BeautifulSoup(str(label), 'html.parser').find('label')
                        input_in_label = label_copy.find('input')
                        if input_in_label:
                            input_in_label.decompose()
                        answer_text = label_copy.get_text(strip=True)
                    else:
                        answer_text = item.get_text(strip=True)
                    
                    answers.append(Answer(id=answer_id, text=answer_text))
                
                # Extract explanation and correct answers
                explanation = ""
                correct_answers = []
                explanation_container = container.find('div', class_='container_explication')
                
                if explanation_container:
                    explanation = explanation_container.get_text(strip=True)
                    
                    # Try to identify correct answers from explanation
                    # Look for strong tags or specific patterns
                    strong_elements = explanation_container.find_all('strong')
                    for strong in strong_elements:
                        strong_text = strong.get_text(strip=True)
                        # Match this text with answers
                        for answer in answers:
                            if strong_text.lower() in answer.text.lower() or answer.text.lower() in strong_text.lower():
                                answer.is_correct = True
                                correct_answers.append(answer.id)
                    
                    # If no strong tags found, try to parse explanation text
                    if not correct_answers:
                        correct_answers = self._parse_correct_answers_from_explanation(explanation, answers)
                
                question = Question(
                    id=question_id,
                    chapter=chapter if chapter else None,
                    test_number=test_number,
                    question_text=question_text,
                    question_type=question_type,
                    answers=answers,
                    explanation=explanation,
                    correct_answers=correct_answers
                )
                
                questions.append(question)
                
            except Exception as e:
                logger.error(f"Error extracting question from container: {e}")
                continue
        
        return questions

    def _parse_correct_answers_from_explanation(self, explanation: str, answers: List[Answer]) -> List[str]:
        """Try to identify correct answers from explanation text"""
        correct_ids = []
        
        # Common patterns in explanations
        patterns = [
            r"correct answer[s]?[:\s]*([^.]+)",
            r"answer[s]?[:\s]*([^.]+)\s+is correct",
            r"([^.]+)\s+is the correct answer"
        ]
        
        explanation_lower = explanation.lower()
        
        for pattern in patterns:
            matches = re.findall(pattern, explanation_lower, re.IGNORECASE)
            for match in matches:
                for answer in answers:
                    if answer.text.lower() in match.lower() or match.lower() in answer.text.lower():
                        answer.is_correct = True
                        if answer.id not in correct_ids:
                            correct_ids.append(answer.id)
        
        return correct_ids

    def crawl_test(self, test_path: str, chapter: str | None, test_number: str) -> List[Question]:
        """Crawl a single test and return questions"""
        url = f"{self.base_url}/{test_path}"
        logger.info(f"Crawling: {url}")
        
        try:
            response = self.session.get(url, timeout=10)
            response.raise_for_status()
            
            questions = self.extract_question_data(response.text, chapter, test_number)
            logger.info(f"Extracted {len(questions)} questions from {test_path}")
            
            return questions
            
        except Exception as e:
            logger.error(f"Error crawling {url}: {e}")
            return []

    def crawl_all_tests(self):
        """Crawl all tests and collect data"""
        logger.info("Starting to crawl all tests...")
        
        if chapter is None:
            for test_paths in self.test_urls.items():
                
                for test_path in test_paths:
                    # Extract test number from path
                    test_number = test_path.split('-')[-1]
                    
                    questions = self.crawl_test(test_path, None, test_number)
                    self.questions_data.extend(questions)
                    
                    # Be respectful to the server
                    time.sleep(1)
        
        logger.info(f"Crawling completed. Total questions: {len(self.questions_data)}")

    def save_to_json(self, filename: str = "uk_visa_all_questions.json"):
        """Save collected data to JSON file"""
        data = {
            "metadata": {
                "total_questions": len(self.questions_data),
                "crawled_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "source": "lifeintheuktestweb.co.uk"
            },
            "questions": []
        }
        
        for question in self.questions_data:
            question_dict = {
                "id": question.id,
                "chapter": question.chapter,
                "test_number": question.test_number,
                "question_text": question.question_text,
                "question_type": question.question_type,
                "answers": [
                    {
                        "id": answer.id,
                        "text": answer.text,
                        "is_correct": answer.is_correct
                    }
                    for answer in question.answers
                ],
                "explanation": question.explanation,
                "correct_answers": question.correct_answers
            }
            data["questions"].append(question_dict)
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        logger.info(f"Data saved to {filename}")

    def create_database_schema(self):
        """Create MySQL database schema"""
        if not self.db_config:
            logger.error("Database configuration not provided")
            return
        
        connection = mysql.connector.connect(**self.db_config)
        cursor = connection.cursor()
        
        # Create tables
        schema_sql = """
        CREATE DATABASE IF NOT EXISTS uk_visa_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        USE uk_visa_test;
        
        CREATE TABLE IF NOT EXISTS chapters (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(50) NOT NULL UNIQUE,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE TABLE IF NOT EXISTS tests (
            id INT AUTO_INCREMENT PRIMARY KEY,
            chapter_id INT DEFAULT NULL,
            test_number VARCHAR(10) NOT NULL,
            title VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (chapter_id) REFERENCES chapters(id),
            UNIQUE KEY unique_chapter_test (chapter_id, test_number)
        );
        
        CREATE TABLE IF NOT EXISTS questions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            test_id INT NOT NULL,
            question_id VARCHAR(50) NOT NULL,
            question_text TEXT NOT NULL,
            question_type ENUM('radio', 'checkbox') NOT NULL,
            explanation TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (test_id) REFERENCES tests(id),
            INDEX idx_question_id (question_id)
        );
        
        CREATE TABLE IF NOT EXISTS answers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            question_id INT NOT NULL,
            answer_id VARCHAR(50) NOT NULL,
            answer_text TEXT NOT NULL,
            is_correct BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (question_id) REFERENCES questions(id),
            INDEX idx_answer_id (answer_id)
        );
        """
        
        # Execute schema creation
        for statement in schema_sql.split(';'):
            if statement.strip():
                cursor.execute(statement)
        
        connection.commit()
        cursor.close()
        connection.close()
        
        logger.info("Database schema created successfully")

    def save_to_database(self):
        """Save collected data to MySQL database"""
        if not self.db_config:
            logger.error("Database configuration not provided")
            return
        
        connection = mysql.connector.connect(**self.db_config)
        cursor = connection.cursor()
        
        try:
            # Use the database
            cursor.execute("USE uk_visa_test")
            
            # Insert chapters
            chapters = {}
            for question in self.questions_data:
                chapter_name = question.chapter
                if chapter_name not in chapters:
                    cursor.execute(
                        "INSERT IGNORE INTO chapters (name) VALUES (%s)",
                        (chapter_name,)
                    )
                    cursor.execute("SELECT id FROM chapters WHERE name = %s", (chapter_name,))
                    chapters[chapter_name] = cursor.fetchone()[0]
            
            # Insert tests and questions
            tests = {}
            for question in self.questions_data:
                chapter_id = chapters[question.chapter]
                test_key = f"{chapter_id}_{question.test_number}"
                
                if test_key not in tests:
                    cursor.execute(
                        "INSERT IGNORE INTO tests (chapter_id, test_number) VALUES (%s, %s)",
                        (chapter_id, question.test_number)
                    )
                    cursor.execute(
                        "SELECT id FROM tests WHERE chapter_id = %s AND test_number = %s",
                        (chapter_id, question.test_number)
                    )
                    tests[test_key] = cursor.fetchone()[0]
                
                test_id = tests[test_key]
                
                # Insert question
                cursor.execute(
                    "INSERT INTO questions (test_id, question_id, question_text, question_type, explanation) VALUES (%s, %s, %s, %s, %s)",
                    (test_id, question.id, question.question_text, question.question_type, question.explanation)
                )
                
                question_db_id = cursor.lastrowid
                
                # Insert answers
                for answer in question.answers:
                    cursor.execute(
                        "INSERT INTO answers (question_id, answer_id, answer_text, is_correct) VALUES (%s, %s, %s, %s)",
                        (question_db_id, answer.id, answer.text, answer.is_correct)
                    )
            
            connection.commit()
            logger.info("Data saved to database successfully")
            
        except Exception as e:
            logger.error(f"Error saving to database: {e}")
            connection.rollback()
        finally:
            cursor.close()
            connection.close()

def main():
    # Database configuration (update with your MySQL credentials)
    db_config = {
        'host': 'localhost',
        'user': 'root',
        'password': '',
        'database': 'uk_visa_test',
        'charset': 'utf8mb4'
    }
    
    # Initialize crawler
    crawler = UKVisaTestCrawler(db_config)
    
    # Create database schema
    crawler.create_database_schema()
    
    # Crawl all tests
    crawler.crawl_all_tests()
    
    # Save to JSON file
    crawler.save_to_json()
    
    # Save to database
    crawler.save_to_database()
    
    print(f"Crawling completed! Found {len(crawler.questions_data)} questions.")

if __name__ == "__main__":
    main()