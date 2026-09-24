import '../config.dart';

class MovieCredit {
  final int id;
  final String title;
  final String? character;
  final String? posterPath;
  final String releaseDate;
  final double voteAverage;
  final double popularity;

  MovieCredit({
    required this.id,
    required this.title,
    this.character,
    this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.popularity,
  });

  factory MovieCredit.fromJson(Map<String, dynamic> json) {
    return MovieCredit(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      character: json['character'] as String?,
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String? get posterUrl => posterPath != null
      ? '${AppConfig.imageBaseUrl}$posterPath'
      : null;
}

class Person {
  final int id;
  final String name;
  final String? knownForDepartment;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final String? profilePath;
  final double popularity;
  final List<String> alsoKnownAs;
  final int gender;
  final String? imdbId;
  final List<MovieCredit> knownFor;

  Person({
    required this.id,
    required this.name,
    this.knownForDepartment,
    this.biography,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.profilePath,
    this.popularity = 0.0,
    this.alsoKnownAs = const [],
    this.gender = 0,
    this.imdbId,
    this.knownFor = const [],
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      knownForDepartment: json['known_for_department'] as String?,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      profilePath: json['profile_path'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      alsoKnownAs: (json['also_known_as'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      gender: json['gender'] as int? ?? 0,
      imdbId: json['imdb_id'] as String?,
    );
  }

  String? get profileUrl => profilePath != null
      ? '${AppConfig.imageBaseUrl}$profilePath'
      : null;

  int? get age {
    if (birthday == null || birthday!.length < 10) return null;
    try {
      final bday = DateTime.parse(birthday!.substring(0, 10));
      final end = deathday != null
          ? DateTime.parse(deathday!.substring(0, 10))
          : DateTime.now();
      int age = end.year - bday.year;
      if (end.month < bday.month ||
          (end.month == bday.month && end.day < bday.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  bool get isDeceased => deathday != null && deathday!.isNotEmpty;
}
