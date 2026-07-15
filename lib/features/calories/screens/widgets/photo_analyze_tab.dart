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
  File?   _image;
  bool    _addingAll = false;
  String  _selectedMeal = 'lunch';
  final _descController  = TextEditingController();
  final _timeController  = TextEditingController();

  static const _meals = [
    (value: 'breakfast', label: 'Breakfast', icon: Icons.wb_sunny_rounded),
    (value: 'lunch',     label: 'Lunch',     icon: Icons.lunch_dining_rounded),
    (value: 'dinner',    label: 'Dinner',    icon: Icons.dinner_dining_rounded),
    (value: 'snack',     label: 'Snack',     icon: Icons.apple_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.defaultMeal;
  }

  @override
  void dispose() {
    _descController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source:       source,
      maxWidth:     1024,
      maxHeight:    1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _image = file;
    });
    ref.read(calorieProvider.notifier).clearPhotoResult();
    _descController.clear();
  }

  Future<void> _runAnalysis() async {
    if (_image == null) return;

    final bytes    = await _image!.readAsBytes();
    final base64   = base64Encode(bytes);
    final mimeType = _image!.path.endsWith('.png') ? 'image/png' : 'image/jpeg';

    await ref.read(calorieProvider.notifier).analyzePhoto(
      base64Image: base64,
      mimeType:    mimeType,
      description: _descController.text,
    );
  }

  Future<void> _addAll() async {
    final result = ref.read(calorieProvider).photoResult;
    if (result == null || result.items.isEmpty) return;

    setState(() => _addingAll = true);
    for (final item in result.items) {
      await ref.read(calorieProvider.notifier).addFood(
        name:       item.name,
        calories:   item.calories,
        protein:    item.protein,
        carbs:      item.carbs,
        fat:        item.fat,
        fiber:      item.fiber,
        quantity:   1,
        unit:       item.estimatedQuantity,
        mealType:   _selectedMeal,
        source:     'photo',
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
      mealType:  _selectedMeal,
      source:    'photo',
    );
    widget.onAdded();
  }

  String get _mealLabel {
    final m = _selectedMeal;
    return m[0].toUpperCase() + m.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calorieProvider);

    return Column(children: [
      // ── Phase 1: No image selected ──────────────────────────────────────────
      if (_image == null) ...[
        // Hero banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.coachDim, AppColors.surface2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.coachBorder, width: 0.5),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.coach.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.coach.withAlpha(60), width: 1),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.coach, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              'AI Food Recognition',
              style: TextStyle(
                fontFamily: 'Outfit', fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Take or upload a photo — our AI will identify\nfood items and estimate nutrition instantly',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 12,
                color: AppColors.textSecondary, height: 1.5,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Camera button
        _PhotoOptionBtn(
          icon:  Icons.camera_alt_rounded,
          label: 'Take a photo',
          color: AppColors.coach,
          bg:    AppColors.coachDim,
          border: AppColors.coachBorder,
          onTap: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: 10),

        // Gallery button
        _PhotoOptionBtn(
          icon:  Icons.photo_library_rounded,
          label: 'Choose from gallery',
          color: AppColors.accent5,
          bg:    const Color(0x1A3B82F6),
          border: AppColors.accent5Light,
          onTap: () => _pickImage(ImageSource.gallery),
        ),
      ] else ...[
        // ── Phase 2: Image selected ─────────────────────────────────────────

        // Image preview with overlay
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              _image!,
              height: 200,
              width:  double.infinity,
              fit:    BoxFit.cover,
            ),
          ),
          // Loading overlay
          if (state.photoLoading)
            Positioned.fill(child: Container(
              decoration: BoxDecoration(
                color:        Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FCLoader(color: AppColors.coach),
                  SizedBox(height: 10),
                  Text('AI analyzing your food...', style: TextStyle(
                    fontFamily: 'Outfit', fontSize: 13,
                    color: Colors.white, fontWeight: FontWeight.w600,
                  )),
                  SizedBox(height: 4),
                  Text('This may take a few seconds', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    color: Colors.white60,
                  )),
                ],
              ),
            )),
          // Close button
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: () {
                setState(() => _image = null);
                ref.read(calorieProvider.notifier).clearPhotoResult();
              },
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color:        Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
          // Retake button
          Positioned(
            bottom: 10, right: 10,
            child: GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color:        Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Retake', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    color: Colors.white, fontWeight: FontWeight.w600,
                  )),
                ]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // ── Before analysis: description + analyze button ───────────────────
        if (state.photoResult == null && !state.photoLoading) ...[
          TextField(
            controller: _descController,
            style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Describe your food (optional) e.g. two rotis and dal',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontFamily: 'Inter'),
              fillColor: AppColors.surface2,
              filled: true,
              prefixIcon: const Icon(Icons.description_rounded, color: AppColors.textTertiary, size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FCButton(
              label: 'Analyze Food with AI',
              onPressed: _runAnalysis,
            ),
          ),
        ],

        // ── Error state ─────────────────────────────────────────────────────
        if (state.photoError != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        AppColors.dangerDim,
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: AppColors.dangerBorder, width: 0.5),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(state.photoError!, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 12,
                color: Color(0xFFFF8888), height: 1.4,
              ))),
            ]),
          ),

        // ── Results section ─────────────────────────────────────────────────
        if (state.photoResult != null && state.photoResult!.success) ...[
          const SizedBox(height: 16),

          // ── MEAL TYPE PICKER ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border2, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.coach, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'When did you eat this?',
                    style: TextStyle(
                      fontFamily: 'Outfit', fontSize: 14,
                      fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.coachDim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Required', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 9,
                      fontWeight: FontWeight.w700, color: AppColors.coach,
                    )),
                  ),
                ]),
                const SizedBox(height: 12),

                // Meal chips row
                Row(
                  children: _meals.map((m) {
                    final sel = _selectedMeal == m.value;
                    final isLast = m.value == _meals.last.value;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMeal = m.value),
                        child: Container(
                          margin: EdgeInsets.only(right: isLast ? 0 : 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.coach : AppColors.surface1,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel ? AppColors.coach : AppColors.border3,
                              width: sel ? 1.5 : 0.5,
                            ),
                            boxShadow: sel ? [
                              BoxShadow(
                                color: AppColors.coach.withAlpha(50),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(m.icon,
                              size: 16,
                              color: sel ? Colors.white : AppColors.textTertiary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter', fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Optional time field
                TextField(
                  controller: _timeController,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Time eaten (optional) e.g. 1:30 PM',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontFamily: 'Inter'),
                    fillColor: AppColors.surface1,
                    filled: true,
                    prefixIcon: const Icon(Icons.schedule_rounded, color: AppColors.textTertiary, size: 16),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border2, width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border2, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.coach, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // AI Notes banner
          if (state.photoResult!.notes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:        AppColors.limeDim,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.limeBorder, width: 0.5),
              ),
              child: Row(children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.lime, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(state.photoResult!.notes,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    color: AppColors.lime, height: 1.4,
                  ))),
              ]),
            ),
          const SizedBox(height: 10),

          // Food item cards
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:        AppColors.surface2,
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(color: AppColors.border3, width: 0.5),
              ),
              child: Row(children: [
                // Food icon
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.set_meal_rounded, color: AppColors.textTertiary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(
                      fontFamily: 'Outfit', fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                    )),
                    const SizedBox(height: 2),
                    Text(
                      item.estimatedQuantity,
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      _MacroChip('P', '${item.protein.round()}g', AppColors.accent5),
                      const SizedBox(width: 4),
                      _MacroChip('C', '${item.carbs.round()}g', const Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      _MacroChip('F', '${item.fat.round()}g', const Color(0xFFEF4444)),
                    ]),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${item.calories}', style: const TextStyle(
                    fontFamily: 'Outfit', fontSize: 18,
                    fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                  )),
                  const Text('kcal', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    color: AppColors.textTertiary,
                  )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: confColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: confColor.withAlpha(60), width: 0.5),
                    ),
                    child: Text(item.confidence, style: TextStyle(
                      fontFamily: 'Inter', fontSize: 9,
                      fontWeight: FontWeight.w700, color: confColor,
                    )),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _addSingle(idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color:        AppColors.coachDim,
                        borderRadius: BorderRadius.circular(8),
                        border:       Border.all(color: AppColors.coachBorder, width: 0.5),
                      ),
                      child: const Text('+ Add', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 10,
                        fontWeight: FontWeight.w700, color: AppColors.coach,
                      )),
                    ),
                  ),
                ]),
              ]),
            );
          }),

          const SizedBox(height: 8),
          FCButton(
            label: _addingAll
                ? 'Adding...'
                : 'Add all to $_mealLabel (${state.photoResult!.totalCalories} kcal)',
            loading:  _addingAll,
            fullWidth: true,
            onPressed: _addAll,
          ),
          const SizedBox(height: 8),
        ],
      ],
    ]);
  }
}

class _MacroChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MacroChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text('$label: $value', style: TextStyle(
      fontFamily: 'Inter', fontSize: 9,
      fontWeight: FontWeight.w700, color: color,
    )),
  );
}

class _PhotoOptionBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color, bg, border;
  final VoidCallback onTap;

  const _PhotoOptionBtn({
    required this.icon,   required this.label,
    required this.color,  required this.bg,
    required this.border, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withAlpha(80), width: 0.5),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(
          fontFamily: 'Outfit', fontSize: 14,
          fontWeight: FontWeight.w600, color: color,
        )),
      ]),
    ),
  );
}