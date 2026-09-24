class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final String? country;
  final String? bio;
  final bool marketingOptIn;
  final String role;
  final bool emailVerified;
  final String? avatarUrl;
  final int? followersCount;
  final int? followingCount;
  final bool? isFollowing;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.country,
    this.bio,
    this.marketingOptIn = false,
    required this.role,
    required this.emailVerified,
    this.avatarUrl,
    this.followersCount,
    this.followingCount,
    this.isFollowing,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      country: json['country'] as String?,
      bio: json['bio'] as String?,
      marketingOptIn: json['marketing_opt_in'] == true,
      role: json['role'] as String? ?? 'user',
      emailVerified: json['email_verified'] == true,
      avatarUrl: json['avatar_url'] as String?,
      followersCount: json['followers_count'] as int?,
      followingCount: json['following_count'] as int?,
      isFollowing: json['is_following'] as bool?,
    );
  }

  bool get isAdmin => role == 'admin';

  bool get isModerator => role == 'moderator' || role == 'admin';

  User copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? country,
    String? bio,
    bool? marketingOptIn,
    String? role,
    bool? emailVerified,
    String? avatarUrl,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
