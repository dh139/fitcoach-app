const mongoose = require('mongoose');

const xpLogSchema = new mongoose.Schema(
  {
    user:   { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    amount: { type: Number, required: true }, // positive = earned, negative = decay
    source: {
      type: String,
      enum: [
        'workout_complete',   // verified workout
        'streak_bonus',       // daily streak milestone
        'comeback_bonus',     // returning after inactivity
        'level_up_bonus',     // bonus XP on levelling up
        'xp_decay',          // inactivity penalty
        'manual',            // admin/debug
      ],
      required: true,
    },
    // Context snapshot (what triggered this XP event)
    meta: {
      workoutId:       { type: mongoose.Schema.Types.ObjectId, ref: 'Workout' },
      qualityScore:    { type: Number },
      streakDay:       { type: Number },
      multiplier:      { type: Number, default: 1 },
      previousLevel:   { type: String },
      newLevel:        { type: String },
      daysInactive:    { type: Number },
    },
    // Running total at the time of this entry
    balanceAfter: { type: Number, required: true },
  },
  { timestamps: true }
);

xpLogSchema.index({ user: 1, createdAt: -1 });
xpLogSchema.index({ user: 1, source: 1 });

module.exports = mongoose.model('XpLog', xpLogSchema);