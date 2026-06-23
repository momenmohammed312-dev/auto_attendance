/// notification_model.dart
/// -----------------------
/// Model يمثّل إشعار واحد في التطبيق
/// الإشعارات ممكن تكون: تأكيد حضور، تحذير غياب، إعلان جلسة جديدة، إلخ

class NotificationModel {
  final String id;
  final String title;
  final String body;
  /// نوع الإشعار - بيحدد الأيقونة واللون
  /// القيم المحتملة: 'attendance_confirmed', 'absence_warning',
  /// 'session_started', 'session_ended', 'general'
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
        if (metadata != null) 'metadata': metadata,
      };

  /// وقت الإشعار بشكل مقروء نسبي مثل "5 min ago" أو "2 hours ago"
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  NotificationModel markAsRead() => copyWith(isRead: true);

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'NotificationModel(id: $id, type: $type, read: $isRead, title: $title)';
}
