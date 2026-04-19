import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise_model.dart';
import '../repositories/exercise_repository.dart';

// Repository
final exerciseRepositoryProvider =
    Provider<ExerciseRepository>((_) => const ExerciseRepository());

// ── State ──────────────────────────────────────────────────────────────────────
class ExerciseState {
  final List<ExerciseModel>   exercises;
  final List<ExerciseModel>   favorites;
  final ExerciseFiltersModel  filterOptions;
  final String                search;
  final String?               selectedBodyPart;
  final String?               selectedEquipment;
  final String?               selectedDifficulty;
  final int                   currentPage;
  final int                   totalPages;
  final bool                  loading;
  final bool                  loadingMore;
  final bool                  loadingFilters;
  final String?               error;
  final Set<String>           favoriteIds;
  final String                activeTab; // 'all' | 'favorites'

  const ExerciseState({
    this.exercises         = const [],
    this.favorites         = const [],
    this.filterOptions     = const ExerciseFiltersModel(
      bodyParts: [], equipment: [], targets: [], difficulties: []),
    this.search            = '',
    this.selectedBodyPart,
    this.selectedEquipment,
    this.selectedDifficulty,
    this.currentPage       = 1,
    this.totalPages        = 1,
    this.loading           = false,
    this.loadingMore       = false,
    this.loadingFilters    = false,
    this.error,
    this.favoriteIds       = const {},
    this.activeTab         = 'all',
  });

  bool get hasMore      => currentPage < totalPages;
  bool get hasActiveFilter =>
      selectedBodyPart   != null ||
      selectedEquipment  != null ||
      selectedDifficulty != null ||
      search.isNotEmpty;

  ExerciseState copyWith({
    List<ExerciseModel>?   exercises,
    List<ExerciseModel>?   favorites,
    ExerciseFiltersModel?  filterOptions,
    String?                search,
    Object?                selectedBodyPart  = _sentinel,
    Object?                selectedEquipment = _sentinel,
    Object?                selectedDifficulty= _sentinel,
    int?                   currentPage,
    int?                   totalPages,
    bool?                  loading,
    bool?                  loadingMore,
    bool?                  loadingFilters,
    Object?                error             = _sentinel,
    Set<String>?           favoriteIds,
    String?                activeTab,
  }) => ExerciseState(
    exercises:          exercises          ?? this.exercises,
    favorites:          favorites          ?? this.favorites,
    filterOptions:      filterOptions      ?? this.filterOptions,
    search:             search             ?? this.search,
    selectedBodyPart:   selectedBodyPart   == _sentinel
        ? this.selectedBodyPart   : selectedBodyPart   as String?,
    selectedEquipment:  selectedEquipment  == _sentinel
        ? this.selectedEquipment  : selectedEquipment  as String?,
    selectedDifficulty: selectedDifficulty == _sentinel
        ? this.selectedDifficulty : selectedDifficulty as String?,
    currentPage:        currentPage        ?? this.currentPage,
    totalPages:         totalPages         ?? this.totalPages,
    loading:            loading            ?? this.loading,
    loadingMore:        loadingMore        ?? this.loadingMore,
    loadingFilters:     loadingFilters     ?? this.loadingFilters,
    error:              error              == _sentinel
        ? this.error : error as String?,
    favoriteIds:        favoriteIds        ?? this.favoriteIds,
    activeTab:          activeTab          ?? this.activeTab,
  );
}

const _sentinel = Object();

// ── Notifier ───────────────────────────────────────────────────────────────────
class ExerciseNotifier extends StateNotifier<ExerciseState> {
  final ExerciseRepository _repo;
  Timer? _debounce;

  ExerciseNotifier(this._repo) : super(const ExerciseState()) {
    _loadFiltersAndExercises();
  }

  Future<void> _loadFiltersAndExercises() async {
    state = state.copyWith(loading: true, loadingFilters: true, error: null);
    try {
      final results = await Future.wait([
        _repo.getFilterOptions(),
        _repo.getExercises(page: 1),
        _repo.getFavorites(),
      ]);

      final filters   = results[0] as ExerciseFiltersModel;
      final exResult  = results[1]
          as ({List<ExerciseModel> exercises, int total, int totalPages});
      final favs      = results[2] as List<ExerciseModel>;

      state = state.copyWith(
        filterOptions:  filters,
        exercises:      exResult.exercises,
        totalPages:     exResult.totalPages,
        currentPage:    1,
        favorites:      favs,
        favoriteIds:    favs.map((f) => f.id).toSet(),
        loading:        false,
        loadingFilters: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false, loadingFilters: false,
        error: e.toString(),
      );
    }
  }

  // Debounced search
  void onSearchChanged(String query) {
    _debounce?.cancel();
    state = state.copyWith(search: query);
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchPage(1, replaceAll: true);
    });
  }

  void setBodyPart(String? value) {
    state = state.copyWith(selectedBodyPart: value);
    _fetchPage(1, replaceAll: true);
  }

  void setEquipment(String? value) {
    state = state.copyWith(selectedEquipment: value);
    _fetchPage(1, replaceAll: true);
  }

  void setDifficulty(String? value) {
    state = state.copyWith(selectedDifficulty: value);
    _fetchPage(1, replaceAll: true);
  }

  void clearFilters() {
    _debounce?.cancel();
    state = state.copyWith(
      search:             '',
      selectedBodyPart:   null,
      selectedEquipment:  null,
      selectedDifficulty: null,
    );
    _fetchPage(1, replaceAll: true);
  }

  void setTab(String tab) {
    state = state.copyWith(activeTab: tab);
    if (tab == 'favorites' && state.favorites.isEmpty) {
      _loadFavorites();
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore) return;
    await _fetchPage(state.currentPage + 1, replaceAll: false);
  }

  Future<void> refresh() => _loadFiltersAndExercises();

  Future<void> _loadFavorites() async {
    try {
      final favs = await _repo.getFavorites();
      state = state.copyWith(
        favorites:   favs,
        favoriteIds: favs.map((f) => f.id).toSet(),
      );
    } catch (_) {}
  }

  Future<void> _fetchPage(int page, {required bool replaceAll}) async {
    if (replaceAll) {
      state = state.copyWith(loading: true, error: null);
    } else {
      state = state.copyWith(loadingMore: true);
    }

    try {
      final result = await _repo.getExercises(
        search:     state.search,
        bodyPart:   state.selectedBodyPart,
        equipment:  state.selectedEquipment,
        difficulty: state.selectedDifficulty,
        page:       page,
      );

      final updated = replaceAll
          ? result.exercises
          : [...state.exercises, ...result.exercises];

      state = state.copyWith(
        exercises:   updated,
        currentPage: page,
        totalPages:  result.totalPages,
        loading:     false,
        loadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading:     false,
        loadingMore: false,
        error:       e.toString(),
      );
    }
  }

  Future<void> toggleFavorite(String exerciseId) async {
    // Optimistic update
    final ids    = Set<String>.from(state.favoriteIds);
    final isFav  = ids.contains(exerciseId);
    isFav ? ids.remove(exerciseId) : ids.add(exerciseId);
    state = state.copyWith(favoriteIds: ids);

    try {
      await _repo.toggleFavorite(exerciseId);
      // Refresh favorites list
      final favs = await _repo.getFavorites();
      state = state.copyWith(
        favorites:   favs,
        favoriteIds: favs.map((f) => f.id).toSet(),
      );
    } catch (_) {
      // Revert optimistic update on failure
      final revert = Set<String>.from(state.favoriteIds);
      isFav ? revert.add(exerciseId) : revert.remove(exerciseId);
      state = state.copyWith(favoriteIds: revert);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final exerciseProvider =
    StateNotifierProvider<ExerciseNotifier, ExerciseState>((ref) {
  return ExerciseNotifier(ref.watch(exerciseRepositoryProvider));
});