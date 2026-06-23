// ============================================================
// EXCUSE REQUEST DATA MODEL
// ============================================================

/// Model representing an excuse request for a missed lecture
class ExcuseRequest {
  /// Unique identifier for the excuse request
  final String id;
  
  /// ID of the lecture being excused
  final String lectureId;
  
  /// Subject/course name
  final String subjectName;
  
  /// Date of the missed lecture
  final DateTime lectureDate;
  
  /// Reason for the absence
  final String reason;
  
  /// Type of excuse (medical, personal, family, etc.)
  final ExcuseType excuseType;
  
  /// Supporting document file path (if any)
  final String? documentPath;
  
  /// Current status of the request
  final ExcuseStatus status;
  
  /// When the request was submitted
  final DateTime submittedAt;
  
  /// When the request was reviewed/updated
  final DateTime? reviewedAt;
  
  /// Reviewer comments (if any)
  final String? reviewerComments;

  const ExcuseRequest({
    required this.id,
    required this.lectureId,
    required this.subjectName,
    required this.lectureDate,
    required this.reason,
    required this.excuseType,
    this.documentPath,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewerComments,
  });

  /// Creates an ExcuseRequest from JSON
  factory ExcuseRequest.fromJson(Map<String, dynamic> json) {
    return ExcuseRequest(
      id: json['id'] as String,
      lectureId: json['lectureId'] as String,
      subjectName: json['subjectName'] as String,
      lectureDate: DateTime.parse(json['lectureDate'] as String),
      reason: json['reason'] as String,
      excuseType: ExcuseType.values.firstWhere(
        (e) => e.toString() == 'ExcuseType.${json['excuseType']}',
        orElse: () => ExcuseType.other,
      ),
      documentPath: json['documentPath'] as String?,
      status: ExcuseStatus.values.firstWhere(
        (e) => e.toString() == 'ExcuseStatus.${json['status']}',
        orElse: () => ExcuseStatus.pending,
      ),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] != null 
          ? DateTime.parse(json['reviewedAt'] as String) 
          : null,
      reviewerComments: json['reviewerComments'] as String?,
    );
  }

  /// Converts ExcuseRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lectureId': lectureId,
      'subjectName': subjectName,
      'lectureDate': lectureDate.toIso8601String(),
      'reason': reason,
      'excuseType': excuseType.toString().split('.').last,
      'documentPath': documentPath,
      'status': status.toString().split('.').last,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewerComments': reviewerComments,
    };
  }

  /// Creates a copy with updated values
  ExcuseRequest copyWith({
    String? id,
    String? lectureId,
    String? subjectName,
    DateTime? lectureDate,
    String? reason,
    ExcuseType? excuseType,
    String? documentPath,
    ExcuseStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewerComments,
  }) {
    return ExcuseRequest(
      id: id ?? this.id,
      lectureId: lectureId ?? this.lectureId,
      subjectName: subjectName ?? this.subjectName,
      lectureDate: lectureDate ?? this.lectureDate,
      reason: reason ?? this.reason,
      excuseType: excuseType ?? this.excuseType,
      documentPath: documentPath ?? this.documentPath,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerComments: reviewerComments ?? this.reviewerComments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExcuseRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExcuseRequest(id: $id, subjectName: $subjectName, status: $status)';
  }
}

/// Types of excuses that can be requested
enum ExcuseType {
  medical,
  personal,
  family,
  emergency,
  technical,
  other,
}

/// Status of an excuse request
enum ExcuseStatus {
  pending,
  approved,
  rejected,
}

/// Extension methods for ExcuseType enum
extension ExcuseTypeExtension on ExcuseType {
  /// Gets the display name for the excuse type
  String get displayName {
    switch (this) {
      case ExcuseType.medical:
        return 'Medical';
      case ExcuseType.personal:
        return 'Personal';
      case ExcuseType.family:
        return 'Family';
      case ExcuseType.emergency:
        return 'Emergency';
      case ExcuseType.technical:
        return 'Technical Issues';
      case ExcuseType.other:
        return 'Other';
    }
  }

  /// Gets the description for the excuse type
  String get description {
    switch (this) {
      case ExcuseType.medical:
        return 'Health-related absence with medical documentation';
      case ExcuseType.personal:
        return 'Personal matters or appointments';
      case ExcuseType.family:
        return 'Family emergencies or obligations';
      case ExcuseType.emergency:
        return 'Unforeseen emergency situations';
      case ExcuseType.technical:
        return 'Technical issues preventing attendance';
      case ExcuseType.other:
        return 'Other valid reasons for absence';
    }
  }
}

/// Extension methods for ExcuseStatus enum
extension ExcuseStatusExtension on ExcuseStatus {
  /// Gets the display name for the status
  String get displayName {
    switch (this) {
      case ExcuseStatus.pending:
        return 'Pending';
      case ExcuseStatus.approved:
        return 'Approved';
      case ExcuseStatus.rejected:
        return 'Rejected';
    }
  }

  /// Gets the color for the status
  String get colorHex {
    switch (this) {
      case ExcuseStatus.pending:
        return '#FFA500'; // Orange
      case ExcuseStatus.approved:
        return '#4CAF50'; // Green
      case ExcuseStatus.rejected:
        return '#F44336'; // Red
    }
  }
}
