import 'package:flutter/material.dart';
import 'status_pill.dart';

/// Reusable app top bar/header widget.
///
/// Displays user avatar, greeting message, app title, notification button,
/// and optional status pill (e.g., SYNCED).
/// Used across all student screens for consistent header appearance.
class AppTopBar extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final bool showStatusPill;
  final String statusText;

  const AppTopBar({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.onNotificationTap,
    this.showStatusPill = false,
    this.statusText = 'SYNCED',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                backgroundColor: const Color(0xFF2E5BFF),
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $userName',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const Text(
                    'Academic Luminary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Status pill (SYNCED) - shown between user info and notification
          if (showStatusPill)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: StatusPill(text: statusText, type: StatusType.success),
            ),

          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
