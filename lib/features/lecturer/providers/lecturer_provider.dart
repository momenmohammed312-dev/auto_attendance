// lecturer_provider.dart
// ---------------------
// Provider لإدارة حالة بيانات الدكتور والمواد والطلاب

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/lecturer_model.dart';
import '../data/models/course_model.dart';
import '../data/lecturer_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Repository Provider
// ═══════════════════════════════════════════════════════════════════════════

final lecturerRepositoryProvider = Provider<LecturerRepository>((ref) {
  return LecturerRepository();
});

// ═══════════════════════════════════════════════════════════════════════════
// Lecturer State
// ═══════════════════════════════════════════════════════════════════════════

class LecturerState {
  final LecturerModel? lecturer;
  final List<CourseModel> courses;
  final List<Map<String, dynamic>> students;
  final bool isLoading;
  final String? error;

  const LecturerState({
    this.lecturer,
    this.courses = const [],
    this.students = const [],
    this.isLoading = false,
    this.error,
  });

  LecturerState copyWith({
    LecturerModel? lecturer,
    List<CourseModel>? courses,
    List<Map<String, dynamic>>? students,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LecturerState(
      lecturer: lecturer ?? this.lecturer,
      courses: courses ?? this.courses,
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Lecturer Notifier
// ═══════════════════════════════════════════════════════════════════════════

class LecturerNotifier extends StateNotifier<LecturerState> {
  final LecturerRepository _repository;

  LecturerNotifier(this._repository) : super(const LecturerState());

  Future<void> loadLecturer(String lecturerId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lecturer = await _repository.getLecturer(lecturerId);
      state = state.copyWith(lecturer: lecturer, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadLecturerCourses(String lecturerId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final courses = await _repository.getLecturerCourses(lecturerId);
      state = state.copyWith(courses: courses, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadLecturerStudents(String lecturerId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final students = await _repository.getLecturerStudents(lecturerId);
      state = state.copyWith(students: students, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadAllLecturerData(String lecturerId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repository.getLecturer(lecturerId),
        _repository.getLecturerCourses(lecturerId),
        _repository.getLecturerStudents(lecturerId),
      ]);
      state = state.copyWith(
        lecturer: results[0] as LecturerModel,
        courses: results[1] as List<CourseModel>,
        students: results[2] as List<Map<String, dynamic>>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // بيانات تجريبية للدكتور
  void loadMockLecturer() {
    final mockLecturer = LecturerModel(
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

    final mockCourses = [
      CourseModel(
        id: 'cs101',
        code: 'CS101',
        name: 'مقدمة في البرمجة',
        description: 'أساسيات البرمجة بلغة Python',
        lecturerId: 'dr_ahmed_mohamed',
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
        lecturerId: 'dr_ahmed_mohamed',
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
        lecturerId: 'dr_ahmed_mohamed',
        creditHours: 3,
        semester: 'الفصل الأول',
        year: 2025,
        studentIds: ['st_003', 'st_004', 'st_005'],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    final mockStudents = [
      {
        'id': 'st_001',
        'name': 'محمد أحمد علي',
        'email': 'mohamed.ali@university.edu',
        'department': 'علوم الحاسب',
        'year': 1,
      },
      {
        'id': 'st_002',
        'name': 'فاطمة محمود حسن',
        'email': 'fatima.hassan@university.edu',
        'department': 'علوم الحاسب',
        'year': 2,
      },
      {
        'id': 'st_003',
        'name': 'عمر خالد إبراهيم',
        'email': 'omar.ibrahim@university.edu',
        'department': 'علوم الحاسب',
        'year': 3,
      },
      {
        'id': 'st_004',
        'name': 'نورة سعيد عبدالله',
        'email': 'noura.abdullah@university.edu',
        'department': 'علوم الحاسب',
        'year': 4,
      },
      {
        'id': 'st_005',
        'name': 'يوسف أحمد محمود',
        'email': 'youssef.mahmoud@university.edu',
        'department': 'علوم الحاسب',
        'year': 4,
      },
      {
        'id': 'st_006',
        'name': 'مؤمن محمد',
        'email': 'momen.mohamed@university.edu',
        'department': 'علوم الحاسب',
        'year': 1,
      },
    ];

    state = state.copyWith(
      lecturer: mockLecturer,
      courses: mockCourses,
      students: mockStudents,
      isLoading: false,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Lecturer Provider
// ═══════════════════════════════════════════════════════════════════════════

final lecturerProvider = StateNotifierProvider<LecturerNotifier, LecturerState>((ref) {
  final repository = ref.watch(lecturerRepositoryProvider);
  return LecturerNotifier(repository);
});
