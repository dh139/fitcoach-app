import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../../../shared/widgets/fc_loader.dart';
import '../../providers/calorie_provider.dart';

class PhotoAnalyzeTab extends ConsumerStatefulWidget {
  final String       defaultMeal;
  final VoidCallback onAdded;

  const PhotoAnalyzeTab({
    super.key,
    required this.defaultMeal,
    required this.onAdded,
  });

  @override
  ConsumerState<PhotoAnalyzeTab> createState() => _PhotoAnalyzeTabState();
}

class _PhotoAnalyzeTabState extends ConsumerState<PhotoAnalyzeTab> {
  File?  _image;
  bool   _addingAll = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source:    source,
      maxWidth:  1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final file  = File(picked.path);
    setState(() => _image = file);
    ref.read(calorieProvider.notifier).clearPhotoResult();

    final bytes    = await file.readAsBytes();
    final base64   = base64Encode(bytes);
    final mimeType = picked.mimeType ?? 'image/jpeg';

    await ref.read(calorieProvider.notifier).analyzePhoto(
      base64Image: base64,
      mimeType:    mimeType,
    );
  }

  Future<void> _addAll() async {
    final result = ref.read(calorieProvider).photoResult;
    if (result == null || result.items.isEmpty) return;

    setState(() => _addingAll = true);
    for (final item in result.items) {
      await ref.read(calorieProvider.notifier).addFood(
        name:      item.name,
        calories:  item.calories,
        protein:   item.protein,
        carbs:     item.carbs,
        fat:       item.fat,
        fiber:     item.fiber,
        quantity:  1,
        unit:      item.estimatedQuantity,
        mealType:  widget.defaultMeal,
        source:    'photo',
        aiAnalysis: result.notes,
      );
    }
    setState(() => _addingAll = false);
    widget.onAdded();
  }

  Future<void> _addSingle(int idx) async {
    final result = ref.read(calorieProvider).photoResult;
    if (result == null) return;
    final item = result.items[idx];
    await ref.read(calorieProvider.notifier).addFood(
      name:      item.name,
      calories:  item.calories,
      protein:   item.protein,
      carbs:     item.carbs,
      fat:       item.fat,
      fiber:     item.fiber,
      quantity:  1,
      unit:      item.estimatedQuantity,
      mealType:  widget.defaultMeal,
      source:    'photo',
    );
    widget.onAdded();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calorieProvider);

    return Column(children: [
      // Photo options
      if (_image == null) ...[
        _PhotoOptionBtn(
          icon:    Icons.camera_alt_rounded,
          label:   'Take a photo',
          color:   AppColors.coach,
          bg:      AppColors.coachDim,
          onTap:   () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: 10),
        _PhotoOptionBtn(
          icon:    Icons.photo_library_rounded,
          label:   'Choose from gallery',
          color:   const Color(0xFF60A5FA),
          bg:      const Color(0x1A3B82F6),
          onTap:   () => _pickImage(ImageSource.gallery),
        ),
        const SizedBox(height: 12),
        const Text(
          'AI will identify food items and estimate nutrition',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            color: AppColors.textTertiary, height: 1.4,
          ),
        ),
      ] else ...[
        // Preview + controls
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _image!,
              height: 180,
              width:  double.infinity,
              fit:    BoxFit.cover,
            ),
          ),
          if (state.photoLoading)
            Positioned.fill(child: Container(
              decoration: BoxDecoration(
                color:        Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FCLoader(color: AppColors.lime),
                  SizedBox(height: 8),
                  Text('AI analyzing food...', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    color: Colors.white,
                  )),
                ],
              ),
            )),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() => _image = null);
                ref.read(calorieProvider.notifier).clearPhotoResult();
              },
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color:        Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Error
        if (state.photoError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:        AppColors.dangerDim,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: AppColors.dangerBorder, width: 0.5),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.danger, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(state.photoError!, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 12,
                color: Color(0xFFFF8888),
              ))),
            ]),
          ),

        // Results
        if (state.photoResult != null && state.photoResult!.success) ...[
          if (state.photoResult!.notes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:        AppColors.limeDim,
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(color: AppColors.limeBorder, width: 0.5),
              ),
              child: Row(children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.lime, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(state.photoResult!.notes,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    color: AppColors.lime, height: 1.4,
                  ))),
              ]),
            ),
          const SizedBox(height: 10),

          // Item list
          ...state.photoResult!.items.asMap().entries.map((entry) {
            final idx  = entry.key;
            final item = entry.value;
            final confColor = switch (item.confidence) {
              'high'   => const Color(0xFF22C55E),
              'medium' => const Color(0xFFF59E0B),
              _        => AppColors.danger,
            };
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color:        AppColors.surface2,
                borderRadius: BorderRadius.circular(14),
                border:       Border.all(color: AppColors.border3, width: 0.5),
              ),
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                    Text('${item.estimatedQuantity} · P:${item.protein.round()}g C:${item.carbs.round()}g F:${item.fat.round()}g',
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: confColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.confidence} confidence',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 9,
                          fontWeight: FontWeight.w600, color: confColor,
                        ),
                      ),
                    ),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${item.calories}', style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                  const Text('kcal', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    color: AppColors.textTertiary,
                  )),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _addSingle(idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:        AppColors.limeDim,
                        borderRadius: BorderRadius.circular(8),
                        border:       Border.all(
                            color: AppColors.limeBorder, width: 0.5),
                      ),
                      child: const Text('+ Add', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 10,
                        fontWeight: FontWeight.w700, color: AppColors.lime,
                      )),
                    ),
                  ),
                ]),
              ]),
            );
          }),

          const SizedBox(height: 4),
          FCButton(
            label:    _addingAll
                ? 'Adding...'
                : 'Add all items (${state.photoResult!.totalCalories} kcal)',
            loading:  _addingAll,
            fullWidth: true,
            onPressed: _addAll,
          ),
        ],
      ],
    ]);
  }
}

class _PhotoOptionBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color, bg;
  final VoidCallback onTap;

  const _PhotoOptionBtn({
    required this.icon,  required this.label,
    required this.color, required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(
          fontFamily: 'Inter', fontSize: 13,
          fontWeight: FontWeight.w600, color: color,
        )),
      ]),
    ),
  );
}