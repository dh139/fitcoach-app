# App
- **Purpose**: AI-driven fitness coaching, gamification, and workout/nutrition tracking.
- **Target users**: Individuals seeking fitness coaching and gym owners/managers tracking member routines.
- **Core workflow**:
  - User: Sign up -> Select goals/wearables -> Buy gym membership -> Log workouts & meals -> Earn XP.
  - Gym Owner: Sign up -> Register Gym -> Manage custom membership plans -> Monitor members/check-ins.

# Tech Stack
- **Frontend**: Flutter (Dart), Hive (Local DB), flutter_secure_storage, Health SDKs.
- **Backend**: Node.js, Express, MongoDB (Mongoose), node-cron.
- **Database**: MongoDB.
- **Authentication**: JWT with bcryptjs.
- **Storage**: None (transient AI photo analysis, local references).
- **External services**: Groq API (LLaMA models), Open Food Facts API, Apple Health / Google Fit.

# Frontend
- **Architecture pattern**: Feature-first layered structure.
- **State management**: Riverpod with code generation.
- **Navigation**: GoRouter (Splash, Auth, and Bottom Navigation Shell).
- **API layer**: Dio with bearer interceptors, supporting SSE streaming.
- **Important folders**:
  - `lib/core`: Constants, theme, router, network client, background tasks, health sync.
  - `lib/features`: Modules (`auth`, `workout`, `gym_hub`, `wearables`, `exercises`, `calories`, `leaderboard`, `coach`, `reports`, `rivals`, `challenges`, `profile`, `history`).
  - `lib/shared/widgets`: Global UI components.

# Backend
- **Architecture**: MVC/Service Layered Architecture.
- **Request flow**: Client -> Express App -> Security & Cors -> Rate limits -> Token check -> Controller -> Service/Model -> Client response.
- **Important folders**:
  - `controllers`: API endpoint handlers.
  - `models`: Mongoose schemas.
  - `routes`: Route declarations.
  - `services`: Business logic (AI, reports, nutrition, gym sync).
  - `jobs`: Cron schedules (leaderboards, XP decay).
  - `utils`: Helpers (anti-cheat, XP engine).
- **Middleware**: Helmet, compression, morgan, rate-limiters, protect auth checker.
- **Error handling**: Global Express error handler catch-all returning customized messages.

# Database
- **User**: Profiles, goals, role (user/owner), gamification metrics (XP, level, streak). No relations.
- **Gym**: Gym details, owner, custom membership plans. Relations: `owner` -> `User`.
- **Membership**: User active plan, status, dummy payment status. Relations: `user` -> `User`, `gym` -> `Gym`.
- **GymCheckIn**: Live check-in logs. Relations: `user` -> `User`, `gym` -> `Gym`.
- **Workout**: Sessions logs, anti-cheat status, exercises. Relations: `user` -> `User`, `exerciseLogs.exercise` -> `Exercise`.
- **FoodLog**: Meal info, macros, AI analysis logs. Relations: `user` -> `User`.
- **Exercise**: Catalog of movements, targets, difficulties. No relations.
- **UserFavorite**: User favorite movements. Relations: `user` -> `User`, `exercise` -> `Exercise`.
- **Challenge**: Daily/weekly target challenges. Relations: `completions.user` -> `User`.
- **XpLog**: XP transaction ledger. Relations: `user` -> `User`, `meta.workoutId` -> `Workout`.
- **LeaderboardSnapshot**: Snapshot rankings. Relations: `entries.user` -> `User`.
- **Report**: AI fitness feedback records. Relations: `user` -> `User`.
- **Rival**: Duels and metrics between users. Relations: `challenger` -> `User`, `rival` -> `User`, `winner` -> `User`.
- **ChatHistory**: rolling AI chat history. Relations: `user` -> `User`.

# APIs
- **Auth**: Register (User/Owner), Login (User/Owner), Get/Update Profile.
- **Exercises**: List/Search, Filters, Toggle Favorites.
- **Workout**: Start, Complete (Anti-cheat check), Get History/Stats.
- **XP**: Get Profile/History, Use Streak Freeze.
- **Leaderboard**: Get Snapshot rankings, Get User Metrics.
- **Calories**: Search, Analyze Photo (AI macros), Log/Delete entry, Get Summary.
- **Report**: Get Report by type, Get History.
- **Coach**: Chat (SSE stream), Get/Clear History, Get Improvement Score.
- **Challenges**: List active, Complete/Claim.
- **Rivals**: Get list/recommendations, Send challenge, Accept/Decline request.
- **Gym Hub**: Register Gym, Check-in/out (QR scan), Add/Edit Plans, Get Gym Members & Memberships.
- **Memberships**: Get Plans, Buy Plan (Dummy checkout), Get Active Status.
- **Wearables**: Sync steps/calories, Link device, Get sleep logs.

# Existing Features
- **Profile Setup & Onboarding**: Collects user body metrics and goals to set personalized AI coaching context.
- **Gamified Leveling & XP**: Custom leveling system based on completed workouts, consistency, streaks, and XP decay.
- **AI Fitness Coach**: Real-time SSE text/voice assistant chatbot.
- **AI Food Photo Analyzer**: Captures macros and calories directly from uploaded food images.
- **Anti-Cheat Verification**: Session validation checking click intervals, exercise counts, and session durations.
- **Composite Leaderboards**: Periodic daily, weekly, and monthly snapshot rankings.
- **Rival Duels**: 1v1 active competitive challenges.
- **AI Fitness Reports**: Periodic progress summaries and motivational analyses.

# Planned Features
- **Gym Owner Registration & Login**: Distinct onboarding/login portal for gym owners and administrators.
- **Gym Membership & Plans**: Gym owners create plans; users choose gym, purchase plans via dummy checkout, and view active status.
- **Gym Owner Portal**: Gym owners manage plans, view active members, membership details, and check-ins.
- **Gym Portal (Gym Hub)**: QR-based check-in, real-time gym occupancy heatmap, local gym leaderboard.
- **Wearable Device Sync**: Integrates background step count, active calories, and heart rate data from smartwatches.

# Reusable Components
- **Global Widgets**: Custom prefix `Fc` widgets: `FcButton`, `FcCard`, `FcLoader`, `FcPageScaffold`, `FcTextField`, `FcBadge`.
- **Feature Indicators**: `LevelBadge`, `PulseDot`, `StatCard`, `StreakRow`, `XpBar`.
- **Core Services**: Background Pedometer & Health sync task, Local Notifications coordinator.
- **HTTP Client**: Singleton `ApiClient` with automated `AuthInterceptor`.

# Environment
- PORT
- MONGO_URI
- JWT_SECRET
- JWT_EXPIRES_IN
- NODE_ENV
- GROQ_API_KEY

# Development Rules
- **Naming convention**:
  - Frontend: `snake_case` files, `PascalCase` classes, `fc_`/`Fc` prefixes for global widgets.
  - Backend: `camelCase` routes/controllers/services/jobs/utils, `PascalCase` models.
- **Folder convention**:
  - Frontend: Feature-first structure: `lib/features/<name>/[models, providers, repositories, screens]`.
  - Backend: Modular directories (`routes`, `controllers`, `services`, `models`, `middleware`, `jobs`, `utils`).
- **Coding style**:
  - Frontend: Riverpod generated code structure; custom API client.
  - Backend: Router routing; thin controllers; business logic in services.
- **Architecture pattern**:
  - Frontend: Repository-Provider-Screen Separation (Clean Architecture inspired).
  - Backend: MVC-Service-based layered pattern.

# Current Limitations
- **Offline catalogs**: Fallback local JSON if ExerciseDB is unreachable.
- **No media hosting**: Relying on base64 strings passed directly to Groq (no S3 bucket storage).
- **Scheduler**: In-memory cron tasks (susceptible to server restarts).
- **Chat limit**: rolling window of 50 messages.
- **Simple anti-cheat**: Relies only on client timestamps click-interval analysis.
- **Wearable sync**: Standard health API aggregates only (no live smartwatch streaming).
- **Dummy checkout**: Payment simulation has no real-world gateway validation (no Razorpay).

## AI Instructions
- Reuse existing architecture.
- Never duplicate functionality.
- Prefer existing services/components.
- Follow current naming conventions.
- Minimize breaking changes.
- Keep controllers thin.
- Put business logic in services.
- Keep UI consistent.
- Ask before changing database schema.
- Ask before changing authentication.
- Keep new features modular.
