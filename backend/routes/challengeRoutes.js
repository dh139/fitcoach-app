const express = require('express');
const router  = express.Router();
const { getChallenges, claimChallenge } = require('../controllers/challengeController');
const { protect } = require('../middleware/authMiddleware');

router.get('/',           protect, getChallenges);
router.post('/:id/claim', protect, claimChallenge);

module.exports = router;