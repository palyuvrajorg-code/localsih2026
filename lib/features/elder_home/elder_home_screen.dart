import 'package:flutter/material.dart';
import '../../store.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/care_task_card.dart';
import '../../core/widgets/safety_check_dialog.dart';
import '../care/care_screen.dart';
import '../cognitive/cognitive_hub_screen.dart';
import '../memories/memories_screen.dart';
import '../family/family_screen.dart';
import '../voice/talk_to_smriti_screen.dart';
import '../stories/stories_screen.dart';
import '../safety/safety_screen.dart';

class ElderHomeScreen extends StatefulWidget {
  final AppStore store;
  final Function(int)? onNavigateTab;

  const ElderHomeScreen({super.key, required this.store, this.onNavigateTab});

  @override
  State<ElderHomeScreen> createState() => _ElderHomeScreenState();
}

class _ElderHomeScreenState extends State<ElderHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSafetyDialog();
    });
  }

  void _checkSafetyDialog() {
    if (widget.store.safetyEngine.anomalyActive) {
      SafetyCheckDialog.showIfActive(context, widget.store);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final w = s.w;

    return AnimatedBuilder(
      animation: Listenable.merge([s, s.safetyEngine]),
      builder: (context, _) {
        if (s.safetyEngine.anomalyActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkSafetyDialog());
        }

        final tasks = s.careTasks;
        final pendingTasks = tasks.where((t) => !t.isCompleted).take(3).toList();

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Profile Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: TextStyle(
                              fontSize: s.fontSize * 0.9,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            s.elderProfile.name,
                            style: TextStyle(
                              fontSize: s.fontSize * 1.5,
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TalkToSmritiScreen(store: s),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.green.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.mic, color: Colors.white, size: 24),
                              SizedBox(width: 6),
                              Text(
                                'TALK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Big Action Quick Grid (Elder-friendly large touch targets)
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          title: 'PLAY',
                          subtitle: 'Brain Activities',
                          icon: Icons.psychology_rounded,
                          color: AppColors.green,
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(2); // PLAY tab
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CognitiveHubScreen(store: s),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildActionTile(
                          title: 'MY CARE',
                          subtitle: 'Daily Plan & Pills',
                          icon: Icons.favorite_rounded,
                          color: AppColors.terracotta,
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(1); // CARE tab
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CareScreen(store: s),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          title: 'MY FAMILY',
                          subtitle: 'Activities & Calls',
                          icon: Icons.diversity_1_rounded,
                          color: const Color(0xFF2B6CB0),
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(4); // FAMILY tab
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FamilyScreen(store: s),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildActionTile(
                          title: 'MY MEMORIES',
                          subtitle: 'Photo Timeline',
                          icon: Icons.photo_library_rounded,
                          color: const Color(0xFF6B46C1),
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(3); // MEMORIES tab
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MemoriesScreen(store: s),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          title: 'MY STORIES',
                          subtitle: 'Folk Tales & Voice',
                          icon: Icons.menu_book_rounded,
                          color: AppColors.gold,
                          textColor: AppColors.ink,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StoriesScreen(store: s),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildActionTile(
                          title: 'SAFETY',
                          subtitle: 'Check & Location',
                          icon: Icons.shield_rounded,
                          color: AppColors.ink,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SafetyScreen(store: s),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Today's Care Plan Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TODAY’S CARE PLAN',
                        style: TextStyle(
                          fontSize: s.fontSize * 0.85,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.ink,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CareScreen(store: s)),
                            );
                          }
                        },
                        child: Text(
                          'View All (${tasks.length})',
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Today's Upcoming Care Tasks
                  if (pendingTasks.isEmpty)
                    SmritiCard(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.safeGreen, size: 36),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All caught up for now!',
                                  style: TextStyle(
                                    fontSize: s.fontSize * 0.95,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'You have completed all scheduled activities so far.',
                                  style: TextStyle(fontSize: 14, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...pendingTasks.map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CareTaskCard(
                            task: task,
                            onConfirm: () => s.completeTask(task.id),
                            onMiss: () => s.missTask(task.id),
                          ),
                        )),

                  const SizedBox(height: 20),

                  // Hydration Quick Log Card
                  SmritiCard(
                    backgroundColor: const Color(0xFFEBF8FF),
                    border: Border.all(color: const Color(0xFFBEE3F8), width: 1.5),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3182CE).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.water_drop_rounded, color: Color(0xFF3182CE), size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Hydration: ${s.hydrationGlassesTaken}/${s.targetHydration} Glasses',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2B6CB0),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Drinking water keeps mind and body refreshed.',
                                style: TextStyle(fontSize: 14, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3182CE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onPressed: () => s.logHydration(),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 18),
                              SizedBox(width: 2),
                              Text('Drink', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: textColor, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
