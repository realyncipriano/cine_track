class UserStats {
  final int moviesWatched;
  final int totalRuntimeMinutes;
  final double hoursWatched;
  final List<GenreCount> genreBreakdown;
  final List<MonthlyCount> monthlyActivity;
  final List<RatingCount> ratingDistribution;
  final int reviewsWritten;
  final int listsCreated;
  final int currentStreak;
  final int longestStreak;

  UserStats({
    required this.moviesWatched,
    required this.totalRuntimeMinutes,
    required this.hoursWatched,
    required this.genreBreakdown,
    required this.monthlyActivity,
    required this.ratingDistribution,
    required this.reviewsWritten,
    required this.listsCreated,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      moviesWatched: json['movies_watched'] as int? ?? 0,
      totalRuntimeMinutes: json['total_runtime_minutes'] as int? ?? 0,
      hoursWatched: (json['hours_watched'] as num?)?.toDouble() ?? 0.0,
      genreBreakdown: (json['genre_breakdown'] as List<dynamic>?)
              ?.map((e) => GenreCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      monthlyActivity: (json['monthly_activity'] as List<dynamic>?)
              ?.map((e) => MonthlyCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ratingDistribution: (json['rating_distribution'] as List<dynamic>?)
              ?.map((e) => RatingCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reviewsWritten: json['reviews_written'] as int? ?? 0,
      listsCreated: json['lists_created'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
    );
  }
}

class GenreCount {
  final String genre;
  final int count;

  GenreCount({required this.genre, required this.count});

  factory GenreCount.fromJson(Map<String, dynamic> json) {
    return GenreCount(
      genre: json['genre'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class MonthlyCount {
  final String month;
  final int count;

  MonthlyCount({required this.month, required this.count});

  factory MonthlyCount.fromJson(Map<String, dynamic> json) {
    return MonthlyCount(
      month: json['month'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class RatingCount {
  final int rating;
  final int count;

  RatingCount({required this.rating, required this.count});

  factory RatingCount.fromJson(Map<String, dynamic> json) {
    return RatingCount(
      rating: json['rating'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
}
