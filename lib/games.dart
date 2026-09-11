import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'catalog.dart';
import 'store.dart';
import 'strings.dart';
import 'ui.dart';
import 'voice.dart';
import 'main.dart' show HelpBar;

class GameScreen extends StatefulWidget {
  final AppStore store;
  final Game game;
  const GameScreen({super.key, required this.store, required this.game});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final VoiceService voice = VoiceService(widget.store);
  final audio = AudioPlayer();
  final random = Random();
  final answer = TextEditingController();
  final stopwatch = Stopwatch();
  Words get w => widget.store.w;
  Game get g => widget.game;
  int get tier => widget.store.tier(g.id);
  int phase = 0, round = 0, position = 0, attempts = 0, correct = 0, hints = 0;
  int selected = -1, rotation = 0, target = 0, imageIndex = 0;
  bool completed = false, reveal = true, busy = false;
  String feedback = '';
  List<int> order = [], sequence = [];
  Set<int> placed = {};
  List<Map<String, dynamic>> family = [];
  Timer? hideTimer;
  final palette = [
    green,
    rust,
    const Color(0xFF365C91),
    const Color(0xFF8B6617),
  ];
  final symbols = ['🌾', '🫖', '🧺', '🌼'];
  final shapeIcons = [
    Icons.circle,
    Icons.square_rounded,
    Icons.change_history_rounded,
    Icons.diamond_rounded,
  ];
  @override
  void initState() {
    super.initState();
    family = widget.store.memories.where((m) {
      final key = switch (g.mechanic) {
        Mechanic.where || Mechanic.thenNow => 'place',
        Mechanic.timeline => 'date',
        Mechanic.there => 'others',
        _ => 'person',
      };
      return (m[key] as String? ?? '').isNotEmpty;
    }).toList();
    if (g.mechanic == Mechanic.timeline || g.mechanic == Mechanic.thenNow) {
      family.sort(
        (a, b) => (a['date'] as String).compareTo(b['date'] as String),
      );
    }
    resetRound();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => voice.say('${g.title(w)}. $instruction'),
    );
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    voice.stop();
    audio.dispose();
    answer.dispose();
    if (phase == 1 && !completed) {
      widget.store.record(
        g.id,
        g.domain,
        attempts,
        correct,
        hints,
        stopwatch.elapsedMilliseconds,
        abandoned: true,
      );
    }
    super.dispose();
  }

  String get instruction => switch (g.mechanic) {
    Mechanic.puzzle => w.text(
      'Tap a piece, then tap its place in the picture.',
      'এটা টুকুৰা চুই ছবিখনত তাৰ ঠাইত চোৱক।',
      'একটি টুকরো ছুঁয়ে ছবিতে তার জায়গায় ছুঁয়ে দিন।',
    ),
    Mechanic.pattern => w.text(
      'Follow the pattern. Tap the next colour.',
      'আৰ্হিটো চাই পৰৱৰ্তী ৰং চোৱক।',
      'নকশা দেখে পরের রং ছুঁয়ে দিন।',
    ),
    Mechanic.farm => w.text(
      'Tap the pictures in order, from seed to meal.',
      'বীজৰ পৰা আহাৰলৈ ক্ৰমে ছবিবোৰ চোৱক।',
      'বীজ থেকে খাবার পর্যন্ত ক্রমে ছবিগুলি ছুঁয়ে দিন।',
    ),
    Mechanic.rhythm => w.text(
      'Listen and watch. Tap the same drum pattern.',
      'শুনক আৰু চাওক। একে তালত চোৱক।',
      'শুনুন ও দেখুন। একই তালে ছুঁয়ে দিন।',
    ),
    Mechanic.market => w.text(
      'Let’s shop. Choose the matching amount.',
      'আহক বজাৰ কৰোঁ। সঠিক টকাৰ পৰিমাণ বাছক।',
      'চলুন বাজার করি। সঠিক টাকার পরিমাণ বাছুন।',
    ),
    Mechanic.bamboo => w.text(
      'Match the piece to the outline. Turn it if needed.',
      'টুকুৰাটো আৰ্হিৰ সৈতে মিলাওক। প্ৰয়োজন হ’লে ঘূৰাওক।',
      'টুকরোটি নকশার সঙ্গে মেলান। দরকার হলে ঘোরান।',
    ),
    Mechanic.who => w.text(
      'Who is in this family photo?',
      'এই পৰিয়ালৰ ফটোত কোন আছে?',
      'পরিবারের এই ছবিতে কে আছেন?',
    ),
    Mechanic.where => w.text(
      'Where was this memory made?',
      'এই স্মৃতিটো কোন ঠাইৰ?',
      'এই স্মৃতিটি কোন জায়গার?',
    ),
    Mechanic.there => w.text(
      'Who shared this moment?',
      'এই মুহূৰ্তত লগত কোন আছিল?',
      'এই মুহূর্তে সঙ্গে কে ছিলেন?',
    ),
    Mechanic.timeline => w.text(
      'Tap the oldest memory first.',
      'আটাইতকৈ পুৰণি স্মৃতিটো প্ৰথমে চোৱক।',
      'সবচেয়ে পুরনো স্মৃতিটি আগে ছুঁয়ে দিন।',
    ),
    Mechanic.detective => w.text(
      'Look closely. Which memory is this detail from?',
      'ভালদৰে চাওক। এই অংশটো কোন স্মৃতিৰ?',
      'ভালো করে দেখুন। এই অংশটি কোন স্মৃতির?',
    ),
    Mechanic.quiz => w.text(
      'Read the family story together. Who is it about?',
      'পৰিয়ালৰ কাহিনী একেলগে পঢ়ক। এয়া কাৰ বিষয়ে?',
      'পরিবারের গল্প একসঙ্গে পড়ুন। এটি কার সম্পর্কে?',
    ),
    Mechanic.tune => w.text(
      'Learn these three little tunes. Then find the one you hear.',
      'এই তিনিটা সৰু সুৰ শুনক। তাৰ পিছত শুনা সুৰটো বাছক।',
      'এই তিনটি ছোট সুর শুনুন। তারপর শোনা সুরটি বাছুন।',
    ),
    Mechanic.thenNow => w.text(
      'Look at two memories. Tell a story about what changed.',
      'দুটা স্মৃতি চাওক। কি সলনি হৈছে কওক।',
      'দুটি স্মৃতি দেখুন। কী বদলেছে বলুন।',
    ),
    Mechanic.proverb => w.text(
      'Complete the familiar saying.',
      'চিনাকি ফকৰাটো সম্পূৰ্ণ কৰক।',
      'চেনা প্রবাদটি সম্পূর্ণ করুন।',
    ),
    Mechanic.chain => w.text(
      'Remember the chain, then tap it in the same order.',
      'শিকলিটো মনত ৰাখি একে ক্ৰমত চোৱক।',
      'শিকলটি মনে রেখে একই ক্রমে ছুঁয়ে দিন।',
    ),
    Mechanic.match => w.text(
      'Find the same picture.',
      'একে ছবিখন বিচাৰক।',
      'একই ছবিটি খুঁজুন।',
    ),
    Mechanic.search => w.text(
      'Find the object shown above.',
      'ওপৰত দেখুওৱা বস্তুটো বিচাৰক।',
      'উপরে দেখানো জিনিসটি খুঁজুন।',
    ),
    Mechanic.sound => w.text(
      'Listen to each sound. Match the sound you hear.',
      'প্ৰতিটো শব্দ শুনক। শুনা শব্দটো মিলাওক।',
      'প্রতিটি শব্দ শুনুন। শোনা শব্দটি মেলান।',
    ),
    Mechanic.recall => w.text(
      'Remember these pictures. Then choose the one you saw.',
      'ছবিবোৰ মনত ৰাখক। তাৰ পিছত দেখা ছবিখন বাছক।',
      'ছবিগুলি মনে রাখুন। তারপর দেখা ছবিটি বাছুন।',
    ),
    Mechanic.number => w.text(
      'Tap the numbers from smallest to largest.',
      'সৰুৰ পৰা ডাঙৰলৈ সংখ্যাবোৰ চোৱক।',
      'ছোট থেকে বড় ক্রমে সংখ্যাগুলি ছুঁয়ে দিন।',
    ),
    Mechanic.shape => w.text(
      'Find the matching colour and shape.',
      'মিল থকা ৰং আৰু আকৃতি বিচাৰক।',
      'মিলে যাওয়া রং ও আকার খুঁজুন।',
    ),
  };
  void resetRound() {
    hideTimer?.cancel();
    selected = -1;
    position = 0;
    rotation = 0;
    placed = {};
    feedback = '';
    reveal = true;
    answer.clear();
    final count = switch (g.mechanic) {
      Mechanic.puzzle => [4, 9, 16][tier],
      Mechanic.number => [3, 5, 7][tier],
      Mechanic.farm => [3, 5, 6][tier],
      Mechanic.timeline => min([3, 4, 6][tier], family.length),
      _ => 4,
    };
    order = List.generate(count, (i) => i)..shuffle(random);
    if (count > 1 && order.asMap().entries.every((e) => e.key == e.value)) {
      final a = order.removeAt(0);
      order.add(a);
    }
    sequence = List.generate(
      g.mechanic == Mechanic.rhythm
          ? [2, 4, 6][tier]
          : g.mechanic == Mechanic.chain
          ? [3, 5, 7][tier]
          : [4, 6, 10][tier],
      (i) => g.mechanic == Mechanic.pattern
          ? i % (tier + 2)
          : random.nextInt(g.mechanic == Mechanic.rhythm ? tier + 1 : 4),
    );
    target = random.nextInt(3);
  }

  void begin() {
    setState(() => phase = 1);
    stopwatch.start();
    voice.say(instruction);
    if ([Mechanic.chain, Mechanic.pattern].contains(g.mechanic) && tier > 0) {
      hideTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => reveal = false);
      });
    }
  }

  Future<void> evaluate(bool success, {bool advance = true}) async {
    if (busy || completed) return;
    attempts++;
    if (success) correct++;
    setState(() {
      feedback = success ? w.nice : w.gentle;
      if (!success) reveal = true;
    });
    voice.say(feedback);
    if (success && advance) {
      if (round >= 2) {
        finish();
        return;
      }
      busy = true;
      await Future<void>.delayed(const Duration(milliseconds: 850));
      if (!mounted) return;
      setState(() {
        round++;
        resetRound();
        busy = false;
      });
    }
  }

  void finish() {
    if (completed) return;
    stopwatch.stop();
    completed = true;
    hideTimer?.cancel();
    widget.store.record(
      g.id,
      g.domain,
      attempts,
      correct,
      hints,
      stopwatch.elapsedMilliseconds,
    );
    setState(() => phase = 2);
    voice.say('${w.nice} ${w.relax}');
  }

  void hint() {
    hints++;
    setState(() {
      reveal = true;
      feedback = w.gentle;
    });
    if (g.mechanic == Mechanic.rhythm) {
      playRhythm();
    } else {
      voice.say(instruction, force: true);
    }
  }

  Future<void> playSound(int index, {bool tune = false}) async {
    try {
      await audio.play(
        AssetSource('audio/${tune ? 'tune' : 'sound'}$index.wav'),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              w.text(
                'Audio unavailable. Please try again.',
                'শব্দ উপলব্ধ নহয়। আকৌ চেষ্টা কৰক।',
                'শব্দ নেই। আবার চেষ্টা করুন।',
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> playRhythm() async {
    if (busy) return;
    setState(() => busy = true);
    for (final pad in sequence) {
      if (!mounted) return;
      setState(() => selected = pad);
      await playSound(pad);
      await Future<void>.delayed(Duration(milliseconds: [750, 600, 450][tier]));
      if (!mounted) return;
      setState(() => selected = -1);
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
    if (mounted) {
      setState(() {
        busy = false;
        position = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(g.title(w), style: const TextStyle(fontSize: 22)),
      actions: [
        IconButton(
          onPressed: () async {
            final ok = await voice.say(instruction, force: true);
            if (context.mounted && !ok) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(w.noVoice)));
            }
          },
          tooltip: w.listen,
          icon: const Icon(Icons.volume_up_outlined),
        ),
      ],
    ),
    body: PageBody(
      children: phase == 0
          ? intro()
          : phase == 2
          ? end()
          : [
              Text(
                instruction,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              gap,
              if (g.mechanic != Mechanic.puzzle)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: LinearProgressIndicator(
                    value: (round + 1) / 3,
                    backgroundColor: sage,
                    color: green,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ...playArea(),
              gap,
              Semantics(
                liveRegion: true,
                child: Text(
                  feedback.isEmpty ? w.relax : feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: green),
                ),
              ),
              gap,
              OutlinedButton.icon(
                onPressed: hint,
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: Text(w.hint),
              ),
            ],
    ),
    bottomNavigationBar: HelpBar(store: widget.store),
  );
  List<Widget> intro() {
    final needsFamily =
        g.family && (family.length < (g.mechanic == Mechanic.timeline ? 3 : 2));
    final pairs = family
        .where(
          (a) => family.any(
            (b) =>
                a['id'] != b['id'] &&
                a['place'] == b['place'] &&
                a['date'] != '' &&
                b['date'] != '' &&
                a['date'] != b['date'],
          ),
        )
        .toList();
    final needsPair = g.mechanic == Mechanic.thenNow && pairs.length < 2;
    if (g.mechanic == Mechanic.thenNow && !needsPair) {
      final first = pairs.first;
      family = pairs.where((p) => p['place'] == first['place']).toList();
    }
    return [
      const SizedBox(height: 30),
      Center(
        child: Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: sage,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Icon(g.icon, size: 52, color: green),
        ),
      ),
      const SizedBox(height: 32),
      Text(
        g.title(w),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
      ),
      gap,
      Text(instruction, textAlign: TextAlign.center),
      gap,
      if (g.mechanic == Mechanic.puzzle || g.mechanic == Mechanic.match)
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            gameImages[imageIndex],
            height: 190,
            fit: BoxFit.cover,
          ),
        ),
      gap,
      if (g.mechanic == Mechanic.puzzle) ...[
        DropdownButtonFormField<int>(
          initialValue: imageIndex,
          decoration: InputDecoration(labelText: w.picture),
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(w.text('Lotus pond', 'পদুমৰ পুখুৰী', 'পদ্মের পুকুর')),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text(w.text('Courtyard', 'চোতাল', 'উঠান')),
            ),
            DropdownMenuItem(
              value: 2,
              child: Text(w.text('Temple', 'মন্দিৰ', 'মন্দির')),
            ),
          ],
          onChanged: (v) => setState(() => imageIndex = v!),
        ),
        gap,
      ],
      if (needsFamily || needsPair)
        Panel(
          color: sage,
          child: Text(
            needsPair
                ? w.text(
                    'Ask family to add two dated photos of the same place to your memories.',
                    'একে ঠাইৰ তাৰিখ থকা দুখন ফটো যোগ কৰিবলৈ পৰিয়ালক কওক।',
                    'একই স্থানের তারিখসহ দুটি ছবি যোগ করতে পরিবারকে বলুন।',
                  )
                : w.text(
                    'Ask family to add at least ${g.mechanic == Mechanic.timeline ? 3 : 2} memories with names, places and dates for this game.',
                    'এই খেলৰ বাবে নাম, ঠাই আৰু তাৰিখসহ স্মৃতি যোগ কৰিবলৈ পৰিয়ালক কওক।',
                    'এই খেলার জন্য নাম, স্থান ও তারিখসহ স্মৃতি যোগ করতে পরিবারকে বলুন।',
                  ),
          ),
        )
      else
        FilledButton.icon(
          onPressed: begin,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(w.start),
        ),
      gap,
      Text(
        w.relax,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, color: muted),
      ),
    ];
  }

  List<Widget> end() => [
    const SizedBox(height: 48),
    const Icon(Icons.spa_outlined, size: 92, color: green),
    const SizedBox(height: 32),
    Text(
      w.nice,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
    ),
    gap,
    Text(
      w.text(
        'A lovely moment for your mind.',
        'মনটোৰ বাবে এটা সুন্দৰ মুহূৰ্ত।',
        'মনের জন্য একটি সুন্দর মুহূর্ত।',
      ),
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 40),
    FilledButton(
      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
      child: Text(w.home),
    ),
    gap,
    OutlinedButton(
      onPressed: () {
        setState(() {
          phase = 1;
          round = 0;
          completed = false;
          attempts = 0;
          correct = 0;
          hints = 0;
          resetRound();
        });
        stopwatch.reset();
        stopwatch.start();
        voice.say(instruction);
      },
      child: Text(w.again),
    ),
  ];
  Widget grid(List<Widget> cells, {int columns = 2, double ratio = 1.2}) =>
      GridView.count(
        crossAxisCount: columns,
        childAspectRatio: ratio,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: cells,
      );
  Widget tile(
    Widget child,
    VoidCallback onTap, {
    bool active = false,
    String? label,
  }) => Semantics(
    label: label,
    button: true,
    child: Material(
      color: active ? sage : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: active ? green : line, width: active ? 3 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : onTap,
        child: Center(child: child),
      ),
    ),
  );
  List<Widget> playArea() => switch (g.mechanic) {
    Mechanic.puzzle => puzzle(),
    Mechanic.pattern || Mechanic.chain => pattern(),
    Mechanic.farm || Mechanic.number || Mechanic.timeline => ordering(),
    Mechanic.rhythm => rhythm(),
    Mechanic.market => market(),
    Mechanic.bamboo => bamboo(),
    Mechanic.who ||
    Mechanic.where ||
    Mechanic.there ||
    Mechanic.detective ||
    Mechanic.quiz => familyQuiz(),
    Mechanic.tune || Mechanic.sound => audioQuiz(),
    Mechanic.thenNow => comparison(),
    Mechanic.proverb => proverb(),
    Mechanic.match ||
    Mechanic.search ||
    Mechanic.recall ||
    Mechanic.shape => matching(),
  };
  List<Widget> puzzle() {
    final side = [2, 3, 4][tier];
    final asset = gameImages[imageIndex];
    final remaining = order.where((i) => !placed.contains(i)).toList();
    final bank = remaining.take(4).toList();
    return [
      if (reveal)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(asset, height: 80, fit: BoxFit.contain),
          ),
        ),
      Center(
        child: SizedBox(
          width: 280,
          height: 280,
          child: GridView.count(
            crossAxisCount: side,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            children: List.generate(
              side * side,
              (i) => tile(
                placed.contains(i)
                    ? PuzzlePiece(asset: asset, index: i, side: side)
                    : Icon(
                        Icons.add_rounded,
                        color: selected == i && reveal ? green : muted,
                        size: 30,
                      ),
                () {
                  if (selected < 0 || placed.contains(i)) return;
                  final success = selected == i;
                  evaluate(success, advance: false);
                  if (success) {
                    setState(() {
                      placed.add(i);
                      selected = -1;
                    });
                    if (placed.length == side * side) finish();
                  }
                },
                active: selected == i && reveal,
                label: '${w.text('Place', 'ঠাই', 'স্থান')} ${w.number(i + 1)}',
              ),
            ),
          ),
        ),
      ),
      gap,
      grid(
        bank
            .map(
              (i) => tile(
                PuzzlePiece(asset: asset, index: i, side: side),
                () => setState(() => selected = i),
                active: selected == i,
                label:
                    '${w.text('Piece', 'টুকুৰা', 'টুকরো')} ${w.number(i + 1)}',
              ),
            )
            .toList(),
        columns: 4,
        ratio: 1,
      ),
    ];
  }

  Widget colour(int index, {double size = 48}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: palette[index % 4],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(shapeIcons[index % 4], color: Colors.white, size: size * .48),
  );
  List<Widget> pattern() {
    final chain = g.mechanic == Mechanic.chain;
    Widget item(int i) => chain
        ? Text(symbols[i], style: const TextStyle(fontSize: 36))
        : colour(i);
    return [
      Panel(
        color: sage,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(
            sequence.length,
            (i) => Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: i == position ? green : Colors.transparent,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: reveal || i < position
                  ? item(sequence[i])
                  : const Icon(Icons.more_horiz, size: 48),
            ),
          ),
        ),
      ),
      gap,
      grid(
        List.generate(
          chain ? 4 : tier + 2,
          (i) => tile(item(i), () {
            final ok = sequence[position] == i;
            evaluate(ok, advance: false);
            if (ok) {
              setState(() => position++);
              if (position == sequence.length) finish();
            }
          }, label: '${w.text('Choice', 'বাছনি', 'পছন্দ')} ${w.number(i + 1)}'),
        ),
      ),
    ];
  }

  List<Widget> ordering() {
    final numbers = g.mechanic == Mechanic.number;
    final timeline = g.mechanic == Mechanic.timeline;
    final stages = tier == 0
        ? ['🌱', '🌾', '🍚']
        : tier == 1
        ? ['🌱', '💧', '🌾', '🧺', '🍚']
        : ['🌱', '💧', '🌾', '🧺', '🍲', '🍚'];
    final names = tier == 0
        ? [
            w.text('Plant', 'ৰোৱা', 'রোপণ'),
            w.text('Harvest', 'চপোৱা', 'ফসল তোলা'),
            w.text('Eat', 'খোৱা', 'খাওয়া'),
          ]
        : [
            w.text('Plant', 'ৰোৱা', 'রোপণ'),
            w.text('Water', 'পানী দিয়া', 'জল দেওয়া'),
            w.text('Harvest', 'চপোৱা', 'ফসল তোলা'),
            w.text('Bring home', 'ঘৰলৈ অনা', 'বাড়ি আনা'),
            if (tier == 2) w.text('Cook', 'ৰন্ধা', 'রান্না'),
            w.text('Eat', 'খোৱা', 'খাওয়া'),
          ];
    // Keep only four unplaced options visible, including the next correct step.
    final remaining = order.where((i) => !placed.contains(i)).toList();
    var shown = remaining.take(4).toList();
    if (!shown.contains(position) && shown.isNotEmpty) {
      shown[shown.length - 1] = position;
    }
    return [
      Text(
        '${w.text('Next', 'পৰৱৰ্তী', 'পরবর্তী')}: ${w.number(numbers && tier == 2 ? (position + 1) * 2 : position + 1)}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 26, color: green),
      ),
      gap,
      grid(
        shown
            .map(
              (i) => tile(
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: numbers
                      ? Text(
                          w.number(tier == 2 ? (i + 1) * 2 : i + 1),
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : timeline
                      ? Column(
                          children: [
                            Expanded(
                              child: Image.memory(
                                base64Decode(family[i]['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (reveal)
                              Text(
                                family[i]['date'],
                                style: const TextStyle(fontSize: 18),
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stages[i],
                              style: const TextStyle(fontSize: 40),
                            ),
                            Flexible(
                              child: Text(
                                names[i],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                ),
                () {
                  final ok = i == position;
                  evaluate(ok, advance: false);
                  if (ok) {
                    setState(() {
                      placed.add(i);
                      position++;
                    });
                    if (position == order.length) finish();
                  }
                },
                label: numbers
                    ? w.number(tier == 2 ? (i + 1) * 2 : i + 1)
                    : null,
              ),
            )
            .toList(),
        ratio: .95,
      ),
    ];
  }

  List<Widget> rhythm() => [
    OutlinedButton.icon(
      onPressed: busy ? null : playRhythm,
      icon: const Icon(Icons.play_circle_outline),
      label: Text(w.listen),
    ),
    gap,
    Text(
      '${w.number(position)} / ${w.number(sequence.length)}',
      textAlign: TextAlign.center,
    ),
    gap,
    grid(
      List.generate(
        tier + 1,
        (i) => tile(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.radio_button_checked_rounded,
                size: 56,
                color: palette[i],
              ),
              Text(w.number(i + 1)),
            ],
          ),
          () {
            playSound(i);
            final ok = sequence[position] == i;
            evaluate(ok, advance: false);
            if (ok) {
              setState(() => position++);
              if (position == sequence.length) finish();
            } else {
              setState(() => position = 0);
            }
          },
          active: selected == i,
          label: '${w.text('Drum', 'ঢোল', 'ঢোল')} ${w.number(i + 1)}',
        ),
      ),
      columns: tier == 0 ? 1 : 2,
      ratio: 1.8,
    ),
  ];
  List<Widget> market() {
    final cost = 10 + round * 5;
    final payment = cost + 10;
    final expected = tier == 0
        ? cost
        : tier == 1
        ? payment - cost
        : 50 - cost - 15;
    final choices = [
      expected,
      expected + 5,
      expected + 10,
      max(0, expected - 5),
    ]..shuffle(Random(round));
    return [
      Panel(
        color: sage,
        child: Column(
          children: [
            const Text('🧺  🍚  🍌', style: TextStyle(fontSize: 48)),
            gap,
            Text(
              tier == 0
                  ? w.text(
                      'Rice costs ₹$cost. How much will you pay?',
                      'চাউলৰ দাম ₹${w.number(cost)}। কিমান দিব?',
                      'চালের দাম ₹${w.number(cost)}। কত দেবেন?',
                    )
                  : tier == 1
                  ? w.text(
                      'Rice costs ₹$cost. You pay ₹$payment. What is the change?',
                      'চাউল ₹${w.number(cost)}। দিলে ₹${w.number(payment)}। ঘূৰাই কিমান পাব?',
                      'চাল ₹${w.number(cost)}। দিলেন ₹${w.number(payment)}। ফেরত কত পাবেন?',
                    )
                  : w.text(
                      'You have ₹50. Rice is ₹$cost and bananas ₹15. How much remains?',
                      'আপোনাৰ ₹৫০ আছে। চাউল ₹${w.number(cost)}, কল ₹১৫। কিমান বাকী?',
                      'আপনার ₹৫০ আছে। চাল ₹${w.number(cost)}, কল ₹১৫। কত বাকি?',
                    ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      gap,
      grid(
        choices
            .map(
              (n) => tile(
                Text('₹${w.number(n)}', style: const TextStyle(fontSize: 30)),
                () => evaluate(n == expected),
              ),
            )
            .toList(),
        ratio: 1.7,
      ),
    ];
  }

  List<Widget> bamboo() {
    final expected = round % 3;
    final neededRotation = tier == 0 ? 0 : (round + 1) % 4;
    return [
      Panel(
        color: sage,
        child: Column(
          children: [
            Text(
              w.text(
                'Match this outline',
                'এই আৰ্হিটো মিলাওক',
                'এই নকশাটি মেলান',
              ),
            ),
            gap,
            RotatedBox(
              quarterTurns: neededRotation,
              child: Icon(
                [
                  Icons.turn_right_rounded,
                  Icons.north_east_rounded,
                  Icons.south_west_rounded,
                ][expected],
                size: 110,
                color: green,
              ),
            ),
          ],
        ),
      ),
      gap,
      grid(
        List.generate(
          3,
          (i) => tile(
            RotatedBox(
              quarterTurns: selected == i ? rotation : 0,
              child: Icon(
                [
                  Icons.turn_right_rounded,
                  Icons.north_east_rounded,
                  Icons.south_west_rounded,
                ][i],
                size: 70,
                color: rust,
              ),
            ),
            () => setState(() => selected = i),
            active: selected == i,
          ),
        ),
        ratio: 1.4,
      ),
      gap,
      if (tier > 0)
        OutlinedButton.icon(
          onPressed: selected < 0
              ? null
              : () => setState(() => rotation = (rotation + 1) % 4),
          icon: const Icon(Icons.rotate_right),
          label: Text(w.text('Turn piece', 'টুকুৰা ঘূৰাওক', 'টুকরো ঘোরান')),
        ),
      gap,
      FilledButton(
        onPressed: selected < 0
            ? null
            : () =>
                  evaluate(selected == expected && rotation == neededRotation),
        child: Text(w.done),
      ),
    ];
  }

  List<Widget> familyQuiz() {
    if (family.isEmpty) return [Text(w.noMemories)];
    final memory = family[round % family.length];
    final key = switch (g.mechanic) {
      Mechanic.where => 'place',
      Mechanic.there => 'others',
      _ => 'person',
    };
    final expected = memory[key] as String;
    final choices = <String>{
      expected,
      ...family.map((m) => m[key] as String).where((v) => v.isNotEmpty),
    }.take(tier + 2).toList()..shuffle(Random(round));
    return [
      if (g.mechanic == Mechanic.quiz)
        Panel(
          color: sage,
          child: Text(
            memory['caption'].toString().isEmpty
                ? w.text(
                    'Who is in this photo?',
                    'এই ফটোত কোন আছে?',
                    'এই ছবিতে কে আছেন?',
                  )
                : memory['caption'],
          ),
        )
      else
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 260,
            child: g.mechanic == Mechanic.detective
                ? ClipRect(
                    child: Transform.scale(
                      scale: 2 + tier.toDouble(),
                      child: Image.memory(
                        base64Decode(memory['image']),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  )
                : Image.memory(
                    base64Decode(memory['image']),
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      gap,
      if (tier == 2 && g.mechanic == Mechanic.where)
        ...freeAnswer(expected)
      else
        ...choices.map(
          (choice) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: () => evaluate(choice == expected),
              child: Text(choice),
            ),
          ),
        ),
      if (feedback == w.gentle) Text('${w.hint}: $expected'),
    ];
  }

  List<Widget> freeAnswer(String expected) => [
    TextField(
      controller: answer,
      decoration: InputDecoration(
        labelText: w.text('Your answer', 'আপোনাৰ উত্তৰ', 'আপনার উত্তর'),
      ),
    ),
    gap,
    OutlinedButton.icon(
      onPressed: () async {
        final ok = await voice.listen((v) {
          if (mounted) setState(() => answer.text = v);
        });
        if (mounted && !ok) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(w.noVoice)));
        }
      },
      icon: const Icon(Icons.mic_none),
      label: Text(w.speak),
    ),
    gap,
    FilledButton(
      onPressed: () => evaluate(
        answer.text.trim().toLowerCase() == expected.trim().toLowerCase(),
      ),
      child: Text(w.done),
    ),
  ];
  List<String> get tuneNames => [
    w.text('River', 'নদী', 'নদী'),
    w.text('Morning', 'ৰাতিপুৱা', 'সকাল'),
    w.text('Rain', 'বৰষুণ', 'বৃষ্টি'),
  ];
  List<String> get soundNames => [
    w.text('Drum', 'ঢোল', 'ঢোল'),
    w.text('Bell', 'ঘণ্টা', 'ঘণ্টা'),
    w.text('Bird-like whistle', 'চৰাইৰ দৰে সুহুৰি', 'পাখির মতো শিস'),
  ];
  List<Widget> audioQuiz() {
    final tune = g.mechanic == Mechanic.tune;
    final names = tune ? tuneNames : soundNames;
    final options = [
      target,
      ...List.generate(3, (j) => j).where((j) => j != target),
    ].take(tier == 0 ? 2 : 3).toList()..shuffle(Random(round));
    return [
      Panel(
        color: sage,
        child: Column(
          children: [
            Icon(g.icon, size: 70, color: green),
            gap,
            Text(w.text('Listen first', 'আগতে শুনক', 'আগে শুনুন')),
            ...List.generate(
              3,
              (i) => TextButton.icon(
                onPressed: () => playSound(i, tune: tune),
                icon: const Icon(Icons.volume_up_outlined),
                label: Text(names[i]),
              ),
            ),
          ],
        ),
      ),
      gap,
      FilledButton.icon(
        onPressed: () => playSound(target, tune: tune),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(
          w.text(
            'Play the mystery sound',
            'ৰহস্যৰ শব্দ শুনক',
            'রহস্যের শব্দ শুনুন',
          ),
        ),
      ),
      gap,
      ...List.generate(options.length, (i) {
        final index = options[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton(
            onPressed: () => evaluate(index == target),
            child: Text(names[index]),
          ),
        );
      }),
    ];
  }

  List<Widget> comparison() {
    if (family.length < 2) return [Text(w.noMemories)];
    return [
      ...[family.first, family.last].map(
        (m) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Panel(
            child: Column(
              children: [
                Image.memory(
                  base64Decode(m['image']),
                  height: 180,
                  fit: BoxFit.contain,
                ),
                Text('${m['place']} · ${m['date']}'),
              ],
            ),
          ),
        ),
      ),
      Text(
        w.text(
          'There is no single answer. Share what you remember with someone beside you.',
          'এটাই উত্তৰ নাই। কাষত থকা আপোনজনৰ সৈতে স্মৃতিৰ কথা পাতক।',
          'একটি নির্দিষ্ট উত্তর নেই। পাশে থাকা প্রিয়জনের সঙ্গে স্মৃতির কথা বলুন।',
        ),
      ),
      gap,
      FilledButton(onPressed: finish, child: Text(w.done)),
    ];
  }

  List<Widget> proverb() {
    final questions = [
      w.text('Slow and steady wins the…', 'একতাই…', 'একতাই…'),
      w.text('Practice makes…', 'সময় অমূল্য…', 'সময় অমূল্য…'),
      w.text('Better late than…', 'পৰিশ্ৰমেই সফলতাৰ…', 'পরিশ্রমই সাফল্যের…'),
    ];
    final endings = [
      w.text('race', 'বল', 'বল'),
      w.text('perfect', 'ধন', 'ধন'),
      w.text('never', 'চাবিকাঠি', 'চাবিকাঠি'),
    ];
    final options = [
      endings[round],
      w.text('rain', 'বৰষুণ', 'বৃষ্টি'),
      w.text('river', 'নদী', 'নদী'),
      w.text('flower', 'ফুল', 'ফুল'),
    ].take(tier + 2).toList()..shuffle(Random(round));
    return [
      Panel(
        color: sage,
        child: Text(
          questions[round],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30),
        ),
      ),
      gap,
      if (tier == 2)
        ...freeAnswer(endings[round])
      else
        ...options.map(
          (v) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: () => evaluate(v == endings[round]),
              child: Text(v),
            ),
          ),
        ),
      if (feedback == w.gentle) Text(endings[round]),
    ];
  }

  List<Widget> matching() {
    final shape = g.mechanic == Mechanic.shape;
    final search = g.mechanic == Mechanic.search;
    final recall = g.mechanic == Mechanic.recall;
    final options = List.generate(tier == 0 ? 2 : 4, (i) => i)
      ..shuffle(Random(round));
    final expected = round % (tier == 0 ? 2 : 4);
    Widget item(int i, {bool large = false}) => shape
        ? Icon(
            shapeIcons[i],
            size: large ? 80 : 58,
            color: palette[tier == 0 ? 0 : i],
          )
        : search
        ? Text(symbols[i], style: TextStyle(fontSize: large ? 80 : 58))
        : Image.asset(
            gameImages[i % 3],
            fit: BoxFit.cover,
            width: double.infinity,
            height: large ? 200 : double.infinity,
            color: i == 3 ? const Color(0x99315C49) : null,
            colorBlendMode: BlendMode.modulate,
          );
    return [
      Panel(
        color: sage,
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: recall && !reveal
              ? const SizedBox(
                  height: 150,
                  child: Center(
                    child: Icon(Icons.spa_outlined, size: 70, color: green),
                  ),
                )
              : item(expected, large: true),
        ),
      ),
      gap,
      if (recall && reveal)
        FilledButton(
          onPressed: () => setState(() => reveal = false),
          child: Text(w.text('I’m ready', 'মই সাজু', 'আমি প্রস্তুত')),
        )
      else
        grid(
          options
              .map(
                (i) => tile(
                  item(i),
                  () => evaluate(i == expected),
                  label: '${w.picture} ${w.number(i + 1)}',
                ),
              )
              .toList(),
          ratio: 1.3,
        ),
    ];
  }
}

class PuzzlePiece extends StatelessWidget {
  final String asset;
  final int index, side;
  const PuzzlePiece({
    super.key,
    required this.asset,
    required this.index,
    required this.side,
  });
  @override
  Widget build(BuildContext context) => ClipRect(
    child: SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: 1024 / side,
          height: 559 / side,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: 1024,
              maxWidth: 1024,
              minHeight: 559,
              maxHeight: 559,
              child: Transform.translate(
                offset: Offset(
                  -(index % side) * 1024 / side,
                  -(index ~/ side) * 559 / side,
                ),
                child: Image.asset(
                  asset,
                  width: 1024,
                  height: 559,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
