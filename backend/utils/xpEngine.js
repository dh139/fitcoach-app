const User  = require('../models/User');
const XpLog = require('../models/XpLog');

// ─── Level thresholds ────────────────────────────────────────────────────────
const LEVELS = [
  { name: 'beginner',     minXP: 0,     maxXP: 799,   color: '#22c55e' },
  { name: 'intermediate', minXP: 800,   maxXP: 2999,  color: '#3b82f6' },
  { name: 'advanced',     minXP: 3000,  maxXP: 9999,  color: '#a855f7' },
  { name: 'elite',        minXP: 10000, maxXP: Infinity, color: '#f59e0b' },
];

// ─── Streak bonuses ──────────────────────────────────────────────────────────
const STREAK_BONUSES = {
  3:  { xp: 50,  label: '3-day streak!' },
  7:  { xp: 150, label: 'Week warrior!' },
  14: { xp: 300, label: '2-week legend!' },
  30: { xp: 750, label: 'Monthly master!' },
};

// ─── Config ──────────────────────────────────────────────────────────────────
const CONFIG = {
  DECAY_START_DAYS:    7,    // days idle before decay kicks in
  DECAY_PERCENT:       0.02, // lose 2% XP per idle day after threshold
  DECAY_MAX_PERCENT:   0.20, // cap at 20% total loss per decay cycle
  COMEBACK_BONUS_DAYS: 14,   // days away to trigger comeback bonus
  COMEBACK_BONUS_XP:   100,
  LEVEL_UP_BONUS_XP:   200,
  MIN_XP:              0,    // XP never goes below 0
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

const getLevelInfo = (xp) => {
  for (let i = LEVELS.length - 1; i >= 0; i--) {
    if (xp >= LEVELS[i].minXP) return LEVELS[i];
  }
  return LEVELS[0];
};

const getNextLevel = (currentLevelName) => {
  const idx = LEVELS.findIndex((l) => l.name === currentLevelName);
  return idx < LEVELS.length - 1 ? LEVELS[idx + 1] : null;
};

const getXpProgress = (xp) => {
  const current  = getLevelInfo(xp);
  const next     = getNextLevel(current.name);
  if (!next) return { current, next: null, progressPct: 100, xpToNext: 0 };
  const earned   = xp - current.minXP;
  const needed   = next.minXP - current.minXP;
  const progressPct = Math.floor((earned / needed) * 100);
  return { current, next, progressPct, xpToNext: next.minXP - xp };
};

// ─── Core: award XP and write a log entry ────────────────────────────────────

const awardXP = async (userId, amount, source, meta = {}) => {
  const user = await User.findById(userId);
  if (!user) throw new Error('User not found');

  const previousLevel = user.level;
  const previousXP    = user.xp;

  user.xp = Math.max(CONFIG.MIN_XP, user.xp + amount);

  // Recalculate level
  const newLevelInfo = getLevelInfo(user.xp);
  user.level = newLevelInfo.name;
  const didLevelUp = previousLevel !== user.level;

  await user.save();

  // Write XP log entry
  const log = await XpLog.create({
    user:   userId,
    amount,
    source,
    meta:   { ...meta, previousLevel, newLevel: user.level },
    balanceAfter: user.xp,
  });

  // If levelled up — award level-up bonus XP (recursive, one level only)
  let levelUpLog = null;
  if (didLevelUp && amount > 0) {
    const bonusLog = await XpLog.create({
      user:   userId,
      amount: CONFIG.LEVEL_UP_BONUS_XP,
      source: 'level_up_bonus',
      meta:   { previousLevel, newLevel: user.level },
      balanceAfter: user.xp + CONFIG.LEVEL_UP_BONUS_XP,
    });
    await User.findByIdAndUpdate(userId, { $inc: { xp: CONFIG.LEVEL_UP_BONUS_XP } });
    levelUpLog = bonusLog;
  }

  return { log, levelUpLog, didLevelUp, previousLevel, newLevel: user.level, newXP: user.xp };
};

// ─── Streak processing ────────────────────────────────────────────────────────

const processStreak = async (userId) => {
  const user = await User.findById(userId);
  if (!user) return null;

  const bonus = STREAK_BONUSES[user.streak];
  if (!bonus) return null;

  return awardXP(userId, bonus.xp, 'streak_bonus', {
    streakDay: user.streak,
    multiplier: 1,
  });
};

// ─── Comeback bonus ───────────────────────────────────────────────────────────

const processComebackBonus = async (userId, daysInactive) => {
  if (daysInactive < CONFIG.COMEBACK_BONUS_DAYS) return null;

  return awardXP(userId, CONFIG.COMEBACK_BONUS_XP, 'comeback_bonus', {
    daysInactive,
    multiplier: 1,
  });
};

// ─── XP decay (called by cron job) ───────────────────────────────────────────

const applyDecayForUser = async (userId) => {
  const user = await User.findById(userId);
  if (!user || user.xp === 0) return null;

  const lastWorkout = user.lastWorkoutDate
    ? new Date(user.lastWorkoutDate)
    : user.createdAt;

  const daysIdle = Math.floor((Date.now() - lastWorkout.getTime()) / (1000 * 60 * 60 * 24));

  if (daysIdle < CONFIG.DECAY_START_DAYS) return null; // not idle enough

  const extraDays   = daysIdle - CONFIG.DECAY_START_DAYS;
  const decayRate   = Math.min(CONFIG.DECAY_MAX_PERCENT, extraDays * CONFIG.DECAY_PERCENT);
  const decayAmount = -Math.floor(user.xp * decayRate);

  if (decayAmount === 0) return null;

  return awardXP(userId, decayAmount, 'xp_decay', { daysInactive: daysIdle });
};

module.exports = {
  awardXP,
  processStreak,
  processComebackBonus,
  applyDecayForUser,
  getLevelInfo,
  getNextLevel,
  getXpProgress,
  LEVELS,
  STREAK_BONUSES,
  CONFIG,
};