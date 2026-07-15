const Workout = require('../models/Workout');
const FoodLog = require('../models/FoodLog');
const User    = require('../models/User');

/**
 * Improvement Score Formula:
 *   Weight progress  × 30%
 *   Consistency      × 30%
 *   Strength/quality × 20%
 *   Diet adherence   × 20%
 */
const calculateImprovementScore = async (userId) => {
  const user = await User.findById(userId).lean();
  if (!user) throw new Error('User not found');

  const now        = new Date();
  const thirtyDaysAgo = new Date(now - 30 * 24 * 60 * 60 * 1000);
  const sixtyDaysAgo  = new Date(now - 60 * 24 * 60 * 60 * 1000);

  // ── Fetch data ──────────────────────────────────────────────────────────────
  const [recentWorkouts, olderWorkouts, recentFood] = await Promise.all([
    Workout.find({
      user:      userId,
      status:    'completed',
      isVerified: true,
      startTime: { $gte: thirtyDaysAgo },
    }).lean(),

    Workout.find({
      user:      userId,
      status:    'completed',
      isVerified: true,
      startTime: { $gte: sixtyDaysAgo, $lt: thirtyDaysAgo },
    }).lean(),

    FoodLog.find({
      user:       userId,
      loggedDate: { $gte: thirtyDaysAgo.toISOString().slice(0, 10) },
    }).lean(),
  ]);

  const breakdown = {};

  // ── 1. Weight progress (30%) ────────────────────────────────────────────────
  // Proxy: XP earned this month vs last (we don't track body weight directly yet)
  // Score based on whether user is progressing toward their goal
  let weightScore = 50; // neutral default
  const totalRecentXP = recentWorkouts.reduce((s, w) => s + (w.xpEarned || 0), 0);
  const totalOlderXP  = olderWorkouts.reduce((s, w)  => s + (w.xpEarned || 0), 0);

  if (totalOlderXP === 0 && totalRecentXP > 0) {
    weightScore = 80; // just starting out — reward
  } else if (totalOlderXP > 0) {
    const ratio = totalRecentXP / totalOlderXP;
    weightScore = Math.min(100, Math.round(ratio * 70)); // cap at 100
  }
  breakdown.weightProgress = { score: weightScore, weight: 0.30,
    detail: `XP this month: ${totalRecentXP} vs last month: ${totalOlderXP}` };

  // ── 2. Consistency (30%) ────────────────────────────────────────────────────
  const workoutDays  = new Set(recentWorkouts.map((w) =>
    new Date(w.startTime).toISOString().slice(0, 10)
  )).size;
  const consistencyScore = Math.min(100, Math.round((workoutDays / 30) * 100 * 2.5));
  // *2.5 so 12 days/month (3x/week) = ~100
  breakdown.consistency = { score: consistencyScore, weight: 0.30,
    detail: `${workoutDays} unique workout days in last 30 days` };

  // ── 3. Strength / quality increase (20%) ────────────────────────────────────
  const recentAvgQ = recentWorkouts.length
    ? recentWorkouts.reduce((s, w) => s + (w.verificationDetails?.qualityScore || 0), 0) / recentWorkouts.length
    : 0;
  const olderAvgQ  = olderWorkouts.length
    ? olderWorkouts.reduce((s, w) => s + (w.verificationDetails?.qualityScore || 0), 0) / olderWorkouts.length
    : recentAvgQ; // no comparison data — treat as neutral

  let strengthScore = Math.round(recentAvgQ); // base from current quality
  if (olderAvgQ > 0 && recentAvgQ > olderAvgQ) {
    // Bonus for improvement
    strengthScore = Math.min(100, strengthScore + 15);
  }
  breakdown.strengthIncrease = { score: strengthScore, weight: 0.20,
    detail: `Avg quality score: ${Math.round(recentAvgQ)}/100 (prev: ${Math.round(olderAvgQ)}/100)` };

  // ── 4. Diet adherence (20%) ─────────────────────────────────────────────────
  const foodDays    = new Set(recentFood.map((f) => f.loggedDate)).size;
  // Reward consistent logging (proxy for diet adherence)
  const loggingRate = foodDays / 30;
  let dietScore     = Math.round(loggingRate * 100);

  // Bonus: if avg calories are within 20% of a sensible target (1800-2500)
  if (recentFood.length > 0) {
    const avgCal = recentFood.reduce((s, f) => s + f.calories, 0) / Math.max(1, foodDays);
    if (avgCal >= 1400 && avgCal <= 2800) dietScore = Math.min(100, dietScore + 20);
  }
  breakdown.dietAdherence = { score: dietScore, weight: 0.20,
    detail: `Food logged ${foodDays}/30 days` };

  // ── Composite ───────────────────────────────────────────────────────────────
  const composite = Math.round(
    weightScore      * 0.30 +
    consistencyScore * 0.30 +
    strengthScore    * 0.20 +
    dietScore        * 0.20
  );

  // ── Smart alerts ────────────────────────────────────────────────────────────
  const alerts = [];

  if (workoutDays < 4) {
    alerts.push({
      type:    'warning',
      message: 'You are losing consistency — less than 4 workouts this month',
      action:  'Schedule a workout for today',
    });
  }

  const lastWorkout = user.lastWorkoutDate ? new Date(user.lastWorkoutDate) : null;
  const daysSinceLast = lastWorkout
    ? Math.floor((now - lastWorkout) / 86400000)
    : 999;

  if (daysSinceLast >= 5) {
    alerts.push({
      type:    'urgent',
      message: `You haven't worked out in ${daysSinceLast} days — XP decay is active`,
      action:  'Do a quick 15-minute workout now',
    });
  }

  if (strengthScore > 70 && consistencyScore > 70) {
    alerts.push({
      type:    'positive',
      message: 'You are improving faster than average — keep this momentum!',
      action:  'Try increasing your workout intensity',
    });
  }

  if (dietScore < 30) {
    alerts.push({
      type:    'info',
      message: 'Logging meals helps your AI reports become more accurate',
      action:  'Log today\'s breakfast to start',
    });
  }

  if (user.streak >= 7) {
    alerts.push({
      type:    'positive',
      message: `${user.streak}-day streak! You're in the top tier of consistency`,
      action:  'Maintain your streak — work out again tomorrow',
    });
  }

  return {
    composite,
    breakdown,
    alerts,
    meta: {
      recentWorkouts:  recentWorkouts.length,
      olderWorkouts:   olderWorkouts.length,
      foodDaysLogged:  foodDays,
      daysSinceLast,
      streak:          user.streak,
    },
  };
};

/**
 * Build a compact fitness context string to inject into the chat system prompt.
 */
const buildCoachContext = async (userId) => {
  const user  = await User.findById(userId).lean();
  const score = await calculateImprovementScore(userId);

  return {
    systemPrompt: `You are FitCoach AI — a friendly, expert personal fitness coach with deep knowledge of strength training, nutrition, and habit formation. You specialise in Indian-friendly diet advice.

USER PROFILE:
- Name: ${user.name}
- Age: ${user.age || 'not set'}, Weight: ${user.weight ? user.weight + 'kg' : 'not set'}, Height: ${user.height ? user.height + 'cm' : 'not set'}
- Fitness goal: ${user.fitnessGoal?.replace(/_/g, ' ') || 'general fitness'}
- Current level: ${user.level} | Total XP: ${user.xp}
- Current streak: ${user.streak} days
- Total workouts: ${user.totalWorkouts}

IMPROVEMENT SCORE: ${score.composite}/100
- Weight progress score:  ${score.breakdown.weightProgress.score}/100 (${score.breakdown.weightProgress.detail})
- Consistency score:      ${score.breakdown.consistency.score}/100 (${score.breakdown.consistency.detail})
- Strength/quality score: ${score.breakdown.strengthIncrease.score}/100 (${score.breakdown.strengthIncrease.detail})
- Diet adherence score:   ${score.breakdown.dietAdherence.score}/100 (${score.breakdown.dietAdherence.detail})
- Days since last workout: ${score.meta.daysSinceLast}

COACHING GUIDELINES:
- Keep responses concise, warm, and action-focused (2-4 sentences unless asked for more)
- Give specific, practical advice tailored to this user's data
- Suggest Indian foods (dal, paneer, roti, rice, etc.) when giving nutrition advice
- If the user seems discouraged, be motivational before being prescriptive
- Never make medical diagnoses — recommend a doctor for health concerns
- Always end with one concrete next action`,
    score,
  };
};

module.exports = { calculateImprovementScore, buildCoachContext };