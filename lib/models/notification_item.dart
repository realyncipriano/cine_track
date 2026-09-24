import 'notification_type.dart';

class NotificationItem {
  final int id;
  final NotificationType type;
  final int? actorId;
  final String? actorName;
  final String? actorAvatar;
  final String? targetType;
  final int? targetId;
  final Map<String, dynamic>? metadata;
  final String createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    this.actorId,
    this.actorName,
    this.actorAvatar,
    this.targetType,
    this.targetId,
    this.metadata,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>?;
    return NotificationItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      type: NotificationType.fromString(json['type'] as String? ?? ''),
      actorId: actor?['id'] as int? ?? (json['actor_id'] as int?),
      actorName: actor?['name'] as String? ?? json['actor_name'] as String?,
      actorAvatar: actor?['avatar_url'] as String? ?? json['actor_avatar'] as String?,
      targetType: json['target_type'] as String?,
      targetId: json['target_id'] != null
          ? (json['target_id'] is int ? json['target_id'] as int : int.tryParse(json['target_id'].toString()))
          : null,
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] as Map<String, dynamic> : null,
      createdAt: json['created_at'] as String? ?? '',
      isRead: json['read_at'] != null,
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      type: type,
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      targetType: targetType,
      targetId: targetId,
      metadata: metadata,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
