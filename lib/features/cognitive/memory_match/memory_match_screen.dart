import 'dart:math';
import 'package:flutter/material.dart';
import '../../../store.dart';
import '../../../data/models/models.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/cultural_motifs.dart';
import '../../../core/widgets/gentle_feedback_dialog.dart';

class MemoryMatchScreen extends StatefulWidget {
  final AppStore store;
  final int nBack; // 1 or 2
  const MemoryMatchScreen({super.key, required this.store, this.nBack = 1});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  final List<CulturalSymbol> _symbols = CulturalMotifs.matchSymbols;
  late final List<CulturalSymbol> _stream;
  int _currentIndex = 0;
  int _score = 0;
  int _attempts = 0;
  final int _totalRounds = 8;
  late DateTime _startTime;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _generateStream();
  }

  void _generateStream() {
    final rand = Random();
    _stream = [];
    for (int i = 0; i < _totalRounds; i++) {
      if (i >= widget.nBack && rand.nextDouble() < 0.45) {
        // Repeat item from nBack turns ago
        _stream.add(_stream[i - widget.nBack]);
      } else {
        _stream.add(_symbols[rand.nextInt(_symbols.length)]);
      }
    }
  }

  void _handleChoice(bool elderSaidMatch) {
    if (_finished) return;

    final bool isActuallyMatch = _currentIndex >= widget.nBack &&
        _stream[_currentIndex].id == _stream[_currentIndex - widget.nBack].id;

    _attempts++;
    if (elderSaidMatch == isActuallyMatch) {
      _score++;
    }

    if (_currentIndex + 1 < _stream.length) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    _finished = true;
    final totalDuration = DateTime.now().difference(_startTime).inMilliseconds;
    final double accuracy = _attempts > 0 ? _score / _attempts : 0.0;

    // Record GameResult
    final result = GameResult(
      gameId: 'match',
      gameName: 'Cultural Memory Match (${widget.nBack}-Back)',
      timestamp: DateTime.now(),
      level: widget.nBack == 1 ? 1 : 2,
      accuracy: accuracy,
      responseTime: totalDuration,
      attempts: _attempts,
      assistanceNeeded: 0,
      completed: true,
      difficulty: widget.nBack == 1 ? 'Gentle' : 'Adaptive',
    );

    widget.store.syncEngine.enqueue('game_result', result.toJson());

    widget.store.record(
      'match',
      'visual_working_memory',
      _attempts,
      _score,
      0,
      totalDuration,
    );

    GentleFeedbackDialog.show(
      context: context,
      title: 'Nice work, Kamala!',
      message: 'You completed this session calmly and attentively. Every moment engaged supports active thinking.',
      positiveActionText: 'Save & Return',
      onPositiveAction: () => Navigator.pop(context),
      secondaryActionText: 'Play Again',
      onSecondaryAction: () {
        setState(() {
          _currentIndex = 0;
          _score = 0;
          _attempts = 0;
          _finished = false;
          _startTime = DateTime.now();
          _generateStream();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSymbol = _stream[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: Text(
          'Memory Match (${widget.nBack}-Back)',
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Calm guidance banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.spa_outlined, color: AppColors.green, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentIndex < widget.nBack
                            ? 'Remember this symbol. Does the next symbol match it?'
                            : widget.nBack == 1
                                ? 'Does this match the previous symbol?'
                                : 'Does this match the symbol from 2 cards ago?',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Cultural Symbol Card
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: currentSymbol.accentColor.withValues(alpha: 0.4), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: currentSymbol.accentColor.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: currentSymbol.accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(currentSymbol.icon, size: 84, color: currentSymbol.accentColor),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentSymbol.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentSymbol.region,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: currentSymbol.accentColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentSymbol.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Pacing reminder
              const Text(
                'Take your time.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              if (_currentIndex < widget.nBack)
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => setState(() => _currentIndex++),
                    child: const Text(
                      'I have seen it — Next',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 64,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            side: const BorderSide(color: AppColors.line, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => _handleChoice(false),
                          icon: const Icon(Icons.close_rounded, size: 26),
                          label: const Text(
                            'Different',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 64,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => _handleChoice(true),
                          icon: const Icon(Icons.check_rounded, size: 26),
                          label: const Text(
                            'Matches',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
