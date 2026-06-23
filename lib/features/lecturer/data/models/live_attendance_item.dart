// live_attendance_item.dart
// -------------------------
// Model يمثّل سجل حضور طالب واحد بشكل فوري (real-time)
// يُستخدم في LiveFeedItem widget لعرض قائمة الطلاب الذين سجّلوا حضورهم

class LiveAttendanceItem {
  final String id;
  final String studentName;
  final String? studentPhotoUrl;
  final DateTime checkInTime;
  final double distanceMeters;
  final bool isVerified;
  /// حالة الحضور: 'present' أو 'late' أو 'rejected'
  final String status;

  const LiveAttendanceItem({
    required this.id,
    required this.studentName,
    this.studentPhotoUrl,
    required this.checkInTime,
    required this.distanceMeters,
    required this.isVerified,
    required this.status,
  });

  factory LiveAttendanceItem.fromJson(Map<String, dynamic> json) {
    return LiveAttendanceItem(
      id: json['id'] as String,
      studentName: json['student_name'] as String,
      studentPhotoUrl: json['student_photo_url'] as String?,
      checkInTime: DateTime.parse(json['check_in_time'] as String),
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      isVerified: json['is_verified'] as bool,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_name': studentName,
        'student_photo_url': studentPhotoUrl,
        'check_in_time': checkInTime.toIso8601String(),
        'distance_meters': distanceMeters,
        'is_verified': isVerified,
        'status': status,
      };

  bool get isPresent => status == 'present' || status == 'late';

  /// نص المسافة بشكل مقروء
  String get formattedDistance {
    if (distanceMeters < 1000) return '${distanceMeters.toStringAsFixed(0)}m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
  }

  /// وقت الحضور بشكل مقروء مثل "09:05 AM"
  String get formattedTime {
    final hour = checkInTime.hour;
    final minute = checkInTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  LiveAttendanceItem copyWith({
    String? id,
    String? studentName,
    String? studentPhotoUrl,
    DateTime? checkInTime,
    double? distanceMeters,
    bool? isVerified,
    String? status,
  }) {
    return LiveAttendanceItem(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      studentPhotoUrl: studentPhotoUrl ?? this.studentPhotoUrl,
      checkInTime: checkInTime ?? this.checkInTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'LiveAttendanceItem(id: $id, student: $studentName, status: $status, time: $formattedTime)';
}
