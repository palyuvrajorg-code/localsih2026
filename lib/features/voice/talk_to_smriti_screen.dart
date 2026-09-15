import 'package:flutter/material.dart';
import '../../store.dart';
import '../../core/constants/colors.dart';
import '../../core/services/voice_engine.dart';
import '../cognitive/cognitive_hub_screen.dart';
import '../memories/memories_screen.dart';
import '../care/care_screen.dart';
import '../safety/safety_screen.dart';

class TalkToSmritiScreen extends StatefulWidget {
  final AppStore store;
  const TalkToSmritiScreen({super.key, required this.store});

  @override
  State<TalkToSmritiScreen> createState() => _TalkToSmritiScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final ParsedIntent? intent;

  _ChatMessage({required this.text, required this.isUser, this.intent});
}

class _TalkToSmritiScreenState extends State<TalkToSmritiScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isListening = false;

  final List<String> _quickSuggestions = [
    'I took my morning medicine',
    'I drank a glass of water',
    'Open Memory Matrix game',
    'What is my plan today?',
    'Show my family memories',
    'Call for help',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text: 'Namaste Kamala! I am SMRITI, your caring companion. How can I help you right now?',
        isUser: false,
      ),
    );
  }

  Future<void> _handleUserUtterance(String text) async {
    if (text.trim().isEmpty) return;
    _textCtrl.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });

    final parsed = await widget.store.voiceService.parseUtterance(text);

    setState(() {
      _messages.add(
        _ChatMessage(
          text: parsed.responseText,
          isUser: false,
          intent: parsed,
        ),
      );
    });
  }

  void _executeIntentAction(ParsedIntent intent) {
    final s = widget.store;
    switch (intent.type) {
      case IntentType.completeMedication:
        final med = s.careTasks.firstWhere(
          (t) => t.category == TaskCategory.medication && !t.isCompleted,
          orElse: () => s.careTasks.first,
        );
        s.completeTask(med.id);
        setState(() {
          _messages.add(
            _ChatMessage(
              text: 'Done! I have marked "${med.title}" as completed and notified Ananya.',
              isUser: false,
            ),
          );
        });
        break;

      case IntentType.logHydration:
        s.logHydration();
        setState(() {
          _messages.add(
            _ChatMessage(
              text: 'Wonderful! Recorded 1 glass of water (${s.hydrationGlassesTaken}/${s.targetHydration} completed).',
              isUser: false,
            ),
          );
        });
        break;

      case IntentType.openGames:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CognitiveHubScreen(store: s)),
        );
        break;

      case IntentType.openMemories:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MemoriesScreen(store: s)),
        );
        break;

      case IntentType.getTodayPlan:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CareScreen(store: s)),
        );
        break;

      case IntentType.emergencyHelp:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SafetyScreen(store: s)),
        );
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Row(
          children: [
            Icon(Icons.spa_rounded, color: AppColors.green),
            SizedBox(width: 8),
            Text(
              'Talk to SMRITI',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Suggestions Strip
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickSuggestions.length,
              itemBuilder: (context, idx) {
                final suggestion = _quickSuggestions[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.line),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    label: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                    onPressed: () => _handleUserUtterance(suggestion),
                  ),
                );
              },
            ),
          ),

          // Message Stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.green,
                          child: Icon(Icons.spa, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              decoration: BoxDecoration(
                                color: msg.isUser ? AppColors.green : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: msg.isUser ? AppColors.green : AppColors.line,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: msg.isUser ? Colors.white : AppColors.ink,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            // Confirmation / Action trigger button
                            if (msg.intent != null && msg.intent!.requiresConfirmation) ...[
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: AppColors.ink,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () => _executeIntentAction(msg.intent!),
                                icon: const Icon(Icons.check_circle_rounded, size: 20),
                                label: Text(
                                  'Confirm: ${msg.intent!.confirmationPrompt ?? "Proceed"}',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (msg.isUser) ...[
                        const SizedBox(width: 10),
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.rust,
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Speech & Text Input Dock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      decoration: InputDecoration(
                        hintText: 'Speak or type here...',
                        hintStyle: const TextStyle(fontSize: 16, color: AppColors.muted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: _handleUserUtterance,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Mic Button (Live Mock Voice Trigger)
                  GestureDetector(
                    onTap: () {
                      setState(() => _isListening = !_isListening);
                      if (_isListening) {
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted && _isListening) {
                            setState(() => _isListening = false);
                            _handleUserUtterance('I already took my medicine');
                          }
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isListening ? AppColors.alertRed : AppColors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? AppColors.alertRed : AppColors.green).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.green, size: 28),
                    onPressed: () => _handleUserUtterance(_textCtrl.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
