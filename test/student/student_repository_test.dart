import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/features/student/data/student_repository.dart';
import 'package:auto_attendace/features/student/data/models/attendance_record.dart';
import 'package:auto_attendace/features/student/data/models/subject_attendance.dart';
import 'package:auto_attendace/features/student/data/models/schedule_item.dart';

void main() {
  late StudentRepository repository;

  setUp(() {
    repository = StudentRepository();
  });

  group('StudentRepository', () {
    test('getAttendanceForSubject returns list of AttendanceRecord', () async {
      final records = await repository.getAttendanceForSubject('cs101');

      expect(records, isA<List<AttendanceRecord>>());
      expect(records.isNotEmpty, isTrue);
      expect(records.first.subjectId, 'cs101');
    });

    test('getAttendanceForSubject returns 2 records', () async {
      final records = await repository.getAttendanceForSubject('any');

      expect(records.length, 2);
    });

    test('getSubjectAttendanceSummary returns 3 subjects', () async {
      final subjects = await repository.getSubjectAttendanceSummary();

      expect(subjects, isA<List<SubjectAttendance>>());
      expect(subjects.length, 3);
    });

    test('getSubjectAttendanceSummary returns correct data', () async {
      final subjects = await repository.getSubjectAttendanceSummary();

      expect(subjects[0].subjectName, 'Physics');
      expect(subjects[0].attendancePercentage, 92.0);
      expect(subjects[1].subjectName, 'History');
      expect(subjects[2].subjectName, 'English');
    });

    test('getTodaySchedule returns schedule items', () async {
      final schedule = await repository.getTodaySchedule();

      expect(schedule, isA<List<ScheduleItem>>());
      expect(schedule.isNotEmpty, isTrue);
    });

    test('getTodaySchedule returns 3 items', () async {
      final schedule = await repository.getTodaySchedule();

      expect(schedule.length, 3);
    });

    test('getAttendanceStatistics returns stats map', () async {
      final stats = await repository.getAttendanceStatistics();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('overall_percentage'), isTrue);
      expect(stats.containsKey('total_lectures'), isTrue);
      expect(stats.containsKey('attended_lectures'), isTrue);
      expect(stats.containsKey('missed_lectures'), isTrue);
      expect(stats.containsKey('monthly_trend'), isTrue);
    });

    test('getAttendanceStatistics returns correct values', () async {
      final stats = await repository.getAttendanceStatistics();

      expect(stats['overall_percentage'], 94.2);
      expect(stats['total_lectures'], 150);
      expect(stats['attended_lectures'], 142);
      expect(stats['missed_lectures'], 8);
      expect(stats['monthly_trend'], 2.4);
    });

    test('singleton instance is same', () {
      final repo1 = StudentRepository();
      final repo2 = StudentRepository();

      expect(identical(repo1, repo2), isTrue);
    });
  });
}
