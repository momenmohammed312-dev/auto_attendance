import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:auto_attendace/auth/data/auth_repository.dart';
import 'package:auto_attendace/auth/data/model/login_request.dart';
import 'package:auto_attendace/auth/data/model/user_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      LoginRequest(name: '', studentId: '', role: ''),
    );
  });

  group('AuthRepository', () {
    late AuthRepository repository;

    setUp(() {
      repository = AuthRepository();
    });

    test('login returns UserModel with correct data', () async {
      final request = LoginRequest(
        name: 'Ahmed',
        studentId: '12345',
        role: 'student',
      );

      final user = await repository.login(request);

      expect(user, isA<UserModel>());
      expect(user.id, '12345');
      expect(user.name, 'Ahmed');
      expect(user.email, '12345@university.edu');
      expect(user.role, 'student');
    });

    test('login generates email from studentId', () async {
      final request = LoginRequest(
        name: 'Sara',
        studentId: '99999',
        role: 'doctor',
      );

      final user = await repository.login(request);

      expect(user.email, '99999@university.edu');
      expect(user.role, 'doctor');
    });

    test('login takes approximately 1 second (mock delay)', () async {
      final request = LoginRequest(
        name: 'Test',
        studentId: '00001',
        role: 'student',
      );

      final stopwatch = Stopwatch()..start();
      await repository.login(request);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(900));
    });
  });

  group('MockAuthRepository', () {
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
    });

    test('mock can be configured to return user', () async {
      final expectedUser = UserModel(
        id: 'mock1',
        name: 'Mock User',
        email: 'mock@test.com',
        role: 'student',
      );

      when(() => mockRepository.login(any())).thenAnswer(
        (_) async => expectedUser,
      );

      final result = await mockRepository.login(
        LoginRequest(name: 'Mock', studentId: 'mock1', role: 'student'),
      );

      expect(result, expectedUser);
      verify(() => mockRepository.login(any())).called(1);
    });

    test('mock can be configured to throw', () async {
      when(() => mockRepository.login(any())).thenThrow(
        Exception('Network error'),
      );

      expect(
        () => mockRepository.login(
          LoginRequest(name: 'Test', studentId: '1', role: 'student'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
