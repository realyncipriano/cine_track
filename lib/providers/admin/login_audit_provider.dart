import 'package:flutter/foundation.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

class LoginAuditProvider extends ChangeNotifier {
  final ApiService _api;

  LoginAuditProvider(this._api);

  List<Map<String, dynamic>> _logs = [];
  int _total = 0;
  int _page = 1;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get logs => _logs;
  int get total => _total;
  int get page => _page;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLogs({
    int page = 1,
    String? email,
    String? successFilter,
    String? dateFrom,
    String? dateTo,
  }) async {
    _isLoading = true;
    _error = null;
    _page = page;
    notifyListeners();
    try {
      final q = <String, String>{
        'page': page.toString(),
        'per_page': '30',
      };
      if (email != null && email.isNotEmpty) q['email'] = email;
      if (successFilter != null) q['success'] = successFilter;
      if (dateFrom != null && dateFrom.isNotEmpty) q['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) q['date_to'] = dateTo;
      final qs = ApiService.buildQueryString(q);
      final data = await _api.get('${ApiEndpoints.loginAudit}?$qs');
      _logs = (data['logs'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ?? [];
      _total = data['total'] as int? ?? 0;
    } catch (e) {
      debugPrint('Failed to load login audit: $e');
      _error = 'Failed to load login audit. Please try again.';
    }
    _isLoading = false;
    notifyListeners();
  }
}
