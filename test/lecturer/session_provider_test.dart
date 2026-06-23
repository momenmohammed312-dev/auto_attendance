import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:auto_attendace/features/lecturer/providers/session_provider.dart';
import 'package:auto_attendace/features/lecturer/data/session_repository.dart';
import 'package:auto_attendace/features/lecturer/data/models/session_model.dart';
import 'package:auto_attendace/features/lecturer/data/models/live_attendance_item.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  group('SessionState', () {
    test('default values are correct', () {
      const state = SessionState();

      expect(state.activeSession, isNull);
      expect(state.attendees, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.radiusMeters, 50.0);
      expect(state.locationSet, isFalse);
    });

    test('copyWith replaces specified fields', () {
      const state = SessionState();

      final updated = state.copyWith(
        isLoading: true,
        radiusMeters: 100.0,
        locationSet: true,
      );

      expect(updated.isLoading, isTrue);
      expect(updated.radiusMeters, 100.0);
      expect(updated.locationSet, isTrue);
    });

    test('copyWith clearSession sets activeSession to null', () {
      final session = SessionModel(
        id: 's1',
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: true,
        totalStudents: 0,
        presentCount: 0,
      );

      final state = SessionState(activeSession: session);
      final updated = state.copyWith(clearSession: true);

      expect(updated.activeSession, isNull);
    });

    test('copyWith clearError removes error', () {
      const state = SessionState(error: 'Some error');
      final updated = state.copyWith(clearError: true);

      expect(updated.error, isNull);
    });
  });

  group('SessionNotifier', () {
    late MockSessionRepository mockRepository;
    late SessionNotifier notifier;

    setUp(() {
      mockRepository = MockSessionRepository();
      notifier = SessionNotifier(mockRepository);
    });

    test('initial state is correct', () {
      expect(notifier.state.activeSession, isNull);
      expect(notifier.state.attendees, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.radiusMeters, 50.0);
    });

    test('createSession creates session successfully', () async {
      final session = SessionModel(
        id: 's1',
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0131,
        longitude: 31.2089,
        radiusMeters: 50.0,
        isActive: true,
        totalStudents: 0,
        presentCount: 0,
      );

      when(() => mockRepository.createSession(
            lecturerId: any(named: 'lecturerId'),
            subjectName: any(named: 'subjectName'),
            subjectCode: any(named: 'subjectCode'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusMeters: any(named: 'radiusMeters'),
          )).thenAnswer((_) async => session);

      await notifier.createSession(
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        latitude: 30.0131,
        longitude: 31.2089,
      );

      expect(notifier.state.activeSession, session);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.locationSet, isTrue);
    });

    test('createSession sets error on failure', () async {
      when(() => mockRepository.createSession(
            lecturerId: any(named: 'lecturerId'),
            subjectName: any(named: 'subjectName'),
            subjectCode: any(named: 'subjectCode'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusMeters: any(named: 'radiusMeters'),
          )).thenThrow(Exception('Create failed'));

      await notifier.createSession(
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        latitude: 30.0,
        longitude: 31.0,
      );

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, contains('Create failed'));
    });

    test('closeSession clears session state', () async {
      // First create a session
      final session = SessionModel(
        id: 's1',
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: true,
        totalStudents: 0,
        presentCount: 0,
      );

      when(() => mockRepository.createSession(
            lecturerId: any(named: 'lecturerId'),
            subjectName: any(named: 'subjectName'),
            subjectCode: any(named: 'subjectCode'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusMeters: any(named: 'radiusMeters'),
          )).thenAnswer((_) async => session);
      when(() => mockRepository.closeSession('s1'))
          .thenAnswer((_) async => session);

      await notifier.createSession(
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        latitude: 30.0,
        longitude: 31.0,
      );
      expect(notifier.state.activeSession, isNotNull);

      await notifier.closeSession();

      expect(notifier.state.activeSession, isNull);
      expect(notifier.state.attendees, isEmpty);
      expect(notifier.state.locationSet, isFalse);
    });

    test('closeSession does nothing when no active session', () async {
      await notifier.closeSession();
      verifyNever(() => mockRepository.closeSession(any()));
    });

    test('refreshAttendees updates attendee list', () async {
      final session = SessionModel(
        id: 's1',
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 200.0,
        isActive: true,
        totalStudents: 0,
        presentCount: 0,
      );

      final attendees = [
        LiveAttendanceItem(
          id: 'a1',
          studentName: 'Ahmed',
          checkInTime: DateTime(2024, 10, 24, 9, 5),
          distanceMeters: 150.0,
          isVerified: true,
          status: 'present',
        ),
      ];

      when(() => mockRepository.createSession(
            lecturerId: any(named: 'lecturerId'),
            subjectName: any(named: 'subjectName'),
            subjectCode: any(named: 'subjectCode'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusMeters: any(named: 'radiusMeters'),
          )).thenAnswer((_) async => session);
      when(() => mockRepository.getSessionAttendees('s1'))
          .thenAnswer((_) async => attendees);

      await notifier.createSession(
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        latitude: 30.0,
        longitude: 31.0,
      );
      await notifier.refreshAttendees();

      expect(notifier.state.attendees.length, 1);
      expect(notifier.state.attendees[0].studentName, 'Ahmed');
    });

    test('updateRadius updates state and syncs with API', () async {
      final session = SessionModel(
        id: 's1',
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        startTime: DateTime(2024, 10, 24, 9, 0),
        latitude: 30.0,
        longitude: 31.0,
        radiusMeters: 50.0,
        isActive: true,
        totalStudents: 0,
        presentCount: 0,
      );

      when(() => mockRepository.createSession(
            lecturerId: any(named: 'lecturerId'),
            subjectName: any(named: 'subjectName'),
            subjectCode: any(named: 'subjectCode'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusMeters: any(named: 'radiusMeters'),
          )).thenAnswer((_) async => session);
      when(() => mockRepository.updateSessionRadius(
            sessionId: any(named: 'sessionId'),
            newRadiusMeters: any(named: 'newRadiusMeters'),
          )).thenAnswer((_) async {});

      await notifier.createSession(
        lecturerId: 'doc1',
        subjectName: 'CS',
        subjectCode: 'CS101',
        latitude: 30.0,
        longitude: 31.0,
      );

      await notifier.updateRadius(200.0);

      expect(notifier.state.radiusMeters, 200.0);
      verify(() => mockRepository.updateSessionRadius(
            sessionId: 's1',
            newRadiusMeters: 200.0,
          )).called(1);
    });

    test('clearError removes error message', () {
      notifier.state = const SessionState(error: 'Error');
      notifier.clearError();

      expect(notifier.state.error, isNull);
    });
  });
}
