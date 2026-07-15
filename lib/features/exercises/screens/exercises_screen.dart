import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../providers/exercise_provider.dart';
import 'widgets/exercise_card.dart';
import 'widgets/exercise_detail_sheet.dart';
import 'widgets/exercises_empty_state.dart';
import '../../workout/providers/workout_provider.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabCtrl;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() {}); // rebuild for custom tab indicator
        ref.read(exerciseProvider.notifier)
            .setTab(_tabCtrl.index == 0 ? 'all' : 'favorites');
      }
    });
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
    final selected = ref.watch(workoutProvider).selectedExercises;

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: selected.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.extended(
                onPressed: () {
                  ref.read(workoutProvider.notifier).startSession();
                  context.go('/workout');
                },
                backgroundColor: AppColors.lime,
                foregroundColor: AppColors.onLime,
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: Text(
                  'Start Workout  ·  ${selected.length}',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: AppColors.bg,
            surfaceTintColor: AppColors.bg,
            shadowColor: Colors.black12,
            forceElevated: true,
            elevation: 0,
            expandedHeight: 0,
            toolbarHeight: 68,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // Icon box
                
                const SizedBox(width: 12),
                // Title + subtitle
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Exercise Library',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        'Discover 500+ professional exercises',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(228),
              child: _ExercisesHeader(
                state: state,
                onSearchChanged: (v) =>
                    ref.read(exerciseProvider.notifier).onSearchChanged(v),
                onBodyPartChanged: (v) =>
                    ref.read(exerciseProvider.notifier).setBodyPart(v),
                onDifficultyChanged: (v) =>
                    ref.read(exerciseProvider.notifier).setDifficulty(v),
                onEquipmentChanged: (v) =>
                    ref.read(exerciseProvider.notifier).setEquipment(v),
                onClearFilters: () =>
                    ref.read(exerciseProvider.notifier).clearFilters(),
                tabCtrl: _tabCtrl,
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _AllExercisesTab(scrollCtrl: _scrollCtrl),
            const _FavouritesTab(),
          ],
        ),
      ),
    );
  }
}

// ── Header (pinned under SliverAppBar) ──────────────────────────────────────
class _ExercisesHeader extends StatelessWidget {
  final dynamic state;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onBodyPartChanged;
  final ValueChanged<String?> onDifficultyChanged;
  final ValueChanged<String?> onEquipmentChanged;
  final VoidCallback onClearFilters;
  final TabController tabCtrl;

  const _ExercisesHeader({
    required this.state,
    required this.onSearchChanged,
    required this.onBodyPartChanged,
    required this.onDifficultyChanged,
    required this.onEquipmentChanged,
    required this.onClearFilters,
    required this.tabCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.fromLTRB(
          AppConstants.pageHPad, 6, AppConstants.pageHPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──────────────────────────────────────────────
          _SearchBar(
            initialValue: state.search as String,
            onChanged: onSearchChanged,
            onFilterTap: onClearFilters,
            hasActiveFilter: state.hasActiveFilter as bool,
          ),
          const SizedBox(height: 14),

          // ── Body part chips ─────────────────────────────────────────
          _BodyPartChips(
            selectedBodyPart: state.selectedBodyPart as String?,
            onChanged: onBodyPartChanged,
          ),
          const SizedBox(height: 12),

          // ── Difficulty pill row ─────────────────────────────────────
          _DifficultyRow(
            selectedDifficulty: state.selectedDifficulty as String?,
            onChanged: onDifficultyChanged,
          ),
          const SizedBox(height: 12),

          // ── Custom tab bar ──────────────────────────────────────────
          _ExerciseTabBar(
            tabCtrl: tabCtrl,
            allCount: (state.exercises as List).length,
            favCount: (state.favoriteIds as Set).length,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Premium Search Bar ───────────────────────────────────────────────────────
class _SearchBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilter;

  const _SearchBar({
    required this.initialValue,
    required this.onChanged,
    required this.onFilterTap,
    required this.hasActiveFilter,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Search field
      Expanded(
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border2, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded,
                size: 20, color: AppColors.textTertiary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: widget.onChanged,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search exercises, body parts...',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ]),
        ),
      ),

      const SizedBox(width: 10),

      // Filter button
      GestureDetector(
        onTap: widget.onFilterTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: widget.hasActiveFilter
                ? AppColors.textPrimary
                : AppColors.surface1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.hasActiveFilter
                  ? AppColors.textPrimary
                  : AppColors.border2,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.hasActiveFilter
                    ? AppColors.textPrimary.withAlpha(40)
                    : Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.tune_rounded,
            size: 20,
            color: widget.hasActiveFilter
                ? Colors.white
                : AppColors.textSecondary,
          ),
        ),
      ),
    ]);
  }
}

// ── Body Part Category Chips ─────────────────────────────────────────────────
class _BodyPartChips extends StatelessWidget {
  final String? selectedBodyPart;
  final ValueChanged<String?> onChanged;

  // (bodyPartKey, displayLabel, icon, accentColor)
  static const _categories = [
    ('chest',       'Chest',     Icons.self_improvement_rounded,      Color(0xFFFF7A8A)),
    ('back',        'Back',      Icons.accessibility_new_rounded,     AppColors.primary),
    ('shoulders',   'Shoulders', Icons.sports_gymnastics_rounded,     Color(0xFFFFB547)),
    ('upper legs',  'Legs',      Icons.directions_walk_rounded,       Color(0xFF34C7A8)),
    ('upper arms',  'Arms',      Icons.fitness_center_rounded,        AppColors.primary),
    ('cardio',      'Cardio',    Icons.monitor_heart_rounded,         AppColors.accent5),
    ('waist',       'Waist',     Icons.directions_run_rounded,        Color(0xFFFFB547)),
  ];

  const _BodyPartChips({required this.selectedBodyPart, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final key = cat.$1;
          final label = cat.$2;
          final icon = cat.$3;
          final color = cat.$4;
          final isSelected =
              selectedBodyPart?.toLowerCase() == key.toLowerCase();

          return GestureDetector(
            onTap: () => onChanged(isSelected ? null : key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 68,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withAlpha(20)
                    : AppColors.surface1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : AppColors.border2,
                  width: isSelected ? 1.5 : 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? color.withAlpha(25)
                        : Colors.black.withAlpha(6),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon in a rounded square
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withAlpha(30)
                          : color.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon,
                        color: color,
                        size: 20),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Difficulty Filter Pills ───────────────────────────────────────────────────
class _DifficultyRow extends StatelessWidget {
  final String? selectedDifficulty;
  final ValueChanged<String?> onChanged;

  static const _options = [
    ('',             'All'),
    ('beginner',     'Beginner'),
    ('intermediate', 'Intermediate'),
    ('advanced',     'Advanced'),
  ];

  const _DifficultyRow({
    required this.selectedDifficulty,
    required this.onChanged,
  });

  Color _pillColor(String val) {
    switch (val) {
      case 'beginner':     return AppColors.beginner;
      case 'intermediate': return AppColors.primary;
      case 'advanced':     return AppColors.advanced;
      default:             return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final key = _options[i].$1;
          final label = _options[i].$2;
          final isAll = key.isEmpty;
          final isSelected = isAll
              ? (selectedDifficulty == null || selectedDifficulty!.isEmpty)
              : selectedDifficulty == key;
          final color = isAll ? AppColors.textSecondary : _pillColor(key);

          return GestureDetector(
            onTap: () => onChanged(isAll ? null : (isSelected ? null : key)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.surface1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : AppColors.border2,
                  width: isSelected ? 0 : 0.8,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withAlpha(40), blurRadius: 8, offset: const Offset(0, 2))]
                    : [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4)],
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Custom Exercise Tab Bar ──────────────────────────────────────────────────
class _ExerciseTabBar extends StatelessWidget {
  final TabController tabCtrl;
  final int allCount, favCount;

  const _ExerciseTabBar({
    required this.tabCtrl,
    required this.allCount,
    required this.favCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: tabCtrl,
          indicator: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withAlpha(30),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: const TextStyle(
              fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(
              fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All Exercises'),
                  if (allCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$allCount',
                        style: const TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Favorites'),
                  if (favCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.surface3,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$favCount',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── All Exercises Tab ────────────────────────────────────────────────────────
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent2Dim,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.danger, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load exercises',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => ref.read(exerciseProvider.notifier).refresh(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state.exercises.isEmpty) {
      return ExercisesEmptyState(
        hasFilter: state.hasActiveFilter,
        onClear: () => ref.read(exerciseProvider.notifier).clearFilters(),
      );
    }

    return GridView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(
          AppConstants.pageHPad, 14, AppConstants.pageHPad, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: state.exercises.length + (state.loadingMore ? 2 : 0),
      itemBuilder: (_, i) {
        if (i >= state.exercises.length) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border1),
            ),
          );
        }
        final ex = state.exercises[i];
        final isSelected = ref.watch(workoutProvider.select(
            (s) => s.selectedExercises.any((e) => e.id == ex.id)));
        return ExerciseCard(
          exercise: ex,
          isFavorited: state.favoriteIds.contains(ex.id),
          isSelected: isSelected,
          onTap: () => ExerciseDetailSheet.show(context, ex),
          onFavoriteTap: () =>
              ref.read(exerciseProvider.notifier).toggleFavorite(ex.id),
          onSelectTap: () =>
              ref.read(workoutProvider.notifier).toggleExercise(ex),
        );
      },
    );
  }
}

// ── Favourites Tab ───────────────────────────────────────────────────────────
class _FavouritesTab extends ConsumerWidget {
  const _FavouritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exerciseProvider);

    if (state.favorites.isEmpty) {
      return const _EmptyFavorites();
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppConstants.pageHPad, 14, AppConstants.pageHPad, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: state.favorites.length,
      itemBuilder: (_, i) {
        final ex = state.favorites[i];
        final isSelected = ref.watch(workoutProvider.select(
            (s) => s.selectedExercises.any((e) => e.id == ex.id)));
        return ExerciseCard(
          exercise: ex,
          isFavorited: true,
          isSelected: isSelected,
          onTap: () => ExerciseDetailSheet.show(context, ex),
          onFavoriteTap: () =>
              ref.read(exerciseProvider.notifier).toggleFavorite(ex.id),
          onSelectTap: () =>
              ref.read(workoutProvider.notifier).toggleExercise(ex),
        );
      },
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryDim,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.favorite_border_rounded,
                color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No favourites yet',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap ♥ on any exercise to save it here',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
