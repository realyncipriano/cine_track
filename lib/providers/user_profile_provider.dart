import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class UserProfileProvider extends ChangeNotifier {
  final ApiService _api;

  User? _profile;
  Map<String, int> _counts = {};
  bool? _isFollowing;
  bool? _isBlocked;
  bool _isLoading = false;
  String? _error;

  UserProfileProvider(this._api);

  User? get profile => _profile;
  Map<String, int> get counts => _counts;
  bool? get isFollowing => _isFollowing;
  bool? get isBlocked => _isBlocked;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('${ApiEndpoints.userProfile}?user_id=$userId');
      final userData = data['user'] as Map<String, dynamic>?;
      if (userData != null) {
        final counts = data['counts'] as Map<String, dynamic>?;
        _profile = User.fromJson({
          ...userData,
          'followers_count': counts?['followers'] as int? ?? 0,
          'following_count': counts?['following'] as int? ?? 0,
          'is_following': data['is_following'] as bool? ?? false,
        });
        _counts = {
          'followers': counts?['followers'] as int? ?? 0,
          'following': counts?['following'] as int? ?? 0,
          'movies_watched': counts?['movies_watched'] as int? ?? 0,
          'reviews': counts?['reviews'] as int? ?? 0,
          'lists': counts?['lists'] as int? ?? 0,
        };
        _isFollowing = data['is_following'] as bool? ?? false;
        _isBlocked = data['is_blocked'] as bool? ?? false;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('fetchProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setIsFollowing(bool value) {
    _isFollowing = value;
    if (_counts.containsKey('followers')) {
      _counts['followers'] = _counts['followers']! + (value ? 1 : -1);
    }
    notifyListeners();
  }

  void setIsBlocked(bool value) {
    _isBlocked = value;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    _counts = {};
    _isFollowing = null;
    _isBlocked = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
