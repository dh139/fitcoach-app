import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class ExerciseGifView extends StatelessWidget {
  final String  gifUrl;
  final String  name;
  final double? width;
  final double? height;
  final BoxFit  fit;

  const ExerciseGifView({
    super.key,
    required this.gifUrl,
    required this.name,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (gifUrl.isEmpty) return _placeholder(name);

    return CachedNetworkImage(
      imageUrl:    gifUrl,
      width:       width,
      height:      height,
      fit:         fit,
      placeholder: (_, __) => _shimmer(),
      errorWidget: (_, __, ___) => _placeholder(name),
    );
  }

  Widget _shimmer() => Container(
    width: width, height: height,
    decoration: BoxDecoration(
      color: AppColors.surface2,
    ),
    child: const Center(child: SizedBox(
      width: 22, height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2, color: AppColors.surface4,
      ),
    )),
  );

  Widget _placeholder(String name) => Container(
    width: width, height: height,
    color: AppColors.surface2,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.fitness_center_rounded,
          color: AppColors.surface4, size: 28),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter', fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    ]),
  );
}