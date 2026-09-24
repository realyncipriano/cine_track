import 'package:flutter/foundation.dart';
import '../models/user_list.dart';
import '../services/api_service.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';

class UserListsProvider extends ChangeNotifier {
  final ApiService _api;
  final AuthService _authService;

  List<UserList> _myLists = [];
  UserList? _currentList;
  List<ListMovieItem> _currentMovies = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _page = 1;
  bool _hasMore = true;
  int _total = 0;
  String? _error;

  UserListsProvider(this._api, this._authService) {
    _authService.addListener(_onAuthChanged);
  }

  List<UserList> get myLists => List.unmodifiable(_myLists);
  UserList? get currentList => _currentList;
  List<ListMovieItem> get currentMovies => List.unmodifiable(_currentMovies);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get total => _total;
  String? get error => _error;

  void _onAuthChanged() {
    if (!_authService.isAuthenticated) {
      _myLists.clear();
      _currentList = null;
      _currentMovies.clear();
      _page = 1;
      _hasMore = true;
      _total = 0;
      notifyListeners();
    }
  }

  Future<void> fetchMyLists({bool loadMore = false}) async {
    if (loadMore && (!_hasMore || _isLoadingMore)) return;
    final userId = _authService.user?.id;
    if (userId == null) return;

    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _page = 1;
      _total = 0;
      _hasMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('${ApiEndpoints.userLists}?user_id=$userId&page=$_page&per_page=20');
      final list = (data['lists'] as List<dynamic>?)
              ?.map((e) => UserList.fromJson(e as Map<String, dynamic>))
              .toList() ?? [];
      _total = data['total'] as int? ?? list.length;

      if (loadMore) {
        _myLists.addAll(list);
      } else {
        _myLists = list;
      }
      _hasMore = _myLists.length < _total;
      _page++;
    } catch (e) {
      _error = e.toString();
      debugPrint('fetchMyLists error: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchListDetail(int listId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('${ApiEndpoints.listDetail}?id=$listId');
      final listData = data['list'] as Map<String, dynamic>?;
      final moviesData = data['movies'] as List<dynamic>? ?? [];
      if (listData != null) {
        _currentList = UserList.fromJson(listData);
      }
      _currentMovies = moviesData
          .map((e) => ListMovieItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('fetchListDetail error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int?> createList({
    required String name,
    String? description,
    bool isPublic = true,
    bool isRanked = false,
  }) async {
    try {
      final data = await _api.post(ApiEndpoints.listCreate, {
        'name': name,
        'description': description,
        'is_public': isPublic,
        'is_ranked': isRanked,
      });
      final id = data['id'] as int?;
      if (id != null) {
        _myLists.insert(0, UserList(
          id: id,
          userId: _authService.user?.id,
          name: name,
          description: description,
          isPublic: isPublic,
          isRanked: isRanked,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ));
        notifyListeners();
      }
      return id;
    } catch (e) {
      debugPrint('createList error: $e');
      return null;
    }
  }

  Future<bool> updateList({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
    bool? isRanked,
  }) async {
    try {
      await _api.post(ApiEndpoints.listUpdate, {
        'id': id,
        'name': ?name,
        'description': ?description,
        'is_public': ?isPublic,
        'is_ranked': ?isRanked,
      });
      return true;
    } catch (e) {
      debugPrint('updateList error: $e');
      return false;
    }
  }

  Future<bool> deleteList(int id) async {
    try {
      await _api.post(ApiEndpoints.listDelete, {'id': id});
      _myLists.removeWhere((l) => l.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('deleteList error: $e');
      return false;
    }
  }

  Future<bool> addMovieToList({
    required int listId,
    required int movieId,
    String? title,
    String? posterPath,
    String? releaseDate,
    double? voteAverage,
    String? note,
  }) async {
    try {
      await _api.post(ApiEndpoints.listAddMovie, {
        'list_id': listId,
        'movie_id': movieId,
        'title': title ?? '',
        'poster_path': posterPath,
        'release_date': releaseDate ?? '',
        'vote_average': voteAverage ?? 0.0,
        'note': note,
      });
      return true;
    } catch (e) {
      debugPrint('addMovieToList error: $e');
      return false;
    }
  }

  Future<bool> removeMovieFromList(int listId, int movieId) async {
    try {
      await _api.post(ApiEndpoints.listRemoveMovie, {'list_id': listId, 'movie_id': movieId});
      _currentMovies.removeWhere((m) => m.movieId == movieId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('removeMovieFromList error: $e');
      return false;
    }
  }

  bool isInList(int listId, int movieId) {
    return _currentMovies.any((m) => m.movieId == movieId);
  }

  void clearDetail() {
    _currentList = null;
    _currentMovies = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }
}
