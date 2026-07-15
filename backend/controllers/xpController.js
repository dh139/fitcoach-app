const User  = require('../models/User');
const XpLog = require('../models/XpLog');
const { getXpProgress, getLevelInfo, LEVELS, STREAK_BONUSES, CONFIG } = require('../utils/xpEngine');

// GET /api/xp/profile
const getXpProfile = async (req, res) => {
  try {
    const user      = await User.findById(req.user._id).lean();
    const progress  = getXpProgress(user.xp);

    // Days since last workout
    const lastWorkout  = user.lastWorkoutDate ? new Date(user.lastWorkoutDate) : null;
    const daysInactive = lastWorkout
      ? Math.floor((Date.now() - lastWorkout.getTime()) / (1000 * 60 * 60 * 24))
      : null;

    // Next streak milestone
    const streakMilestones = Object.keys(STREAK_BONUSES).map(Number).sort((a, b) => a - b);
    const nextMilestone    = streakMilestones.find((m) => m > user.streak) || null;

    res.status(200).json({
      success: true,
      data: {
        xp:             user.xp,
        level:          user.level,
        streak:         user.streak,
        streakFreezes:  user.streakFreezeCount,
        totalWorkouts:  user.totalWorkouts,
        progress,
        daysInactive,
        nextStreakMilestone:    nextMilestone,
        nextStreakMilestoneXP:  nextMilestone ? STREAK_BONUSES[nextMilestone] : null,
        decayWarning:   daysInactive !== null && daysInactive >= CONFIG.DECAY_START_DAYS - 1,
        allLevels:      LEVELS,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/xp/history
const getXpHistory = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    const [logs, total] = await Promise.all([
      XpLog.find({ user: req.user._id })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit))
        .lean(),
      XpLog.countDocuments({ user: req.user._id }),
    ]);

    res.status(200).json({
      success: true,
      data: logs,
      pagination: { total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/xp/use-streak-freeze
const useStreakFreeze = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (user.streakFreezeCount <= 0) {
      return res.status(400).json({ success: false, message: 'No streak freezes remaining.' });
    }
    user.streakFreezeCount -= 1;
    // Treat today as a workout day so streak doesn't reset
    user.lastWorkoutDate = new Date();
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Streak freeze applied — your streak is safe!',
      streakFreezes: user.streakFreezeCount,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { getXpProfile, getXpHistory, useStreakFreeze };