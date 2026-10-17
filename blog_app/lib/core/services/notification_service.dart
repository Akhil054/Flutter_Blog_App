import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Must be a top-level function: the OS invokes it in a separate isolate
/// when a data/notification message arrives while the app is terminated
/// or in the background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications from Blog App.',
    importance: Importance.high,
  );

  /// blog ids from tapped notifications (system push or local banner), so
  /// the app can open that blog - see MyApp
  static final StreamController<String> _blogTapController =
      StreamController<String>.broadcast();
  static Stream<String> get onBlogTap => _blogTapController.stream;

  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    /// foreground banners are shown by the app itself (via [show]) on both
    /// platforms - letting iOS also present the push would double them up
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _emitBlogTap(response.payload),
    );

    // Foreground messages don't show a system notification by default,
    // so display one manually via flutter_local_notifications.
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    /// app was in the background and the user tapped the push
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _emitBlogTap(message.data['blog_id'] as String?));
  }

  /// This device's FCM token, or null where it isn't available (e.g. web
  /// without a VAPID key, or permission denied).
  static Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('Could not get FCM token: $e');
      return null;
    }
  }

  static Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

  /// Blog id from the push that launched the app from a terminated state,
  /// if any. Only returns it once.
  static Future<String?> takeInitialBlogId() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    final blogId = message?.data['blog_id'] as String?;
    return (blogId == null || blogId.isEmpty) ? null : blogId;
  }

  static void _emitBlogTap(String? blogId) {
    if (blogId == null || blogId.isEmpty) return;
    _blogTapController.add(blogId);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    /// likes / new-blog pushes carry a notification_id - while the app is
    /// open those already arrive over Realtime (NotificationCubit shows the
    /// banner), so showing the FCM copy too would double them up
    if (message.data.containsKey('notification_id')) return;

    await show(
      id: notification.hashCode,
      title: notification.title ?? '',
      body: notification.body ?? '',
      blogId: message.data['blog_id'] as String?,
    );
  }

  /// Shows a system notification banner while the app is in the
  /// foreground. Tapping it emits [blogId] on [onBlogTap].
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? blogId,
  }) async {
    /// flutter_local_notifications has no web implementation
    if (kIsWeb) return;

    /// in the background the OS already shows the FCM push itself
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      payload: blogId,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
