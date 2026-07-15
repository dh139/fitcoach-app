import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'manual_entry_tab.dart';
import 'photo_analyze_tab.dart';

class AddFoodSheet extends ConsumerStatefulWidget {
  final String defaultMeal;

  const AddFoodSheet({super.key, required this.defaultMeal});

  static Future<void> show(BuildContext context, {String defaultMeal = 'snack'}) =>
      showModalBottomSheet(
        context:            context,
        isScrollControlled: true,
        backgroundColor:    Colors.transparent,
        builder: (_) => ProviderScope(
          parent: ProviderScope.containerOf(context),
          child: AddFoodSheet(defaultMeal: defaultMeal),
        ),
      );

  @override
  ConsumerState<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<AddFoodSheet>
    with SingleTickerProviderStateMixin {

  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  void _onAdded() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 4),
          width: 44, height: 4,
          decoration: BoxDecoration(
            color:        AppColors.border3,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.coachDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant_rounded, color: AppColors.coach, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Add food', style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                )),
                Text('Log your meal', style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textTertiary,
                )),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border2, width: 0.5),
                ),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textTertiary, size: 18),
              ),
            ),
          ]),
        ),

        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color:        AppColors.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border2, width: 0.5),
          ),
          child: TabBar(
            controller:    _tabs,
            indicator: BoxDecoration(
              color:        AppColors.surface1,
              borderRadius: BorderRadius.circular(13),
              border:       Border.all(color: AppColors.border2, width: 0.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            indicatorSize:  TabBarIndicatorSize.tab,
            dividerColor:   Colors.transparent,
            labelColor:     AppColors.textPrimary,
            unselectedLabelColor: AppColors.textTertiary,
            labelStyle: const TextStyle(
              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, size: 14),
                    SizedBox(width: 6),
                    Text('Photo AI'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, size: 14),
                    SizedBox(width: 6),
                    Text('Manual'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 1, color: AppColors.border2),

        // Tab content
        Expanded(child: TabBarView(
          controller: _tabs,
          children: [
            SingleChildScrollView(padding: const EdgeInsets.all(20),
              child: PhotoAnalyzeTab(
                defaultMeal: widget.defaultMeal,
                onAdded:     _onAdded,
              ),
            ),
            SingleChildScrollView(padding: const EdgeInsets.all(20),
              child: ManualEntryTab(
                defaultMeal: widget.defaultMeal,
                onAdded:     _onAdded,
              ),
            ),
          ],
        )),
      ]),
    );
  }
}