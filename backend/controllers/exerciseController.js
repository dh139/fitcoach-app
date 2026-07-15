const Exercise = require('../models/Exercise');
const UserFavorite = require('../models/UserFavorite');
const axios = require('axios');

// GET /api/exercises
const getExercises = async (req, res) => {
  try {
    const {
      bodyPart, equipment, target, difficulty,
      search, page = 1, limit = 20,
    } = req.query;

    const filter = {};
    if (bodyPart)    filter.bodyPart   = { $regex: new RegExp(bodyPart, 'i') };
    if (equipment)   filter.equipment  = { $regex: new RegExp(equipment, 'i') };
    if (target)      filter.target     = { $regex: new RegExp(target, 'i') };
    if (difficulty)  filter.difficulty = difficulty.toLowerCase();

    // Text search — search name and target muscle
    if (search) {
      filter.$or = [
        { name:   { $regex: new RegExp(search, 'i') } },
        { target: { $regex: new RegExp(search, 'i') } },
        { bodyPart: { $regex: new RegExp(search, 'i') } },
        { secondaryMuscles: { $elemMatch: { $regex: new RegExp(search, 'i') } } },
      ];
    }

    const skip  = (Number(page) - 1) * Number(limit);
    const [exercises, total] = await Promise.all([
      Exercise.find(filter)
        .skip(skip)
        .limit(Number(limit))
        .sort({ name: 1 })
        .lean(),
      Exercise.countDocuments(filter),
    ]);

    res.status(200).json({
      success: true,
      data: exercises,
      pagination: {
        total,
        page:       Number(page),
        limit:      Number(limit),
        totalPages: Math.ceil(total / Number(limit)),
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/exercises/meta/filters
const getFilterOptions = async (req, res) => {
  try {
    const [bodyParts, equipment, targets, difficulties] = await Promise.all([
      Exercise.distinct('bodyPart'),
      Exercise.distinct('equipment'),
      Exercise.distinct('target'),
      Exercise.distinct('difficulty'),
    ]);
    res.status(200).json({
      success: true,
      data: {
        bodyParts:    bodyParts.filter(Boolean).sort(),
        equipment:    equipment.filter(Boolean).sort(),
        targets:      targets.filter(Boolean).sort(),
        difficulties: ['beginner', 'intermediate', 'advanced'],
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/exercises/:id
const getExerciseById = async (req, res) => {
  try {
    const exercise = await Exercise.findById(req.params.id).lean();
    if (!exercise) {
      return res.status(404).json({ success: false, message: 'Exercise not found' });
    }
    res.status(200).json({ success: true, data: exercise });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/exercises/:id/favorite
const toggleFavorite = async (req, res) => {
  try {
    const { id } = req.params;
    const userId  = req.user._id;
    const existing = await UserFavorite.findOne({ user: userId, exercise: id });
    if (existing) {
      await existing.deleteOne();
      return res.status(200).json({ success: true, favorited: false });
    }
    await UserFavorite.create({ user: userId, exercise: id });
    res.status(201).json({ success: true, favorited: true });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/exercises/user/favorites
const getUserFavorites = async (req, res) => {
  try {
    const favorites = await UserFavorite.find({ user: req.user._id })
      .populate('exercise')
      .sort({ createdAt: -1 })
      .lean();
    res.status(200).json({
      success: true,
      data: favorites.map((f) => f.exercise).filter(Boolean),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/exercises/ai-recommendations
const getAiRecommendations = async (req, res) => {
  try {
    const { goal, focus, duration } = req.body;
    
    // Fetch a pool of exercises from the database to give the AI context (e.g. 60 exercises)
    const exercises = await Exercise.find({}).limit(60).lean();
    
    if (!process.env.NVIDIA_API_KEY) {
      console.warn("NVIDIA_API_KEY not found. Falling back to DB filters.");
      const fallback = exercises
        .filter(e => e.bodyPart?.toLowerCase() === focus?.toLowerCase() || e.target?.toLowerCase() === focus?.toLowerCase())
        .slice(0, 5);
      return res.status(200).json({ success: true, data: fallback.length ? fallback : exercises.slice(0, 5) });
    }

    // Call Nvidia completions API with the database list
    const payload = {
      model: "minimaxai/minimax-m3",
      messages: [
        {
          role: "user",
          content: `Select exactly 5 exercises from this database that match the user's fitness goal: "${goal}", target area: "${focus}", workout duration: "${duration}" minutes.
Database list:
${JSON.stringify(exercises.map(e => ({ name: e.name, bodyPart: e.bodyPart, target: e.target, difficulty: e.difficulty })))}

Respond ONLY with a JSON array of the recommended exercise names, like: ["Pushups", "Squats", "Plank"]. Do not write any markdown or text.`
        }
      ],
      max_tokens: 500,
      temperature: 0.2
    };

    const response = await axios.post("https://integrate.api.nvidia.com/v1/chat/completions", payload, {
      headers: {
        "Authorization": `Bearer ${process.env.NVIDIA_API_KEY}`,
        "Content-Type": "application/json"
      },
      timeout: 10000
    });

    const rawText = response.data.choices[0]?.message?.content || "";
    const cleaned = rawText.replace(/```json|```/g, "").trim();
    let names = [];
    try {
      names = JSON.parse(cleaned);
    } catch (e) {
      // Fallback parser in case of formatting leakage
      const matches = cleaned.match(/"([^"]+)"/g) || [];
      names = matches.map(m => m.replace(/"/g, ''));
    }

    // Fetch full exercise objects from DB by matching name
    let recommended = await Exercise.find({ name: { $in: names } }).lean();
    if (!recommended.length) {
      recommended = await Exercise.find({
        $or: names.map(n => ({ name: { $regex: new RegExp(n, 'i') } }))
      }).limit(5).lean();
    }
    
    res.status(200).json({ success: true, data: recommended.length ? recommended : exercises.slice(0, 5) });
  } catch (error) {
    console.error("Nvidia exercise recommendations error:", error.message);
    try {
      const fallback = await Exercise.find({}).limit(5).lean();
      res.status(200).json({ success: true, data: fallback });
    } catch (dbErr) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
};

module.exports = {
  getExercises,
  getExerciseById,
  getFilterOptions,
  toggleFavorite,
  getUserFavorites,
  getAiRecommendations,
};