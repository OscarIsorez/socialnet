import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction that allows the data layer to query the device network status in
/// a testable fashion.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();

    if (results.isEmpty) {
      return false;
    }

    return results.any((status) => status != ConnectivityResult.none);
  }
}
