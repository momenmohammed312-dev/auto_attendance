import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/auth/data/model/login_request.dart';

void main() {
  group('LoginRequest', () {
    test('constructor stores all fields', () {
      final request = LoginRequest(
        name: 'Ahmed',
        studentId: '12345',
        role: 'student',
      );

      expect(request.name, 'Ahmed');
      expect(request.studentId, '12345');
      expect(request.role, 'student');
    });

    test('toJson returns correct map with snake_case keys', () {
      final request = LoginRequest(
        name: 'Sara',
        studentId: '67890',
        role: 'doctor',
      );

      final json = request.toJson();

      expect(json, {
        'name': 'Sara',
        'student_id': '67890',
        'role': 'doctor',
      });
    });

    test('handles empty strings', () {
      final request = LoginRequest(
        name: '',
        studentId: '',
        role: '',
      );

      final json = request.toJson();

      expect(json['name'], '');
      expect(json['student_id'], '');
      expect(json['role'], '');
    });
  });
}
