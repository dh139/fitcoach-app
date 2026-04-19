import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ReportSkeleton extends StatefulWidget {
  const ReportSkeleton({super.key});

  @override
  State<ReportSkeleton> createState() => _ReportSkeletonState();
}

class _ReportSkeletonState extends State<ReportSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Widget _bone({double h = 16, double? w, double r = 8}) =>
      Container(
        height: h,
        width:  w,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color:        AppColors.surface2.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(r),
        ),
      );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score meters
        Row(children: [
          Expanded(child: _bone(h: 80, r: 16)),
          const SizedBox(width: 10),
          Expanded(child: _bone(h: 80, r: 16)),
        ]),
        const SizedBox(height: 10),
        _bone(h: 56, r: 12),
        const SizedBox(height: 10),
        // Summary block
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        AppColors.surface1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _bone(h: 12, w: 80),
            _bone(h: 10),
            _bone(h: 10),
            _bone(h: 10, w: 180),
          ]),
        ),
        const SizedBox(height: 10),
        // Bullet sections
        ...List.generate(3, (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        AppColors.surface1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            _bone(h: 12, w: 100),
            Row(children: [
              _bone(h: 16, w: 16, r: 100),
              const SizedBox(width: 8),
              Expanded(child: _bone(h: 10)),
            ]),
            Row(children: [
              _bone(h: 16, w: 16, r: 100),
              const SizedBox(width: 8),
              Expanded(child: _bone(h: 10, w: 160)),
            ]),
          ]),
        )),
      ],
    ),
  );
}