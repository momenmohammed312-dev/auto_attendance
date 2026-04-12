# Auto Attendance - Feature Documentation

## Project Overview
A Flutter-based smart attendance system for universities with role-based access for Students and Doctors/Instructors.

---

## 🎓 Student Feature Module

### Purpose
Allows students to:
- View their attendance records
- Track attendance percentage per subject
- View daily schedule/timeline
- Access attendance reports

### File Structure

```
lib/features/student/
├── data/
│   ├── models/
│   │   ├── attendance_record.dart      # Model for individual attendance records
│   │   └── subject_attendance.dart     # Model for subject-wise attendance summary
│   └── student_repository.dart          # Repository for student data API calls
├── providers/
│   └── student_provider.dart            # Riverpod state management for student features
├── screens/
│   ├── student_dashboard_screen.dart    # Main dashboard for students
│   ├── student_profile_screen.dart     # Student profile and settings
│   └── student_reports_screen.dart     # Detailed attendance reports
└── widgets/
    ├── attendance_circle_chart.dart     # Circular chart showing attendance %
    ├── schedule_timeline_item.dart     # Timeline widget for daily schedule
    └── subject_card.dart                # Card widget for subject attendance
```

### Implementation Status
| File | Status | Description |
|------|--------|-------------|
| attendance_record.dart | Empty | Needs model implementation |
| subject_attendance.dart | Empty | Needs model implementation |
| student_repository.dart | Empty | Needs API integration |
| student_provider.dart | Empty | Needs Riverpod setup |
| student_dashboard_screen.dart | Empty | Needs UI implementation |
| student_profile_screen.dart | Empty | Needs UI implementation |
| student_reports_screen.dart | Empty | Needs UI implementation |
| attendance_circle_chart.dart | Empty | Needs chart widget |
| schedule_timeline_item.dart | Empty | Needs timeline widget |
| subject_card.dart | Empty | Needs card widget |

---

## 👨‍🏫 Doctor/Instructor Feature Module

### Purpose
Allows doctors/instructors to:
- Monitor live attendance sessions
- Set geofencing radius for attendance
- View real-time student check-ins
- Create and manage attendance sessions
- Visualize attendance data with maps and charts

### File Structure

```
lib/features/lecturer/
├── data/
│   ├── models/
│   │   ├── live_attendance_item.dart   # Model for live attendance entries
│   │   └── session_model.dart            # Model for attendance sessions
│   └── session_repository.dart           # Repository for session API calls
├── providers/
│   └── session_provider.dart             # Riverpod state management for sessions
├── screens/
│   └── doctor_monitor_screen.dart        # Main monitoring dashboard for doctors
└── widgets/
    ├── geo_map_card.dart                  # Map widget showing attendance location
    ├── live_feed_item.dart                # Real-time student check-in feed item
    ├── radius_slider_card.dart            # Slider for setting geofence radius
    └── smart_pulse_viz.dart               # Pulse visualization for live activity
```

### Implementation Status
| File | Status | Description |
|------|--------|-------------|
| live_attendance_item.dart | Empty | Needs model implementation |
| session_model.dart | Empty | Needs model implementation |
| session_repository.dart | Empty | Needs API integration |
| session_provider.dart | Empty | Needs Riverpod setup |
| doctor_monitor_screen.dart | Empty | Needs UI implementation |
| geo_map_card.dart | Empty | Needs map integration |
| live_feed_item.dart | Empty | Needs feed widget |
| radius_slider_card.dart | Empty | Needs slider widget |
| smart_pulse_viz.dart | Empty | Needs animation widget |

---

## 🔧 Common Dependencies

### Student Features Use:
- `percent_indicator: 4.0.0` - For donut charts (attendance %)
- `fl_chart: 0.68.0` - For bar charts (reports)
- `intl: 0.19.0` - For date formatting

### Doctor Features Use:
- `google_maps_flutter: 2.13.1` - For geolocation map
- `geolocator: 11.1.0` - For GPS location tracking

### Both Use:
- `flutter_riverpod: 2.5.1` - State management
- `dio: 5.4.3` - HTTP client for API calls
- `flutter_secure_storage: 9.2.2` - JWT token storage

---

## 🗺️ Feature Architecture

### Student Flow
```
Login → StudentDashboard → SubjectCard → AttendanceDetails
                    ↓
            StudentReports (Charts)
                    ↓
            StudentProfile
```

### Doctor Flow
```
Login → DoctorMonitorScreen → GeoMapCard (Set Location)
                    ↓
            RadiusSliderCard (Set Radius)
                    ↓
            LiveFeedItem (Real-time check-ins)
                    ↓
            SmartPulseViz (Activity indicator)
```

---

## 📝 Next Steps for Implementation

### Phase 1: Models (Both)
1. Implement all model classes with fromJson/toJson
2. Add data validation

### Phase 2: Repository (Both)
1. Implement API endpoints in repositories
2. Add error handling
3. Add token management

### Phase 3: Providers (Both)
1. Setup Riverpod providers
2. Implement state management logic
3. Connect repositories to UI

### Phase 4: UI (Both)
1. Implement screen layouts
2. Create reusable widgets
3. Add responsive design

### Phase 5: Integration
1. Connect Login to Dashboards
2. Add navigation between screens
3. Test role-based routing

---

## 🔐 Authentication Flow

Current Auth Structure:
```
lib/auth/
├── data/
│   ├── auth_repository.dart     ✅ Implemented
│   └── models/
│       ├── login_request.dart     ✅ Implemented
│       └── user_model.dart        ✅ Implemented
├── providers/
│   └── auth_provider.dart         ✅ Implemented
└── screens/
    ├── login_screen.dart          ✅ Implemented
    └── splash_screen.dart         ✅ Implemented
```

---

## 📊 Project Structure Summary

```
lib/
├── auth/                    ✅ Complete (Models + UI + Logic)
├── core/                    ⚠️ Network files empty
├── features/
│   ├── auth/               ⚠️ Empty (duplicate?)
│   ├── biometric/          ⚠️ Has files (not documented)
│   ├── lecturer/           ⚠️ All empty
│   ├── notifications/      ⚠️ Has files (not documented)
│   └── student/            ⚠️ All empty
├── router/                 ⚠️ app_router.dart exists
└── main.dart               ✅ ProviderScope added
```

---

## 🚀 Development Status

| Module | Status | Progress |
|--------|--------|----------|
| Authentication | ✅ Done | 100% |
| Student Features | ⚠️ Not Started | 0% |
| Doctor Features | ⚠️ Not Started | 0% |
| Biometric | ⚠️ Exists | ?% |
| Notifications | ⚠️ Exists | ?% |

---

*Last Updated: April 12, 2025*
*Project: Auto Attendance System*
