// session_provider.dart
// ----------------------
// Riverpod State Management للدكتور - الوسيط بين الـ UI والـ Repository

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/session_repository.dart';
import '../data/models/session_model.dart';
import '../data/models/live_attendance_item.dart';

// ═══════════════════════════════════════════════════════════════════════════
// State Class
// ═══════════════════════════════════════════════════════════════════════════

class SessionState {
  final SessionModel? activeSession;
  final List<LiveAttendanceItem> attendees;
  final bool isLoading;
  final String? error;
  final double radiusMeters;
  final bool locationSet;

  const SessionState({
    this.activeSession,
    this.attendees = const [],
    this.isLoading = false,
    this.error,
    this.radiusMeters = 50.0,
    this.locationSet = false,
  });

  SessionState copyWith({
    SessionModel? activeSession,
    List<LiveAttendanceItem>? attendees,
    bool? isLoading,
    String? error,
    double? radiusMeters,
    bool? locationSet,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return SessionState(
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
      attendees: attendees ?? this.attendees,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      radiusMeters: radiusMeters ?? this.radiusMeters,
      locationSet: locationSet ?? this.locationSet,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Repository Provider
// ═══════════════════════════════════════════════════════════════════════════

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

// ═══════════════════════════════════════════════════════════════════════════
// Notifier
// ═══════════════════════════════════════════════════════════════════════════

class SessionNotifier extends StateNotifier<SessionState> {
  final SessionRepository _repository;

  SessionNotifier(this._repository) : super(const SessionState());

  Future<void> createSession({
    required String lecturerId,
    required String subjectName,
    required String subjectCode,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.createSession(
        lecturerId: lecturerId,
        subjectName: subjectName,
        subjectCode: subjectCode,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: state.radiusMeters,
      );
      state = state.copyWith(activeSession: session, isLoading: false, locationSet: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> closeSession() async {
    final sessionId = state.activeSession?.id;
    if (sessionId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.closeSession(sessionId);
      state = state.copyWith(
        isLoading: false,
        clearSession: true,
        attendees: [],
        locationSet: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshAttendees() async {
    final sessionId = state.activeSession?.id;
    if (sessionId == null) return;
    try {
      final attendees = await _repository.getSessionAttendees(sessionId);
      state = state.copyWith(attendees: attendees);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateRadius(double newRadius) async {
    state = state.copyWith(radiusMeters: newRadius);
    final sessionId = state.activeSession?.id;
    if (sessionId != null) {
      try {
        await _repository.updateSessionRadius(sessionId: sessionId, newRadiusMeters: newRadius);
      } catch (e) {
        state = state.copyWith(error: 'Failed to sync radius: $e');
      }
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ═══════════════════════════════════════════════════════════════════════════
// Main Provider
// ═══════════════════════════════════════════════════════════════════════════

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref.watch(sessionRepositoryProvider));
});
