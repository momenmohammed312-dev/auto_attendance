// live_feed_item.dart
// -------------------
// Widget يعرض سجل حضور طالب واحد في الـ live feed
// يظهر اسم الطالب، وقت الحضور، المسافة، وحالة التحقق

import 'package:flutter/material.dart';
import '../data/models/live_attendance_item.dart';
import 'package:auto_attendace/core/app_colors.dart';

class LiveFeedItem extends StatelessWidget {
  final LiveAttendanceItem item;
  final bool isNew;

  const LiveFeedItem({
    super.key,
    required this.item,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isNew ? AppColors.primaryLight.withValues(alpha: 0.4) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNew ? AppColors.primary.withValues(alpha: 0.3) : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(item.formattedTime,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(item.formattedDistance,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(),
                const SizedBox(height: 4),
                if (item.isVerified)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.face, size: 12, color: AppColors.success),
                      SizedBox(width: 2),
                      Text('Verified',
                          style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w500)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: item.studentPhotoUrl != null ? NetworkImage(item.studentPhotoUrl!) : null,
      child: item.studentPhotoUrl == null
          ? Text(
              item.studentName.isNotEmpty ? item.studentName[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
            )
          : null,
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (item.status) {
      case 'present':
        bgColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
        label = 'Present';
        icon = Icons.check_circle_outline;
        break;
      case 'late':
        bgColor = AppColors.warning.withValues(alpha: 0.12);
        textColor = AppColors.warning;
        label = 'Late';
        icon = Icons.watch_later_outlined;
        break;
      case 'rejected':
        bgColor = AppColors.danger.withValues(alpha: 0.12);
        textColor = AppColors.danger;
        label = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = AppColors.surfaceAlt;
        textColor = AppColors.textMuted;
        label = item.status;
        icon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
