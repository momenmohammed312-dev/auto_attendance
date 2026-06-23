import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/features/student/data/models/attendance_record.dart';

void main() {
  group('AttendanceRecord', () {
    test('constructor stores all fields including optional', () {
      final record = AttendanceRecord(
        id: '1',
        subjectId: 'cs101',
        subjectName: 'Computer Science',
        date: '2024-10-24',
        status: 'present',
        checkedInTime: '09:05',
        room: 'Lab 4B',
        verificationMethod: 'biometric',
      );

      expect(record.id, '1');
      expect(record.subjectId, 'cs101');
      expect(record.room, 'Lab 4B');
      expect(record.verificationMethod, 'biometric');
    });

    test('constructor with null optional fields', () {
      final record = AttendanceRecord(
        id: '2',
        subjectId: 'math101',
        subjectName: 'Math',
        date: '2024-10-25',
        status: 'absent',
        checkedInTime: '',
      );

      expect(record.room, isNull);
      expect(record.verificationMethod, isNull);
    });

    test('fromJson creates correct AttendanceRecord', () {
      final json = {
        'id': '3',
        'subjectId:': 'phys101',
        'subjectName': 'Physics',
        'date': '2024-10-26',
        'status': 'late',
        'checkedInTime': '09:15',
        'room': 'Hall A',
        'verificationMethod': 'face',
      };

      // Note: json key is 'subjectId' not 'subjectId:'
      json['subjectId'] = json.remove('subjectId:')!;

      final record = AttendanceRecord.fromJson(json);

      expect(record.id, '3');
      expect(record.status, 'late');
      expect(record.verificationMethod, 'face');
    });

    test('toJson returns correct map', () {
      final record = AttendanceRecord(
        id: '4',
        subjectId: 'eng101',
        subjectName: 'English',
        date: '2024-10-27',
        status: 'present',
        checkedInTime: '08:55',
        room: 'Room 201',
        verificationMethod: 'fingerprint',
      );

      final json = record.toJson();

      expect(json['id'], '4');
      expect(json['room'], 'Room 201');
      expect(json['verificationMethod'], 'fingerprint');
    });

    test('copyWith replaces specified fields', () {
      final original = AttendanceRecord(
        id: '5',
        subjectId: 'cs101',
        subjectName: 'CS',
        date: '2024-10-28',
        status: 'present',
        checkedInTime: '09:00',
      );

      final modified = original.copyWith(status: 'absent', room: 'Lab 1');

      expect(modified.status, 'absent');
      expect(modified.room, 'Lab 1');
      expect(modified.id, '5'); // unchanged
    });
  });
}
