import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message_model.dart';
import '../models/improvement_score_model.dart';
import '../repositories/coach_repository.dart';
import '../../dashboard/providers/step_provider.dart';
import '../../calories/providers/calorie_provider.dart';
import '../../history/providers/history_provider.dart';

final coachRepositoryProvider =
    Provider<CoachRepository>((_) => const CoachRepository());

// ── State ──────────────────────────────────────────────────────────────────────
class CoachState {
  final List<ChatMessage>      messages;
  final String                 streamingContent;
  final bool                   isStreaming;
  final bool                   historyLoading;
  final ImprovementScoreModel? scoreData;
  final bool                   scoreLoading;
  final String?                error;
  final bool                   clearingHistory;

  const CoachState({
    this.messages        = const [],
    this.streamingContent = '',
    this.isStreaming     = false,
    this.historyLoading  = false,
    this.scoreData,
    this.scoreLoading    = false,
    this.error,
    this.clearingHistory = false,
  });

  bool get hasMessages => messages.isNotEmpty;

  CoachState copyWith({
    List<ChatMessage>?      messages,
    String?                 streamingContent,
    bool?                   isStreaming,
    bool?                   historyLoading,
    ImprovementScoreModel?  scoreData,
    bool?                   scoreLoading,
    Object?                 error          = _s,
    bool?                   clearingHistory,
  }) => CoachState(
    messages:         messages          ?? this.messages,
    streamingContent: streamingContent  ?? this.streamingContent,
    isStreaming:      isStreaming        ?? this.isStreaming,
    historyLoading:   historyLoading     ?? this.historyLoading,
    scoreData:        scoreData          ?? this.scoreData,
    scoreLoading:     scoreLoading       ?? this.scoreLoading,
    error:            error == _s        ? this.error : error as String?,
    clearingHistory:  clearingHistory    ?? this.clearingHistory,
  );
}

const _s = Object();

// ── Notifier ───────────────────────────────────────────────────────────────────
class CoachNotifier extends StateNotifier<CoachState> {
  final CoachRepository _repo;
  final Ref ref;
  StreamSubscription<String>? _streamSub;

  CoachNotifier(this._repo, this.ref) : super(const CoachState()) {
    _loadAll();
  }

  Future<void> _loadAll() async {
    state = state.copyWith(
      historyLoading: true,
      scoreLoading:   true,
      error:          null,
    );

    // Load history and score in parallel
    final results = await Future.wait([
      _repo.getChatHistory().catchError((_) => <ChatMessage>[]),
      _repo.getImprovementScore().catchError((_) => null),
    ]);

    final history = results[0] as List<ChatMessage>;
    final score   = results[1] as ImprovementScoreModel?;

    state = state.copyWith(
      messages:       history,
      historyLoading: false,
      scoreData:      score,
      scoreLoading:   false,
    );
  }

  // ── Send message ───────────────────────────────────────────────────────────
  Future<void> sendMessage(String text, String userName) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isStreaming) return;

    // Add user message
    final userMsg = ChatMessage(
      role:      'user',
      content:   trimmed,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages:         [...state.messages, userMsg],
      isStreaming:      true,
      streamingContent: '',
      error:            null,
    );

    _streamSub?.cancel();
    final buffer = StringBuffer();
    
    String contextPrefix = "";
    try {
      final stepState = ref.read(stepProvider);
      final calState = ref.read(calorieProvider);
      final histState = ref.read(historyProvider);
      
      final steps = stepState.stepsToday;
      final target = stepState.targetSteps;
      final cals = calState.totals.calories;
      final protein = calState.totals.protein.toStringAsFixed(1);
      final carbs = calState.totals.carbs.toStringAsFixed(1);
      final fat = calState.totals.fat.toStringAsFixed(1);

      // Extract workouts completed today
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final todayWorkouts = histState.workouts.where((w) {
        final dt = w.completedDateTime;
        if (dt == null) return false;
        return dt.toIso8601String().split('T')[0] == todayStr;
      }).toList();

      String exercisesStr = "";
      if (todayWorkouts.isEmpty) {
        exercisesStr = "No exercises logged yet today.";
      } else {
        final names = <String>[];
        for (final w in todayWorkouts) {
          for (final ex in w.exercises) {
            names.add("${ex.exerciseName} (${ex.setsCompleted} sets x ${ex.repsCompleted} reps)");
          }
        }
        exercisesStr = names.join(", ");
      }
      
      contextPrefix = "User data for today:\n- Steps: $steps / $target target\n- Calories Consumed: $cals kcal (Protein: ${protein}g, Carbs: ${carbs}g, Fat: ${fat}g)\n- Exercises Completed Today: $exercisesStr";
    } catch (e) {
      print("Context extraction error: $e");
    }

    _streamSub = _repo.streamChat(trimmed, context: contextPrefix).listen(
      (delta) {
         print('DELTA RECEIVED: "$delta"');
        buffer.write(delta);
        state = state.copyWith(streamingContent: buffer.toString());
      },
      onDone: () {
         print('STREAM DONE. Buffer: "${buffer.toString()}"');
        final assistantMsg = ChatMessage(
          role:      'assistant',
          content:   buffer.toString(),
          timestamp: DateTime.now(),
        );
        state = state.copyWith(
          messages:         [...state.messages, assistantMsg],
          isStreaming:      false,
          streamingContent: '',
        );
      },
      onError: (e) {
        print('STREAM ERROR: $e');
        state = state.copyWith(
          isStreaming:      false,
          streamingContent: '',
          error:            e.toString(),
        );
      },
    );
  }

  // ── Clear history ──────────────────────────────────────────────────────────
  Future<void> clearHistory() async {
    state = state.copyWith(clearingHistory: true);
    await _repo.clearHistory().catchError((_) {});
    state = state.copyWith(
      messages:       [],
      clearingHistory: false,
    );
  }

  // ── Refresh score ──────────────────────────────────────────────────────────
  Future<void> refreshScore() async {
    state = state.copyWith(scoreLoading: true);
    try {
      final score = await _repo.getImprovementScore();
      state = state.copyWith(scoreData: score, scoreLoading: false);
    } catch (_) {
      state = state.copyWith(scoreLoading: false);
    }
  }

  // ── Cancel streaming ───────────────────────────────────────────────────────
  void cancelStream() {
    _streamSub?.cancel();
    state = state.copyWith(isStreaming: false, streamingContent: '');
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}

final coachProvider =
    StateNotifierProvider<CoachNotifier, CoachState>((ref) {
  return CoachNotifier(ref.watch(coachRepositoryProvider), ref);
});