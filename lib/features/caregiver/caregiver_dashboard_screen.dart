import 'package:flutter/material.dart';
import '../../store.dart';
import '../../data/models/models.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/services/adaptive_engine.dart';
import '../care/care_screen.dart';
import '../cognitive/cognitive_hub_screen.dart';
import '../memories/memories_screen.dart';
import '../safety/safety_screen.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  final AppStore store;
  const CaregiverDashboardScreen({super.key, required this.store});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final s = widget.store;

    return AnimatedBuilder(
      animation: Listenable.merge([s, s.safetyEngine, s.locationEngine, s.syncEngine]),
      builder: (context, _) {
        final unresolvedAlerts = s.alerts.where((a) => !a.isResolved).toList();
        final allTasks = s.careTasks;
        final medTasks = allTasks.where((t) => t.category == TaskCategory.medication).toList();
        final medsCompleted = medTasks.where((t) => t.isCompleted).length;
        final routineTasks = allTasks.where((t) => t.category != TaskCategory.medication).toList();
        final routineCompleted = routineTasks.where((t) => t.isCompleted).length;

        final recentSessions = s.sessions.map((m) => GameResult.fromJson(m)).toList();
        final perf = AdaptiveCognitiveEngine.summarizePerformance(recentSessions);

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Caregiver Portal',
                  style: TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Care for ${s.elderProfile.name}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.green),
                tooltip: 'Simulate Sync',
                onPressed: () => s.syncEngine.triggerSync(),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // 1. NEEDS ATTENTION Section
              if (unresolvedAlerts.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.alertSoftRed,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.alertRed, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_rounded, color: AppColors.alertRed, size: 28),
                          const SizedBox(width: 10),
                          const Text(
                            'NEEDS ATTENTION',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.alertRed,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.alertRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${unresolvedAlerts.length} Active',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...unresolvedAlerts.map(
                        (alert) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      alert.message,
                                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.safeGreen.withValues(alpha: 0.15),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () => s.resolveAlert(alert.id),
                                child: const Text(
                                  'Acknowledge',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.safeGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 2. TODAY'S CARE ADHERENCE
              const Text(
                'TODAY’S CARE ADHERENCE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),

              SmritiCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildAdherenceRow(
                      title: 'Medication',
                      countText: '$medsCompleted/${medTasks.length} doses taken',
                      progress: medTasks.isEmpty ? 1.0 : medsCompleted / medTasks.length,
                      color: AppColors.green,
                      icon: Icons.medication_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CareScreen(store: s))),
                    ),
                    const Divider(height: 24, color: AppColors.line),
                    _buildAdherenceRow(
                      title: 'Hydration',
                      countText: '${s.hydrationGlassesTaken}/${s.targetHydration} glasses recorded',
                      progress: (s.hydrationGlassesTaken / s.targetHydration).clamp(0.0, 1.0),
                      color: const Color(0xFF2B6CB0),
                      icon: Icons.water_drop_rounded,
                      onTap: () => s.logHydration(),
                    ),
                    const Divider(height: 24, color: AppColors.line),
                    _buildAdherenceRow(
                      title: 'Brain Activity',
                      countText: '${perf['totalSessions']} sessions engaged',
                      progress: (perf['totalSessions'] as int) > 0 ? 1.0 : 0.0,
                      color: const Color(0xFF6B46C1),
                      icon: Icons.psychology_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CognitiveHubScreen(store: s))),
                    ),
                    const Divider(height: 24, color: AppColors.line),
                    _buildAdherenceRow(
                      title: 'Routine Care',
                      countText: '$routineCompleted/${routineTasks.length} tasks completed',
                      progress: routineTasks.isEmpty ? 1.0 : routineCompleted / routineTasks.length,
                      color: AppColors.rust,
                      icon: Icons.checklist_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CareScreen(store: s))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. ACTIVITY PERFORMANCE & PERSONALIZATION
              const Text(
                'ACTIVITY PERFORMANCE & PERSONALIZATION',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),

              SmritiCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cognitive Stimulation Analytics',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.green),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'Accuracy',
                            '${((perf['averageAccuracy'] as double) * 100).toInt()}%',
                            Icons.check_circle_outline,
                            AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            'Avg Response',
                            '${perf['averageResponseMs']}ms',
                            Icons.speed_rounded,
                            const Color(0xFF2B6CB0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            'Completed',
                            '${((perf['completionRate'] as double) * 100).toInt()}%',
                            Icons.done_all_rounded,
                            AppColors.rust,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Engine Recommendation: ${perf['recommendedDomain']}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. PHONE LOCATION & SAFETY STATUS
              const Text(
                'SAFETY & DEVICE TELEMETRY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),

              SmritiCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              s.locationEngine.currentLocation.isInsideSafeZone
                                  ? Icons.fmd_good_rounded
                                  : Icons.fmd_bad_rounded,
                              color: s.locationEngine.currentLocation.isInsideSafeZone
                                  ? AppColors.safeGreen
                                  : AppColors.alertRed,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Phone Location',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SafetyScreen(store: s))),
                          child: const Text('View Safety Screen', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    Text(
                      s.locationEngine.currentLocation.locationName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.locationEngine.currentLocation.details,
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. CAREGIVER QUICK ACTIONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        s.simulateFamilyInteraction();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sent new photo memory prompt to Kamala!')),
                        );
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Send Activity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MemoriesScreen(store: s))),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('View Memories'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdherenceRow({
    required String title,
    required String countText,
    required double progress,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      Text(
                        countText,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.line,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
