import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/features/student/data/models/subject_attendance.dart';

void main() {
  group('SubjectAttendance', () {
    test('constructor stores all fields', () {
      final subject = SubjectAttendance(
        subjectId: 'cs101',
        subjectName: 'CS',
        totalLectures: 25,
        attendedLectures: 23,
        missedLectures: 2,
        attendancePercentage: 92.0,
        colorHex: '#2E5BFF',
      );

      expect(subject.subjectId, 'cs101');
      expect(subject.totalLectures, 25);
      expect(subject.attendancePercentage, 92.0);
    });

    test('fromJson creates correct SubjectAttendance', () {
      final json = {
        'subjectId': 'hist201',
        'subjectName': 'History',
        'totalLectures': 18,
        'attendedLectures': 14,
        'missedLectures': 4,
        'attendancePercentage': 78.0,
        'colorHex': '#F59E0B',
      };

      final subject = SubjectAttendance.fromJson(json);

      expect(subject.subjectId, 'hist201');
      expect(subject.attendancePercentage, 78.0);
    });

    test('toJson returns correct map', () {
      final subject = SubjectAttendance(
        subjectId: 'eng102',
        subjectName: 'English',
        totalLectures: 20,
        attendedLectures: 17,
        missedLectures: 3,
        attendancePercentage: 85.0,
        colorHex: '#22C55E',
      );

      final json = subject.toJson();

      expect(json['subjectId'], 'eng102');
      expect(json['attendancePercentage'], 85.0);
      expect(json['colorHex'], '#22C55E');
    });

    test('copyWith replaces specified fields', () {
      final original = SubjectAttendance(
        subjectId: 'cs101',
        subjectName: 'CS',
        totalLectures: 25,
        attendedLectures: 23,
        missedLectures: 2,
        attendancePercentage: 92.0,
        colorHex: '#2E5BFF',
      );

      final modified = original.copyWith(attendancePercentage: 95.0);

      expect(modified.attendancePercentage, 95.0);
      expect(modified.subjectId, 'cs101'); // unchanged
    });

    group('statusLabel', () {
      test('returns Excellent when percentage >= 85', () {
        final subject = SubjectAttendance(
          subjectId: '1',
          subjectName: 'Test',
          totalLectures: 20,
          attendedLectures: 20,
          missedLectures: 0,
          attendancePercentage: 100.0,
          colorHex: '#000',
        );
        expect(subject.statusLabel, 'Excellent');
      });

      test('returns Excellent when percentage is exactly 85', () {
        final subject = SubjectAttendance(
          subjectId: '2',
          subjectName: 'Test',
          totalLectures: 20,
          attendedLectures: 17,
          missedLectures: 3,
          attendancePercentage: 85.0,
          colorHex: '#000',
        );
        expect(subject.statusLabel, 'Excellent');
      });

      test('returns Good when percentage >= 75 but < 85', () {
        final subject = SubjectAttendance(
          subjectId: '3',
          subjectName: 'Test',
          totalLectures: 20,
          attendedLectures: 16,
          missedLectures: 4,
          attendancePercentage: 80.0,
          colorHex: '#000',
        );
        expect(subject.statusLabel, 'Good');
      });

      test('returns Good when percentage is exactly 75', () {
        final subject = SubjectAttendance(
          subjectId: '4',
          subjectName: 'Test',
          totalLectures: 20,
          attendedLectures: 15,
          missedLectures: 5,
          attendancePercentage: 75.0,
          colorHex: '#000',
        );
        expect(subject.statusLabel, 'Good');
      });

      test('returns Warning when percentage >= 60 but < 75', () {
        final subject = SubjectAttendance(
          subjectId: '5',
          subjectName: 'Test',
          totalLectures: 20,
          attendedLectures: 13,
          missedLectures: 7,
          attendancePercentage: 65.0,
          colorHex: '#000',
        );
        expect(subject.statusLabel, 'Warning');
      });

      test('returns Warning when percentage is exactly 60', () {
        final subject = SubjectAttendance(
          subjectId: '6',
          subjectName: 'Test',
          totalLectures: 20,
          attendedLectures: 12,
          missedLectures: 8,
          attendancePercentage: 60.0,
          colorHex: '#000',
        );
        expect(subject.statusLabel, 'Warning');
      });

      test('returns At Risk when percentage < 60', () {
        final subject = SubjectAttendance(
          subjectId: '7',
          subjectName: 'Test',
          totalLectures: 20,
          attendedLectures: 10,
          missedLectures: 10,
          attendancePercentage: 50.0,
          colorHex: '#000',
        );
        expect(subject.statusLabel, 'At Risk');
      });
    });
  });
}
