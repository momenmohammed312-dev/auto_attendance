import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:auto_attendace/features/notifications/data/notification_repository.dart';
import 'package:auto_attendace/features/notifications/data/notification_model.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  group('NotificationRepository (mocked)', () {
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
    });

    group('getNotifications', () {
      test('returns list of NotificationModel', () async {
        final notifications = [
          NotificationModel(
            id: '1',
            title: 'Attendance Confirmed',
            body: 'Your attendance was recorded',
            type: 'attendance_confirmed',
            createdAt: DateTime(2024, 10, 24, 9, 0),
            isRead: false,
          ),
          NotificationModel(
            id: '2',
            title: 'Warning',
            body: 'Absence warning',
            type: 'absence_warning',
            createdAt: DateTime(2024, 10, 24, 10, 0),
            isRead: true,
          ),
        ];

        when(() => mockRepository.getNotifications('user1'))
            .thenAnswer((_) async => notifications);

        final result = await mockRepository.getNotifications('user1');

        expect(result.length, 2);
        expect(result[0].title, 'Attendance Confirmed');
        expect(result[1].isRead, isTrue);
      });

      test('throws on error', () async {
        when(() => mockRepository.getNotifications('user1'))
            .thenThrow(Exception('Network error'));

        expect(
          () => mockRepository.getNotifications('user1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('markAsRead', () {
      test('completes without error', () async {
        when(() => mockRepository.markAsRead('n1'))
            .thenAnswer((_) async {});

        await mockRepository.markAsRead('n1');

        verify(() => mockRepository.markAsRead('n1')).called(1);
      });

      test('throws on error', () async {
        when(() => mockRepository.markAsRead('n1'))
            .thenThrow(Exception('Mark failed'));

        expect(
          () => mockRepository.markAsRead('n1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('markAllAsRead', () {
      test('completes without error', () async {
        when(() => mockRepository.markAllAsRead('user1'))
            .thenAnswer((_) async {});

        await mockRepository.markAllAsRead('user1');

        verify(() => mockRepository.markAllAsRead('user1')).called(1);
      });

      test('throws on error', () async {
        when(() => mockRepository.markAllAsRead('user1'))
            .thenThrow(Exception('Mark all failed'));

        expect(
          () => mockRepository.markAllAsRead('user1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('showLocalNotification', () {
      test('completes without error', () async {
        when(() => mockRepository.showLocalNotification(
              id: any(named: 'id'),
              title: any(named: 'title'),
              body: any(named: 'body'),
            )).thenAnswer((_) async {});

        await mockRepository.showLocalNotification(
          id: 1,
          title: 'Test',
          body: 'Body',
        );

        verify(() => mockRepository.showLocalNotification(
              id: 1,
              title: 'Test',
              body: 'Body',
            )).called(1);
      });
    });
  });
}
