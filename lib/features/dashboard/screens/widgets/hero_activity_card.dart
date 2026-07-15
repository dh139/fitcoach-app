import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Premium "Today" hero — an animated triple-metric activity ring on a deep
/// forest panel. Steps drive the ring sweep; active calories sit at the centre.
class HeroActivityCard extends StatefulWidget {
  final int steps;
  final int goalSteps;
  final int activeCals;
  final int activeMinutes;
  final double distanceKm;
  final VoidCallback? onTap;

  const HeroActivityCard({
    super.key,
    required this.steps,
    required this.goalSteps,
    required this.activeCals,
    required this.activeMinutes,
    required this.distanceKm,
    this.onTap,
  });

  @override
  State<HeroActivityCard> createState() => _HeroActivityCardState();
}

class _HeroActivityCardState extends State<HeroActivityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _sweep;

  double get _progress =>
      widget.goalSteps == 0 ? 0 : (widget.steps / widget.goalSteps).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _sweep = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void didUpdateWidget(covariant HeroActivityCard old) {
    super.didUpdateWidget(old);
    if (old.steps != widget.steps || old.goalSteps != widget.goalSteps) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_progress * 100).round();
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.gradientHero,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.forest.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header row ──────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: AppColors.lime, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  "Today's Activity",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.92),
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$pct% of goal',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lime,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Ring + centre metric ────────────────────────────────────
            AnimatedBuilder(
              animation: _sweep,
              builder: (_, __) {
                final v = _sweep.value;
                return SizedBox(
                  width: 176,
                  height: 176,
                  child: CustomPaint(
                    painter: _RingPainter(_progress * v),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(widget.activeCals * v).round()}',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 46,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.6,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'KCAL BURNED',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Metric strip ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _metric(Icons.directions_walk_rounded,
                      _fmt(widget.steps), 'Steps'),
                  _divider(),
                  _metric(Icons.straighten_rounded,
                      '${widget.distanceKm.toStringAsFixed(1)} km', 'Distance'),
                  _divider(),
                  _metric(Icons.timer_outlined,
                      '${widget.activeMinutes} min', 'Active'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) => Expanded(
        child: Column(
          children: [
            Icon(icon, color: AppColors.lime, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1,
        height: 34,
        color: Colors.white.withValues(alpha: 0.1),
      );

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const stroke = 14.0;
    const start = -math.pi / 2;

    // Track
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    // Progress arc with lime gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final arc = Paint()
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [AppColors.primary, AppColors.lime, AppColors.limeBright],
        stops: [0.0, 0.7, 1.0],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, 2 * math.pi * progress, false, arc);

    // Glowing head dot
    final angle = start + 2 * math.pi * progress;
    final dot = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawCircle(dot, stroke / 2 + 2,
        Paint()..color = AppColors.limeBright);
    canvas.drawCircle(dot, stroke / 2 - 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
