import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class FollowProvider extends ChangeNotifier {
  final ApiService _api;

  final Set<int> _followingIds = {};
  final bool _isLoading = false;
  String? _error;

  FollowProvider(this._api);

  Set<int> get followingIds => Set.unmodifiable(_followingIds);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFollowing(int userId) => _followingIds.contains(userId);

  Future<bool> toggleFollow(int userId) async {
    final wasFollowing = _followingIds.contains(userId);
    if (wasFollowing) {
      _followingIds.remove(userId);
    } else {
      _followingIds.add(userId);
    }
    notifyListeners();

    try {
      final data = await _api.post(ApiEndpoints.follow, {'user_id': userId});
      final following = data['following'] as bool;
      if (following) {
        _followingIds.add(userId);
      } else {
        _followingIds.remove(userId);
      }
      notifyListeners();
      return following;
    } catch (e) {
      if (wasFollowing) {
        _followingIds.add(userId);
      } else {
        _followingIds.remove(userId);
      }
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<User>> fetchFollowing(int userId, {int page = 1, int perPage = 20}) async {
    try {
      final data = await _api.get('${ApiEndpoints.following}?user_id=$userId&page=$page&per_page=$perPage');
      final list = data['following'] as List<dynamic>? ?? [];
      final users = list.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
      for (final u in users) {
        _followingIds.add(u.id);
      }
      notifyListeners();
      return users;
    } catch (e) {
      debugPrint('fetchFollowing error: $e');
      rethrow;
    }
  }

  Future<List<User>> fetchFollowers(int userId, {int page = 1, int perPage = 20}) async {
    try {
      final data = await _api.get('${ApiEndpoints.followers}?user_id=$userId&page=$page&per_page=$perPage');
      final list = data['followers'] as List<dynamic>? ?? [];
      final users = list.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
      return users;
    } catch (e) {
      debugPrint('fetchFollowers error: $e');
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
