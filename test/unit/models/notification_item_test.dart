import 'package:flutter_test/flutter_test.dart';
import 'package:cine_track/models/notification_item.dart';
import 'package:cine_track/models/notification_type.dart';

void main() {
  group('NotificationItem.fromJson', () {
    test('parses follow notification with actor sub-object', () {
      final json = {
        'id': 1,
        'type': 'follow',
        'actor': {'id': 42, 'name': 'Alice', 'avatar_url': 'https://example.com/avatar.jpg'},
        'target_type': 'user',
        'target_id': 7,
        'read_at': null,
        'created_at': '2026-07-18 12:00:00',
      };

      final item = NotificationItem.fromJson(json);

      expect(item.id, 1);
      expect(item.type, NotificationType.follow);
      expect(item.actorId, 42);
      expect(item.actorName, 'Alice');
      expect(item.actorAvatar, 'https://example.com/avatar.jpg');
      expect(item.targetType, 'user');
      expect(item.targetId, 7);
      expect(item.isRead, false);
    });

    test('parses review_like notification with flat fields', () {
      final json = {
        'id': 2,
        'type': 'review_like',
        'actor_id': 99,
        'actor_name': 'Bob',
        'target_type': 'review',
        'target_id': 15,
        'read_at': '2026-07-18 12:30:00',
        'created_at': '2026-07-18 12:00:00',
      };

      final item = NotificationItem.fromJson(json);

      expect(item.type, NotificationType.reviewLike);
      expect(item.actorId, 99);
      expect(item.actorName, 'Bob');
      expect(item.isRead, true);
    });

    test('parses unknown type as NotificationType.unknown', () {
      final json = {
        'id': 3,
        'type': 'unknown_type_xyz',
        'created_at': '2026-07-18',
      };

      final item = NotificationItem.fromJson(json);

      expect(item.type, NotificationType.unknown);
    });
  });

  group('NotificationItem.copyWith', () {
    test('creates copy with isRead flipped', () {
      final item = NotificationItem(
        id: 1,
        type: NotificationType.follow,
        createdAt: '',
        isRead: false,
      );

      final updated = item.copyWith(isRead: true);

      expect(updated.isRead, true);
      expect(item.isRead, false);
    });
  });
}
