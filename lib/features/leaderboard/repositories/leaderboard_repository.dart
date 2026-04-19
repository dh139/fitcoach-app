import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/leaderboard_model.dart';

class LeaderboardRepository {
  const LeaderboardRepository();

  Future<LeaderboardData> getLeaderboard({
    required String period,
    int page  = 1,
    int limit = 50,
  }) async {
    final res = await ApiClient.get(
      ApiEndpoints.leaderboard,
      params: {'period': period, 'page': page, 'limit': limit},
    );
    if (res.statusCode == 200 && res.data['success'] == true) {
      return LeaderboardData.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to load leaderboard');
  }

  Future<List<MyPeriodRank>> getMyStats() async {
    final res = await ApiClient.get(ApiEndpoints.leaderboardMyStats);
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => MyPeriodRank.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}