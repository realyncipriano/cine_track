import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';
import '../models/notification_preferences.dart';
import '../services/api_service.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _api;
  final AuthService _authService;

  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _page = 1;
  bool _hasMore = true;
  int _total = 0;
  String? _error;
  Timer? _pollTimer;
  NotificationPreferences _preferences = const NotificationPreferences();
  bool _preferencesLoading = false;

  NotificationProvider(this._api, this._authService) {
    _authService.addListener(_onAuthChanged);
  }

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  NotificationPreferences get preferences => _preferences;
  bool get preferencesLoading => _preferencesLoading;

  void _onAuthChanged() {
    if (_authService.isAuthenticated) {
      fetchUnreadCount();
      fetchNotifications();
      fetchPreferences();
      _startPolling();
    } else {
      _notifications.clear();
      _unreadCount = 0;
      _page = 1;
      _hasMore = true;
      _total = 0;
      _preferences = const NotificationPreferences();
      _stopPolling();
      notifyListeners();
    }
  }

  void _startPolling() {
    _stopPolling();
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      fetchUnreadCount();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> fetchUnreadCount() async {
    try {
      final data = await _api.get(ApiEndpoints.notificationUnreadCount);
      _unreadCount = data['unread_count'] as int? ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('fetchUnreadCount error: $e');
    }
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _page = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('${ApiEndpoints.notificationList}?page=1&per_page=20');
      final list = data['notifications'] as List<dynamic>? ?? [];
      _total = data['total'] as int? ?? list.length;
      _notifications = list.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
      _hasMore = _notifications.length < _total;
    } catch (e) {
      _error = e.toString();
      debugPrint('fetchNotifications error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    _page++;
    notifyListeners();

    try {
      final data = await _api.get('${ApiEndpoints.notificationList}?page=$_page&per_page=20');
      final list = data['notifications'] as List<dynamic>? ?? [];
      _total = data['total'] as int? ?? 0;
      _notifications.addAll(list.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)));
      _hasMore = _notifications.length < _total;
    } catch (e) {
      _page--;
      _error = e.toString();
      debugPrint('loadMore error: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0 && _notifications[idx].isRead) return;

    try {
      await _api.post(ApiEndpoints.notificationRead, {'notification_id': id});
      if (idx >= 0) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('markAsRead error: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
      await _api.post(ApiEndpoints.notificationRead, {'all': true});
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('markAllRead error: $e');
    }
  }

  Future<void> fetchPreferences() async {
    _preferencesLoading = true;
    notifyListeners();
    try {
      final data = await _api.get(ApiEndpoints.notificationPreferences);
      _preferences = NotificationPreferences.fromJson(data);
    } catch (e) {
      debugPrint('fetchPreferences error: $e');
    } finally {
      _preferencesLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferences(NotificationPreferences prefs) async {
    try {
      await _api.post(ApiEndpoints.notificationPreferences, prefs.toJson());
      _preferences = prefs;
      notifyListeners();
    } catch (e) {
      debugPrint('updatePreferences error: $e');
      rethrow;
    }
  }

  void decrementUnread() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }
}
