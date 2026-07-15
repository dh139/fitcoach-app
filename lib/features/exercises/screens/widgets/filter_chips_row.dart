import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/exercise_model.dart';

class FilterChipsRow extends StatelessWidget {
  final ExerciseFiltersModel filters;
  final String? selectedBodyPart, selectedDifficulty, selectedEquipment;
  final ValueChanged<String?> onBodyPartChanged, onDifficultyChanged, onEquipmentChanged;
  final VoidCallback onClearAll;

  const FilterChipsRow({
    super.key,
    required this.filters,
    this.selectedBodyPart,
    this.selectedDifficulty,
    this.selectedEquipment,
    required this.onBodyPartChanged,
    required this.onDifficultyChanged,
    required this.onEquipmentChanged,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasAny = selectedBodyPart != null || selectedDifficulty != null || selectedEquipment != null;

    return SizedBox(
      height: 36,
      child: ListView(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), children: [
        _Chip(label: 'Beginner', value: 'beginner', selected: selectedDifficulty, onChanged: onDifficultyChanged, color: AppColors.accent5),
        const SizedBox(width: 8),
        _Chip(label: 'Intermediate', value: 'intermediate', selected: selectedDifficulty, onChanged: onDifficultyChanged, color: AppColors.info),
        const SizedBox(width: 8),
        _Chip(label: 'Advanced', value: 'advanced', selected: selectedDifficulty, onChanged: onDifficultyChanged, color: AppColors.primary),
        const SizedBox(width: 8),
        _DropdownChip(label: selectedEquipment ?? 'Equipment', items: filters.equipment, selected: selectedEquipment, onChanged: onEquipmentChanged),
        const SizedBox(width: 8),
        if (hasAny)
          GestureDetector(
            onTap: onClearAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AppColors.dangerDim, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.dangerBorder, width: 0.5)),
              child: const Row(children: [Icon(Icons.close_rounded, size: 12, color: AppColors.danger), SizedBox(width: 4), Text('Clear', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger))]),
            ),
          ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label, value;
  final String? selected;
  final ValueChanged<String?> onChanged;
  final Color color;
  const _Chip({required this.label, required this.value, required this.selected, required this.onChanged, required this.color});

  @override
  Widget build(BuildContext context) {
    final isSel = selected == value;
    return GestureDetector(
      onTap: () => onChanged(isSel ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? color.withOpacity(0.1) : AppColors.surface1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSel ? color.withOpacity(0.4) : AppColors.border1, width: isSel ? 1 : 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (isSel) ...[Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 5)],
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: isSel ? color : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _DropdownChip({required this.label, required this.items, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isSel = selected != null;
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: AppColors.surface1, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border1, width: 0.5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: isSel ? AppColors.primary : AppColors.textSecondary)),
          const SizedBox(width: 4),
          Icon(Icons.expand_more_rounded, size: 14, color: isSel ? AppColors.primary : AppColors.textTertiary),
        ]),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Equipment', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.surface2, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20)),
            ),
          ]),
          const SizedBox(height: 16),
          if (selected != null) ...[
            GestureDetector(
              onTap: () { onChanged(null); Navigator.pop(context); },
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('Clear selection', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary))),
            ),
            const Divider(color: AppColors.border1),
          ],
          ...items.map((item) => GestureDetector(
            onTap: () { onChanged(item); Navigator.pop(context); },
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [
              Expanded(child: Text(item[0].toUpperCase() + item.substring(1), style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: item == selected ? AppColors.primary : AppColors.textPrimary))),
              if (item == selected) Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.primaryDim, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 14)),
            ])),
          )),
        ]),
      ),
    );
  }
}
