import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'store.dart';
import 'ui.dart';
import 'voice.dart';
import 'catalog.dart';
import 'games.dart';
import 'caregiver.dart';
import 'app/smriti_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore(await SharedPreferences.getInstance());
  runApp(SmritiApp(store: store));
}

class SmritiApp extends StatelessWidget {
  final AppStore store;
  const SmritiApp({super.key, required this.store});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => MaterialApp(
      title: 'SMRITI · SIH 2026',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      locale: Locale(store.language == 'as' ? 'bn' : store.language),
      supportedLocales: const [Locale('en'), Locale('bn')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(
            (store.fontSize / 20) * MediaQuery.textScalerOf(context).scale(1),
          ),
        ),
        child: child!,
      ),
      home: SmritiRoot(store: store),
    ),
  );
}

/// Backwards-compatible test/embedding alias while the product is branded Smriti.
class XopunApp extends StatelessWidget {
  final AppStore store;
  const XopunApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => MaterialApp(
      title: 'Smriti · A little joy, every day',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      locale: Locale(store.language == 'as' ? 'bn' : store.language),
      supportedLocales: const [Locale('en'), Locale('bn')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(
            (store.fontSize / 20) * MediaQuery.textScalerOf(context).scale(1),
          ),
        ),
        child: child!,
      ),
      home: store.onboarded ? PatientHome(store: store) : Welcome(store: store),
    ),
  );
}

class Welcome extends StatefulWidget {
  final AppStore store;
  const Welcome({super.key, required this.store});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late final voice = VoiceService(widget.store);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => voice.say(
        widget.store.w.text(
          'Welcome. A little joy, every day.',
          'স্বাগতম। প্ৰতিদিনে অলপ আনন্দ।',
          'স্বাগতম। প্রতিদিন একটু আনন্দ।',
        ),
      ),
    );
  }

  @override
  void dispose() {
    voice.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final w = s.w;
    return Scaffold(
      body: SafeArea(
        child: PageBody(
          children: [
            const SizedBox(height: 20),
            const Text(
              'smriti',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 52,
                letterSpacing: -2,
                color: green,
              ),
            ),
            Text(
              w.text(
                'A little joy, every day.',
                'প্ৰতিদিনে অলপ আনন্দ।',
                'প্রতিদিন একটু আনন্দ।',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.asset(
                'assets/images/logo.jpeg',
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
            gap,
            Text(
              w.text(
                'Make yourself at home.',
                'আপোনাক স্বাগতম।',
                'আপনাকে স্বাগতম।',
              ),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            ),
            Text(
              w.text(
                'Simple moments. Familiar memories. Together.',
                'সৰল মুহূৰ্ত। চিনাকি স্মৃতি। একেলগে।',
                'সহজ মুহূর্ত। চেনা স্মৃতি। একসঙ্গে।',
              ),
            ),
            gap,
            languagePicker(s),
            gap,
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CaregiverSetup(store: s)),
              ),
              child: Text(
                w.text(
                  'Set up with family',
                  'পৰিয়ালৰ সৈতে আৰম্ভ কৰক',
                  'পরিবারের সঙ্গে শুরু করুন',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                s.onboarded = true;
                s.save();
              },
              child: Text(
                w.text(
                  'Try the activities',
                  'খেলবোৰ খেলি চাওক',
                  'খেলাগুলি দেখুন',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget languagePicker(AppStore s) => DropdownButtonFormField<String>(
  initialValue: s.language,
  decoration: const InputDecoration(
    prefixIcon: Icon(Icons.translate_rounded),
    labelText: 'Language · ভাষা',
  ),
  items: const [
    DropdownMenuItem(value: 'as', child: Text('অসমীয়া')),
    DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
    DropdownMenuItem(value: 'en', child: Text('English')),
  ],
  onChanged: (v) {
    if (v != null) {
      s.language = v;
      s.save();
    }
  },
);

class PatientHome extends StatefulWidget {
  final AppStore store;
  const PatientHome({super.key, required this.store});
  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  late final voice = VoiceService(widget.store);
  Timer? clock;
  @override
  void initState() {
    super.initState();
    clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => voice.say(
        widget.store.w.text(
          'Welcome. Let’s enjoy a little activity.',
          'স্বাগতম। আহক অলপ খেলোঁ।',
          'স্বাগতম। চলুন একটু খেলি।',
        ),
      ),
    );
  }

  @override
  void dispose() {
    clock?.cancel();
    voice.stop();
    super.dispose();
  }

  void open(Widget page) {
    voice.stop();
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> speak() async {
    final ok = await voice.listen((words) {
      if (!mounted) return;
      final text = words.toLowerCase();
      if (RegExp('play|খেল').hasMatch(text)) {
        open(GameScreen(store: widget.store, game: catalog.first));
      } else if (RegExp('memor|স্মৃতি').hasMatch(text)) {
        open(MemoryPage(store: widget.store));
      } else if (RegExp('day|today|দিন').hasMatch(text)) {
        open(DayPage(store: widget.store));
      } else if (RegExp('help|call|সহায়|সাহায্য').hasMatch(text)) {
        showHelp(context, widget.store);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.store.w.text(
                'Say: play, memories, my day, or help.',
                'কওক: খেল, স্মৃতি, দিন, বা সহায়।',
                'বলুন: খেলি, স্মৃতি, দিন, বা সাহায্য।',
              ),
            ),
          ),
        );
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? widget.store.w.text('Listening…', 'শুনি আছোঁ…', 'শুনছি…')
                : widget.store.w.noVoice,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final w = s.w;
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? w.text('Good morning', 'সুপ্ৰভাত', 'সুপ্রভাত')
        : now.hour < 17
        ? w.text('Good afternoon', 'শুভ দুপৰীয়া', 'শুভ অপরাহ্ণ')
        : w.text('Good evening', 'শুভ সন্ধিয়া', 'শুভ সন্ধ্যা');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'smriti',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 32,
            letterSpacing: -1,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => open(LanguagePage(store: s)),
            icon: const Icon(Icons.translate_rounded, size: 22),
            label: Text(
              s.language == 'as'
                  ? 'অসমীয়া'
                  : s.language == 'bn'
                  ? 'বাংলা'
                  : 'English',
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: PageBody(
          children: [
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 20, color: muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${w.number(now.hour % 12 == 0 ? 12 : now.hour % 12)}:${w.number(now.minute).padLeft(2, s.language == 'en' ? '0' : '০')} ${now.hour < 12 ? w.text('AM', 'পুৱা', 'সকাল') : w.text('PM', 'অপৰাহ্ণ', 'বিকেল')}  ·  ${w.date(now)}',
                    style: const TextStyle(fontSize: 18, color: muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '$greeting${s.name.isEmpty ? '' : ', ${s.name}'}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Panel(
              color: sage,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_outlined, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            w.text(
                              'TODAY’S LITTLE ACTIVITY',
                              'আজিৰ সৰু খেল',
                              'আজকের ছোট্ট খেলা',
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        gameImages[0],
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          w.text(
                            'A picture. A little joy.',
                            'এখন ছবি। অলপ আনন্দ।',
                            'একটি ছবি। একটু আনন্দ।',
                          ),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () =>
                              open(GameScreen(store: s, game: catalog.first)),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(w.play),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            gap,
            ActionTile(
              icon: Icons.photo_library_outlined,
              title: w.memories,
              onTap: () => open(MemoryPage(store: s)),
            ),
            ActionTile(
              icon: Icons.wb_sunny_outlined,
              title: w.today,
              onTap: () => open(DayPage(store: s)),
            ),
            TextButton(
              onPressed: () => open(GameLibrary(store: s)),
              child: Text(w.text('More activities', 'আৰু খেল', 'আরও খেলা')),
            ),
            TextButton.icon(
              onPressed: () => enterCaregiver(context, s),
              icon: const Icon(Icons.lock_outline_rounded, size: 20),
              label: Text(w.caregiver),
            ),
            if (s.storageError != null)
              Text(s.storageError!, style: const TextStyle(color: rust)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: cream,
            border: Border(top: BorderSide(color: line)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showHelp(context, s),
                  icon: const Icon(Icons.favorite_border_rounded, color: rust),
                  label: Text(w.help),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: speak,
                tooltip: w.speak,
                icon: const Icon(Icons.mic_none_rounded),
                style: IconButton.styleFrom(
                  minimumSize: const Size(64, 64),
                  backgroundColor: sage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguagePage extends StatelessWidget {
  final AppStore store;
  const LanguagePage({super.key, required this.store});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Language · ভাষা')),
    body: PageBody(
      children: [
        languagePicker(store),
        gap,
        Text(
          store.w.text(
            'Choose the language that feels like home.',
            'আপোনাৰ চিনাকি ভাষা বাছক।',
            'আপনার পরিচিত ভাষা বাছুন।',
          ),
        ),
      ],
    ),
  );
}

class GameLibrary extends StatefulWidget {
  final AppStore store;
  const GameLibrary({super.key, required this.store});
  @override
  State<GameLibrary> createState() => _GameLibraryState();
}

class _GameLibraryState extends State<GameLibrary> {
  int category = 0;
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final w = s.w;
    final titles = [
      w.text('Everyday joys', 'দৈনন্দিন আনন্দ', 'প্রতিদিনের আনন্দ'),
      w.text('Family', 'পৰিয়াল', 'পরিবার'),
      w.text('Together', 'একেলগে', 'একসঙ্গে'),
      w.text('Little challenges', 'সৰু খেল', 'ছোট্ট খেলা'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(w.games)),
      body: PageBody(
        children: [
          Text(w.relax),
          gap,
          DropdownButtonFormField<int>(
            initialValue: category,
            decoration: InputDecoration(labelText: w.games),
            items: List.generate(
              4,
              (i) => DropdownMenuItem(value: i, child: Text(titles[i])),
            ),
            onChanged: (v) => setState(() => category = v!),
          ),
          gap,
          ...catalog
              .where((g) => g.category == category)
              .map(
                (g) => ActionTile(
                  icon: g.icon,
                  title: g.title(w),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(store: s, game: g),
                    ),
                  ),
                ),
              ),
        ],
      ),
      bottomNavigationBar: HelpBar(store: s),
    );
  }
}

class MemoryPage extends StatefulWidget {
  final AppStore store;
  const MemoryPage({super.key, required this.store});
  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  int index = 0;
  late final voice = VoiceService(widget.store);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => read());
  }

  void read() {
    voice.say(
      widget.store.memories.isEmpty
          ? widget.store.w.noMemories
          : widget.store.memories[index]['caption'] ?? '',
    );
  }

  @override
  void dispose() {
    voice.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final w = s.w;
    final m = s.memories.isEmpty ? null : s.memories[index];
    return Scaffold(
      appBar: AppBar(title: Text(w.memories)),
      body: PageBody(
        children: [
          if (m == null) ...[
            const SizedBox(height: 70),
            const Icon(Icons.photo_library_outlined, size: 72, color: green),
            gap,
            Text(w.noMemories, textAlign: TextAlign.center),
          ] else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.memory(
                base64Decode(m['image']),
                height: 330,
                fit: BoxFit.contain,
              ),
            ),
            gap,
            Text(
              m['person'] ?? '',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            Text(m['caption'] ?? ''),
            gap,
            OutlinedButton.icon(
              onPressed: read,
              icon: const Icon(Icons.volume_up_outlined),
              label: Text(w.listen),
            ),
            gap,
            if (s.memories.length > 1)
              FilledButton(
                onPressed: () {
                  setState(() => index = (index + 1) % s.memories.length);
                  read();
                },
                child: Text(w.next),
              ),
          ],
        ],
      ),
      bottomNavigationBar: HelpBar(store: s),
    );
  }
}

class DayPage extends StatefulWidget {
  final AppStore store;
  const DayPage({super.key, required this.store});
  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  late final voice = VoiceService(widget.store);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => voice.say(
        widget.store.reminders
            .map((r) => '${r['time']}. ${r['title']}')
            .join('. '),
      ),
    );
  }

  @override
  void dispose() {
    voice.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final w = s.w;
    final reminders = [...s.reminders]
      ..sort((a, b) => (a['time'] as String).compareTo(b['time']));
    return Scaffold(
      appBar: AppBar(title: Text(w.today)),
      body: PageBody(
        children: [
          Text(
            w.text(
              'One thing at a time.',
              'এবাৰত এটা কাম।',
              'একবারে একটি কাজ।',
            ),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
          gap,
          if (reminders.isEmpty)
            Panel(
              child: Text(
                w.text(
                  'Nothing planned. Enjoy a quiet moment.',
                  'এতিয়া কোনো কাম নাই। অলপ জিৰাওক।',
                  'এখন কোনো কাজ নেই। একটু বিশ্রাম নিন।',
                ),
              ),
            ),
          ...reminders.map((r) {
            final done = r['done'] == s.dayKey;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Panel(
                color: done ? sage : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(r['time'], style: const TextStyle(color: muted)),
                    Text(r['title'], style: const TextStyle(fontSize: 26)),
                    gap,
                    FilledButton.icon(
                      onPressed: done
                          ? null
                          : () {
                              r['done'] = s.dayKey;
                              s.save();
                              setState(() {});
                              voice.say(w.nice);
                            },
                      icon: Icon(
                        done ? Icons.check_circle_outline : Icons.check_rounded,
                      ),
                      label: Text(w.done),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: HelpBar(store: s),
    );
  }
}

class HelpBar extends StatelessWidget {
  final AppStore store;
  const HelpBar({super.key, required this.store});
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: OutlinedButton.icon(
        onPressed: () => showHelp(context, store),
        icon: const Icon(Icons.favorite_border, color: rust),
        label: Text(store.w.help),
      ),
    ),
  );
}

Future<void> showHelp(BuildContext context, AppStore s) async {
  final w = s.w;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.favorite_outline_rounded, size: 48, color: rust),
            gap,
            Text(
              w.text(
                'You are not alone.',
                'আপুনি অকলশৰীয়া নহয়।',
                'আপনি একা নন।',
              ),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            gap,
            Text(
              s.phone.isEmpty
                  ? w.text(
                      'Ask your family to add their phone number in Family settings.',
                      'পৰিয়ালৰ ছেটিংছত ফোন নম্বৰ যোগ কৰিবলৈ কওক।',
                      'পরিবারের সেটিংসে ফোন নম্বর যোগ করতে বলুন।',
                    )
                  : w.text(
                      'Open the phone to call your family.',
                      'পৰিয়ালক ফোন কৰিবলৈ ফোনটো খোলক।',
                      'পরিবারকে কল করতে ফোন খুলুন।',
                    ),
            ),
            gap,
            if (s.phone.isNotEmpty)
              FilledButton.icon(
                onPressed: () async {
                  bool ok = false;
                  try {
                    ok = await launchUrl(Uri(scheme: 'tel', path: s.phone));
                  } catch (_) {}
                  if (ctx.mounted && !ok) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${w.text('Please dial', 'ফোন কৰক', 'কল করুন')}: ${s.phone}',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.call_outlined),
                label: Text(
                  w.text('Call family', 'পৰিয়ালক ফোন কৰক', 'পরিবারকে কল করুন'),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(w.back),
            ),
          ],
        ),
      ),
    ),
  );
}
