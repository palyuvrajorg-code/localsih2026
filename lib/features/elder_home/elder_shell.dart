import 'package:flutter/material.dart';
import '../../store.dart';
import '../../core/constants/colors.dart';
import 'elder_home_screen.dart';
import '../care/care_screen.dart';
import '../cognitive/cognitive_hub_screen.dart';
import '../memories/memories_screen.dart';
import '../family/family_screen.dart';

class ElderShell extends StatefulWidget {
  final AppStore store;
  const ElderShell({super.key, required this.store});

  @override
  State<ElderShell> createState() => _ElderShellState();
}

class _ElderShellState extends State<ElderShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.store;

    final List<Widget> pages = [
      ElderHomeScreen(
        store: s,
        onNavigateTab: (index) => setState(() => _currentIndex = index),
      ),
      CareScreen(store: s),
      CognitiveHubScreen(store: s),
      MemoriesScreen(store: s),
      FamilyScreen(store: s),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.green.withValues(alpha: 0.18),
        height: 74,
        elevation: 4,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 26),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.green, size: 28),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded, size: 26),
            selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.green, size: 28),
            label: 'Care',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined, size: 26),
            selectedIcon: Icon(Icons.psychology_rounded, color: AppColors.green, size: 28),
            label: 'Play',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined, size: 26),
            selectedIcon: Icon(Icons.photo_library_rounded, color: AppColors.green, size: 28),
            label: 'Memories',
          ),
          NavigationDestination(
            icon: Icon(Icons.diversity_1_outlined, size: 26),
            selectedIcon: Icon(Icons.diversity_1_rounded, color: AppColors.green, size: 28),
            label: 'Family',
          ),
        ],
      ),
    );
  }
}
