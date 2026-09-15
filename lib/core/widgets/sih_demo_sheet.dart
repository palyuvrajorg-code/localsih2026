import 'package:flutter/material.dart';
import '../../store.dart';
import '../constants/colors.dart';

class SihDemoSheet extends StatelessWidget {
  const SihDemoSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SihDemoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.current;
    if (store == null) return const SizedBox();

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final isOffline = store.syncEngine.isOffline;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.muted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune_rounded, color: AppColors.green, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'SIH DEMO MODE',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Text(
                    'Smart India Hackathon 2026 Jury Live Simulation Suite.\nTap any action below to trigger real application state transitions.',
                    style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.3),
                  ),
                  const SizedBox(height: 18),

                  // Simulation Grid
                  _buildSectionTitle('Care & Adherence Scenarios'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'SIMULATE MEDICATION MISSED',
                          subtitle: 'Escalates to Caregiver alert',
                          icon: Icons.medication_liquid_rounded,
                          color: AppColors.rust,
                          onTap: () {
                            store.simulateMedicationMissed();
                            _showToast(context, 'Morning medication marked missed -> Escalated to Caregiver!');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'SIMULATE CAREGIVER ALERT',
                          subtitle: 'Creates Needs Attention item',
                          icon: Icons.notifications_active_rounded,
                          color: AppColors.terracotta,
                          onTap: () {
                            store.simulateCaregiverAlert();
                            _showToast(context, 'New Caregiver attention alert triggered!');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildSectionTitle('Safety & Geofencing Scenarios'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'SIMULATE SAFETY EVENT',
                          subtitle: 'Shows "Are you okay?" check',
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.alertRed,
                          onTap: () {
                            Navigator.pop(context);
                            store.simulateSafetyEvent();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'SIMULATE SAFE-ZONE EXIT',
                          subtitle: 'Crosses 200m geofence',
                          icon: Icons.fmd_bad_rounded,
                          color: Colors.deepOrange,
                          onTap: () {
                            store.simulateSafeZoneExit();
                            _showToast(context, 'Safe-zone exit event recorded -> Alert dispatched!');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildSectionTitle('Offline-First & Connectivity'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: isOffline ? 'RESTORE INTERNET' : 'SIMULATE OFFLINE MODE',
                          subtitle: isOffline ? 'Syncs queued items' : 'Queues all local actions',
                          icon: isOffline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                          color: isOffline ? AppColors.safeGreen : AppColors.muted,
                          onTap: () {
                            if (isOffline) {
                              store.restoreInternet();
                              _showToast(context, 'Restoring connectivity -> Running SyncEngine...');
                            } else {
                              store.simulateOfflineMode();
                              _showToast(context, 'Offline mode activated -> Actions will enter local sync queue.');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'SIMULATE DOCTOR APPT',
                          subtitle: 'Teleconsultation incoming',
                          icon: Icons.video_call_rounded,
                          color: AppColors.green,
                          onTap: () {
                            store.simulateDoctorAppointment();
                            _showToast(context, 'Dr. R. Sharma telehealth consultation scheduled!');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildSectionTitle('Social & Reset'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'SIMULATE FAMILY INTERACTION',
                          subtitle: 'Photo card from Ananya',
                          icon: Icons.photo_library_rounded,
                          color: const Color(0xFF6B46C1),
                          onTap: () {
                            store.simulateFamilyInteraction();
                            _showToast(context, 'New family activity received from Ananya!');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'RESET DEMO DATA',
                          subtitle: 'Restore fresh jury baseline',
                          icon: Icons.refresh_rounded,
                          color: AppColors.ink,
                          onTap: () {
                            store.resetDemoData();
                            _showToast(context, 'Demo data reset to clean baseline.');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.muted,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.ink,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
