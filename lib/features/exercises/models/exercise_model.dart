class ExerciseModel {
  final String       id;
  final String       exerciseId;
  final String       name;
  final String       bodyPart;
  final String       equipment;
  final String       gifUrl;
  final String       target;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String       difficulty;
  final int          caloriesPerMinute;

  const ExerciseModel({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.target,
    required this.secondaryMuscles,
    required this.instructions,
    required this.difficulty,
    required this.caloriesPerMinute,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
    id:                json['_id']               as String? ?? '',
    exerciseId:        json['exerciseId']         as String? ?? '',
    name:              json['name']               as String? ?? '',
    bodyPart:          json['bodyPart']           as String? ?? '',
    equipment:         json['equipment']          as String? ?? '',
    gifUrl:            json['gifUrl']             as String? ?? '',
    target:            json['target']             as String? ?? '',
    secondaryMuscles: (json['secondaryMuscles']   as List<dynamic>?)
                          ?.map((e) => e as String).toList() ?? [],
    instructions:     (json['instructions']       as List<dynamic>?)
                          ?.map((e) => e as String).toList() ?? [],
    difficulty:        json['difficulty']         as String? ?? 'intermediate',
    caloriesPerMinute:(json['caloriesPerMinute']  as num?)?.toInt() ?? 6,
  );

  // Helpers
  String get capitalizedName =>
      name.split(' ').map((w) => w.isEmpty ? w :
        '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  String get capitalizedBodyPart =>
      bodyPart.split(' ').map((w) => w.isEmpty ? w :
        '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  bool get hasGif => gifUrl.isNotEmpty;
}

// Filter options returned from /exercises/meta/filters
class ExerciseFiltersModel {
  final List<String> bodyParts;
  final List<String> equipment;
  final List<String> targets;
  final List<String> difficulties;

  const ExerciseFiltersModel({
    required this.bodyParts,
    required this.equipment,
    required this.targets,
    required this.difficulties,
  });

  factory ExerciseFiltersModel.fromJson(Map<String, dynamic> json) =>
      ExerciseFiltersModel(
        bodyParts:    (json['bodyParts']    as List<dynamic>?)?.cast<String>() ?? [],
        equipment:    (json['equipment']    as List<dynamic>?)?.cast<String>() ?? [],
        targets:      (json['targets']      as List<dynamic>?)?.cast<String>() ?? [],
        difficulties: (json['difficulties'] as List<dynamic>?)?.cast<String>()
                      ?? ['beginner', 'intermediate', 'advanced'],
      );

  static ExerciseFiltersModel get empty => const ExerciseFiltersModel(
    bodyParts: [], equipment: [], targets: [], difficulties: [],
  );
}