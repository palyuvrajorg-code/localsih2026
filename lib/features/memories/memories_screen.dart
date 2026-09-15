import 'package:flutter/material.dart';
import '../../store.dart';
import '../../data/models/models.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/smriti_card.dart';

class MemoriesScreen extends StatefulWidget {
  final AppStore store;
  const MemoriesScreen({super.key, required this.store});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final List<MemoryItem> _defaultMemories = [
    const MemoryItem(
      id: 'mem-1975',
      title: 'Wedding Ceremony in Jorhat',
      year: '1975',
      person: 'Kamala Devi & Late Bhaben Phukan',
      place: 'Jorhat, Assam',
      occasion: 'Traditional Assamese Wedding',
      description: 'Dressed in heirloom golden Muga silk mekhela sador with royal japi decorations and shehnai music.',
      imageAsset: 'assets/images/temple.jpg',
      tags: ['Wedding', 'Family', 'Jorhat'],
    ),
    const MemoryItem(
      id: 'mem-1984',
      title: 'First Family Home in Guwahati',
      year: '1984',
      person: 'Kamala & Family',
      place: 'Ulubari, Guwahati',
      occasion: 'Housewarming Blessing',
      description: 'Moving into the house with our small garden of betel nuts and night-blooming jasmine.',
      imageAsset: 'assets/images/courtyard.jpg',
      tags: ['Home', 'Milestone', 'Guwahati'],
    ),
    const MemoryItem(
      id: 'mem-1992',
      title: 'Village Bihu Festival',
      year: '1992',
      person: 'Village Gathering',
      place: 'Titabar Village',
      occasion: 'Rongali Bihu Celebrations',
      description: 'Dancing in the courtyard with relatives, playing dhol and sharing hot pitha with neighbors.',
      imageAsset: 'assets/images/lotus.jpg',
      tags: ['Bihu', 'Festivals', 'Culture'],
    ),
    const MemoryItem(
      id: 'mem-2001',
      title: 'Granddaughter Ananya Born',
      year: '2001',
      person: 'Baby Ananya & Grandmother',
      place: 'Guwahati Hospital',
      occasion: 'Arrival of First Grandchild',
      description: 'Holding little Ananya for the first time. The entire family celebrated with sandesh and sweets.',
      imageAsset: 'assets/images/courtyard.jpg',
      tags: ['Ananya', 'Grandchild', 'Joy'],
    ),
  ];

  void _showAddMemoryDialog() {
    final titleCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: '2026');
    final personCtrl = TextEditingController();
    final placeCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add a Cherished Memory', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Memory Title (e.g. Garden Harvest)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearCtrl,
                decoration: const InputDecoration(labelText: 'Year (e.g. 1995)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: personCtrl,
                decoration: const InputDecoration(labelText: 'Who was there? (e.g. Ananya & Bhaskar)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: placeCtrl,
                decoration: const InputDecoration(labelText: 'Where was this? (e.g. Jorhat)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Short Story or Memory'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                final newItem = MemoryItem(
                  id: 'mem-${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  year: yearCtrl.text.trim(),
                  person: personCtrl.text.trim(),
                  place: placeCtrl.text.trim(),
                  occasion: 'Family Remembrance',
                  description: descCtrl.text.trim(),
                  imageAsset: 'assets/images/courtyard.jpg',
                  tags: ['Family', 'Remembrance'],
                );
                widget.store.addMemory(newItem);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Memory'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Memory?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to remove this memory from your timeline?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.store.deleteMemory(id);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;

    return AnimatedBuilder(
      animation: s,
      builder: (context, _) {
        final customMemories = s.memories.map((m) => MemoryItem.fromJson(m)).toList();
        final allItems = [...customMemories, ..._defaultMemories];

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            title: const Text(
              'My Memories Timeline',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.green, size: 28),
                tooltip: 'Add Memory',
                onPressed: _showAddMemoryDialog,
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final memory = allItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SmritiCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Header
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Stack(
                          children: [
                            Image.asset(
                              memory.imageAsset ?? 'assets/images/courtyard.jpg',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.ink.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  memory.year,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              right: 14,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                                  minimumSize: const Size(40, 40),
                                ),
                                icon: const Icon(Icons.delete_outline, color: AppColors.alertRed, size: 20),
                                onPressed: () => _confirmDelete(memory.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Details
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              memory.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.place_outlined, size: 18, color: AppColors.muted),
                                const SizedBox(width: 4),
                                Text(
                                  memory.place,
                                  style: const TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 14),
                                const Icon(Icons.people_outline, size: 18, color: AppColors.muted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    memory.person,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              memory.description,
                              style: const TextStyle(fontSize: 16, color: AppColors.ink, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Memory', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: _showAddMemoryDialog,
          ),
        );
      },
    );
  }
}
