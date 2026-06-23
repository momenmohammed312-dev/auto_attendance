// ============================================================
// STUDENT REPORTS SCREEN - Attendance Reports and Statistics
// ============================================================
// This screen displays detailed attendance reports including:
// - Overall attendance statistics (total, attended, missed, percentage)
// - Monthly attendance trends visualization
// - Recent attendance records list
// - Date filtering options
//
// Features:
// - Pull-to-refresh for updated data
// - Visual statistics cards
// - Bar chart for monthly trends
// - Scrollable recent records list
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// add: import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/student_provider.dart';
import '../data/models/attendance_record.dart';

/// Student Reports Screen - Detailed attendance analytics
///
/// Shows comprehensive attendance data including statistics,
/// monthly trends, and recent attendance records.
/// Uses Riverpod for state management.
class StudentReportsScreen extends ConsumerWidget {
  /// Creates the student reports screen
  const StudentReportsScreen({super.key});

  /// Builds the reports screen UI
  ///
  /// [context] - Build context for UI rendering
  /// [ref] - Riverpod widget reference for state access
  /// Returns the complete reports screen widget tree
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch student state from Riverpod provider
    final state = ref.watch(studentProvider);
    final statistics = state.statistics;

    return Scaffold(
      // Light grey background for modern look
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // Filter button in app bar (for date range filtering)
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show date range filter dialog
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        // Pull to refresh data
        onRefresh: () async {
          await ref.read(studentProvider.notifier).loadReports();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Overview Section
              // Shows total lectures, attended, missed, and percentage
              _buildStatisticsOverview(statistics),

              const SizedBox(height: 24),

              // Export Reports Section
              // Allows users to download attendance data in different formats
              _buildExportSection(context),

              const SizedBox(height: 24),

              // Monthly Trend Section
              // Visual representation of attendance over time
              _buildMonthlyTrendSection(context),

              const SizedBox(height: 24),

              // Alerts & Timelines Section
              // Shows upcoming lectures and attendance notifications
              _buildAlertsSection(context),

              const SizedBox(height: 24),

              // Recent Records Section
              // List of latest attendance entries
              _buildRecentRecordsSection(state.recentAttendance),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the export reports section
  ///
  /// Creates dark-themed cards for downloading reports:
  /// - CSV Spreadsheet for data analysis
  /// - PDF Summary for formal records
  ///
  /// [context] - Build context for UI rendering
  /// Returns styled export section with two action buttons
  Widget _buildExportSection(BuildContext context) {
    return Container(
      // Dark background matching the design
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E), // Dark navy background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title and subtitle
          const Text(
            'Generate Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Download academic attendance records\nin professional formats',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // CSV Export Button
          _buildExportButton(
            icon: Icons.table_chart_outlined,
            label: 'CSV Spreadsheet',
            onTap: () {
              // TODO: Implement CSV export functionality
              // Generates CSV file with attendance records for Excel
              _showExportSnackbar(context, 'CSV report downloaded');
            },
          ),

          const SizedBox(height: 10),

          // PDF Export Button
          _buildExportButton(
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF Summary',
            onTap: () {
              // TODO: Implement PDF export functionality
              // Generates PDF report with summary and charts
              _showExportSnackbar(context, 'PDF report downloaded');
            },
          ),
        ],
      ),
    );
  }

  /// Shows a snackbar notification after export action
  ///
  /// [context] - Build context for showing snackbar
  /// [message] - Success message to display
  void _showExportSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E5BFF),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Builds an individual export button
  ///
  /// [icon] - Icon to display on the left
  /// [label] - Button text label
  /// [onTap] - Callback when button is pressed
  /// Returns styled button with icon and download arrow
  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E), // Slightly lighter than background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Export format icon
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            // Button label
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Download arrow icon
            const Icon(Icons.arrow_downward, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  /// Builds the statistics overview cards
  ///
  /// [statistics] - Map containing attendance statistics data
  /// Returns a row of statistic cards showing key metrics
  Widget _buildStatisticsOverview(Map<String, dynamic>? statistics) {
    // Default values if statistics not loaded yet
    final total = statistics?['total_lectures'] ?? 0;
    final attended = statistics?['attended_lectures'] ?? 0;
    final missed = statistics?['missed_lectures'] ?? 0;
    final percentage = statistics?['overall_percentage'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        const Text(
          'Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Statistics cards grid (2x2)
        Row(
          children: [
            // Total Lectures Card
            Expanded(
              child: _buildStatCard(
                title: 'Total',
                value: total.toString(),
                icon: Icons.calendar_today,
                color: const Color(0xFF2E5BFF),
              ),
            ),
            const SizedBox(width: 12),
            // Attended Lectures Card
            Expanded(
              child: _buildStatCard(
                title: 'Attended',
                value: attended.toString(),
                icon: Icons.check_circle,
                color: const Color(0xFF22C55E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Missed Lectures Card
            Expanded(
              child: _buildStatCard(
                title: 'Missed',
                value: missed.toString(),
                icon: Icons.cancel,
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 12),
            // Attendance Percentage Card
            Expanded(
              child: _buildStatCard(
                title: 'Percentage',
                value: '${percentage.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a single statistic card
  ///
  /// [title] - Card label (e.g., "Total", "Attended")
  /// [value] - The numeric value to display
  /// [icon] - Icon to show on the card
  /// [color] - Card accent color
  /// Returns a styled card widget
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with colored background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          // Large value text
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // Title label
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  /// Builds the monthly participation bar chart section
  ///
  /// Displays attendance data as grouped bar chart showing:
  /// - Present lectures (blue bars)
  /// - Absent lectures (red bars)
  /// - Monthly labels (Jan, Feb, Mar, Apr, May)
  ///
  /// Uses fl_chart package for professional visualization.
  /// Data is mock for now - will connect to real API later.
  ///
  /// [context] - Build context for theme access
  /// Returns styled card with legend and bar chart
  Widget _buildMonthlyTrendSection(BuildContext context) {
    // TODO: Replace mock monthly data with real API response
    final monthlyData = [
      {'month': 'Jan', 'present': 18, 'absent': 2},
      {'month': 'Feb', 'present': 20, 'absent': 0},
      {'month': 'Mar', 'present': 16, 'absent': 4},
      {'month': 'Apr', 'present': 22, 'absent': 1},
      {'month': 'May', 'present': 15, 'absent': 3},
    ];

    // Chart colors
    const presentColor = Color(0xFF2E5BFF); // Blue for present
    const absentColor = Color(0xFFE53935); // Red for absent

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with title and legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Monthly Participation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Legend: Present / Absent indicators
            Row(
              children: [
                // Present indicator
                _buildLegendItem('Present', presentColor),
                const SizedBox(width: 12),
                // Absent indicator
                _buildLegendItem('Absent', absentColor),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bar chart container
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              // Grid configuration
              gridData: const FlGridData(show: false),
              // Border configuration
              borderData: FlBorderData(show: false),
              // Bar touch configuration
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final month = monthlyData[groupIndex]['month'] as String;
                    final value = rod.toY.toInt();
                    final label = rodIndex == 0 ? 'Present' : 'Absent';
                    return BarTooltipItem(
                      '$month\n$label: $value',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              // Chart titles (month labels at bottom)
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= monthlyData.length) {
                        return const SizedBox.shrink();
                      }
                      final month =
                          monthlyData[value.toInt()]['month'] as String;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          month,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Bar groups data
              barGroups: List.generate(monthlyData.length, (index) {
                final data = monthlyData[index];
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    // Present bar (left side)
                    BarChartRodData(
                      toY: (data['present'] as int).toDouble(),
                      color: presentColor,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                    // Absent bar (right side)
                    BarChartRodData(
                      toY: (data['absent'] as int).toDouble(),
                      color: absentColor,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
              // Chart range
              maxY: 25,
              minY: 0,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a legend item for the chart
  ///
  /// [label] - Text label (Present/Absent)
  /// [color] - Color indicator for the legend
  /// Returns row with colored dot and label
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        // Colored indicator dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        // Label text
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds the recent attendance records section
  ///
  /// [records] - List of recent attendance records
  /// Returns a column with section title and records list
  Widget _buildRecentRecordsSection(List<AttendanceRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with record count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${records.length} records',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Records list or empty state
        if (records.isEmpty)
          // Empty state when no records available
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No records yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          // List of attendance records
          ...records.take(10).map((record) => _buildRecordItem(record)),
      ],
    );
  }

  /// Builds the alerts and timelines section
  ///
  /// Displays upcoming lectures and recent attendance notifications:
  /// - "Lecture starting in X minutes" with warning icon
  /// - "Attendance record updated" with checkmark icon
  ///
  /// Includes "Mark all as read" action in the header.
  /// Data is mock for now - will connect to notification service later.
  ///
  /// [context] - Build context for UI rendering
  /// Returns styled section with timeline-style alert items
  Widget _buildAlertsSection(BuildContext context) {
    // TODO: Replace mock alerts data with real notifications API
    final alerts = [
      {
        'type': 'upcoming',
        'title': 'Lecture starting in 5 mins',
        'subtitle':
            'CS 402: Neural Networks - Hall 3B\nPlease have your digital ID ready for check-in',
        'time': 'Now',
        'icon': Icons.access_time,
        'iconColor': const Color(0xFFFF9800), // Orange warning
      },
      {
        'type': 'updated',
        'title': 'Attendance record updated',
        'subtitle':
            'Prof. Anderson confirmed your\nattendance for Advanced Programming Lab.',
        'time': '2 hours ago',
        'icon': Icons.check_circle_outline,
        'iconColor': const Color(0xFF22C55E), // Green success
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with title and action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alerts & Timelines',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Mark all as read button
            TextButton(
              onPressed: () {
                // TODO: Mark all notifications as read
                _showExportSnackbar(context, 'All alerts marked as read');
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E5BFF),
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Mark all as read',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Alerts container with timeline styling
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: alerts.asMap().entries.map((entry) {
              final index = entry.key;
              final alert = entry.value;
              final isLast = index == alerts.length - 1;

              return _buildAlertItem(
                icon: alert['icon'] as IconData,
                iconColor: alert['iconColor'] as Color,
                title: alert['title'] as String,
                subtitle: alert['subtitle'] as String,
                time: alert['time'] as String,
                showConnector: !isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Builds a single alert/timeline item
  ///
  /// [icon] - Leading icon for the alert
  /// [iconColor] - Color for the icon and timeline connector
  /// [title] - Alert headline/title
  /// [subtitle] - Detailed description (can be multi-line)
  /// [time] - Timestamp (e.g., "Now", "2 hours ago")
  /// [showConnector] - Whether to show vertical line to next item
  /// Returns timeline-style alert item with optional connector
  Widget _buildAlertItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool showConnector,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline with icon
          Column(
            children: [
              // Icon with colored background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              // Vertical connector line (if not last item)
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: iconColor.withAlpha(77),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Alert content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and time row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Alert title
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Time badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: time == 'Now'
                            ? const Color(0xFFFF9800).withAlpha(26)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: time == 'Now'
                              ? const Color(0xFFFF9800)
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Subtitle with multiple lines support
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                // Bottom spacing (except for last item)
                if (showConnector) const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single attendance record item
  ///
  /// [record] - The attendance record to display
  /// Returns a styled list tile for the record
  Widget _buildRecordItem(AttendanceRecord record) {
    // Determine status color (green for present, red for absent)
    final isPresent = record.status.toLowerCase() == 'present';
    final statusColor = isPresent
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);
    final statusIcon = isPresent ? Icons.check_circle : Icons.cancel;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // Status icon
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        // Subject name
        title: Text(
          record.subjectName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        // Date and room info
        subtitle: Text(
          '${record.date} • ${record.room ?? 'N/A'}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        // Check-in time
        trailing: Text(
          record.checkedInTime,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
