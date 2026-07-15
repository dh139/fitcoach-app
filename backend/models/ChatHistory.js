const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  role:      { type: String, enum: ['user', 'assistant'], required: true },
  content:   { type: String, required: true },
  timestamp: { type: Date,   default: Date.now },
}, { _id: false });

const chatHistorySchema = new mongoose.Schema(
  {
    user:     { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    messages: [messageSchema],
    // Rolling window — keep last 30 messages per user
    messageCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

chatHistorySchema.index({ user: 1 }, { unique: true });

module.exports = mongoose.model('ChatHistory', chatHistorySchema);