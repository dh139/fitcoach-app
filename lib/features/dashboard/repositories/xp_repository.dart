import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/xp_log_model.dart';
import '../models/xp_profile_model.dart';
import '../models/workout_stats_model.dart';

class XpRepository {
  const XpRepository();

  Future<XpProfileModel> getXpProfile() async {
    final res = await ApiClient.get(ApiEndpoints.xpProfile);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return XpProfileModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to load XP profile');
  }

  Future<List<XpLogModel>> getXpHistory({int limit = 10}) async {
    final res = await ApiClient.get(
      ApiEndpoints.xpHistory,
      params: {'limit': limit},
    );
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => XpLogModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(res.data['message'] ?? 'Failed to load XP history');
  }

  Future<WorkoutStatsModel> getWorkoutStats() async {
    final res = await ApiClient.get(ApiEndpoints.workoutStats);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return WorkoutStatsModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to load stats');
  }

  Future<void> useStreakFreeze() async {
    final res = await ApiClient.post(ApiEndpoints.streakFreeze);
    if (res.statusCode != 200 || res.data['success'] != true) {
      throw Exception(res.data['message'] ?? 'Failed to use streak freeze');
    }
  }
}