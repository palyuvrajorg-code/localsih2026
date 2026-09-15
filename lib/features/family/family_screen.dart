import 'package:flutter/material.dart';
import '../../store.dart';
import '../../data/models/models.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/gentle_feedback_dialog.dart';

class FamilyScreen extends StatelessWidget {
  final AppStore store;
  const FamilyScreen({super.key, required this.store});

  void _openActivity(BuildContext context, FamilyActivity activity) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shared by: ${activity.senderName}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.green),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/courtyard.jpg',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              activity.prompt,
              style: const TextStyle(fontSize: 16, color: AppColors.ink, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              store.completeFamilyActivity(activity.id);
              Navigator.pop(ctx);
              GentleFeedbackDialog.show(
                context: context,
                title: 'Activity Shared with ${activity.senderName}',
                message: 'Your response has been saved and shared with your family.',
                onPositiveAction: () {},
              );
            },
            child: const Text('Mark as Completed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final family = store.familyMembers;
        final activities = store.familyActivities;

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            title: const Text(
              'Family Together',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Family Members Carousel Header
              const Text(
                'MY LOVING FAMILY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: family.length,
                  itemBuilder: (context, index) {
                    final member = family[index];
                    return Container(
                      width: 110,
                      margin: const EdgeInsets.only(right: 14),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: AssetImage(member.photoAsset),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            member.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            member.relationship.split(' ').first,
                            style: const TextStyle(fontSize: 12, color: AppColors.muted),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Shared Family Activities Section
              const Text(
                'ACTIVITIES FROM FAMILY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),

              if (activities.isEmpty)
                const SmritiCard(
                  child: Center(
                    child: Text(
                      'No new family activities today. Ananya will send one soon!',
                      style: TextStyle(fontSize: 16, color: AppColors.muted),
                    ),
                  ),
                )
              else
                ...activities.map((act) {
                  final isDone = act.status == FamilyActivityStatus.completed;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SmritiCard(
                      backgroundColor: isDone ? AppColors.sage.withValues(alpha: 0.3) : Colors.white,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B46C1).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'From ${act.senderName}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF6B46C1),
                                  ),
                                ),
                              ),
                              if (isDone)
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: AppColors.safeGreen, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      'Completed',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.safeGreen,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            act.title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            act.prompt,
                            style: const TextStyle(fontSize: 15, color: AppColors.muted),
                          ),
                          if (!isDone) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () => _openActivity(context, act),
                                child: const Text(
                                  'Open Activity',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
