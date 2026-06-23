class LoginRequest {
  final String name;
  final String studentId;
  final String role;

  LoginRequest({
    required this.name,
    required this.studentId,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'student_id': studentId, 'role': role};
  }
}
