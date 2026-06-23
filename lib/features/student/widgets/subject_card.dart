import 'package:flutter/material.dart';

/// Card widget displaying subject attendance in vertical bar format.
///
/// Shows a vertical progress bar with the subject name and percentage below.
/// Bar height is proportional to the attendance percentage.
///
/// Used in the Subject Breakdown section of the Dashboard.
class SubjectCard extends StatelessWidget {
  final String subjectName;
  final double percentage;
  final String colorHex;

  const SubjectCard({
    super.key,
    required this.subjectName,
    required this.percentage,
    required this.colorHex,
  });

  /// Converts the hex color string to a Flutter Color.
  ///
  /// Example: "#2E5BFF" -> Color(0xFF2E5BFF)
  Color get _barColor {
    return Color(
      (int.tryParse(colorHex.replaceFirst('#', ''), radix: 16) ?? 0xFF9E9E9E) + 0xFF000000,
    );
  }

  @override
  Widget build(BuildContext context) {
    final barMaxHeight = 100.0;
    final barHeight = (percentage / 100) * barMaxHeight;

    return Container(
      width: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Container(
              width: 12,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 12,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: _barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            subjectName.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '${percentage.toInt()}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
