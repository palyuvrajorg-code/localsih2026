import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';

abstract interface class LocationProvider {
  Future<LocationEvent> getCurrentPhoneLocation();
}

class MockLocationProvider implements LocationProvider {
  @override
  Future<LocationEvent> getCurrentPhoneLocation() async {
    return LocationEvent(
      id: 'loc-1',
      latitude: 26.1445,
      longitude: 91.7362,
      locationName: 'Home Residence (Ulubari, Guwahati)',
      isInsideSafeZone: true,
      timestamp: DateTime.now(),
      details: 'Within designated 200m home safe zone.',
    );
  }
}

class LocationEngine extends ChangeNotifier {
  static const String disclaimer =
      'Notice: Location tracks the phone device and does not guarantee the person’s physical possession of it.';

  LocationEvent _currentLocation = LocationEvent(
    id: 'loc-init',
    latitude: 26.1445,
    longitude: 91.7362,
    locationName: 'Home (Ulubari, Guwahati)',
    isInsideSafeZone: true,
    timestamp: DateTime.now(),
    details: 'Within designated 200m home perimeter.',
  );

  final List<LocationEvent> _history = [];
  void Function(CareAlert)? onAlertTriggered;

  LocationEvent get currentLocation => _currentLocation;
  List<LocationEvent> get history => List.unmodifiable(_history);

  LocationEngine({this.onAlertTriggered}) {
    _history.add(_currentLocation);
  }

  void simulateSafeZoneExit() {
    _currentLocation = LocationEvent(
      id: 'loc-${DateTime.now().millisecondsSinceEpoch}',
      latitude: 26.1510,
      longitude: 91.7450,
      locationName: 'Near G.S. Road (Outside Safe Zone)',
      isInsideSafeZone: false,
      timestamp: DateTime.now(),
      details: 'Phone device has crossed the designated 200m home boundary.',
    );
    _history.insert(0, _currentLocation);

    final alert = CareAlert(
      id: 'alert-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Geofence Safe-Zone Alert',
      message: 'Kamala’s phone has moved outside the designated Home Safe Zone.',
      severity: AlertSeverity.high,
      timestamp: DateTime.now(),
    );
    onAlertTriggered?.call(alert);
    notifyListeners();
  }

  void returnToSafeZone() {
    _currentLocation = LocationEvent(
      id: 'loc-${DateTime.now().millisecondsSinceEpoch}',
      latitude: 26.1445,
      longitude: 91.7362,
      locationName: 'Home (Ulubari, Guwahati)',
      isInsideSafeZone: true,
      timestamp: DateTime.now(),
      details: 'Phone device is back inside home safe zone.',
    );
    _history.insert(0, _currentLocation);
    notifyListeners();
  }
}
