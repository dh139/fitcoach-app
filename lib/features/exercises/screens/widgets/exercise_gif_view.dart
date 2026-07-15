import "package:flutter/material.dart";
import "package:cached_network_image/cached_network_image.dart";
import "../../../../core/constants/app_colors.dart";

class ExerciseGifView extends StatelessWidget {
  final String gifUrl, name;
  final BoxFit fit;
  const ExerciseGifView({super.key, required this.gifUrl, required this.name, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: gifUrl,
      fit: fit,
      alignment: Alignment.center,
      placeholder: (_, __) => Container(
        color: AppColors.surface2,
        child: const Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surface2,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.fitness_center_rounded,
              color: AppColors.textTertiary, size: 24),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ]),
      ),
    );
  }
}
