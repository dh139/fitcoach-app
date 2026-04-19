import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum ReportSectionType { highlight, improvement, action, text }

class ReportSectionTile extends StatelessWidget {
  final String            title;
  final IconData          icon;
  final Color             iconColor;
  final Color             iconBg;
  final List<String>      items;
  final ReportSectionType type;
  final String?           bodyText;

  const ReportSectionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.items    = const [],
    this.type     = ReportSectionType.text,
    this.bodyText,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent =
        (items.isNotEmpty) || (bodyText != null && bodyText!.isNotEmpty);
    if (!hasContent) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color:        iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 10),
          Text(title.toUpperCase(), style: const TextStyle(
            fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700,
            color: AppColors.textTertiary, letterSpacing: 0.8,
          )),
        ]),
        const SizedBox(height: 14),

        // Body text
        if (bodyText != null && bodyText!.isNotEmpty)
          Text(bodyText!, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 13,
            color: AppColors.textSecondary, height: 1.6,
          )),

        // Bullet list
        if (items.isNotEmpty)
          Column(children: items.asMap().entries.map((e) {
            final (dotColor, dotIcon) = switch (type) {
              ReportSectionType.highlight   =>
                (AppColors.lime,  Icons.check_rounded),
              ReportSectionType.improvement =>
                (AppColors.warn,  Icons.priority_high_rounded),
              ReportSectionType.action      =>
                (AppColors.coach, Icons.arrow_forward_rounded),
              ReportSectionType.text        =>
                (AppColors.textTertiary, Icons.circle),
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 20, height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color:        dotColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(dotIcon, color: dotColor, size: 11),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  color: AppColors.textSecondary, height: 1.55,
                ))),
              ]),
            );
          }).toList()),
      ]),
    );
  }
}