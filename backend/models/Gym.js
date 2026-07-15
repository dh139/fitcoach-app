const mongoose = require('mongoose');

const planSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Plan name is required'],
    trim: true,
  },
  price: {
    type: Number,
    required: [true, 'Plan price is required'],
    min: [0, 'Price cannot be negative'],
  },
  durationDays: {
    type: Number,
    required: [true, 'Plan duration in days is required'],
    min: [1, 'Duration must be at least 1 day'],
  },
  roamingEnabled: {
    type: Boolean,
    default: false,
  },
});

const staffSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  role: {
    type: String,
    enum: ['manager', 'frontdesk'],
    required: true,
  },
});

const gymSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Gym name is required'],
      trim: true,
    },
    address: {
      type: String,
      required: [true, 'Gym address is required'],
      trim: true,
    },
    description: {
      type: String,
      default: '',
    },
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Gym must belong to an owner'],
    },
    plans: [planSchema],
    staff: [staffSchema],
    occupancyLimit: {
      type: Number,
      default: 100,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Gym', gymSchema);
