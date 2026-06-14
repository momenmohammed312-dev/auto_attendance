# Auto Attendance — Smart University Attendance System

A Flutter mobile application that automates attendance tracking for universities using GPS geofencing and role-based access control.

## Overview

Manual attendance is slow and error-prone. This app lets instructors create a geofenced attendance session from their location, and students check in automatically when they’re within the defined radius — no paper, no confusion.

## Features

### For Students

- View attendance records per subject
- Track attendance percentage with visual charts
- Access daily schedule/timeline
- Generate attendance reports

### For Instructors

- Create and manage live attendance sessions
- Set GPS geofencing radius on an interactive map
- Monitor real-time student check-ins
- View live activity pulse visualization

### Authentication

- Role-based login (Student / Instructor)
- JWT token management with secure storage
- Persistent session handling

## Tech Stack

|Layer           |Technology                      |
|----------------|--------------------------------|
|Framework       |Flutter (Dart)                  |
|State Management|Riverpod                        |
|HTTP Client     |Dio                             |
|Maps & GPS      |Google Maps Flutter + Geolocator|
|Charts          |FL Chart + Percent Indicator    |
|Secure Storage  |Flutter Secure Storage          |
|Date Formatting |Intl                            |

## Architecture

Clean feature-based architecture separating data, logic, and UI layers:

```
lib/
├── auth/           ✅ Complete — login, splash, JWT
├── features/
│   ├── student/    — Dashboard, reports, attendance charts
│   └── lecturer/   — Session management, geo map, live feed
├── core/           — Network, routing, shared utilities
└── main.dart
```

## Project Status

|Module                       |Status       |
|-----------------------------|-------------|
|Authentication (Login + JWT) |✅ Complete   |
|Student Dashboard & Charts   |🔄 In Progress|
|Instructor Session Management|🔄 In Progress|
|GPS Geofencing               |🔄 In Progress|
|Notifications                |🔄 In Progress|

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Android Studio or VS Code
- Android/iOS device or emulator

### Run the app

```bash
git clone https://github.com/momenmohammed312-dev/auto_attendance
cd auto_attendance
flutter pub get
flutter run
```

## Screenshots

> Coming soon

## Author

**Moamen Mohamed** — Flutter Developer  
[GitHub](https://github.com/momenmohammed312-dev)
