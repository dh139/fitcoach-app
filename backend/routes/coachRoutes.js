const express = require('express');
const router  = express.Router();
const {
  chat, getChatHistory, clearChatHistory, getImprovementScore, getDailyAdvice,
} = require('../controllers/coachController');
const { protect } = require('../middleware/authMiddleware');

router.post('/chat',              protect, chat);
router.get('/history',            protect, getChatHistory);
router.delete('/history',         protect, clearChatHistory);
router.get('/improvement-score',  protect, getImprovementScore);
router.get('/daily-advice',       protect, getDailyAdvice);

module.exports = router;