import 'package:flutter/foundation.dart';
import '../models/user_stats.dart';
import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class StatsProvider extends ChangeNotifier {
  final ApiService _api;

  UserStats? _stats;
  bool _isLoading = false;
  String? _error;

  StatsProvider(this._api);

  UserStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get(ApiEndpoints.userStats);
      _stats = UserStats.fromJson(data);
    } catch (e) {
      _error = '$e';
      debugPrint('fetchStats error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
