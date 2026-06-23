import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/auth/data/model/user_model.dart';

void main() {
  group('UserModel', () {
    test('constructor stores all fields', () {
      final user = UserModel(
        id: '123',
        name: 'Ahmed',
        email: 'ahmed@uni.edu',
        role: 'student',
      );

      expect(user.id, '123');
      expect(user.name, 'Ahmed');
      expect(user.email, 'ahmed@uni.edu');
      expect(user.role, 'student');
    });

    test('fromJson creates correct UserModel', () {
      final json = {
        'id': '456',
        'name': 'Sara',
        'email': 'sara@uni.edu',
        'role': 'doctor',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '456');
      expect(user.name, 'Sara');
      expect(user.email, 'sara@uni.edu');
      expect(user.role, 'doctor');
    });

    test('toJson returns correct map', () {
      final user = UserModel(
        id: '789',
        name: 'Ali',
        email: 'ali@uni.edu',
        role: 'student',
      );

      final json = user.toJson();

      expect(json, {
        'id': '789',
        'name': 'Ali',
        'email': 'ali@uni.edu',
        'role': 'student',
      });
    });

    test('roundtrip fromJson(toJson()) preserves data', () {
      final original = UserModel(
        id: '101',
        name: 'Mona',
        email: 'mona@uni.edu',
        role: 'student',
      );

      final roundtripped = UserModel.fromJson(original.toJson());

      expect(roundtripped.id, original.id);
      expect(roundtripped.name, original.name);
      expect(roundtripped.email, original.email);
      expect(roundtripped.role, original.role);
    });
  });
}
