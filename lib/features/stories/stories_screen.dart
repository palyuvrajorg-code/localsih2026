import 'dart:async';
import 'package:flutter/material.dart';
import '../../store.dart';
import '../../data/models/models.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/smriti_card.dart';

class StoriesScreen extends StatefulWidget {
  final AppStore store;
  const StoriesScreen({super.key, required this.store});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  String _selectedCategory = 'all';
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  final List<String> _categories = [
    'all',
    'recipes',
    'festivals',
    'childhood',
    'traditions',
    'village',
  ];

  void _toggleMockRecording() {
    if (_isRecording) {
      _recordTimer?.cancel();
      setState(() => _isRecording = false);
      _showSaveStoryDialog();
    } else {
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (mounted) setState(() => _recordSeconds++);
      });
    }
  }

  void _showSaveStoryDialog() {
    final titleCtrl = TextEditingController(text: 'Story from the Hearth');
    final descCtrl = TextEditingController(text: 'Remembering the golden fields of mustard and songs sung by the elders.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Save Recorded Story', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Duration: ${_recordSeconds}s recorded'),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Story Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Story Transcription or Summary'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Discard', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                final story = Story(
                  id: 'story-${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  category: 'traditions',
                  narration: descCtrl.text.trim(),
                  durationSeconds: _recordSeconds,
                  recordedDate: 'Recorded just now',
                  tags: ['Family', 'Folk'],
                );
                widget.store.addStory(story);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Story'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;

    return AnimatedBuilder(
      animation: s,
      builder: (context, _) {
        final stories = s.stories.where((st) {
          if (_selectedCategory == 'all') return true;
          return st.category.toLowerCase() == _selectedCategory.toLowerCase();
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            title: const Text(
              'My Stories & Folklore',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Category Filter Chips
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat.toUpperCase()),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.ink,
                        ),
                        selectedColor: AppColors.green,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onSelected: (val) {
                          setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Recording Status Bar
              if (_isRecording)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alertSoftRed,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.alertRed, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record, color: AppColors.alertRed, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Listening & Recording Story... (${_recordSeconds}s)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.alertRed,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertRed,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _toggleMockRecording,
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                ),

              // Stories List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SmritiCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    story.category.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.green,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.muted),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${story.durationSeconds}s',
                                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              story.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              story.narration,
                              style: const TextStyle(fontSize: 16, color: AppColors.ink, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  story.recordedDate,
                                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                                ),
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.sage.withValues(alpha: 0.4),
                                    minimumSize: const Size(44, 44),
                                  ),
                                  icon: const Icon(Icons.play_arrow_rounded, color: AppColors.green, size: 28),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Playing narration: "${story.title}"'),
                                        backgroundColor: AppColors.green,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: _isRecording ? AppColors.alertRed : AppColors.green,
            foregroundColor: Colors.white,
            icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
            label: Text(
              _isRecording ? 'Stop Recording' : 'Record a Story',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: _toggleMockRecording,
          ),
        );
      },
    );
  }
}
