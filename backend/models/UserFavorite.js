const mongoose = require('mongoose');

const userFavoriteSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    exercise: { type: mongoose.Schema.Types.ObjectId, ref: 'Exercise', required: true },
  },
  { timestamps: true }
);

userFavoriteSchema.index({ user: 1, exercise: 1 }, { unique: true });

module.exports = mongoose.model('UserFavorite', userFavoriteSchema);