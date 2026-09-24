import 'package:flutter/foundation.dart';
import '../models/person.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class PeopleProvider extends ChangeNotifier {
  final TmdbService _tmdbService;

  Person? _person;
  List<Movie> _knownForMovies = [];
  bool _isLoading = false;
  String? _error;

  PeopleProvider(this._tmdbService);

  Person? get person => _person;
  List<Movie> get knownForMovies => _knownForMovies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPerson(int personId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _tmdbService.getPerson(personId),
        _tmdbService.getPersonMovieCredits(personId),
      ]);

      final person = results[0] as Person;
      final creditsData = results[1] as Map<String, dynamic>;

      final castList = creditsData['cast'] as List<dynamic>;
      final sorted = castList
          .whereType<Map<String, dynamic>>()
          .map((e) => MovieCredit.fromJson(e))
          .where((c) => c.posterPath != null)
          .toList()
        ..sort((a, b) => b.popularity.compareTo(a.popularity));

      final filmography = sorted;

      _person = Person(
        id: person.id,
        name: person.name,
        knownForDepartment: person.knownForDepartment,
        biography: person.biography,
        birthday: person.birthday,
        deathday: person.deathday,
        placeOfBirth: person.placeOfBirth,
        profilePath: person.profilePath,
        popularity: person.popularity,
        alsoKnownAs: person.alsoKnownAs,
        gender: person.gender,
        imdbId: person.imdbId,
        knownFor: filmography,
      );

      _knownForMovies = filmography
          .take(10)
          .map((c) => Movie(
                id: c.id,
                title: c.title,
                overview: '',
                posterPath: c.posterPath,
                releaseDate: c.releaseDate,
                voteAverage: c.voteAverage,
              ))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _person = null;
    _knownForMovies = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
