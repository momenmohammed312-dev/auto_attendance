import 'package:flutter/material.dart';

/// Circular progress chart showing overall attendance percentage.
///
/// Displays a large circular progress indicator with percentage text
/// and a motivational status message below.
///
/// Used in the Student Dashboard as the main attendance visual.
class AttendanceCircleChart extends StatelessWidget {
  final double percentage;
  final int attendedLectures;
  final int totalLectures;

  const AttendanceCircleChart({
    super.key,
    required this.percentage,
    required this.attendedLectures,
    required this.totalLectures,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الدائرة
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // الخلفية الرمادية
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 22,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey.withValues(alpha: 0.1),
                  ),
                ),

                // الـ Progress الأزرق
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 22,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2E5BFF),
                  ),
                  strokeCap: StrokeCap.round, // زوايا مدورة
                ),

                // النص في النص
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toInt()}%',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'ATTENDANCE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // النص التحتي
          Text(
            _getStatusText(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a motivational status message based on attendance percentage.
  ///
  /// - Excellent: >= 85%
  /// - Good: >= 75%
  /// - Warning: >= 60%
  /// - At Risk: < 60%
  String _getStatusText() {
    if (percentage >= 85) {
      return 'Excellent! You\'ve attended $attendedLectures out of $totalLectures lectures this semester.';
    } else if (percentage >= 75) {
      return 'Good job! You\'ve attended $attendedLectures out of $totalLectures lectures this semester.';
    } else if (percentage >= 60) {
      return 'You\'ve attended $attendedLectures out of $totalLectures lectures. Keep improving!';
    } else {
      return 'Warning! You\'ve only attended $attendedLectures out of $totalLectures lectures.';
    }
  }
}
