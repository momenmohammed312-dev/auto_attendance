import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/face_recognition_service.dart';

enum BiometricFlow {
  idle,
  cameraReady,
  capturingImage,
  sendingToApi,
  verifyingLocation,
  recordingAttendance,
  success,
  error,
}

class BiometricState {
  final BiometricFlow flow;
  final String? errorMessage;
  final AttendanceCheckInResult? checkInResult;
  final FaceEnrollResult? enrollResult;
  final double? capturedConfidence;

  const BiometricState({
    this.flow = BiometricFlow.idle,
    this.errorMessage,
    this.checkInResult,
    this.enrollResult,
    this.capturedConfidence,
  });

  BiometricState copyWith({
    BiometricFlow? flow,
    String? errorMessage,
    bool clearError = false,
    AttendanceCheckInResult? checkInResult,
    FaceEnrollResult? enrollResult,
    double? capturedConfidence,
  }) {
    return BiometricState(
      flow: flow ?? this.flow,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      checkInResult: checkInResult ?? this.checkInResult,
      enrollResult: enrollResult ?? this.enrollResult,
      capturedConfidence: capturedConfidence ?? this.capturedConfidence,
    );
  }
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  final FaceRecognitionService _faceService;

  BiometricNotifier(this._faceService) : super(const BiometricState());

  /// Attendance check-in with face (one API call does everything).
  Future<void> attendanceCheckIn({
    required String employeeId,
    required Uint8List imageBytes,
  }) async {
    state = state.copyWith(
      flow: BiometricFlow.sendingToApi,
      clearError: true,
    );

    final result = await _faceService.attendanceCheckIn(
      employeeId: employeeId,
      imageBytes: imageBytes,
    );

    if (result.success) {
      state = state.copyWith(
        flow: BiometricFlow.success,
        checkInResult: result,
      );
    } else {
      state = state.copyWith(
        flow: BiometricFlow.error,
        errorMessage: result.errorMessage ?? 'Check-in failed.',
      );
    }
  }

  /// Register face for enrollment.
  Future<void> registerFace({
    required String employeeId,
    required Uint8List imageBytes,
  }) async {
    state = state.copyWith(
      flow: BiometricFlow.sendingToApi,
      clearError: true,
    );

    final result = await _faceService.registerFace(
      employeeId: employeeId,
      imageBytes: imageBytes,
    );

    if (result.success) {
      state = state.copyWith(
        flow: BiometricFlow.success,
        enrollResult: result,
      );
    } else {
      state = state.copyWith(
        flow: BiometricFlow.error,
        errorMessage: result.errorMessage ?? 'Registration failed.',
      );
    }
  }

  void reset() {
    state = const BiometricState();
  }
}

// ── Providers ──

final faceRecognitionServiceProvider = Provider<FaceRecognitionService>((ref) {
  return FaceRecognitionService();
});

final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  return BiometricNotifier(ref.watch(faceRecognitionServiceProvider));
});
