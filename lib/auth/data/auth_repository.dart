import 'package:dio/dio.dart';
import 'package:auto_attendace/auth/data/model/login_request.dart';
import 'package:auto_attendace/auth/data/model/user_model.dart';
import 'package:auto_attendace/core/network/api_client.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository({Dio? dio}) : _dio = dio ?? ApiClient().backendDio;

  final List<Map<String, dynamic>> _mockStudents = [
    {
      'id': 'st_001',
      'full_name': 'محمد أحمد علي',
      'email': 'mohamed.ali@university.edu',
    },
    {
      'id': 'st_002',
      'full_name': 'فاطمة محمود حسن',
      'email': 'fatima.hassan@university.edu',
    },
    {
      'id': 'st_003',
      'full_name': 'عمر خالد إبراهيم',
      'email': 'omar.ibrahim@university.edu',
    },
    {
      'id': 'st_004',
      'full_name': 'نورة سعيد عبدالله',
      'email': 'noura.abdullah@university.edu',
    },
    {
      'id': 'st_005',
      'full_name': 'يوسف أحمد محمود',
      'email': 'youssef.mahmoud@university.edu',
    },
    {
      'id': 'st_006',
      'full_name': 'مؤمن محمد',
      'email': 'momen.mohamed@university.edu',
      'password': '123456',
    },
  ];

  Future<UserModel> login(LoginRequest request) async {
    try {
      if (request.role == 'student') {
        // Try API first, fallback to mock data on failure
        List<Map<String, dynamic>> students = [];

        try {
          final response = await _dio.get('/students');
          if (response.statusCode == 200) {
            students = (response.data as List<dynamic>)
                .map((s) => s as Map<String, dynamic>)
                .toList();
          }
        } catch (_) {
          // API failed, use mock data
        }

        if (students.isEmpty) {
          students = _mockStudents;
          await Future.delayed(const Duration(milliseconds: 500));
        }

        final student = students.firstWhere(
          (s) =>
              (s['id'] as String) == request.studentId ||
              (s['full_name'] as String).contains(request.name) ||
              (s['password'] != null && s['password'] == request.studentId),
          orElse: () => <String, dynamic>{},
        );

        if (student.isNotEmpty) {
          return UserModel(
            id: student['id'] as String,
            name: student['full_name'] as String,
            email: student['email'] as String,
            role: request.role,
          );
        }

        throw Exception('Student not found');
      } else {
        // للدكاترة: استخدام بيانات تجريبية
        await Future.delayed(const Duration(seconds: 1));

        if (request.name.contains('أحمد') || request.name.contains('ahmed')) {
          return UserModel(
            id: 'dr_ahmed_mohamed',
            name: 'د. أحمد محمد',
            email: 'ahmed.mohamed@university.edu',
            role: request.role,
          );
        }

        throw Exception('Doctor not found');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
