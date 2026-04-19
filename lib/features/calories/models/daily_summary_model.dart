class MacroTotals {
  final int    calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const MacroTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory MacroTotals.fromJson(Map<String, dynamic> json) => MacroTotals(
    calories:(json['calories'] as num?)?.toInt()    ?? 0,
    protein: (json['protein']  as num?)?.toDouble() ?? 0.0,
    carbs:   (json['carbs']    as num?)?.toDouble() ?? 0.0,
    fat:     (json['fat']      as num?)?.toDouble() ?? 0.0,
    fiber:   (json['fiber']    as num?)?.toDouble() ?? 0.0,
  );

  static MacroTotals get zero => const MacroTotals(
    calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0,
  );
}

class DailySummaryModel {
  final String               date;
  final MacroTotals          totals;
  final Map<String, dynamic> byMeal; // raw map from backend

  const DailySummaryModel({
    required this.date,
    required this.totals,
    required this.byMeal,
  });

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) =>
      DailySummaryModel(
        date:   json['date']   as String? ?? '',
        totals: MacroTotals.fromJson(
            json['totals'] as Map<String, dynamic>? ?? {}),
        byMeal: json['byMeal'] as Map<String, dynamic>? ?? {},
      );
}

class WeeklyDayModel {
  final String date;
  final int    calories;
  final double protein;
  final double carbs;
  final double fat;
  final int    entries;

  const WeeklyDayModel({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.entries,
  });

  factory WeeklyDayModel.fromJson(Map<String, dynamic> json) => WeeklyDayModel(
    date:    json['date']     as String? ?? '',
    calories:(json['calories'] as num?)?.toInt()    ?? 0,
    protein: (json['protein']  as num?)?.toDouble() ?? 0.0,
    carbs:   (json['carbs']    as num?)?.toDouble() ?? 0.0,
    fat:     (json['fat']      as num?)?.toDouble() ?? 0.0,
    entries: (json['entries']  as num?)?.toInt()    ?? 0,
  );

  String get shortDay {
    final d = DateTime.tryParse(date + 'T00:00:00');
    if (d == null) return '';
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[(d.weekday - 1) % 7];
  }
}