# Auto Attendance — Smart University Attendance System

A Flutter mobile application that automates attendance tracking for universities using **face recognition via remote ML API**, **GPS geofencing**, **biometric authentication**, and role-based access control.

## Overview

Manual attendance is slow and error-prone. This app lets instructors create a geofenced attendance session, and students check in using **face recognition** or **biometric authentication** — no paper, no confusion.

## Features

### For Students

- **Face Recognition Check-in** — Capture face via camera, verified against ML API server
- **Biometric Authentication** — Fingerprint / Face ID / PIN fallback via `local_auth`
- View attendance records per subject with visual charts
- Track overall attendance percentage (circular chart)
- Access daily schedule/timeline
- Submit excuse requests for absences
- Real-time notifications

### For Instructors (Doctor)

- Create and manage live attendance sessions
- Set GPS geofencing radius on an interactive map
- Monitor real-time student check-ins with live feed
- View attendance history and analytics
- Smart pulse visualization showing present/absent counts
- End sessions and view reports

### Authentication

- Role-based login (Student / Doctor) with **Name + Student ID**
- Biometric quick-login with "Remember Me" (secure storage)
- JWT token management with secure storage
- Persistent session handling

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| HTTP Client | Dio |
| Face Recognition | Remote ML API (`hassanhamamsi-ml-api.hf.space`) |
| Biometric Auth | `local_auth` (fingerprint / Face ID / PIN) |
| Face Detection | `google_mlkit_face_detection` (pre-check) |
| GPS & Location | `geolocator` |
| Camera | `camera` |
| Charts | `fl_chart` + `percent_indicator` |
| Secure Storage | `flutter_secure_storage` |
| Notifications | `flutter_local_notifications` |
| Date Formatting | `intl` |

## Architecture

Feature-based architecture with clear data / provider / screen / widget layers:

```
lib/
├── auth/                    # Login, splash, JWT, biometric quick-login
│   ├── data/                # AuthRepository, LoginRequest, UserModel
│   ├── providers/           # AuthProvider (Riverpod StateNotifier)
│   └── screens/             # LoginScreen, SplashScreen
├── core/
│   ├── biometric/           # BiometricService (local_auth wrapper)
│   ├── network/             # ApiClient, ApiEndpoints, MlSecretInterceptor
│   ├── storage/             # SecureStorage (JWT + user data)
│   └── utils/               # Constants
├── features/
│   ├── biometric/           # Face enrollment & identity verification
│   │   ├── data/            # FaceRecognitionService (ML API), LivenessDetectionService
│   │   ├── providers/       # BiometricProvider
│   │   └── screens/         # BiometricEnrollmentScreen, IdentityVerificationScreen
│   ├── student/             # Student dashboard, reports, schedule
│   │   ├── data/            # StudentRepository, models
│   │   ├── providers/       # StudentProvider
│   │   ├── screens/         # Dashboard, Reports, ExcuseRequest
│   │   └── widgets/         # SubjectCard, AttendanceCircleChart, ScheduleTimelineItem
│   ├── lecturer/            # Doctor session management
│   │   ├── data/            # SessionRepository, models
│   │   ├── providers/       # SessionProvider
│   │   ├── screens/         # DoctorDashboard, DoctorMonitor, AttendanceHistory
│   │   └── widgets/         # GeoMapCard, RadiusSliderCard, SmartPulseViz, LiveFeedItem
│   └── notifications/       # Notification center
│       ├── data/            # NotificationRepository, NotificationModel
│       ├── providers/       # NotificationsProvider
│       └── screens/         # NotificationCenterScreen
├── shared/widgets/          # AppTopBar, AppBottomNav
├── router/                  # AppRouter with role-based routing
└── main.dart
```

## ML API Integration

The app integrates with a remote face recognition API:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/register-face/{employee_id}` | POST | Register a student's face |
| `/attendance/check-in/{employee_id}` | POST | Detect + liveness + recognize in one call |
| `/recognize-face` | POST | Recognize a face from image |
| `/liveness-check` | POST | Anti-spoofing liveness detection |
| `/detect-face` | POST | Detect face in image |

All endpoints accept `multipart/form-data` with a `file` field and require an `X-ML-Secret` header.

## Getting Started

### Prerequisites

- Flutter SDK 3.9+
- Android Studio or VS Code
- Android/iOS device or emulator (with camera for face features)

### Run the app

```bash
git clone https://github.com/momenmohammed312-dev/auto_attendance
cd auto_attendance
flutter pub get
flutter run
```

### Run on web (for quick testing)

```bash
flutter run -d edge
```

## Configuration

### ML Secret Key

Replace the placeholder in `lib/core/network/api_endpoints.dart`:

```dart
static const String mlSecretKey = 'YOUR_ML_SECRET_KEY';
```

### Backend API

The backend dashboard URL is configured in `lib/core/network/api_endpoints.dart`:

```dart
static const String backendBaseUrl = 'https://medoedress999-backendapi.hf.space';
```

## Project Status

| Module | Status |
|--------|--------|
| Authentication (Name + ID) | ✅ Complete |
| Face Recognition (ML API) | ✅ Complete |
| Biometric Auth (fingerprint/Face ID) | ✅ Complete |
| Student Dashboard & Charts | ✅ Complete |
| Instructor Session Management | ✅ Complete |
| GPS Geofencing (200m campus radius) | ✅ Complete |
| Excuse Requests | ✅ Complete |
| Notifications | ✅ Complete |
| Backend REST API Integration | 🔄 TODO |

## TODO

- [ ] Integrate backend REST API (dashboard endpoints unknown)
- [ ] Connect `studentId`/`employeeId` from auth provider in enrollment/verification screens
- [ ] Add real-time WebSocket updates for live attendance feed
- [ ] Add push notification support

## Author

**Moamen Mohamed** — Flutter Developer
[GitHub](https://github.com/momenmohammed312-dev)
