# GoalKeeper - Collaborative Goal Tracking App

## Project Overview
GoalKeeper is a collaborative goal-tracking mobile application built with Flutter and Firebase. It enables users to manage personal and group goals, track progress, collaborate with friends, and stay productive with a clean UI, real-time updates, and social features.

## Key Features
- **Personal Goals**: Set, edit, and track your individual goals  
- **Group Goals**: Collaborate with friends on shared goals  
- **Real-Time Sync**: Instantly sync changes across devices via Firebase  
- **Due Dates & Status**: Set deadlines and mark goals as completed  
- **Friends System**: Add/remove friends, view their profiles, and see shared goals  
- **Secure Authentication**: Firebase Auth with email/password sign-in  
- **User Profiles**: View user info, friend lists, and shared activity  
- **Goal Details**: Deep-dive into goal metadata, participants, and status  

## Technologies Used
- **Frontend**: Dart, Flutter
- **Backend**: Firebase (Authentication, Cloud Firestore)

## How to Use This Source Code

### Prerequisites
- Android Studio / VS Code
- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Firebase account & project (with Firestore + Auth enabled)
- Firebase CLI (for automatic configuration)

---

### 1. Clone the Repository
```bash
git clone https://github.com/SumithShetty1/goalkeeper.git
cd goalkeeper
```

### 2. Install Dependencies
```bash
flutter pub get
```

# Firebase Configuration (Android, iOS, Web)

To use Firebase across **Android**, **iOS** and **Web**, follow these steps:

---

## a. Android Setup

1. Go to Firebase Console → [https://console.firebase.google.com](https://console.firebase.google.com)
2. Select your Firebase project  
3. Click **"Add App"** → choose **Android**  
4. Register App:
   - **Package Name**: `com.example.goalkeeper`  
5. Download `google-services.json`
6. Place it in:
   ```bash
   android/app/google-services.json
   ```

## b. iOS Setup

1. Go back to Firebase Console
2. Click **"Add App"** → choose iOS
3. Register App:
   - **iOS bundle ID**: `com.example.goalkeeper`
4. Download `GoogleService-Info.plist`
5. Place it in:
   ```bash
   ios/Runner/GoogleService-Info.plist
   ```

## c. Web Setup

1. Go back to Firebase Console
2. Click **"Add App"** → choose Web
3. Register app and give it a nickname (e.g., **"GoalKeeper Web"**)

You'll see a Firebase config object, but do not manually copy it

Instead, run the Firebase CLI (see next section) to auto-generate platform options for Flutter

## d. Firebase CLI Setup (Auto-generate firebase_options.dart)

This will generate platform-specific Firebase configuration automatically.

**Install Firebase CLI** (if not installed):

```bash
npm install -g firebase-tools
```

**Login to Firebase:**

```bash
firebase login
```

**Run FlutterFire CLI to generate firebase_options.dart:**

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will:
- Detect your Firebase project
- Let you select supported platforms (Android, Web, iOS)
- Generate:
  ```bash
  lib/firebase_options.dart
  ```

## e. Run the App on Any Platform

**Android:**
```bash
flutter run -d android
```

**Web:**
```bash
flutter run -d chrome
```

**iOS:**
```bash
flutter run -d ios
```

## Disclaimer

This project is a personal/portfolio project created for educational and demonstration purposes. It is not affiliated with or endorsed by any existing company or product that may share a similar name.
