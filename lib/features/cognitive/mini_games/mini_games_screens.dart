import 'package:flutter/material.dart';
import '../../../store.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/gentle_feedback_dialog.dart';

/// Simplified playable implementation for extended cognitive stimulation activities
class CulturalMiniGameScreen extends StatefulWidget {
  final AppStore store;
  final String gameId;
  final String title;
  final String subtitle;
  final String instruction;
  final IconData icon;
  final List<String> options;
  final int correctOptionIndex;

  const CulturalMiniGameScreen({
    super.key,
    required this.store,
    required this.gameId,
    required this.title,
    required this.subtitle,
    required this.instruction,
    required this.icon,
    required this.options,
    required this.correctOptionIndex,
  });

  @override
  State<CulturalMiniGameScreen> createState() => _CulturalMiniGameScreenState();
}

class _CulturalMiniGameScreenState extends State<CulturalMiniGameScreen> {
  int? _selectedIndex;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  void _submitChoice(int index) {
    setState(() => _selectedIndex = index);
    final isCorrect = index == widget.correctOptionIndex;
    final totalDuration = DateTime.now().difference(_startTime).inMilliseconds;

    widget.store.record(
      widget.gameId,
      'cognitive_stimulation',
      1,
      isCorrect ? 1 : 0,
      0,
      totalDuration,
    );

    GentleFeedbackDialog.show(
      context: context,
      title: isCorrect ? 'Wonderful choice!' : 'A thoughtful moment.',
      message: isCorrect
          ? 'You remembered the cultural connection accurately.'
          : 'Reflecting on traditions keeps our stories and mental agility vivid.',
      positiveActionText: 'Save & Return',
      onPositiveAction: () => Navigator.pop(context),
      secondaryActionText: 'Try Another Question',
      onSecondaryAction: () {
        setState(() {
          _selectedIndex = null;
          _startTime = DateTime.now();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.line, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.icon, size: 36, color: AppColors.green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: const TextStyle(fontSize: 14, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Instruction / Question
              Text(
                widget.instruction,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),

              // Options
              ...List.generate(widget.options.length, (idx) {
                final isSelected = _selectedIndex == idx;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isSelected ? AppColors.green : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 1,
                    child: InkWell(
                      onTap: () => _submitChoice(idx),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? AppColors.green : AppColors.line,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isSelected
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : AppColors.sage,
                              child: Text(
                                String.fromCharCode(65 + idx),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: isSelected ? Colors.white : AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.options[idx],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),
              const Center(
                child: Text(
                  'Take your time. Every moment engaged is valued.',
                  style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
