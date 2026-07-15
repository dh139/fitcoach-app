const express = require('express');
const router  = express.Router();
const { getLeaderboard, getMyStats } = require('../controllers/leaderboardController');
const { protect } = require('../middleware/authMiddleware');

router.get('/',         protect, getLeaderboard);
router.get('/my-stats', protect, getMyStats);

module.exports = router;