import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:auto_attendace/features/notifications/providers/notifications_provider.dart';
import 'package:auto_attendace/features/notifications/data/notification_repository.dart';
import 'package:auto_attendace/features/notifications/data/notification_model.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  group('NotificationsState', () {
    test('default values are correct', () {
      const state = NotificationsState();

      expect(state.notifications, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('unreadCount returns correct count', () {
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'T',
          body: 'B',
          type: 'general',
          createdAt: DateTime.now(),
          isRead: false,
        ),
        NotificationModel(
          id: '2',
          title: 'T',
          body: 'B',
          type: 'general',
          createdAt: DateTime.now(),
          isRead: true,
        ),
        NotificationModel(
          id: '3',
          title: 'T',
          body: 'B',
          type: 'general',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      final state = NotificationsState(notifications: notifications);

      expect(state.unreadCount, 2);
    });

    test('hasUnread returns true when there are unread notifications', () {
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'T',
          body: 'B',
          type: 'general',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      final state = NotificationsState(notifications: notifications);

      expect(state.hasUnread, isTrue);
    });

    test('hasUnread returns false when all are read', () {
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'T',
          body: 'B',
          type: 'general',
          createdAt: DateTime.now(),
          isRead: true,
        ),
      ];

      final state = NotificationsState(notifications: notifications);

      expect(state.hasUnread, isFalse);
    });

    test('copyWith clearError removes error', () {
      const state = NotificationsState(error: 'Error');
      final updated = state.copyWith(clearError: true);

      expect(updated.error, isNull);
    });
  });

  group('NotificationsNotifier', () {
    late MockNotificationRepository mockRepository;
    late NotificationsNotifier notifier;

    setUp(() {
      mockRepository = MockNotificationRepository();
      notifier = NotificationsNotifier(mockRepository);
    });

    test('initial state is correct', () {
      expect(notifier.state.notifications, isEmpty);
      expect(notifier.state.isLoading, isFalse);
    });

    test('fetchNotifications loads and sorts notifications', () async {
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'Old',
          body: 'Body',
          type: 'general',
          createdAt: DateTime(2024, 10, 24, 8, 0),
        ),
        NotificationModel(
          id: '2',
          title: 'New',
          body: 'Body',
          type: 'general',
          createdAt: DateTime(2024, 10, 24, 10, 0),
        ),
      ];

      when(() => mockRepository.getNotifications('user1'))
          .thenAnswer((_) async => notifications);

      await notifier.fetchNotifications('user1');

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.notifications.length, 2);
      // Should be sorted newest first
      expect(notifier.state.notifications[0].title, 'New');
      expect(notifier.state.notifications[1].title, 'Old');
    });

    test('fetchNotifications sets error on failure', () async {
      when(() => mockRepository.getNotifications('user1'))
          .thenThrow(Exception('Network error'));

      await notifier.fetchNotifications('user1');

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNotNull);
    });

    test('markAsRead updates locally then syncs', () async {
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'T',
          body: 'B',
          type: 'general',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      when(() => mockRepository.getNotifications('user1'))
          .thenAnswer((_) async => notifications);
      when(() => mockRepository.markAsRead('1'))
          .thenAnswer((_) async {});

      await notifier.fetchNotifications('user1');
      expect(notifier.state.notifications[0].isRead, isFalse);

      await notifier.markAsRead('1');

      expect(notifier.state.notifications[0].isRead, isTrue);
      verify(() => mockRepository.markAsRead('1')).called(1);
    });

    test('markAsRead sets error on API failure', () async {
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'T',
          body: 'B',
          type: 'general',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      when(() => mockRepository.getNotifications('user1'))
          .thenAnswer((_) async => notifications);
      when(() => mockRepository.markAsRead('1'))
          .thenThrow(Exception('Sync failed'));

      await notifier.fetchNotifications('user1');
      await notifier.markAsRead('1');

      // Should still be marked locally even if API fails
      expect(notifier.state.notifications[0].isRead, isTrue);
      expect(notifier.state.error, contains('Could not sync'));
    });

    test('markAllAsRead marks all notifications as read', () async {
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'T',
          body: 'B',
          type: 'general',
          createdAt: DateTime.now(),
          isRead: false,
        ),
        NotificationModel(
          id: '2',
          title: 'T',
          body: 'B',
          type: 'general',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      when(() => mockRepository.getNotifications('user1'))
          .thenAnswer((_) async => notifications);
      when(() => mockRepository.markAllAsRead('user1'))
          .thenAnswer((_) async {});

      await notifier.fetchNotifications('user1');
      await notifier.markAllAsRead('user1');

      expect(notifier.state.notifications.every((n) => n.isRead), isTrue);
    });

    test('clearError removes error', () async {
      when(() => mockRepository.getNotifications('user1'))
          .thenThrow(Exception('Error'));

      await notifier.fetchNotifications('user1');
      expect(notifier.state.error, isNotNull);

      notifier.clearError();
      expect(notifier.state.error, isNull);
    });
  });
}
