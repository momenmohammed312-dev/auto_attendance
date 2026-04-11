lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart          ← #0040E0, #006971, #22C55E...
│   │   ├── app_text_styles.dart     ← Inter font family
│   │   └── app_theme.dart
│   │
│   ├── router/
│   │   └── app_router.dart          ← GoRouter + guards per role
│   │
│   ├── network/
│   │   ├── api_client.dart          ← Dio + JWT interceptor
│   │   ├── api_endpoints.dart       ← const base URLs
│   │   └── auth_interceptor.dart    ← refresh token logic
│   │
│   ├── storage/
│   │   ├── secure_storage.dart      ← flutter_secure_storage (JWT)
│   │   └── biometric_storage.dart   ← face template (iOS Keychain / Android Keystore)
│   │
│   └── utils/
│       ├── haversine.dart           ← client-side distance check (UI only)
│       └── constants.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── models/
│   │   │       ├── login_request.dart
│   │   │       └── user_model.dart     ← role: student | lecturer | admin
│   │   ├── providers/
│   │   │   └── auth_provider.dart      ← Riverpod AsyncNotifier
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       └── login_screen.dart       ← Segmented: Student / Doctor
│   │
│   ├── biometric/
│   │   ├── data/
│   │   │   ├── face_recognition_service.dart  ← TFLite MobileFaceNet
│   │   │   └── liveness_detection_service.dart
│   │   ├── providers/
│   │   │   └── biometric_provider.dart
│   │   └── screens/
│   │       ├── identity_verification_screen.dart   ← Face scan (Figma: 4:347)
│   │       ├── biometric_enrollment_screen.dart    ← Step 3 of 5
│   │       └── verification_methods_screen.dart    ← + Fingerprint + Geofence error
│   │
│   ├── student/
│   │   ├── data/
│   │   │   ├── student_repository.dart
│   │   │   └── models/
│   │   │       ├── attendance_record.dart
│   │   │       └── subject_attendance.dart
│   │   ├── providers/
│   │   │   └── student_provider.dart
│   │   ├── screens/
│   │   │   ├── student_dashboard_screen.dart   ← Figma: 4:2
│   │   │   ├── student_reports_screen.dart     ← Figma: 4:522
│   │   │   └── student_profile_screen.dart     ← Figma: 4:735
│   │   └── widgets/
│   │       ├── attendance_circle_chart.dart    ← 88% donut chart
│   │       ├── subject_card.dart               ← vertical bar + %
│   │       └── schedule_timeline_item.dart     ← NOW badge + time/room
│   │
│   ├── lecturer/
│   │   ├── data/
│   │   │   ├── session_repository.dart
│   │   │   └── models/
│   │   │       ├── session_model.dart          ← course_id, lat, lng, radius
│   │   │       └── live_attendance_item.dart
│   │   ├── providers/
│   │   │   └── session_provider.dart
│   │   ├── screens/
│   │   │   └── doctor_monitor_screen.dart      ← Figma: 4:382
│   │   └── widgets/
│   │       ├── geo_map_card.dart               ← geofence circle on map
│   │       ├── radius_slider_card.dart
│   │       ├── smart_pulse_viz.dart            ← pulse rings animation
│   │       └── live_feed_item.dart             ← student + time + status
│   │
│   └── notifications/
│       ├── data/
│       │   └── notification_repository.dart
│       ├── providers/
│       │   └── notifications_provider.dart
│       └── screens/
│           └── notification_center_screen.dart ← Figma: 4:826
│
└── shared/
    ├── widgets/
    │   ├── app_bottom_nav.dart         ← Home / Reports / Profile
    │   ├── app_top_bar.dart            ← avatar + name + bell
    │   ├── primary_button.dart
    │   └── status_pill.dart            ← NOW / SYNCED badges
    │
    └── models/
        └── api_response.dart           ← generic wrapper