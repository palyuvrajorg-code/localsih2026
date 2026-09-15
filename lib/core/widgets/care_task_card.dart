import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../constants/colors.dart';
import 'smriti_card.dart';

class CareTaskCard extends StatelessWidget {
  final CareTask task;
  final VoidCallback? onConfirm;
  final VoidCallback? onMiss;

  const CareTaskCard({
    super.key,
    required this.task,
    this.onConfirm,
    this.onMiss,
  });

  IconData _getCategoryIcon() {
    switch (task.category) {
      case TaskCategory.medication:
        return Icons.medication_rounded;
      case TaskCategory.hydration:
        return Icons.water_drop_rounded;
      case TaskCategory.meal:
        return Icons.restaurant_rounded;
      case TaskCategory.cognitive:
        return Icons.psychology_rounded;
      case TaskCategory.family:
        return Icons.diversity_1_rounded;
      case TaskCategory.appointment:
        return Icons.calendar_month_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color _getCategoryColor() {
    switch (task.category) {
      case TaskCategory.medication:
        return AppColors.green;
      case TaskCategory.hydration:
        return const Color(0xFF2B6CB0);
      case TaskCategory.meal:
        return AppColors.rust;
      case TaskCategory.cognitive:
        return const Color(0xFF6B46C1);
      default:
        return AppColors.ink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final bool isDone = task.isCompleted;
    final bool isMissed = task.isMissed;

    return SmritiCard(
      backgroundColor: isDone
          ? AppColors.sage.withValues(alpha: 0.35)
          : isMissed
              ? AppColors.alertSoftRed.withValues(alpha: 0.5)
              : Colors.white,
      padding: const EdgeInsets.all(18),
      border: Border.all(
        color: isDone
            ? AppColors.safeGreen.withValues(alpha: 0.6)
            : isMissed
                ? AppColors.alertRed.withValues(alpha: 0.4)
                : AppColors.line,
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getCategoryIcon(), color: categoryColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.ink.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.time,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (isDone)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.safeGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, size: 16, color: AppColors.safeGreen),
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
                          )
                        else if (isMissed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.alertRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Follow-up',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.alertRed,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.dosage != null || task.instructions != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${task.dosage ?? ''} ${task.instructions ?? ''}'.trim(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isDone) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check, size: 24),
                    label: const Text(
                      'I Completed This',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (onMiss != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(52, 52),
                      padding: const EdgeInsets.all(12),
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: onMiss,
                    child: const Icon(Icons.close, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
