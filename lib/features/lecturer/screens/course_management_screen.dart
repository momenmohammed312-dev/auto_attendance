import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import 'doctor_monitor_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  int _selectedFilter = 0;
  final _searchController = TextEditingController();
  final _filters = ['All', 'Active', 'Upcoming'];

  final List<Map<String, dynamic>> _courses = [
    {
      'code': 'CS101',
      'name': 'Introduction to Computer Science',
      'description': 'Fundamental principles of computation and algorithm design',
      'students': 124,
      'duration': '2h 30m',
      'attendanceRate': 89,
      'status': 'active',
      'color': AppColors.primary,
    },
    {
      'code': 'MA302',
      'name': 'Advanced Linear Algebra',
      'description': 'Matrix theory, vector spaces, and linear transformations',
      'students': 87,
      'duration': '1h 45m',
      'attendanceRate': 92,
      'status': 'active',
      'color': AppColors.teal,
    },
    {
      'code': 'CS405',
      'name': 'Neural Networks',
      'description': 'Deep learning architectures and training methodologies',
      'students': 65,
      'duration': '2h 30m',
      'attendanceRate': 98,
      'status': 'active',
      'color': AppColors.accent,
    },
    {
      'code': 'CS110',
      'name': 'Data Structures',
      'description': 'Arrays, linked lists, trees, graphs, and algorithms',
      'students': 156,
      'duration': '2h 00m',
      'attendanceRate': 85,
      'status': 'upcoming',
      'color': AppColors.warning,
    },
    {
      'code': 'REG601',
      'name': 'Quantum Computing Ethics',
      'description': 'Ethical implications of quantum computing technologies',
      'students': 42,
      'duration': '1h 30m',
      'attendanceRate': 78,
      'status': 'upcoming',
      'color': AppColors.danger,
    },
  ];

  List<Map<String, dynamic>> get _filteredCourses {
    if (_selectedFilter == 0) return _courses;
    final status = _selectedFilter == 1 ? 'active' : 'upcoming';
    return _courses.where((c) => c['status'] == status).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildFilterTabs(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCourses.length,
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCourseCard(_filteredCourses[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search courses...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _filters[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (course['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    course['code'].toString().substring(0, 2),
                    style: TextStyle(
                      color: course['color'] as Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course['code']}: ${course['name']}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course['description'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCourseMeta(Icons.people_outline, '${course['students']} Students'),
              const SizedBox(width: 16),
              _buildCourseMeta(Icons.access_time, course['duration'] as String),
              const Spacer(),
              _buildAttendanceBadge(course['attendanceRate'] as int),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorMonitorScreen(
                      subjectName: '${course['code']}: ${course['name']}',
                      subjectCode: course['code'] as String,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text(
                'Start Attendance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceBadge(int rate) {
    final color = rate >= 90
        ? AppColors.success
        : rate >= 75
            ? AppColors.warning
            : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$rate%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
