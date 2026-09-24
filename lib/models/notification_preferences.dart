class NotificationPreferences {
  final bool follow;
  final bool reviewLike;
  final bool reply;
  final bool moderation;
  final bool listAdd;

  const NotificationPreferences({
    this.follow = true,
    this.reviewLike = true,
    this.reply = true,
    this.moderation = true,
    this.listAdd = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      follow: json['follow'] as bool? ?? true,
      reviewLike: json['review_like'] as bool? ?? true,
      reply: json['reply'] as bool? ?? true,
      moderation: json['moderation'] as bool? ?? true,
      listAdd: json['list_add'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'follow': follow,
      'review_like': reviewLike,
      'reply': reply,
      'moderation': moderation,
      'list_add': listAdd,
    };
  }

  NotificationPreferences copyWith({
    bool? follow,
    bool? reviewLike,
    bool? reply,
    bool? moderation,
    bool? listAdd,
  }) {
    return NotificationPreferences(
      follow: follow ?? this.follow,
      reviewLike: reviewLike ?? this.reviewLike,
      reply: reply ?? this.reply,
      moderation: moderation ?? this.moderation,
      listAdd: listAdd ?? this.listAdd,
    );
  }
}
