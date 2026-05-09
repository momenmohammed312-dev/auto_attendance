import 'package:auto_attendace/features/student/data/models/attendance_record.dart';
import 'package:auto_attendace/features/student/data/models/schedule_item.dart';
import 'package:auto_attendace/features/student/data/models/subject_attendance.dart';

/// Repository for fetching student-related data from the API.
///
/// Currently uses mock data for testing. Will connect to real API endpoints
/// when backend is ready.
///
/// Methods:
/// - [getAttendanceForSubject]: Fetches attendance records for a specific subject
/// - [getSubjectAttendanceSummary]: Fetches summary for all subjects
/// - [getTodaySchedule]: Fetches today's lecture schedule
/// - [getAttendanceStatistics]: Fetches overall statistics for reports
class StudentRepository {
  final String baseUrl = 'https://api.university.edu/student';
  static final StudentRepository _instance = StudentRepository._internal();
  factory StudentRepository() => _instance;
  StudentRepository._internal();

  /// Fetches attendance records for a specific subject.
  ///
  /// Returns a list of [AttendanceRecord] containing the student's
  /// attendance history for the given subject.
  Future<List<AttendanceRecord>> getAttendanceForSubject(
    String subjectId,
  ) async {
    try {
      // TODO: لما الـ API يكون جاهز، فك التعليق ده
      // final response = await http.get(
      //   Uri.parse('$baseUrl/attendance/$subjectId'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      //
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => AttendanceRecord.fromJson(json)).toList();
      // } else {
      //   throw Exception('فشل في تحميل البيانات: ${response.statusCode}');
      // }

      // دلوقتي: Mock Data للاختبار
      await Future.delayed(const Duration(seconds: 1)); // محاكاة الانتظار

      return [
        AttendanceRecord(
          id: '1',
          subjectId: subjectId,
          subjectName: 'Physics 101',
          date: DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          status: 'present',
          checkedInTime: '09:05',
          room: 'Hall A2',
          verificationMethod: 'biometric',
        ),
        AttendanceRecord(
          id: '2',
          subjectId: subjectId,
          subjectName: 'Physics 101',
          date: DateTime.now()
              .subtract(const Duration(days: 5))
              .toIso8601String(),
          status: 'present',
          checkedInTime: '08:58',
          room: 'Hall A2',
          verificationMethod: 'biometric',
        ),
      ];
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  /// Fetches attendance summary for all subjects.
  ///
  /// Returns a list of [SubjectAttendance] used in the dashboard
  /// to display subject-wise attendance statistics.
  Future<List<SubjectAttendance>> getSubjectAttendanceSummary() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock Data - نفس اللي في الـ Figma
      return [
        SubjectAttendance(
          subjectId: 'phys101',
          subjectName: 'Physics',
          totalLectures: 25,
          attendedLectures: 23,
          missedLectures: 2,
          attendancePercentage: 92.0,
          colorHex: '#2E5BFF', // أزرق
        ),
        SubjectAttendance(
          subjectId: 'hist201',
          subjectName: 'History',
          totalLectures: 18,
          attendedLectures: 14,
          missedLectures: 4,
          attendancePercentage: 78.0,
          colorHex: '#F59E0B', // برتقالي
        ),
        SubjectAttendance(
          subjectId: 'eng102',
          subjectName: 'English',
          totalLectures: 20,
          attendedLectures: 17,
          missedLectures: 3,
          attendancePercentage: 85.0,
          colorHex: '#22C55E', // أخضر
        ),
      ];
    } catch (e) {
      throw Exception('خطأ في تحميل ملخص المواد: $e');
    }
  }

  /// Fetches today's lecture schedule.
  ///
  /// Returns a list of [ScheduleItem] representing the student's
  /// lectures for the current day with time, room, and status.
  Future<List<ScheduleItem>> getTodaySchedule() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();

      return [
        ScheduleItem(
          id: '1',
          subjectName: 'Computer Science 101',
          subjectCode: 'CS101',
          startTime: DateTime(now.year, now.month, now.day, 9, 0),
          endTime: DateTime(now.year, now.month, now.day, 10, 30),
          room: 'Lab 4B',
          status: 'ongoing', // شغالة دلوقتي
          instructorName: 'Dr. Smith',
        ),
        ScheduleItem(
          id: '2',
          subjectName: 'Modern History',
          subjectCode: 'HIST201',
          startTime: DateTime(now.year, now.month, now.day, 11, 0),
          endTime: DateTime(now.year, now.month, now.day, 12, 30),
          room: 'Hall A2',
          status: 'upcoming', // جاية
          instructorName: 'Prof. Johnson',
        ),
        ScheduleItem(
          id: '3',
          subjectName: 'Advanced Calculus',
          subjectCode: 'MATH301',
          startTime: DateTime(now.year, now.month, now.day, 14, 0),
          endTime: DateTime(now.year, now.month, now.day, 15, 30),
          room: 'Room 302',
          status: 'upcoming',
          instructorName: 'Dr. Williams',
        ),
      ];
    } catch (e) {
      throw Exception('خطأ في تحميل الجدول: $e');
    }
  }

  /// Fetches overall attendance statistics for reports.
  ///
  /// Returns a map containing overall percentage, total lectures,
  /// attended count, missed count, and monthly trend.
  Future<Map<String, dynamic>> getAttendanceStatistics() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      return {
        'overall_percentage': 94.2,
        'total_lectures': 150,
        'attended_lectures': 142,
        'missed_lectures': 8,
        'monthly_trend': 2.4, // +2.4% عن الشهر اللي فات
      };
    } catch (e) {
      throw Exception('خطأ في تحميل الإحصائيات: $e');
    }
  }
}
