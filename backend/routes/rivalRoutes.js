const express = require('express');
const router  = express.Router();
const {
  getMyRivals, challengeUser, respondToChallenge, getSuggestedRivals,
} = require('../controllers/rivalController');
const { protect } = require('../middleware/authMiddleware');

router.get('/',                      protect, getMyRivals);
router.get('/suggestions',           protect, getSuggestedRivals);
router.post('/challenge/:userId',    protect, challengeUser);
router.post('/:id/respond',          protect, respondToChallenge);

module.exports = router;