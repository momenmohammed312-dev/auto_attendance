import 'package:flutter/material.dart';

/// Status types for the [StatusPill] widget.
///
/// Each type has its own color scheme:
/// - [success]: Green (SYNCED, VERIFIED)
/// - [info]: Blue (NOW, ACTIVE)
/// - [warning]: Orange (UPCOMING, WARNING)
/// - [error]: Red (ERROR, OUT OF RANGE)
enum StatusType { success, info, warning, error }

/// Reusable status pill/badge widget for showing status indicators.
///
/// Supports different types with their own color schemes.
///
/// Usage:
/// ```dart
/// StatusPill(text: 'SYNCED', type: StatusType.success)
/// StatusPill(text: 'NOW', type: StatusType.info)
/// ```
class StatusPill extends StatelessWidget {
  final String text;
  final StatusType type;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.text,
    required this.type,
    this.icon,
  });

  Color get backgroundColor {
    switch (type) {
      case StatusType.success:
        return const Color(0xFF22C55E).withValues(alpha: 0.1);
      case StatusType.info:
        return const Color(0xFF2E5BFF).withValues(alpha: 0.1);
      case StatusType.warning:
        return const Color(0xFFF59E0B).withValues(alpha: 0.1);
      case StatusType.error:
        return const Color(0xFFEF4444).withValues(alpha: 0.1);
    }
  }

  Color get textColor {
    switch (type) {
      case StatusType.success:
        return const Color(0xFF22C55E);
      case StatusType.info:
        return const Color(0xFF2E5BFF);
      case StatusType.warning:
        return const Color(0xFFF59E0B);
      case StatusType.error:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
