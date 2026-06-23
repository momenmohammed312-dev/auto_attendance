import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/features/lecturer/data/models/session_model.dart';

void main() {
  group('SessionModel', () {
    test('constructor stores all fields', () {
      final session = SessionModel(
        id: 's1',
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0131,
        longitude: 31.2089,
        radiusMeters: 200.0,
        isActive: true,
        totalStudents: 50,
        presentCount: 30,
      );

      expect(session.id, 's1');
      expect(session.isActive, isTrue);
      expect(session.presentCount, 30);
    });

    test('fromJson creates correct SessionModel', () {
      final json = {
        'id': 's2',
        'lecturer_id': 'doc2',
        'subject_name': 'Math',
        'subject_code': 'MATH101',
        'start_time': '2024-10-24T09:00:00.000',
        'end_time': '2024-10-24T10:30:00.000',
        'latitude': 30.0131,
        'longitude': 31.2089,
        'radius_meters': 150.0,
        'is_active': false,
        'total_students': 40,
        'present_count': 35,
      };

      final session = SessionModel.fromJson(json);

      expect(session.subjectCode, 'MATH101');
      expect(session.endTime, DateTime(2024, 10, 24, 10, 30));
      expect(session.isActive, isFalse);
    });

    test('fromJson handles null end_time', () {
      final json = {
        'id': 's3',
        'lecturer_id': 'doc3',
        'subject_name:': 'Physics',
        'subject_code': 'PHY101',
        'start_time': '2024-10-24T09:00:00.000',
        'end_time': null,
        'latitude': 30.0,
        'longitude': 31.0,
        'radius_meters': 200.0,
        'is_active': true,
        'total_students': 30,
        'present_count': 10,
      };

      json['subject_name'] = json.remove('subject_name:')!;

      final session = SessionModel.fromJson(json);

      expect(session.endTime, isNull);
    });

    test('toJson returns correct map', () {
      final session = SessionModel(
        id: 's4',
        lecturerId: 'doc4',
        subjectName: 'Eng',
        subjectCode: 'ENG101',
        startTime: DateTime(2024, 10, 24, 11, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 100.0,
        isActive: true,
        totalStudents: 25,
        presentCount: 20,
      );

      final json = session.toJson();

      expect(json['lecturer_id'], 'doc4');
      expect(json['radius_meters'], 100.0);
      expect(json['end_time'], isNull);
    });

    test('copyWith replaces specified fields', () {
      final original = SessionModel(
        id: 's5',
        lecturerId: 'doc5',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: true,
        totalStudents: 50,
        presentCount: 30,
      );

      final modified = original.copyWith(presentCount: 31);

      expect(modified.presentCount, 31);
      expect(modified.id, 's5'); // unchanged
    });

    test('attendanceRate returns correct ratio', () {
      final session = SessionModel(
        id: 's6',
        lecturerId: 'doc6',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: true,
        totalStudents: 50,
        presentCount: 25,
      );

      expect(session.attendanceRate, 0.5);
    });

    test('attendanceRate returns 0.0 when totalStudents is 0', () {
      final session = SessionModel(
        id: 's7',
        lecturerId: 'doc7',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: true,
        totalStudents: 0,
        presentCount: 0,
      );

      expect(session.attendanceRate, 0.0);
    });

    test('attendanceRateText returns formatted percentage', () {
      final session = SessionModel(
        id: 's8',
        lecturerId: 'doc8',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: true,
        totalStudents: 100,
        presentCount: 73,
      );

      expect(session.attendanceRateText, '73%');
    });

    test('durationText returns correct format', () {
      final session = SessionModel(
        id: 's9',
        lecturerId: 'doc9',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        endTime: DateTime(2024, 10, 24, 10, 30),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: false,
        totalStudents: 50,
        presentCount: 40,
      );

      expect(session.durationText, '1h 30m');
    });

    test('durationText returns minutes only when less than 1 hour', () {
      final session = SessionModel(
        id: 's10',
        lecturerId: 'doc10',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        endTime: DateTime(2024, 10, 24, 9, 45),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: false,
        totalStudents: 50,
        presentCount: 40,
      );

      expect(session.durationText, '45m');
    });

    test('withNewAttendee increments presentCount', () {
      final session = SessionModel(
        id: 's11',
        lecturerId: 'doc11',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: true,
        totalStudents: 50,
        presentCount: 30,
      );

      final updated = session.withNewAttendee();

      expect(updated.presentCount, 31);
    });
  });
}
