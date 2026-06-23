import 'package:flutter/foundation.dart';

/// Model representing attendance summary for a specific subject.
///
/// Used in the dashboard to show subject-wise attendance statistics
/// including total lectures, attended count, and percentage.
///
/// Features:
/// - Calculates status label based on percentage
/// - Supports color coding for different subjects
@immutable
class SubjectAttendance {
  final String subjectId;
  final String subjectName;
  final int totalLectures;
  final int attendedLectures;
  final int missedLectures;
  final double attendancePercentage;
  final String colorHex;

  const SubjectAttendance({
    required this.subjectId,
    required this.subjectName,
    required this.totalLectures,
    required this.attendedLectures,
    required this.missedLectures,
    required this.attendancePercentage,
    required this.colorHex,
  });

  factory SubjectAttendance.fromJson(Map<String, dynamic> json) {
    return SubjectAttendance(
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      totalLectures: json['totalLectures'] ?? 0,
      attendedLectures: json['attendedLectures'] ?? 0,
      missedLectures: json['missedLectures'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] ?? 0).toDouble(),
      colorHex: json['colorHex'] ?? '#9E9E9E',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'totalLectures': totalLectures,
      'attendedLectures': attendedLectures,
      'missedLectures': missedLectures,
      'attendancePercentage': attendancePercentage,
      'colorHex': colorHex,
    };
  }

  /// Returns a status label based on attendance percentage.
  ///
  /// - Excellent: >= 85%
  /// - Good: >= 75%
  /// - Warning: >= 60%
  /// - At Risk: < 60%
  String get statusLabel {
    if (attendancePercentage >= 85) return 'Excellent';
    if (attendancePercentage >= 75) return 'Good';
    if (attendancePercentage >= 60) return 'Warning';
    return 'At Risk';
  }

  SubjectAttendance copyWith({
    String? subjectId,
    String? subjectName,
    int? totalLectures,
    int? attendedLectures,
    int? missedLectures,
    double? attendancePercentage,
    String? colorHex,
  }) {
    return SubjectAttendance(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      totalLectures: totalLectures ?? this.totalLectures,
      attendedLectures: attendedLectures ?? this.attendedLectures,
      missedLectures: missedLectures ?? this.missedLectures,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
