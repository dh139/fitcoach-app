// Anti-cheat thresholds
const RULES = {
  MIN_DURATION_SECONDS: 120,        // session must be at least 2 minutes
  MIN_EXERCISES_COMPLETED: 2,       // must complete at least 2 exercises
  MIN_CLICK_SPACING_MS: 5000,       // each "done" click must be 5s apart
  MAX_SUSPICIOUS_SPEED_MS: 2000,    // clicks faster than 2s = suspicious
  INSTANT_COMPLETE_THRESHOLD_S: 10, // completing everything in <10s = instant
};

/**
 * Validates a completed workout session.
 * Returns { isVerified, qualityScore, details, xpMultiplier, reason }
 */
const validateSession = ({ startTime, endTime, exerciseLogs }) => {
  const durationSeconds = Math.floor((endTime - startTime) / 1000);
  const exerciseCount   = exerciseLogs.filter((e) => e.setsCompleted > 0 || e.durationSeconds > 0).length;

  const details = {
    durationValid:      false,
    exerciseCountValid: false,
    clickSpacingValid:  false,
    qualityScore:       0,
  };

  const reasons = [];

  // Rule 1: Minimum duration
  if (durationSeconds >= RULES.MIN_DURATION_SECONDS) {
    details.durationValid = true;
  } else {
    reasons.push(`Session too short (${durationSeconds}s < ${RULES.MIN_DURATION_SECONDS}s minimum)`);
  }

  // Rule 2: Minimum exercises
  if (exerciseCount >= RULES.MIN_EXERCISES_COMPLETED) {
    details.exerciseCountValid = true;
  } else {
    reasons.push(`Too few exercises completed (${exerciseCount} < ${RULES.MIN_EXERCISES_COMPLETED} minimum)`);
  }

  // Rule 3: Click spacing — check all clickTimestamps across all exercises
  const allClicks = exerciseLogs
    .flatMap((e) => e.clickTimestamps || [])
    .sort((a, b) => a - b);

  let suspiciousClicks = 0;
  if (allClicks.length <= 1) {
    // Only 0 or 1 click — no spacing to validate, pass if other rules met
    details.clickSpacingValid = exerciseCount > 0;
  } else {
    for (let i = 1; i < allClicks.length; i++) {
      const gap = allClicks[i] - allClicks[i - 1];
      if (gap < RULES.MAX_SUSPICIOUS_SPEED_MS) suspiciousClicks++;
    }
    const suspiciousRatio = suspiciousClicks / (allClicks.length - 1);
    details.clickSpacingValid = suspiciousRatio < 0.5; // less than 50% suspicious
    if (!details.clickSpacingValid) {
      reasons.push(`Suspicious click pattern detected (${suspiciousClicks} rapid completions)`);
    }
  }

  // Rule 4: Instant complete check
  if (durationSeconds < RULES.INSTANT_COMPLETE_THRESHOLD_S && exerciseCount > 0) {
    details.durationValid    = false;
    details.clickSpacingValid = false;
    reasons.push('Session completed too fast — possible instant-complete attempt');
  }

  // Quality score (0-100)
  let score = 0;
  if (details.durationValid)      score += 40;
  if (details.exerciseCountValid) score += 30;
  if (details.clickSpacingValid)  score += 30;

  // Bonus for longer sessions (up to +20 virtual points for XP multiplier calc)
  const durationBonus = Math.min(20, Math.floor(durationSeconds / 60) * 2);
  details.qualityScore = Math.min(100, score + durationBonus);

  const isVerified = details.durationValid && details.exerciseCountValid && details.clickSpacingValid;

  // XP multiplier based on quality
  let xpMultiplier = 0;
  if (isVerified) {
    if (details.qualityScore >= 90) xpMultiplier = 1.5;
    else if (details.qualityScore >= 70) xpMultiplier = 1.2;
    else xpMultiplier = 1.0;
  }

  return {
    isVerified,
    qualityScore: details.qualityScore,
    details,
    xpMultiplier,
    durationSeconds,
    reason: reasons.length > 0 ? reasons.join('; ') : 'Session verified',
  };
};

/**
 * Calculate XP earned from a verified session.
 * Base XP: 10 per minute + 5 per exercise + calories/10
 */
const calculateXP = ({ durationSeconds, exerciseCount, totalCalories, xpMultiplier = 1.0 }) => {
  const minuteXP   = Math.floor(durationSeconds / 60) * 10;
  const exerciseXP = exerciseCount * 5;
  const calorieXP  = Math.floor(totalCalories / 10);
  const baseXP     = minuteXP + exerciseXP + calorieXP;
  return Math.round(baseXP * xpMultiplier);
};

/**
 * Calculate calories burned from an exercise log entry.
 */
const calculateCalories = ({ caloriesPerMinute = 6, durationSeconds = 0, setsCompleted = 0, repsCompleted = 0 }) => {
  if (durationSeconds > 0) {
    return Math.round((caloriesPerMinute * durationSeconds) / 60);
  }
  // Estimate ~3s per rep for strength exercises
  const estimatedSeconds = setsCompleted * repsCompleted * 3;
  return Math.round((caloriesPerMinute * estimatedSeconds) / 60);
};

module.exports = { validateSession, calculateXP, calculateCalories, RULES };