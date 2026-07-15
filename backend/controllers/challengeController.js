const Groq = require('groq-sdk');
const Challenge = require('../models/Challenge');
const Workout = require('../models/Workout');
const User = require('../models/User');
const { awardXP } = require('../utils/xpEngine');

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

// Allowed target metrics (must match your Mongoose schema enum)
const VALID_METRICS = ['minutes', 'calories', 'workouts'];

// Improved Prompt with strict rules + few-shot example
const generateChallenges = async (user) => {
  if (!process.env.GROQ_API_KEY) {
    console.log('GROQ_API_KEY not found, using default challenges');
    return getDefaultChallenges();
  }

  try {
    const prompt = `You are a fitness challenge generator.

Generate exactly 3 fitness challenges for a ${user.level || 'intermediate'} level user whose goal is ${user.fitnessGoal?.replace(/_/g, ' ') || 'general fitness'}.

Rules:
- 1 easy daily challenge
- 1 medium daily challenge  
- 1 hard weekly challenge
- Only use these target metrics: "minutes", "calories", "workouts"
- Never use reps, sets, steps, distance, or any other metric
- xpReward should be: easy=30, medium=60, hard=150-250
- Keep titles and descriptions short and motivating

Respond ONLY with a valid JSON array. No explanation, no markdown.

Example of correct output:
[
  {
    "title": "Morning Burn",
    "description": "Complete a 20-minute workout session today",
    "type": "daily",
    "difficulty": "easy",
    "xpReward": 30,
    "target": { "metric": "minutes", "value": 20 }
  },
  {
    "title": "Calorie Crusher",
    "description": "Burn at least 400 calories in one workout session",
    "type": "daily",
    "difficulty": "medium",
    "xpReward": 60,
    "target": { "metric": "calories", "value": 400 }
  }
]`;

    const resp = await groq.chat.completions.create({
      model: 'llama-3.3-70b-versatile',
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 700,
      temperature: 0.65,        // More consistent output
      response_format: { type: 'json_object' }   // Helps with JSON
    });

    let raw = resp.choices[0]?.message?.content || '';
    
    // Clean the response
    raw = raw.replace(/```json|```/g, '').trim();

    // Extract JSON array if wrapped in extra text
    const match = raw.match(/\[[\s\S]*\]/);
    if (!match) throw new Error('No JSON array found');

    let challenges = JSON.parse(match[0]);

    if (!Array.isArray(challenges) || challenges.length === 0) {
      throw new Error('Invalid challenges format');
    }

    // Safety validation and sanitization
    challenges = challenges.map((ch, index) => {
      const difficulty = ['easy', 'medium', 'hard'][index] || 'medium';

      return {
        title: ch.title?.trim() || `Challenge ${index + 1}`,
        description: ch.description?.trim() || 'Complete the required target',
        type: ch.type === 'weekly' ? 'weekly' : 'daily',
        difficulty: ['easy', 'medium', 'hard'].includes(ch.difficulty) ? ch.difficulty : difficulty,
        xpReward: typeof ch.xpReward === 'number' && ch.xpReward > 0 
                  ? ch.xpReward 
                  : (difficulty === 'easy' ? 30 : difficulty === 'medium' ? 60 : 200),
        target: {
          metric: VALID_METRICS.includes(ch.target?.metric) ? ch.target.metric : 'minutes',
          value: typeof ch.target?.value === 'number' && ch.target.value > 0 
                 ? Math.round(ch.target.value) 
                 : (ch.target?.metric === 'calories' ? 350 : 25)
        }
      };
    });

    return challenges;

  } catch (error) {
    console.error('Error generating challenges with Groq:', error.message);
    return getDefaultChallenges();
  }
};

const getDefaultChallenges = () => [
  {
    title: 'Quick Burn',
    description: 'Complete a 20-minute workout today',
    type: 'daily',
    difficulty: 'easy',
    xpReward: 30,
    target: { metric: 'minutes', value: 20 }
  },
  {
    title: 'Calorie Crusher',
    description: 'Burn 350 calories in one session',
    type: 'daily',
    difficulty: 'medium',
    xpReward: 60,
    target: { metric: 'calories', value: 350 }
  },
  {
    title: 'Weekly Warrior',
    description: 'Complete 5 workouts this week',
    type: 'weekly',
    difficulty: 'hard',
    xpReward: 200,
    target: { metric: 'workouts', value: 5 }
  },
];

// GET /api/challenges
const getChallenges = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).lean();
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const today = new Date().toISOString().slice(0, 10);

    // Generate weekKey (ISO week)
    const weekKey = (() => {
      const d = new Date();
      const day = d.getUTCDay() || 7;
      d.setUTCDate(d.getUTCDate() + 4 - day);
      const y = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
      const w = Math.ceil((((d - y) / 86400000) + 1) / 7);
      return `${d.getUTCFullYear()}-W${String(w).padStart(2, '0')}`;
    })();

    // Find existing challenges
    let challenges = await Challenge.find({
      periodKey: { $in: [today, weekKey] },
    }).lean();

    // Generate new challenges if none exist
    if (challenges.length === 0) {
      const generated = await generateChallenges(user);

      const todayEnd = new Date();
      todayEnd.setHours(23, 59, 59, 999);

      const weekEnd = new Date();
      weekEnd.setDate(weekEnd.getDate() + (7 - weekEnd.getDay()));

      const challengeDocs = generated.map((c) => ({
        ...c,
        periodKey: c.type === 'daily' ? today : weekKey,
        expiresAt: c.type === 'daily' ? todayEnd : weekEnd,
        completions: [],
      }));

      challenges = await Challenge.insertMany(challengeDocs);
    }

    // Calculate progress for each challenge
    const userId = req.user._id.toString();
    const periodStartCache = new Map();

    const withProgress = await Promise.all(
      challenges.map(async (ch) => {
        const userCompletion = ch.completions?.find(
          (c) => c.user?.toString() === userId
        );
        const completed = !!userCompletion;

        // Get period start date
        let periodStart;
        if (ch.type === 'daily') {
          periodStart = new Date(`${ch.periodKey}T00:00:00Z`);
        } else {
          if (!periodStartCache.has(ch.periodKey)) {
            const [year, week] = ch.periodKey.split('-W').map(Number);
            const startOfWeek = new Date(Date.UTC(year, 0, 1 + (week - 1) * 7));
            const day = startOfWeek.getUTCDay() || 7;
            startOfWeek.setUTCDate(startOfWeek.getUTCDate() - day + 1);
            periodStartCache.set(ch.periodKey, startOfWeek);
          }
          periodStart = periodStartCache.get(ch.periodKey);
        }

        // Fetch workouts in this period
        const workouts = await Workout.find({
          user: req.user._id,
          status: 'completed',
          isVerified: true,
          startTime: { $gte: periodStart },
        }).lean();

        let progress = 0;
        const metric = ch.target?.metric;

        if (metric === 'workouts') {
          progress = workouts.length;
        } else if (metric === 'minutes') {
          progress = Math.round(workouts.reduce((sum, w) => sum + (w.durationSeconds || 0) / 60, 0));
        } else if (metric === 'calories') {
          progress = Math.round(workouts.reduce((sum, w) => sum + (w.totalCaloriesBurned || 0), 0));
        }

        const targetValue = ch.target?.value || 1;
        const progressPct = Math.min(100, Math.round((progress / targetValue) * 100));

        return {
          ...ch,
          progress,
          progressPct,
          completed,
        };
      })
    );

    res.status(200).json({ success: true, data: withProgress });
  } catch (error) {
    console.error('Get challenges error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/challenges/:id/claim
const claimChallenge = async (req, res) => {
  try {
    const challenge = await Challenge.findById(req.params.id);
    if (!challenge) {
      return res.status(404).json({ success: false, message: 'Challenge not found' });
    }

    const userIdStr = req.user._id.toString();
    const alreadyClaimed = challenge.completions.some(
      (c) => c.user?.toString() === userIdStr
    );

    if (alreadyClaimed) {
      return res.status(400).json({ success: false, message: 'Challenge already claimed' });
    }

    // Re-verify progress
    const periodStart = challenge.type === 'daily'
      ? new Date(`${challenge.periodKey}T00:00:00Z`)
      : (() => {
          const [year, week] = challenge.periodKey.split('-W').map(Number);
          const d = new Date(Date.UTC(year, 0, 1 + (week - 1) * 7));
          const day = d.getUTCDay() || 7;
          d.setUTCDate(d.getUTCDate() - day + 1);
          return d;
        })();

    const workouts = await Workout.find({
      user: req.user._id,
      status: 'completed',
      isVerified: true,
      startTime: { $gte: periodStart },
    }).lean();

    let progress = 0;
    const metric = challenge.target?.metric;

    if (metric === 'workouts') progress = workouts.length;
    else if (metric === 'minutes') {
      progress = Math.round(workouts.reduce((s, w) => s + (w.durationSeconds || 0) / 60, 0));
    }
    else if (metric === 'calories') {
      progress = Math.round(workouts.reduce((s, w) => s + (w.totalCaloriesBurned || 0), 0));
    }

    const required = challenge.target?.value || 0;

    if (progress < required) {
      return res.status(400).json({
        success: false,
        message: `Target not met yet — ${progress}/${required} ${metric}`,
      });
    }

    // Mark as completed
    challenge.completions.push({ user: req.user._id, progress, claimedAt: new Date() });
    await challenge.save();

    // Award XP
    const xpResult = await awardXP(req.user._id, challenge.xpReward, 'challenge', {
      multiplier: 1,
    });

    res.status(200).json({
      success: true,
      message: `Challenge completed! +${challenge.xpReward} XP`,
      xpEarned: challenge.xpReward,
      didLevelUp: xpResult?.didLevelUp || false,
    });
  } catch (error) {
    console.error('Claim challenge error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { getChallenges, claimChallenge };