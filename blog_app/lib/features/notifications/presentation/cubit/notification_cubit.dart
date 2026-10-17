import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repository/notification_repository.dart';

part 'notification_state.dart';

/// App-wide notifications for the logged-in user: the list behind the bell,
/// the unread badge, live updates over Realtime (each one also shown as a
/// banner while the app is open) and this device's FCM token registration.
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationState());

  StreamSubscription<AppNotification>? _realtimeSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// the token saved for the current user, so logout can remove exactly it
  String? _registeredToken;

  /// Called once a user is logged in.
  Future<void> start() async {
    await _cancelSubscriptions();

    _realtimeSubscription =
        _repository.watchNewNotifications().listen(_onNewNotification);

    final token = await NotificationService.getToken();
    if (token != null) await _registerToken(token);
    _tokenRefreshSubscription =
        NotificationService.onTokenRefresh.listen(_registerToken);

    await load();
  }

  /// Called right before logging out, while the session is still valid -
  /// otherwise RLS would block removing the token and this device would
  /// keep receiving the previous user's pushes.
  Future<void> stop() async {
    await _cancelSubscriptions();
    final token = _registeredToken;
    _registeredToken = null;
    if (token != null) await _repository.unregisterDeviceToken(token);
    emit(const NotificationState());
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final res = await _repository.getNotifications();
    res.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (notifications) =>
          emit(NotificationState(notifications: notifications)),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final previous = state.notifications;
    if (previous.every((n) => n.id != notificationId || n.isRead)) return;

    emit(state.copyWith(
      notifications: [
        for (final n in previous)
          n.id == notificationId ? n.copyWith(isRead: true) : n,
      ],
    ));

    final res = await _repository.markAsRead(notificationId);
    res.fold(
      (failure) => emit(state.copyWith(notifications: previous, error: failure.message)),
      (_) {},
    );
  }

  Future<void> markAllAsRead() async {
    final previous = state.notifications;
    if (state.unreadCount == 0) return;

    emit(state.copyWith(
      notifications: [for (final n in previous) n.copyWith(isRead: true)],
    ));

    final res = await _repository.markAllAsRead();
    res.fold(
      (failure) => emit(state.copyWith(notifications: previous, error: failure.message)),
      (_) {},
    );
  }

  // Realtime Notification 
  void _onNewNotification(AppNotification notification) {
    /// a like -> unlike -> like replaces the earlier row server-side, so
    /// drop any stale copy of the same like before adding the new one
    final rest = state.notifications.where((n) =>
        n.id != notification.id &&
        !(notification.type == NotificationType.like &&
            n.type == NotificationType.like &&
            n.blogId == notification.blogId &&
            n.actorId == notification.actorId));

    emit(state.copyWith(notifications: [notification, ...rest]));

    NotificationService.show(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.body,
      blogId: notification.blogId,
    );
  }

  Future<void> _registerToken(String token) async {
    final res = await _repository.registerDeviceToken(
      token: token,
      platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
    );
    res.fold(
      (failure) => debugPrint('Could not register FCM token: ${failure.message}'),
      (_) => _registeredToken = token,
    );
  }

  Future<void> _cancelSubscriptions() async {
    await _realtimeSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    _realtimeSubscription = null;
    _tokenRefreshSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}
