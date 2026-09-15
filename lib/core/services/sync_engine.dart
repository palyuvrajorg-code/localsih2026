import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';

enum SyncStatus { synced, syncing, offline }

class SyncEngine extends ChangeNotifier {
  SyncStatus _status = SyncStatus.synced;
  final List<SyncQueueItem> _queue = [];

  SyncStatus get status => _status;
  bool get isOffline => _status == SyncStatus.offline;
  bool get isSyncing => _status == SyncStatus.syncing;
  List<SyncQueueItem> get queue => List.unmodifiable(_queue);

  void enqueue(String action, Map<String, dynamic> payload) {
    final item = SyncQueueItem(
      id: 'sync-${DateTime.now().millisecondsSinceEpoch}',
      action: action,
      payload: payload,
      timestamp: DateTime.now(),
      synced: !isOffline,
    );
    _queue.add(item);
    notifyListeners();
  }

  void setOfflineMode(bool offline) {
    if (offline) {
      _status = SyncStatus.offline;
      notifyListeners();
    } else {
      triggerSync();
    }
  }

  Future<void> triggerSync() async {
    _status = SyncStatus.syncing;
    notifyListeners();

    // Simulate network latency and synchronization processing
    await Future.delayed(const Duration(milliseconds: 1200));

    for (var item in _queue) {
      item.synced = true;
    }
    _status = SyncStatus.synced;
    notifyListeners();
  }
}
