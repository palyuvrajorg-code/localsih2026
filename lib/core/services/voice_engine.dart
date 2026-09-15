enum IntentType {
  completeMedication,
  logHydration,
  openGames,
  openMemories,
  getTodayPlan,
  checkAppointments,
  openFamily,
  emergencyHelp,
  generalGreeting,
  unknown,
}

class ParsedIntent {
  final IntentType type;
  final String rawQuery;
  final String responseText;
  final bool requiresConfirmation;
  final String? confirmationPrompt;
  final Map<String, dynamic> parameters;

  const ParsedIntent({
    required this.type,
    required this.rawQuery,
    required this.responseText,
    this.requiresConfirmation = false,
    this.confirmationPrompt,
    this.parameters = const {},
  });
}

abstract interface class ConversationService {
  Future<ParsedIntent> parseUtterance(String input);
}

class LocalMockConversationService implements ConversationService {
  @override
  Future<ParsedIntent> parseUtterance(String input) async {
    final lower = input.toLowerCase().trim();

    if (lower.contains('medicine') || lower.contains('pill') || lower.contains('dawa') || lower.contains('oukhod')) {
      if (lower.contains('took') || lower.contains('taken') || lower.contains('already') || lower.contains('done')) {
        return ParsedIntent(
          type: IntentType.completeMedication,
          rawQuery: input,
          responseText: 'Shall I mark your scheduled morning medicine as completed?',
          requiresConfirmation: true,
          confirmationPrompt: 'Mark morning medicine completed?',
        );
      }
      return ParsedIntent(
        type: IntentType.getTodayPlan,
        rawQuery: input,
        responseText: 'Your next medicine is scheduled at 08:00 AM: Amlodipine 5mg.',
      );
    }

    if (lower.contains('water') || lower.contains('drink') || lower.contains('pani')) {
      return ParsedIntent(
        type: IntentType.logHydration,
        rawQuery: input,
        responseText: 'Shall I record a glass of water for your daily hydration goal?',
        requiresConfirmation: true,
        confirmationPrompt: 'Record 1 glass of water?',
      );
    }

    if (lower.contains('game') || lower.contains('play') || lower.contains('khel') || lower.contains('puzzle') || lower.contains('matrix')) {
      return ParsedIntent(
        type: IntentType.openGames,
        rawQuery: input,
        responseText: 'Opening Brain Activities. Let us enjoy Memory Matrix together.',
      );
    }

    if (lower.contains('memory') || lower.contains('photo') || lower.contains('picture') || lower.contains('album')) {
      return ParsedIntent(
        type: IntentType.openMemories,
        rawQuery: input,
        responseText: 'Opening your cherished photo memories timeline.',
      );
    }

    if (lower.contains('family') || lower.contains('ananya') || lower.contains('grandchild')) {
      return ParsedIntent(
        type: IntentType.openFamily,
        rawQuery: input,
        responseText: 'Opening Family Together. Ananya shared a lovely photo activity.',
      );
    }

    if (lower.contains('plan') || lower.contains('today') || lower.contains('routine') || lower.contains('schedule')) {
      return ParsedIntent(
        type: IntentType.getTodayPlan,
        rawQuery: input,
        responseText: 'Today you have morning medicine at 08:00, brain activities at 10:00, and lunch at 13:00.',
      );
    }

    if (lower.contains('doctor') || lower.contains('appointment') || lower.contains('sharma')) {
      return ParsedIntent(
        type: IntentType.checkAppointments,
        rawQuery: input,
        responseText: 'You have an upcoming telehealth review with Dr. R. Sharma tomorrow at 11:00 AM.',
      );
    }

    if (lower.contains('help') || lower.contains('emergency') || lower.contains('fall') || lower.contains('dizzy')) {
      return ParsedIntent(
        type: IntentType.emergencyHelp,
        rawQuery: input,
        responseText: 'I am alerting Ananya and checking your safety right now.',
      );
    }

    return ParsedIntent(
      type: IntentType.generalGreeting,
      rawQuery: input,
      responseText: 'I am here with you, Kamala. You can tell me if you took your medicine, drank water, or want to play an activity.',
    );
  }
}
