import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:auto_attendace/auth/data/auth_repository.dart';
import 'package:auto_attendace/auth/data/model/login_request.dart';
import 'package:auto_attendace/auth/data/model/user_model.dart';

class MockDio extends Mock implements Dio {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late Dio mockDio;
  late AuthRepository repository;

  setUpAll(() {
    registerFallbackValue(
      LoginRequest(name: '', studentId: '', role: ''),
    );
  });

  setUp(() {
    mockDio = MockDio();
    repository = AuthRepository(dio: mockDio);
  });

  group('AuthRepository - Student Login', () {
    test('login returns student mock data when API fails', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/students'),
        type: DioExceptionType.connectionTimeout,
      ));

      final request = LoginRequest(
        name: 'محمد أحمد علي',
        studentId: 'st_001',
        role: 'student',
      );
      final user = await repository.login(request);

      expect(user, isA<UserModel>());
      expect(user.id, 'st_001');
      expect(user.name, 'محمد أحمد علي');
      expect(user.email, 'mohamed.ali@university.edu');
      expect(user.role, 'student');
    });

    test('login with name match returns correct student', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/students'),
        type: DioExceptionType.connectionTimeout,
      ));

      final request = LoginRequest(
        name: 'مؤمن محمد',
        studentId: 'st_006',
        role: 'student',
      );
      final user = await repository.login(request);

      expect(user.name, 'مؤمن محمد');
      expect(user.id, 'st_006');
    });

    test('login with password match (123456) returns مؤمن محمد', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/students'),
        type: DioExceptionType.connectionTimeout,
      ));

      final request = LoginRequest(
        name: 'anything',
        studentId: '123456',
        role: 'student',
      );
      final user = await repository.login(request);

      expect(user.name, 'مؤمن محمد');
      expect(user.id, 'st_006');
    });

    test('login throws when student not found', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/students'),
        type: DioExceptionType.connectionTimeout,
      ));

      final request = LoginRequest(
        name: 'غير موجود',
        studentId: '000',
        role: 'student',
      );

      expect(
        () => repository.login(request),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRepository - Doctor Login', () {
    test('login returns doctor when name contains أحمد', () async {
      final request = LoginRequest(
        name: 'أحمد',
        studentId: '000',
        role: 'doctor',
      );
      final user = await repository.login(request);

      expect(user, isA<UserModel>());
      expect(user.name, 'د. أحمد محمد');
      expect(user.role, 'doctor');
    });

    test('login returns doctor when name contains ahmed', () async {
      final request = LoginRequest(
        name: 'ahmed',
        studentId: '000',
        role: 'doctor',
      );
      final user = await repository.login(request);

      expect(user.name, 'د. أحمد محمد');
      expect(user.role, 'doctor');
    });

    test('login throws when doctor not found', () async {
      final request = LoginRequest(
        name: 'خالد',
        studentId: '000',
        role: 'doctor',
      );

      expect(
        () => repository.login(request),
        throwsA(isA<Exception>()),
      );
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
