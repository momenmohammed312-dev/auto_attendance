// session_repository.dart
// -----------------------
// Repository الخاص بالدكتور/المحاضر - مسؤول عن كل العمليات المتعلقة
// بجلسات الحضور مع الـ API

import 'package:dio/dio.dart';
import 'models/session_model.dart';
import 'models/live_attendance_item.dart';
import 'package:auto_attendace/core/utils/constants.dart';
import 'package:auto_attendace/core/network/api_client.dart';

class SessionRepository {
  final Dio _dio;

  SessionRepository({Dio? dio})
      : _dio = dio ?? ApiClient().backendDio;

  // ═══════════════════════════════════════════════════════════════════════════
  // Session Management
  // ═══════════════════════════════════════════════════════════════════════════

  Future<SessionModel> createSession({
    required String lecturerId,
    required String subjectName,
    required String subjectCode,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}/sessions',
        data: {
          'lecturer_id': lecturerId,
          'subject_name': subjectName,
          'subject_code': subjectCode,
          'latitude': latitude,
          'longitude': longitude,
          'radius_meters': radiusMeters,
        },
      );
      if (response.statusCode == 201) {
        return SessionModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 500));
    return SessionModel(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      lecturerId: lecturerId,
      subjectName: subjectName,
      subjectCode: subjectCode,
      startTime: DateTime.now(),
      endTime: null,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      isActive: true,
      totalStudents: 10,
      presentCount: 0,
    );
  }

  Future<SessionModel> getSession(String sessionId) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/sessions/$sessionId');
      if (response.statusCode == 200) {
        return SessionModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Session not found');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<SessionModel>> getLecturerSessions(String lecturerId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/sessions',
        queryParameters: {'lecturer_id': lecturerId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((item) => SessionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch sessions');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<SessionModel> closeSession(String sessionId) async {
    try {
      final response = await _dio.patch('${AppConstants.baseUrl}/sessions/$sessionId/close');
      if (response.statusCode == 200) {
        return SessionModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}
    throw Exception('Session closed');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Live Attendance Feed
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<LiveAttendanceItem>> getSessionAttendees(String sessionId) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/sessions/$sessionId/attendees');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((item) => LiveAttendanceItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> updateSessionRadius({
    required String sessionId,
    required double newRadiusMeters,
  }) async {
    try {
      await _dio.patch(
        '${AppConstants.baseUrl}/sessions/$sessionId/radius',
        data: {'radius_meters': newRadiusMeters},
      );
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Error Handling
  // ═══════════════════════════════════════════════════════════════════════════

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Check your internet connection.');
      case DioExceptionType.connectionError:
        return Exception('Cannot connect to server. Try again later.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return Exception('Unauthorized. Please login again.');
        if (statusCode == 404) return Exception('Resource not found.');
        if (statusCode == 500) return Exception('Server error. Try again later.');
        return Exception('Server error: $statusCode');
      default:
        return Exception('Unexpected error: ${e.message}');
    }
  }
}
