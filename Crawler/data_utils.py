

import json
import mysql.connector
from typing import Dict, List, Any
from collections import defaultdict, Counter
import argparse

class DataAnalyzer:
    def __init__(self, db_config: Dict = None, json_file: str = None):
        self.db_config = db_config
        self.json_file = json_file
        self.data = None
        
        if json_file:
            self.load_from_json()
    
    def load_from_json(self):
        """Load data from JSON file"""
        try:
            with open(self.json_file, 'r', encoding='utf-8') as f:
                self.data = json.load(f)
        except FileNotFoundError:
            print(f"JSON file {self.json_file} not found!")
            self.data = None
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get comprehensive statistics about the data"""
        if not self.data:
            return {}
        
        questions = self.data['questions']
        stats = {
            'total_questions': len(questions),
            'by_test_type': defaultdict(int),
            'by_chapter': defaultdict(int),
            'by_question_type': defaultdict(int),
            'by_test_number': defaultdict(int),
            'answer_distribution': defaultdict(int),
            'questions_with_explanations': 0,
            'questions_with_correct_answers': 0,
            'comprehensive_tests': defaultdict(int),
            'chapter_tests': defaultdict(int)
        }
        
        for q in questions:
            # Test type distribution
            test_type = q.get('test_type', 'unknown')
            stats['by_test_type'][test_type] += 1
            
            # Chapter distribution
            chapter = q.get('chapter', 'comprehensive')
            if chapter:
                stats['by_chapter'][chapter] += 1
            else:
                stats['by_chapter']['comprehensive'] += 1
            
            # Question type distribution
            stats['by_question_type'][q['question_type']] += 1
            
            # Test number distribution
            test_key = f"{test_type}_test_{q['test_number']}"
            stats['by_test_number'][test_key] += 1
            
            # Separate comprehensive and chapter test tracking
            if test_type == 'comprehensive':
                stats['comprehensive_tests'][f"test_{q['test_number']}"] += 1
            else:
                chapter_key = f"{chapter}_test_{q['test_number']}"
                stats['chapter_tests'][chapter_key] += 1
            
            # Answer count distribution
            answer_count = len(q['answers'])
            stats['answer_distribution'][f'{answer_count}_answers'] += 1
            
            # Questions with explanations
            if q.get('explanation'):
                stats['questions_with_explanations'] += 1
            
            # Questions with identified correct answers
            if q.get('correct_answers'):
                stats['questions_with_correct_answers'] += 1
        
        return dict(stats)
    
    def print_statistics(self):
        """Print formatted statistics"""
        stats = self.get_statistics()
        
        if not stats:
            print("No data available for analysis")
            return
        
        print("=" * 60)
        print("UK VISA TEST DATA STATISTICS")
        print("=" * 60)
        print(f"Total Questions: {stats['total_questions']}")
        print()
        
        print("📊 Test Type Distribution:")
        for test_type, count in sorted(stats['by_test_type'].items()):
            print(f"  {test_type.title()}: {count}")
        print()
        
        print("📚 Chapter Distribution:")
        chapter_items = sorted(stats['by_chapter'].items())
        for chapter, count in chapter_items:
            if chapter == 'comprehensive':
                print(f"  🔄 Comprehensive Tests: {count}")
            else:
                chapter_display = chapter.replace('_', ' ').title()
                print(f"  📖 {chapter_display}: {count}")
        print()
        
        print("❓ Question Type Distribution:")
        for qtype, count in stats['by_question_type'].items():
            icon = "🔘" if qtype == "radio" else "☑️"
            print(f"  {icon} {qtype.title()}: {count}")
        print()
        
        print("📝 Answer Distribution:")
        for answers, count in sorted(stats['answer_distribution'].items()):
            print(f"  {answers}: {count}")
        print()
        
        print("✅ Data Quality:")
        print(f"  Questions with explanations: {stats['questions_with_explanations']}/{stats['total_questions']}")
        print(f"  Questions with correct answers: {stats['questions_with_correct_answers']}/{stats['total_questions']}")
        
        # Show potential data quality issues
        missing_explanations = stats['total_questions'] - stats['questions_with_explanations']
        missing_correct_answers = stats['total_questions'] - stats['questions_with_correct_answers']
        
        if missing_explanations > 0 or missing_correct_answers > 0:
            print("\n⚠️  DATA QUALITY ISSUES:")
            if missing_explanations > 0:
                print(f"  📝 {missing_explanations} questions missing explanations")
            if missing_correct_answers > 0:
                print(f"  ✅ {missing_correct_answers} questions missing correct answer identification")
        
        # Show comprehensive test coverage
        print(f"\n🔄 Comprehensive Test Coverage:")
        comp_tests = len(stats['comprehensive_tests'])
        print(f"  Tests found: {comp_tests}/40")
        if comp_tests < 40:
            missing_tests = []
            for i in range(1, 41):
                if f"test_{i}" not in stats['comprehensive_tests']:
                    missing_tests.append(str(i))
            if missing_tests:
                print(f"  Missing tests: {', '.join(missing_tests[:10])}")
                if len(missing_tests) > 10:
                    print(f"  ... and {len(missing_tests) - 10} more")
        
        # Show chapter test coverage
        print(f"\n📚 Chapter Test Coverage:")
        for chapter in ['chapter_1', 'chapter_2', 'chapter_3', 'chapter_4', 'chapter_5']:
            chapter_tests = [k for k in stats['chapter_tests'].keys() if k.startswith(chapter)]
            print(f"  {chapter.replace('_', ' ').title()}: {len(chapter_tests)} tests")
    
    def find_questions_without_correct_answers(self) -> List[Dict]:
        """Find questions where correct answers couldn't be identified"""
        if not self.data:
            return []
        
        problematic = []
        for q in self.data['questions']:
            if not q.get('correct_answers'):
                problematic.append({
                    'id': q['id'],
                    'chapter': q.get('chapter', 'comprehensive'),
                    'test_number': q['test_number'],
                    'test_type': q.get('test_type', 'unknown'),
                    'question_text': q['question_text'][:100] + "..." if len(q['question_text']) > 100 else q['question_text'],
                    'explanation': (q.get('explanation', '')[:100] + "...") if q.get('explanation') and len(q.get('explanation', '')) > 100 else q.get('explanation', 'No explanation'),
                    'answers': [{'id': a['id'], 'text': a['text']} for a in q['answers']]
                })
        
        return problematic
    
    def find_duplicate_questions(self) -> List[Dict]:
        """Find potential duplicate questions"""
        if not self.data:
            return []
        
        question_texts = defaultdict(list)
        for q in self.data['questions']:
            # Normalize question text for comparison
            normalized_text = q['question_text'].lower().strip()
            question_texts[normalized_text].append({
                'id': q['id'],
                'chapter': q.get('chapter', 'comprehensive'),
                'test_number': q['test_number'],
                'test_type': q.get('test_type', 'unknown')
            })
        
        duplicates = []
        for text, questions in question_texts.items():
            if len(questions) > 1:
                duplicates.append({
                    'question_text': text[:100] + "..." if len(text) > 100 else text,
                    'occurrences': questions
                })
        
        return duplicates
    
    def export_for_manual_review(self, output_file: str = "questions_for_review.json"):
        """Export questions that need manual review"""
        problematic = self.find_questions_without_correct_answers()
        duplicates = self.find_duplicate_questions()
        
        review_data = {
            'metadata': {
                'export_date': json.dumps(None),
                'problematic_count': len(problematic),
                'duplicate_count': len(duplicates)
            },
            'questions_without_correct_answers': problematic,
            'potential_duplicates': duplicates
        }
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(review_data, f, indent=2, ensure_ascii=False)
        
        print(f"📤 Exported {len(problematic)} problematic questions and {len(duplicates)} potential duplicates to {output_file}")
    
    def validate_database_data(self) -> Dict[str, Any]:
        """Validate data in MySQL database"""
        if not self.db_config:
            return {"error": "No database configuration provided"}
        
        try:
            connection = mysql.connector.connect(**self.db_config)
            cursor = connection.cursor(dictionary=True)
            
            cursor.execute("USE uk_visa_test")
            
            # Get counts from each table
            results = {}
            
            cursor.execute("SELECT COUNT(*) as count FROM chapters")
            results['chapters'] = cursor.fetchone()['count']
            
            cursor.execute("SELECT COUNT(*) as count FROM tests")
            results['tests'] = cursor.fetchone()['count']
            
            cursor.execute("SELECT COUNT(*) as count FROM questions")
            results['questions'] = cursor.fetchone()['count']
            
            cursor.execute("SELECT COUNT(*) as count FROM answers")
            results['answers'] = cursor.fetchone()['count']
            
            # Get test type distribution
            cursor.execute("""
                SELECT test_type, COUNT(*) as count 
                FROM tests 
                GROUP BY test_type
            """)
            results['test_type_distribution'] = cursor.fetchall()
            
            # Get questions without correct answers
            cursor.execute("""
                SELECT q.id, q.question_text, t.test_type, c.name as chapter_name
                FROM questions q 
                JOIN tests t ON q.test_id = t.id
                LEFT JOIN chapters c ON t.chapter_id = c.id
                WHERE q.id NOT IN (
                    SELECT DISTINCT a.question_id 
                    FROM answers a 
                    WHERE a.is_correct = TRUE
                )
                LIMIT 10
            """)
            results['questions_without_correct_answers'] = cursor.fetchall()
            
            # Get distribution by chapter
            cursor.execute("""
                SELECT 
                    COALESCE(c.name, 'Comprehensive Tests') as chapter_name,
                    t.test_type,
                    COUNT(q.id) as question_count
                FROM tests t
                LEFT JOIN chapters c ON t.chapter_id = c.id
                LEFT JOIN questions q ON t.id = q.test_id
                GROUP BY c.id, c.name, t.test_type
                ORDER BY c.chapter_number, t.test_type
            """)
            results['chapter_distribution'] = cursor.fetchall()
            
            # Get comprehensive test coverage
            cursor.execute("""
                SELECT test_number, COUNT(q.id) as question_count
                FROM tests t
                LEFT JOIN questions q ON t.id = q.test_id
                WHERE t.test_type = 'comprehensive'
                GROUP BY t.test_number
                ORDER BY CAST(t.test_number AS UNSIGNED)
            """)
            results['comprehensive_test_coverage'] = cursor.fetchall()
            
            return results
            
        except Exception as e:
            return {"error": f"Database error: {str(e)}"}
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'connection' in locals():
                connection.close()

class DataManager:
    def __init__(self, db_config: Dict):
        self.db_config = db_config
    
    def backup_database_to_json(self, output_file: str = "database_backup.json"):
        """Backup entire database to JSON"""
        try:
            connection = mysql.connector.connect(**self.db_config)
            cursor = connection.cursor(dictionary=True)
            
            cursor.execute("USE uk_visa_test")
            
            # Get all data
            backup_data = {
                'metadata': {
                    'backup_date': json.dumps(None),
                    'version': '2.0'
                },
                'chapters': [],
                'tests': [],
                'questions': [],
                'answers': []
            }
            
            # Chapters
            cursor.execute("SELECT * FROM chapters ORDER BY chapter_number")
            backup_data['chapters'] = cursor.fetchall()
            
            # Tests
            cursor.execute("SELECT * FROM tests ORDER BY id")
            backup_data['tests'] = cursor.fetchall()
            
            # Questions
            cursor.execute("SELECT * FROM questions ORDER BY id")
            backup_data['questions'] = cursor.fetchall()
            
            # Answers
            cursor.execute("SELECT * FROM answers ORDER BY id")
            backup_data['answers'] = cursor.fetchall()
            
            # Convert datetime objects to strings
            def serialize_datetime(obj):
                if hasattr(obj, 'isoformat'):
                    return obj.isoformat()
                return obj
            
            # Save to file
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(backup_data, f, indent=2, ensure_ascii=False, default=serialize_datetime)
            
            print(f"📦 Database backed up to {output_file}")
            
        except Exception as e:
            print(f"❌ Backup failed: {e}")
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'connection' in locals():
                connection.close()
    
    def clear_database(self, confirm: bool = False):
        """Clear all data from database (be careful!)"""
        if not confirm:
            print("❌ This operation requires confirmation. Use --confirm flag.")
            return
            
        try:
            connection = mysql.connector.connect(**self.db_config)
            cursor = connection.cursor()
            
            cursor.execute("USE uk_visa_test")
            
            # Disable foreign key checks
            cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
            
            # Clear tables in reverse order
            tables = ['answers', 'questions', 'tests', 'chapters']
            for table in tables:
                cursor.execute(f"DELETE FROM {table}")
                print(f"🗑️  Cleared table: {table}")
            
            # Re-enable foreign key checks
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
            
            connection.commit()
            print("✅ Database cleared successfully")
            
        except Exception as e:
            print(f"❌ Clear operation failed: {e}")
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'connection' in locals():
                connection.close()

def main():
    parser = argparse.ArgumentParser(description='UK Visa Test Data Utilities')
    parser.add_argument('command', choices=['stats', 'validate', 'backup', 'review', 'clear'], 
                       help='Command to run')
    parser.add_argument('--json-file', default='uk_visa_all_questions.json',
                       help='JSON file to analyze')
    parser.add_argument('--output', help='Output file for export commands')
    parser.add_argument('--confirm', action='store_true', 
                       help='Confirm destructive operations')
    
    args = parser.parse_args()
    
    # Database config (update as needed)
    db_config = {
        'host': 'localhost',
        'port': 3307,  # Default MySQL port
        'user': 'root',
        'password': '',
        'database': 'uk_visa_test',
        'charset': 'utf8mb4'
    }
    
    if args.command == 'stats':
        analyzer = DataAnalyzer(json_file=args.json_file)
        analyzer.print_statistics()
    
    elif args.command == 'validate':
        analyzer = DataAnalyzer(db_config=db_config)
        results = analyzer.validate_database_data()
        
        if 'error' in results:
            print(f"❌ {results['error']}")
        else:
            print("📊 DATABASE VALIDATION RESULTS")
            print("=" * 40)
            print(f"Chapters: {results['chapters']}")
            print(f"Tests: {results['tests']}")
            print(f"Questions: {results['questions']}")
            print(f"Answers: {results['answers']}")
            
            print("\n📈 Test Type Distribution:")
            for item in results['test_type_distribution']:
                print(f"  {item['test_type']}: {item['count']}")
            
            print("\n📚 Chapter Distribution:")
            for item in results['chapter_distribution']:
                print(f"  {item['chapter_name']} ({item['test_type']}): {item['question_count']} questions")
            
            problematic_count = len(results['questions_without_correct_answers'])
            if problematic_count > 0:
                print(f"\n⚠️  {problematic_count} questions without correct answers (showing first 10)")
    
    elif args.command == 'backup':
        manager = DataManager(db_config)
        output_file = args.output or 'database_backup.json'
        manager.backup_database_to_json(output_file)
    
    elif args.command == 'review':
        analyzer = DataAnalyzer(json_file=args.json_file)
        output_file = args.output or 'questions_for_review.json'
        analyzer.export_for_manual_review(output_file)
    
    elif args.command == 'clear':
        manager = DataManager(db_config)
        manager.clear_database(args.confirm)

if __name__ == "__main__":
    main()