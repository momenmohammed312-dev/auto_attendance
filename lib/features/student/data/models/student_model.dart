// student_model.dart
// -----------------
// Model يمثّل الطالب مع بياناته الكاملة

class StudentModel {
  final String id;
  final String fullName;
  final String email;

  const StudentModel({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
      };

  StudentModel copyWith({
    String? id,
    String? fullName,
    String? email,
  }) {
    return StudentModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
    );
  }

  @override
  String toString() => 'StudentModel(id: $id, name: $fullName, email: $email)';
}
