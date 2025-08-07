import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/user_stats_repository.dart';

final progressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final statsRepository = ref.watch(userStatsRepositoryProvider);
  return await statsRepository.getProgressStats();
});

final testAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final statsRepository = ref.watch(userStatsRepositoryProvider);
  return await statsRepository.getTestAnalytics();
});

final recommendationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final statsRepository = ref.watch(userStatsRepositoryProvider);
  return await statsRepository.getRecommendations();
});