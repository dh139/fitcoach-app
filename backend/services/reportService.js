const Groq    = require('groq-sdk');
const Workout = require('../models/Workout');
const FoodLog = require('../models/FoodLog');
const XpLog   = require('../models/XpLog');
const User    = require('../models/User');

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

// ─── Period helpers ───────────────────────────────────────────────────────────

const getPeriodBounds = (type, periodKey) => {
  const now = new Date();

  if (type === 'daily') {
    const start = new Date(periodKey + 'T00:00:00.000Z');
    const end   = new Date(periodKey + 'T23:59:59.999Z');
    return { start, end };
  }

  if (type === 'weekly') {
    // periodKey = "2024-W42"
    const [year, week] = periodKey.split('-W').map(Number);
    const jan1  = new Date(Date.UTC(year, 0, 1));
    const start = new Date(jan1.getTime() + (week - 1) * 7 * 86400000);
    // Adjust to Monday
    const day   = start.getUTCDay() || 7;
    start.setUTCDate(start.getUTCDate() - day + 1);
    const end   = new Date(start.getTime() + 7 * 86400000 - 1);
    return { start, end };
  }

  if (type === 'monthly') {
    const [year, month] = periodKey.split('-').map(Number);
    const start = new Date(Date.UTC(year, month - 1, 1));
    const end   = new Date(Date.UTC(year, month, 0, 23, 59, 59, 999));
    return { start, end };
  }

  if (type === 'yearly') {
    const year  = Number(periodKey);
    const start = new Date(Date.UTC(year, 0, 1));
    const end   = new Date(Date.UTC(year, 11, 31, 23, 59, 59, 999));
    return { start, end };
  }
};

// ─── Data collector ───────────────────────────────────────────────────────────

const collectContext = async (userId, type, periodKey) => {
  const { start, end } = getPeriodBounds(type, periodKey);

  const [user, workouts, foodLogs, xpLogs] = await Promise.all([
    User.findById(userId).lean(),
    Workout.find({
      user:      userId,
      status:    'completed',
      isVerified: true,
      startTime: { $gte: start, $lte: end },
    }).lean(),
    FoodLog.find({
      user:       userId,
      loggedDate: {
        $gte: start.toISOString().slice(0, 10),
        $lte: end.toISOString().slice(0, 10),
      },
    }).lean(),
    XpLog.find({
      user:      userId,
      createdAt: { $gte: start, $lte: end },
    }).lean(),
  ]);

  // Workout stats
  const totalWorkouts     = workouts.length;
  const totalMinutes      = Math.round(workouts.reduce((s, w) => s + w.durationSeconds / 60, 0));
  const totalCaloriesBurned = workouts.reduce((s, w) => s + w.totalCaloriesBurned, 0);
  const avgQuality        = workouts.length
    ? Math.round(workouts.reduce((s, w) => s + (w.verificationDetails?.qualityScore || 0), 0) / workouts.length)
    : 0;
  const exerciseFrequency = workouts.map((w) => ({
    date:      w.startTime.toISOString().slice(0, 10),
    duration:  Math.round(w.durationSeconds / 60),
    calories:  w.totalCaloriesBurned,
    quality:   w.verificationDetails?.qualityScore || 0,
    exercises: w.exerciseLogs?.map((e) => e.exerciseName) || [],
  }));

  // Calorie stats
  const totalCaloriesConsumed = foodLogs.reduce((s, f) => s + f.calories, 0);
  const totalProtein  = Math.round(foodLogs.reduce((s, f) => s + f.protein, 0));
  const totalCarbs    = Math.round(foodLogs.reduce((s, f) => s + f.carbs,   0));
  const totalFat      = Math.round(foodLogs.reduce((s, f) => s + f.fat,     0));
  const daysLogged    = [...new Set(foodLogs.map((f) => f.loggedDate))].length;
  const avgDailyCalories = daysLogged > 0
    ? Math.round(totalCaloriesConsumed / daysLogged)
    : 0;

  // XP stats
  const totalXpEarned = xpLogs.filter((x) => x.amount > 0).reduce((s, x) => s + x.amount, 0);
  const xpDecayed     = xpLogs.filter((x) => x.amount < 0).reduce((s, x) => s + x.amount, 0);

  // Period days for consistency
  const periodDays = Math.max(1, Math.ceil((end - start) / 86400000));
  const consistencyPct = Math.round((totalWorkouts / periodDays) * 100);

  return {
    user: {
      name:         user.name,
      age:          user.age,
      weight:       user.weight,
      height:       user.height,
      fitnessGoal:  user.fitnessGoal,
      level:        user.level,
      streak:       user.streak,
      totalXP:      user.xp,
    },
    period:  { type, periodKey, start: start.toISOString(), end: end.toISOString(), days: periodDays },
    workouts: {
      total:            totalWorkouts,
      totalMinutes,
      totalCaloriesBurned,
      avgQualityScore:  avgQuality,
      consistencyPct,
      sessions:         exerciseFrequency,
    },
    nutrition: {
      totalCaloriesConsumed,
      avgDailyCalories,
      totalProtein,
      totalCarbs,
      totalFat,
      daysLogged,
      calorieDeficit: totalCaloriesBurned - totalCaloriesConsumed,
    },
    xp: {
      earned:  totalXpEarned,
      decayed: xpDecayed,
      net:     totalXpEarned + xpDecayed,
    },
  };
};

// ─── Prompt templates ─────────────────────────────────────────────────────────

const buildPrompt = (type, ctx) => {
  const base = `You are an expert fitness coach AI analyzing a user's fitness data.
User: ${ctx.user.name}, Age: ${ctx.user.age || 'unknown'}, Goal: ${ctx.user.fitnessGoal?.replace('_', ' ')}, Level: ${ctx.user.level}.
Period: ${ctx.period.type} (${ctx.period.periodKey}).

FITNESS DATA:
- Workouts: ${ctx.workouts.total} sessions, ${ctx.workouts.totalMinutes} total minutes
- Calories burned: ${ctx.workouts.totalCaloriesBurned} kcal
- Avg session quality: ${ctx.workouts.avgQualityScore}/100
- Consistency: ${ctx.workouts.consistencyPct}% (${ctx.workouts.total} workouts in ${ctx.period.days} days)
- Streak: ${ctx.user.streak} days
- XP earned this period: ${ctx.xp.earned} (net: ${ctx.xp.net})

NUTRITION DATA:
- Days food logged: ${ctx.nutrition.daysLogged}/${ctx.period.days}
- Avg daily calories: ${ctx.nutrition.avgDailyCalories} kcal
- Total protein: ${ctx.nutrition.totalProtein}g, Carbs: ${ctx.nutrition.totalCarbs}g, Fat: ${ctx.nutrition.totalFat}g
- Calorie deficit/surplus: ${ctx.nutrition.calorieDeficit} kcal`;

  const periodInstructions = {
    daily: `Generate a concise DAILY fitness report. Focus on: today's activity quality, calorie balance, and one specific tip for tomorrow.`,
    weekly: `Generate a WEEKLY fitness report. Focus on: workout frequency, consistency patterns, nutrition balance, strength/endurance trends, and plateau detection.`,
    monthly: `Generate a MONTHLY fitness report. Focus on: overall progress toward goal, body composition trends, performance improvements, habit formation, and a strategic plan for next month.`,
    yearly: `Generate a YEARLY fitness report. Focus on: total transformation, major milestones, consistency over the year, biggest improvements, and vision for next year.`,
  };

  return `${base}

${periodInstructions[type]}

Respond ONLY with valid JSON — no markdown, no extra text:
{
  "summary": "2-3 sentence overall summary of this period",
  "highlights": ["achievement 1", "achievement 2", "achievement 3"],
  "improvements": ["area to improve 1", "area to improve 2"],
  "nextSteps": ["specific action 1", "specific action 2", "specific action 3"],
  "motivationMessage": "one powerful motivational sentence personalized to this user",
  "plateauWarning": "empty string if no plateau, or describe the plateau detected",
  "dietFeedback": "2 sentences about nutrition — protein intake, calorie balance, Indian diet tips if relevant",
  "workoutFeedback": "2 sentences about workout quality and what muscle groups to focus on",
  "consistencyScore": <number 0-100 based on workout frequency>,
  "overallScore": <number 0-100 overall improvement score>
}`;
};

// ─── Main generator ───────────────────────────────────────────────────────────

const generateReport = async (userId, type, periodKey) => {
  const ctx = await collectContext(userId, type, periodKey);

  if (!process.env.GROQ_API_KEY) {
    // Return a basic report without AI if no key
    return {
      report: {
        summary:          `${ctx.user.name} completed ${ctx.workouts.total} verified workouts this ${type} with ${ctx.workouts.consistencyPct}% consistency.`,
        highlights:       ctx.workouts.total > 0 ? [`${ctx.workouts.total} workouts completed`, `${ctx.workouts.totalCaloriesBurned} calories burned`, `${ctx.xp.earned} XP earned`] : ['No workouts this period'],
        improvements:     ['Add GROQ_API_KEY for personalized AI insights'],
        nextSteps:        ['Complete a workout today', 'Log your meals', 'Check the leaderboard'],
        motivationMessage: 'Every workout counts — keep showing up!',
        plateauWarning:   '',
        dietFeedback:     ctx.nutrition.daysLogged > 0 ? `Avg ${ctx.nutrition.avgDailyCalories} kcal/day logged.` : 'Start logging meals for diet analysis.',
        workoutFeedback:  ctx.workouts.total > 0 ? `${ctx.workouts.totalMinutes} minutes trained with avg quality ${ctx.workouts.avgQualityScore}/100.` : 'No workouts this period.',
        consistencyScore: ctx.workouts.consistencyPct,
        overallScore:     Math.round((ctx.workouts.consistencyPct * 0.4) + (Math.min(100, ctx.workouts.avgQualityScore) * 0.6)),
      },
      context: ctx,
      rawResponse: 'Generated without AI (no GROQ_API_KEY)',
    };
  }

  const prompt = buildPrompt(type, ctx);

  const response = await groq.chat.completions.create({
    model:       'llama-3.3-70b-versatile',
    messages:    [{ role: 'user', content: prompt }],
    max_tokens:  1200,
    temperature: 0.4,
  });

  const raw    = response.choices[0]?.message?.content || '';
  const clean  = raw.replace(/```json|```/g, '').trim();

  let parsed;
  try {
    parsed = JSON.parse(clean);
  } catch {
    // Fallback parse — extract JSON object if LLM adds surrounding text
    const match = clean.match(/\{[\s\S]*\}/);
    parsed = match ? JSON.parse(match[0]) : {};
  }

  return { report: parsed, context: ctx, rawResponse: raw };
};

module.exports = { generateReport, collectContext };