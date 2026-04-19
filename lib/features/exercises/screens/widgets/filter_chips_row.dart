import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/exercise_model.dart';

class FilterChipsRow extends StatelessWidget {
  final ExerciseFiltersModel filters;
  final String?              selectedBodyPart;
  final String?              selectedDifficulty;
  final String?              selectedEquipment;
  final ValueChanged<String?> onBodyPartChanged;
  final ValueChanged<String?> onDifficultyChanged;
  final ValueChanged<String?> onEquipmentChanged;
  final VoidCallback          onClearAll;

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

  bool get _hasActive =>
      selectedBodyPart != null ||
      selectedDifficulty != null ||
      selectedEquipment != null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Clear all chip
          if (_hasActive) ...[
            _ClearChip(onTap: onClearAll),
            const SizedBox(width: 6),
          ],

          // Body part dropdown chip
          _DropdownChip(
            label:    selectedBodyPart ?? 'Body part',
            isActive: selectedBodyPart != null,
            options:  filters.bodyParts,
            onSelected: onBodyPartChanged,
          ),
          const SizedBox(width: 6),

          // Difficulty chips
          ..._diffOptions.map((d) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _SelectableChip(
              label:    d,
              isActive: selectedDifficulty == d,
              onTap: () => onDifficultyChanged(
                selectedDifficulty == d ? null : d,
              ),
            ),
          )),

          // Equipment dropdown chip
          _DropdownChip(
            label:    selectedEquipment ?? 'Equipment',
            isActive: selectedEquipment != null,
            options:  filters.equipment,
            onSelected: onEquipmentChanged,
          ),
        ],
      ),
    );
  }
}

const _diffOptions = ['beginner', 'intermediate', 'advanced'];

class _SelectableChip extends StatelessWidget {
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:        isActive ? AppColors.limeDim : AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.limeBorder : AppColors.border3,
            width: isActive ? 1 : 0.5,
          ),
        ),
        child: Text(
          label[0].toUpperCase() + label.substring(1),
          style: TextStyle(
            fontFamily:  'Inter',
            fontSize:    12,
            fontWeight:  FontWeight.w600,
            color:       isActive ? AppColors.lime : AppColors.textSecondary,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final String              label;
  final bool                isActive;
  final List<String>        options;
  final ValueChanged<String?> onSelected;

  const _DropdownChip({
    required this.label,
    required this.isActive,
    required this.options,
    required this.onSelected,
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context:           context,
      backgroundColor:   AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OptionsPicker(
        options:    options,
        isActive:   isActive,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:        isActive ? AppColors.limeDim : AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.limeBorder : AppColors.border3,
            width: isActive ? 1 : 0.5,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            isActive
              ? label[0].toUpperCase() + label.substring(1)
              : label,
            style: TextStyle(
              fontFamily:  'Inter', fontSize: 12, fontWeight: FontWeight.w600,
              color: isActive ? AppColors.lime : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size:  15,
            color: isActive ? AppColors.lime : AppColors.textTertiary,
          ),
        ]),
      ),
    );
  }
}

class _OptionsPicker extends StatelessWidget {
  final List<String>        options;
  final bool                isActive;
  final ValueChanged<String?> onSelected;

  const _OptionsPicker({
    required this.options,
    required this.isActive,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 8),
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: AppColors.border3,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('Select option', style: TextStyle(
              fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            )),
          ),
        ),
        const Divider(height: 1, color: AppColors.border2),
        Flexible(child: ListView.builder(
          shrinkWrap:  true,
          itemCount:   options.length + (isActive ? 1 : 0),
          itemBuilder: (_, i) {
            if (isActive && i == 0) {
              return ListTile(
                onTap: () { Navigator.pop(context); onSelected(null); },
                leading: const Icon(Icons.close_rounded,
                    color: AppColors.danger, size: 18),
                title: const Text('Clear filter', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  color: AppColors.danger, fontWeight: FontWeight.w600,
                )),
              );
            }
            final idx = isActive ? i - 1 : i;
            final opt = options[idx];
            return ListTile(
              onTap: () { Navigator.pop(context); onSelected(opt); },
              title: Text(
                opt[0].toUpperCase() + opt.substring(1),
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary, size: 18),
            );
          },
        )),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _ClearChip extends StatelessWidget {
  final VoidCallback onTap;
  const _ClearChip({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:        AppColors.dangerDim,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: AppColors.dangerBorder, width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.close_rounded, color: AppColors.danger, size: 13),
        SizedBox(width: 4),
        Text('Clear', style: TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
          color: AppColors.danger,
        )),
      ]),
    ),
  );
}