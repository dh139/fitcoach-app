const mongoose = require('mongoose');

const challengeSchema = new mongoose.Schema(
  {
    title:       { type: String, required: true },
    description: { type: String, required: true },
    type:        { type: String, enum: ['daily', 'weekly'], default: 'daily' },
    difficulty:  { type: String, enum: ['easy', 'medium', 'hard'], default: 'medium' },
    xpReward:    { type: Number, default: 50 },
    target: {
      metric: { type: String, enum: ['workouts', 'minutes', 'calories', 'streak', 'exercises'] },
      value:  { type: Number },
    },
    // Per-user completion tracking
    completions: [{
      user:        { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      completedAt: { type: Date, default: Date.now },
      progress:    { type: Number, default: 0 },
    }],
    periodKey:   { type: String, required: true }, // "2024-10-15" or "2024-W42"
    expiresAt:   { type: Date,   required: true },
    aiGenerated: { type: Boolean, default: true },
  },
  { timestamps: true }
);

challengeSchema.index({ type: 1, periodKey: 1 });
challengeSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // auto-delete expired

module.exports = mongoose.model('Challenge', challengeSchema);