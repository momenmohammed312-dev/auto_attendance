// lecturer_model.dart
// -------------------
// Model يمثّل الدكتور/المحاضر مع بياناته الكاملة

class LecturerModel {
  final String id;
  final String name;
  final String email;
  final String department;
  final String? phone;
  final String? office;
  final List<String> courseIds;
  final List<String> studentIds;
  final DateTime createdAt;

  const LecturerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    this.phone,
    this.office,
    required this.courseIds,
    required this.studentIds,
    required this.createdAt,
  });

  factory LecturerModel.fromJson(Map<String, dynamic> json) {
    return LecturerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      department: json['department'] as String,
      phone: json['phone'] as String?,
      office: json['office'] as String?,
      courseIds: (json['course_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      studentIds: (json['student_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'department': department,
        'phone': phone,
        'office': office,
        'course_ids': courseIds,
        'student_ids': studentIds,
        'created_at': createdAt.toIso8601String(),
      };

  LecturerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? phone,
    String? office,
    List<String>? courseIds,
    List<String>? studentIds,
    DateTime? createdAt,
  }) {
    return LecturerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      office: office ?? this.office,
      courseIds: courseIds ?? this.courseIds,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'LecturerModel(id: $id, name: $name, department: $department, courses: ${courseIds.length}, students: ${studentIds.length})';
}
