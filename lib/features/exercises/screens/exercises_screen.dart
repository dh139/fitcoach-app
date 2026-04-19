import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../providers/exercise_provider.dart';
import 'widgets/exercise_card.dart';
import 'widgets/exercise_detail_sheet.dart';
import 'widgets/exercise_search_bar.dart';
import 'widgets/exercises_empty_state.dart';
import 'widgets/filter_chips_row.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabCtrl;
  final ScrollController   _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        ref.read(exerciseProvider.notifier)
            .setTab(_tabCtrl.index == 0 ? 'all' : 'favorites');
      }
    });

    // Infinite scroll listener
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 300) {
        ref.read(exerciseProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [

          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned:          true,
            floating:        false,
            backgroundColor: AppColors.bg,
            expandedHeight:  0,
            toolbarHeight:   56,
            automaticallyImplyLeading: false,
            title: const Text('Exercise library', style: TextStyle(
              fontFamily:    'Inter',
              fontSize:      18,
              fontWeight:    FontWeight.w700,
              color:         AppColors.textPrimary,
              letterSpacing: -0.3,
            )),
            actions: [
              // Results count badge
              if (state.activeTab == 'all' && !state.loading)
                Center(child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        AppColors.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(color: AppColors.border3, width: 0.5),
                  ),
                  child: Text(
                    '${state.exercises.length} exercises',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(130),
              child: Container(
                color: AppColors.bg,
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pageHPad, 0,
                  AppConstants.pageHPad, 10,
                ),
                child: Column(children: [
                  // Search
                  ExerciseSearchBar(
                    initialValue: state.search,
                    onChanged: (v) => ref
                        .read(exerciseProvider.notifier)
                        .onSearchChanged(v),
                  ),
                  const SizedBox(height: 10),

                  // Filter chips
                  FilterChipsRow(
                    filters:             state.filterOptions,
                    selectedBodyPart:    state.selectedBodyPart,
                    selectedDifficulty:  state.selectedDifficulty,
                    selectedEquipment:   state.selectedEquipment,
                    onBodyPartChanged:   (v) => ref
                        .read(exerciseProvider.notifier).setBodyPart(v),
                    onDifficultyChanged: (v) => ref
                        .read(exerciseProvider.notifier).setDifficulty(v),
                    onEquipmentChanged:  (v) => ref
                        .read(exerciseProvider.notifier).setEquipment(v),
                    onClearAll: () => ref
                        .read(exerciseProvider.notifier).clearFilters(),
                  ),
                  const SizedBox(height: 10),

                  // Tabs
                  TabBar(
                    controller:         _tabCtrl,
                    indicatorColor:     AppColors.lime,
                    indicatorWeight:    2,
                    labelColor:         AppColors.lime,
                    unselectedLabelColor: AppColors.textTertiary,
                    indicatorSize:      TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(
                      fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      const Tab(text: 'All exercises'),
                      Tab(text: 'Favourites'
                          '${state.favoriteIds.isNotEmpty
                              ? ' (${state.favoriteIds.length})' : ''}'),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ],

        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── All exercises tab ──────────────────────────────────────────
            _AllExercisesTab(scrollCtrl: _scrollCtrl),

            // ── Favourites tab ─────────────────────────────────────────────
            const _FavouritesTab(),
          ],
        ),
      ),
    );
  }
}

// ── All exercises tab ──────────────────────────────────────────────────────────
class _AllExercisesTab extends ConsumerWidget {
  final ScrollController scrollCtrl;
  const _AllExercisesTab({required this.scrollCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exerciseProvider);

    if (state.loading && state.exercises.isEmpty) {
      return const Center(child: FCLoader());
    }

    if (state.error != null && state.exercises.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.textTertiary, size: 40),
          const SizedBox(height: 12),
          const Text('Failed to load exercises',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                ref.read(exerciseProvider.notifier).refresh(),
            child: const Text('Try again'),
          ),
        ],
      ));
    }

    if (state.exercises.isEmpty) {
      return ExercisesEmptyState(
        hasFilter: state.hasActiveFilter,
        onClear: () =>
            ref.read(exerciseProvider.notifier).clearFilters(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(exerciseProvider.notifier).refresh(),
      color:           AppColors.lime,
      backgroundColor: AppColors.surface1,
      child: GridView.builder(
        controller:  scrollCtrl,
        padding: const EdgeInsets.fromLTRB(
          AppConstants.pageHPad, 12,
          AppConstants.pageHPad, 100,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          crossAxisSpacing: 10,
          mainAxisSpacing:  10,
          childAspectRatio: 0.62,
        ),
        itemCount: state.exercises.length + (state.loadingMore ? 2 : 0),
        itemBuilder: (_, i) {
          // Loading shimmer cards at the bottom
          if (i >= state.exercises.length) {
            return Container(
              decoration: BoxDecoration(
                color:        AppColors.surface2,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }

          final ex = state.exercises[i];
          return ExerciseCard(
            exercise:    ex,
            isFavorited: state.favoriteIds.contains(ex.id),
            onTap: () => ExerciseDetailSheet.show(context, ex),
            onFavoriteTap: () => ref
                .read(exerciseProvider.notifier)
                .toggleFavorite(ex.id),
          );
        },
      ),
    );
  }
}

// ── Favourites tab ─────────────────────────────────────────────────────────────
class _FavouritesTab extends ConsumerWidget {
  const _FavouritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exerciseProvider);

    if (state.favorites.isEmpty) {
      return const ExercisesEmptyState(
        hasFilter: false,
        onClear: _noop,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.pageHPad, 12,
        AppConstants.pageHPad, 100,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 10,
        mainAxisSpacing:  10,
        childAspectRatio: 0.62,
      ),
      itemCount: state.favorites.length,
      itemBuilder: (_, i) {
        final ex = state.favorites[i];
        return ExerciseCard(
          exercise:    ex,
          isFavorited: true,
          onTap: () => ExerciseDetailSheet.show(context, ex),
          onFavoriteTap: () => ref
              .read(exerciseProvider.notifier)
              .toggleFavorite(ex.id),
        );
      },
    );
  }
}

void _noop() {}