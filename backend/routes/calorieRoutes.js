const express = require('express');
const router  = express.Router();
const {
  searchFood, analyzePhoto, logFood,
  getDayLog,  deleteLogEntry, getWeeklySummary,
} = require('../controllers/calorieController');
const { protect } = require('../middleware/authMiddleware');

router.get('/search',          protect, searchFood);
router.post('/analyze-photo',  protect, analyzePhoto);
router.post('/log',            protect, logFood);
router.get('/log',             protect, getDayLog);
router.delete('/log/:id',      protect, deleteLogEntry);
router.get('/weekly',          protect, getWeeklySummary);

module.exports = router;