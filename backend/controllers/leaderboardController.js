const LeaderboardSnapshot = require('../models/LeaderboardSnapshot');
const { buildSnapshot }   = require('../jobs/leaderboardJob');

// ─── Helpers ──────────────────────────────────────────────────────────────────

const getPeriodKey = (period) => {
  const now = new Date();
  if (period === 'daily') return now.toISOString().slice(0, 10);
  if (period === 'weekly') {
    const d   = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()));
    const day = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - day);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    const weekNo    = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
    return `${d.getUTCFullYear()}-W${String(weekNo).padStart(2, '0')}`;
  }
  if (period === 'monthly') {
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  }
};

// ─── GET /api/leaderboard ─────────────────────────────────────────────────────
// Query: period (daily|weekly|monthly), page, limit

const getLeaderboard = async (req, res) => {
  try {
    const { period = 'weekly', page = 1, limit = 50 } = req.query;

    if (!['daily', 'weekly', 'monthly'].includes(period)) {
      return res.status(400).json({ success: false, message: 'Invalid period. Use daily, weekly, or monthly.' });
    }

    const periodKey = getPeriodKey(period);
    let snapshot    = await LeaderboardSnapshot.findOne({ period, periodKey });

    // If no snapshot exists yet — build it on-demand
    if (!snapshot) {
      await buildSnapshot(period);
      snapshot = await LeaderboardSnapshot.findOne({ period, periodKey });
    }

    if (!snapshot || snapshot.entries.length === 0) {
      return res.status(200).json({
        success: true,
        data:    { entries: [], myRank: null, period, periodKey, builtAt: null },
      });
    }

    // Paginate entries
    const skip       = (Number(page) - 1) * Number(limit);
    const total      = snapshot.entries.length;
    const paginated  = snapshot.entries.slice(skip, skip + Number(limit));

    // Find current user's rank
    const myEntry = snapshot.entries.find(
      (e) => e.user.toString() === req.user._id.toString()
    );

    res.status(200).json({
      success: true,
      data: {
        entries:    paginated,
        myRank:     myEntry || null,
        period,
        periodKey,
        builtAt:    snapshot.builtAt,
        pagination: {
          total,
          page:       Number(page),
          limit:      Number(limit),
          totalPages: Math.ceil(total / Number(limit)),
        },
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ─── GET /api/leaderboard/my-stats ───────────────────────────────────────────
// Returns user's rank across all three periods at once

const getMyStats = async (req, res) => {
  try {
    const userId  = req.user._id.toString();
    const periods = ['daily', 'weekly', 'monthly'];

    const results = await Promise.all(
      periods.map(async (period) => {
        const periodKey = getPeriodKey(period);
        const snapshot  = await LeaderboardSnapshot.findOne({ period, periodKey });
        if (!snapshot) return { period, rank: null, totalUsers: 0, entry: null };

        const entry      = snapshot.entries.find((e) => e.user.toString() === userId);
        const totalUsers = snapshot.entries.length;
        return { period, rank: entry?.rank || null, totalUsers, entry: entry || null };
      })
    );

    res.status(200).json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { getLeaderboard, getMyStats };