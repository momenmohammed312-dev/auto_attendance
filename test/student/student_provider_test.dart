import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:auto_attendace/features/student/providers/student_provider.dart';
import 'package:auto_attendace/features/student/data/student_repository.dart';
import 'package:auto_attendace/features/student/data/models/attendance_record.dart';
import 'package:auto_attendace/features/student/data/models/subject_attendance.dart';
import 'package:auto_attendace/features/student/data/models/schedule_item.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

void main() {
  group('StudentState', () {
    test('default values are correct', () {
      const state = StudentState();

      expect(state.subjectAttendance, isEmpty);
      expect(state.todaySchedule, isEmpty);
      expect(state.recentAttendance, isEmpty);
      expect(state.statistics, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.selectedSubjectId, isNull);
    });

    test('copyWith replaces specified fields', () {
      const state = StudentState();

      final updated = state.copyWith(
        isLoading: true,
        error: 'Some error',
      );

      expect(updated.isLoading, isTrue);
      expect(updated.error, 'Some error');
    });

    test('copyWith preserves unmodified fields', () {
      final subjects = [
        SubjectAttendance(
          subjectId: '1',
          subjectName: 'CS',
          totalLectures: 20,
          attendedLectures: 18,
          missedLectures: 2,
          attendancePercentage: 90.0,
          colorHex: '#000',
        ),
      ];

      final state = StudentState(subjectAttendance: subjects);
      final updated = state.copyWith(isLoading: true);

      expect(updated.subjectAttendance, subjects); // preserved
      expect(updated.isLoading, isTrue);
    });

    test('copyWith error can be cleared', () {
      const state = StudentState(error: 'Error message');
      final updated = state.copyWith(error: null);

      expect(updated.error, isNull);
    });
  });

  group('StudentNotifier', () {
    late MockStudentRepository mockRepository;
    late StudentNotifier notifier;

    setUp(() {
      mockRepository = MockStudentRepository();
      notifier = StudentNotifier(mockRepository);
    });

    test('initial state is correct', () {
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.subjectAttendance, isEmpty);
      expect(notifier.state.todaySchedule, isEmpty);
      expect(notifier.state.recentAttendance, isEmpty);
    });

    test('loadDashboard loads all data in parallel', () async {
      final subjects = [
        SubjectAttendance(
          subjectId: '1',
          subjectName: 'CS',
          totalLectures: 20,
          attendedLectures: 18,
          missedLectures: 2,
          attendancePercentage: 90.0,
          colorHex: '#000',
        ),
      ];

      final schedule = [
        ScheduleItem(
          id: '1',
          subjectName: 'CS 101',
          subjectCode: 'CS101',
          startTime: DateTime(2024, 10, 24, 9, 0),
          endTime: DateTime(2024, 10, 24, 10, 0),
          room: 'Lab 1',
          status: 'ongoing',
        ),
      ];

      final records = [
        AttendanceRecord(
          id: '1',
          subjectId: '1',
          subjectName: 'CS',
          date: '2024-10-24',
          status: 'present',
          checkedInTime: '09:05',
        ),
      ];

      when(() => mockRepository.getSubjectAttendanceSummary())
          .thenAnswer((_) async => subjects);
      when(() => mockRepository.getTodaySchedule())
          .thenAnswer((_) async => schedule);
      when(() => mockRepository.getAttendanceForSubject('all'))
          .thenAnswer((_) async => records);

      await notifier.loadDashboard();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.subjectAttendance, subjects);
      expect(notifier.state.todaySchedule, schedule);
      expect(notifier.state.recentAttendance, records);
      expect(notifier.state.error, isNull);
    });

    test('loadDashboard sets error on failure', () async {
      when(() => mockRepository.getSubjectAttendanceSummary())
          .thenThrow(Exception('Network error'));

      await notifier.loadDashboard();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, contains('فشل في تحميل البيانات'));
    });

    test('loadReports loads statistics', () async {
      final stats = {
        'overall_percentage': 94.2,
        'total_lectures': 150,
      };

      when(() => mockRepository.getAttendanceStatistics())
          .thenAnswer((_) async => stats);

      await notifier.loadReports();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.statistics, stats);
    });

    test('loadReports sets error on failure', () async {
      when(() => mockRepository.getAttendanceStatistics())
          .thenThrow(Exception('API error'));

      await notifier.loadReports();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, contains('فشل في تحميل التقارير'));
    });

    test('clearError removes error message', () async {
      when(() => mockRepository.getAttendanceStatistics())
          .thenThrow(Exception('Error'));

      await notifier.loadReports();
      expect(notifier.state.error, isNotNull);

      notifier.clearError();
      expect(notifier.state.error, isNull);
    });

    test('refreshSubject calls repository', () async {
      when(() => mockRepository.getAttendanceForSubject('cs101'))
          .thenAnswer((_) async => []);

      await notifier.refreshSubject('cs101');

      verify(() => mockRepository.getAttendanceForSubject('cs101')).called(1);
    });

    test('refreshSubject sets error on failure', () async {
      when(() => mockRepository.getAttendanceForSubject('cs101'))
          .thenThrow(Exception('Refresh error'));

      await notifier.refreshSubject('cs101');

      expect(notifier.state.error, contains('فشل التحديث'));
    });
  });
}
