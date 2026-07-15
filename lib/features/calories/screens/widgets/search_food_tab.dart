import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_loader.dart';
import '../../models/food_search_result.dart';
import '../../providers/calorie_provider.dart';

class SearchFoodTab extends ConsumerStatefulWidget {
  final String    defaultMeal;
  final VoidCallback onAdded;

  const SearchFoodTab({
    super.key,
    required this.defaultMeal,
    required this.onAdded,
  });

  @override
  ConsumerState<SearchFoodTab> createState() => _SearchFoodTabState();
}

class _SearchFoodTabState extends ConsumerState<SearchFoodTab> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calorieProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Search input
      Container(
        height: 44,
        decoration: BoxDecoration(
          color:        AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.border3, width: 0.5),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded,
              color: AppColors.textTertiary, size: 18),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _ctrl,
            onChanged: (v) =>
                ref.read(calorieProvider.notifier).onSearchChanged(v),
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText:       'Search foods — try "Dal", "Banana"...',
              hintStyle: TextStyle(
                fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
              ),
              border:         InputBorder.none,
              isDense:        true,
              contentPadding: EdgeInsets.zero,
            ),
          )),
          if (_ctrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                ref.read(calorieProvider.notifier).clearSearch();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.close_rounded,
                    color: AppColors.textTertiary, size: 16),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 10),

      // Results
      if (state.searchLoading)
        const Center(child: Padding(
          padding: EdgeInsets.all(20),
          child: FCLoader(),
        ))
      else if (state.searchResults.isNotEmpty)
        ListView.builder(
          shrinkWrap: true,
          physics:    const NeverScrollableScrollPhysics(),
          itemCount:  state.searchResults.length,
          itemBuilder: (_, i) => _SearchResultTile(
            result:      state.searchResults[i],
            defaultMeal: widget.defaultMeal,
            onAdded:     widget.onAdded,
          ),
        )
      else if (state.searchQuery.isNotEmpty && !state.searchLoading)
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No results found', style: TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
          ))),
        ),
    ]);
  }
}

class _SearchResultTile extends ConsumerStatefulWidget {
  final FoodSearchResult result;
  final String           defaultMeal;
  final VoidCallback     onAdded;

  const _SearchResultTile({
    required this.result,
    required this.defaultMeal,
    required this.onAdded,
  });

  @override
  ConsumerState<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends ConsumerState<_SearchResultTile> {
  bool _expanded = false;
  double _qty    = 1.0;
  String _meal   = 'snack';
  bool   _adding = false;

  @override
  void initState() {
    super.initState();
    _meal = widget.defaultMeal;
  }

  Future<void> _add() async {
    setState(() => _adding = true);
    final macro = widget.result.perServing * _qty;
    final ok    = await ref.read(calorieProvider.notifier).addFood(
      name:     widget.result.name,
      brand:    widget.result.brand,
      quantity: _qty,
      unit:     widget.result.servingSize,
      calories: macro.calories,
      protein:  macro.protein,
      carbs:    macro.carbs,
      fat:      macro.fat,
      fiber:    macro.fiber,
      mealType: _meal,
      source:   'search',
    );
    if (mounted) {
      setState(() => _adding = false);
      if (ok) widget.onAdded();
    }
  }

  static const _meals = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  Widget build(BuildContext context) {
    final r     = widget.result;
    final macro = r.perServing * _qty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:        AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border3, width: 0.5),
      ),
      child: Column(children: [
        // Main row
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name, style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                  )),
                  Text('${r.brand.isNotEmpty ? '${r.brand} · ' : ''}${r.servingSize}',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              )),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${macro.calories}', style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 15,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                const Text('kcal', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 10,
                  color: AppColors.textTertiary,
                )),
              ]),
              const SizedBox(width: 8),
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textTertiary, size: 18,
              ),
            ]),
          ),
        ),

        // Expanded config
        if (_expanded) ...[
          const Divider(height: 1, color: AppColors.border2),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              // Macro strip
              Row(children: [
                _MacroPill('P', macro.protein.round(), AppColors.accent5),
                const SizedBox(width: 6),
                _MacroPill('C', macro.carbs.round(),   const Color(0xFF22C55E)),
                const SizedBox(width: 6),
                _MacroPill('F', macro.fat.round(),     const Color(0xFFF59E0B)),
              ]),
              const SizedBox(height: 12),

              // Qty stepper + meal selector
              Row(children: [
                const Text('Servings', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  color: AppColors.textSecondary,
                )),
                const Spacer(),
                _QtyBtn(
                  icon: Icons.remove_rounded,
                  onTap: () => setState(() =>
                      _qty = (_qty - 0.5).clamp(0.5, 99.0)),
                ),
                SizedBox(
                  width: 40,
                  child: Text('$_qty', textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                ),
                _QtyBtn(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _qty = _qty + 0.5),
                ),
              ]),
              const SizedBox(height: 10),

              // Meal chips
              Row(children: _meals.map((m) {
                final sel = _meal == m;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _meal = m),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: m != _meals.last ? 5 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.limeDim : AppColors.surface3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: sel ? AppColors.limeBorder : AppColors.border3,
                        width: sel ? 1 : 0.5,
                      ),
                    ),
                    child: Text(
                      m[0].toUpperCase() + m.substring(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: sel ? AppColors.lime : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 12),

              // Add button
              GestureDetector(
                onTap: _adding ? null : _add,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color:        AppColors.lime,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _adding
                    ? const Center(child: SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onLime,
                        ),
                      ))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_rounded, color: AppColors.onLime, size: 16),
                        SizedBox(width: 6),
                        Text('Add to log', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w700, color: AppColors.onLime,
                        )),
                      ]),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final int    value;
  final Color  color;
  const _MacroPill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color:        color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text('$label: ${value}g', style: TextStyle(
      fontFamily: 'Inter', fontSize: 10,
      fontWeight: FontWeight.w600, color: color,
    )),
  );
}

class _QtyBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color:        AppColors.surface4,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 16),
    ),
  );
}