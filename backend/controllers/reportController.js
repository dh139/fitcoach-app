const Report  = require('../models/Report');
const { generateReport } = require('../services/reportService');

// ─── Period key helpers ───────────────────────────────────────────────────────

const getCurrentPeriodKey = (type) => {
  const now = new Date();
  if (type === 'daily') return now.toISOString().slice(0, 10);
  if (type === 'weekly') {
    const d   = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()));
    const day = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - day);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    const weekNo    = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
    return `${d.getUTCFullYear()}-W${String(weekNo).padStart(2, '0')}`;
  }
  if (type === 'monthly') {
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  }
  if (type === 'yearly') return String(now.getFullYear());
};

// Cache TTL per report type (ms)
const CACHE_TTL = {
  daily:   2  * 60 * 60 * 1000,  // 2 hours
  weekly:  6  * 60 * 60 * 1000,  // 6 hours
  monthly: 24 * 60 * 60 * 1000,  // 24 hours
  yearly:  48 * 60 * 60 * 1000,  // 48 hours
};

// ─── GET /api/report/:type  (daily | weekly | monthly | yearly) ───────────────

const getReport = async (req, res) => {
  try {
    const { type }  = req.params;
    const { refresh = 'false' } = req.query;

    if (!['daily', 'weekly', 'monthly', 'yearly'].includes(type)) {
      return res.status(400).json({ success: false, message: 'Invalid report type.' });
    }

    const periodKey = getCurrentPeriodKey(type);
    const userId    = req.user._id;

    // Check cache
    const existing = await Report.findOne({ user: userId, type, periodKey });
    const isExpired = existing
      ? Date.now() - new Date(existing.generatedAt).getTime() > CACHE_TTL[type]
      : true;
    const forceRefresh = refresh === 'true';

    if (existing && !isExpired && !forceRefresh) {
      return res.status(200).json({
        success: true,
        data:    existing,
        cached:  true,
      });
    }

    // Generate fresh report
    const { report, context, rawResponse } = await generateReport(userId, type, periodKey);

    // Upsert into DB
    const saved = await Report.findOneAndUpdate(
      { user: userId, type, periodKey },
      {
        $set: {
          context,
          report,
          rawResponse,
          generatedAt: new Date(),
          isStale:     false,
        },
      },
      { upsert: true, new: true }
    );

    res.status(200).json({ success: true, data: saved, cached: false });
  } catch (error) {
    console.error('Report generation error:', error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

// ─── GET /api/report/history — last 5 of each type ───────────────────────────

const getReportHistory = async (req, res) => {
  try {
    const reports = await Report.find({ user: req.user._id })
      .sort({ generatedAt: -1 })
      .limit(20)
      .select('type periodKey report.summary report.overallScore report.consistencyScore generatedAt')
      .lean();

    // Group by type
    const grouped = { daily: [], weekly: [], monthly: [], yearly: [] };
    reports.forEach((r) => grouped[r.type]?.push(r));

    res.status(200).json({ success: true, data: grouped });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { getReport, getReportHistory };