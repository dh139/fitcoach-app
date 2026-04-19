import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../repositories/challenge_repository.dart';

final challengeRepositoryProvider =
    Provider<ChallengeRepository>((_) => const ChallengeRepository());

class ChallengeState {
  final List<ChallengeModel> challenges;
  final bool                 loading;
  final bool                 claiming;
  final String?              error;
  final String?              claimedMessage;
  final int?                 claimedXP;

  const ChallengeState({
    this.challenges    = const [],
    this.loading       = false,
    this.claiming      = false,
    this.error,
    this.claimedMessage,
    this.claimedXP,
  });

  List<ChallengeModel> get daily =>
      challenges.where((c) => c.type == 'daily').toList();
  List<ChallengeModel> get weekly =>
      challenges.where((c) => c.type == 'weekly').toList();
  int get pendingCount =>
      challenges.where((c) => c.canClaim).length;

  ChallengeState copyWith({
    List<ChallengeModel>? challenges,
    bool?                 loading,
    bool?                 claiming,
    Object?               error          = _s,
    Object?               claimedMessage = _s,
    Object?               claimedXP      = _s,
  }) => ChallengeState(
    challenges:     challenges     ?? this.challenges,
    loading:        loading        ?? this.loading,
    claiming:       claiming       ?? this.claiming,
    error:          error == _s    ? this.error          : error          as String?,
    claimedMessage: claimedMessage == _s ? this.claimedMessage : claimedMessage as String?,
    claimedXP:      claimedXP     == _s  ? this.claimedXP      : claimedXP      as int?,
  );
}

const _s = Object();

class ChallengeNotifier extends StateNotifier<ChallengeState> {
  final ChallengeRepository _repo;

  ChallengeNotifier(this._repo) : super(const ChallengeState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _repo.getChallenges();
      state = state.copyWith(loading: false, challenges: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> claim(String id) async {
    state = state.copyWith(
        claiming: true, claimedMessage: null, claimedXP: null);
    try {
      final result = await _repo.claimChallenge(id);
      // Mark claimed in local list
      final updated = state.challenges.map((c) =>
          c.id == id ? ChallengeModel.fromJson({
            '_id': c.id, 'title': c.title,
            'description': c.description,
            'type': c.type, 'category': c.category,
            'target': c.target, 'current': c.current,
            'xpReward': c.xpReward,
            'completed': true, 'claimed': true,
            'createdAt': c.createdAt,
          }) : c).toList();
      state = state.copyWith(
        claiming:       false,
        challenges:     updated,
        claimedMessage: result.message,
        claimedXP:      result.xpEarned,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          claiming: false, error: e.toString());
      return false;
    }
  }

  void clearClaimed() => state = state.copyWith(
    claimedMessage: null, claimedXP: null,
  );
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, ChallengeState>((ref) {
  return ChallengeNotifier(ref.watch(challengeRepositoryProvider));
});