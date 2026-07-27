import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
}

/// impl of class 
class ConnectionCheckerImpl implements ConnectionChecker {
  
  /// dependency injection of InternetConnection class from internet_connection_checker_plus package
  final InternetConnection internetConnection;

  /// constructor to initialize the internetConnection variable
  ConnectionCheckerImpl({required this.internetConnection});

  @override
  Future<bool> get isConnected async => 
  await internetConnection.hasInternetAccess;

}