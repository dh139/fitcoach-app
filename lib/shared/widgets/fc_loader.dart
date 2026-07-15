import "package:flutter/material.dart";
import "../../core/constants/app_colors.dart";

class FCLoader extends StatelessWidget {
  final Color? color;
  final double size;
  const FCLoader({super.key, this.color, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size, child: CircularProgressIndicator(strokeWidth: 2.5, color: color ?? AppColors.primary));
  }
}

class FCLoaderScaffold extends StatelessWidget {
  final Color? color;
  const FCLoaderScaffold({super.key, this.color});
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: AppColors.bg, body: Center(child: FCLoader()));
}

class FCShimmerCard extends StatelessWidget {
  final double height;
  const FCShimmerCard({super.key, this.height = 120});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: height,
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(20)),
    );
  }
}
