import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class FCFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isVisible;

  const FCFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.isVisible = true,
  });

  static const _items = [
    (label: 'Home',       icon: Icons.home_rounded),
    (label: 'Exercise',   icon: Icons.fitness_center_rounded),
    (label: 'Statistics', icon: Icons.bar_chart_rounded),
    (label: 'Profile',    icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final disableAnims = MediaQuery.disableAnimationsOf(context);
    final bottomPad    = MediaQuery.of(context).padding.bottom;

    return AnimatedSlide(
      duration: disableAnims ? Duration.zero : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      offset: isVisible ? Offset.zero : const Offset(0, 1.2),
      child: AnimatedOpacity(
        duration: disableAnims ? Duration.zero : const Duration(milliseconds: 220),
        opacity: isVisible ? 1.0 : 0.0,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 14),
          child: LayoutBuilder(builder: (context, c) {
            return Container(
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Stack(
                  children: [
                    // Sliding pill behind active item
                    AnimatedPositioned(
                      duration: disableAnims ? Duration.zero : const Duration(milliseconds: 380),
                      curve: Curves.easeOutQuart,
                      top: 8,
                      bottom: 8,
                      left: 8 + (selectedIndex * ((c.maxWidth - 16) / _items.length)),
                      width: (c.maxWidth - 16) / _items.length,
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_items.length, (i) {
                        final active = i == selectedIndex;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTap(i),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              style: AppTextStyles.label.copyWith(
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                color: active ? AppColors.textPrimary : Colors.white60,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeOutBack,
                                    scale: active ? 1.06 : 1.0,
                                    child: Icon(
                                      _items[i].icon,
                                      size: 22,
                                      color: active ? AppColors.textPrimary : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_items[i].label),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
