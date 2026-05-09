import 'package:auto_attendace/shared/widgets/status_pill.dart';
import 'package:flutter/material.dart';

/// Timeline item widget for displaying scheduled lectures.
///
/// Features:
/// - Vertical timeline connector with dots
/// - Highlighted background for current lecture
/// - Time, room, and subject information
/// - "NOW" status pill for ongoing lectures
///
/// Used in the Today's Schedule section of the Dashboard.
class ScheduleTimelineItem extends StatelessWidget {
  final String subjectName;
  final String timeRange;
  final String room;
  final bool isNow;
  final bool isFirst;
  final bool isLast;

  const ScheduleTimelineItem({
    super.key,
    required this.subjectName,
    required this.timeRange,
    required this.room,
    this.isNow = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isNow
                    ? const Color(0xFF2E5BFF)
                    : Colors.grey.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: isNow
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isNow ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isNow
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isNow ? Colors.black : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.black38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeRange,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.black38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            room,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isNow) const StatusPill(text: 'NOW', type: StatusType.info),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
