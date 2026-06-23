import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:auto_attendace/features/biometric/data/face_recognition_service.dart';
import 'package:auto_attendace/core/network/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late FaceRecognitionService service;
  late MockApiClient mockClient;

  setUpAll(() {
    registerFallbackValue(FormData.fromMap({}));
  });

  setUp(() {
    mockClient = MockApiClient();
    service = FaceRecognitionService(client: mockClient);
  });

  group('FaceRecognitionService', () {
    group('registerFace', () {
      test('returns FaceEnrollResult on success', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenAnswer(
          (_) async => Response(
            data: {'message': 'Face registered successfully'},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/register-face/1'),
          ),
        );

        final result = await service.registerFace(
          employeeId: '1',
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result.success, isTrue);
        expect(result.message, 'Face registered successfully');
      });

      test('returns failure on DioException', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {'detail': 'Face not clear'},
              statusCode: 400,
              requestOptions: RequestOptions(path: '/register-face/1'),
            ),
            requestOptions: RequestOptions(path: '/register-face/1'),
          ),
        );

        final result = await service.registerFace(
          employeeId: '1',
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, 'Face not clear');
      });

      test('returns failure on unexpected error', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenThrow(Exception('Unexpected'));

        final result = await service.registerFace(
          employeeId: '1',
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Unexpected'));
      });
    });

    group('attendanceCheckIn', () {
      test('returns AttendanceCheckInResult on success', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'status': 'present',
              'employee_id': '1',
              'message': 'Check-in successful',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/attendance/check-in/1'),
          ),
        );

        final result = await service.attendanceCheckIn(
          employeeId: '1',
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result.success, isTrue);
        expect(result.status, 'present');
        expect(result.employeeId, '1');
      });

      test('returns failure on DioException', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {'detail': 'No face detected'},
              statusCode: 400,
              requestOptions: RequestOptions(path: '/attendance/check-in/1'),
            ),
            requestOptions: RequestOptions(path: '/attendance/check-in/1'),
          ),
        );

        final result = await service.attendanceCheckIn(
          employeeId: '1',
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, 'No face detected');
      });
    });

    group('recognizeFace', () {
      test('returns FaceVerifyResult on success', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'matched': true,
              'confidence': 0.95,
              'employee_id': '1',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/recognize-face'),
          ),
        );

        final result = await service.recognizeFace(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result.matched, isTrue);
        expect(result.confidence, 0.95);
        expect(result.employeeId, '1');
      });

      test('returns failure on DioException', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {'detail': 'Recognition failed'},
              statusCode: 400,
              requestOptions: RequestOptions(path: '/recognize-face'),
            ),
            requestOptions: RequestOptions(path: '/recognize-face'),
          ),
        );

        final result = await service.recognizeFace(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result.matched, isFalse);
        expect(result.errorMessage, 'Recognition failed');
      });
    });

    group('checkLiveness', () {
      test('returns LivenessResult on success', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'is_live': true,
              'spoof_probability': 0.05,
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/liveness-check'),
          ),
        );

        final result = await service.checkLiveness(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result.isLive, isTrue);
        expect(result.spoofProbability, 0.05);
      });

      test('returns failure on DioException', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {'detail': 'Liveness check failed'},
              statusCode: 400,
              requestOptions: RequestOptions(path: '/liveness-check'),
            ),
            requestOptions: RequestOptions(path: '/liveness-check'),
          ),
        );

        final result = await service.checkLiveness(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result.isLive, isFalse);
        expect(result.errorMessage, 'Liveness check failed');
      });
    });

    group('detectFace', () {
      test('returns true when face detected', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenAnswer(
          (_) async => Response(
            data: {'face_detected': true},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/detect-face'),
          ),
        );

        final result = await service.detectFace(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result, isTrue);
      });

      test('returns false when no face detected', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenAnswer(
          (_) async => Response(
            data: {'face_detected': false},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/detect-face'),
          ),
        );

        final result = await service.detectFace(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result, isFalse);
      });

      test('returns false on error', () async {
        when(() => mockClient.mlUpload(
              any(),
              formData: any(named: 'formData'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/detect-face'),
          ),
        );

        final result = await service.detectFace(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(result, isFalse);
      });
    });

    group('checkHealth', () {
      test('returns true on 200', () async {
        when(() => mockClient.mlGet(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            data: {'status': 'healthy'},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/health'),
          ),
        );

        final result = await service.checkHealth();

        expect(result, isTrue);
      });

      test('returns false on error', () async {
        when(() => mockClient.mlGet(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(
          Exception('Connection failed'),
        );

        final result = await service.checkHealth();

        expect(result, isFalse);
      });
    });
  });
}
