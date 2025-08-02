import os
from typing import Dict

class Config:
    # Database configuration
    DB_CONFIG = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': int(os.getenv('DB_PORT', '3307')),  # Default MySQL port
        'user': os.getenv('DB_USER', 'root'),
        'password': os.getenv('DB_PASSWORD', ''),
        'database': os.getenv('DB_NAME', 'uk_visa_test'),
        'charset': 'utf8mb4'
    }
    
    # Crawler settings
    CRAWLER_DELAY = float(os.getenv('CRAWLER_DELAY', '1.0'))  # seconds between requests
    CRAWLER_TIMEOUT = int(os.getenv('CRAWLER_TIMEOUT', '10'))  # request timeout
    
    # Output settings
    JSON_OUTPUT_FILE = os.getenv('JSON_OUTPUT_FILE', 'uk_visa_questions.json')
    
    # Logging settings
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')