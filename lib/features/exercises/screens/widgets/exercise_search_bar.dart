import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ExerciseSearchBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  const ExerciseSearchBar({super.key, this.initialValue = '', required this.onChanged});

  @override
  State<ExerciseSearchBar> createState() => _ExerciseSearchBarState();
}

class _ExerciseSearchBarState extends State<ExerciseSearchBar> {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _focused ? AppColors.primary.withOpacity(0.4) : AppColors.border1, width: _focused ? 1.5 : 0.5),
      ),
      child: TextField(
        controller: _ctrl,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          prefixIcon: const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20)),
          suffixIcon: _ctrl.text.isNotEmpty
              ? GestureDetector(
                  onTap: () { _ctrl.clear(); widget.onChanged(''); },
                  child: const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18)),
                )
              : null,
          border: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
