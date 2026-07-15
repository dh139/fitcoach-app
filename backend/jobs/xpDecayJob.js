const cron = require('node-cron');
const User = require('../models/User');
const { applyDecayForUser } = require('../utils/xpEngine');

const startDecayJob = () => {
  // Runs every day at 3:00 AM
  cron.schedule('0 3 * * *', async () => {
    console.log('[XP Decay Job] Starting daily decay pass...');
    try {
      // Only users who have XP and haven't worked out recently
      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      const candidates = await User.find({
        xp: { $gt: 0 },
        $or: [
          { lastWorkoutDate: { $lt: sevenDaysAgo } },
          { lastWorkoutDate: null },
        ],
      }).select('_id').lean();

      let decayed = 0;
      for (const u of candidates) {
        const result = await applyDecayForUser(u._id);
        if (result) decayed++;
      }
      console.log(`[XP Decay Job] Applied decay to ${decayed}/${candidates.length} users`);
    } catch (err) {
      console.error('[XP Decay Job] Error:', err.message);
    }
  });

  console.log('[XP Decay Job] Scheduled — runs daily at 3:00 AM');
};

module.exports = { startDecayJob };