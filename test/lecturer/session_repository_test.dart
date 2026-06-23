import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:auto_attendace/features/lecturer/data/session_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late SessionRepository repository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    repository = SessionRepository(dio: mockDio);
  });

  group('SessionRepository', () {
    group('createSession', () {
      test('returns SessionModel on 201 response', () async {
        final responseData = {
          'id': 's1',
          'lecturer_id': 'doc1',
          'subject_name': 'CS',
          'subject_code': 'CS101',
          'start_time': '2024-10-24T09:00:00.000',
          'end_time': null,
          'latitude': 30.0131,
          'longitude': 31.2089,
          'radius_meters': 200.0,
          'is_active': true,
          'total_students': 0,
          'present_count': 0,
        };

        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 201,
            requestOptions: RequestOptions(path: '/sessions'),
          ),
        );

        final session = await repository.createSession(
          lecturerId: 'doc1',
          subjectName: 'CS',
          subjectCode: 'CS101',
          latitude: 30.0131,
          longitude: 31.2089,
          radiusMeters: 200.0,
        );

        expect(session.id, 's1');
        expect(session.subjectCode, 'CS101');
        expect(session.isActive, isTrue);
      });

      test('throws on non-201 response', () async {
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: 'Error',
            statusCode: 500,
            requestOptions: RequestOptions(path: '/sessions'),
          ),
        );

        expect(
          () => repository.createSession(
            lecturerId: 'doc1',
            subjectName: 'CS',
            subjectCode: 'CS101',
            latitude: 30.0,
            longitude: 31.0,
            radiusMeters: 200.0,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getSession', () {
      test('returns SessionModel on 200 response', () async {
        final responseData = {
          'id': 's2',
          'lecturer_id': 'doc2',
          'subject_name': 'Math',
          'subject_code': 'MATH101',
          'start_time': '2024-10-24T10:00:00.000',
          'end_time': null,
          'latitude': 30.0,
          'longitude': 31.0,
          'radius_meters': 150.0,
          'is_active': true,
          'total_students': 30,
          'present_count': 20,
        };

        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/sessions/s2'),
          ),
        );

        final session = await repository.getSession('s2');

        expect(session.id, 's2');
        expect(session.presentCount, 20);
      });
    });

    group('closeSession', () {
      test('returns closed SessionModel', () async {
        final responseData = {
          'id': 's3',
          'lecturer_id': 'doc3',
          'subject_name:': 'Eng',
          'subject_code': 'ENG101',
          'start_time': '2024-10-24T09:00:00.000',
          'end_time': '2024-10-24T10:30:00.000',
          'latitude': 30.0,
          'longitude': 31.0,
          'radius_meters': 200.0,
          'is_active': false,
          'total_students': 25,
          'present_count': 22,
        };

        responseData['subject_name'] = responseData.remove('subject_name:')!;

        when(() => mockDio.patch(any())).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/sessions/s3/close'),
          ),
        );

        final session = await repository.closeSession('s3');

        expect(session.isActive, isFalse);
      });
    });

    group('getSessionAttendees', () {
      test('returns list of LiveAttendanceItem', () async {
        final responseData = [
          {
            'id': 'a1',
            'student_name': 'Ahmed',
            'student_photo_url': null,
            'check_in_time': '2024-10-24T09:05:00.000',
            'distance_meters': 150.0,
            'is_verified': true,
            'status': 'present',
          },
        ];

        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/sessions/s1/attendees'),
          ),
        );

        final attendees = await repository.getSessionAttendees('s1');

        expect(attendees.length, 1);
        expect(attendees[0].studentName, 'Ahmed');
      });
    });

    group('updateSessionRadius', () {
      test('sends PATCH request with new radius', () async {
        when(() => mockDio.patch(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/sessions/s1/radius'),
          ),
        );

        await repository.updateSessionRadius(
          sessionId: 's1',
          newRadiusMeters: 300.0,
        );

        verify(() => mockDio.patch(
              any(),
              data: {'radius_meters': 300.0},
            )).called(1);
      });
    });

    group('error handling', () {
      test('handles connection timeout', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/sessions'),
          ),
        );

        expect(
          () => repository.getSession('s1'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Connection timeout'),
          )),
        );
      });

      test('handles 401 unauthorized', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 401,
              requestOptions: RequestOptions(path: '/sessions'),
            ),
            requestOptions: RequestOptions(path: '/sessions'),
          ),
        );

        expect(
          () => repository.getSession('s1'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unauthorized'),
          )),
        );
      });

      test('handles 404 not found', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/sessions'),
            ),
            requestOptions: RequestOptions(path: '/sessions'),
          ),
        );

        expect(
          () => repository.getSession('s1'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not found'),
          )),
        );
      });
    });
  });
}
