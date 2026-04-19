import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_history_model.dart';
import '../repositories/history_repository.dart';

final historyRepositoryProvider =
    Provider<HistoryRepository>((_) => const HistoryRepository());

class HistoryState {
  final List<WorkoutHistoryModel> workouts;
  final List<ChartDataPoint>      frequencyData;
  final List<ChartDataPoint>      calorieData;
  final List<ChartDataPoint>      xpData;
  final bool                      loading;
  final bool                      loadingMore;
  final int                       currentPage;
  final int                       totalPages;
  final String?                   error;

  const HistoryState({
    this.workouts      = const [],
    this.frequencyData = const [],
    this.calorieData   = const [],
    this.xpData        = const [],
    this.loading       = false,
    this.loadingMore   = false,
    this.currentPage   = 1,
    this.totalPages    = 1,
    this.error,
  });

  bool get hasMore  => currentPage < totalPages;
  bool get hasData  => workouts.isNotEmpty;

  HistoryState copyWith({
    List<WorkoutHistoryModel>? workouts,
    List<ChartDataPoint>?      frequencyData,
    List<ChartDataPoint>?      calorieData,
    List<ChartDataPoint>?      xpData,
    bool?                      loading,
    bool?                      loadingMore,
    int?                       currentPage,
    int?                       totalPages,
    Object?                    error = _s,
  }) => HistoryState(
    workouts:      workouts      ?? this.workouts,
    frequencyData: frequencyData ?? this.frequencyData,
    calorieData:   calorieData   ?? this.calorieData,
    xpData:        xpData        ?? this.xpData,
    loading:       loading       ?? this.loading,
    loadingMore:   loadingMore   ?? this.loadingMore,
    currentPage:   currentPage   ?? this.currentPage,
    totalPages:    totalPages    ?? this.totalPages,
    error:         error == _s   ? this.error : error as String?,
  );
}

const _s = Object();

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repo;

  HistoryNotifier(this._repo) : super(const HistoryState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final result = await _repo.getWorkoutHistory(page: 1);
      final ws     = result.workouts;
      state = state.copyWith(
        loading:       false,
        workouts:      ws,
        totalPages:    result.totalPages,
        currentPage:   1,
        frequencyData: _repo.buildFrequencyData(ws),
        calorieData:   _repo.buildCalorieData(ws),
        xpData:        _repo.buildXpData(ws),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore) return;
    state = state.copyWith(loadingMore: true);
    try {
      final result  = await _repo.getWorkoutHistory(
          page: state.currentPage + 1);
      final updated = [...state.workouts, ...result.workouts];
      state = state.copyWith(
        loadingMore:   false,
        workouts:      updated,
        currentPage:   state.currentPage + 1,
        frequencyData: _repo.buildFrequencyData(updated),
        calorieData:   _repo.buildCalorieData(updated),
        xpData:        _repo.buildXpData(updated),
      );
    } catch (_) {
      state = state.copyWith(loadingMore: false);
    }
  }

  Future<void> refresh() => load();
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref.watch(historyRepositoryProvider));
});