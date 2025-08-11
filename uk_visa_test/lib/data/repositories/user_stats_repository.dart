// lib/data/repositories/user_stats_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

final userStatsRepositoryProvider = Provider<UserStatsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserStatsRepository(dio);
});

class UserStatsRepository {
  final Dio _dio;

  UserStatsRepository(this._dio);

  /// Get user progress statistics
  Future<Map<String, dynamic>> getProgressStats() async {
    try {
      final response = await _dio.get('/user/progress');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        // Return mock data for development
        return _getMockProgressStats();
      }
    } catch (e) {
      print('⚠️ Failed to get progress stats, using mock data: $e');
      return _getMockProgressStats();
    }
  }

  /// Get test analytics
  Future<Map<String, dynamic>> getTestAnalytics() async {
    try {
      final response = await _dio.get('/user/analytics');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        return _getMockTestAnalytics();
      }
    } catch (e) {
      print('⚠️ Failed to get test analytics, using mock data: $e');
      return _getMockTestAnalytics();
    }
  }

  /// Get personalized recommendations
  Future<List<Map<String, dynamic>>> getRecommendations() async {
    try {
      final response = await _dio.get('/user/recommendations');

      if (response.data['success'] == true) {
        return (response.data['data'] as List).cast<Map<String, dynamic>>();
      } else {
        return _getMockRecommendations();
      }
    } catch (e) {
      print('⚠️ Failed to get recommendations, using mock data: $e');
      return _getMockRecommendations();
    }
  }

  // ✅ Mock data for development
  Map<String, dynamic> _getMockProgressStats() {
    return {
      'practice_progress': {
        'percentage': 76,
        'daily_questions_answered': 29,
        'tests_completed': 34,
        'total_tests': 45,
      },
      'reading_progress': {
        'percentage': 89,
        'sections_read': 24,
        'total_sections': 27,
      },
      'overall_stats': {
        'total_study_time': '25h 30m',
        'current_streak': 7,
        'longest_streak': 15,
        'average_score': 78.5,
        'best_score': 95.0,
        'total_attempts': 34,
        'passed_attempts': 26,
      }
    };
  }

  Map<String, dynamic> _getMockTestAnalytics() {
    return {
      'score_history': [65, 72, 68, 78, 85, 82, 90, 87, 92, 88],
      'score_labels': ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10'],
      'performance_by_chapter': {
        '1': {'average': 85.5, 'attempts': 5, 'best': 95},
        '2': {'average': 78.2, 'attempts': 4, 'best': 88},
        '3': {'average': 82.7, 'attempts': 6, 'best': 92},
        '4': {'average': 76.1, 'attempts': 3, 'best': 85},
        '5': {'average': 80.3, 'attempts': 4, 'best': 90},
      },
      'weak_areas': [
        {'topic': 'British History', 'accuracy': 65, 'suggestions': 'Focus on dates and key events'},
        {'topic': 'Government Structure', 'accuracy': 72, 'suggestions': 'Review parliamentary system'},
      ],
      'strong_areas': [
        {'topic': 'Values and Principles', 'accuracy': 92, 'suggestions': 'Keep practicing to maintain'},
        {'topic': 'Modern Society', 'accuracy': 88, 'suggestions': 'Excellent understanding'},
      ]
    };
  }

  List<Map<String, dynamic>> _getMockRecommendations() {
    return [
      {
        'type': 'study_focus',
        'title': 'Focus on British History',
        'description': 'Your weakest area. Spend 15-20 minutes reviewing key historical events.',
        'priority': 'high',
        'action': 'study_chapter',
        'chapter_id': '3'
      },
      {
        'type': 'practice_test',
        'title': 'Take Comprehensive Test 2',
        'description': 'You haven\'t attempted this test yet. Good for overall assessment.',
        'priority': 'medium',
        'action': 'take_test',
        'test_id': '15'
      },
      {
        'type': 'review',
        'title': 'Review Failed Questions',
        'description': 'You have 12 questions that need review from previous tests.',
        'priority': 'medium',
        'action': 'review_questions'
      },
      {
        'type': 'milestone',
        'title': 'Maintain Study Streak',
        'description': 'You\'re on a 7-day streak! Don\'t break it now.',
        'priority': 'low',
        'action': 'daily_question'
      }
    ];
  }
}