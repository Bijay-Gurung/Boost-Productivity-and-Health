# Boost Productivity and Health

A comprehensive Flutter application designed to help users manage their daily tasks, plan their meals, and track their fitness routines all in one place.

## Overview

**Boost Productivity and Health** is a full-stack project featuring a Flutter mobile app and a Node.js backend API. The application aims to create a holistic ecosystem for users to improve their lifestyle by keeping track of their diet, exercise, and daily tasks.

### Key Features

- **Authentication & Security:** Secure user registration, login, and password recovery using secure storage.
- **Task Management:** Organize your daily to-dos, set priorities, and track task completion.
- **Meal Planner & Dietary Tracking:**
  - Browse meal categories and specific meal details.
  - Set dietary preferences and plan daily or weekly meals.
- **Fitness & Exercise Log:**
  - Choose from different workout types.
  - Log exercises and track your fitness journey.
- **Calendar Integration:** View your tasks, meals, and workouts in an intuitive calendar view.

## Technology Stack

### Frontend (Mobile App)

- **Framework:** Flutter & Dart
- **State Management:** Provider
- **Local Storage:** Shared Preferences, Flutter Secure Storage
- **Key Packages:** `table_calendar` for scheduling, `http` for API communication, `image_picker` for media uploads, and `cached_network_image`.

### Backend (API)

- **Runtime:** Node.js
- **Structure:** Includes routes, middleware, models, and utility modules to serve the mobile application.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.0.0)
- [Node.js](https://nodejs.org/) (for the backend server)

### Running the Mobile App

1. Clone the repository and navigate to the project directory.
2. Run `flutter pub get` to install the dependencies.
3. Start the app on your emulator or physical device using `flutter run`.

### Running the Backend Server

1. Navigate to the `backend/` directory.
2. Run `npm install` to install necessary Node modules.
3. Configure your `.env` variables (such as database URI, port, etc.).
4. Run `npm start` or `node server.js` to launch the backend API.

## Project Structure

- `lib/` - Contains the Dart source code for the Flutter app.
  - Authentication screens (`Login.dart`, `Signup.dart`, etc.)
  - Feature screens (`MealPlanner.dart`, `taskManagerScreen.dart`, `exerciseLogScreen.dart`, etc.)
- `backend/` - Contains the Node.js API server code.
  - `models/` - Database schemas
  - `routes/` - API endpoints
  - `middleware/` - Custom middleware functions
  - `server.js` - Server entry point
- `assets/` - Images and other static assets.
