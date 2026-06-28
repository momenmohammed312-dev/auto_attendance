

class CourseModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String lecturerId;
  final int creditHours;
  final String semester;
  final int year;
  final List<String> studentIds;
  final DateTime createdAt;

  const CourseModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.lecturerId,
    required this.creditHours,
    required this.semester,
    required this.year,
    required this.studentIds,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      lecturerId: json['lecturer_id'] as String,
      creditHours: json['credit_hours'] as int,
      semester: json['semester'] as String,
      year: json['year'] as int,
      studentIds: (json['student_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'lecturer_id': lecturerId,
        'credit_hours': creditHours,
        'semester': semester,
        'year': year,
        'student_ids': studentIds,
        'created_at': createdAt.toIso8601String(),
      };

  CourseModel copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? lecturerId,
    int? creditHours,
    String? semester,
    int? year,
    List<String>? studentIds,
    DateTime? createdAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      lecturerId: lecturerId ?? this.lecturerId,
      creditHours: creditHours ?? this.creditHours,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'CourseModel(code: $code, name: $name, lecturer: $lecturerId, students: ${studentIds.length})';
}
