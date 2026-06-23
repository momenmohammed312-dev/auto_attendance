import 'package:flutter_test/flutter_test.dart';
import 'package:auto_attendace/features/student/data/models/excuse_request.dart';

void main() {
  group('ExcuseRequest', () {
    test('constructor stores all fields', () {
      final request = ExcuseRequest(
        id: '1',
        lectureId: 'lec1',
        subjectName: 'CS 101',
        lectureDate: DateTime(2024, 10, 24),
        reason: 'Sick',
        excuseType: ExcuseType.medical,
        status: ExcuseStatus.pending,
        submittedAt: DateTime(2024, 10, 25),
      );

      expect(request.id, '1');
      expect(request.excuseType, ExcuseType.medical);
      expect(request.status, ExcuseStatus.pending);
    });

    test('fromJson creates correct ExcuseRequest', () {
      final json = {
        'id': '2',
        'lectureId': 'lec2',
        'subjectName': 'Math',
        'lectureDate': '2024-10-24T00:00:00.000',
        'reason': 'Family emergency',
        'excuseType': 'family',
        'documentPath': null,
        'status': 'approved',
        'submittedAt': '2024-10-25T10:00:00.000',
        'reviewedAt': '2024-10-26T14:00:00.000',
        'reviewerComments': 'Approved with documentation',
      };

      final request = ExcuseRequest.fromJson(json);

      expect(request.excuseType, ExcuseType.family);
      expect(request.status, ExcuseStatus.approved);
      expect(request.reviewerComments, 'Approved with documentation');
    });

    test('fromJson handles unknown excuse type', () {
      final json = {
        'id': '3',
        'lectureId': 'lec3',
        'subjectName:': 'Physics',
        'lectureDate': '2024-10-24T00:00:00.000',
        'reason': 'Unknown',
        'excuseType': 'unknown_type',
        'status': 'pending',
        'submittedAt': '2024-10-25T10:00:00.000',
      };

      json['subjectName'] = json.remove('subjectName:')!;

      final request = ExcuseRequest.fromJson(json);

      expect(request.excuseType, ExcuseType.other);
    });

    test('toJson returns correct map', () {
      final request = ExcuseRequest(
        id: '4',
        lectureId: 'lec4',
        subjectName: 'English',
        lectureDate: DateTime(2024, 10, 24),
        reason: 'Technical issues',
        excuseType: ExcuseType.technical,
        status: ExcuseStatus.rejected,
        submittedAt: DateTime(2024, 10, 25),
        reviewerComments: 'Insufficient proof',
      );

      final json = request.toJson();

      expect(json['excuseType'], 'technical');
      expect(json['status'], 'rejected');
    });

    test('copyWith replaces specified fields', () {
      final original = ExcuseRequest(
        id: '5',
        lectureId: 'lec5',
        subjectName: 'CS',
        lectureDate: DateTime(2024, 10, 24),
        reason: 'Sick',
        excuseType: ExcuseType.medical,
        status: ExcuseStatus.pending,
        submittedAt: DateTime(2024, 10, 25),
      );

      final modified = original.copyWith(
        status: ExcuseStatus.approved,
        reviewerComments: 'Approved',
      );

      expect(modified.status, ExcuseStatus.approved);
      expect(modified.reviewerComments, 'Approved');
      expect(modified.id, '5'); // unchanged
    });

    test('equality is based on id', () {
      final a = ExcuseRequest(
        id: '1',
        lectureId: 'lec1',
        subjectName: 'CS',
        lectureDate: DateTime(2024, 10, 24),
        reason: 'Sick',
        excuseType: ExcuseType.medical,
        status: ExcuseStatus.pending,
        submittedAt: DateTime(2024, 10, 25),
      );

      final b = ExcuseRequest(
        id: '1',
        lectureId: 'lec99',
        subjectName: 'Different',
        lectureDate: DateTime(2025, 1, 1),
        reason: 'Different',
        excuseType: ExcuseType.family,
        status: ExcuseStatus.approved,
        submittedAt: DateTime(2025, 1, 1),
      );

      expect(a, equals(b));
    });

    test('inequality for different ids', () {
      final a = ExcuseRequest(
        id: '1',
        lectureId: 'lec1',
        subjectName: 'CS',
        lectureDate: DateTime(2024, 10, 24),
        reason: 'Sick',
        excuseType: ExcuseType.medical,
        status: ExcuseStatus.pending,
        submittedAt: DateTime(2024, 10, 25),
      );

      final b = ExcuseRequest(
        id: '2',
        lectureId: 'lec1',
        subjectName: 'CS',
        lectureDate: DateTime(2024, 10, 24),
        reason: 'Sick',
        excuseType: ExcuseType.medical,
        status: ExcuseStatus.pending,
        submittedAt: DateTime(2024, 10, 25),
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('ExcuseType extension', () {
    test('displayName returns correct values', () {
      expect(ExcuseType.medical.displayName, 'Medical');
      expect(ExcuseType.personal.displayName, 'Personal');
      expect(ExcuseType.family.displayName, 'Family');
      expect(ExcuseType.emergency.displayName, 'Emergency');
      expect(ExcuseType.technical.displayName, 'Technical Issues');
      expect(ExcuseType.other.displayName, 'Other');
    });

    test('description returns non-empty strings', () {
      for (final type in ExcuseType.values) {
        expect(type.description.isNotEmpty, isTrue);
      }
    });
  });

  group('ExcuseStatus extension', () {
    test('displayName returns correct values', () {
      expect(ExcuseStatus.pending.displayName, 'Pending');
      expect(ExcuseStatus.approved.displayName, 'Approved');
      expect(ExcuseStatus.rejected.displayName, 'Rejected');
    });

    test('colorHex returns correct hex codes', () {
      expect(ExcuseStatus.pending.colorHex, '#FFA500');
      expect(ExcuseStatus.approved.colorHex, '#4CAF50');
      expect(ExcuseStatus.rejected.colorHex, '#F44336');
    });
  });
}
