class AppConstants {
  AppConstants._();

  // ── API ────────────────────────────────────────────────────────────────────
  // Android emulator uses 10.0.2.2 to reach the host machine's localhost.
  // For a physical device, use your LAN IP (e.g. 192.168.x.x).
  static const baseUrl     = 'https://fitcoach-zlpn.onrender.com/api';
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

  static const minWorkoutSeconds = 120;

  // ── UI ────────────────────────────────────────────────────────────────────
  static const pageHPad   = 20.0;
  static const cardRadius = 24.0;
  static const btnRadius  = 20.0;
  static const smRadius   = 8.0;
  static const pillRadius = 100.0;
}
