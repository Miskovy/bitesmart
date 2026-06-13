# 🍎 BiteSmart Backend

[![TypeScript](https://img.shields.io/badge/TypeScript-5.9-blue?style=for-the-badge&logo=typescript)](https://www.typescriptlang.org/)
[![Node.js](https://img.shields.io/badge/Node.js-20-green?style=for-the-badge&logo=node.js)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-5.2-lightgrey?style=for-the-badge&logo=express)](https://expressjs.com/)
[![Drizzle ORM](https://img.shields.io/badge/Drizzle%20ORM-0.45-orange?style=for-the-badge&logo=drizzle)](https://orm.drizzle.team/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=for-the-badge&logo=mysql)](https://www.mysql.com/)
[![Redis](https://img.shields.io/badge/Redis-5.10-red?style=for-the-badge&logo=redis)](https://redis.io/)
[![Docker](https://img.shields.io/badge/Docker-20-blue?style=for-the-badge&logo=docker)](https://www.docker.com/)

BiteSmart is an AI-powered nutrition, coaching, and health tracking platform designed to simplify calorie counting, promote habit formation, and connect users with expert coaches. 

This repository houses the robust backend API built on **Node.js**, **Express**, **TypeScript**, and **Drizzle ORM**, supporting real-time AI nutrition prediction, chat streaming, and dynamic gamification features.

---

## 🌟 Key Features

### 1. 🤖 AI-Powered Nutrition Analysis
* **AR-Based Prediction (`/api/prediction/ar`)**: Predicts food type and portion sizes using image analysis and the absolute width of the food item.
* **Plate Calibration (`/api/prediction/callibration`)**: Predicts nutrition facts using image recognition calibrated against the diameter of a standard dining plate.
* **User Feedback Loop (`/api/prediction/correct/:id`)**: Supports user corrections to continuously refine and train the AI models.

### 2. 💬 Coaching & Interactive Chat
* **Expert Chat Sessions**: Connects users with AI-driven or real-world coaches with support for full history retrieval, search, pagination, and category filters.
* **SSE Streaming (`/api/coach/chat/stream`)**: Real-time message streaming using Server-Sent Events (SSE) for responsive, low-latency communication.

### 3. 📅 Daily Health Logging
* **Meal & Water Tracker**: Easily log meals, calculate daily calorie budgets/macronutrients, and track water intake.
* **Symptom Tracker**: Specifically optimized for logging symptoms (e.g., GLP-1 weight-loss medication side effects) and general daily health check-ins.
* **Day Completion Summary**: Summarize daily achievements (calories consumed vs. targeted, water targets met, challenges updated) and confirm the end of a log day.

### 4. 🏆 Gamification & Engagement
* **Community Challenges**: Join, track, and complete community-wide fitness and diet challenges.
* **Leaderboards**: Dynamically computed leaderboards sorting users by challenge completion points.
* **Badges & Achievements**: Automated system awarding badges for milestones (e.g., water logging streaks, daily completion streaks).

### 5. ⚙️ Health Sync & Mode Configurations
* **Tailored Health Modes**: Toggle and configure specialized modules:
  * **GLP-1 Mode**: Focuses on symptom tracking, protein intake, and hydration.
  * **Fasting Mode**: Tracks fasting/eating window progress and settings.
  * **Ramadan Mode**: Supports pre-dawn (Suhoor) and post-dusk (Iftar) fasting periods.
* **Health Syncing**: Secure endpoints designed to sync physical metrics with mobile health systems (Apple Health / Google Fit).

---

## 🛠️ Technology Stack

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| **Runtime & Language** | Node.js (v20+), TypeScript | Reliable type-safe runtime execution |
| **Web Framework** | Express (v5.2) | Fast, unopinionated routing and controller handling |
| **Database & ORM** | MySQL (Aiven.io), Drizzle ORM | Relational data mapping with type-safe schema migrations |
| **Caching & Queues** | Redis (ioredis) | Session management, caching, and rate limiting |
| **Security** | Helmet, CORS, JWT, CryptoJS | Secure headers, custom origin restrictions, encrypted signatures |
| **File Storage** | Multer | Handling multipart form data for avatar and food image uploads |

---

## 📂 Project Architecture

The codebase follows a clean, modular layer-based architecture separating routes, controllers, and business service logic:

```text
src/
├── constants/         # App-wide constant configurations (API endpoints, credentials keys)
├── controllers/       # Handles HTTP requests, validations, and response payload mapping
│   ├── auth/          # Signup, login, forgot-password, Google OAuth
│   ├── food/          # Food item queries, custom foods, and AI predictions
│   └── user/          # Profiles, daily logs, symptoms, modes, and challenges
├── db/                # Database connection configuration and schema reset script
├── drizzle/           # Automatically generated Drizzle ORM migration files
├── errors/            # Custom application error classes (BadRequest, Unauthorized, etc.)
├── middlewares/       # Security (CORS, Helmet), Authentication (JWT validation), and Error Handling
├── models/            # Drizzle relational database table definitions
├── routes/            # Express endpoint mappings and route registration
├── seeds/             # Seed runners for populating local/staging mock data
├── server.ts          # Core entrypoint initializing Express, Middlewares, and Database connection
├── services/          # Pure business logic layer interacting with databases and external APIs
├── types/             # TypeScript interfaces and namespace declarations
├── utils/             # Helper utilities (response helpers, async wrappers)
└── validators/        # Schema validators for incoming request bodies
```

---

## ⚙️ Environment Variables Setup

Create a `.env` file in the root directory. You can copy the values from `example.env` as a template:

```bash
cp example.env .env
```

| Variable | Description | Example / Default |
| :--- | :--- | :--- |
| `PORT` | Local server port | `3000` |
| `NODE_ENV` | Environment stage | `development` \| `production` |
| `JWT_SECRET` | Secret key used to sign JWTs | `your_super_secret_jwt_key` |
| `CORS_ORIGINS` | Allowed origins (comma-separated in production) | `*` (wildcard) or `https://app.bitesmart.com` |
| `AI_BASE_URL` | Base URL of the Hugging Face AI engine | `https://miskovy-bitesmart-ai.hf.space/api` |
| `AI_API_KEY` | Public key credentials for AI Service | `your_ai_api_key` |
| `AI_API_SECRET`| Secret key credentials for signing requests | `your_ai_api_secret` |
| `DATABASE_URL` | MySQL Connection URL | `mysql://user:password@host:port/dbname` |
| `REDIS_HOST` | Hostname of the Redis server | `127.0.0.1` |
| `REDIS_PORT` | Port of the Redis server | `6379` |
| `EMAIL_USER` | SMTP username for password resets | `noreply@bitesmart.com` |
| `EMAIL_PASS` | SMTP password / App password | `your_smtp_app_password` |

---

## 🚀 Getting Started

### Prerequisites
* **Node.js** (v20 or higher)
* **npm** (v10 or higher)
* **MySQL Database**
* **Redis Server**

### 1. Installation
Clone the repository and install all dependencies:
```bash
npm install
```

### 2. Database Migration & Setup
Generate and apply database tables to your MySQL database using Drizzle Kit:

```bash
# 1. Create the database (if not exists)
npm run dbcreate

# 2. Generate migration SQL files
npm run generate-db

# 3. Apply schema migrations directly to the database
npm run migrate-db
```

### 3. Database Seeding (Optional)
Populate your database with mock users, food items, and challenges:
```bash
# Seed standard mock data
npm run seed

# Clear database and perform a fresh seed
npm run seed:fresh

# Reset database (drops all tables)
npm run reset-db
```

### 4. Running the Application

* **Development Mode** (with hot-reloading via `tsx`):
  ```bash
  npm run dev
  ```

* **Production Mode**:
  ```bash
  npm run build
  npm run start:prod
  ```

---

## 📡 API Route Reference

### Authentication (`/api/auth`)
* `POST /api/auth/signup` - Registers a new user.
* `POST /api/auth/login` - Authenticates user and returns JWT.
* `POST /api/auth/google` - Verifies Google OAuth token and logs in/registers.
* `POST /api/auth/forgot-password` - Requests reset code via email.
* `POST /api/auth/verify-reset-code` - Validates the password reset OTP.
* `POST /api/auth/reset-password` - Resets user password using valid OTP.

### Food & AI Predictions (`/api/food` & `/api/prediction`)
* `GET /api/food` - Fetch food inventory list (supports search).
* `GET /api/food/:id` - Fetch details of a specific food item.
* `POST /api/food/custom` *(Auth)* - Register a custom food item.
* `POST /api/prediction/ar` - Predict nutrition using food image + food width.
* `POST /api/prediction/callibration` - Predict nutrition using food image + plate diameter.
* `PUT /api/prediction/correct/:trainingDataId` - Submit user corrections for AI feedback.

### User Profile (`/api/profile` - *Auth*)
* `GET /api/profile` - Fetch current user profile details, target, and preferences.
* `PUT /api/profile` - Update user bio, dietary preferences, and medical conditions.
* `POST /api/profile/avatar` - Upload a profile image.
* `POST /api/profile/targets/calculate` - Automatically compute and save nutrition targets.
* `PATCH /api/profile/device-settings` - Update health device parameters.
* `POST /api/profile/health-sync` - Sync health metrics from external devices.

### Daily Tracking Logs (`/api/logs` - *Auth*)
* `GET /api/logs` - Retrieve meal log entries for a specific date.
* `POST /api/logs` - Log a food/meal entry.
* `DELETE /api/logs/:logId` - Remove logged meal entry.
* `GET /api/logs/summary` - Get daily nutrition and calorie summary.
* `GET /api/logs/water` - Retrieve logged water consumption.
* `POST /api/logs/water` - Log water intake.
* `POST /api/logs/complete` - Confirm the completion of a day (processes streaks/achievements).

### Specialized Health Settings (`/api/settings` - *Auth*)
* `GET /api/settings/glp1` - Retrieve GLP-1 Mode tracking settings.
* `PUT /api/settings/glp1` - Update GLP-1 Mode tracking settings.
* `GET /api/settings/fasting` - Retrieve Fasting Mode intervals.
* `PUT /api/settings/fasting` - Update Fasting Mode configuration.
* `PUT /api/settings/ramadan` - Configure Ramadan eating/fasting settings.

### Coach Interactions (`/api/coach` - *Auth*)
* `GET /api/coach/sessions` - Retrieve all ongoing coaching chat sessions.
* `GET /api/coach/sessions/:chatId/history` - Fetch full message history of a session.
* `DELETE /api/coach/sessions/:chatId` - Delete a chat session.
* `POST /api/coach/chat` - Send a message to a coach (asynchronous response).
* `POST /api/coach/chat/stream` - Send a message to a coach (real-time stream response).

### Challenges & Leaderboards (`/api/challenges` & `/api/leaderboard` - *Auth*)
* `GET /api/challenges` - List available community challenges and user progress.
* `POST /api/challenges/:challengeId/join` - Join a specific community challenge.
* `POST /api/challenges/:challengeId/leave` - Leave a challenge.
* `POST /api/challenges/:challengeId/progress` - Update challenge milestone progress.
* `GET /api/leaderboard` - Fetch points leaderboard of all competing users.

---

## 🐳 Docker Deployment

The application features a multi-stage `Dockerfile` optimized for minimal production image sizes.

### Build the Docker Image
```bash
docker build -t bitesmart-backend .
```

### Run the Docker Container
Ensure your environment variables are configured. You can load variables directly using an `.env` file:
```bash
docker run -d \
  -p 3000:3000 \
  --env-file .env \
  --name bitesmart-api \
  bitesmart-backend
```

---

## 📄 License
This project is licensed under the ISC License. See the [LICENSE](LICENSE) file for more information.
