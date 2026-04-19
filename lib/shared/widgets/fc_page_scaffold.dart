import 'package:flutter/material.dart';

/// Wraps any screen content with a fade-slide entrance animation.
class FCPageScaffold extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FCPageScaffold({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<FCPageScaffold> createState() => _FCPageScaffoldState();
}

class _FCPageScaffoldState extends State<FCPageScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _fade;
  late final Animation<Offset>    _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 380),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child:   SlideTransition(position: _slide, child: widget.child),
  );
}