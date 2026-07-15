const mongoose = require('mongoose');

// Individual exercise log within a session
const exerciseLogSchema = new mongoose.Schema({
  exercise:         { type: mongoose.Schema.Types.ObjectId, ref: 'Exercise', required: true },
  exerciseName:     { type: String, required: true },
  setsCompleted:    { type: Number, default: 0 },
  repsCompleted:    { type: Number, default: 0 },
  durationSeconds:  { type: Number, default: 0 },  // for timed exercises
  caloriesBurned:   { type: Number, default: 0 },
  completedAt:      { type: Date },
  // Anti-cheat: timestamps of each "mark complete" click
  clickTimestamps:  [{ type: Number }], // unix ms
}, { _id: false });

const workoutSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    // Session timing
    startTime:   { type: Date, required: true },
    endTime:     { type: Date },
    durationSeconds: { type: Number, default: 0 },

    // Exercises
    exerciseLogs: [exerciseLogSchema],
    totalExercises: { type: Number, default: 0 },

    // Calories & XP
    totalCaloriesBurned: { type: Number, default: 0 },
    xpEarned:            { type: Number, default: 0 },

    // Anti-cheat validation result
    isVerified: { type: Boolean, default: false },
    verificationDetails: {
      durationValid:        { type: Boolean, default: false },
      exerciseCountValid:   { type: Boolean, default: false },
      clickSpacingValid:    { type: Boolean, default: false },
      qualityScore:         { type: Number, default: 0 }, // 0-100
    },

    // Session metadata
    status: {
      type: String,
      enum: ['in_progress', 'completed', 'rejected'],
      default: 'in_progress',
    },
    notes:    { type: String, default: '' },
    workoutName: { type: String, default: 'Custom Workout' },
  },
  { timestamps: true }
);

workoutSchema.index({ user: 1, createdAt: -1 });
workoutSchema.index({ user: 1, status: 1 });

module.exports = mongoose.model('Workout', workoutSchema);