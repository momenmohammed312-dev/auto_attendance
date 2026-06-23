import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/features/lecturer/data/models/live_attendance_item.dart';

void main() {
  group('LiveAttendanceItem', () {
    test('constructor stores all fields', () {
      final item = LiveAttendanceItem(
        id: '1',
        studentName: 'Ahmed',
        studentPhotoUrl: 'https://example.com/photo.jpg',
        checkInTime: DateTime(2024, 10, 24, 9, 5),
        distanceMeters: 150.0,
        isVerified: true,
        status: 'present',
      );

      expect(item.id, '1');
      expect(item.studentName, 'Ahmed');
      expect(item.isVerified, isTrue);
    });

    test('fromJson creates correct LiveAttendanceItem', () {
      final json = {
        'id': '2',
        'student_name': 'Sara',
        'student_photo_url': null,
        'check_in_time': '2024-10-24T09:10:00.000',
        'distance_meters': 85.5,
        'is_verified': true,
        'status': 'late',
      };

      final item = LiveAttendanceItem.fromJson(json);

      expect(item.studentName, 'Sara');
      expect(item.studentPhotoUrl, isNull);
      expect(item.distanceMeters, 85.5);
    });

    test('toJson returns correct map', () {
      final item = LiveAttendanceItem(
        id: '3',
        studentName: 'Ali',
        checkInTime: DateTime(2024, 10, 24, 9, 15),
        distanceMeters: 200.0,
        isVerified: false,
        status: 'rejected',
      );

      final json = item.toJson();

      expect(json['student_name'], 'Ali');
      expect(json['is_verified'], false);
      expect(json['status'], 'rejected');
    });

    test('copyWith replaces specified fields', () {
      final original = LiveAttendanceItem(
        id: '4',
        studentName: 'Mona',
        checkInTime: DateTime(2024, 10, 24, 9, 5),
        distanceMeters: 100.0,
        isVerified: false,
        status: 'pending',
      );

      final modified = original.copyWith(isVerified: true, status: 'present');

      expect(modified.isVerified, isTrue);
      expect(modified.status, 'present');
      expect(modified.studentName, 'Mona'); // unchanged
    });

    group('isPresent', () {
      test('returns true for present status', () {
        final item = LiveAttendanceItem(
          id: '5',
          studentName: 'Test',
          checkInTime: DateTime.now(),
          distanceMeters: 100,
          isVerified: true,
          status: 'present',
        );
        expect(item.isPresent, isTrue);
      });

      test('returns true for late status', () {
        final item = LiveAttendanceItem(
          id: '6',
          studentName: 'Test',
          checkInTime: DateTime.now(),
          distanceMeters: 100,
          isVerified: true,
          status: 'late',
        );
        expect(item.isPresent, isTrue);
      });

      test('returns false for rejected status', () {
        final item = LiveAttendanceItem(
          id: '7',
          studentName: 'Test',
          checkInTime: DateTime.now(),
          distanceMeters: 100,
          isVerified: false,
          status: 'rejected',
        );
        expect(item.isPresent, isFalse);
      });
    });

    group('formattedDistance', () {
      test('returns meters when less than 1000', () {
        final item = LiveAttendanceItem(
          id: '8',
          studentName: 'Test',
          checkInTime: DateTime.now(),
          distanceMeters: 150.0,
          isVerified: true,
          status: 'present',
        );
        expect(item.formattedDistance, '150m');
      });

      test('returns km when >= 1000', () {
        final item = LiveAttendanceItem(
          id: '9',
          studentName: 'Test',
          checkInTime: DateTime.now(),
          distanceMeters: 1500.0,
          isVerified: true,
          status: 'present',
        );
        expect(item.formattedDistance, '1.5km');
      });
    });

    test('formattedTime returns correct AM/PM format', () {
      final item = LiveAttendanceItem(
        id: '10',
        studentName: 'Test',
        checkInTime: DateTime(2024, 10, 24, 14, 5),
        distanceMeters: 100,
        isVerified: true,
        status: 'present',
      );
      expect(item.formattedTime, '2:05 PM');
    });

    test('formattedTime handles midnight', () {
      final item = LiveAttendanceItem(
        id: '11',
        studentName: 'Test',
        checkInTime: DateTime(2024, 10, 24, 0, 30),
        distanceMeters: 100,
        isVerified: true,
        status: 'present',
      );
      expect(item.formattedTime, '12:30 AM');
    });
  });
}
