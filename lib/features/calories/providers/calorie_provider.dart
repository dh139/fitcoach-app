import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_summary_model.dart';
import '../models/food_log_model.dart';
import '../models/food_search_result.dart';
         // ← Added if MacroTotals is in separate file
import '../repositories/calorie_repository.dart';

// ── Helper ─────────────────────────────────────────────────────────────────────
String _localDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ── State ──────────────────────────────────────────────────────────────────────
class CalorieState {
  final String selectedDate;
  final DailySummaryModel? daySummary;
  final List<FoodLogModel> entries;
  final List<WeeklyDayModel> weekly;
  final bool loading;
  final bool weeklyLoading;
  final String? error;

  // Search
  final String searchQuery;
  final List<FoodSearchResult> searchResults;
  final bool searchLoading;

  // Photo
  final PhotoAnalysisResult? photoResult;
  final bool photoLoading;
  final String? photoError;

  // Adding
  final bool addingFood;

  const CalorieState({
    required this.selectedDate,
    this.daySummary,
    this.entries = const [],
    this.weekly = const [],
    this.loading = false,
    this.weeklyLoading = false,
    this.error,
    this.searchQuery = '',
    this.searchResults = const [],
    this.searchLoading = false,
    this.photoResult,
    this.photoLoading = false,
    this.photoError,
    this.addingFood = false,
  });

  static CalorieState initial() => CalorieState(
        selectedDate: _localDate(DateTime.now()),
      );

  MacroTotals get totals => daySummary?.totals ?? MacroTotals.zero;

  bool get isToday => selectedDate == _localDate(DateTime.now());

  CalorieState copyWith({
    String? selectedDate,
    DailySummaryModel? daySummary,
    List<FoodLogModel>? entries,
    List<WeeklyDayModel>? weekly,
    bool? loading,
    bool? weeklyLoading,
    Object? error = _s,
    String? searchQuery,
    List<FoodSearchResult>? searchResults,
    bool? searchLoading,
    Object? photoResult = _s,
    bool? photoLoading,
    Object? photoError = _s,
    bool? addingFood,
  }) =>
      CalorieState(
        selectedDate: selectedDate ?? this.selectedDate,
        daySummary: daySummary ?? this.daySummary,
        entries: entries ?? this.entries,
        weekly: weekly ?? this.weekly,
        loading: loading ?? this.loading,
        weeklyLoading: weeklyLoading ?? this.weeklyLoading,
        error: error == _s ? this.error : error as String?,
        searchQuery: searchQuery ?? this.searchQuery,
        searchResults: searchResults ?? this.searchResults,
        searchLoading: searchLoading ?? this.searchLoading,
        photoResult: photoResult == _s
            ? this.photoResult
            : photoResult as PhotoAnalysisResult?,
        photoLoading: photoLoading ?? this.photoLoading,
        photoError:
            photoError == _s ? this.photoError : photoError as String?,
        addingFood: addingFood ?? this.addingFood,
      );
}

const _s = Object(); // sentinel

// ── Notifier ───────────────────────────────────────────────────────────────────
class CalorieNotifier extends StateNotifier<CalorieState> {
  final CalorieRepository _repo;
  Timer? _searchDebounce;

  CalorieNotifier(this._repo) : super(CalorieState.initial()) {
    loadDay(state.selectedDate);
    loadWeekly();
  }

  // ── Day Navigation ─────────────────────────────────────────────────────────
  Future<void> goToDate(String date) async {
    final today = _localDate(DateTime.now());
    if (date.compareTo(today) > 0) return; // no future dates
    state = state.copyWith(selectedDate: date);
    await loadDay(date);
  }

  void goBack() {
    final d = DateTime.parse(state.selectedDate);
    final prev = d.subtract(const Duration(days: 1));
    goToDate(_localDate(prev));
  }

  void goForward() {
    final d = DateTime.parse(state.selectedDate);
    final next = d.add(const Duration(days: 1));
    goToDate(_localDate(next));
  }

  // ── Load Data ──────────────────────────────────────────────────────────────
  Future<void> loadDay(String date) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final summary = await _repo.getDayLog(date);

      // Extract all entries from byMeal map
      final all = <FoodLogModel>[];
      for (final meal in summary.byMeal.values) {
        if (meal is List) {
          all.addAll(meal.map((e) =>
              FoodLogModel.fromJson(e as Map<String, dynamic>)));
        }
      }

      state = state.copyWith(
        loading: false,
        daySummary: summary,
        entries: all,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadWeekly() async {
    state = state.copyWith(weeklyLoading: true);
    try {
      final weekly = await _repo.getWeeklySummary();
      state = state.copyWith(weeklyLoading: false, weekly: weekly);
    } catch (_) {
      state = state.copyWith(weeklyLoading: false);
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 420), () async {
      state = state.copyWith(searchLoading: true);
      try {
        final results = await _repo.searchFood(query.trim());
        state = state.copyWith(
            searchResults: results, searchLoading: false);
      } catch (_) {
        state = state.copyWith(searchLoading: false);
      }
    });
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    state = state.copyWith(
      searchQuery: '',
      searchResults: [],
      searchLoading: false,
    );
  }

  // ── Photo Analysis ─────────────────────────────────────────────────────────
  Future<void> analyzePhoto({
    required String base64Image,
    required String mimeType,
    String description = '',
  }) async {
    state = state.copyWith(
        photoLoading: true, photoResult: null, photoError: null);
    try {
      final result = await _repo.analyzePhoto(
        base64Image: base64Image,
        mimeType: mimeType,
        description: description,
      );
      if (result.success) {
        state = state.copyWith(photoLoading: false, photoResult: result);
      } else {
        state = state.copyWith(
          photoLoading: false,
          photoError: result.message ?? 'Analysis failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
          photoLoading: false, photoError: e.toString());
    }
  }

  void clearPhotoResult() => state = state.copyWith(
        photoResult: null,
        photoError: null,
      );

  // ── Add Food ───────────────────────────────────────────────────────────────
  Future<bool> addFood({
    required String name,
    required int calories,
    String brand = '',
    double quantity = 1.0,
    String unit = 'serving',
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    double fiber = 0,
    String mealType = 'snack',
    String source = 'manual',
    String aiAnalysis = '',
  }) async {
    state = state.copyWith(addingFood: true);
    try {
      await _repo.logFood(
        name: name,
        calories: calories,
        brand: brand,
        quantity: quantity,
        unit: unit,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: fiber,
        mealType: mealType,
        source: source,
        loggedDate: state.selectedDate,
        aiAnalysis: aiAnalysis,
      );

      state = state.copyWith(addingFood: false);
      await loadDay(state.selectedDate);
      await loadWeekly();
      return true;
    } catch (_) {
      state = state.copyWith(addingFood: false);
      return false;
    }
  }

  // ── Delete Entry ───────────────────────────────────────────────────────────
  Future<void> deleteEntry(String id) async {
    try {
      await _repo.deleteEntry(id);
      await loadDay(state.selectedDate);
      await loadWeekly();
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────
final calorieProvider = StateNotifierProvider<CalorieNotifier, CalorieState>(
  (ref) => CalorieNotifier(ref.watch(calorieRepositoryProvider)),
);

final calorieRepositoryProvider =
    Provider<CalorieRepository>((_) => const CalorieRepository());