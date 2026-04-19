class AppConstants {
  AppConstants._();

  // ── API ────────────────────────────────────────────────────────────────────
  // Change this to your deployed backend URL in production
  static const baseUrl     = 'https://fitcoach-zlpn.onrender.com/api'; // Android emulator
  // static const baseUrl  = 'http://localhost:5000/api'; // iOS simulator
  // static const baseUrl  = 'https://your-backend.com/api'; // Production

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);

  // ── Storage keys ──────────────────────────────────────────────────────────
  static const tokenKey    = 'auth_token';
  static const userKey     = 'user_data';

  // ── Gamification ──────────────────────────────────────────────────────────
  static const xpLevels = {
    'beginner':     [0,    799  ],
    'intermediate': [800,  2999 ],
    'advanced':     [3000, 9999 ],
    'elite':        [10000, 99999],
  };

  static const minWorkoutSeconds = 120;  // anti-cheat minimum

  // ── UI ────────────────────────────────────────────────────────────────────
  static const pageHPad   = 20.0;
  static const cardRadius = 20.0;
  static const btnRadius  = 12.0;
  static const smRadius   = 8.0;
  static const pillRadius = 100.0;
}