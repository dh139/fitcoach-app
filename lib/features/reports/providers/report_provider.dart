import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../repositories/report_repository.dart';

final reportRepositoryProvider =
    Provider<ReportRepository>((_) => const ReportRepository());

class ReportState {
  final Map<String, ReportModel> cache;        // type -> report
  final Map<String, bool>        loading;      // type -> bool
  final Map<String, String?>     errors;       // type -> error
  final String                   activeType;
  final bool                     regenerating;

  const ReportState({
    this.cache       = const {},
    this.loading     = const {},
    this.errors      = const {},
    this.activeType  = 'weekly',
    this.regenerating = false,
  });

  ReportModel? get current => cache[activeType];
  bool    isLoading(String type) => loading[type] ?? false;
  String? getError(String type)  => errors[type];

  ReportState copyWith({
    Map<String, ReportModel>? cache,
    Map<String, bool>?        loading,
    Map<String, String?>?     errors,
    String?                   activeType,
    bool?                     regenerating,
  }) => ReportState(
    cache:        cache        ?? this.cache,
    loading:      loading      ?? this.loading,
    errors:       errors       ?? this.errors,
    activeType:   activeType   ?? this.activeType,
    regenerating: regenerating ?? this.regenerating,
  );
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportRepository _repo;

  ReportNotifier(this._repo) : super(const ReportState()) {
    // Pre-load weekly on init
    loadReport('weekly');
  }

  Future<void> setType(String type) async {
    state = state.copyWith(activeType: type);
    if (!state.cache.containsKey(type)) {
      await loadReport(type);
    }
  }

  Future<void> loadReport(String type, {bool refresh = false}) async {
    // Mark loading
    state = state.copyWith(
      loading: {...state.loading, type: true},
      errors:  {...state.errors,  type: null},
      regenerating: refresh,
    );
    try {
      final report = await _repo.getReport(type, refresh: refresh);
      state = state.copyWith(
        cache:        {...state.cache,   type: report},
        loading:      {...state.loading, type: false},
        regenerating: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading:      {...state.loading, type: false},
        errors:       {...state.errors,  type: e.toString()},
        regenerating: false,
      );
    }
  }

  Future<void> regenerate() =>
      loadReport(state.activeType, refresh: true);
}

final reportProvider =
    StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.watch(reportRepositoryProvider));
});