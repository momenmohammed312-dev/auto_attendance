import 'package:flutter/foundation.dart';

/// Model representing a single attendance record for a lecture.
///
/// Contains information about a student's attendance for a specific subject
/// on a specific date, including check-in time, status, and verification method.
///
/// Example:
/// ```dart
/// AttendanceRecord record = AttendanceRecord(
///   id: '1',
///   subjectId: 'cs101',
///   subjectName: 'Computer Science 101',
///   date: '2024-10-24',
///   status: 'present',
///   checkedInTime: '09:05',
///   room: 'Lab 4B',
///   verificationMethod: 'biometric',
/// );
/// ```
@immutable
class AttendanceRecord {
  final String id;
  final String subjectId;
  final String subjectName;
  final String date;
  final String status;
  final String checkedInTime;

  final String? room;
  final String? verificationMethod;

  const AttendanceRecord({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    required this.status,
    required this.checkedInTime,
    this.room,
    this.verificationMethod,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      date: json['date'],
      status: json['status'],
      checkedInTime: json['checkedInTime'],
      room: json['room'],
      verificationMethod: json['verificationMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'date': date,
      'status': status,
      'checkedInTime': checkedInTime,
      'room': room,
      'verificationMethod': verificationMethod,
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? date,
    String? status,
    String? checkedInTime,
    String? room,
    String? verificationMethod,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      date: date ?? this.date,
      status: status ?? this.status,
      checkedInTime: checkedInTime ?? this.checkedInTime,
      room: room ?? this.room,
      verificationMethod: verificationMethod ?? this.verificationMethod,
    );
  }
}
