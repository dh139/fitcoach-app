import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/workout_session_model.dart';
import '../models/workout_result_model.dart';

class WorkoutRepository {
  const WorkoutRepository();

  // Start a new session — returns workoutId from backend
  Future<String> startWorkout({required String workoutName}) async {
    final res = await ApiClient.post(ApiEndpoints.workoutStart, data: {
      'workoutName': workoutName,
    });
    if (res.statusCode == 201 && res.data['success'] == true) {
      return res.data['data']['_id'] as String;
    }
    throw Exception(res.data['message'] ?? 'Failed to start workout');
  }

  // Complete session — sends all logs, returns result
  Future<WorkoutResultModel> completeWorkout({
    required String                workoutId,
    required List<ExerciseLogEntry> exerciseLogs,
  }) async {
    final res = await ApiClient.post(ApiEndpoints.workoutComplete, data: {
      'workoutId':    workoutId,
      'exerciseLogs': exerciseLogs.map((e) => e.toJson()).toList(),
    });

    if (res.statusCode == 200 && res.data['success'] == true) {
      return WorkoutResultModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to complete workout');
  }
}