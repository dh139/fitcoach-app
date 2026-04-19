import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/improvement_score_model.dart';

class SmartAlertsList extends StatefulWidget {
  final List<SmartAlert>      alerts;
  final ValueChanged<String>? onActionTap;

  const SmartAlertsList({
    super.key,
    required this.alerts,
    this.onActionTap,
  });

  @override
  State<SmartAlertsList> createState() => _SmartAlertsListState();
}

class _SmartAlertsListState extends State<SmartAlertsList> {
  final _dismissed = <int>{};

  @override
  Widget build(BuildContext context) {
    final visible = widget.alerts
        .asMap()
        .entries
        .where((e) => !_dismissed.contains(e.key))
        .toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      children: visible.map((entry) {
        final i     = entry.key;
        final alert = entry.value;
        final (bg, border, textColor, icon) = _style(alert.type);

        return Dismissible(
          key:       Key('alert_$i'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => setState(() => _dismissed.add(i)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color:        bg,
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: border, width: 0.5),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Icon(icon, color: textColor, size: 15),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.message, style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    color: textColor, height: 1.4,
                  )),
                  if (alert.action.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => widget.onActionTap?.call(alert.action),
                      child: Text(
                        '${alert.action} →',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor.withOpacity(0.8),
                          decoration: TextDecoration.underline,
                          decorationColor: textColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ],
              )),
              GestureDetector(
                onTap: () => setState(() => _dismissed.add(i)),
                child: Icon(Icons.close_rounded,
                    color: textColor.withOpacity(0.5), size: 14),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  (Color, Color, Color, IconData) _style(String type) => switch (type) {
    'urgent'   => (AppColors.dangerDim, AppColors.dangerBorder,
                   const Color(0xFFFF8888), Icons.error_outline_rounded),
    'warning'  => (AppColors.warnDim,   AppColors.warn.withOpacity(0.3),
                   const Color(0xFFFCD34D), Icons.warning_amber_rounded),
    'positive' => (AppColors.limeDim,   AppColors.limeBorder,
                   AppColors.lime, Icons.trending_up_rounded),
    _          => (const Color(0x1A3B82F6), const Color(0x333B82F6),
                   const Color(0xFF93C5FD), Icons.info_outline_rounded),
  };
}