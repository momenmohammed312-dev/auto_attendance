// ============================================================
// STUDENT DASHBOARD SCREEN - Complete Implementation
// ============================================================

// Flutter core imports
import 'package:flutter/material.dart';

// Riverpod for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data models
import '../data/models/schedule_item.dart';
import '../data/models/subject_attendance.dart';

// Riverpod providers for state management
import '../providers/student_provider.dart';

// Student-specific widgets
import '../widgets/attendance_circle_chart.dart';
import '../widgets/schedule_timeline_item.dart';
import '../widgets/subject_card.dart';

// Shared/reusable widgets
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_top_bar.dart';

// App router for navigation
import '../../../router/app_router.dart';

/// Student Dashboard Screen - Main landing page for students.
///
/// Displays:
/// - User greeting and notification button
/// - Sync status indicator
/// - Overall attendance percentage (circular chart)
/// - Subject breakdown (vertical bar cards)
/// - Today's lecture schedule (timeline)
/// - Quick attendance FAB
/// - Bottom navigation
///
/// Features:
/// - Pull-to-refresh for data reloading
/// - Real-time schedule status (NOW indicator)
/// - Loading and error states
/// - Navigation to other screens
class StudentDashboardScreen extends ConsumerStatefulWidget {
  /// Creates the student dashboard screen.
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

/// State class for the dashboard screen.
///
/// Manages:
/// - Current bottom nav index (0 = Home, 1 = Reports, 2 = Profile)
/// - Data loading lifecycle
class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  /// Currently selected bottom navigation index.
  /// 0 = Home, 1 = Reports, 2 = Profile
  int _currentIndex = 0;

  /// Loads dashboard data when screen initializes.
  ///
  /// Uses [Future.microtask] to avoid calling setState during build.
  @override
  void initState() {
    super.initState();
    // Schedule data loading after first frame
    Future.microtask(() {
      ref.read(studentProvider.notifier).loadDashboard();
    });
  }

  /// Builds the complete dashboard UI.
  ///
  /// Watches providers for:
  /// - Subject attendance data
  /// - Today's schedule
  /// - Loading state
  /// - Error state
  @override
  Widget build(BuildContext context) {
    // Watch data from Riverpod providers
    final subjects = ref.watch(subjectAttendanceProvider);
    final schedule = ref.watch(todayScheduleProvider);
    final isLoading = ref.watch(studentLoadingProvider);
    final error = ref.watch(studentErrorProvider);

    return Scaffold(
      // Light grey background for modern look
      backgroundColor: Colors.grey[100],

      // Main scrollable content area
      body: SafeArea(
        child: _buildBody(context, subjects, schedule, isLoading, error),
      ),

      // Floating Action Button for quick biometric attendance
      floatingActionButton: _buildFloatingActionButton(),

      // Bottom navigation bar (Home / Reports / Profile)
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  /// Builds the main body content based on loading/error states.
  ///
  /// Shows:
  /// - Loading indicator when [isLoading] is true
  /// - Error message when [error] is not null
  /// - Full dashboard when data is ready
  Widget _buildBody(
    BuildContext context,
    List<SubjectAttendance> subjects,
    List<ScheduleItem> schedule,
    bool isLoading,
    String? error,
  ) {
    // Show loading spinner while fetching initial data
    if (isLoading && subjects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message if something went wrong
    if (error != null && subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(studentProvider.notifier).loadDashboard();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Main dashboard content with pull-to-refresh
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HEADER SECTION ====================
            // Top bar with avatar, greeting, SYNCED pill, and notification
            AppTopBar(
              userName: 'Alex Rivers',
              onNotificationTap: _onNotificationTap,
              showStatusPill: true,
            ),

            const SizedBox(height: 30),

            // ==================== ATTENDANCE SECTION ====================
            // Circular chart showing overall attendance percentage
            Center(
              child: AttendanceCircleChart(
                percentage: 88.0,
                attendedLectures: 44,
                totalLectures: 50,
              ),
            ),

            const SizedBox(height: 40),

            // ==================== SUBJECT BREAKDOWN SECTION ====================
            // Section title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Subject Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Horizontal scrollable subject cards
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SubjectCard(
                      subjectName: subject.subjectName,
                      percentage: subject.attendancePercentage,
                      colorHex: subject.colorHex,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // ==================== TODAY'S SCHEDULE SECTION ====================
            // Section title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Today\'s Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Timeline of scheduled lectures
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  for (int i = 0; i < schedule.length; i++)
                    ScheduleTimelineItem(
                      subjectName: schedule[i].subjectName,
                      timeRange: schedule[i].timeRange,
                      room: schedule[i].room,
                      isNow: schedule[i].isNow,
                      isFirst: i == 0,
                      isLast: i == schedule.length - 1,
                    ),
                ],
              ),
            ),

            // Bottom padding for FAB clearance
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// Builds the Floating Action Button for quick attendance.
  ///
  /// Opens biometric verification when tapped.
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _onAttendButtonTap,
      backgroundColor: const Color(0xFF2E5BFF),
      child: const Icon(Icons.fingerprint, color: Colors.white, size: 32),
    );
  }

  /// Handles pull-to-refresh gesture.
  ///
  /// Reloads dashboard data from the repository.
  Future<void> _onRefresh() async {
    await ref.read(studentProvider.notifier).loadDashboard();
  }

  /// Handles notification button tap.
  ///
  /// Navigates to the notifications screen.
  void _onNotificationTap() {
    // TODO: Navigate to notifications screen
    debugPrint('Notification tapped');
  }

  /// Handles attendance FAB tap.
  ///
  /// Opens biometric attendance verification flow.
  ///
  /// Flow:
  /// 1. Navigate to IdentityVerificationScreen
  /// 2. Wait for verification result
  /// 3. On success: Refresh dashboard with new attendance
  /// 4. On cancel/error: Stay on dashboard
  ///
  /// Uses the default fingerprint method. In future, this can
  /// check user's preferred method from settings and navigate
  /// to VerificationMethodsScreen instead.
  void _onAttendButtonTap() async {
    // Navigate to biometric verification screen
    // Pass default method (fingerprint) as argument
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.identityVerification,
      arguments: {'method': 'face'},
    );

    // Handle verification result
    if (result != null && result is Map) {
      // Verification successful - refresh dashboard data
      // TODO: Refresh attendance stats and recent attendance list
      debugPrint('Attendance recorded: $result');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance marked successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // User cancelled or verification failed
      debugPrint('Attendance cancelled or failed');
    }
  }

  /// Handles bottom navigation item selection.
  ///
  /// Updates the current index and navigates to selected screen.
  /// Navigation destinations:
  /// - Index 0: Home (current screen) - no action needed
  /// - Index 1: Reports screen - shows detailed attendance reports
  /// - Index 2: Profile screen - shows student info and settings
  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to different screens based on selected tab index
    switch (index) {
      case 0:
        // Already on Home dashboard, no navigation needed
        break;
      case 1:
        // Navigate to Reports screen
        // Shows detailed attendance statistics and recent records
        Navigator.pushNamed(context, AppRoutes.studentReports);
        break;
      case 2:
        // Navigate to Profile screen
        // Shows student profile, settings, and logout option
        Navigator.pushNamed(context, AppRoutes.studentProfile);
        break;
    }
  }
}
