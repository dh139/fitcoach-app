const helmet      = require('helmet');
const rateLimit   = require('express-rate-limit');
const compression = require('compression');
const morgan      = require('morgan');

// General API rate limit — 100 req / 15 min per IP
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max:      100,
  standardHeaders: true,
  legacyHeaders:   false,
  message: { success: false, message: 'Too many requests — please slow down.' },
});

// Stricter limit for auth routes — 10 req / 15 min
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max:      10,
  message:  { success: false, message: 'Too many auth attempts — try again later.' },
});

// Stricter for AI endpoints (expensive)
const aiLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max:      5,
  message:  { success: false, message: 'AI rate limit — wait a moment before sending another request.' },
});

const applySecurityMiddleware = (app) => {
  // HTTP headers security
  app.use(helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
    contentSecurityPolicy: false, // disable CSP for API server
  }));

  // Gzip compression
  app.use(compression());

  // Request logging (only in development)
  if (process.env.NODE_ENV !== 'production') {
    app.use(morgan('dev'));
  } else {
    app.use(morgan('combined'));
  }

  return { apiLimiter, authLimiter, aiLimiter };
};

module.exports = { applySecurityMiddleware, apiLimiter, authLimiter, aiLimiter };