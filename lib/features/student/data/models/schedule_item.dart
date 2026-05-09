import 'package:flutter/foundation.dart';

/// Model representing a single schedule item (lecture) for the timeline.
///
/// Contains lecture details including time, room, and status.
/// Provides helper getters for formatted time display and current status check.
@immutable
class ScheduleItem {
  final String id;
  final String subjectName;
  final String subjectCode;
  final DateTime startTime;
  final DateTime endTime;
  final String room;
  final String status;
  final String? instructorName;

  const ScheduleItem({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.status,
    this.instructorName,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as String,
      subjectName: json['subject_name'] as String,
      subjectCode: json['subject_code'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      room: json['room'] as String,
      status: json['status'] as String,
      instructorName: json['instructor_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_name': subjectName,
      'subject_code': subjectCode,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'room': room,
      'status': status,
      'instructor_name': instructorName,
    };
  }

  /// Returns the start time formatted as HH:mm (e.g., "09:00").
  String get formattedStartTime {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Returns the end time formatted as HH:mm (e.g., "10:30").
  String get formattedEndTime {
    final hour = endTime.hour.toString().padLeft(2, '0');
    final minute = endTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Returns the full time range as "HH:mm - HH:mm" (e.g., "09:00 - 10:30").
  String get timeRange => '$formattedStartTime - $formattedEndTime';

  /// Checks if the lecture is currently ongoing.
  ///
  /// Returns true if current time is between start and end time.
  bool get isNow {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  ScheduleItem copyWith({
    String? id,
    String? subjectName,
    String? subjectCode,
    DateTime? startTime,
    DateTime? endTime,
    String? room,
    String? status,
    String? instructorName,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      subjectCode: subjectCode ?? this.subjectCode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      status: status ?? this.status,
      instructorName: instructorName ?? this.instructorName,
    );
  }
}
