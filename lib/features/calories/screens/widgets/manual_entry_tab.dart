import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../../../shared/widgets/fc_text_field.dart';
import '../../providers/calorie_provider.dart';

class ManualEntryTab extends ConsumerStatefulWidget {
  final String       defaultMeal;
  final VoidCallback onAdded;

  const ManualEntryTab({
    super.key,
    required this.defaultMeal,
    required this.onAdded,
  });

  @override
  ConsumerState<ManualEntryTab> createState() => _ManualEntryTabState();
}

class _ManualEntryTabState extends ConsumerState<ManualEntryTab> {
  final _nameCtrl    = TextEditingController();
  final _calCtrl     = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl   = TextEditingController();
  final _fatCtrl     = TextEditingController();
  final _qtyCtrl     = TextEditingController(text: '1');
  final _unitCtrl    = TextEditingController(text: 'serving');

  String _meal  = 'snack';
  String _error = '';

  static const _meals = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  void initState() {
    super.initState();
    _meal = widget.defaultMeal;
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _calCtrl, _proteinCtrl,
                     _carbsCtrl, _fatCtrl, _qtyCtrl, _unitCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    final cals = int.tryParse(_calCtrl.text.trim()) ?? 0;
    if (name.isEmpty || cals == 0) {
      setState(() => _error = 'Food name and calories are required');
      return;
    }
    setState(() => _error = '');

    final ok = await ref.read(calorieProvider.notifier).addFood(
      name:     name,
      calories: cals,
      quantity: double.tryParse(_qtyCtrl.text) ?? 1.0,
      unit:     _unitCtrl.text.trim().isEmpty ? 'serving' : _unitCtrl.text.trim(),
      protein:  double.tryParse(_proteinCtrl.text) ?? 0,
      carbs:    double.tryParse(_carbsCtrl.text)   ?? 0,
      fat:      double.tryParse(_fatCtrl.text)     ?? 0,
      mealType: _meal,
      source:   'manual',
    );

    if (ok && mounted) {
      _nameCtrl.clear(); _calCtrl.clear();
      _proteinCtrl.clear(); _carbsCtrl.clear(); _fatCtrl.clear();
      widget.onAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adding = ref.watch(calorieProvider.select((s) => s.addingFood));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Name
      FCTextField(
        hint:       'Food name (e.g. Dal Tadka, Chicken breast)',
        controller: _nameCtrl,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 10),

      // Calories + qty row
      Row(children: [
        Expanded(flex: 2, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CALORIES *', style: TextStyle(
              fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
              color: AppColors.textTertiary, letterSpacing: 0.9,
            )),
            const SizedBox(height: 5),
            FCTextField(
              hint:        'e.g. 250',
              controller:  _calCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
          ],
        )),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QTY', style: TextStyle(
              fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
              color: AppColors.textTertiary, letterSpacing: 0.9,
            )),
            const SizedBox(height: 5),
            FCTextField(
              hint:        '1',
              controller:  _qtyCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
          ],
        )),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('UNIT', style: TextStyle(
              fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
              color: AppColors.textTertiary, letterSpacing: 0.9,
            )),
            const SizedBox(height: 5),
            FCTextField(
              hint:        'serving',
              controller:  _unitCtrl,
              textInputAction: TextInputAction.next,
            ),
          ],
        )),
      ]),
      const SizedBox(height: 10),

      // Macros row
      Row(children: [
        Expanded(child: _MacroInput('P (g)', _proteinCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _MacroInput('C (g)', _carbsCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _MacroInput('F (g)', _fatCtrl)),
      ]),
      const SizedBox(height: 12),

      // Meal chips
      Row(children: _meals.map((m) {
        final sel = _meal == m;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _meal = m),
          child: Container(
            margin: EdgeInsets.only(right: m != _meals.last ? 6 : 0),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: sel ? AppColors.lime : AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: sel ? AppColors.lime : AppColors.border3,
                width: sel ? 1 : 0.5,
              ),
            ),
            child: Text(
              m[0].toUpperCase() + m.substring(1),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                fontWeight: FontWeight.w600,
                color: sel ? AppColors.onLime : AppColors.textSecondary,
              ),
            ),
          ),
        ));
      }).toList()),

      if (_error.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(_error, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 12, color: AppColors.danger,
        )),
      ],
      const SizedBox(height: 12),

      FCButton(
        label:    adding ? 'Adding...' : 'Add entry',
        loading:  adding,
        fullWidth: true,
        leading:  const Icon(Icons.add_rounded, size: 18, color: AppColors.onLime),
        onPressed: _add,
      ),
    ]);
  }
}

class _MacroInput extends StatelessWidget {
  final String                 label;
  final TextEditingController  ctrl;
  const _MacroInput(this.label, this.ctrl);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
        color: AppColors.textTertiary, letterSpacing: 0.9,
      )),
      const SizedBox(height: 5),
      FCTextField(
        hint:        '0',
        controller:  ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
      ),
    ],
  );
}