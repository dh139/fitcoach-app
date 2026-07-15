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
import '../../../shared/widgets/fc_loader.dart';

import '../providers/dashboard_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/decay_warning_banner.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/streak_widget.dart';
import 'widgets/xp_history_tile.dart';
import 'widgets/hero_activity_card.dart';
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
    }
  }

  Future<void> _fetchAiRecommendations(String goal, String focus, String duration) async {
    setState(() {
      _aiLoadingRecommendations = true;
    });
    try {
      final stepState = ref.read(stepProvider);
      final res = await ApiClient.post('/exercises/ai-recommendations', data: {
        'goal': goal,
        'focus': focus,
        'duration': duration,
        'context': 'User logged ${stepState.stepsToday} steps today, slept $_sleepHours hours, and had $_waterGlasses glasses of water.',
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
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lime.withAlpha(120),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: AppColors.onLime, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Start Workout Session',
                        style: TextStyle(
                          fontFamily: 'Outfit', fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onLime,
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
          backgroundColor: AppColors.forest,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.smart_toy_rounded, color: AppColors.lime, size: 24),
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
                toolbarHeight:   74,
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
                                colors: AppColors.gradientHero,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.forest.withAlpha(55),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.lime.withAlpha(30),
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
                                    color: AppColors.lime.withAlpha(28),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: AppColors.lime.withAlpha(70),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppColors.lime,
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
                                      color: AppColors.lime,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.lime,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.lime.withAlpha(110),
                                          blurRadius: 14,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _preferencesSet
                                          ? Icons.play_arrow_rounded
                                          : Icons.tune_rounded,
                                      color: AppColors.onLime,
                                      size: 22,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── 2. Hero Activity Ring ──────────────────────────────────
                      HeroActivityCard(
                        steps: steps,
                        goalSteps: stepState.targetSteps,
                        activeCals: activeCals,
                        activeMinutes: (steps / 110).round() + (workoutCals ~/ 8),
                        distanceKm: steps * 0.000762,
                        onTap: () => context.go('/history'),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 60.ms)
                          .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
                      const SizedBox(height: 20),

                      // ── 3. Quick vitals row (Heart · Water · Sleep) ────────────
                      _buildVitalsRow()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 140.ms)
                          .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
                      const SizedBox(height: 24),

                      // ── Weekly Activity Chart (Past 7 days steps & calories burned) ──
                      _sectionHeader('Weekly Activity',
                          action: 'Details', onAction: () => context.go('/history')),
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
                                    color: AppColors.primaryDim,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 18),
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
                                          color: isSelected ? AppColors.surface2 : Colors.transparent,
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
                                                                ? [AppColors.limeBright, AppColors.lime]
                                                                : [AppColors.primaryLight, AppColors.primary.withOpacity(0.55)],
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
                                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 220.ms).slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                      const SizedBox(height: 26),

                      // ── Streak Widget ──────────────────────────────────────────
                      _sectionHeader('Your Streak'),
                      const StreakWidget(),
                      const SizedBox(height: 26),

                      // ── Quick Actions Grid (Leaderboard, AI Reports, Rivals) ────
                      _sectionHeader('Explore'),
                      const QuickActionsGrid(),
                      const SizedBox(height: 26),

                      // ── Recent Activity / XP History ────────────────────────────
                      if (dashState.xpHistory.isNotEmpty) ...[
                        _sectionHeader('Recent Activity'),
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

  void _addWater() {
    setState(() => _waterGlasses = (_waterGlasses + 1).clamp(0, 12));
    if (_waterGlasses == 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hydration goal reached! 💧')),
      );
    }
  }

  // ── Quick vitals row: Heart · Water · Sleep ────────────────────────────────
  Widget _buildVitalsRow() {
    return Row(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _heartPulseController,
            builder: (_, child) {
              final s = _measuringHeartRate
                  ? 1.0 + 0.05 * math.sin(_heartPulseController.value * math.pi * 2)
                  : 1.0;
              return Transform.scale(scale: s, child: child);
            },
            child: _VitalTile(
              icon: Icons.favorite_rounded,
              accent: AppColors.accent2,
              value: _measuringHeartRate ? '· · ·' : '$_heartRate',
              unit: 'bpm',
              label: 'Heart rate',
              onTap: _startHeartRateMeasurement,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VitalTile(
            icon: Icons.water_drop_rounded,
            accent: AppColors.accent3,
            value: '$_waterGlasses',
            unit: '/8',
            label: 'Water',
            progress: (_waterGlasses / 8).clamp(0.0, 1.0),
            onTap: _addWater,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VitalTile(
            icon: Icons.bedtime_rounded,
            accent: AppColors.accent4,
            value: _sleepHours.toStringAsFixed(1),
            unit: 'h',
            label: 'Sleep',
            onTap: _showSleepDialog,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, {String? action, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Premium vital tile ─────────────────────────────────────────────────────────
class _VitalTile extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String value, unit, label;
  final double? progress;
  final VoidCallback onTap;

  const _VitalTile({
    required this.icon,
    required this.accent,
    required this.value,
    required this.unit,
    required this.label,
    required this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.slate),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: accent, size: 16),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: accent.withValues(alpha: 0.14),
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
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
