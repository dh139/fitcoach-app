const express = require('express');
const router  = express.Router();
const { getReport, getReportHistory } = require('../controllers/reportController');
const { protect } = require('../middleware/authMiddleware');

router.get('/history',  protect, getReportHistory);
router.get('/:type',    protect, getReport);

module.exports = router;