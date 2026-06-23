// notifications_provider.dart
// ----------------------------
// Riverpod State Management للإشعارات
// بيدير قائمة الإشعارات وعدد الغير مقروء

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';
import '../data/notification_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// State Class
// ═══════════════════════════════════════════════════════════════════════════

class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Repository Provider
// ═══════════════════════════════════════════════════════════════════════════

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

// ═══════════════════════════════════════════════════════════════════════════
// Notifier
// ═══════════════════════════════════════════════════════════════════════════

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationRepository _repository;

  NotificationsNotifier(this._repository) : super(const NotificationsState());

  Future<void> fetchNotifications(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final notifications = await _repository.getNotifications(userId);
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final updatedList = state.notifications.map((n) {
      return n.id == notificationId ? n.markAsRead() : n;
    }).toList();

    state = state.copyWith(notifications: updatedList);

    try {
      await _repository.markAsRead(notificationId);
    } catch (e) {
      state = state.copyWith(error: 'Could not sync: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    final updatedList = state.notifications.map((n) => n.isRead ? n : n.markAsRead()).toList();
    state = state.copyWith(notifications: updatedList);

    try {
      await _repository.markAllAsRead(userId);
    } catch (e) {
      state = state.copyWith(error: 'Could not sync: $e');
    }
  }

  Future<void> addNewNotification(NotificationModel notification) async {
    state = state.copyWith(notifications: [notification, ...state.notifications]);
    await _repository.showLocalNotification(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.body,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ═══════════════════════════════════════════════════════════════════════════
// Main Provider
// ═══════════════════════════════════════════════════════════════════════════

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.watch(notificationRepositoryProvider));
});

/// Provider مستقل بيرجع عدد الإشعارات الغير مقروءة - بنستخدمه في الـ Bottom Nav
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});
