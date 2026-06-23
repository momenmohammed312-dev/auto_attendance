// notification_center_screen.dart
// ---------------------------------
// شاشة مركز الإشعارات - بتعرض كل الإشعارات مرتّبة
// مع إمكانية التعليم كمقروء وتصفية حسب النوع

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notifications_provider.dart';
import '../data/notification_model.dart';
import '../../../auth/providers/auth_provider.dart';
import 'package:auto_attendace/core/app_colors.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authProvider).user?.id;
      if (userId != null) {
        ref.read(notificationsProvider.notifier).fetchNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    final filtered = _selectedFilter == null
        ? state.notifications
        : state.notifications.where((n) => n.type == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            const Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            if (state.hasUnread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Text('${state.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        actions: [
          if (state.hasUnread)
            TextButton(
              onPressed: () {
                final userId = ref.read(authProvider).user?.id;
                if (userId != null) {
                  ref.read(notificationsProvider.notifier).markAllAsRead(userId);
                }
              },
              child: const Text('Mark all read', style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _buildError(state.error!)
                    : filtered.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: () {
                              final userId = ref.read(authProvider).user?.id;
                              if (userId != null) {
                                return ref.read(notificationsProvider.notifier).fetchNotifications(userId);
                              }
                              return Future.value();
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, index) => _NotificationTile(notification: filtered[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = [
      {'label': 'All', 'value': null},
      {'label': '✅ Attendance', 'value': 'attendance_confirmed'},
      {'label': '⚠️ Warnings', 'value': 'absence_warning'},
      {'label': '📢 Sessions', 'value': 'session_started'},
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter['label'] as String),
                selected: isSelected,
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSub, fontSize: 12),
                onSelected: (_) => setState(() => _selectedFilter = filter['value']),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('No notifications yet', style: TextStyle(fontSize: 16, color: AppColors.textMuted)),
          SizedBox(height: 4),
          Text('You\'ll see updates about your attendance here',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final userId = ref.read(authProvider).user?.id;
              if (userId != null) {
                ref.read(notificationsProvider.notifier).fetchNotifications(userId);
              }
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Notification Tile Widget
// ═══════════════════════════════════════════════════════════════════════════

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationsProvider.notifier).markAsRead(notification.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.surface : AppColors.primaryLight.withValues(alpha:0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead ? AppColors.divider : AppColors.primary.withValues(alpha:0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _getTypeColor(notification.type).withValues(alpha:0.12), shape: BoxShape.circle),
              child: Icon(_getTypeIcon(notification.type), color: _getTypeColor(notification.type), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(notification.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'attendance_confirmed':
        return Icons.check_circle_outline;
      case 'absence_warning':
        return Icons.warning_amber_outlined;
      case 'session_started':
        return Icons.sensors;
      case 'session_ended':
        return Icons.sensors_off;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'attendance_confirmed':
        return AppColors.success;
      case 'absence_warning':
        return AppColors.warning;
      case 'session_started':
        return AppColors.primary;
      case 'session_ended':
        return AppColors.textMuted;
      default:
        return AppColors.accent;
    }
  }
}
