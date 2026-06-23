// session_model.dart
// -------------------
// Model يمثّل جلسة حضور (Attendance Session) ينشئها الدكتور
// كل جلسة عندها موقع جغرافي ونصف قطر وقائمة بالطلاب الذين حضروا

class SessionModel {
  final String id;
  final String lecturerId;
  final String subjectName;
  final String subjectCode;
  final DateTime startTime;
  final DateTime? endTime;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;
  final int totalStudents;
  final int presentCount;

  const SessionModel({
    required this.id,
    required this.lecturerId,
    required this.subjectName,
    required this.subjectCode,
    required this.startTime,
    this.endTime,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
    required this.totalStudents,
    required this.presentCount,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      lecturerId: json['lecturer_id'] as String,
      subjectName: json['subject_name'] as String,
      subjectCode: json['subject_code'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radius_meters'] as num).toDouble(),
      isActive: json['is_active'] as bool,
      totalStudents: json['total_students'] as int,
      presentCount: json['present_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lecturer_id': lecturerId,
        'subject_name': subjectName,
        'subject_code': subjectCode,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'radius_meters': radiusMeters,
        'is_active': isActive,
        'total_students': totalStudents,
        'present_count': presentCount,
      };

  /// نسبة الحضور من 0.0 إلى 1.0
  double get attendanceRate => totalStudents == 0 ? 0.0 : presentCount / totalStudents;

  String get attendanceRateText => '${(attendanceRate * 100).toStringAsFixed(0)}%';

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get durationText {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  SessionModel withNewAttendee() => copyWith(presentCount: presentCount + 1);

  SessionModel copyWith({
    String? id,
    String? lecturerId,
    String? subjectName,
    String? subjectCode,
    DateTime? startTime,
    DateTime? endTime,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? isActive,
    int? totalStudents,
    int? presentCount,
  }) {
    return SessionModel(
      id: id ?? this.id,
      lecturerId: lecturerId ?? this.lecturerId,
      subjectName: subjectName ?? this.subjectName,
      subjectCode: subjectCode ?? this.subjectCode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isActive: isActive ?? this.isActive,
      totalStudents: totalStudents ?? this.totalStudents,
      presentCount: presentCount ?? this.presentCount,
    );
  }

  @override
  String toString() =>
      'SessionModel(id: $id, subject: $subjectCode, active: $isActive, attendance: $presentCount/$totalStudents)';
}
