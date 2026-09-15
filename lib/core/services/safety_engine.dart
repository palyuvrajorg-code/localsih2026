import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';

abstract interface class SafetyVisionService {
  Future<bool> detectPossibleMovementAnomaly();
}

class MockSafetyVisionService implements SafetyVisionService {
  @override
  Future<bool> detectPossibleMovementAnomaly() async {
    return false; // Mock simulation
  }
}

class SafetyEngine extends ChangeNotifier {
  final List<SafetyEvent> _events = [];
  bool _anomalyActive = false;
  String? _currentPrompt;
  void Function(CareAlert)? onAlertTriggered;

  bool get anomalyActive => _anomalyActive;
  String? get currentPrompt => _currentPrompt;
  List<SafetyEvent> get events => List.unmodifiable(_events);

  SafetyEngine({this.onAlertTriggered});

  /// Trigger simulation of a safety anomaly
  void triggerSafetyAnomaly({String details = 'Sudden phone tilt and prolonged inactivity'}) {
    _anomalyActive = true;
    _currentPrompt = 'Kamala, are you doing okay? Please tap below to let us know.';
    final event = SafetyEvent(
      id: 'safety-${DateTime.now().millisecondsSinceEpoch}',
      type: 'Possible safety anomaly',
      timestamp: DateTime.now(),
      description: details,
      isResolved: false,
    );
    _events.insert(0, event);
    notifyListeners();
  }

  /// User confirms they are safe
  void resolveAnomalySafe() {
    _anomalyActive = false;
    _currentPrompt = null;
    if (_events.isNotEmpty && !_events.first.isResolved) {
      final updated = SafetyEvent(
        id: _events.first.id,
        type: _events.first.type,
        timestamp: _events.first.timestamp,
        description: _events.first.description,
        isResolved: true,
        resolutionNotes: 'Elder confirmed safe via touch response.',
      );
      _events[0] = updated;
    }
    notifyListeners();
  }

  /// Elder requests help or simulated no-response timeout occurs
  void escalateAnomalyHelp({String reason = 'Elder requested help or did not respond'}) {
    _anomalyActive = false;
    _currentPrompt = null;
    if (_events.isNotEmpty) {
      final updated = SafetyEvent(
        id: _events.first.id,
        type: _events.first.type,
        timestamp: _events.first.timestamp,
        description: _events.first.description,
        isResolved: false,
        resolutionNotes: reason,
      );
      _events[0] = updated;
    }

    final alert = CareAlert(
      id: 'alert-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Safety Anomaly Escalation',
      message: 'Possible safety anomaly for Kamala Devi ($reason). Please check in immediately.',
      severity: AlertSeverity.emergency,
      timestamp: DateTime.now(),
    );
    onAlertTriggered?.call(alert);
    notifyListeners();
  }
}
