import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FCLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const FCLoader({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  size,
      height: size,
      child:  CircularProgressIndicator(
        strokeWidth: 2.5,
        color:       color ?? AppColors.lime,
      ),
    );
  }
}

class FCLoaderScaffold extends StatelessWidget {
  const FCLoaderScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: FCLoader()),
    );
  }
}

// Shimmer card placeholder
class FCShimmerCard extends StatelessWidget {
  final double height;
  final double? width;

  const FCShimmerCard({super.key, this.height = 80, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width,
      height: height,
      decoration: BoxDecoration(
        color:        AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}