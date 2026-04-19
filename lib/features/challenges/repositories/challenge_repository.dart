import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/challenge_model.dart';

class ChallengeRepository {
  const ChallengeRepository();

  Future<List<ChallengeModel>> getChallenges() async {
    final res = await ApiClient.get(ApiEndpoints.challenges);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return (res.data['data'] as List<dynamic>)
          .map((e) => ChallengeModel.fromJson(
              e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(res.data['message'] ?? 'Failed to load challenges');
  }

  Future<({int xpEarned, String message})> claimChallenge(
      String id) async {
    final res =
        await ApiClient.post(ApiEndpoints.claimChallenge(id));
    if (res.statusCode == 200 && res.data['success'] == true) {
      return (
        xpEarned: (res.data['xpEarned'] as num?)?.toInt() ?? 0,
        message:  res.data['message']   as String? ?? 'Reward claimed!',
      );
    }
    throw Exception(res.data['message'] ?? 'Failed to claim reward');
  }
}