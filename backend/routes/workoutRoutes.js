const express = require('express');
const router  = express.Router();
const { startWorkout, completeWorkout, getWorkoutHistory, getWorkoutStats } = require('../controllers/workoutController');
const { protect } = require('../middleware/authMiddleware');

router.post('/start',    protect, startWorkout);
router.post('/complete', protect, completeWorkout);
router.get('/history',   protect, getWorkoutHistory);
router.get('/stats',     protect, getWorkoutStats);

module.exports = router;