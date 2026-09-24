import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'api_endpoints.dart';
import 'api_service.dart';
import 'auth_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message: ${message.messageId}');
}

class FcmService {
  final ApiService _api;
  final AuthService _authService;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final GlobalKey<NavigatorState> _navigatorKey;

  bool _initialized = false;

  FcmService({
    required ApiService api,
    required AuthService authService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _api = api,
       _authService = authService,
       _localNotifications = FlutterLocalNotificationsPlugin(),
       _navigatorKey = navigatorKey;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await _requestPermission();

    _authService.addListener(_onAuthChanged);

    _initialized = true;
  }

  Future<void> _requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');
  }

  void _onAuthChanged() {
    if (_authService.isAuthenticated) {
      _registerToken();
      _setupForegroundHandler();
      _setupTapHandler();
    }
  }

  Future<void> _registerToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (token != null) {
        await _api.post(ApiEndpoints.notificationRegisterToken, {
          'token': token,
          'platform': kIsWeb ? 'web' : 'android',
        });
        debugPrint('FCM token registered');

        messaging.onTokenRefresh.listen((newToken) async {
          await _api.post(ApiEndpoints.notificationRegisterToken, {
            'token': newToken,
            'platform': kIsWeb ? 'web' : 'android',
          });
          debugPrint('FCM token refreshed and registered');
        });
      }
    } catch (e) {
      debugPrint('FCM registerToken error: $e');
    }
  }

  Future<void> unregisterToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (token != null) {
        await _api.post(ApiEndpoints.notificationUnregisterToken, {
          'token': token,
        });
        debugPrint('FCM token unregistered');
      }
    } catch (e) {
      debugPrint('FCM unregisterToken error: $e');
    }
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  void _setupTapHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    FirebaseMessaging.instance.getInitialMessage().then(_handleNotificationTap);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'cine_track_channel',
      'CineTrack',
      channelDescription: 'Movie tracking notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      _navigateFromPayload(response.payload!);
    }
  }

  void _handleNotificationTap(RemoteMessage? message) {
    if (message == null) return;
    final payload = jsonEncode(message.data);
    _navigateFromPayload(payload);
  }

  void _navigateFromPayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final targetType = data['target_type'] as String?;
      final targetId = data['target_id'] as String?;

      if (type == null) return;

      final context = _navigatorKey.currentContext;
      if (context == null) return;

      switch (type) {
        case 'follow':
          if (targetId != null) {
            context.go('/profile/$targetId');
          }
          break;
        case 'review_like':
        case 'reply':
          if (targetType == 'review' && targetId != null) {
            context.go('/movies/$targetId');
          }
          break;
      }
    } catch (e) {
      debugPrint('FCM navigateFromPayload error: $e');
    }
  }

  void dispose() {
    _authService.removeListener(_onAuthChanged);
  }
}
