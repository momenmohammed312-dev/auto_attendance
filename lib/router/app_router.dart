// ============================================================
// APP ROUTER - Application Navigation Management
// ============================================================
// This file defines all app routes and handles navigation between screens.
// Add new routes here when creating new screens.
// ============================================================

import 'package:flutter/material.dart';

// Auth screens
import '../auth/screens/splash_screen.dart';
import '../auth/screens/login_screen.dart';

// Student screens
import '../features/student/screens/student_dashboard_screen.dart';

/// Student Profile screen - Shows student info, settings, and logout option
/// Contains: Avatar, name, email, settings list, and logout button
import '../features/student/screens/student_profile_screen.dart';

/// Student Reports screen - Shows detailed attendance statistics and records
/// Contains: Statistics cards, monthly trend chart, and recent records list
import '../features/student/screens/student_reports_screen.dart';

// Biometric screens
import '../features/biometric/screens/biometric_enrollment_screen.dart';
import '../features/biometric/screens/verification_methods_screen.dart';
import '../features/biometric/screens/identity_verification_screen.dart';

/// Route names for navigation
///
/// Use these constants to navigate between screens instead of hardcoding
/// route strings. This prevents typos and makes refactoring easier.
///
/// Example:
/// ```dart
/// Navigator.pushNamed(context, AppRoutes.identityVerification);
/// ```
class AppRoutes {
  // ============================================================
  // AUTH ROUTES
  // ============================================================
  /// Splash screen - App entry point, shows logo and checks auth status
  static const String splash = '/';

  /// Login screen - User authentication with email/password
  static const String login = '/login';

  // ============================================================
  // STUDENT ROUTES
  // ============================================================
  /// Student Dashboard - Main screen showing attendance, schedule, subjects
  static const String studentDashboard = '/student/dashboard';

  /// Student Profile - Shows student information and app settings
  /// Route: /student/profile
  static const String studentProfile = '/student/profile';

  /// Student Reports - Detailed attendance reports and statistics
  /// Route: /student/reports
  static const String studentReports = '/student/reports';

  // ============================================================
  // DOCTOR ROUTES (TODO: Implement doctor screens)
  // ============================================================
  /// Doctor Dashboard - Main screen for instructors (placeholder for now)
  /// TODO: Create actual doctor dashboard screen
  static const String doctorDashboard = '/doctor/dashboard';

  // ============================================================
  // BIOMETRIC ROUTES
  // ============================================================
  /// Biometric Enrollment - First-time setup for fingerprint/face ID
  /// One-time setup screen for new users
  static const String biometricEnrollment = '/biometric/enroll';

  /// Verification Methods - Choose between fingerprint, face, or PIN
  /// Allows users to select their preferred auth method
  static const String verificationMethods = '/biometric/methods';

  /// Identity Verification - Main attendance verification screen
  /// Used every time student marks attendance
  static const String identityVerification = '/biometric/verify';
}

/// Application router that handles all screen navigation
///
/// This class uses MaterialPageRoute for all transitions.
/// Each route returns the appropriate screen widget.
///
/// To add a new route:
/// 1. Add route name to AppRoutes class
/// 2. Add import statement at top of file
/// 3. Add case to onGenerateRoute switch statement
///
/// The settings parameter contains route arguments passed via
/// Navigator.pushNamed(context, routeName, arguments: {...})
class AppRouter {
  /// Generates routes based on route name
  ///
  /// [settings] contains the route name and arguments
  /// Returns a MaterialPageRoute with the appropriate screen
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ============================================================
      // AUTH ROUTES
      // ============================================================

      /// Splash screen route - App entry point
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      /// Login screen route - User authentication
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      // ============================================================
      // STUDENT ROUTES
      // ============================================================

      /// Student Dashboard route - Main student interface
      case AppRoutes.studentDashboard:
        return MaterialPageRoute(
          builder: (_) => const StudentDashboardScreen(),
        );

      /// Student Profile route - Shows profile and settings
      /// Arguments: None (uses current user from auth provider)
      case AppRoutes.studentProfile:
        return MaterialPageRoute(builder: (_) => const StudentProfileScreen());

      /// Student Reports route - Shows attendance statistics and records
      /// Arguments: None (uses student provider for data)
      case AppRoutes.studentReports:
        return MaterialPageRoute(builder: (_) => const StudentReportsScreen());

      /// Doctor Dashboard route - Placeholder, redirects to student dashboard
      /// TODO: Replace with actual DoctorDashboardScreen when implemented
      case AppRoutes.doctorDashboard:
        return MaterialPageRoute(
          builder: (_) => const StudentDashboardScreen(), // Placeholder
        );

      // ============================================================
      // BIOMETRIC ROUTES
      // ============================================================

      /// Biometric Enrollment route - First-time setup screen
      /// Arguments: None
      case AppRoutes.biometricEnrollment:
        return MaterialPageRoute(
          builder: (_) => const BiometricEnrollmentScreen(),
        );

      /// Verification Methods route - Choose auth method
      /// Arguments: None
      case AppRoutes.verificationMethods:
        return MaterialPageRoute(
          builder: (_) => const VerificationMethodsScreen(),
        );

      /// Identity Verification route - Main attendance verification
      /// Arguments: { 'method': 'fingerprint' | 'face' | 'pin' }
      case AppRoutes.identityVerification:
        return MaterialPageRoute(
          builder: (_) => const IdentityVerificationScreen(),
          settings: settings, // Pass arguments to screen
        );

      // ============================================================
      // DEFAULT - UNKNOWN ROUTE
      // ============================================================

      /// Fallback for undefined routes
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}

/// Global navigator key for navigation without context
///
/// Use this key to navigate from anywhere in the app, even without
/// access to BuildContext. Useful for navigation from background
/// services or deep linking.
///
/// Example:
/// ```dart
/// navigatorKey.currentState?.pushNamed(AppRoutes.login);
/// ```
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// End of file
