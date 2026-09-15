import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../store.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/gentle_feedback_dialog.dart';

class DigitalLoomScreen extends StatefulWidget {
  final AppStore store;
  final int loomSize; // 4 or 6

  const DigitalLoomScreen({super.key, required this.store, this.loomSize = 4});

  @override
  State<DigitalLoomScreen> createState() => _DigitalLoomScreenState();
}

class _DigitalLoomScreenState extends State<DigitalLoomScreen> {
  final List<Color> _loomPalette = const [
    Color(0xFFB35436), // Madder terracotta
    Color(0xFF315C49), // Indigo forest green
    Color(0xFFD4AF37), // Muga golden silk
    Color(0xFF2B6CB0), // Traditional blue
  ];

  late int _currentColorIndex;
  late List<int> _targetMotif;
  late List<int> _userCanvas;
  bool _showingPattern = true;
  late DateTime _startTime;
  int _hintsUsed = 0;

  @override
  void initState() {
    super.initState();
    _currentColorIndex = 0;
    _startTime = DateTime.now();
    _generateLoomPattern();
  }

  void _generateLoomPattern() {
    final rand = Random();
    final total = widget.loomSize * widget.loomSize;
    _targetMotif = List.generate(total, (_) => rand.nextInt(_loomPalette.length));
    _userCanvas = List.filled(total, -1);
    _showingPattern = true;

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _showingPattern = false);
      }
    });
  }

  void _onThreadTapped(int index) {
    if (_showingPattern) return;
    setState(() {
      _userCanvas[index] = _currentColorIndex;
    });
  }

  void _showWeaveHint() {
    _hintsUsed++;
    setState(() => _showingPattern = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showingPattern = false);
    });
  }

  void _verifyWeave() {
    final totalDuration = DateTime.now().difference(_startTime).inMilliseconds;
    int matches = 0;
    for (int i = 0; i < _targetMotif.length; i++) {
      if (_userCanvas[i] == _targetMotif[i]) matches++;
    }
    final accuracy = matches / _targetMotif.length;

    widget.store.record(
      'loom',
      'visuospatial_pattern_reproduction',
      _targetMotif.length,
      matches,
      _hintsUsed,
      totalDuration,
    );

    GentleFeedbackDialog.show(
      context: context,
      title: 'Sacred Loom Complete',
      message: accuracy >= 0.7
          ? 'Your woven motif reflects peace and balanced attention.'
          : 'Every row woven with calm intention exercises hand-eye harmony.',
      positiveActionText: 'Save & Return',
      onPositiveAction: () => Navigator.pop(context),
      secondaryActionText: 'Weave Again',
      onSecondaryAction: () {
        setState(() {
          _generateLoomPattern();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalThreads = widget.loomSize * widget.loomSize;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: Text(
          'Digital Loom (${widget.loomSize}×${widget.loomSize} Weave)',
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.texture_rounded, color: AppColors.green, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _showingPattern
                            ? 'Memorize the colors of the silk textile pattern.'
                            : 'Select a thread color below, then tap squares to weave.',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Loom Grid
              Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F2E7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.rust.withValues(alpha: 0.35), width: 3),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.loomSize,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: totalThreads,
                      itemBuilder: (context, index) {
                        Color tileColor;
                        if (_showingPattern) {
                          tileColor = _loomPalette[_targetMotif[index]];
                        } else {
                          final userColorIdx = _userCanvas[index];
                          tileColor = userColorIdx == -1 ? Colors.white : _loomPalette[userColorIdx];
                        }

                        return GestureDetector(
                          onTap: () => _onThreadTapped(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.line, width: 1.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Thread Palette Selector
              if (!_showingPattern) ...[
                const Text(
                  'Choose Silk Thread:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_loomPalette.length, (idx) {
                    final isSelected = _currentColorIndex == idx;
                    return GestureDetector(
                      onTap: () => setState(() => _currentColorIndex = idx),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _loomPalette[idx],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.ink : Colors.transparent,
                            width: 3.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: _loomPalette[idx].withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],

              // Controls
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.line, width: 2),
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: _showingPattern ? null : _showWeaveHint,
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text('Peek Pattern', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: _showingPattern ? null : _verifyWeave,
                      child: const Text('Done Weaving', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
