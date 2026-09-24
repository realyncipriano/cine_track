enum NotificationType {
  follow,
  reviewLike,
  reply,
  moderation,
  listAdd,
  unknown;

  static NotificationType fromString(String type) {
    switch (type) {
      case 'follow':
        return NotificationType.follow;
      case 'review_like':
        return NotificationType.reviewLike;
      case 'reply':
        return NotificationType.reply;
      case 'moderation':
        return NotificationType.moderation;
      case 'list_add':
        return NotificationType.listAdd;
      default:
        return NotificationType.unknown;
    }
  }
}
