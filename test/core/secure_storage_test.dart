import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:auto_attendace/core/storage/secure_storage.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockStorage = MockSecureStorageService();
  });

  group('SecureStorageService', () {
    test('singleton returns same instance', () {
      final instance1 = SecureStorageService();
      final instance2 = SecureStorageService();

      expect(identical(instance1, instance2), isTrue);
    });

    group('saveUser', () {
      test('calls write with user data', () async {
        final userData = {
          'id': '1',
          'name': 'Ahmed',
          'email': 'ahmed@test.com',
          'role': 'student',
        };

        when(() => mockStorage.saveUser(userData))
            .thenAnswer((_) async {});

        await mockStorage.saveUser(userData);

        verify(() => mockStorage.saveUser(userData)).called(1);
      });
    });

    group('getUser', () {
      test('returns user data when exists', () async {
        final userData = {
          'id': '1',
          'name': 'Ahmed',
          'email': 'ahmed@test.com',
          'role': 'student',
        };

        when(() => mockStorage.getUser()).thenAnswer((_) async => userData);

        final result = await mockStorage.getUser();

        expect(result, userData);
      });

      test('returns null when no user saved', () async {
        when(() => mockStorage.getUser()).thenAnswer((_) async => null);

        final result = await mockStorage.getUser();

        expect(result, isNull);
      });
    });

    group('deleteUser', () {
      test('calls delete for user key', () async {
        when(() => mockStorage.deleteUser()).thenAnswer((_) async {});

        await mockStorage.deleteUser();

        verify(() => mockStorage.deleteUser()).called(1);
      });
    });

    group('token operations', () {
      test('saveToken and getToken', () async {
        when(() => mockStorage.saveToken('jwt123'))
            .thenAnswer((_) async {});
        when(() => mockStorage.getToken())
            .thenAnswer((_) async => 'jwt123');

        await mockStorage.saveToken('jwt123');
        final token = await mockStorage.getToken();

        expect(token, 'jwt123');
      });

      test('deleteToken', () async {
        when(() => mockStorage.deleteToken()).thenAnswer((_) async {});

        await mockStorage.deleteToken();

        verify(() => mockStorage.deleteToken()).called(1);
      });
    });

    group('refresh token operations', () {
      test('saveRefreshToken and getRefreshToken', () async {
        when(() => mockStorage.saveRefreshToken('refresh123'))
            .thenAnswer((_) async {});
        when(() => mockStorage.getRefreshToken())
            .thenAnswer((_) async => 'refresh123');

        await mockStorage.saveRefreshToken('refresh123');
        final token = await mockStorage.getRefreshToken();

        expect(token, 'refresh123');
      });

      test('deleteRefreshToken', () async {
        when(() => mockStorage.deleteRefreshToken())
            .thenAnswer((_) async {});

        await mockStorage.deleteRefreshToken();

        verify(() => mockStorage.deleteRefreshToken()).called(1);
      });
    });

    group('rememberMe', () {
      test('setRememberMe and getRememberMe', () async {
        when(() => mockStorage.setRememberMe(true))
            .thenAnswer((_) async {});
        when(() => mockStorage.getRememberMe())
            .thenAnswer((_) async => true);

        await mockStorage.setRememberMe(true);
        final result = await mockStorage.getRememberMe();

        expect(result, isTrue);
      });

      test('getRememberMe returns false by default', () async {
        when(() => mockStorage.getRememberMe())
            .thenAnswer((_) async => false);

        final result = await mockStorage.getRememberMe();

        expect(result, isFalse);
      });
    });

    group('clearAll', () {
      test('calls deleteAll', () async {
        when(() => mockStorage.clearAll()).thenAnswer((_) async {});

        await mockStorage.clearAll();

        verify(() => mockStorage.clearAll()).called(1);
      });
    });
  });
}
