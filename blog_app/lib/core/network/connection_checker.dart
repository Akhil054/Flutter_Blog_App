import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Small abstraction so the repositories don't depend on a concrete
/// connectivity package. Returns whether the device can actually reach
/// the internet (not just whether wifi/mobile is on).
abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  final InternetConnection internetConnection;

  ConnectionCheckerImpl(this.internetConnection);

  @override
  Future<bool> get isConnected async => internetConnection.hasInternetAccess;
}
