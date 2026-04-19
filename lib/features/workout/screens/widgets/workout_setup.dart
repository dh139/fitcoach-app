import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/exercises/models/exercise_model.dart';
import '../../../../features/exercises/providers/exercise_provider.dart';
import '../../../../features/exercises/screens/widgets/exercise_gif_view.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../../../shared/widgets/fc_loader.dart';
import '../../../../shared/widgets/fc_text_field.dart';
import '../../providers/workout_provider.dart';

class WorkoutSetup extends ConsumerStatefulWidget {
  const WorkoutSetup({super.key});

  @override
  ConsumerState<WorkoutSetup> createState() => _WorkoutSetupState();
}

class _WorkoutSetupState extends ConsumerState<WorkoutSetup> with SingleTickerProviderStateMixin {
  final _nameCtrl   = TextEditingController(text: 'My Workout');
  final _searchCtrl = TextEditingController();
  late final TabController _tabCtrl;
  bool  _starting   = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (ref.read(workoutProvider).selectedExercises.isEmpty) return;
    setState(() => _starting = true);
    ref.read(workoutProvider.notifier).setWorkoutName(_nameCtrl.text.trim());
    await ref.read(workoutProvider.notifier).startSession();
    if (mounted) setState(() => _starting = false);
  }

  @override
  Widget build(BuildContext context) {
    final wState    = ref.watch(workoutProvider);
    final exState   = ref.watch(exerciseProvider);
    final selected  = wState.selectedExercises;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned:          true,
            floating:        false,
            backgroundColor: AppColors.bg,
            expandedHeight:  0,
            toolbarHeight:   56,
            automaticallyImplyLeading: false,
            title: const Text('New workout', style: TextStyle(
              fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, letterSpacing: -0.3,
            )),
            actions: [
              if (selected.isNotEmpty)
                Center(child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.limeDim,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.limeBorder, width: 0.5),
                  ),
                  child: Text(
                    '${selected.length} selected',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 11,
                      fontWeight: FontWeight.w700, color: AppColors.lime,
                    ),
                  ),
                )),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(182),
              child: Container(
                color: AppColors.bg,
                padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 0, AppConstants.pageHPad, 10),
                child: Column(children: [
                  FCTextField(
                    hint: 'Workout name',
                    controller: _nameCtrl,
                    prefixIcon: const Icon(Icons.edit_outlined, color: AppColors.textTertiary, size: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => ref.read(exerciseProvider.notifier).onSearchChanged(v),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search exercises to add...',
                      hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                      filled: true, fillColor: AppColors.surface2,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border3, width: 0.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border3, width: 0.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.limeBorder, width: 1)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabCtrl,
                    indicatorColor: AppColors.lime, indicatorWeight: 2,
                    labelColor: AppColors.lime, unselectedLabelColor: AppColors.textTertiary,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500),
                    tabs: [
                      const Tab(text: 'Library'),
                      Tab(text: 'Selected${selected.isNotEmpty ? ' (${selected.length})' : ''}'),
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
            // Tab 1: Search results
            exState.loading && exState.exercises.isEmpty
              ? const Center(child: FCLoader())
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 8, AppConstants.pageHPad, 100),
                  itemCount: exState.exercises.length,
                  itemBuilder: (_, i) {
                    final ex = exState.exercises[i];
                    final isSel = ref.watch(workoutProvider.select((s) => s.selectedExercises.any((e) => e.id == ex.id)));
                    return _ExercisePickRow(
                      exercise: ex, isSelected: isSel,
                      onTap: () => ref.read(workoutProvider.notifier).toggleExercise(ex),
                    );
                  },
                ),
            // Tab 2: Selected exercises
            selected.isEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.fitness_center_rounded, color: AppColors.textTertiary, size: 48),
                    const SizedBox(height: 16),
                    Text('No exercises selected', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Find exercises in the Library tab and tap + to add them to your workout.', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary, height: 1.5)),
                  ]),
                ))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 8, AppConstants.pageHPad, 100),
                  itemCount: selected.length,
                  itemBuilder: (_, i) {
                    final ex = selected[i];
                    return _ExercisePickRow(
                      exercise: ex, isSelected: true,
                      onTap: () => ref.read(workoutProvider.notifier).toggleExercise(ex),
                    );
                  },
                ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 8, AppConstants.pageHPad, 16),
          child: FCButton(
            label: selected.isEmpty
                ? 'Select exercises to start'
                : _starting ? 'Starting...' : 'Start workout (${selected.length} exercise${selected.length > 1 ? 's' : ''})',
            loading: _starting,
            fullWidth: true,
            size: FCButtonSize.lg,
            onPressed: selected.isEmpty ? null : _start,
          ),
        ),
      ),
    );
  }
}

class _ExercisePickRow extends StatelessWidget {
  final ExerciseModel exercise;
  final bool          isSelected;
  final VoidCallback  onTap;

  const _ExercisePickRow({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:        isSelected ? AppColors.limeDim : AppColors.surface1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.limeBorder : AppColors.border2,
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ExerciseGifView(
              gifUrl: exercise.gifUrl,
              name:   exercise.name,
              width:  44, height: 44,
              fit:    BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              exercise.capitalizedName,
              maxLines:  1,
              overflow:  TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${exercise.capitalizedBodyPart} · ${exercise.equipment}',
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 26, height: 26,
            decoration: BoxDecoration(
              color:        isSelected ? AppColors.lime : AppColors.surface3,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSelected ? Icons.check_rounded : Icons.add_rounded,
              color: isSelected ? AppColors.bg : AppColors.textSecondary,
              size:  15,
            ),
          ),
        ]),
      ),
    );
  }
}