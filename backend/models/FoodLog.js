const mongoose = require('mongoose');

const foodLogSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    // Food details
    name:     { type: String, required: true, trim: true },
    brand:    { type: String, default: '' },
    quantity: { type: Number, default: 1 },
    unit:     { type: String, default: 'serving' }, // g, ml, cup, piece, serving

    // Macros per entry (already multiplied by quantity)
    calories: { type: Number, required: true, min: 0 },
    protein:  { type: Number, default: 0 },  // grams
    carbs:    { type: Number, default: 0 },  // grams
    fat:      { type: Number, default: 0 },  // grams
    fiber:    { type: Number, default: 0 },  // grams

    // Meal slot
    mealType: {
      type: String,
      enum: ['breakfast', 'lunch', 'dinner', 'snack'],
      default: 'snack',
    },

    // Source of entry
    source: {
      type: String,
      enum: ['search', 'photo', 'manual'],
      default: 'manual',
    },

    // Photo analysis (optional)
    photoUrl:       { type: String, default: '' },
    aiAnalysis:     { type: String, default: '' }, // raw AI response text

    // Date the food was consumed (not createdAt — user may log past meals)
    loggedDate: {
      type: String, // "YYYY-MM-DD"
      required: true,
      default: () => new Date().toISOString().slice(0, 10),
    },
  },
  { timestamps: true }
);

foodLogSchema.index({ user: 1, loggedDate: 1 });
foodLogSchema.index({ user: 1, createdAt: -1 });

module.exports = mongoose.model('FoodLog', foodLogSchema);