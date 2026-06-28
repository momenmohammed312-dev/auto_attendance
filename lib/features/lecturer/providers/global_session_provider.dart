import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/session_model.dart';
import '../data/models/live_attendance_item.dart';

class GlobalSessionState {
  final SessionModel? activeSession;
  final List<LiveAttendanceItem> attendees;

  const GlobalSessionState({
    this.activeSession,
    this.attendees = const [],
  });

  GlobalSessionState copyWith({
    SessionModel? activeSession,
    List<LiveAttendanceItem>? attendees,
    bool clearSession = false,
  }) {
    return GlobalSessionState(
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
      attendees: attendees ?? this.attendees,
    );
  }
}

class GlobalSessionNotifier extends StateNotifier<GlobalSessionState> {
  GlobalSessionNotifier() : super(const GlobalSessionState());

  void startSession({
    required String lecturerId,
    required String lecturerName,
    required String subjectName,
    required String subjectCode,
  }) {
    state = GlobalSessionState(
      activeSession: SessionModel(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        lecturerId: lecturerId,
        subjectName: subjectName,
        subjectCode: subjectCode,
        startTime: DateTime.now(),
        endTime: null,
        latitude: 30.0131,
        longitude: 31.2089,
        radiusMeters: 200,
        isActive: true,
        totalStudents: 10,
        presentCount: 0,
      ),
      attendees: [],
    );
  }

  void addAttendee({
    required String studentId,
    required String studentName,
  }) {
    final session = state.activeSession;
    if (session == null) return;

    final alreadyCheckedIn = state.attendees.any((a) => a.id == studentId);
    if (alreadyCheckedIn) return;

    final attendee = LiveAttendanceItem(
      id: studentId,
      studentName: studentName,
      checkInTime: DateTime.now(),
      distanceMeters: 0,
      isVerified: true,
      status: 'present',
    );

    state = state.copyWith(
      attendees: [...state.attendees, attendee],
      activeSession: session.withNewAttendee(),
    );
  }

  void endSession() {
    state = const GlobalSessionState();
  }
}

final globalSessionProvider = StateNotifierProvider<GlobalSessionNotifier, GlobalSessionState>((ref) {
  return GlobalSessionNotifier();
});
