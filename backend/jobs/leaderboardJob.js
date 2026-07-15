const cron     = require('node-cron');
const mongoose = require('mongoose');
const Workout  = require('../models/Workout');
const User     = require('../models/User');
const XpLog    = require('../models/XpLog');
const LeaderboardSnapshot = require('../models/LeaderboardSnapshot');

// ─── Period helpers ───────────────────────────────────────────────────────────

const getPeriodBounds = (period) => {
  const now   = new Date();
  const start = new Date();

  if (period === 'daily') {
    start.setHours(0, 0, 0, 0);
  } else if (period === 'weekly') {
    const day = now.getDay(); // 0 = Sun
    start.setDate(now.getDate() - ((day + 6) % 7)); // Monday
    start.setHours(0, 0, 0, 0);
  } else if (period === 'monthly') {
    start.setDate(1);
    start.setHours(0, 0, 0, 0);
  }

  return { start, end: now };
};

const getPeriodKey = (period) => {
  const now = new Date();
  if (period === 'daily') {
    return now.toISOString().slice(0, 10); // "2024-10-15"
  }
  if (period === 'weekly') {
    // ISO week number
    const d    = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()));
    const day  = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - day);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    const weekNo    = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
    return `${d.getUTCFullYear()}-W${String(weekNo).padStart(2, '0')}`;
  }
  if (period === 'monthly') {
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  }
};

// ─── Core aggregation ─────────────────────────────────────────────────────────

const buildSnapshot = async (period) => {
  const { start, end } = getPeriodBounds(period);
  const periodKey      = getPeriodKey(period);
  const possibleDays   = Math.max(1, Math.ceil((end - start) / 86400000));

  console.log(`[Leaderboard] Building ${period} snapshot (${periodKey})...`);

  // Step 1: Aggregate verified workouts in the period
  const workoutAgg = await Workout.aggregate([
    {
      $match: {
        status:    'completed',
        isVerified: true,
        startTime: { $gte: start, $lte: end },
      },
    },
    {
      $group: {
        _id:                '$user',
        workoutsCompleted:  { $sum: 1 },
        totalCalories:      { $sum: '$totalCaloriesBurned' },
        totalMinutes:       { $sum: { $divide: ['$durationSeconds', 60] } },
        avgQualityScore:    { $avg: '$verificationDetails.qualityScore' },
        // Collect unique workout dates for consistency calc
        workoutDates: {
          $addToSet: {
            $dateToString: { format: '%Y-%m-%d', date: '$startTime' },
          },
        },
        // Quality scores array for improvement trend
        qualityScores: { $push: '$verificationDetails.qualityScore' },
      },
    },
  ]);

  if (workoutAgg.length === 0) {
    console.log(`[Leaderboard] No verified workouts found for ${period} — skipping`);
    return;
  }

  // Step 2: Fetch verified XP logs in the period (workout_complete source only)
  const xpAgg = await XpLog.aggregate([
    {
      $match: {
        source:    'workout_complete',
        createdAt: { $gte: start, $lte: end },
      },
    },
    {
      $group: {
        _id:        '$user',
        verifiedXP: { $sum: '$amount' },
      },
    },
  ]);

  const xpByUser = Object.fromEntries(xpAgg.map((x) => [x._id.toString(), x.verifiedXP]));

  // Step 3: Fetch user profiles for name / level / streak / avatar
  const userIds   = workoutAgg.map((w) => w._id);
  const users     = await User.find({ _id: { $in: userIds } })
    .select('name avatar level streak')
    .lean();
  const userMap   = Object.fromEntries(users.map((u) => [u._id.toString(), u]));

  // Step 4: Score each user
  const scored = workoutAgg.map((w) => {
    const userId  = w._id.toString();
    const userDoc = userMap[userId] || {};

    // Consistency: unique workout days / possible days (capped at 100)
    const consistencyScore = Math.min(
      100,
      Math.round((w.workoutDates.length / possibleDays) * 100)
    );

    // Improvement: compare first-half avg vs second-half avg quality scores
    const scores = (w.qualityScores || []).filter(Boolean);
    let improvementScore = 50; // neutral if not enough data
    if (scores.length >= 2) {
      const half    = Math.floor(scores.length / 2);
      const firstH  = scores.slice(0, half).reduce((a, b) => a + b, 0) / half;
      const secondH = scores.slice(half).reduce((a, b) => a + b, 0) / (scores.length - half);
      // Map delta (-100 to +100) → score (0 to 100)
      const delta   = secondH - firstH;
      improvementScore = Math.min(100, Math.max(0, 50 + delta));
    }

    const verifiedXP = xpByUser[userId] || 0;

    // Composite score (weighted):
    // 50% verifiedXP (normalised later), 25% consistency, 25% improvement
    // We store raw values and normalise after collecting all users
    return {
      userId,
      verifiedXP,
      consistencyScore:  Math.round(consistencyScore),
      improvementScore:  Math.round(improvementScore),
      workoutsCompleted: w.workoutsCompleted,
      totalCalories:     Math.round(w.totalCalories),
      totalMinutes:      Math.round(w.totalMinutes),
      avgQualityScore:   Math.round(w.avgQualityScore || 0),
      name:   userDoc.name   || 'Unknown',
      avatar: userDoc.avatar || '',
      level:  userDoc.level  || 'beginner',
      streak: userDoc.streak || 0,
    };
  });

  // Step 5: Normalise XP to 0-100 scale then compute totalScore
  const maxXP = Math.max(1, ...scored.map((s) => s.verifiedXP));
  const withScore = scored.map((s) => {
    const xpNorm     = Math.round((s.verifiedXP / maxXP) * 100);
    const totalScore = Math.round(
      xpNorm              * 0.50 +
      s.consistencyScore  * 0.25 +
      s.improvementScore  * 0.25
    );
    return { ...s, xpNorm, totalScore };
  });

  // Step 6: Sort and assign ranks
  withScore.sort((a, b) => b.totalScore - a.totalScore || b.verifiedXP - a.verifiedXP);

  const entries = withScore.map((s, i) => ({
    rank:             i + 1,
    user:             new mongoose.Types.ObjectId(s.userId),
    name:             s.name,
    avatar:           s.avatar,
    level:            s.level,
    verifiedXP:       s.verifiedXP,
    consistencyScore: s.consistencyScore,
    improvementScore: s.improvementScore,
    totalScore:       s.totalScore,
    workoutsCompleted:   s.workoutsCompleted,
    totalCalories:       s.totalCalories,
    totalMinutes:        s.totalMinutes,
    avgQualityScore:     s.avgQualityScore,
    streak:              s.streak,
  }));

  // Step 7: Upsert snapshot
  await LeaderboardSnapshot.findOneAndUpdate(
    { period, periodKey },
    { $set: { entries, builtAt: new Date() } },
    { upsert: true, new: true }
  );

  console.log(`[Leaderboard] ${period} snapshot saved — ${entries.length} users ranked`);
};

// ─── Build all three periods ──────────────────────────────────────────────────

const buildAllSnapshots = async () => {
  await Promise.all([
    buildSnapshot('daily'),
    buildSnapshot('weekly'),
    buildSnapshot('monthly'),
  ]);
};

// ─── Cron schedule ────────────────────────────────────────────────────────────

const startLeaderboardJob = () => {
  // Every hour — keeps leaderboard fresh without hammering the DB
  cron.schedule('0 * * * *', async () => {
    try {
      await buildAllSnapshots();
    } catch (err) {
      console.error('[Leaderboard Job] Error:', err.message);
    }
  });

  // Build immediately on startup
  buildAllSnapshots().catch(console.error);

  console.log('[Leaderboard Job] Scheduled — runs every hour + on startup');
};

module.exports = { startLeaderboardJob, buildAllSnapshots, buildSnapshot };