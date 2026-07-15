const Workout  = require('../models/Workout');
const User     = require('../models/User');
const Exercise = require('../models/Exercise');
const { validateSession, calculateXP, calculateCalories } = require('../utils/antiCheat');
const { awardXP, processStreak, processComebackBonus } = require('../utils/xpEngine');

// POST /api/workout/start
const startWorkout = async (req, res) => {
  try {
    const { workoutName = 'Custom Workout', exerciseIds = [] } = req.body;

    // Close any previous in-progress session for this user (safety)
    await Workout.updateMany(
      { user: req.user._id, status: 'in_progress' },
      { $set: { status: 'rejected' } }
    );

    const workout = await Workout.create({
      user:        req.user._id,
      workoutName,
      startTime:   new Date(),
      status:      'in_progress',
      exerciseLogs: [],
    });

    res.status(201).json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/workout/complete
const completeWorkout = async (req, res) => {
  try {
    const { workoutId, exerciseLogs } = req.body;

    const workout = await Workout.findOne({
      _id:    workoutId,
      user:   req.user._id,
      status: 'in_progress',
    });

    if (!workout) {
      return res.status(404).json({ success: false, message: 'Active workout session not found.' });
    }

    const endTime = new Date();

    // Enrich exercise logs with calorie data from DB
    const enrichedLogs = await Promise.all(
      (exerciseLogs || []).map(async (log) => {
        const exercise = await Exercise.findById(log.exercise).lean();
        const caloriesBurned = calculateCalories({
          caloriesPerMinute: exercise?.caloriesPerMinute || 6,
          durationSeconds:   log.durationSeconds || 0,
          setsCompleted:     log.setsCompleted    || 0,
          repsCompleted:     log.repsCompleted    || 0,
        });
        return {
          ...log,
          exerciseName:    exercise?.name || log.exerciseName || 'Unknown',
          caloriesBurned,
          completedAt:     log.completedAt ? new Date(log.completedAt) : endTime,
          clickTimestamps: log.clickTimestamps || [],
        };
      })
    );

    const totalCaloriesBurned = enrichedLogs.reduce((sum, l) => sum + (l.caloriesBurned || 0), 0);

    // Run anti-cheat validation
    const validation = validateSession({
      startTime:    workout.startTime,
      endTime,
      exerciseLogs: enrichedLogs,
    });

    // Calculate XP only if verified
    let xpEarned = 0;
    if (validation.isVerified) {
      xpEarned = calculateXP({
        durationSeconds: validation.durationSeconds,
        exerciseCount:   enrichedLogs.filter((l) => l.setsCompleted > 0 || l.durationSeconds > 0).length,
        totalCalories:   totalCaloriesBurned,
        xpMultiplier:    validation.xpMultiplier,
      });
    }

    // Update workout record
    workout.endTime              = endTime;
    workout.durationSeconds      = validation.durationSeconds;
    workout.exerciseLogs         = enrichedLogs;
    workout.totalExercises       = enrichedLogs.length;
    workout.totalCaloriesBurned  = totalCaloriesBurned;
    workout.xpEarned             = xpEarned;
    workout.isVerified           = validation.isVerified;
    workout.verificationDetails  = validation.details;
    workout.status               = validation.isVerified ? 'completed' : 'rejected';
    await workout.save();

    // If verified — update user stats + XP + streak
    if (validation.isVerified) {
      const user = await User.findById(req.user._id);

      // Comeback bonus — were they inactive a long time?
      const lastWorkout   = user.lastWorkoutDate;
      const daysInactive  = lastWorkout
        ? Math.floor((Date.now() - new Date(lastWorkout).getTime()) / (1000 * 60 * 60 * 24))
        : 0;

      if (daysInactive >= 14) {
        await processComebackBonus(req.user._id, daysInactive);
      }

      // Update streak
      const todayStr      = new Date().toDateString();
      const yesterdayDate = new Date(Date.now() - 86400000);
      const lastStr       = lastWorkout ? new Date(lastWorkout).toDateString() : null;

      if (lastStr === todayStr) {
        // Already worked out today — no streak change
      } else if (lastStr === yesterdayDate.toDateString()) {
        user.streak += 1;
      } else {
        user.streak = 1;
      }

      user.lastWorkoutDate      = new Date();
      user.totalWorkouts        += 1;
      user.totalCaloriesBurned  += totalCaloriesBurned;
      user.totalMinutesWorked   += Math.floor(validation.durationSeconds / 60);
      await user.save();

      // Award workout XP via engine (writes XpLog, handles level-up)
      const xpResult = await awardXP(req.user._id, xpEarned, 'workout_complete', {
        workoutId:    workout._id,
        qualityScore: validation.qualityScore,
        multiplier:   validation.xpMultiplier,
      });

      // Streak milestone bonus
      await processStreak(req.user._id);

      // Attach level-up info to response
      workout.xpEarned = xpEarned;
      await workout.save();

      return res.status(200).json({
        success: true,
        data: {
          workout,
          validation: {
            isVerified:   validation.isVerified,
            qualityScore: validation.qualityScore,
            reason:       validation.reason,
            details:      validation.details,
          },
          xpEarned,
          totalCaloriesBurned,
          didLevelUp:    xpResult.didLevelUp,
          previousLevel: xpResult.previousLevel,
          newLevel:      xpResult.newLevel,
        },
      });
    }

    // If not verified, still return the workout result
    return res.status(200).json({
      success: true,
      data: {
        workout,
        validation: {
          isVerified:   validation.isVerified,
          qualityScore: validation.qualityScore,
          reason:       validation.reason,
          details:      validation.details,
        },
        xpEarned: 0,
        totalCaloriesBurned,
      },
    });

  } catch (error) {
    console.error('Complete workout error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/workout/history
const getWorkoutHistory = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    const [workouts, total] = await Promise.all([
      Workout.find({ user: req.user._id, status: { $in: ['completed', 'rejected'] } })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit))
        .lean(),
      Workout.countDocuments({ user: req.user._id, status: { $in: ['completed', 'rejected'] } }),
    ]);

    res.status(200).json({
      success: true,
      data: workouts,
      pagination: { 
        total, 
        page: Number(page), 
        totalPages: Math.ceil(total / Number(limit)) 
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/workout/stats
const getWorkoutStats = async (req, res) => {
  try {
    const userId = req.user._id;

    const [user, weeklyCount, monthlyCalories] = await Promise.all([
      User.findById(userId).lean(),
      Workout.countDocuments({
        user:   userId,
        status: 'completed',
        createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
      }),
      Workout.aggregate([
        { $match: { 
            user: userId, 
            status: 'completed', 
            createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } 
        }},
        { $group: { _id: null, total: { $sum: '$totalCaloriesBurned' } } },
      ]),
    ]);

    res.status(200).json({
      success: true,
      data: {
        totalWorkouts:       user.totalWorkouts,
        totalCaloriesBurned: user.totalCaloriesBurned,
        totalMinutesWorked:  user.totalMinutesWorked,
        currentStreak:       user.streak,
        xp:                  user.xp,
        level:               user.level,
        weeklyWorkouts:      weeklyCount,
        monthlyCalories:     monthlyCalories[0]?.total || 0,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { 
  startWorkout, 
  completeWorkout, 
  getWorkoutHistory, 
  getWorkoutStats 
};