import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/rival_model.dart';

class RivalRepository {
  const RivalRepository();

  Future<List<RivalModel>> getMyRivals() async {
    final res = await ApiClient.get(ApiEndpoints.rivals);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return (res.data['data'] as List<dynamic>)
          .map((e) => RivalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<RivalSuggestion>> getSuggestions() async {
    final res = await ApiClient.get(ApiEndpoints.rivalSuggestions);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return (res.data['data'] as List<dynamic>)
          .map((e) => RivalSuggestion.fromJson(
              e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> challengeUser({
    required String userId,
    required String metric,
    required int    duration,
  }) async {
    final res = await ApiClient.post(
      ApiEndpoints.challengeUser(userId),
      data: {'metric': metric, 'duration': duration},
    );
    if (res.statusCode != 201 || res.data['success'] != true) {
      throw Exception(res.data['message'] ?? 'Challenge failed');
    }
  }

  Future<void> respondToRival({
    required String rivalId,
    required bool   accept,
  }) async {
    final res = await ApiClient.post(
      ApiEndpoints.respondRival(rivalId),
      data: {'accept': accept},
    );
    if (res.statusCode != 200 || res.data['success'] != true) {
      throw Exception(res.data['message'] ?? 'Response failed');
    }
  }
}