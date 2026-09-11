import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'store.dart';

class VoiceService {
  final AppStore store;
  final FlutterTts tts = FlutterTts();
  final SpeechToText stt = SpeechToText();
  VoiceService(this.store);
  String get locale => '${store.language}-IN';
  Future<bool> say(String text, {bool force = false}) async {
    if (!store.voice && !force) return true;
    try {
      final available = await tts.isLanguageAvailable(locale);
      if (available != true && available != 1) return false;
      await tts.stop();
      await tts.setLanguage(locale);
      await tts.setSpeechRate(.38);
      await tts.speak(text);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> listen(void Function(String) onResult) async {
    try {
      await tts.stop();
      if (!await stt.initialize()) return false;
      final locales = await stt.locales();
      final matching = locales
          .where((l) => l.localeId.toLowerCase().startsWith(store.language))
          .toList();
      if (matching.isEmpty) return false;
      await stt.listen(
        listenOptions: SpeechListenOptions(
          localeId: matching.first.localeId,
          listenFor: const Duration(seconds: 15),
        ),
        onResult: (r) {
          if (r.finalResult) onResult(r.recognizedWords);
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    await tts.stop();
    await stt.stop();
  }
}
