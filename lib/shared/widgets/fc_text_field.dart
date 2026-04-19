import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FCTextField extends StatelessWidget {
  final String          hint;
  final Widget?         prefixIcon;
  final Widget?         suffixIcon;
  final bool            obscureText;
  final TextEditingController? controller;
  final String?         Function(String?)? validator;
  final TextInputType?  keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback?   onTap;
  final bool            readOnly;
  final int?            maxLines;
  final FocusNode?      focusNode;

  const FCTextField({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText    = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.readOnly       = false,
    this.maxLines       = 1,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:       controller,
      obscureText:      obscureText,
      validator:        validator,
      keyboardType:     keyboardType,
      textInputAction:  textInputAction,
      onChanged:        onChanged,
      onTap:            onTap,
      readOnly:         readOnly,
      maxLines:         maxLines,
      focusNode:        focusNode,
      style: const TextStyle(
        fontFamily: 'Inter', fontSize: 14,
        color: AppColors.textPrimary, fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText:    hint,
        prefixIcon:  prefixIcon != null
          ? Padding(padding: const EdgeInsets.only(left:12, right:8), child: prefixIcon)
          : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon:  suffixIcon,
        filled:      true,
        fillColor:   AppColors.surface2,
        border:      OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.border3, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.border3, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.limeBorder, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.dangerBorder, width: 1),
        ),
        hintStyle: const TextStyle(
          fontFamily:'Inter', fontSize:13, color:AppColors.textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal:14, vertical:12),
      ),
    );
  }
}