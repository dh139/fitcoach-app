const express = require('express');
const router = express.Router();
const {
  registerGym,
  getOwnerGyms,
  updateGymPlans,
  getGymMembers,
  listGyms,
  getGymDetails,
  buyMembership,
  getActiveMembership,
  checkIn,
  checkOut,
  getOccupancy,
} = require('../controllers/gymController');
const { protect } = require('../middleware/authMiddleware');

// Base path: /api/gyms

// Owner routes
router.post('/', protect, registerGym);
router.get('/owner', protect, getOwnerGyms);
router.patch('/:id/plans', protect, updateGymPlans);
router.get('/:id/members', protect, getGymMembers);

// User routes
router.get('/', protect, listGyms);
router.get('/memberships/active', protect, getActiveMembership);
router.get('/:id', protect, getGymDetails);
router.post('/:id/memberships', protect, buyMembership);
router.post('/:id/checkin', protect, checkIn);
router.post('/:id/checkout', protect, checkOut);
router.get('/:id/occupancy', protect, getOccupancy);

module.exports = router;
