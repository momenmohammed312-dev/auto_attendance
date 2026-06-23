import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:auto_attendace/features/biometric/providers/biometric_provider.dart';
import 'package:auto_attendace/features/biometric/data/face_recognition_service.dart';

class MockFaceRecognitionService extends Mock implements FaceRecognitionService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  group('BiometricState', () {
    test('default values are correct', () {
      const state = BiometricState();

      expect(state.flow, BiometricFlow.idle);
      expect(state.errorMessage, isNull);
      expect(state.checkInResult, isNull);
      expect(state.enrollResult, isNull);
      expect(state.capturedConfidence, isNull);
    });

    test('copyWith replaces specified fields', () {
      const state = BiometricState();

      final updated = state.copyWith(
        flow: BiometricFlow.success,
        errorMessage: 'Error',
      );

      expect(updated.flow, BiometricFlow.success);
      expect(updated.errorMessage, 'Error');
    });

    test('copyWith clearError removes error', () {
      const state = BiometricState(errorMessage: 'Error');
      final updated = state.copyWith(clearError: true);

      expect(updated.errorMessage, isNull);
    });
  });

  group('BiometricNotifier', () {
    late MockFaceRecognitionService mockFaceService;
    late BiometricNotifier notifier;

    setUp(() {
      mockFaceService = MockFaceRecognitionService();
      notifier = BiometricNotifier(mockFaceService);
    });

    test('initial state is idle', () {
      expect(notifier.state.flow, BiometricFlow.idle);
    });

    test('attendanceCheckIn sets success flow on success', () async {
      final result = AttendanceCheckInResult(
        success: true,
        status: 'present',
        employeeId: '1',
        message: 'Success',
      );

      when(() => mockFaceService.attendanceCheckIn(
            employeeId: any(named: 'employeeId'),
            imageBytes: any(named: 'imageBytes'),
          )).thenAnswer((_) async => result);

      await notifier.attendanceCheckIn(
        employeeId: '1',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(notifier.state.flow, BiometricFlow.success);
      expect(notifier.state.checkInResult, result);
    });

    test('attendanceCheckIn sets error flow on failure', () async {
      final result = AttendanceCheckInResult(
        success: false,
        errorMessage: 'No face detected',
      );

      when(() => mockFaceService.attendanceCheckIn(
            employeeId: any(named: 'employeeId'),
            imageBytes: any(named: 'imageBytes'),
          )).thenAnswer((_) async => result);

      await notifier.attendanceCheckIn(
        employeeId: '1',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(notifier.state.flow, BiometricFlow.error);
      expect(notifier.state.errorMessage, 'No face detected');
    });

    test('registerFace sets success flow on success', () async {
      final result = FaceEnrollResult(
        success: true,
        message: 'Face registered',
      );

      when(() => mockFaceService.registerFace(
            employeeId: any(named: 'employeeId'),
            imageBytes: any(named: 'imageBytes'),
          )).thenAnswer((_) async => result);

      await notifier.registerFace(
        employeeId: '1',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(notifier.state.flow, BiometricFlow.success);
      expect(notifier.state.enrollResult, result);
    });

    test('registerFace sets error flow on failure', () async {
      final result = FaceEnrollResult(
        success: false,
        errorMessage: 'Registration failed',
      );

      when(() => mockFaceService.registerFace(
            employeeId: any(named: 'employeeId'),
            imageBytes: any(named: 'imageBytes'),
          )).thenAnswer((_) async => result);

      await notifier.registerFace(
        employeeId: '1',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(notifier.state.flow, BiometricFlow.error);
      expect(notifier.state.errorMessage, 'Registration failed');
    });

    test('reset returns to idle state', () async {
      final result = AttendanceCheckInResult(
        success: true,
        status: 'present',
        employeeId: '1',
      );

      when(() => mockFaceService.attendanceCheckIn(
            employeeId: any(named: 'employeeId'),
            imageBytes: any(named: 'imageBytes'),
          )).thenAnswer((_) async => result);

      await notifier.attendanceCheckIn(
        employeeId: '1',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(notifier.state.flow, BiometricFlow.success);

      notifier.reset();

      expect(notifier.state.flow, BiometricFlow.idle);
      expect(notifier.state.checkInResult, isNull);
      expect(notifier.state.errorMessage, isNull);
    });

    test('attendanceCheckIn clears previous error', () async {
      final failResult = AttendanceCheckInResult(
        success: false,
        errorMessage: 'Error',
      );

      when(() => mockFaceService.attendanceCheckIn(
            employeeId: any(named: 'employeeId'),
            imageBytes: any(named: 'imageBytes'),
          )).thenAnswer((_) async => failResult);

      await notifier.attendanceCheckIn(
        employeeId: '1',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(notifier.state.errorMessage, 'Error');

      final successResult = AttendanceCheckInResult(
        success: true,
        status: 'present',
        employeeId: '1',
      );

      when(() => mockFaceService.attendanceCheckIn(
            employeeId: any(named: 'employeeId'),
            imageBytes: any(named: 'imageBytes'),
          )).thenAnswer((_) async => successResult);

      await notifier.attendanceCheckIn(
        employeeId: '1',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.flow, BiometricFlow.success);
    });
  });
}
