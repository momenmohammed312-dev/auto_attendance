import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/features/notifications/data/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('constructor stores all fields', () {
      final notification = NotificationModel(
        id: '1',
        title: 'Attendance Confirmed',
        body: 'Your attendance was recorded',
        type: 'attendance_confirmed',
        createdAt: DateTime(2024, 10, 24, 9, 0),
        isRead: false,
        metadata: {'subject': 'CS101'},
      );

      expect(notification.id, '1');
      expect(notification.title, 'Attendance Confirmed');
      expect(notification.isRead, isFalse);
      expect(notification.metadata, {'subject': 'CS101'});
    });

    test('constructor defaults isRead to false', () {
      final notification = NotificationModel(
        id: '2',
        title: 'Test',
        body: 'Body',
        type: 'general',
        createdAt: DateTime(2024, 10, 24),
      );

      expect(notification.isRead, isFalse);
      expect(notification.metadata, isNull);
    });

    test('fromJson creates correct NotificationModel', () {
      final json = {
        'id': '3',
        'title': 'New Session',
        'body:': 'Session started for CS101',
        'type': 'session_started',
        'created_at': '2024-10-24T10:00:00.000',
        'is_read': true,
        'metadata': null,
      };

      json['body'] = json.remove('body:')!;

      final notification = NotificationModel.fromJson(json);

      expect(notification.type, 'session_started');
      expect(notification.isRead, isTrue);
    });

    test('toJson returns correct map', () {
      final notification = NotificationModel(
        id: '4',
        title: 'Warning',
        body: 'Absence warning',
        type: 'absence_warning',
        createdAt: DateTime(2024, 10, 24, 11, 0),
        isRead: false,
      );

      final json = notification.toJson();

      expect(json['id'], '4');
      expect(json['is_read'], false);
      expect(json.containsKey('metadata'), isFalse); // null metadata excluded
    });

    test('copyWith replaces specified fields', () {
      final original = NotificationModel(
        id: '5',
        title: 'Test',
        body: 'Body',
        type: 'general',
        createdAt: DateTime(2024, 10, 24),
      );

      final modified = original.copyWith(isRead: true);

      expect(modified.isRead, isTrue);
      expect(modified.id, '5'); // unchanged
    });

    test('markAsRead returns copy with isRead true', () {
      final notification = NotificationModel(
        id: '6',
        title: 'Test',
        body: 'Body',
        type: 'general',
        createdAt: DateTime(2024, 10, 24),
        isRead: false,
      );

      final read = notification.markAsRead();

      expect(read.isRead, isTrue);
      expect(read.id, '6');
    });

    group('timeAgo', () {
      test('returns Just now for seconds ago', () {
        final notification = NotificationModel(
          id: '7',
          title: 'Test',
          body: 'Body',
          type: 'general',
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        );
        expect(notification.timeAgo, 'Just now');
      });

      test('returns minutes ago', () {
        final notification = NotificationModel(
          id: '8',
          title: 'Test',
          body: 'Body',
          type: 'general',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        expect(notification.timeAgo, '5 min ago');
      });

      test('returns hours ago', () {
        final notification = NotificationModel(
          id: '9',
          title: 'Test',
          body: 'Body',
          type: 'general',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        );
        expect(notification.timeAgo, '3h ago');
      });

      test('returns days ago', () {
        final notification = NotificationModel(
          id: '10',
          title: 'Test',
          body: 'Body',
          type: 'general',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        expect(notification.timeAgo, '2d ago');
      });

      test('returns formatted date for older notifications', () {
        final date = DateTime(2024, 1, 15);
        final notification = NotificationModel(
          id: '11',
          title: 'Test',
          body: 'Body',
          type: 'general',
          createdAt: date,
        );
        expect(notification.timeAgo, '15/1/2024');
      });
    });
  });
}
