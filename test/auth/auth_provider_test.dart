import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:auto_attendace/auth/providers/auth_provider.dart';
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

  group('AuthState', () {
    test('default values are correct', () {
      final state = AuthState();

      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith replaces specified fields', () {
      final state = AuthState();

      final user = UserModel(
        id: '1',
        name: 'Test',
        email: 'test@test.com',
        role: 'student',
      );

      final updated = state.copyWith(
        user: user,
        isLoading: true,
        error: 'Some error',
      );

      expect(updated.user, user);
      expect(updated.isLoading, isTrue);
      expect(updated.error, 'Some error');
    });

    test('copyWith preserves unmodified fields', () {
      final user = UserModel(
        id: '1',
        name: 'Test',
        email: 'test@test.com',
        role: 'student',
      );

      final state = AuthState(user: user, isLoading: true);
      final updated = state.copyWith(error: 'New error');

      expect(updated.user, user);
      expect(updated.isLoading, isTrue);
      expect(updated.error, 'New error');
    });
  });

  group('AuthNotifier', () {
    late MockAuthRepository mockRepository;
    late AuthNotifier notifier;

    setUp(() {
      mockRepository = MockAuthRepository();
      notifier = AuthNotifier(mockRepository);
    });

    test('initial state is correct', () {
      expect(notifier.state.user, isNull);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('login sets isLoading true then false on success', () async {
      final user = UserModel(
        id: '1',
        name: 'Ahmed',
        email: 'ahmed@test.com',
        role: 'student',
      );

      when(() => mockRepository.login(any())).thenAnswer((_) async => user);

      final loginFuture = notifier.login('Ahmed', '1', 'student');

      expect(notifier.state.isLoading, isTrue);

      await loginFuture;

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.user, user);
      expect(notifier.state.error, isNull);
    });

    test('login sets error on failure', () async {
      when(() => mockRepository.login(any())).thenThrow(
        Exception('Login failed'),
      );

      await notifier.login('Ahmed', '1', 'student');

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.user, isNull);
      expect(notifier.state.error, contains('Login failed'));
    });

    test('login clears previous error', () async {
      when(() => mockRepository.login(any())).thenThrow(
        Exception('Error'),
      );
      await notifier.login('Ahmed', '1', 'student');
      expect(notifier.state.error, isNotNull);

      final user = UserModel(
        id: '1',
        name: 'Ahmed',
        email: 'ahmed@test.com',
        role: 'student',
      );
      when(() => mockRepository.login(any())).thenAnswer((_) async => user);

      await notifier.login('Ahmed', '1', 'student');

      expect(notifier.state.error, isNull);
      expect(notifier.state.user, user);
    });

    test('setUserFromStorage sets user from map', () {
      final userData = {
        'id': '100',
        'name': 'Restored User',
        'email': 'restored@test.com',
        'role': 'student',
      };

      notifier.setUserFromStorage(userData);

      expect(notifier.state.user, isA<UserModel>());
      expect(notifier.state.user!.id, '100');
      expect(notifier.state.user!.name, 'Restored User');
      expect(notifier.state.isLoading, isFalse);
    });

    test('setUserFromStorage sets error on invalid data', () {
      notifier.setUserFromStorage({'invalid': 'data'});

      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error, contains('Failed to restore'));
    });
  });
}
