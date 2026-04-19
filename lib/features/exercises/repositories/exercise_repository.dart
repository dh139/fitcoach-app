import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  const ExerciseRepository();

  Future<({List<ExerciseModel> exercises, int total, int totalPages})>
      getExercises({
    String? search,
    String? bodyPart,
    String? equipment,
    String? difficulty,
    int page  = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      'page':  page,
      'limit': limit,
      if (search    != null && search.isNotEmpty)    'search':     search,
      if (bodyPart  != null && bodyPart.isNotEmpty)  'bodyPart':   bodyPart,
      if (equipment != null && equipment.isNotEmpty) 'equipment':  equipment,
      if (difficulty!= null && difficulty.isNotEmpty)'difficulty': difficulty,
    };

    final res = await ApiClient.get(ApiEndpoints.exercises, params: params);
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = (res.data['data'] as List<dynamic>)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = res.data['pagination'] as Map<String, dynamic>? ?? {};
      return (
        exercises:  list,
        total:      (pagination['total']      as num?)?.toInt() ?? list.length,
        totalPages: (pagination['totalPages'] as num?)?.toInt() ?? 1,
      );
    }
    throw Exception(res.data['message'] ?? 'Failed to load exercises');
  }

  Future<ExerciseFiltersModel> getFilterOptions() async {
    final res = await ApiClient.get(ApiEndpoints.exerciseFilters);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return ExerciseFiltersModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    }
    return ExerciseFiltersModel.empty;
  }

  Future<List<ExerciseModel>> getFavorites() async {
    final res = await ApiClient.get(ApiEndpoints.myFavorites);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return (res.data['data'] as List<dynamic>)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> toggleFavorite(String exerciseId) async {
    final res = await ApiClient.post(
        ApiEndpoints.favoriteById(exerciseId));
    if (res.statusCode == 200 || res.statusCode == 201) {
      return res.data['favorited'] as bool? ?? false;
    }
    throw Exception('Failed to toggle favorite');
  }
}