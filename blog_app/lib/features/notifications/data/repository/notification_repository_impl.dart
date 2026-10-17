import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/network/connection_checker.dart';
import '../../../../error/exception.dart';
import '../../../../error/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repository/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  NotificationRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  /// shared connectivity check + error mapping for every one-off call
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionMessage));
      }
      return right(await action());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() =>
      _guard(() => remoteDataSource.getNotifications());

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) =>
      _guard(() => remoteDataSource.markAsRead(notificationId));

  @override
  Future<Either<Failure, void>> markAllAsRead() =>
      _guard(() => remoteDataSource.markAllAsRead());

  @override
  Stream<AppNotification> watchNewNotifications() =>
      remoteDataSource.watchNewNotifications();

  @override
  Future<Either<Failure, void>> registerDeviceToken({
    required String token,
    required String platform,
  }) =>
      _guard(() => remoteDataSource.registerDeviceToken(
            token: token,
            platform: platform,
          ));

  @override
  Future<Either<Failure, void>> unregisterDeviceToken(String token) =>
      _guard(() => remoteDataSource.unregisterDeviceToken(token));
}
