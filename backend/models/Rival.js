const mongoose = require('mongoose');

const rivalSchema = new mongoose.Schema(
  {
    challenger: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    rival:      { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    status:     { type: String, enum: ['pending', 'active', 'declined'], default: 'pending' },
    // Week of the battle
    weekKey:    { type: String, required: true },
    // Snapshot scores (updated when leaderboard rebuilds)
    challengerScore: { type: Number, default: 0 },
    rivalScore:      { type: Number, default: 0 },
    winner:          { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
  },
  { timestamps: true }
);

rivalSchema.index({ challenger: 1, rival: 1, weekKey: 1 }, { unique: true });

module.exports = mongoose.model('Rival', rivalSchema);