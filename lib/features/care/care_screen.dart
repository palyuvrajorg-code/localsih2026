import 'package:flutter/material.dart';
import '../../store.dart';
import '../../data/models/models.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/care_task_card.dart';
import '../../core/widgets/smriti_card.dart';

class CareScreen extends StatefulWidget {
  final AppStore store;
  const CareScreen({super.key, required this.store});

  @override
  State<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<CareScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;

    return AnimatedBuilder(
      animation: s,
      builder: (context, _) {
        final allTasks = s.careTasks;
        final medTasks = allTasks.where((t) => t.category == TaskCategory.medication).toList();
        final routineTasks = allTasks.where((t) => t.category != TaskCategory.medication).toList();
        final completedTasks = allTasks.where((t) => t.isCompleted).toList();

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            title: const Text(
              'My Daily Care',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.green,
              indicatorWeight: 3,
              labelColor: AppColors.green,
              unselectedLabelColor: AppColors.muted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Pills'),
                Tab(text: 'Routine'),
                Tab(text: 'Done'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // All Today Tab
              _buildTaskList(allTasks, s, emptyMessage: 'No care tasks scheduled for today.'),

              // Medications Tab
              _buildTaskList(medTasks, s, emptyMessage: 'No medications scheduled for today.'),

              // Routine / Hydration / Meals Tab
              _buildRoutineTab(routineTasks, s),

              // Completed Tab
              _buildTaskList(completedTasks, s, emptyMessage: 'No completed tasks yet today. Take your time!'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoutineTab(List<CareTask> tasks, AppStore s) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Hydration tracker card
        SmritiCard(
          backgroundColor: const Color(0xFFEBF8FF),
          border: Border.all(color: const Color(0xFFBEE3F8), width: 1.5),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.water_drop_rounded, color: Color(0xFF3182CE), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Daily Hydration Goal',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2B6CB0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${s.hydrationGlassesTaken} of ${s.targetHydration} glasses completed',
                style: const TextStyle(fontSize: 16, color: AppColors.ink, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (s.hydrationGlassesTaken / s.targetHydration).clamp(0.0, 1.0),
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3182CE)),
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3182CE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => s.logHydration(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Log 1 Glass of Water',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'ROUTINE TASKS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 10),
        ...tasks.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CareTaskCard(
              task: t,
              onConfirm: () => s.completeTask(t.id),
              onMiss: () => s.missTask(t.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<CareTask> tasks, AppStore s, {required String emptyMessage}) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.spa_outlined, color: AppColors.green, size: 54),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: AppColors.muted, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CareTaskCard(
            task: task,
            onConfirm: () => s.completeTask(task.id),
            onMiss: () => s.missTask(task.id),
          ),
        );
      },
    );
  }
}
