import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class WaterTrackerCard extends StatefulWidget {
  const WaterTrackerCard({super.key});

  @override
  State<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<WaterTrackerCard> {
  int _waterGlasses = 0;
  final int _targetGlasses = 8;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final box = await Hive.openBox('settings');
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    final savedDate = box.get('waterDate', defaultValue: '');
    
    if (savedDate != dateStr) {
      await box.put('waterDate', dateStr);
      await box.put('waterCount', 0);
      _waterGlasses = 0;
    } else {
      _waterGlasses = box.get('waterCount', defaultValue: 0);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _addWater() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _waterGlasses++;
    });
    await box.put('waterCount', _waterGlasses);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 100);

    final pct = (_waterGlasses / _targetGlasses).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border2, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 15,
          )
        ],
      ),
      child: Row(
        children: [
          // Graphic
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                ),
                AnimatedContainer(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                  height: 70 * pct,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0EA5E9),
                  ),
                ),
                const Center(
                  child: Icon(Icons.water_drop_rounded, color: Colors.white, size: 28),
                )
              ],
            ),
          ).animate(target: pct > 0 ? 1 : 0).scale(duration: 300.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hydration Station',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_waterGlasses / $_targetGlasses glasses today',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _addWater,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
