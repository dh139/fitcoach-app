const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      maxlength: 50,
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      match: [/\S+@\S+\.\S+/, 'Invalid email format'],
    },
    password: {
      type: String,
      required: [true, 'Password is required'],
      minlength: 6,
      select: false,
    },

    // Profile
    age: { type: Number, min: 10, max: 100 },
    weight: { type: Number, min: 20, max: 300 }, // kg
    height: { type: Number, min: 100, max: 250 }, // cm
    gender: { type: String, enum: ['male', 'female', 'other'] },
    fitnessGoal: {
      type: String,
      enum: ['lose_weight', 'build_muscle', 'improve_endurance', 'stay_fit', 'gain_weight'],
      default: 'stay_fit',
    },
    activityLevel: {
      type: String,
      enum: ['sedentary', 'light', 'moderate', 'active', 'very_active'],
      default: 'moderate',
    },

    // Gamification
    xp: { type: Number, default: 0 },
    level: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced', 'elite'],
      default: 'beginner',
    },
    streak: { type: Number, default: 0 },
    lastWorkoutDate: { type: Date },
    streakFreezeCount: { type: Number, default: 0 },

    // Stats
    totalWorkouts: { type: Number, default: 0 },
    totalCaloriesBurned: { type: Number, default: 0 },
    totalMinutesWorked: { type: Number, default: 0 },

    // Profile image (optional)
    avatar: { type: String, default: '' },

    isActive: { type: Boolean, default: true },
    role: {
      type: String,
      enum: ['user', 'owner'],
      default: 'user',
    },
    referralCode: {
      type: String,
      unique: true,
      sparse: true,
    },
  },
  { timestamps: true }
);

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (this.isNew && this.role === 'user' && !this.referralCode) {
    this.referralCode = Math.random().toString(36).substring(2, 10).toUpperCase();
  }
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Compare password
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Auto-calculate level from XP
userSchema.methods.calculateLevel = function () {
  if (this.xp >= 10000) return 'elite';
  if (this.xp >= 3000) return 'advanced';
  if (this.xp >= 800) return 'intermediate';
  return 'beginner';
};

module.exports = mongoose.model('User', userSchema);