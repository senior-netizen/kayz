import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class MockSyncService {
  final List<Future<void> Function()> _queue = [];
  StreamSubscription<List<ConnectivityResult>>? _sub;

  void enqueue(Future<void> Function() operation) {
    _queue.add(operation);
  }

  void start() {
    _sub = Connectivity().onConnectivityChanged.listen((results) async {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (!online || _queue.isEmpty) return;
      final operations = List<Future<void> Function()>.from(_queue);
      _queue.clear();
      for (final operation in operations) {
        await operation();
      }
    });
  }

  void dispose() => _sub?.cancel();
}
