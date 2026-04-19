import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rival_model.dart';
import '../repositories/rival_repository.dart';

final rivalRepositoryProvider =
    Provider<RivalRepository>((_) => const RivalRepository());

class RivalState {
  final List<RivalModel>      rivals;
  final List<RivalSuggestion> suggestions;
  final bool                  loading;
  final bool                  actionLoading;
  final String?               error;
  final String?               successMessage;

  const RivalState({
    this.rivals         = const [],
    this.suggestions    = const [],
    this.loading        = false,
    this.actionLoading  = false,
    this.error,
    this.successMessage,
  });

  List<RivalModel> get pending  =>
      rivals.where((r) => r.isPending).toList();
  List<RivalModel> get active   =>
      rivals.where((r) => r.isActive).toList();
  List<RivalModel> get finished =>
      rivals.where((r) => r.isCompleted).toList();

  RivalState copyWith({
    List<RivalModel>?      rivals,
    List<RivalSuggestion>? suggestions,
    bool?                  loading,
    bool?                  actionLoading,
    Object?                error          = _s,
    Object?                successMessage = _s,
  }) => RivalState(
    rivals:         rivals         ?? this.rivals,
    suggestions:    suggestions    ?? this.suggestions,
    loading:        loading        ?? this.loading,
    actionLoading:  actionLoading  ?? this.actionLoading,
    error:          error == _s    ? this.error          : error          as String?,
    successMessage: successMessage == _s
        ? this.successMessage : successMessage as String?,
  );
}

const _s = Object();

class RivalNotifier extends StateNotifier<RivalState> {
  final RivalRepository _repo;

  RivalNotifier(this._repo) : super(const RivalState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await Future.wait([
        _repo.getMyRivals(),
        _repo.getSuggestions(),
      ]);
      state = state.copyWith(
        loading:     false,
        rivals:      results[0] as List<RivalModel>,
        suggestions: results[1] as List<RivalSuggestion>,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> challenge({
    required String userId,
    required String metric,
    required int    duration,
  }) async {
    state = state.copyWith(actionLoading: true, error: null);
    try {
      await _repo.challengeUser(
          userId: userId, metric: metric, duration: duration);
      state = state.copyWith(
        actionLoading:  false,
        successMessage: 'Challenge sent!',
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(
          actionLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> respond(String rivalId, bool accept) async {
    state = state.copyWith(actionLoading: true);
    try {
      await _repo.respondToRival(rivalId: rivalId, accept: accept);
      state = state.copyWith(
        actionLoading:  false,
        successMessage: accept ? 'Challenge accepted!' : 'Challenge declined',
      );
      await load();
    } catch (e) {
      state = state.copyWith(
          actionLoading: false, error: e.toString());
    }
  }

  void clearMessage() =>
      state = state.copyWith(successMessage: null, error: null);
}

final rivalProvider =
    StateNotifierProvider<RivalNotifier, RivalState>((ref) {
  return RivalNotifier(ref.watch(rivalRepositoryProvider));
});