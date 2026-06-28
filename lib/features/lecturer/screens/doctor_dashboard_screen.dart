import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../router/app_router.dart';
import '../providers/lecturer_provider.dart';
import '../providers/global_session_provider.dart';
import 'attendance_history_screen.dart';
import 'course_management_screen.dart';
import 'advanced_analytics_screen.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lecturerProvider.notifier).loadMockLecturer();
    });
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return const AttendanceHistoryScreen();
      case 1:
        return const CourseManagementScreen();
      case 2:
        return const AdvancedAnalyticsScreen();
      default:
        return const AttendanceHistoryScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lecturerState = ref.watch(lecturerProvider);
    final globalSession = ref.watch(globalSessionProvider);
    final hasActiveSession = globalSession.activeSession != null;
    final lecturerName = lecturerState.lecturer?.name ?? 'Professor';

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: hasActiveSession ? _endGlobalSession : _startGlobalSession,
        backgroundColor: hasActiveSession ? Colors.red : AppColors.primary,
        icon: Icon(hasActiveSession ? Icons.stop : Icons.play_arrow, color: Colors.white),
        label: Text(
          hasActiveSession ? 'End Session' : 'Start Attendance',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              userName: lecturerName,
              onAvatarTap: () {
                Navigator.pushNamed(context, AppRoutes.doctorProfile);
              },
              onNotificationTap: () {},
              showStatusPill: true,
              statusText: hasActiveSession ? 'SESSION LIVE' : 'ONLINE',
            ),
            if (hasActiveSession)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.green.shade50,
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${globalSession.activeSession!.subjectName} — ${globalSession.attendees.length} checked in',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            Expanded(child: _buildTab(_currentIndex)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _startGlobalSession() {
    final lecturer = ref.read(lecturerProvider).lecturer;
    if (lecturer == null) return;
    ref.read(globalSessionProvider.notifier).startSession(
      lecturerId: lecturer.id,
      lecturerName: lecturer.name,
      subjectName: 'مقدمة في البرمجة',
      subjectCode: 'CS101',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session started! Students can now check in.')),
    );
  }

  void _endGlobalSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Students will no longer be able to check in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('End Session', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(globalSessionProvider.notifier).endSession();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session ended.')),
        );
      }
    }
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.book_outlined, 'Courses'),
              _buildNavItem(2, Icons.analytics_outlined, 'Analytics'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
