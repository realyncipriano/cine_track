class UserList {
  final int id;
  final int? userId;
  final String name;
  final String? description;
  final String? coverPath;
  final bool isPublic;
  final bool isRanked;
  final int? movieCount;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic>? owner;

  UserList({
    required this.id,
    this.userId,
    required this.name,
    this.description,
    this.coverPath,
    this.isPublic = true,
    this.isRanked = false,
    this.movieCount,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
  });

  factory UserList.fromJson(Map<String, dynamic> json) {
    return UserList(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      userId: json['user_id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      coverPath: json['cover_path'] as String?,
      isPublic: json['is_public'] == true || json['is_public'] == 1,
      isRanked: json['is_ranked'] == true || json['is_ranked'] == 1,
      movieCount: json['movie_count'] as int?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      owner: json['owner'] as Map<String, dynamic>?,
    );
  }
}

class ListMovieItem {
  final int id;
  final int movieId;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;
  final String? note;
  final int position;
  final String addedAt;

  ListMovieItem({
    required this.id,
    required this.movieId,
    required this.title,
    this.posterPath,
    this.releaseDate,
    this.voteAverage = 0.0,
    this.note,
    this.position = 0,
    required this.addedAt,
  });

  factory ListMovieItem.fromJson(Map<String, dynamic> json) {
    return ListMovieItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      movieId: json['movie_id'] is int ? json['movie_id'] as int : int.parse(json['movie_id'].toString()),
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
      position: json['position'] as int? ?? 0,
      addedAt: json['added_at'] as String? ?? '',
    );
  }

  String? get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w200$posterPath'
      : null;
}
