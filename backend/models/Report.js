const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema(
  {
    user:       { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    type:       { type: String, enum: ['daily', 'weekly', 'monthly', 'yearly'], required: true },
    periodKey:  { type: String, required: true }, // "2024-10-15" / "2024-W42" / "2024-10" / "2024"

    // Raw context snapshot used to generate this report
    context: { type: mongoose.Schema.Types.Mixed },

    // Parsed AI output — structured sections
    report: {
      summary:          { type: String, default: '' },
      highlights:       [{ type: String }],          // bullet achievements
      improvements:     [{ type: String }],          // what to work on
      nextSteps:        [{ type: String }],          // recommended actions
      motivationMessage:{ type: String, default: '' },
      plateauWarning:   { type: String, default: '' },
      dietFeedback:     { type: String, default: '' },
      workoutFeedback:  { type: String, default: '' },
      consistencyScore: { type: Number, default: 0 },// 0-100
      overallScore:     { type: Number, default: 0 },// 0-100 improvement score
    },

    // Full raw LLM response (for debugging)
    rawResponse:  { type: String, default: '' },
    generatedAt:  { type: Date, default: Date.now },

    // Cache control — re-generate if stale
    isStale:      { type: Boolean, default: false },
  },
  { timestamps: true }
);

reportSchema.index({ user: 1, type: 1, periodKey: 1 }, { unique: true });

module.exports = mongoose.model('Report', reportSchema);