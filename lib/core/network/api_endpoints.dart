class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const register      = '/auth/register';
  static const login         = '/auth/login';
  static const me            = '/auth/me';
  static const updateProfile = '/auth/update-profile';

  // Exercises
  static const exercises      = '/exercises';
  static const exerciseFilters= '/exercises/meta/filters';
  static const myFavorites    = '/exercises/user/favorites';
  static String favoriteById(String id) => '/exercises/$id/favorite';
  static String exerciseById(String id) => '/exercises/$id';

  // Workout
  static const workoutStart    = '/workout/start';
  static const workoutComplete = '/workout/complete';
  static const workoutHistory  = '/workout/history';
  static const workoutStats    = '/workout/stats';

  // XP
  static const xpProfile  = '/xp/profile';
  static const xpHistory  = '/xp/history';
  static const streakFreeze= '/xp/use-streak-freeze';

  // Leaderboard
  static const leaderboard      = '/leaderboard';
  static const leaderboardMyStats= '/leaderboard/my-stats';

  // Calories
  static const calorieSearch   = '/calories/search';
  static const calorieAnalyze  = '/calories/analyze-photo';
  static const calorieLog      = '/calories/log';
  static const calorieWeekly   = '/calories/weekly';
  static String calorieLogById(String id) => '/calories/log/$id';

  // Reports
  static String report(String type) => '/report/$type';
  static const reportHistory = '/report/history';

  // Coach
  static const coachChat        = '/coach/chat';
  static const coachHistory     = '/coach/history';
  static const improvementScore = '/coach/improvement-score';
  static const dailyAdvice      = '/coach/daily-advice';

  // Challenges
  static const challenges = '/challenges';
  static String claimChallenge(String id) => '/challenges/$id/claim';

  // Rivals
  static const rivals            = '/rivals';
  static const rivalSuggestions  = '/rivals/suggestions';
  static String challengeUser(String id) => '/rivals/challenge/$id';
  static String respondRival(String id)  => '/rivals/$id/respond';
}