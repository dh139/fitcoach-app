import 'dart:convert';

class UserModel {
  final String  id;
  final String  name;
  final String  email;
  final int?    age;
  final double? weight;
  final double? height;
  final String? gender;
  final String  fitnessGoal;
  final String  activityLevel;
  final int     xp;
  final String  level;
  final int     streak;
  final int     streakFreezeCount;
  final int     totalWorkouts;
  final int     totalCaloriesBurned;
  final int     totalMinutesWorked;
  final String? lastWorkoutDate;
  final String? avatar;
  final String  createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.weight,
    this.height,
    this.gender,
    required this.fitnessGoal,
    required this.activityLevel,
    required this.xp,
    required this.level,
    required this.streak,
    required this.streakFreezeCount,
    required this.totalWorkouts,
    required this.totalCaloriesBurned,
    required this.totalMinutesWorked,
    this.lastWorkoutDate,
    this.avatar,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:                  json['_id']             as String,
    name:                json['name']            as String,
    email:               json['email']           as String,
    age:                 json['age']             as int?,
    weight:             (json['weight']          as num?)?.toDouble(),
    height:             (json['height']          as num?)?.toDouble(),
    gender:              json['gender']          as String?,
    fitnessGoal:        (json['fitnessGoal']     as String?) ?? 'stay_fit',
    activityLevel:      (json['activityLevel']   as String?) ?? 'moderate',
    xp:                 (json['xp']              as int?)    ?? 0,
    level:              (json['level']           as String?) ?? 'beginner',
    streak:             (json['streak']          as int?)    ?? 0,
    streakFreezeCount:  (json['streakFreezeCount'] as int?)  ?? 0,
    totalWorkouts:      (json['totalWorkouts']   as int?)    ?? 0,
    totalCaloriesBurned:(json['totalCaloriesBurned'] as int?) ?? 0,
    totalMinutesWorked: (json['totalMinutesWorked'] as int?) ?? 0,
    lastWorkoutDate:     json['lastWorkoutDate'] as String?,
    avatar:              json['avatar']          as String?,
    createdAt:          (json['createdAt']       as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id':                id,
    'name':               name,
    'email':              email,
    'age':                age,
    'weight':             weight,
    'height':             height,
    'gender':             gender,
    'fitnessGoal':        fitnessGoal,
    'activityLevel':      activityLevel,
    'xp':                 xp,
    'level':              level,
    'streak':             streak,
    'streakFreezeCount':  streakFreezeCount,
    'totalWorkouts':      totalWorkouts,
    'totalCaloriesBurned':totalCaloriesBurned,
    'totalMinutesWorked': totalMinutesWorked,
    'lastWorkoutDate':    lastWorkoutDate,
    'avatar':             avatar,
    'createdAt':          createdAt,
  };

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String s) =>
      UserModel.fromJson(jsonDecode(s) as Map<String, dynamic>);

  UserModel copyWith({
    String?  name,
    int?     age,
    double?  weight,
    double?  height,
    String?  gender,
    String?  fitnessGoal,
    String?  activityLevel,
    int?     xp,
    String?  level,
    int?     streak,
    int?     streakFreezeCount,
    int?     totalWorkouts,
    int?     totalCaloriesBurned,
    int?     totalMinutesWorked,
    String?  lastWorkoutDate,
    String?  avatar,
  }) => UserModel(
    id:                  id,
    name:                name               ?? this.name,
    email:               email,
    age:                 age                ?? this.age,
    weight:              weight             ?? this.weight,
    height:              height             ?? this.height,
    gender:              gender             ?? this.gender,
    fitnessGoal:         fitnessGoal        ?? this.fitnessGoal,
    activityLevel:       activityLevel      ?? this.activityLevel,
    xp:                  xp                 ?? this.xp,
    level:               level              ?? this.level,
    streak:              streak             ?? this.streak,
    streakFreezeCount:   streakFreezeCount  ?? this.streakFreezeCount,
    totalWorkouts:       totalWorkouts      ?? this.totalWorkouts,
    totalCaloriesBurned: totalCaloriesBurned?? this.totalCaloriesBurned,
    totalMinutesWorked:  totalMinutesWorked ?? this.totalMinutesWorked,
    lastWorkoutDate:     lastWorkoutDate    ?? this.lastWorkoutDate,
    avatar:              avatar             ?? this.avatar,
    createdAt:           createdAt,
  );

  // Helpers
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get readableGoal => fitnessGoal
      .split('_').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  bool get hasWorkedOutToday {
    if (lastWorkoutDate == null) return false;
    final last  = DateTime.tryParse(lastWorkoutDate!) ?? DateTime(2000);
    final today = DateTime.now();
    return last.year == today.year &&
           last.month == today.month &&
           last.day == today.day;
  }
}