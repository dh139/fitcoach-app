const express = require('express');
const router  = express.Router();
const { getXpProfile, getXpHistory, useStreakFreeze } = require('../controllers/xpController');
const { protect } = require('../middleware/authMiddleware');

router.get('/profile',            protect, getXpProfile);
router.get('/history',            protect, getXpHistory);
router.post('/use-streak-freeze', protect, useStreakFreeze);

module.exports = router;