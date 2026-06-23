/// notification_repository.dart
/// -----------------------------
/// Repository مسؤول عن:
/// 1. جلب الإشعارات من الـ API
/// 2. تعليمها كـ "مقروءة"
/// 3. تهيئة flutter_local_notifications للإشعارات المحلية

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_model.dart';
import 'package:auto_attendace/core/utils/constants.dart';

class NotificationRepository {
  final Dio _dio;
  final FlutterLocalNotificationsPlugin _localNotifications;

  NotificationRepository({Dio? dio})
      : _dio = dio ?? Dio(), // TODO: Add auth interceptor with JWT token from SecureStorageService for backend API calls
        _localNotifications = FlutterLocalNotificationsPlugin() {
    _initLocalNotifications();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Local Notifications Setup
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // API Operations
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/notifications',
        queryParameters: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch notifications');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _dio.patch('${AppConstants.baseUrl}/notifications/$notificationId/read');
      if (response.statusCode != 200) throw Exception('Failed to mark notification as read');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final response = await _dio.patch(
        '${AppConstants.baseUrl}/notifications/read-all',
        data: {'user_id': userId},
      );
      if (response.statusCode != 200) throw Exception('Failed to mark all as read');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Local Push Notifications
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'attendance_channel',
      'Attendance Notifications',
      channelDescription: 'Notifications for attendance events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Error Handling
  // ═══════════════════════════════════════════════════════════════════════════

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Check your internet.');
      case DioExceptionType.connectionError:
        return Exception('Cannot connect to server.');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${e.response?.statusCode}');
      default:
        return Exception('Unexpected error: ${e.message}');
    }
  }
}
