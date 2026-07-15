const mongoose = require('mongoose');

const gymCheckInSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Check-in must belong to a user'],
    },
    gym: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Gym',
      required: [true, 'Check-in must be associated with a gym'],
    },
    checkInTime: {
      type: Date,
      default: Date.now,
      required: true,
    },
    checkOutTime: {
      type: Date,
    },
    zone: {
      type: String,
      enum: ['cardio', 'weights', 'studio', null],
      default: null,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('GymCheckIn', gymCheckInSchema);
