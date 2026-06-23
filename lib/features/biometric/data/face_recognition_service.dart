import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class FaceEnrollResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const FaceEnrollResult({
    required this.success,
    this.message,
    this.errorMessage,
  });
}

class FaceVerifyResult {
  final bool matched;
  final double confidence;
  final String? employeeId;
  final String? errorMessage;

  const FaceVerifyResult({
    required this.matched,
    this.confidence = 0.0,
    this.employeeId,
    this.errorMessage,
  });
}

class LivenessResult {
  final bool isLive;
  final double? spoofProbability;
  final String? errorMessage;

  const LivenessResult({
    required this.isLive,
    this.spoofProbability,
    this.errorMessage,
  });
}

class AttendanceCheckInResult {
  final bool success;
  final String? status;
  final String? employeeId;
  final String? message;
  final String? errorMessage;

  const AttendanceCheckInResult({
    required this.success,
    this.status,
    this.employeeId,
    this.message,
    this.errorMessage,
  });
}

class FaceRecognitionService {
  final ApiClient _client;

  FaceRecognitionService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Register a face for an employee.
  ///
  /// POST /register-face/{employee_id} with multipart image file.
  Future<FaceEnrollResult> registerFace({
    required String employeeId,
    required Uint8List imageBytes,
    String fileName = 'face_register.jpg',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      final response = await _client.mlUpload(
        ApiEndpoints.mlRegisterFaceById(employeeId),
        formData: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return FaceEnrollResult(
          success: true,
          message: data['message']?.toString() ?? data['detail']?.toString(),
        );
      }
      return const FaceEnrollResult(success: true);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail']
          ?? e.response?.data?['message']
          ?? 'Registration failed. Please try again.';
      return FaceEnrollResult(success: false, errorMessage: errorMsg.toString());
    } catch (e) {
      return FaceEnrollResult(success: false, errorMessage: 'Unexpected error: $e');
    }
  }

  /// Attendance check-in with face verification.
  ///
  /// POST /attendance/check-in/{employee_id} — does detect + liveness + recognize in one call.
  Future<AttendanceCheckInResult> attendanceCheckIn({
    required String employeeId,
    required Uint8List imageBytes,
    String fileName = 'checkin.jpg',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      final response = await _client.mlUpload(
        ApiEndpoints.mlAttendanceCheckInById(employeeId),
        formData: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AttendanceCheckInResult(
          success: true,
          status: data['status']?.toString(),
          employeeId: data['employee_id']?.toString() ?? data['student_id']?.toString(),
          message: data['message']?.toString() ?? data['detail']?.toString(),
        );
      }
      return const AttendanceCheckInResult(success: true);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail']
          ?? e.response?.data?['message']
          ?? 'Check-in failed. Please try again.';
      return AttendanceCheckInResult(success: false, errorMessage: errorMsg.toString());
    } catch (e) {
      return AttendanceCheckInResult(success: false, errorMessage: 'Unexpected error: $e');
    }
  }

  /// Recognize a face (without attendance check-in).
  ///
  /// POST /recognize-face with multipart image file.
  Future<FaceVerifyResult> recognizeFace({
    required Uint8List imageBytes,
    String fileName = 'recognize.jpg',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      final response = await _client.mlUpload(
        ApiEndpoints.mlRecognizeFace,
        formData: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final matched = data['matched'] ?? data['recognized'] ?? false;
        return FaceVerifyResult(
          matched: matched == true,
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
          employeeId: data['employee_id']?.toString() ?? data['student_id']?.toString(),
        );
      }
      return const FaceVerifyResult(matched: false);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail']
          ?? e.response?.data?['message']
          ?? 'Recognition failed. Please try again.';
      return FaceVerifyResult(matched: false, errorMessage: errorMsg.toString());
    } catch (e) {
      return FaceVerifyResult(matched: false, errorMessage: 'Unexpected error: $e');
    }
  }

  /// Liveness check to detect spoofing.
  ///
  /// POST /liveness-check with multipart image file.
  Future<LivenessResult> checkLiveness({
    required Uint8List imageBytes,
    String fileName = 'liveness.jpg',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      final response = await _client.mlUpload(
        ApiEndpoints.mlLivenessCheck,
        formData: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final isLive = data['is_live'] ?? data['live'] ?? false;
        return LivenessResult(
          isLive: isLive == true,
          spoofProbability: (data['spoof_probability'] as num?)?.toDouble(),
        );
      }
      return const LivenessResult(isLive: false);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail']
          ?? e.response?.data?['message']
          ?? 'Liveness check failed.';
      return LivenessResult(isLive: false, errorMessage: errorMsg.toString());
    } catch (e) {
      return LivenessResult(isLive: false, errorMessage: 'Unexpected error: $e');
    }
  }

  /// Detect if a face exists in the image.
  ///
  /// POST /detect-face with multipart image file.
  Future<bool> detectFace({
    required Uint8List imageBytes,
    String fileName = 'detect.jpg',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      final response = await _client.mlUpload(
        ApiEndpoints.mlDetectFace,
        formData: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['face_detected'] == true || data['detected'] == true;
      }
      return false;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check ML API health.
  Future<bool> checkHealth() async {
    try {
      final response = await _client.mlGet(ApiEndpoints.mlHealth);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
