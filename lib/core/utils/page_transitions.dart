import 'package:flutter/material.dart';

/// Fade + slide up — used for all main screens
class FadeSlideTransition extends PageRouteBuilder {
  final Widget page;

  FadeSlideTransition({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: (_, animation, __, child) {
            final fade = CurvedAnimation(
              parent: animation, curve: Curves.easeOut,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.05),
              end:   Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation, curve: Curves.easeOut,
            ));
            return FadeTransition(
              opacity:  fade,
              child:    SlideTransition(position: slide, child: child),
            );
          },
        );
}