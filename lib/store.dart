import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'strings.dart';

const gameImages = [
  'assets/images/lotus.jpg',
  'assets/images/courtyard.jpg',
  'assets/images/temple.jpg',
];

class AppStore extends ChangeNotifier {
  final SharedPreferences prefs;
  String language = 'as', name = '', phone = '', pinHash = '', salt = '';
  double fontSize = 20;
  bool voice = true, onboarded = false;
  List<Map<String, dynamic>> memories = [], reminders = [], sessions = [];
  Map<String, dynamic> levels = {};
  String? storageError;
  Future<void> _writes = Future.value();
  AppStore(this.prefs) {
    try {
      final raw = prefs.getString('xopun.v1');
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      language = data['language'] ?? 'as';
      name = data['name'] ?? '';
      phone = data['phone'] ?? '';
      pinHash = data['pinHash'] ?? '';
      salt = data['salt'] ?? '';
      fontSize = (data['fontSize'] as num? ?? 20).toDouble();
      voice = data['voice'] ?? true;
      onboarded = data['onboarded'] ?? false;
      memories = List<Map<String, dynamic>>.from(data['memories'] ?? []);
      reminders = List<Map<String, dynamic>>.from(data['reminders'] ?? []);
      sessions = List<Map<String, dynamic>>.from(data['sessions'] ?? []);
      levels = Map<String, dynamic>.from(data['levels'] ?? {});
    } catch (_) {
      storageError =
          'Stored data could not be read. Please ask your family for help.';
    }
  }
  Words get w => Words(language);
  Future<void> save() {
    final payload = jsonEncode({
      'language': language,
      'name': name,
      'phone': phone,
      'pinHash': pinHash,
      'salt': salt,
      'fontSize': fontSize,
      'voice': voice,
      'onboarded': onboarded,
      'memories': memories,
      'reminders': reminders,
      'sessions': sessions,
      'levels': levels,
    });
    notifyListeners();
    _writes = _writes.then((_) async {
      try {
        if (!await prefs.setString('xopun.v1', payload)) {
          throw StateError('Storage full');
        }
        storageError = null;
      } catch (_) {
        storageError =
            'Changes could not be saved. Device storage may be full.';
      }
      notifyListeners();
    });
    return _writes;
  }

  void setPin(String pin) {
    salt = List.generate(32, (_) => Random.secure().nextInt(256)).join('-');
    pinHash = sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  bool checkPin(String pin) =>
      pinHash == sha256.convert(utf8.encode('$salt:$pin')).toString();
  int step(String id) => (levels[id] as num? ?? 0).toInt().clamp(0, 11);
  int tier(String id) => step(id) ~/ 4;
  Future<void> record(
    String id,
    String domain,
    int attempts,
    int correct,
    int hints,
    int milliseconds, {
    bool abandoned = false,
  }) async {
    final entry = {
      'game': id,
      'domain': domain,
      'at': DateTime.now().toIso8601String(),
      'accuracy': attempts == 0 ? 0.0 : correct / attempts,
      'responseMs': milliseconds ~/ max(1, attempts),
      'hints': hints,
      'abandoned': abandoned,
      'step': step(id),
    };
    sessions.add(entry);
    if (sessions.length > 300) sessions.removeAt(0);
    final recent = sessions
        .where((s) => s['game'] == id)
        .toList()
        .reversed
        .take(5)
        .toList();
    if (recent.length >= 3) {
      final strong = recent
          .take(3)
          .every(
            (s) =>
                (s['accuracy'] as num) >= .85 &&
                s['hints'] == 0 &&
                s['abandoned'] == false,
          );
      final struggle =
          recent
              .take(3)
              .where(
                (s) => (s['accuracy'] as num) < .5 || s['abandoned'] == true,
              )
              .length >=
          2;
      levels[id] =
          (step(id) +
                  (strong
                      ? 1
                      : struggle
                      ? -1
                      : 0))
              .clamp(0, 11);
    }
    await save();
  }

  String get dayKey => DateTime.now().toIso8601String().substring(0, 10);
}
