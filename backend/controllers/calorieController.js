const FoodLog  = require('../models/FoodLog');
const { searchFoodCombined, analyzePhotoWithNvidia } = require('../services/nutritionService');

// ─── GET /api/calories/search?q=banana ───────────────────────────────────────
const searchFood = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q?.trim()) {
      return res.status(400).json({ success: false, message: 'Search query required' });
    }
    const results = await searchFoodCombined(q.trim());
    res.status(200).json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ─── POST /api/calories/analyze-photo ────────────────────────────────────────
const analyzePhoto = async (req, res) => {
  try {
    const { base64Image, mimeType = 'image/jpeg', description = '' } = req.body;
    if (!base64Image) {
      return res.status(400).json({ success: false, message: 'base64Image required' });
    }
    const result = await analyzePhotoWithNvidia(base64Image, mimeType, description);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ─── POST /api/calories/log ───────────────────────────────────────────────────
const logFood = async (req, res) => {
  try {
    const {
      name, brand = '', quantity = 1, unit = 'serving',
      calories, protein = 0, carbs = 0, fat = 0, fiber = 0,
      mealType = 'snack', source = 'manual',
      photoUrl = '', aiAnalysis = '',
      loggedDate,
    } = req.body;

    if (!name || calories === undefined) {
      return res.status(400).json({ success: false, message: 'name and calories are required' });
    }

    const date = loggedDate || new Date().toISOString().slice(0, 10);

    const entry = await FoodLog.create({
      user: req.user._id,
      name, brand, quantity, unit,
      calories: Math.round(calories),
      protein:  Math.round(protein  * 10) / 10,
      carbs:    Math.round(carbs    * 10) / 10,
      fat:      Math.round(fat      * 10) / 10,
      fiber:    Math.round(fiber    * 10) / 10,
      mealType, source, photoUrl, aiAnalysis,
      loggedDate: date,
    });

    res.status(201).json({ success: true, data: entry });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ─── GET /api/calories/log?date=2024-10-15 ───────────────────────────────────
const getDayLog = async (req, res) => {
  try {
    const date = req.query.date || new Date().toISOString().slice(0, 10);

    const entries = await FoodLog.find({
      user:       req.user._id,
      loggedDate: date,
    }).sort({ createdAt: 1 }).lean();

    // Aggregate totals
    const totals = entries.reduce(
      (acc, e) => ({
        calories: acc.calories + e.calories,
        protein:  acc.protein  + e.protein,
        carbs:    acc.carbs    + e.carbs,
        fat:      acc.fat      + e.fat,
        fiber:    acc.fiber    + e.fiber,
      }),
      { calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0 }
    );

    // Group by meal type
    const byMeal = { breakfast: [], lunch: [], dinner: [], snack: [] };
    entries.forEach((e) => byMeal[e.mealType]?.push(e));

    res.status(200).json({
      success: true,
      data: { date, entries, totals, byMeal },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ─── DELETE /api/calories/log/:id ────────────────────────────────────────────
const deleteLogEntry = async (req, res) => {
  try {
    const entry = await FoodLog.findOneAndDelete({
      _id:  req.params.id,
      user: req.user._id,
    });
    if (!entry) {
      return res.status(404).json({ success: false, message: 'Entry not found' });
    }
    res.status(200).json({ success: true, message: 'Entry deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ─── GET /api/calories/weekly ─────────────────────────────────────────────────
const getWeeklySummary = async (req, res) => {
  try {
    const days = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      days.push(d.toISOString().slice(0, 10));
    }

    const logs = await FoodLog.find({
      user:       req.user._id,
      loggedDate: { $in: days },
    }).lean();

    const summary = days.map((date) => {
      const dayLogs = logs.filter((l) => l.loggedDate === date);
      return {
        date,
        calories: dayLogs.reduce((s, l) => s + l.calories, 0),
        protein:  Math.round(dayLogs.reduce((s, l) => s + l.protein, 0) * 10) / 10,
        carbs:    Math.round(dayLogs.reduce((s, l) => s + l.carbs,   0) * 10) / 10,
        fat:      Math.round(dayLogs.reduce((s, l) => s + l.fat,     0) * 10) / 10,
        entries:  dayLogs.length,
      };
    });

    res.status(200).json({ success: true, data: summary });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  searchFood, analyzePhoto, logFood,
  getDayLog,  deleteLogEntry, getWeeklySummary,
};