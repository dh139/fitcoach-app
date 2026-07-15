const express = require('express');
const router = express.Router();
const {
  getExercises,
  getExerciseById,
  getFilterOptions,
  toggleFavorite,
  getUserFavorites,
  getAiRecommendations,
} = require('../controllers/exerciseController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, getExercises);
router.get('/meta/filters', protect, getFilterOptions);
router.get('/user/favorites', protect, getUserFavorites);
router.post('/ai-recommendations', protect, getAiRecommendations);
router.get('/:id', protect, getExerciseById);
router.post('/:id/favorite', protect, toggleFavorite);

module.exports = router;