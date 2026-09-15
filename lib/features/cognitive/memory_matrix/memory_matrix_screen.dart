import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../store.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/gentle_feedback_dialog.dart';

class MemoryMatrixScreen extends StatefulWidget {
  final AppStore store;
  final int gridDimension; // 3, 4, or 5

  const MemoryMatrixScreen({
    super.key,
    required this.store,
    this.gridDimension = 3,
  });

  @override
  State<MemoryMatrixScreen> createState() => _MemoryMatrixScreenState();
}

enum MatrixState { showingPattern, waitingForInput, completed }

class _MemoryMatrixScreenState extends State<MemoryMatrixScreen> {
  late int _dim;
  late Set<int> _targetCells;
  final Set<int> _selectedCells = {};
  MatrixState _state = MatrixState.showingPattern;
  late DateTime _startTime;
  int _hintsUsed = 0;

  @override
  void initState() {
    super.initState();
    _dim = widget.gridDimension;
    _startTime = DateTime.now();
    _generatePattern();
  }

  void _generatePattern() {
    final rand = Random();
    final totalCells = _dim * _dim;
    final targetCount = _dim == 3 ? 3 : (_dim == 4 ? 5 : 7);
    _targetCells = {};

    while (_targetCells.length < targetCount) {
      _targetCells.add(rand.nextInt(totalCells));
    }

    _selectedCells.clear();
    _state = MatrixState.showingPattern;

    // Show pattern for 3 seconds then hide
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _state = MatrixState.waitingForInput;
        });
      }
    });
  }

  void _onCellTapped(int index) {
    if (_state != MatrixState.waitingForInput) return;

    setState(() {
      if (_selectedCells.contains(index)) {
        _selectedCells.remove(index);
      } else {
        _selectedCells.add(index);
      }
    });

    if (_selectedCells.length == _targetCells.length) {
      _checkCompletion();
    }
  }

  void _showHint() {
    _hintsUsed++;
    setState(() {
      _state = MatrixState.showingPattern;
    });
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _state = MatrixState.waitingForInput;
        });
      }
    });
  }

  void _checkCompletion() {
    _state = MatrixState.completed;
    final totalDuration = DateTime.now().difference(_startTime).inMilliseconds;

    int correct = 0;
    for (var idx in _selectedCells) {
      if (_targetCells.contains(idx)) correct++;
    }

    final double accuracy = correct / _targetCells.length;

    // Save result
    widget.store.record(
      'matrix',
      'spatial_working_memory',
      _targetCells.length,
      correct,
      _hintsUsed,
      totalDuration,
    );

    GentleFeedbackDialog.show(
      context: context,
      title: accuracy >= 0.7 ? 'Lovely work, Kamala!' : 'Let’s try that one together.',
      message: accuracy >= 0.7
          ? 'You remembered the weave pattern splendidly.'
          : 'Traditional weaving takes patience. Every trial strengthens visual memory.',
      positiveActionText: 'Save & Return',
      onPositiveAction: () => Navigator.pop(context),
      secondaryActionText: 'Next Pattern',
      onSecondaryAction: () {
        setState(() {
          _generatePattern();
        });
      },
    );
  }

  String get _themeTitle {
    switch (_dim) {
      case 3:
        return '3×3 Bamboo Weave Grid';
      case 4:
        return '4×4 Puan Textile Matrix';
      default:
        return '5×5 Thangka-inspired Grid';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCells = _dim * _dim;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: Text(
          _themeTitle,
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Instructions banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.grid_on_rounded, color: AppColors.green, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _state == MatrixState.showingPattern
                            ? 'Memorize the highlighted bamboo squares.'
                            : 'Tap the squares you remember from the weave.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Grid Container
              Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDE2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.rust.withValues(alpha: 0.3), width: 3),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _dim,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: totalCells,
                      itemBuilder: (context, index) {
                        final isTarget = _targetCells.contains(index);
                        final isSelected = _selectedCells.contains(index);

                        Color cellColor;
                        if (_state == MatrixState.showingPattern) {
                          cellColor = isTarget ? AppColors.green : Colors.white;
                        } else {
                          cellColor = isSelected ? AppColors.green : Colors.white;
                        }

                        return GestureDetector(
                          onTap: () => _onCellTapped(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected || (_state == MatrixState.showingPattern && isTarget)
                                    ? AppColors.green
                                    : AppColors.line,
                                width: 2,
                              ),
                              boxShadow: [
                                if (isSelected || (_state == MatrixState.showingPattern && isTarget))
                                  BoxShadow(
                                    color: AppColors.green.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: isSelected || (_state == MatrixState.showingPattern && isTarget)
                                  ? const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 28)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const Spacer(),

              const Text(
                'Take your time. There’s no rush.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),

              // Bottom control buttons
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
                      onPressed: _state == MatrixState.waitingForInput ? _showHint : null,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Show Pattern', style: TextStyle(fontSize: 17)),
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
                      onPressed: _selectedCells.isNotEmpty ? _checkCompletion : null,
                      child: const Text('Check', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
