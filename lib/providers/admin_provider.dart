import 'package:flutter/foundation.dart';
import '../models/admin/admin_movie.dart';
import '../services/api_endpoints.dart';
import '../services/api_service.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _api;

  AdminProvider(this._api);

  // ── Admin Movies ──────────────────────────────────────────────

  bool _isLoadingAdminMovies = false;
  String? _adminMoviesError;
  List<AdminMovie> _adminMovies = [];
  int _totalAdminMovies = 0;
  int _adminMoviesPage = 1;

  bool get isLoadingAdminMovies => _isLoadingAdminMovies;
  String? get adminMoviesError => _adminMoviesError;
  List<AdminMovie> get adminMovies => _adminMovies;
  int get totalAdminMovies => _totalAdminMovies;
  int get adminMoviesPage => _adminMoviesPage;

  Future<void> fetchAdminMovies({
    int page = 1,
    String sortBy = 'interactions',
    String sortOrder = 'desc',
    String? search,
  }) async {
    _isLoadingAdminMovies = true;
    _adminMoviesError = null;
    _adminMoviesPage = page;
    notifyListeners();
    try {
      final q = <String, String>{
        'page': page.toString(),
        'per_page': '20',
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };
      if (search != null && search.isNotEmpty) q['search'] = search;
      final qs = ApiService.buildQueryString(q);
      final data = await _api.get('${ApiEndpoints.movies}?$qs');
      _adminMovies = (data['movies'] as List<dynamic>?)
              ?.map((e) => AdminMovie.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _totalAdminMovies = data['total'] as int? ?? 0;
    } catch (e) {
      _adminMoviesError = e.toString();
    }
    _isLoadingAdminMovies = false;
    notifyListeners();
  }
}
