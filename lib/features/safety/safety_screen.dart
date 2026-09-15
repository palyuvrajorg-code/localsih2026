import 'package:flutter/material.dart';
import '../../store.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/services/location_engine.dart';

class SafetyScreen extends StatelessWidget {
  final AppStore store;
  const SafetyScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([store, store.safetyEngine, store.locationEngine]),
      builder: (context, _) {
        final safetyEvents = store.safetyEngine.events;
        final loc = store.locationEngine.currentLocation;
        final isInsideSafeZone = loc.isInsideSafeZone;

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            title: const Text(
              'Safety & Phone Location',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Mandatory Legal Disclaimer Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        LocationEngine.disclaimer,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Current Phone Location & Geofence Status Card
              SmritiCard(
                backgroundColor: isInsideSafeZone ? Colors.white : AppColors.alertSoftRed,
                border: Border.all(
                  color: isInsideSafeZone ? AppColors.line : AppColors.alertRed,
                  width: 1.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: AppColors.green, size: 26),
                            SizedBox(width: 8),
                            Text(
                              'Phone Location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isInsideSafeZone
                                ? AppColors.safeGreen.withValues(alpha: 0.15)
                                : AppColors.alertRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isInsideSafeZone ? 'Inside Safe Zone' : 'Safe-Zone Exit Alert',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isInsideSafeZone ? AppColors.safeGreen : AppColors.alertRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.locationName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coordinates: ${loc.latitude.toStringAsFixed(4)}° N, ${loc.longitude.toStringAsFixed(4)}° E',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.details,
                      style: const TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    // Simulation button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isInsideSafeZone ? Colors.deepOrange : AppColors.green,
                          side: BorderSide(color: isInsideSafeZone ? Colors.deepOrange : AppColors.green),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          if (isInsideSafeZone) {
                            store.simulateSafeZoneExit();
                          } else {
                            store.locationEngine.returnToSafeZone();
                          }
                        },
                        icon: Icon(isInsideSafeZone ? Icons.fmd_bad : Icons.home_rounded),
                        label: Text(
                          isInsideSafeZone
                              ? 'Simulate Safe-Zone Exit (Jury Demo)'
                              : 'Return to Safe Zone',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Safety Anomaly Check Section
              const Text(
                'SAFETY ANOMALY MONITORING',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 10),
              SmritiCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Automated Inactivity & Movement Checks',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Monitors prolonged inactivity or sudden tilt anomalies without intrusive camera surveillance.',
                      style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.35),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          store.simulateSafetyEvent();
                        },
                        icon: const Icon(Icons.warning_amber_rounded),
                        label: const Text(
                          'Simulate Possible Anomaly Event',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Safety History
              const Text(
                'RECENT SAFETY LOGS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 10),
              if (safetyEvents.isEmpty)
                const SmritiCard(
                  child: Center(
                    child: Text('No safety incidents recorded. All calm.', style: TextStyle(color: AppColors.muted)),
                  ),
                )
              else
                ...safetyEvents.map(
                  (evt) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SmritiCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            evt.isResolved ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                            color: evt.isResolved ? AppColors.safeGreen : AppColors.alertRed,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  evt.type,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  evt.description,
                                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: evt.isResolved
                                  ? AppColors.safeGreen.withValues(alpha: 0.15)
                                  : AppColors.alertRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              evt.isResolved ? 'Resolved' : 'Escalated',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: evt.isResolved ? AppColors.safeGreen : AppColors.alertRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
