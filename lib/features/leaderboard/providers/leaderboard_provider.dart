import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../repositories/leaderboard_repository.dart';

final leaderboardRepositoryProvider =
    Provider<LeaderboardRepository>((_) => const LeaderboardRepository());

class LeaderboardState {
  final Map<String, LeaderboardData> cache; // period -> data
  final List<MyPeriodRank>           myStats;
  final String                       activePeriod;
  final bool                         loading;
  final bool                         refreshing;
  final String?                      error;

  const LeaderboardState({
    this.cache        = const {},
    this.myStats      = const [],
    this.activePeriod = 'weekly',
    this.loading      = false,
    this.refreshing   = false,
    this.error,
  });

  LeaderboardData? get current => cache[activePeriod];

  LeaderboardState copyWith({
    Map<String, LeaderboardData>? cache,
    List<MyPeriodRank>?           myStats,
    String?                       activePeriod,
    bool?                         loading,
    bool?                         refreshing,
    Object?                       error = _s,
  }) => LeaderboardState(
    cache:        cache        ?? this.cache,
    myStats:      myStats      ?? this.myStats,
    activePeriod: activePeriod ?? this.activePeriod,
    loading:      loading      ?? this.loading,
    refreshing:   refreshing   ?? this.refreshing,
    error:        error == _s  ? this.error : error as String?,
  );
}

const _s = Object();

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final LeaderboardRepository _repo;

  LeaderboardNotifier(this._repo) : super(const LeaderboardState()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await Future.wait([
        _repo.getLeaderboard(period: 'weekly'),
        _repo.getMyStats(),
      ]);
      final lb      = results[0] as LeaderboardData;
      final myStats = results[1] as List<MyPeriodRank>;
      state = state.copyWith(
        loading:  false,
        myStats:  myStats,
        cache:    {'weekly': lb},
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> setPeriod(String period) async {
    if (state.activePeriod == period) return;
    state = state.copyWith(activePeriod: period);
    // Load from cache or fetch
    if (state.cache.containsKey(period)) return;
    await _fetchPeriod(period);
  }

  Future<void> _fetchPeriod(String period) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _repo.getLeaderboard(period: period);
      final updated = Map<String, LeaderboardData>.from(state.cache)
        ..[period] = data;
      state = state.copyWith(loading: false, cache: updated);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(refreshing: true, error: null);
    try {
      final results = await Future.wait([
        _repo.getLeaderboard(period: state.activePeriod),
        _repo.getMyStats(),
      ]);
      final lb = results[0] as LeaderboardData;
      final my = results[1] as List<MyPeriodRank>;
      final updated = Map<String, LeaderboardData>.from(state.cache)
        ..[state.activePeriod] = lb;
      state = state.copyWith(
        refreshing: false,
        cache:      updated,
        myStats:    my,
      );
    } catch (e) {
      state = state.copyWith(refreshing: false, error: e.toString());
    }
  }
}

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier(ref.watch(leaderboardRepositoryProvider));
});