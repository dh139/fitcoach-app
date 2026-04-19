import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/xp_log_model.dart';
import '../models/xp_profile_model.dart';
import '../models/workout_stats_model.dart';
import '../repositories/xp_repository.dart';

// Repository provider
final xpRepositoryProvider =
    Provider<XpRepository>((ref) => const XpRepository());

// ── Dashboard state ────────────────────────────────────────────────────────────
class DashboardState {
  final XpProfileModel?    xpProfile;
  final WorkoutStatsModel? stats;
  final List<XpLogModel>   xpHistory;
  final bool               loading;
  final String?            error;
  final bool               freezeLoading;

  const DashboardState({
    this.xpProfile,
    this.stats,
    this.xpHistory     = const [],
    this.loading       = false,
    this.error,
    this.freezeLoading = false,
  });

  DashboardState copyWith({
    XpProfileModel?    xpProfile,
    WorkoutStatsModel? stats,
    List<XpLogModel>?  xpHistory,
    bool?              loading,
    String?            error,
    bool?              freezeLoading,
  }) => DashboardState(
    xpProfile:     xpProfile     ?? this.xpProfile,
    stats:         stats         ?? this.stats,
    xpHistory:     xpHistory     ?? this.xpHistory,
    loading:       loading       ?? this.loading,
    error:         error,
    freezeLoading: freezeLoading ?? this.freezeLoading,
  );

  bool get hasData => xpProfile != null && stats != null;
}

// ── Dashboard notifier ─────────────────────────────────────────────────────────
class DashboardNotifier extends StateNotifier<DashboardState> {
  final XpRepository _repo;

  DashboardNotifier(this._repo) : super(const DashboardState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      // Fetch all three in parallel
      final results = await Future.wait([
        _repo.getXpProfile(),
        _repo.getWorkoutStats(),
        _repo.getXpHistory(limit: 10),
      ]);

      state = state.copyWith(
        loading:    false,
        xpProfile:  results[0] as XpProfileModel,
        stats:      results[1] as WorkoutStatsModel,
        xpHistory:  results[2] as List<XpLogModel>,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refresh() => load();

  Future<bool> useStreakFreeze() async {
    state = state.copyWith(freezeLoading: true);
    try {
      await _repo.useStreakFreeze();
      await load(); // reload to get updated streak info
      return true;
    } catch (_) {
      state = state.copyWith(freezeLoading: false);
      return false;
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(xpRepositoryProvider));
});