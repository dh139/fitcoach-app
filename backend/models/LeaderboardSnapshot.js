const mongoose = require('mongoose');

const entrySchema = new mongoose.Schema({
  rank:             { type: Number, required: true },
  user:             { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name:             { type: String, required: true },
  avatar:           { type: String, default: '' },
  level:            { type: String, required: true },
  // Scoring pillars
  verifiedXP:       { type: Number, default: 0 }, // XP from verified sessions only
  consistencyScore: { type: Number, default: 0 }, // 0-100: workouts / possible days
  improvementScore: { type: Number, default: 0 }, // 0-100: quality score trend
  totalScore:       { type: Number, default: 0 }, // weighted composite
  // Supporting stats
  workoutsCompleted:   { type: Number, default: 0 },
  totalCalories:       { type: Number, default: 0 },
  totalMinutes:        { type: Number, default: 0 },
  avgQualityScore:     { type: Number, default: 0 },
  streak:              { type: Number, default: 0 },
}, { _id: false });

const leaderboardSnapshotSchema = new mongoose.Schema(
  {
    period:    { type: String, enum: ['daily', 'weekly', 'monthly'], required: true },
    periodKey: { type: String, required: true }, // e.g. "2024-W42", "2024-10", "2024-10-15"
    entries:   [entrySchema],
    builtAt:   { type: Date, default: Date.now },
  },
  { timestamps: true }
);

leaderboardSnapshotSchema.index({ period: 1, periodKey: 1 }, { unique: true });

module.exports = mongoose.model('LeaderboardSnapshot', leaderboardSnapshotSchema);