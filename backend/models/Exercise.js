const mongoose = require('mongoose');

const exerciseSchema = new mongoose.Schema(
  {
    exerciseId: { type: String, required: true, unique: true }, // from external API
    name: { type: String, required: true, trim: true },
    bodyPart: { type: String, required: true, lowercase: true },
    equipment: { type: String, required: true, lowercase: true },
    gifUrl: { type: String },
    target: { type: String, required: true, lowercase: true }, // primary muscle
    secondaryMuscles: [{ type: String }],
    instructions: [{ type: String }],
    difficulty: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced'],
      default: 'intermediate',
    },
    caloriesPerMinute: { type: Number, default: 6 }, // rough estimate by difficulty
    isFeatured: { type: Boolean, default: false },
  },
  { timestamps: true }
);

exerciseSchema.index({ bodyPart: 1 });
exerciseSchema.index({ target: 1 });
exerciseSchema.index({ equipment: 1 });
exerciseSchema.index({ name: 'text' }); // full-text search

module.exports = mongoose.model('Exercise', exerciseSchema);