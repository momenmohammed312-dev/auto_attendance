import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/features/student/data/models/schedule_item.dart';

void main() {
  group('ScheduleItem', () {
    test('constructor stores all fields', () {
      final item = ScheduleItem(
        id: '1',
        subjectName: 'CS 101',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        endTime: DateTime(2024, 10, 24, 10, 30),
        room: 'Lab 4B',
        status: 'ongoing',
        instructorName: 'Dr. Smith',
      );

      expect(item.id, '1');
      expect(item.subjectCode, 'CS101');
      expect(item.room, 'Lab 4B');
      expect(item.instructorName, 'Dr. Smith');
    });

    test('fromJson creates correct ScheduleItem', () {
      final json = {
        'id': '2',
        'subject_name': 'History',
        'subject_code': 'HIST201',
        'start_time': '2024-10-24T11:00:00.000',
        'end_time': '2024-10-24T12:30:00.000',
        'room': 'Hall A2',
        'status': 'upcoming',
        'instructor_name': 'Prof. Johnson',
      };

      final item = ScheduleItem.fromJson(json);

      expect(item.subjectName, 'History');
      expect(item.startTime, DateTime(2024, 10, 24, 11, 0));
      expect(item.status, 'upcoming');
    });

    test('toJson returns correct map', () {
      final item = ScheduleItem(
        id: '3',
        subjectName: 'Math',
        subjectCode: 'MATH301',
        startTime: DateTime(2024, 10, 24, 14, 0),
        endTime: DateTime(2024, 10, 24, 15, 30),
        room: 'Room 302',
        status: 'upcoming',
      );

      final json = item.toJson();

      expect(json['subject_name'], 'Math');
      expect(json['start_time'], '2024-10-24T14:00:00.000');
      expect(json['instructor_name'], isNull);
    });

    test('copyWith replaces specified fields', () {
      final original = ScheduleItem(
        id: '4',
        subjectName: 'Physics',
        subjectCode: 'PHY101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        endTime: DateTime(2024, 10, 24, 10, 0),
        room: 'Hall B',
        status: 'completed',
      );

      final modified = original.copyWith(status: 'ongoing');

      expect(modified.status, 'ongoing');
      expect(modified.room, 'Hall B'); // unchanged
    });

    test('formattedStartTime returns HH:mm', () {
      final item = ScheduleItem(
        id: '5',
        subjectName: 'Test',
        subjectCode: 'T1',
        startTime: DateTime(2024, 10, 24, 9, 5),
        endTime: DateTime(2024, 10, 24, 10, 0),
        room: 'R1',
        status: 'ongoing',
      );

      expect(item.formattedStartTime, '09:05');
    });

    test('formattedEndTime returns HH:mm', () {
      final item = ScheduleItem(
        id: '6',
        subjectName: 'Test',
        subjectCode: 'T1',
        startTime: DateTime(2024, 10, 24, 9, 0),
        endTime: DateTime(2024, 10, 24, 13, 30),
        room: 'R1',
        status: 'ongoing',
      );

      expect(item.formattedEndTime, '13:30');
    });

    test('timeRange returns formatted range', () {
      final item = ScheduleItem(
        id: '7',
        subjectName: 'Test',
        subjectCode: 'T1',
        startTime: DateTime(2024, 10, 24, 9, 0),
        endTime: DateTime(2024, 10, 24, 10, 30),
        room: 'R1',
        status: 'ongoing',
      );

      expect(item.timeRange, '09:00 - 10:30');
    });

    test('isNow returns true when current time is between start and end', () {
      final now = DateTime.now();
      final item = ScheduleItem(
        id: '8',
        subjectName: 'Test',
        subjectCode: 'T1',
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 1)),
        room: 'R1',
        status: 'ongoing',
      );

      expect(item.isNow, isTrue);
    });

    test('isNow returns false when current time is outside range', () {
      final item = ScheduleItem(
        id: '9',
        subjectName: 'Test',
        subjectCode: 'T1',
        startTime: DateTime(2020, 1, 1, 9, 0),
        endTime: DateTime(2020, 1, 1, 10, 0),
        room: 'R1',
        status: 'completed',
      );

      expect(item.isNow, isFalse);
    });
  });
}
