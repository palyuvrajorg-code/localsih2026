import 'dart:math';
import '../../data/models/models.dart';

/// Evidence-informed Adaptive Cognitive Engine.
/// IMPORTANT: NEVER produces "Dementia Score", "Disease Severity", or "Medical Diagnosis".
/// Focuses purely on "Activity Performance & Personalization".
class AdaptiveCognitiveEngine {
  /// Evaluates recent sessions to dynamically update difficulty step (0 - 11).
  static int computeNextLevel({
    required int currentLevel,
    required List<GameResult> recentResults,
  }) {
    if (recentResults.length < 3) return currentLevel;

    final last3 = recentResults.take(3).toList();
    final bool strong = last3.every(
      (r) => r.accuracy >= 0.80 && r.assistanceNeeded == 0 && r.completed,
    );
    final bool struggling = last3.where(
      (r) => r.accuracy < 0.50 || !r.completed,
    ).length >= 2;

    if (strong) {
      return min(11, currentLevel + 1);
    } else if (struggling) {
      return max(0, currentLevel - 1);
    }
    return currentLevel;
  }

  /// Calculates overall engagement & accuracy stats without medical labeling.
  static Map<String, dynamic> summarizePerformance(List<GameResult> results) {
    if (results.isEmpty) {
      return {
        'totalSessions': 0,
        'averageAccuracy': 0.0,
        'averageResponseMs': 0,
        'completionRate': 0.0,
        'recommendedDomain': 'Gentle visual recall',
      };
    }

    final total = results.length;
    final totalAccuracy = results.fold<double>(0.0, (sum, r) => sum + r.accuracy);
    final totalResponse = results.fold<int>(0, (sum, r) => sum + r.responseTime);
    final completedCount = results.where((r) => r.completed).length;

    return {
      'totalSessions': total,
      'averageAccuracy': totalAccuracy / total,
      'averageResponseMs': totalResponse ~/ total,
      'completionRate': completedCount / total,
      'recommendedDomain': _determineRecommendation(results),
    };
  }

  static String _determineRecommendation(List<GameResult> results) {
    if (results.isEmpty) return 'Memory Matrix (Bamboo Weave)';
    final lastGame = results.last.gameName;
    if (lastGame.contains('Match')) {
      return 'Try Memory Matrix for gentle spatial stimulation';
    } else if (lastGame.contains('Matrix')) {
      return 'Try Sequence Recall for melodic listening';
    } else {
      return 'Try Digital Loom for peaceful textile patterns';
    }
  }
}
