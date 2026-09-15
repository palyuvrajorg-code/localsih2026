import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../store.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/cultural_motifs.dart';
import '../../../core/widgets/gentle_feedback_dialog.dart';

class SequenceRecallScreen extends StatefulWidget {
  final AppStore store;
  const SequenceRecallScreen({super.key, required this.store});

  @override
  State<SequenceRecallScreen> createState() => _SequenceRecallScreenState();
}

class _SequenceRecallScreenState extends State<SequenceRecallScreen> {
  final List<Map<String, dynamic>> _instruments = CulturalMotifs.instruments;
  final List<int> _sequence = [];
  final List<int> _userSequence = [];
  int? _activeInstrumentIndex;
  bool _isPlayingSequence = false;
  int _currentStep = 0;
  final int _targetSteps = 4;
  late DateTime _startTime;
  int _attempts = 0;
  int _correctHits = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startNewRound();
  }

  void _startNewRound() {
    final rand = Random();
    _sequence.clear();
    for (int i = 0; i < _targetSteps; i++) {
      _sequence.add(rand.nextInt(_instruments.length));
    }
    _userSequence.clear();
    _currentStep = 0;
    _playSequence();
  }

  Future<void> _playSequence() async {
    setState(() => _isPlayingSequence = true);
    await Future.delayed(const Duration(milliseconds: 600));

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      final instIndex = _sequence[i];
      setState(() => _activeInstrumentIndex = instIndex);
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() => _activeInstrumentIndex = null);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) {
      setState(() => _isPlayingSequence = false);
    }
  }

  void _onInstrumentTapped(int index) {
    if (_isPlayingSequence) return;

    _attempts++;
    setState(() {
      _activeInstrumentIndex = index;
    });

    Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _activeInstrumentIndex = null);
    });

    if (_sequence[_currentStep] == index) {
      _correctHits++;
      _currentStep++;
      if (_currentStep >= _sequence.length) {
        _finishGame(true);
      }
    } else {
      _finishGame(false);
    }
  }

  void _finishGame(bool success) {
    final totalDuration = DateTime.now().difference(_startTime).inMilliseconds;
    final accuracy = _attempts > 0 ? _correctHits / _attempts : 0.0;

    widget.store.syncEngine.enqueue('game_result', {
      'gameId': 'sequence',
      'accuracy': accuracy,
      'responseTime': totalDuration,
      'completed': success,
    });

    widget.store.record(
      'sequence',
      'auditory_working_memory',
      _attempts,
      _correctHits,
      0,
      totalDuration,
    );

    GentleFeedbackDialog.show(
      context: context,
      title: success ? 'Melodic Harmony!' : 'A peaceful melody together.',
      message: success
          ? 'You recreated the traditional instruments sequence beautifully.'
          : 'Listening to folk rhythms brings calm and mindfulness. Let’s enjoy another listen.',
      positiveActionText: 'Save & Return',
      onPositiveAction: () => Navigator.pop(context),
      secondaryActionText: 'Play Again',
      onSecondaryAction: () {
        setState(() {
          _attempts = 0;
          _correctHits = 0;
          _startTime = DateTime.now();
          _startNewRound();
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
        title: const Text(
          'Sequence Recall: Folk Rhythms',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
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
                    const Icon(Icons.music_note_rounded, color: AppColors.green, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isPlayingSequence
                            ? 'Watch and listen to the instrument pattern...'
                            : 'Repeat the pattern in order.',
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

              // 2x2 Grid of Instruments
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _instruments.length,
                itemBuilder: (context, index) {
                  final inst = _instruments[index];
                  final isActive = _activeInstrumentIndex == index;
                  final color = inst['color'] as Color;

                  return GestureDetector(
                    onTap: () => _onInstrumentTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isActive ? color : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: color.withValues(alpha: 0.6),
                          width: isActive ? 4 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isActive ? color.withValues(alpha: 0.4) : Colors.black12,
                            blurRadius: isActive ? 16 : 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            inst['icon'] as IconData,
                            size: 48,
                            color: isActive ? Colors.white : color,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            inst['name'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.white : AppColors.ink,
                            ),
                          ),
                          Text(
                            inst['region'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive ? Colors.white70 : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              const Text(
                'Take your time. Listen with calm attention.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    side: const BorderSide(color: AppColors.green, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _isPlayingSequence ? null : _playSequence,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Hear Pattern Again', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
