// ============================================================
// STUDENT DASHBOARD SCREEN - Complete Implementation
// ============================================================

// Flutter core imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/schedule_item.dart';
import '../data/models/subject_attendance.dart';
import '../providers/student_provider.dart';
import '../widgets/attendance_circle_chart.dart';
import '../widgets/schedule_timeline_item.dart';
import '../widgets/subject_card.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../router/app_router.dart';
import '../../../features/lecturer/providers/global_session_provider.dart';

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
    final authUser = ref.watch(authProvider).user;

    // Calculate overall attendance from subjects
    final totalLectures = subjects.fold<int>(0, (sum, s) => sum + s.totalLectures);
    final attendedLectures = subjects.fold<int>(0, (sum, s) => sum + s.attendedLectures);
    final attendancePercentage = totalLectures > 0 ? (attendedLectures / totalLectures * 100) : 0.0;

    return Scaffold(
      // Light grey background for modern look
      backgroundColor: Colors.grey[100],

      // Main scrollable content area
      body: SafeArea(
        child: _buildBody(
          context,
          subjects,
          schedule,
          isLoading,
          error,
          userName: authUser?.name ?? 'Student',
          attendancePercentage: attendancePercentage,
          attendedLectures: attendedLectures,
          totalLectures: totalLectures,
        ),
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
    String? error, {
    String? userName,
    double attendancePercentage = 0,
    int attendedLectures = 0,
    int totalLectures = 0,
  }) {
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

    // Watch global session state
    final globalSession = ref.watch(globalSessionProvider);
    final hasActiveSession = globalSession.activeSession != null;

    // Main dashboard content with pull-to-refresh
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HEADER SECTION ====================
            AppTopBar(
              userName: userName ?? 'Student',
              onNotificationTap: _onNotificationTap,
              showStatusPill: true,
            ),

            const SizedBox(height: 20),

            // ==================== ACTIVE SESSION BANNER ====================
            if (hasActiveSession)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E5BFF), Color(0xFF1E3FAF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E5BFF).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'LIVE SESSION',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        globalSession.activeSession!.subjectName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        globalSession.activeSession!.subjectCode,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            'د. أحمد محمد',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Tap to Attend',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: hasActiveSession ? 16 : 30),

            // ==================== ATTENDANCE SECTION ====================
            // Circular chart showing overall attendance percentage
            Center(
              child: AttendanceCircleChart(
                percentage: attendancePercentage,
                attendedLectures: attendedLectures,
                totalLectures: totalLectures,
              ),
            ),

            const SizedBox(height: 30),

            // ==================== EXCUSE REQUEST SECTION ====================
            // Section for requesting excuses for absences
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha:0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Colors.orange[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Need an Excuse?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Missed a lecture? Submit an excuse request with proper documentation.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onRequestExcuseTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E5BFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Request Excuse',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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

  /// Handles Request Excuse button tap.
  ///
  /// Navigates to the excuse request screen.
  void _onRequestExcuseTap() {
    Navigator.pushNamed(context, AppRoutes.excuseRequest);
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
    final authUser = ref.read(authProvider).user;
    final globalSession = ref.read(globalSessionProvider);
    if (authUser == null) return;

    // Pick subject: active session or choose from list
    String subjectName;
    if (globalSession.activeSession != null) {
      subjectName = globalSession.activeSession!.subjectName;
    } else {
      final schedule = ref.read(todayScheduleProvider);
      final subjects = schedule.map((s) => s.subjectName).toList();
      if (subjects.isEmpty) {
        subjectName = 'General';
      } else if (subjects.length == 1) {
        subjectName = subjects.first;
      } else {
        subjectName = await showDialog<String>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: const Text('Select Subject'),
            children: subjects.map((s) => SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, s),
              child: Text(s),
            )).toList(),
          ),
        ) ?? subjects.first;
      }
    }

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.identityVerification,
      arguments: {
        'method': 'face',
        'studentId': authUser.id,
        'subjectName': subjectName,
      },
    );

    if (result != null && result is Map) {
      if (globalSession.activeSession != null) {
        ref.read(globalSessionProvider.notifier).addAttendee(
          studentId: authUser.id,
          studentName: authUser.name,
        );
      }
      debugPrint('Attendance recorded: $result');
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
