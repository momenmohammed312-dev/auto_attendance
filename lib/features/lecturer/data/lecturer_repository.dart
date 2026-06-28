// lecturer_repository.dart
// -----------------------
// Repository الخاص بالدكتور - مسؤول عن كل العمليات المتعلقة
// ببيانات الدكتور والمواد والطلاب مع الـ API

import 'package:dio/dio.dart';
import 'models/lecturer_model.dart';
import 'models/course_model.dart';
import 'package:auto_attendace/core/network/api_client.dart';

class LecturerRepository {
  final Dio _dio;

  LecturerRepository({Dio? dio})
      : _dio = dio ?? ApiClient().backendDio;

  // ═══════════════════════════════════════════════════════════════════════════
  // Lecturer Operations
  // ═══════════════════════════════════════════════════════════════════════════

  Future<LecturerModel> getLecturer(String lecturerId) async {
    try {
      // استخدام بيانات تجريبية لأن الـ API لا يحتوي على endpoint للدكاترة
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (lecturerId == 'dr_ahmed_mohamed') {
        return LecturerModel(
          id: 'dr_ahmed_mohamed',
          name: 'د. أحمد محمد',
          email: 'ahmed.mohamed@university.edu',
          department: 'علوم الحاسب',
          phone: '+201234567890',
          office: 'مبنى الحاسب - 302',
          courseIds: ['cs101', 'cs201', 'cs301'],
          studentIds: ['st_001', 'st_002', 'st_003', 'st_004', 'st_005', 'st_006'],
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
        );
      }
      
      throw Exception('Lecturer not found');
    } catch (e) {
      throw Exception('Error fetching lecturer: $e');
    }
  }

  Future<List<LecturerModel>> getAllLecturers() async {
    try {
      // استخدام بيانات تجريبية
      await Future.delayed(const Duration(milliseconds: 500));
      
      return [
        LecturerModel(
          id: 'dr_ahmed_mohamed',
          name: 'د. أحمد محمد',
          email: 'ahmed.mohamed@university.edu',
          department: 'علوم الحاسب',
          phone: '+201234567890',
          office: 'مبنى الحاسب - 302',
          courseIds: ['cs101', 'cs201', 'cs301'],
          studentIds: ['st_001', 'st_002', 'st_003', 'st_004', 'st_005', 'st_006'],
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
        ),
      ];
    } catch (e) {
      throw Exception('Error fetching lecturers: $e');
    }
  }

  Future<List<CourseModel>> getLecturerCourses(String lecturerId) async {
    try {
      // استخدام بيانات تجريبية
      await Future.delayed(const Duration(milliseconds: 500));
      
      return [
        CourseModel(
          id: 'cs101',
          code: 'CS101',
          name: 'مقدمة في البرمجة',
          description: 'أساسيات البرمجة بلغة Python',
          lecturerId: lecturerId,
          creditHours: 3,
          semester: 'الفصل الأول',
          year: 2024,
          studentIds: ['st_001', 'st_002', 'st_003', 'st_006'],
          createdAt: DateTime.now().subtract(const Duration(days: 180)),
        ),
        CourseModel(
          id: 'cs201',
          code: 'CS201',
          name: 'هياكل البيانات',
          description: 'دراسة هياكل البيانات المختلفة والخوارزميات',
          lecturerId: lecturerId,
          creditHours: 4,
          semester: 'الفصل الثاني',
          year: 2024,
          studentIds: ['st_002', 'st_003', 'st_004'],
          createdAt: DateTime.now().subtract(const Duration(days: 120)),
        ),
        CourseModel(
          id: 'cs301',
          code: 'CS301',
          name: 'قواعد البيانات',
          description: 'تصميم وإدارة قواعد البيانات العلائقية',
          lecturerId: lecturerId,
          creditHours: 3,
          semester: 'الفصل الأول',
          year: 2025,
          studentIds: ['st_003', 'st_004', 'st_005'],
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
      ];
    } catch (e) {
      throw Exception('Error fetching lecturer courses: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLecturerStudents(String lecturerId) async {
    try {
      // محاولة استخدام الـ API الحقيقي للطلاب
      final response = await _dio.get('/students');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (_) {
      // API فشل، نستخدم البيانات التجريبية
    }

    // بيانات تجريبية للطلاب
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': 'st_001', 'name': 'محمد أحمد علي', 'email': 'mohamed.ali@university.edu', 'department': 'علوم الحاسب', 'year': 1},
      {'id': 'st_002', 'name': 'فاطمة محمود حسن', 'email': 'fatima.hassan@university.edu', 'department': 'علوم الحاسب', 'year': 2},
      {'id': 'st_003', 'name': 'عمر خالد إبراهيم', 'email': 'omar.ibrahim@university.edu', 'department': 'علوم الحاسب', 'year': 3},
      {'id': 'st_004', 'name': 'نورة سعيد عبدالله', 'email': 'noura.abdullah@university.edu', 'department': 'علوم الحاسب', 'year': 4},
      {'id': 'st_005', 'name': 'يوسف أحمد محمود', 'email': 'youssef.mahmoud@university.edu', 'department': 'علوم الحاسب', 'year': 4},
      {'id': 'st_006', 'name': 'مؤمن محمد', 'email': 'momen.mohamed@university.edu', 'department': 'علوم الحاسب', 'year': 1},
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Course Operations
  // ═══════════════════════════════════════════════════════════════════════════

  Future<CourseModel> getCourse(String courseId) async {
    try {
      // استخدام بيانات تجريبية لأن الـ API لا يحتوي على endpoint للكورس
      await Future.delayed(const Duration(milliseconds: 500));
      
      final courses = await getLecturerCourses('dr_ahmed_mohamed');
      final course = courses.firstWhere(
        (c) => c.id == courseId,
        orElse: () => throw Exception('Course not found'),
      );
      
      return course;
    } catch (e) {
      throw Exception('Error fetching course: $e');
    }
  }

  Future<List<CourseModel>> getAllCourses() async {
    try {
      // استخدام بيانات تجريبية
      return await getLecturerCourses('dr_ahmed_mohamed');
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCourseStudents(String courseId) async {
    try {
      // محاولة استخدام الـ API الحقيقي للطلاب
      final response = await _dio.get('/students');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (_) {
      // API فشل، نستخدم البيانات التجريبية
    }

    // بيانات تجريبية للطلاب
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': 'st_001', 'name': 'محمد أحمد علي', 'email': 'mohamed.ali@university.edu', 'department': 'علوم الحاسب', 'year': 1},
      {'id': 'st_002', 'name': 'فاطمة محمود حسن', 'email': 'fatima.hassan@university.edu', 'department': 'علوم الحاسب', 'year': 2},
      {'id': 'st_003', 'name': 'عمر خالد إبراهيم', 'email': 'omar.ibrahim@university.edu', 'department': 'علوم الحاسب', 'year': 3},
      {'id': 'st_004', 'name': 'نورة سعيد عبدالله', 'email': 'noura.abdullah@university.edu', 'department': 'علوم الحاسب', 'year': 4},
      {'id': 'st_005', 'name': 'يوسف أحمد محمود', 'email': 'youssef.mahmoud@university.edu', 'department': 'علوم الحاسب', 'year': 4},
      {'id': 'st_006', 'name': 'مؤمن محمد', 'email': 'momen.mohamed@university.edu', 'department': 'علوم الحاسب', 'year': 1},
    ];
  }
}
