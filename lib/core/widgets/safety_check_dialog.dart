import 'dart:async';
import 'package:flutter/material.dart';
import '../../store.dart';
import '../constants/colors.dart';

class SafetyCheckDialog extends StatefulWidget {
  final AppStore store;
  const SafetyCheckDialog({super.key, required this.store});

  static void showIfActive(BuildContext context, AppStore store) {
    if (store.safetyEngine.anomalyActive) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => SafetyCheckDialog(store: store),
      );
    }
  }

  @override
  State<SafetyCheckDialog> createState() => _SafetyCheckDialogState();
}

class _SafetyCheckDialogState extends State<SafetyCheckDialog> {
  int _countdown = 25;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        _escalateNoResponse();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _escalateNoResponse() {
    widget.store.safetyEngine.escalateAnomalyHelp(
      reason: 'No response after 25 seconds check-in window.',
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppColors.cream,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.alertRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.health_and_safety_rounded, size: 54, color: AppColors.alertRed),
            ),
            const SizedBox(height: 18),
            const Text(
              'Kamala, are you okay?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'We noticed an unusual stillness. Please tap below to let Ananya know you are safe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Alerting family in $_countdown s',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.alertRed,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  _timer?.cancel();
                  widget.store.safetyEngine.resolveAnomalySafe();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline, size: 28),
                label: const Text(
                  'I AM OKAY',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.alertRed,
                  side: const BorderSide(color: AppColors.alertRed, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  _timer?.cancel();
                  widget.store.safetyEngine.escalateAnomalyHelp(
                    reason: 'Elder tapped "Need Help" button.',
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.sos_rounded, size: 24),
                label: const Text(
                  'NEED HELP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                _escalateNoResponse();
              },
              child: const Text(
                'Simulate No Response (Jury Demo)',
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
