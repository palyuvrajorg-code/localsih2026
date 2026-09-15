import '../../data/models/models.dart';

typedef OnAlertTriggered = void Function(CareAlert alert);
typedef OnStateChanged = void Function();

/// Closed-loop state machine for dementia care tasks.
/// "SMRITI doesn't just remind. It follows through."
///
/// INITIATE -> GUIDE -> PERFORM -> VERIFY -> COMPLETE -> RECORD -> REPORT -> ESCALATE
class ClosedLoopEngine {
  final OnAlertTriggered? onAlert;
  final OnStateChanged? onStateChanged;

  ClosedLoopEngine({this.onAlert, this.onStateChanged});

  /// Transition: INITIATE
  void initiate(CareTask task) {
    if (task.status == TaskStatus.scheduled) {
      task.status = TaskStatus.reminded;
      onStateChanged?.call();
    }
  }

  /// Transition: GUIDE / REMIND
  void remind(CareTask task) {
    task.status = TaskStatus.reminded;
    onStateChanged?.call();
  }

  /// Transition: ACKNOWLEDGE
  void acknowledge(CareTask task) {
    if (task.status == TaskStatus.reminded || task.status == TaskStatus.scheduled) {
      task.status = TaskStatus.acknowledged;
      onStateChanged?.call();
    }
  }

  /// Transition: PERFORM & VERIFY & COMPLETE
  void complete(CareTask task) {
    task.status = TaskStatus.completed;
    task.completedAt = DateTime.now();
    onStateChanged?.call();
  }

  /// Transition: MISS
  void miss(CareTask task) {
    task.missedCount++;
    if (task.category == TaskCategory.medication) {
      if (task.missedCount >= 2) {
        escalate(task, reason: 'Repeated missed medication: ${task.title}');
      } else {
        task.status = TaskStatus.missed;
        onStateChanged?.call();
      }
    } else if (task.category == TaskCategory.hydration) {
      if (task.missedCount >= 3) {
        escalate(task, reason: 'Hydration goal behind schedule for elder');
      } else {
        task.status = TaskStatus.missed;
        onStateChanged?.call();
      }
    } else {
      // Cognitive games do not generate alarming caregiver alerts
      task.status = TaskStatus.missed;
      onStateChanged?.call();
    }
  }

  /// Transition: ESCALATE
  void escalate(CareTask task, {String? reason}) {
    task.status = TaskStatus.escalated;
    final alert = CareAlert(
      id: 'alert-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Care Adherence Alert',
      message: reason ?? 'Task "${task.title}" missed and needs attention.',
      severity: task.category == TaskCategory.medication
          ? AlertSeverity.high
          : AlertSeverity.medium,
      timestamp: DateTime.now(),
    );
    onAlert?.call(alert);
    onStateChanged?.call();
  }
}
