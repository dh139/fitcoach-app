class MacroValues {
  final int    calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const MacroValues({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory MacroValues.fromJson(Map<String, dynamic> json) => MacroValues(
    calories:(json['calories'] as num?)?.toInt()    ?? 0,
    protein: (json['protein']  as num?)?.toDouble() ?? 0.0,
    carbs:   (json['carbs']    as num?)?.toDouble() ?? 0.0,
    fat:     (json['fat']      as num?)?.toDouble() ?? 0.0,
    fiber:   (json['fiber']    as num?)?.toDouble() ?? 0.0,
  );

  MacroValues operator *(double factor) => MacroValues(
    calories: (calories * factor).round(),
    protein:  protein  * factor,
    carbs:    carbs    * factor,
    fat:      fat      * factor,
    fiber:    fiber    * factor,
  );
}

class FoodSearchResult {
  final String      name;
  final String      brand;
  final String      servingSize;
  final String      imageUrl;
  final MacroValues perServing;
  final MacroValues per100g;

  const FoodSearchResult({
    required this.name,
    required this.brand,
    required this.servingSize,
    required this.imageUrl,
    required this.perServing,
    required this.per100g,
  });

  factory FoodSearchResult.fromJson(Map<String, dynamic> json) =>
      FoodSearchResult(
        name:        json['name']        as String? ?? '',
        brand:       json['brand']       as String? ?? '',
        servingSize: json['servingSize'] as String? ?? '100g',
        imageUrl:    json['imageUrl']    as String? ?? '',
        perServing: MacroValues.fromJson(
            json['perServing'] as Map<String, dynamic>? ?? {}),
        per100g: MacroValues.fromJson(
            json['per100g']    as Map<String, dynamic>? ?? {}),
      );
}

// AI photo analysis item
class PhotoFoodItem {
  final String name;
  final String estimatedQuantity;
  final int    calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String confidence; // high | medium | low

  const PhotoFoodItem({
    required this.name,
    required this.estimatedQuantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.confidence,
  });

  factory PhotoFoodItem.fromJson(Map<String, dynamic> json) => PhotoFoodItem(
    name:              json['name']              as String? ?? '',
    estimatedQuantity: json['estimatedQuantity'] as String? ?? '1 serving',
    calories:         (json['calories']          as num?)?.toInt()    ?? 0,
    protein:          (json['protein']           as num?)?.toDouble() ?? 0.0,
    carbs:            (json['carbs']             as num?)?.toDouble() ?? 0.0,
    fat:              (json['fat']               as num?)?.toDouble() ?? 0.0,
    fiber:            (json['fiber']             as num?)?.toDouble() ?? 0.0,
    confidence:        json['confidence']        as String? ?? 'medium',
  );
}

class PhotoAnalysisResult {
  final bool               success;
  final List<PhotoFoodItem> items;
  final int                totalCalories;
  final String             notes;
  final String?            message; // error message if failed

  const PhotoAnalysisResult({
    required this.success,
    required this.items,
    required this.totalCalories,
    required this.notes,
    this.message,
  });

  factory PhotoAnalysisResult.fromJson(Map<String, dynamic> data) =>
      PhotoAnalysisResult(
        success:       (data['success']       as bool?) ?? false,
        totalCalories:(data['totalCalories']  as num?)?.toInt() ?? 0,
        notes:         data['notes']          as String? ?? '',
        message:       data['message']        as String?,
        items: ((data['items'] as List<dynamic>?) ?? [])
            .map((e) => PhotoFoodItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}