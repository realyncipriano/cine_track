import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class BlockProvider extends ChangeNotifier {
  final ApiService _api;

  final Set<int> _blockedIds = {};
  bool _isLoading = false;
  String? _error;

  BlockProvider(this._api);

  Set<int> get blockedIds => Set.unmodifiable(_blockedIds);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isBlocked(int userId) => _blockedIds.contains(userId);

  Future<bool> toggleBlock(int userId) async {
    final wasBlocked = _blockedIds.contains(userId);
    if (wasBlocked) {
      _blockedIds.remove(userId);
    } else {
      _blockedIds.add(userId);
    }
    notifyListeners();

    try {
      final data = await _api.post(ApiEndpoints.block, {'user_id': userId});
      final blocking = data['blocking'] as bool;
      if (blocking) {
        _blockedIds.add(userId);
      } else {
        _blockedIds.remove(userId);
      }
      notifyListeners();
      return blocking;
    } catch (e) {
      if (wasBlocked) {
        _blockedIds.add(userId);
      } else {
        _blockedIds.remove(userId);
      }
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<User>> fetchBlockedUsers({int page = 1, int perPage = 20}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.get('${ApiEndpoints.blockedUsers}?page=$page&per_page=$perPage');
      final list = data['users'] as List<dynamic>? ?? [];
      final users = list.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
      for (final u in users) {
        _blockedIds.add(u.id);
      }
      notifyListeners();
      return users;
    } catch (e) {
      debugPrint('fetchBlockedUsers error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
