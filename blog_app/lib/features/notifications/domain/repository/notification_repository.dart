import 'package:fpdart/fpdart.dart';

import '../../../../error/failures.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  /// Notifications for the current user as they're created, pushed live.
  Stream<AppNotification> watchNewNotifications();

  Future<Either<Failure, void>> registerDeviceToken({
    required String token,
    required String platform,
  });

  Future<Either<Failure, void>> unregisterDeviceToken(String token);
}
