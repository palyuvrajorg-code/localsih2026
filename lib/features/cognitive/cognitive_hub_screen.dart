import 'package:flutter/material.dart';
import '../../store.dart';
import '../../core/constants/colors.dart';
import '../../core/services/adaptive_engine.dart';
import '../../data/models/models.dart';
import 'memory_match/memory_match_screen.dart';
import 'memory_matrix/memory_matrix_screen.dart';
import 'sequence_recall/sequence_recall_screen.dart';
import 'digital_loom/digital_loom_screen.dart';
import 'mini_games/mini_games_screens.dart';

class CognitiveHubScreen extends StatelessWidget {
  final AppStore store;
  const CognitiveHubScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final recentResults = store.sessions.map((m) => GameResult.fromJson(m)).toList();
        final performance = AdaptiveCognitiveEngine.summarizePerformance(recentResults);

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            title: const Text(
              'Brain Activities',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Medical disclaimer & calm tone banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.spa_outlined, color: AppColors.green, size: 30),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Evidence-informed cognitive stimulation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Designed for joy, gentle engagement, and calm focus. Take your time.',
                              style: TextStyle(fontSize: 13, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Activity Performance & Personalization card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_graph_rounded, color: AppColors.green, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Activity Performance & Personalization',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Sessions', '${performance['totalSessions']}'),
                          _buildStatItem(
                            'Accuracy',
                            '${((performance['averageAccuracy'] as double) * 100).toInt()}%',
                          ),
                          _buildStatItem('Response', '${performance['averageResponseMs']}ms'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.sage.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.recommend_rounded, color: AppColors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Recommended today: ${performance['recommendedDomain']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Priority Games Header
                const Text(
                  'PRIORITY CULTURAL ACTIVITIES',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 12),

                // Priority 1: Memory Match
                _buildGameCard(
                  context,
                  title: '1. Cultural Memory Match',
                  subtitle: 'Assamese Japi, Mizo Puan, and Hornbill symbol recall',
                  tag: 'Visual Working Memory',
                  icon: Icons.wb_sunny_rounded,
                  color: AppColors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemoryMatchScreen(store: store, nBack: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Priority 2: Memory Matrix
                _buildGameCard(
                  context,
                  title: '2. Memory Matrix (Bamboo Weave)',
                  subtitle: 'Recreate spatial highlights in 3×3 and 4×4 textile matrices',
                  tag: 'Spatial Working Memory',
                  icon: Icons.grid_on_rounded,
                  color: const Color(0xFF2B6CB0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemoryMatrixScreen(store: store, gridDimension: 3),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Priority 3: Sequence Recall
                _buildGameCard(
                  context,
                  title: '3. Sequence Recall: Folk Rhythms',
                  subtitle: 'Listen to Dhol, Pepa, and Gogona melodic sequences',
                  tag: 'Auditory Working Memory',
                  icon: Icons.music_note_rounded,
                  color: AppColors.rust,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SequenceRecallScreen(store: store),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Priority 4: Digital Loom
                _buildGameCard(
                  context,
                  title: '4. Digital Loom: Silk Pattern',
                  subtitle: 'Weave Muga silk and terracotta yarn into symmetrical motifs',
                  tag: 'Visuospatial Construction',
                  icon: Icons.texture_rounded,
                  color: AppColors.gold,
                  textColor: AppColors.ink,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DigitalLoomScreen(store: store, loomSize: 4),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Extended Activities Header
                const Text(
                  'MORE CULTURAL ACTIVITIES',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 12),

                _buildGameCard(
                  context,
                  title: 'Living Root Bridges',
                  subtitle: 'Meghalaya river crossing path reasoning and logic',
                  tag: 'Executive Reasoning',
                  icon: Icons.park_rounded,
                  color: const Color(0xFF276749),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CulturalMiniGameScreen(
                          store: store,
                          gameId: 'root_bridges',
                          title: 'Living Root Bridges',
                          subtitle: 'Meghalaya River Crossing',
                          instruction: 'Which living tree provides the aerial roots guided by the Khasi tribes to bridge streams?',
                          icon: Icons.park_rounded,
                          options: const [
                            'Ficus elastica (Indian Rubber Fig)',
                            'Bamboo shoot cluster',
                            'Sal tree trunks',
                          ],
                          correctOptionIndex: 0,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _buildGameCard(
                  context,
                  title: 'Village Bazaar',
                  subtitle: 'Regional market calculation, tea leaves, and local spices',
                  tag: 'Everyday Numeracy',
                  icon: Icons.storefront_rounded,
                  color: AppColors.terracotta,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CulturalMiniGameScreen(
                          store: store,
                          gameId: 'village_bazaar',
                          title: 'Village Bazaar',
                          subtitle: 'Morning Market Selection',
                          instruction: 'At the weekly Haat, if fresh ginger costs ₹20 and mustard oil costs ₹50, how much are both together?',
                          icon: Icons.storefront_rounded,
                          options: const ['₹60', '₹70', '₹80'],
                          correctOptionIndex: 1,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _buildGameCard(
                  context,
                  title: 'Musician’s Courtyard',
                  subtitle: 'Match traditional Northeast instruments with their festive sounds',
                  tag: 'Cultural Association',
                  icon: Icons.audiotrack_rounded,
                  color: const Color(0xFF6B46C1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CulturalMiniGameScreen(
                          store: store,
                          gameId: 'musicians_courtyard',
                          title: 'Musician’s Courtyard',
                          subtitle: 'Festive Instruments',
                          instruction: 'Which buffalo horn instrument heralds the arrival of the spring Rongali Bihu festival?',
                          icon: Icons.audiotrack_rounded,
                          options: const ['Pepa', 'Dhol', 'Gogona'],
                          correctOptionIndex: 0,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.muted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
