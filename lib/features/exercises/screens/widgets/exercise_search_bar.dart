import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ExerciseSearchBar extends StatefulWidget {
  final String          initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback?   onClear;

  const ExerciseSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue = '',
    this.onClear,
  });

  @override
  State<ExerciseSearchBar> createState() => _ExerciseSearchBarState();
}

class _ExerciseSearchBarState extends State<ExerciseSearchBar> {
  late final TextEditingController _ctrl;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _hasFocus = f),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color:        AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hasFocus ? AppColors.limeBorder : AppColors.border3,
            width: _hasFocus ? 1.0 : 0.5,
          ),
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded,
              color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: TextField(
            controller:     _ctrl,
            onChanged:      widget.onChanged,
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText:       'Search exercises, muscles...',
              hintStyle: TextStyle(
                fontFamily: 'Inter', fontSize: 14,
                color: AppColors.textTertiary,
              ),
              border:         InputBorder.none,
              isDense:        true,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.search,
          )),
          if (_ctrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                widget.onChanged('');
                widget.onClear?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color:        AppColors.surface4,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 13),
                ),
              ),
            )
          else
            const SizedBox(width: 14),
        ]),
      ),
    );
  }
}