import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../../../shared/widgets/stat_card.dart';

import '../providers/dashboard_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/decay_warning_banner.dart';
import 'widgets/level_up_dialog.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/activity_rings_card.dart';
import 'widgets/streak_widget.dart';
import 'widgets/xp_history_tile.dart';
import '../../../shared/widgets/xp_bar.dart';
import '../providers/step_provider.dart';
import '../../../core/network/api_client.dart';
import '../../exercises/models/exercise_model.dart';
import '../../workout/providers/workout_provider.dart';
import '../../history/providers/history_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with TickerProviderStateMixin {
  // State variables for interactive mockup cards
  int _waterGlasses = 4;
  double _weight = 70.0;
  double _sleepHours = 7.4;
  int _heartRate = 72;
  bool _measuringHeartRate = false;
  int _selectedChartIndex = 6; // Weekly activity selected day
  
  // Controller for AI Coach query
  final _aiQueryCtrl = TextEditingController();

  late final AnimationController _heartPulseController;

  Timer? _heartRateFluctuationTimer;
  bool _isSleeping = false;
  DateTime? _sleepStartTime;
  Timer? _sleepTickerTimer;
  int _sleepSecondsElapsed = 0;

  List<ExerciseModel> _aiRecommendedExercises = [];
  bool _aiLoadingRecommendations = false;
  bool _preferencesSet = false;

  @override
  void initState() {
    super.initState();
    _heartPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLevelUp();
      _checkPreferencesAndLoad();
    });

    _heartRateFluctuationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && !_measuringHeartRate) {
        setState(() {
          _heartRate = 70 + (math.Random().nextInt(5)); // fluctuate 70-74
        });
      }
    });
  }

  @override
  void dispose() {
    _heartRateFluctuationTimer?.cancel();
    _sleepTickerTimer?.cancel();
    _heartPulseController.dispose();
    _aiQueryCtrl.dispose();
    super.dispose();
  }

  void _startSleepTicker() {
    _sleepTickerTimer?.cancel();
    _sleepTickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isSleeping && _sleepStartTime != null) {
        setState(() {
          _sleepSecondsElapsed = DateTime.now().difference(_sleepStartTime!).inSeconds;
        });
      }
    });
  }

  Future<void> _checkPreferencesAndLoad() async {
    final box = await Hive.openBox('settings');
    final goal = box.get('pref_goal');
    final focus = box.get('pref_focus');
    final duration = box.get('pref_duration');
    
    if (goal != null && focus != null && duration != null) {
      setState(() => _preferencesSet = true);
      
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final cacheDate = box.get('ai_workout_date');
      final cacheList = box.get('ai_workout_list');
      
      if (cacheDate == todayStr && cacheList != null) {
        try {
          final decoded = jsonDecode(cacheList.toString()) as List<dynamic>;
          setState(() {
            _aiRecommendedExercises = decoded
                .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
                .toList();
          });
          return;
        } catch (e) {
          debugPrint("Error parsing cached AI recommendations: $e");
        }
      }
      _fetchAiRecommendations(goal.toString(), focus.toString(), duration.toString());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showQuestionnaireDialog();
      });
    }
  }

  Future<void> _fetchAiRecommendations(String goal, String focus, String duration) async {
    setState(() {
      _aiLoadingRecommendations = true;
    });
    try {
      final res = await ApiClient.post('/exercises/ai-recommendations', data: {
        'goal': goal,
        'focus': focus,
        'duration': duration,
      });
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>)
            .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList();
            
        final box = await Hive.openBox('settings');
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        await box.put('ai_workout_date', todayStr);
        await box.put('ai_workout_list', jsonEncode(list.map((e) => e.toJson()).toList()));

        setState(() {
          _aiRecommendedExercises = list;
          _aiLoadingRecommendations = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching AI recommendations: $e");
      setState(() {
        _aiLoadingRecommendations = false;
      });
    }
  }

  void _checkLevelUp() {}

  Future<void> _onRefresh() async {
    await ref.read(dashboardProvider.notifier).refresh();
    final box = await Hive.openBox('settings');
    final goal = box.get('pref_goal');
    final focus = box.get('pref_focus');
    final duration = box.get('pref_duration');
    if (goal != null && focus != null && duration != null) {
      await _fetchAiRecommendations(goal.toString(), focus.toString(), duration.toString());
    }
  }

  // Micro-interaction: Measure Heart Rate
  void _startHeartRateMeasurement() {
    if (_measuringHeartRate) return;
    setState(() {
      _measuringHeartRate = true;
    });
    _heartPulseController.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _measuringHeartRate = false;
          _heartRate = 68 + (DateTime.now().millisecond % 18); // randomized realistic value
        });
        _heartPulseController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Heart rate measured: $_heartRate bpm (Normal)"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  // Micro-interaction: Log Weight
  void _showWeightDialog() {
    final ctrl = TextEditingController(text: _weight.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: const Text('Update Weight', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0) {
                setState(() => _weight = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Micro-interaction: Log Sleep
  String _formatSleepElapsed() {
    final h = _sleepSecondsElapsed ~/ 3600;
    final m = (_sleepSecondsElapsed % 3600) ~/ 60;
    final s = _sleepSecondsElapsed % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showSleepDialog() {
    if (_isSleeping) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Sleep Tracker Active', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.nights_stay_rounded, color: AppColors.primary, size: 48)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(duration: 1.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
              const SizedBox(height: 16),
              const Text('You are currently logged as sleeping.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              StreamBuilder<int>(
                stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
                builder: (context, snapshot) {
                  return Text(
                    _formatSleepElapsed(),
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  );
                }
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Sleeping'),
            ),
            TextButton(
              onPressed: () {
                _sleepTickerTimer?.cancel();
                final hoursSlept = _sleepSecondsElapsed / 3600.0;
                setState(() {
                  _isSleeping = false;
                  _sleepHours = double.parse((_sleepHours + hoursSlept).toStringAsFixed(1));
                  _sleepSecondsElapsed = 0;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged ${hoursSlept.toStringAsFixed(1)} hours of sleep!')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Wake Up & Log'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Sleep Tracker', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select tracking method:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isSleeping = true;
                    _sleepStartTime = DateTime.now();
                    _sleepSecondsElapsed = 0;
                  });
                  _startSleepTicker();
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Real-time Sleep Timer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDim,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showManualSleepInput();
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Log Sleep Manually'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface2,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showManualSleepInput() {
    final ctrl = TextEditingController(text: _sleepHours.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: const Text('Log Sleep Manually', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Sleep Hours'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0 && val <= 24) {
                setState(() => _sleepHours = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showQuestionnaireDialog() {
    String goal = 'Lose Weight';
    String focus = 'Cardio';
    String duration = '30';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text('Welcome to FitCoach!', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Let\'s customize your daily routine with AI recommendations.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
              const SizedBox(height: 18),
              
              const Text('What is your primary goal?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: goal,
                decoration: InputDecoration(
                  fillColor: AppColors.surface2,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['Lose Weight', 'Gain Muscle', 'Stay Healthy'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setDialogState(() => goal = val!),
              ),
              const SizedBox(height: 14),

              const Text('What is your focus area?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: focus,
                decoration: InputDecoration(
                  fillColor: AppColors.surface2,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['Cardio', 'Strength', 'Flexibility'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (val) => setDialogState(() => focus = val!),
              ),
              const SizedBox(height: 14),

              const Text('Daily workout duration?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: duration,
                decoration: InputDecoration(
                  fillColor: AppColors.surface2,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['15', '30', '45'].map((d) => DropdownMenuItem(value: d, child: Text('$d minutes'))).toList(),
                onChanged: (val) => setDialogState(() => duration = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final box = await Hive.openBox('settings');
                await box.put('pref_goal', goal);
                await box.put('pref_focus', focus);
                await box.put('pref_duration', duration);
                if (mounted) {
                  setState(() => _preferencesSet = true);
                  Navigator.pop(ctx);
                  _fetchAiRecommendations(goal, focus, duration);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text('Save & Get Recommendations', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecommendedWorkoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDim,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily AI Routine',
                          style: TextStyle(
                            fontFamily: 'Outfit', fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${_aiRecommendedExercises.length} exercises  •  Personalised for you',
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 1, color: AppColors.border2),
            ),
            const SizedBox(height: 8),

            // Exercise list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: _aiRecommendedExercises.length,
                itemBuilder: (context, idx) {
                  final ex = _aiRecommendedExercises[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border1, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        // Number badge
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDim,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.capitalizedName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Outfit', fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${ex.capitalizedBodyPart}  •  ${ex.target}',
                                style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDim,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.local_fire_department_rounded,
                                color: AppColors.primary, size: 11),
                            const SizedBox(width: 2),
                            Text(
                              '${ex.caloriesPerMinute}/min',
                              style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Start Workout button
            Padding(
              padding: EdgeInsets.fromLTRB(
                20, 8, 20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(workoutProvider.notifier)
                      .startCustomSession(_aiRecommendedExercises, 'AI Daily Workout');
                  context.go('/workout');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF3B82F6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Start Workout Session',
                        style: TextStyle(
                          fontFamily: 'Outfit', fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardProvider);
    final stepState = ref.watch(stepProvider);
    final histState = ref.watch(historyProvider);

    final steps = stepState.stepsToday;
    final stepCals = (steps * 0.04).toInt();

    final box = Hive.box('settings');
    final today = DateTime.now();
    final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final List<Map<String, dynamic>> weeklyData = [];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month}-${date.day}';
      int daySteps = box.get('recentSteps_$dateStr', defaultValue: 0) as int;
      if (i == 0) {
        daySteps = steps;
      }
      final dayCals = (daySteps * 0.04).toInt();
      weeklyData.add({
        'dayLabel': weekdays[date.weekday - 1].substring(0, 1),
        'fullName': weekdays[date.weekday - 1],
        'steps': daySteps,
        'cals': dayCals,
        'pct': (daySteps / 10000.0).clamp(0.12, 1.0),
      });
    }
    
    // Sum up today's workout calories from history provider
    int workoutCals = 0;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    for (final w in histState.workouts) {
      if (w.completedAt.startsWith(todayStr)) {
        workoutCals += w.totalCaloriesBurned;
      }
    }
    final activeCals = stepCals + workoutCals;

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: () => context.go('/coach'),
          backgroundColor: const Color(0xFF1E202B),
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF6BB5FF), size: 24),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh:  _onRefresh,
          color:      AppColors.primary,
          backgroundColor: AppColors.surface1,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ───────────────────────────────────────────────
              const SliverAppBar(
                pinned:          false,
                floating:        false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation:       0,
                scrolledUnderElevation: 0,
                toolbarHeight:   64,
                automaticallyImplyLeading: false,
                flexibleSpace: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.pageHPad),
                  child: DashboardHeader(),
                ),
              ),

              if (dashState.loading && !dashState.hasData)
                const SliverFillRemaining(
                  child: Center(child: FCLoader()),
                )
              else if (dashState.error != null && !dashState.hasData)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded, color: AppColors.textTertiary, size: 48),
                        const SizedBox(height: 12),
                        const Text('Failed to load dashboard', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        TextButton(onPressed: _onRefresh, child: const Text('Try again')),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 8, AppConstants.pageHPad, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (dashState.xpProfile?.decayWarning == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: DecayWarningBanner(daysInactive: dashState.xpProfile?.daysInactive),
                        ),

                      // ── 1. AI Daily Workout Banner ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: _preferencesSet
                              ? (_aiRecommendedExercises.isNotEmpty ? _showRecommendedWorkoutSheet : null)
                              : _showQuestionnaireDialog,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1A1C2B), Color(0xFF0F1629)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(30),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withAlpha(15),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left icon
                                Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primary.withAlpha(60),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Color(0xFF6BB5FF),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Text content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _preferencesSet ? 'AI Daily Workout' : 'Set AI Workout Goal',
                                        style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _preferencesSet
                                            ? (_aiRecommendedExercises.isNotEmpty
                                                ? '${_aiRecommendedExercises.length} exercises ready  •  Tap to start'
                                                : 'Personalizing your routine...')
                                            : 'Choose your goal to unlock AI routine',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: Colors.white.withAlpha(140),
                                        ),
                                      ),
                                      if (_preferencesSet && _aiRecommendedExercises.isNotEmpty) ...
                                        [
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _WorkoutTagChip('Strength'),
                                              const SizedBox(width: 6),
                                              _WorkoutTagChip('Custom'),
                                            ],
                                          ),
                                        ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Right action button
                                if (_aiLoadingRecommendations)
                                  const SizedBox(
                                    width: 32, height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF6BB5FF),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withAlpha(80),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _preferencesSet
                                          ? Icons.play_arrow_rounded
                                          : Icons.tune_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── 2. Large Hero Tracker Card ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=600&auto=format&fit=crop',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.55),
                                        Colors.black.withOpacity(0.15),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0, right: 0, bottom: 20, height: 50,
                                child: CustomPaint(
                                  painter: HeartbeatPainter(color: Colors.white.withOpacity(0.7)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$activeCals KCAL",
                                      style: const TextStyle(
                                        fontFamily: "Outfit",
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.directions_walk_rounded, color: Colors.white70, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "$steps STEPS",
                                          style: const TextStyle(
                                            fontFamily: "Outfit",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── 3. Heart Beat Metric Card ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SizedBox(
                          height: 115, // Expanded to 115 to prevent 9px RenderFlex bottom overflow
                          child: _buildMetricCard(
                            title: "Heart beat",
                            value: _measuringHeartRate ? "..." : "$_heartRate bpm",
                            status: _measuringHeartRate ? "MEASURING" : "NORMAL",
                            bgColor: const Color(0xFFFFF0F2), // Light Pink
                            textColor: const Color(0xFFFF5C7A),
                            icon: Icons.favorite_rounded,
                            onTap: _startHeartRateMeasurement,
                          ),
                        ),
                      ),

                      // ── Weekly Activity Chart (Past 7 days steps & calories burned) ──
                      const Text(
                        "Weekly Activity",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface1,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.slate, width: 1.0),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEEF6FF), // Soft light blue
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.show_chart_rounded, color: Color(0xFF6BB5FF), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "On ${weeklyData[_selectedChartIndex]['fullName']}",
                                      style: const TextStyle(
                                        fontFamily: "Outfit",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      "${weeklyData[_selectedChartIndex]['steps'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} steps • ${weeklyData[_selectedChartIndex]['cals']} kcal burned",
                                      style: const TextStyle(
                                        fontFamily: "PlusJakartaSans",
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(7, (idx) {
                                final item = weeklyData[idx];
                                final isSelected = idx == _selectedChartIndex;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedChartIndex = idx;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFF0F4FA) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  final totalH = constraints.maxHeight;
                                                  final fillH = totalH * item['pct'];
                                                  return Stack(
                                                    alignment: Alignment.bottomCenter,
                                                    children: [
                                                      Container(
                                                        width: 8,
                                                        decoration: BoxDecoration(
                                                          color: AppColors.surface2,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      AnimatedContainer(
                                                        duration: const Duration(milliseconds: 300),
                                                        width: 8,
                                                        height: fillH,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: isSelected
                                                                ? [const Color(0xFF6BB5FF), const Color(0xFF3B82F6)]
                                                                : [const Color(0xFF93C5FD), const Color(0xFF60A5FA)],
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                          ),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['dayLabel'],
                                        style: TextStyle(
                                          fontFamily: "Outfit",
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected ? const Color(0xFF3B82F6) : AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Streak Widget ──────────────────────────────────────────
                      const Text(
                        "Your Streak",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const StreakWidget(),
                      const SizedBox(height: 24),

                      // ── Quick Actions Grid (Leaderboard, AI Reports, Rivals) ────
                      const QuickActionsGrid(),
                      const SizedBox(height: 24),

                      // ── Recent Activity / XP History ────────────────────────────
                      if (dashState.xpHistory.isNotEmpty) ...[
                        const Text(
                          "Recent Activity",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dashState.xpHistory.length.clamp(0, 5),
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) => XpHistoryTile(log: dashState.xpHistory[idx]),
                        ),
                        const SizedBox(height: 24),
                      ],
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper builder for metric cards
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String status,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final scale = _measuringHeartRate && title == "Heart beat" ? (1.0 + 0.05 * math.sin(_heartPulseController.value * math.pi * 2)) : 1.0;
    
    return Transform.scale(
      scale: scale,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withOpacity(0.12), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "PlusJakartaSans",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  Icon(icon, color: textColor, size: 18),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Heartbeat/Wave Painter ───────────────────────────────────────────────────
class HeartbeatPainter extends CustomPainter {
  final Color color;
  HeartbeatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.6);
    path.lineTo(w * 0.2, h * 0.6);
    path.lineTo(w * 0.25, h * 0.5);
    path.lineTo(w * 0.3, h * 0.65);
    path.lineTo(w * 0.35, h * 0.6);
    path.lineTo(w * 0.5, h * 0.6);
    path.lineTo(w * 0.55, h * 0.15);
    path.lineTo(w * 0.6, h * 0.9);
    path.lineTo(w * 0.65, h * 0.55);
    path.lineTo(w * 0.7, h * 0.6);
    path.lineTo(w * 0.8, h * 0.6);
    path.lineTo(w * 0.84, h * 0.52);
    path.lineTo(w * 0.88, h * 0.63);
    path.lineTo(w * 0.92, h * 0.6);
    path.lineTo(w, h * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Workout Tag Chip ─────────────────────────────────────────────────────────
class _WorkoutTagChip extends StatelessWidget {
  final String label;
  const _WorkoutTagChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(18),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withAlpha(30), width: 0.5),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter', fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white60,
      ),
    ),
  );
}
