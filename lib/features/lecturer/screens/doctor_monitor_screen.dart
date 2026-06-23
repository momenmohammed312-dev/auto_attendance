/// doctor_monitor_screen.dart
/// --------------------------
/// الشاشة الرئيسية للدكتور - لوحة التحكم في جلسة الحضور
/// بتجمع كل الـ widgets (الخريطة، الـ radius، الـ pulse، والـ live feed)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import '../widgets/geo_map_card.dart';
import '../widgets/radius_slider_card.dart';
import '../widgets/smart_pulse_viz.dart';
import '../widgets/live_feed_item.dart';
import 'package:auto_attendace/auth/providers/auth_provider.dart';
import 'package:auto_attendace/core/app_colors.dart';

class DoctorMonitorScreen extends ConsumerStatefulWidget {
  final String subjectName;
  final String subjectCode;

  const DoctorMonitorScreen({
    super.key,
    required this.subjectName,
    required this.subjectCode,
  });

  @override
  ConsumerState<DoctorMonitorScreen> createState() => _DoctorMonitorScreenState();
}

class _DoctorMonitorScreenState extends ConsumerState<DoctorMonitorScreen>
    with SingleTickerProviderStateMixin {
  double? _selectedLat;
  double? _selectedLng;
  Timer? _pollTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    ref.listenManual(sessionProvider, (previous, next) {
      if (next.error != null && previous?.error == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () => ref.read(sessionProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      ref.read(sessionProvider.notifier).refreshAttendees();
    });
    ref.read(sessionProvider.notifier).refreshAttendees();
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _createSession() async {
    if (_selectedLat == null || _selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set the lecture location on the map first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = ref.read(authProvider).user;
    if (user == null) return;

    await ref.read(sessionProvider.notifier).createSession(
          lecturerId: user.id,
          subjectName: widget.subjectName,
          subjectCode: widget.subjectCode,
          latitude: _selectedLat!,
          longitude: _selectedLng!,
        );

    final state = ref.read(sessionProvider);
    if (state.activeSession != null) {
      _tabController.animateTo(1);
      _startPolling();
    }
  }

  Future<void> _closeSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Session?'),
        content: const Text(
          'This will end the attendance session. Students will no longer be able to check in.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Close Session', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _stopPolling();
      await ref.read(sessionProvider.notifier).closeSession();
      _tabController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final hasActiveSession = sessionState.activeSession != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subjectName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(widget.subjectCode, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          if (hasActiveSession)
            TextButton.icon(
              onPressed: _closeSession,
              icon: const Icon(Icons.stop_circle, color: AppColors.danger),
              label: const Text('End Session', style: TextStyle(color: AppColors.danger)),
            ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Setup', icon: Icon(Icons.settings_outlined, size: 18)),
            Tab(text: 'Monitor', icon: Icon(Icons.bar_chart, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSetupTab(sessionState),
          _buildMonitorTab(sessionState),
        ],
      ),
    );
  }

  Widget _buildSetupTab(SessionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GeoMapCard(
            onLocationSelected: (lat, lng) {
              setState(() {
                _selectedLat = lat;
                _selectedLng = lng;
              });
            },
          ),
          const SizedBox(height: 16),
          const RadiusSliderCard(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: state.isLoading ? null : _createSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.play_arrow),
              label: Text(
                state.isLoading ? 'Starting...' : 'Start Session',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorTab(SessionState state) {
    if (state.activeSession == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors_off, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text('No active session', style: TextStyle(fontSize: 16, color: AppColors.textMuted)),
            Text('Start a session from the Setup tab', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    final session = state.activeSession!;
    final attendees = state.attendees;

    return RefreshIndicator(
      onRefresh: () => ref.read(sessionProvider.notifier).refreshAttendees(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmartPulseViz(
              presentCount: session.presentCount,
              totalCount: session.totalStudents,
              isActive: session.isActive,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Live Check-ins',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: Text('${attendees.length}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (attendees.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_empty, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 8),
                      Text('Waiting for students to check in...', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              )
            else
              ...attendees.map((item) => LiveFeedItem(key: ValueKey(item.id), item: item)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopPolling();
    _tabController.dispose();
    super.dispose();
  }
}
