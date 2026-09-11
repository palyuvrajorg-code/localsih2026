import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xopun/main.dart';
import 'package:xopun/store.dart';
import 'package:xopun/games.dart';
import 'package:xopun/catalog.dart';
import 'package:xopun/ui.dart';
import 'package:xopun/caregiver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    for (final channel in [
      'flutter_tts',
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (_) async => 1);
    }
  });
  Future<AppStore> store() async {
    final s = AppStore(await SharedPreferences.getInstance());
    s.voice = false;
    s.language = 'en';
    return s;
  }

  test('Preferences and caregiver PIN survive a restart', () async {
    final s = await store();
    s.name = 'Mina';
    s.language = 'as';
    s.setPin('4321');
    s.reminders.add({'id': '1', 'title': 'Water', 'time': '09:00'});
    await s.save();
    final loaded = AppStore(await SharedPreferences.getInstance());
    expect(loaded.name, 'Mina');
    expect(loaded.language, 'as');
    expect(loaded.checkPin('4321'), isTrue);
    expect(loaded.checkPin('1234'), isFalse);
    expect(loaded.reminders.single['time'], '09:00');
    expect(loaded.pinHash, isNot(contains('4321')));
  });
  test(
    'Adaptation moves a single bounded step and responds to abandonment',
    () async {
      final s = await store();
      for (int i = 0; i < 3; i++) {
        await s.record('match', 'attention', 4, 4, 0, 4000);
      }
      expect(s.step('match'), 1);
      await s.record('match', 'attention', 4, 4, 0, 4000);
      expect(s.step('match'), 2);
      for (int i = 0; i < 3; i++) {
        await s.record('match', 'attention', 2, 0, 2, 4000, abandoned: true);
      }
      expect(s.step('match'), 0);
    },
  );
  testWidgets(
    'Minimal patient home works at phone size with Assamese large text',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final s = await store();
      s.onboarded = true;
      s.language = 'as';
      s.fontSize = 28;
      await tester.pumpWidget(XopunApp(store: s));
      await tester.pumpAndSettle();
      expect(find.text('আহক খেলোঁ'), findsOneWidget);
      expect(find.text('সহায় বিচাৰক'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
  testWidgets('Daily completion persists by date', (tester) async {
    final s = await store();
    s.reminders.add({'id': '1', 'title': 'A glass of water', 'time': '09:00'});
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: DayPage(store: s),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(s.reminders.single['done'], s.dayKey);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
  for (final game in catalog) {
    for (final level in [0, 4, 8]) {
      testWidgets(
        '${game.id} step $level: intro and activity render with seeded family content',
        (tester) async {
          tester.view.physicalSize = const Size(390, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final s = await store();
          s.levels[game.id] = level;
          final bytes = await rootBundle.load('assets/images/lotus.jpg');
          for (var i = 0; i < 6; i++) {
            s.memories.add({
              'id': '$i',
              'image': base64Encode(bytes.buffer.asUint8List()),
              'person': 'Person $i',
              'place': 'Home',
              'date': '200$i-01-01',
              'caption': 'Story $i',
              'others': 'Friend $i',
            });
          }
          await tester.pumpWidget(
            MaterialApp(
              theme: appTheme(),
              home: GameScreen(store: s, game: game),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Start'), findsOneWidget);
          await tester.ensureVisible(find.text('Start'));
          await tester.tap(find.text('Start'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        },
      );
    }
  }
  testWidgets('Number game completes and records a real session', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final s = await store();
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: GameScreen(
          store: s,
          game: catalog.firstWhere((g) => g.id == 'number'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    for (var n = 1; n <= 3; n++) {
      await tester.ensureVisible(find.text('$n'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('$n'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Lovely work!'), findsOneWidget);
    expect(s.sessions.single['abandoned'], false);
    expect(s.sessions.single['accuracy'], 1.0);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets(
    'Caregiver overview renders empty state without invented progress',
    (tester) async {
      final s = await store();
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(),
          home: CaregiverDashboard(store: s),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0 activities enjoyed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Four puzzle pieces can be placed and saved as a completed session',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final s = await store();
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(),
          home: GameScreen(store: s, game: catalog.first),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Start'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      for (var n = 1; n <= 4; n++) {
        final piece = find.byWidgetPredicate(
          (v) => v is Semantics && v.properties.label == 'Piece $n',
        );
        final place = find.byWidgetPredicate(
          (v) => v is Semantics && v.properties.label == 'Place $n',
        );
        await tester.ensureVisible(piece);
        await tester.pumpAndSettle();
        await tester.tap(piece);
        await tester.pumpAndSettle();
        await tester.ensureVisible(place);
        await tester.pumpAndSettle();
        await tester.tap(place);
        await tester.pumpAndSettle();
      }
      expect(find.text('Lovely work!'), findsOneWidget);
      expect(s.sessions.single['accuracy'], 1.0);
      expect(s.sessions.single['abandoned'], false);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
