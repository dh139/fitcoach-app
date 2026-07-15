import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/models/user_model.dart';
import '../../../../shared/widgets/level_badge.dart';

class ProfileAvatar extends StatelessWidget {
  final UserModel user;
  final double    size;

  const ProfileAvatar({super.key, required this.user, this.size = 84});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(alignment: Alignment.bottomRight, children: [
        Container(
          width:  size,
          height: size,
          decoration: BoxDecoration(
            shape:  BoxShape.circle,
            color:  AppColors.lime,
            border: Border.all(
              color: AppColors.limeBorder,
              width: 2.5,
            ),
          ),
          child: Center(child: Text(
            user.initials,
            style: TextStyle(
              fontFamily:  'Inter',
              fontSize:    size * 0.32,
              fontWeight:  FontWeight.w800,
              color:       AppColors.bg,
            ),
          )),
        ),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color:  AppColors.surface1,
            shape:  BoxShape.circle,
            border: Border.all(color: AppColors.slate, width: 1.0),
          ),
          child: const Icon(Icons.edit_rounded,
              color: AppColors.textSecondary, size: 14),
        ),
      ]),
      const SizedBox(height: 12),
      Text(user.name, style: const TextStyle(
        fontFamily:    'Outfit',
        fontSize:      22,
        fontWeight:    FontWeight.w700,
        color:         AppColors.textPrimary,
        letterSpacing: -0.5,
      )),
      const SizedBox(height: 6),
      Row(mainAxisSize: MainAxisSize.min, children: [
        LevelBadge(level: user.level, fontSize: 11),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color:        AppColors.surface2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${user.xp.toLocaleString()} XP',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ]),
    ]);
  }
}

extension on int {
  String toLocaleString() {
    final s   = toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}