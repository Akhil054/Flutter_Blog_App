import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  /// The current user's most recent notifications, newest first.
  Future<List<AppNotificationModel>> getNotifications({int limit});

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  /// Emits each notification inserted for the current user from now on,
  /// via Supabase Realtime. Cancelling the subscription closes the channel.
  Stream<AppNotificationModel> watchNewNotifications();

  /// Saves this device's FCM token against the current user so the
  /// `send-push` edge function can reach it.
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  });

  Future<void> unregisterDeviceToken(String token);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;
  NotificationRemoteDataSourceImpl({required this.supabaseClient});

  String get _currentUserId {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('You must be logged in');
    return userId;
  }

  @override
  Future<List<AppNotificationModel>> getNotifications({int limit = 50}) async {
    try {
      /// RLS already limits rows to the current user's; the explicit filter
      /// just keeps the query obvious
      final rows = await supabaseClient
          .from('notifications')
          .select()
          .eq('recipient_id', _currentUserId)
          .order('created_at', ascending: false)
          .limit(limit);

      return rows.map(AppNotificationModel.fromJson).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', _currentUserId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Stream<AppNotificationModel> watchNewNotifications() {
    final userId = _currentUserId;
    final controller = StreamController<AppNotificationModel>();

    final channel = supabaseClient
        .channel('notifications-$userId-${DateTime.now().millisecondsSinceEpoch}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: userId,
          ),
          callback: (payload) =>
              controller.add(AppNotificationModel.fromJson(payload.newRecord)),
        )
        .subscribe();

    controller.onCancel = () => supabaseClient.removeChannel(channel);
    return controller.stream;
  }

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    try {
      /// an RPC rather than a plain upsert so a token left behind by another
      /// account on this device gets reassigned instead of failing RLS
      await supabaseClient.rpc('register_device_token', params: {
        'p_token': token,
        'p_platform': platform,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> unregisterDeviceToken(String token) async {
    try {
      await supabaseClient.from('device_tokens').delete().eq('token', token);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
