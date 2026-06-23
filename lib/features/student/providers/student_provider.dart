import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/attendance_record.dart';
import '../data/models/schedule_item.dart';
import '../data/models/subject_attendance.dart';
import '../data/student_repository.dart';

/// Immutable state class for Student feature module.
///
/// Contains all of the data needed for student dashboard, schedule,
/// and reports screens. Also tracks loading and error states.
class StudentState {
  final List<SubjectAttendance> subjectAttendance;
  final List<ScheduleItem> todaySchedule;
  final List<AttendanceRecord> recentAttendance;
  final Map<String, dynamic>? statistics;
  final bool isLoading;
  final String? error;
  final String? selectedSubjectId;

  const StudentState({
    this.subjectAttendance = const [],
    this.todaySchedule = const [],
    this.recentAttendance = const [],
    this.statistics,
    this.isLoading = false,
    this.error,
    this.selectedSubjectId,
  });

  /// Creates a copy of this state with the given fields replaced.
  ///
  /// Used to update specific fields while keeping others unchanged.
  /// Note: [error] is not defaulted to maintain null when clearing errors.
  StudentState copyWith({
    List<SubjectAttendance>? subjectAttendance,
    List<ScheduleItem>? todaySchedule,
    List<AttendanceRecord>? recentAttendance,
    Map<String, dynamic>? statistics,
    bool? isLoading,
    String? error,
  }) {
    return StudentState(
      subjectAttendance: subjectAttendance ?? this.subjectAttendance,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      recentAttendance: recentAttendance ?? this.recentAttendance,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// State notifier for managing student-related state.
///
/// Handles data fetching from [StudentRepository] and updates
/// the [StudentState] accordingly. Provides methods for:
/// - Loading dashboard data
/// - Loading reports data
/// - Refreshing subject data
/// - Clearing errors
class StudentNotifier extends StateNotifier<StudentState> {
  final StudentRepository _repository;

  StudentNotifier(this._repository) : super(const StudentState());

  /// Loads all data needed for the dashboard.
  ///
  /// Fetches subject attendance summary, today's schedule, and
  /// recent attendance records in parallel. Updates state with
  /// results or error message.
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // شغل الـ 3 requests في نفس الوقت (Parallel)
      final results = await Future.wait([
        _repository.getSubjectAttendanceSummary(),
        _repository.getTodaySchedule(),
        _repository.getAttendanceForSubject('all'), // recent
      ]);

      state = state.copyWith(
        subjectAttendance: results[0] as List<SubjectAttendance>,
        todaySchedule: results[1] as List<ScheduleItem>,
        recentAttendance: results[2] as List<AttendanceRecord>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل البيانات: $e',
      );
    }
  }

  /// Loads statistics data for the reports screen.
  ///
  /// Fetches overall attendance statistics and monthly trends.
  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _repository.getAttendanceStatistics();

      state = state.copyWith(statistics: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل التقارير: $e',
      );
    }
  }

  /// Refreshes attendance data for a specific subject.
  ///
  /// Called when user pulls to refresh on a subject detail screen.
  /// [subjectId] The ID of the subject to refresh.
  Future<void> refreshSubject(String subjectId) async {
    try {
      // TODO: Update specific subject in state
      await _repository.getAttendanceForSubject(subjectId);
    } catch (e) {
      state = state.copyWith(error: 'فشل التحديث: $e');
    }
  }

  /// Clears any existing error message from the state.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================
// Riverpod Providers - Exposed for use in UI screens
// ============================================================

/// Provider for [StudentRepository] instance.
///
/// Provides a singleton instance of the repository for data fetching.
final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository();
});

/// Main provider for student state management.
///
/// Use this to access and modify the full [StudentState].
/// For specific data, consider using selector providers below.
final studentProvider = StateNotifierProvider<StudentNotifier, StudentState>((
  ref,
) {
  final repository = ref.watch(studentRepositoryProvider);
  return StudentNotifier(repository);
});

/// Selector provider for subject attendance data only.
///
/// Use this when you only need subject data to avoid unnecessary rebuilds.
final subjectAttendanceProvider = Provider<List<SubjectAttendance>>((ref) {
  return ref.watch(studentProvider).subjectAttendance;
});

/// Selector provider for today's schedule only.
///
/// Use this when you only need schedule data to avoid unnecessary rebuilds.
final todayScheduleProvider = Provider<List<ScheduleItem>>((ref) {
  return ref.watch(studentProvider).todaySchedule;
});

/// Selector provider for loading state only.
///
/// Use this for showing/hiding loading indicators.
final studentLoadingProvider = Provider<bool>((ref) {
  return ref.watch(studentProvider).isLoading;
});

/// Selector provider for error state only.
///
/// Use this for displaying error messages.
final studentErrorProvider = Provider<String?>((ref) {
  return ref.watch(studentProvider).error;
});
