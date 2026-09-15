import 'package:flutter/material.dart';
import '../constants/colors.dart';

class GentleFeedbackDialog extends StatelessWidget {
  final String title;
  final String message;
  final String positiveActionText;
  final VoidCallback onPositiveAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final IconData icon;

  const GentleFeedbackDialog({
    super.key,
    required this.title,
    required this.message,
    this.positiveActionText = 'Continue',
    required this.onPositiveAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.icon = Icons.spa_outlined,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String positiveActionText = 'Continue',
    required VoidCallback onPositiveAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    IconData icon = Icons.spa_outlined,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GentleFeedbackDialog(
        title: title,
        message: message,
        positiveActionText: positiveActionText,
        onPositiveAction: onPositiveAction,
        secondaryActionText: secondaryActionText,
        onSecondaryAction: onSecondaryAction,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppColors.cream,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.green),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onPositiveAction();
                },
                child: Text(
                  positiveActionText,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (secondaryActionText != null && onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onSecondaryAction!();
                },
                child: Text(
                  secondaryActionText!,
                  style: const TextStyle(fontSize: 17, color: AppColors.muted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
