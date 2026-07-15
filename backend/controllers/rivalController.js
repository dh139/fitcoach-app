const Rival   = require('../models/Rival');
const User    = require('../models/User');
const Workout = require('../models/Workout');

const getWeekKey = () => {
  const d   = new Date();
  const day = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - day);
  const y = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const w = Math.ceil((((d - y) / 86400000) + 1) / 7);
  return `${d.getUTCFullYear()}-W${String(w).padStart(2, '0')}`;
};

// GET /api/rivals — my rivals this week
const getMyRivals = async (req, res) => {
  try {
    const userId  = req.user._id;
    const weekKey = getWeekKey();

    const rivals = await Rival.find({
      $or: [{ challenger: userId }, { rival: userId }],
      weekKey,
    })
      .populate('challenger', 'name level xp streak')
      .populate('rival',      'name level xp streak')
      .lean();

    res.status(200).json({ success: true, data: rivals });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/rivals/challenge/:userId
const challengeUser = async (req, res) => {
  try {
    const challengerId = req.user._id;
    const rivalId      = req.params.userId;
    const weekKey      = getWeekKey();

    if (challengerId.toString() === rivalId) {
      return res.status(400).json({ success: false, message: "You can't challenge yourself." });
    }

    const targetUser = await User.findById(rivalId).lean();
    if (!targetUser) return res.status(404).json({ success: false, message: 'User not found' });

    const existing = await Rival.findOne({
      $or: [
        { challenger: challengerId, rival: rivalId, weekKey },
        { challenger: rivalId, rival: challengerId, weekKey },
      ],
    });
    if (existing) return res.status(400).json({ success: false, message: 'Already challenged this week' });

    const battle = await Rival.create({
      challenger: challengerId,
      rival:      rivalId,
      weekKey,
      status:     'pending',
    });

    res.status(201).json({
      success: true,
      message: `Challenge sent to ${targetUser.name}!`,
      data:    battle,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/rivals/:id/respond
const respondToChallenge = async (req, res) => {
  try {
    const { accept } = req.body;
    const battle     = await Rival.findById(req.params.id);

    if (!battle) return res.status(404).json({ success: false, message: 'Challenge not found' });
    if (battle.rival.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not your challenge' });
    }

    battle.status = accept ? 'active' : 'declined';
    await battle.save();

    res.status(200).json({
      success: true,
      message: accept ? 'Challenge accepted! Battle begins.' : 'Challenge declined.',
      data:    battle,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/rivals/leaderboard-users — users to challenge (from leaderboard nearby)
const getSuggestedRivals = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).lean();
    const suggestions = await User.find({
      _id:   { $ne: req.user._id },
      level: user.level,
    })
      .select('name level xp streak totalWorkouts')
      .sort({ xp: -1 })
      .limit(10)
      .lean();

    res.status(200).json({ success: true, data: suggestions });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { getMyRivals, challengeUser, respondToChallenge, getSuggestedRivals };