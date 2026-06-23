// ============================================================
// EXCUSE REQUEST SCREEN - Complete Implementation
// ============================================================

// Flutter core imports
import 'package:flutter/material.dart';

// Riverpod for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Color utility
import '../../../core/utils/color_utils.dart';

// Data models
import '../data/models/excuse_request.dart';
import '../data/models/schedule_item.dart';

// Riverpod providers for state management
// import '../providers/student_provider.dart'; // Not used yet

// Shared/reusable widgets
// import '../../../shared/widgets/app_bottom_nav.dart'; // Not used in this screen
// import '../../../shared/widgets/app_top_bar.dart'; // Not used in this screen

// App router for navigation
// import '../../../router/app_router.dart'; // Not used in this screen

/// Excuse Request Screen - Allows students to submit excuses for absences
///
/// Features:
/// - Select lecture to excuse
/// - Choose excuse type
/// - Write detailed reason
/// - Attach supporting documents
/// - Submit request
/// - View request status
class ExcuseRequestScreen extends ConsumerStatefulWidget {
  /// Creates the excuse request screen
  const ExcuseRequestScreen({super.key});

  @override
  ConsumerState<ExcuseRequestScreen> createState() =>
      _ExcuseRequestScreenState();
}

/// State class for the excuse request screen
class _ExcuseRequestScreenState extends ConsumerState<ExcuseRequestScreen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Selected lecture to excuse
  ScheduleItem? _selectedLecture;

  /// Selected excuse type
  ExcuseType _selectedExcuseType = ExcuseType.medical;

  /// Reason text controller
  final _reasonController = TextEditingController();

  /// Currently selected tab (0: New Request, 1: History)
  int _currentTab = 0;

  /// List of recent excuse requests
  List<ExcuseRequest> _recentRequests = [];

  /// Is currently submitting a request
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadRecentRequests();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Loads recent excuse requests
  Future<void> _loadRecentRequests() async {
    // TODO: Load actual data from repository
    setState(() {
      _recentRequests = [
        ExcuseRequest(
          id: '1',
          lectureId: 'lec1',
          subjectName: 'Computer Science 101',
          lectureDate: DateTime.now().subtract(const Duration(days: 7)),
          reason: 'Medical appointment',
          excuseType: ExcuseType.medical,
          status: ExcuseStatus.approved,
          submittedAt: DateTime.now().subtract(const Duration(days: 7)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 6)),
          reviewerComments: 'Approved with medical documentation',
        ),
        ExcuseRequest(
          id: '2',
          lectureId: 'lec2',
          subjectName: 'Mathematics 202',
          lectureDate: DateTime.now().subtract(const Duration(days: 3)),
          reason: 'Family emergency',
          excuseType: ExcuseType.family,
          status: ExcuseStatus.pending,
          submittedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
    });
  }

  /// Builds the complete excuse request UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Request Excuse'),
        backgroundColor: const Color(0xFF2E5BFF),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: [_buildNewRequestTab(), _buildHistoryTab()],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the tab bar for switching between new request and history
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _currentTab == 0
                      ? const Color(0xFF2E5BFF)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                  ),
                ),
                child: Text(
                  'New Request',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _currentTab == 0 ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _currentTab == 1
                      ? const Color(0xFF2E5BFF)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: Text(
                  'Request History',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _currentTab == 1 ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the new request form tab
  Widget _buildNewRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lecture Selection
            _buildSectionTitle('Select Lecture'),
            const SizedBox(height: 12),
            _buildLectureSelector(),
            const SizedBox(height: 24),

            // Excuse Type Selection
            _buildSectionTitle('Excuse Type'),
            const SizedBox(height: 12),
            _buildExcuseTypeSelector(),
            const SizedBox(height: 24),

            // Reason Input
            _buildSectionTitle('Reason for Absence'),
            const SizedBox(height: 12),
            _buildReasonInput(),
            const SizedBox(height: 24),

            // Document Attachment (Optional)
            _buildSectionTitle('Supporting Document (Optional)'),
            const SizedBox(height: 12),
            _buildDocumentAttachment(),
            const SizedBox(height: 32),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the request history tab
  Widget _buildHistoryTab() {
    if (_recentRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No excuse requests yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Submit your first excuse request',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _recentRequests.length,
      itemBuilder: (context, index) {
        final request = _recentRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  /// Builds a section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  /// Builds the lecture selector dropdown
  Widget _buildLectureSelector() {
    // Mock data for recent lectures
    final now = DateTime.now();
    final recentLectures = [
      ScheduleItem(
        id: '1',
        subjectName: 'Computer Science 101',
        subjectCode: 'CS101',
        startTime: DateTime(now.year, now.month, now.day, 10, 0),
        endTime: DateTime(now.year, now.month, now.day, 11, 30),
        room: 'Room 201',
        status: 'scheduled',
      ),
      ScheduleItem(
        id: '2',
        subjectName: 'Mathematics 202',
        subjectCode: 'MATH202',
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 30),
        room: 'Room 105',
        status: 'scheduled',
      ),
      ScheduleItem(
        id: '3',
        subjectName: 'Physics 101',
        subjectCode: 'PHYS101',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 10, 30),
        room: 'Lab 3',
        status: 'scheduled',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ScheduleItem>(
          hint: const Text('Select a lecture'),
          value: _selectedLecture,
          isExpanded: true,
          items: recentLectures.map((lecture) {
            return DropdownMenuItem<ScheduleItem>(
              value: lecture,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lecture.subjectName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${lecture.timeRange} • ${lecture.room}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLecture = value;
            });
          },
        ),
      ),
    );
  }

  /// Builds the excuse type selector
  Widget _buildExcuseTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ExcuseType.values.map((type) {
        final isSelected = _selectedExcuseType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedExcuseType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2E5BFF) : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? const Color(0xFF2E5BFF) : Colors.grey[300]!,
              ),
            ),
            child: Text(
              type.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the reason input field
  Widget _buildReasonInput() {
    return TextFormField(
      controller: _reasonController,
      maxLines: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please provide a reason for your absence';
        }
        if (value.trim().length < 10) {
          return 'Please provide more details (at least 10 characters)';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Please explain why you missed this lecture...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E5BFF)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  /// Builds the document attachment section
  Widget _buildDocumentAttachment() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Attach Document',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: _pickDocument, child: const Text('Browse')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PDF, JPG, or PNG files (Max 5MB)',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E5BFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  /// Builds a request card for the history tab
  Widget _buildRequestCard(ExcuseRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.subjectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tryColorFromHex(request.status.colorHex),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${_formatDate(request.lectureDate)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Type: ${request.excuseType.displayName}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(request.reason, style: const TextStyle(fontSize: 14)),
          if (request.reviewerComments != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Reviewer: ${request.reviewerComments}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Submitted: ${_formatDate(request.submittedAt)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Handles document picking
  Future<void> _pickDocument() async {
    // TODO: Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File picker will be implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Submits the excuse request
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLecture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a lecture'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create new excuse request
      final newRequest = ExcuseRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lectureId: 'lec_${DateTime.now().millisecondsSinceEpoch}',
        subjectName: _selectedLecture!.subjectName,
        lectureDate: DateTime.now().subtract(
          const Duration(days: 1),
        ), // Mock date
        reason: _reasonController.text.trim(),
        excuseType: _selectedExcuseType,
        status: ExcuseStatus.pending,
        submittedAt: DateTime.now(),
      );

      // TODO: Submit to repository
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Add to recent requests
      setState(() {
        _recentRequests.insert(0, newRequest);
        _isSubmitting = false;
      });

      // Clear form
      _formKey.currentState?.reset();
      _reasonController.clear();
      _selectedLecture = null;
      _selectedExcuseType = ExcuseType.medical;

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excuse request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Switch to history tab
      setState(() {
        _currentTab = 1;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
