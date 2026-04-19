import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/workout_history_model.dart';

class HistoryRepository {
  const HistoryRepository();

  Future<({
    List<WorkoutHistoryModel> workouts,
    int total,
    int totalPages,
  })> getWorkoutHistory({
    int page  = 1,
    int limit = 20,
  }) async {
    final res = await ApiClient.get(
      ApiEndpoints.workoutHistory,
      params: {'page': page, 'limit': limit},
    );
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = (res.data['data'] as List<dynamic>)
          .map((e) => WorkoutHistoryModel.fromJson(
              e as Map<String, dynamic>))
          .toList();
      final pagination =
          res.data['pagination'] as Map<String, dynamic>? ?? {};
      return (
        workouts:   list,
        total:     (pagination['total']      as num?)?.toInt() ?? list.length,
        totalPages:(pagination['totalPages'] as num?)?.toInt() ?? 1,
      );
    }
    throw Exception(res.data['message'] ?? 'Failed to load history');
  }

  // Build chart data from history
  List<ChartDataPoint> buildFrequencyData(
      List<WorkoutHistoryModel> workouts) {
    // Last 8 weeks — workouts per week aligned to latest workout
    final validDates = workouts.map((w) => w.completedDateTime).where((d) => d != null).toList();
    final now = validDates.isNotEmpty 
        ? validDates.reduce((a, b) => a!.isAfter(b!) ? a : b) ?? DateTime.now()
        : DateTime.now();
    final weeks  = <String, int>{};

    for (var i = 7; i >= 0; i--) {
      final key = 'W${8 - i}';
      weeks[key] = 0;
    }

    // A fast way to compute weeks diff independent of timezone/hours is by creating pure date objects at midnight
    final nowMidnight = DateTime(now.year, now.month, now.day);
    for (final w in workouts) {
      final dtRaw = w.completedDateTime;
      if (dtRaw == null) continue;
      final dt = DateTime(dtRaw.year, dtRaw.month, dtRaw.day);
      final diff  = nowMidnight.difference(dt).inDays;
      if (diff < 0) continue;
      final wkIdx = diff ~/ 7;
      if (wkIdx > 7) continue;
      final key = 'W${8 - wkIdx}';
      weeks[key] = (weeks[key] ?? 0) + 1;
    }

    return weeks.entries.map((e) => ChartDataPoint(
      label: e.key,
      value: e.value.toDouble(),
      date:  now,
    )).toList();
  }

  List<ChartDataPoint> buildCalorieData(
      List<WorkoutHistoryModel> workouts) {
    // Last 14 days aligned to latest workout
    final validDates = workouts.map((w) => w.completedDateTime).where((d) => d != null).toList();
    final now = validDates.isNotEmpty 
        ? validDates.reduce((a, b) => a!.isAfter(b!) ? a : b) ?? DateTime.now()
        : DateTime.now();
    final days   = <String, double>{};

    final nowMidnight = DateTime(now.year, now.month, now.day);
    for (var i = 13; i >= 0; i--) {
      final d = nowMidnight.subtract(Duration(days: i));
      days[_dayKey(d)] = 0;
    }

    for (final w in workouts) {
      final dtRaw = w.completedDateTime;
      if (dtRaw == null) continue;
      final dt = DateTime(dtRaw.year, dtRaw.month, dtRaw.day);
      final diff = nowMidnight.difference(dt).inDays;
      if (diff < 0 || diff > 13) continue;
      final key = _dayKey(dt);
      days[key] = (days[key] ?? 0) + w.totalCaloriesBurned;
    }

    return days.entries.map((e) => ChartDataPoint(
      label: e.key,
      value: e.value,
      date:  now,
    )).toList();
  }

  List<ChartDataPoint> buildXpData(
      List<WorkoutHistoryModel> workouts) {
    // Cumulative XP over last 14 days aligned to latest workout
    final validDates = workouts.map((w) => w.completedDateTime).where((d) => d != null).toList();
    final now = validDates.isNotEmpty 
        ? validDates.reduce((a, b) => a!.isAfter(b!) ? a : b) ?? DateTime.now()
        : DateTime.now();
    final sorted = [...workouts]
      ..sort((a, b) =>
          (a.completedDateTime ?? now)
              .compareTo(b.completedDateTime ?? now));

    final nowMidnight = DateTime(now.year, now.month, now.day);
    final days = <String, double>{};
    for (var i = 13; i >= 0; i--) {
      final d = nowMidnight.subtract(Duration(days: i));
      days[_dayKey(d)] = 0;
    }

    for (final w in sorted) {
      final dtRaw = w.completedDateTime;
      if (dtRaw == null) continue;
      final dt = DateTime(dtRaw.year, dtRaw.month, dtRaw.day);
      final diff = nowMidnight.difference(dt).inDays;
      if (diff < 0 || diff > 13) continue;
      final key = _dayKey(dt);
      days[key] = (days[key] ?? 0) + w.xpEarned;
    }

    // Cumulative sum
    double cumulative = 0;
    return days.entries.map((e) {
      cumulative += e.value;
      return ChartDataPoint(
        label: e.key,
        value: cumulative,
        date:  now,
      );
    }).toList();
  }

  String _dayKey(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
}