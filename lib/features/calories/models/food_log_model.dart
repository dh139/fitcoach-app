class FoodLogModel {
  final String  id;
  final String  name;
  final String  brand;
  final double  quantity;
  final String  unit;
  final int     calories;
  final double  protein;
  final double  carbs;
  final double  fat;
  final double  fiber;
  final String  mealType;
  final String  source;
  final String  loggedDate;
  final String  createdAt;

  const FoodLogModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.mealType,
    required this.source,
    required this.loggedDate,
    required this.createdAt,
  });

  factory FoodLogModel.fromJson(Map<String, dynamic> json) => FoodLogModel(
    id:          json['_id']         as String? ?? '',
    name:        json['name']        as String? ?? '',
    brand:       json['brand']       as String? ?? '',
    quantity:   (json['quantity']    as num?)?.toDouble() ?? 1.0,
    unit:        json['unit']        as String? ?? 'serving',
    calories:   (json['calories']    as num?)?.toInt()    ?? 0,
    protein:    (json['protein']     as num?)?.toDouble() ?? 0.0,
    carbs:      (json['carbs']       as num?)?.toDouble() ?? 0.0,
    fat:        (json['fat']         as num?)?.toDouble() ?? 0.0,
    fiber:      (json['fiber']       as num?)?.toDouble() ?? 0.0,
    mealType:    json['mealType']    as String? ?? 'snack',
    source:      json['source']      as String? ?? 'manual',
    loggedDate:  json['loggedDate']  as String? ?? '',
    createdAt:   json['createdAt']   as String? ?? '',
  );

  String get capitalizedMeal =>
      mealType.isEmpty ? 'Snack'
      : mealType[0].toUpperCase() + mealType.substring(1);
}