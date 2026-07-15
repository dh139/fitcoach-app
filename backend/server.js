require('dotenv').config();
const express   = require('express');
const cors      = require('cors');
const connectDB = require('./config/db');
const { applySecurityMiddleware, apiLimiter, authLimiter, aiLimiter } = require('./middleware/security');
const { startDecayJob }       = require('./jobs/xpDecayJob');
const { startLeaderboardJob } = require('./jobs/leaderboardJob');
const { syncFromAPI }         = require('./services/exerciseService');
const Exercise                = require('./models/Exercise');

const app = express();

// ── Security middleware ────────────────────────────────────────────────────────
applySecurityMiddleware(app);

// ── CORS ──────────────────────────────────────────────────────────────────────
const allowedOrigins = [
  'http://localhost:5173',
  'http://localhost:4173',
  process.env.FRONTEND_URL,
].filter(Boolean);

app.use(cors({
  origin:      (origin, cb) => (!origin || allowedOrigins.includes(origin)) ? cb(null, true) : cb(new Error('CORS blocked')),
  credentials: true,
}));

// ── Body parsing ──────────────────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ── DB ────────────────────────────────────────────────────────────────────────
connectDB();

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth',        authLimiter,  require('./routes/authRoutes'));
app.use('/api/exercises',   apiLimiter,   require('./routes/exerciseRoutes'));
app.use('/api/workout',     apiLimiter,   require('./routes/workoutRoutes'));
app.use('/api/xp',          apiLimiter,   require('./routes/xpRoutes'));
app.use('/api/leaderboard', apiLimiter,   require('./routes/leaderboardRoutes'));
app.use('/api/calories',    apiLimiter,   require('./routes/calorieRoutes'));
app.use('/api/report',      aiLimiter,    require('./routes/reportRoutes'));
app.use('/api/coach',       aiLimiter,    require('./routes/coachRoutes'));
app.use('/api/challenges',  apiLimiter,   require('./routes/challengeRoutes'));
app.use('/api/rivals',      apiLimiter,   require('./routes/rivalRoutes'));
app.use('/api/gyms',        apiLimiter,   require('./routes/gymRoutes'));

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/api/health', (_, res) => res.json({
  status:    'OK',
  timestamp: new Date(),
  uptime:    Math.round(process.uptime()),
}));

// ── Global error handler ──────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error(`[${new Date().toISOString()}] ${err.stack}`);
  res.status(err.status || 500).json({
    success: false,
    message: process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message,
  });
});

// ── 404 ───────────────────────────────────────────────────────────────────────
app.use((req, res) => res.status(404).json({ success: false, message: 'Route not found' }));

// ── Start server + jobs ───────────────────────────────────────────────────────
const PORT = process.env.PORT || 5000;
app.listen(PORT, async () => {
  console.log(`\n🚀 Server running on port ${PORT} (${process.env.NODE_ENV || 'development'})`);
  startDecayJob();
  startLeaderboardJob();

  // Seed exercises if database is empty or only has mock data
  try {
    const count = await Exercise.countDocuments();
    if (count <= 10) {
      console.log(`Only ${count} exercises found in DB. Running syncFromAPI to load full dataset...`);
      syncFromAPI();
    }
  } catch (err) {
    console.error('Failed to check exercise count on startup:', err);
  }
});