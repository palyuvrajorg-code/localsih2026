import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'store.dart';
import 'ui.dart';
import 'main.dart' show languagePicker;
import 'catalog.dart';

class CaregiverSetup extends StatefulWidget {
  final AppStore store;
  const CaregiverSetup({super.key, required this.store});
  @override
  State<CaregiverSetup> createState() => _CaregiverSetupState();
}

class _CaregiverSetupState extends State<CaregiverSetup> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.store.name);
  late final phone = TextEditingController(text: widget.store.phone);
  final pin = TextEditingController(), confirm = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    pin.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final w = s.w;
    return Scaffold(
      appBar: AppBar(title: Text(w.caregiver)),
      body: PageBody(
        children: [
          Text(
            w.text(
              'A familiar beginning',
              'এটা চিনাকি আৰম্ভণি',
              'একটি চেনা শুরু',
            ),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
          ),
          gap,
          Text(
            w.text(
              'Set up once, then hand the phone to your loved one.',
              'এবাৰ ছেট আপ কৰি আপোনজনক ফোনটো দিয়ক।',
              'একবার সেট আপ করে প্রিয়জনকে ফোনটি দিন।',
            ),
          ),
          gap,
          Form(
            key: form,
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: w.text('Patient’s name', 'নাম', 'নাম'),
                  ),
                  validator: (v) => v!.trim().isEmpty
                      ? w.text('Enter a name', 'নাম লিখক', 'নাম লিখুন')
                      : null,
                ),
                gap,
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: w.text(
                      'Family phone (optional)',
                      'পৰিয়ালৰ ফোন (ঐচ্ছিক)',
                      'পরিবারের ফোন (ঐচ্ছিক)',
                    ),
                  ),
                  validator: (v) =>
                      v!.isNotEmpty &&
                          !RegExp(r'^\+?[0-9 ()-]{7,20}$').hasMatch(v)
                      ? w.text(
                          'Enter a valid number',
                          'সঠিক নম্বৰ লিখক',
                          'সঠিক নম্বর লিখুন',
                        )
                      : null,
                ),
                gap,
                languagePicker(s),
                gap,
                TextFormField(
                  controller: pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: w.text(
                      'Create a 4-digit family PIN',
                      '৪ অংকৰ পৰিয়ালৰ পিন',
                      '৪ সংখ্যার পরিবারের পিন',
                    ),
                  ),
                  validator: (v) => !RegExp(r'^\d{4}$').hasMatch(v ?? '')
                      ? w.text(
                          'Use 4 digits',
                          '৪টা অংক লিখক',
                          '৪টি সংখ্যা লিখুন',
                        )
                      : null,
                ),
                gap,
                TextFormField(
                  controller: confirm,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: w.text(
                      'Repeat PIN',
                      'পিন আকৌ লিখক',
                      'পিন আবার লিখুন',
                    ),
                  ),
                  validator: (v) => v != pin.text
                      ? w.text(
                          'PINs must match',
                          'একে পিন লিখক',
                          'একই পিন লিখুন',
                        )
                      : null,
                ),
                gap,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!form.currentState!.validate()) return;
                      s.name = name.text.trim();
                      s.phone = phone.text.trim();
                      s.setPin(pin.text);
                      s.onboarded = true;
                      await s.save();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaregiverDashboard(store: s),
                        ),
                      );
                    },
                    child: Text(
                      w.text('Create a caring space', 'আৰম্ভ কৰক', 'শুরু করুন'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> enterCaregiver(BuildContext context, AppStore s) async {
  if (s.pinHash.isEmpty) {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CaregiverSetup(store: s)),
    );
    return;
  }
  final unlocked = await showDialog<bool>(
    context: context,
    builder: (_) => PinDialog(store: s),
  );
  if (unlocked == true && context.mounted) {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CaregiverDashboard(store: s)),
    );
  }
  // The gate never exposes a default PIN or persists an unlocked session.
}

class PinDialog extends StatefulWidget {
  final AppStore store;
  const PinDialog({super.key, required this.store});
  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final pin = TextEditingController();
  String? error;
  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  Future<void> unlock() async {
    final s = widget.store;
    final w = s.w;
    final lockedUntil = s.prefs.getInt('pin.lockedUntil') ?? 0;
    if (DateTime.now().millisecondsSinceEpoch < lockedUntil) {
      setState(
        () => error = w.text(
          'Please wait 30 seconds.',
          '৩০ ছেকেণ্ড ৰওক।',
          '৩০ সেকেন্ড অপেক্ষা করুন।',
        ),
      );
      return;
    }
    if (s.checkPin(pin.text)) {
      await s.prefs.setInt('pin.failures', 0);
      if (mounted) Navigator.pop(context, true);
    } else {
      final failures = (s.prefs.getInt('pin.failures') ?? 0) + 1;
      await s.prefs.setInt('pin.failures', failures % 5);
      if (failures >= 5) {
        await s.prefs.setInt(
          'pin.lockedUntil',
          DateTime.now()
              .add(const Duration(seconds: 30))
              .millisecondsSinceEpoch,
        );
      }
      if (mounted) {
        setState(
          () => error = w.text(
            'Check your PIN and try again.',
            'পিন পৰীক্ষা কৰি আকৌ চেষ্টা কৰক।',
            'পিন দেখে আবার চেষ্টা করুন।',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.store.w.caregiver),
    content: TextField(
      controller: pin,
      autofocus: true,
      obscureText: true,
      maxLength: 4,
      keyboardType: TextInputType.number,
      onSubmitted: (_) => unlock(),
      decoration: InputDecoration(labelText: 'PIN', errorText: error),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(widget.store.w.cancel),
      ),
      FilledButton(onPressed: unlock, child: Text(widget.store.w.next)),
    ],
  );
}

class CaregiverDashboard extends StatefulWidget {
  final AppStore store;
  const CaregiverDashboard({super.key, required this.store});
  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  int page = 0;
  bool importing = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final w = s.w;
    return AnimatedBuilder(
      animation: s,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(w.caregiver),
          actions: [
            IconButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              tooltip: w.home,
              icon: const Icon(Icons.home_outlined),
            ),
          ],
        ),
        body: PageBody(
          width: 820,
          children: [
            Text(
              w.text(
                'A little care goes a long way.',
                'আপোনাৰ যত্নই বহুত সহায় কৰে।',
                'আপনার যত্ন অনেক সাহায্য করে।',
              ),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            gap,
            if (page == 0) ...overview(s),
            if (page == 1) ...[
              Text(
                w.text('Memory vault', 'স্মৃতি ভঁৰাল', 'স্মৃতির ভাণ্ডার'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                w.text(
                  'Add real family photos and a short story in the patient’s language. Photos stay on this device.',
                  'পৰিয়ালৰ ফটো আৰু চিনাকি ভাষাত এটা সৰু কাহিনী যোগ কৰক। ফটো এই যন্ত্ৰতে থাকে।',
                  'পরিবারের ছবি ও পরিচিত ভাষায় ছোট গল্প যোগ করুন। ছবি এই যন্ত্রেই থাকে।',
                ),
              ),
              gap,
              FilledButton.icon(
                onPressed: importing ? null : addMemory,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  importing
                      ? w.text('Adding…', 'যোগ কৰি আছোঁ…', 'যোগ করছি…')
                      : w.text(
                          'Add a memory',
                          'স্মৃতি যোগ কৰক',
                          'স্মৃতি যোগ করুন',
                        ),
                ),
              ),
              gap,
              ...s.memories.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(
                            base64Decode(m['image']),
                            height: 170,
                            fit: BoxFit.cover,
                          ),
                        ),
                        gap,
                        Text(
                          '${m['person']} · ${m['place']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(m['caption']),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => editMemory(m),
                                child: Text(
                                  w.text('Edit', 'সম্পাদনা', 'সম্পাদনা'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () => removeItem(s.memories, m),
                                child: Text(
                                  w.text('Remove', 'আঁতৰাওক', 'সরান'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (page == 2) ...[
              Text(
                w.text('Daily reminders', 'দৈনিক সোঁৱৰণী', 'প্রতিদিনের কাজ'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                w.text(
                  'Shown in My day. This demo does not send background notifications.',
                  'মোৰ দিনটোত দেখা যায়। এই ডেমোৱে পটভূমিত জাননী নপঠিয়ায়।',
                  'আমার দিনে দেখা যায়। এই ডেমো পটভূমিতে বিজ্ঞপ্তি পাঠায় না।',
                ),
              ),
              gap,
              FilledButton.icon(
                onPressed: () => editReminder(),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  w.text('Add reminder', 'সোঁৱৰণী যোগ কৰক', 'কাজ যোগ করুন'),
                ),
              ),
              gap,
              ...s.reminders.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${r['time']}  ·  ${r['title']}'),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => editReminder(r),
                              child: Text(
                                w.text('Edit', 'সম্পাদনা', 'সম্পাদনা'),
                              ),
                            ),
                            TextButton(
                              onPressed: () => removeItem(s.reminders, r),
                              child: Text(w.text('Remove', 'আঁতৰাওক', 'সরান')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (page == 3) ...[
              languagePicker(s),
              gap,
              Text(w.text('Text size', 'লিখনীৰ আকাৰ', 'লেখার আকার')),
              Slider(
                value: s.fontSize,
                min: 20,
                max: 28,
                divisions: 4,
                label: w.number(s.fontSize.toInt()),
                onChanged: (v) {
                  s.fontSize = v;
                  s.save();
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  w.text(
                    'Read instructions aloud',
                    'নিৰ্দেশনা পঢ়ি শুনাওক',
                    'নির্দেশনা পড়ে শোনান',
                  ),
                ),
                value: s.voice,
                onChanged: (v) {
                  s.voice = v;
                  s.save();
                },
              ),
              Text(
                w.text(
                  'Regional speech depends on installed device voices. Download an Assamese or Bengali voice in your device settings if available.',
                  'কণ্ঠসেৱা যন্ত্ৰত থকা ভাষাৰ ওপৰত নিৰ্ভৰ কৰে। যন্ত্ৰৰ ছেটিংছত অসমীয়া কণ্ঠ উপলব্ধ থাকিলে ডাউনলোড কৰক।',
                  'কণ্ঠসেবা যন্ত্রে থাকা ভাষার উপর নির্ভর করে। যন্ত্রের সেটিংসে বাংলা কণ্ঠ থাকলে ডাউনলোড করুন।',
                ),
                style: const TextStyle(fontSize: 18, color: muted),
              ),
              gap,
              TextFormField(
                initialValue: s.name,
                decoration: InputDecoration(
                  labelText: w.text('Patient’s name', 'নাম', 'নাম'),
                ),
                onChanged: (v) {
                  s.name = v;
                  s.save();
                },
              ),
              gap,
              TextFormField(
                initialValue: s.phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: w.text(
                    'Family phone',
                    'পৰিয়ালৰ ফোন',
                    'পরিবারের ফোন',
                  ),
                ),
                onChanged: (v) {
                  s.phone = v.replaceAll(RegExp(r'[^0-9+]'), '');
                  s.save();
                },
              ),
              gap,
              Panel(
                color: sage,
                child: Text(
                  w.text(
                    'Local demo • No account needed. Online family circles, live location sharing, video calls and cloud sync are not connected.',
                    'স্থানীয় ডেমো। একাউণ্ট নালাগে। অনলাইন পৰিয়াল, অৱস্থান ভাগ-বতৰা, ভিডিঅ’ কল আৰু ক্লাউড ছিংক সংযুক্ত নহয়।',
                    'স্থানীয় ডেমো। অ্যাকাউন্ট লাগে না। অনলাইন পরিবার, অবস্থান ভাগ করা, ভিডিও কল ও ক্লাউড সিঙ্ক যুক্ত নয়।',
                  ),
                ),
              ),
            ],
            if (s.storageError != null)
              Text(s.storageError!, style: const TextStyle(color: rust)),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          height: 88,
          selectedIndex: page,
          onDestinationSelected: (v) => setState(() => page = v),
          labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 18)),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              label: w.text('Overview', 'সাৰাংশ', 'সারাংশ'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.photo_library_outlined),
              label: w.text('Photos', 'ফটো', 'ছবি'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.today_outlined),
              label: w.text('My day', 'দিন', 'দিন'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.tune_rounded),
              label: w.text('Settings', 'ছেটিংছ', 'সেটিংস'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> overview(AppStore s) {
    final w = s.w;
    final completed = s.sessions.where((e) => e['abandoned'] == false).toList();
    return [
      Panel(
        color: sage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              w.text(
                'Small moments count.',
                'সৰু মুহূৰ্তও মূল্যৱান।',
                'ছোট মুহূর্তও মূল্যবান।',
              ),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            gap,
            Text(
              '${w.number(completed.length)} ${w.text('activities enjoyed', 'খেল সম্পূৰ্ণ', 'খেলা সম্পূর্ণ')}',
            ),
            Text(
              '${w.number(s.memories.length)} ${w.text('family memories', 'পৰিয়ালৰ স্মৃতি', 'পরিবারের স্মৃতি')}',
            ),
          ],
        ),
      ),
      gap,
      Text(
        w.text(
          'Engagement this week',
          'এই সপ্তাহৰ অংশগ্ৰহণ',
          'এই সপ্তাহের অংশগ্রহণ',
        ),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
      gap,
      Panel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final day = DateTime.now().subtract(Duration(days: 6 - i));
            final key = day.toIso8601String().substring(0, 10);
            final n = completed
                .where((e) => (e['at'] as String).startsWith(key))
                .length;
            return Expanded(
              child: Semantics(
                label: '$key: $n',
                child: Column(
                  children: [
                    Text(w.number(n), style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Container(
                      height: 12 + (n * 18).clamp(0, 100).toDouble(),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: n == 0 ? sage : green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      w.number(day.day),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      gap,
      Text(
        w.text('Activity comfort', 'খেলৰ স্তৰ', 'খেলার স্তর'),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
      Text(
        w.text(
          'Levels change gradually after recent sessions. This is engagement information, not a clinical assessment.',
          'শেহতীয়া খেল অনুসৰি স্তৰ লাহে লাহে সলনি হয়। এয়া অংশগ্ৰহণৰ তথ্য, চিকিৎসাৰ মূল্যায়ন নহয়।',
          'সাম্প্রতিক খেলা অনুযায়ী স্তর ধীরে বদলায়। এটি অংশগ্রহণের তথ্য, চিকিৎসার মূল্যায়ন নয়।',
        ),
        style: const TextStyle(fontSize: 18, color: muted),
      ),
      gap,
      if (s.sessions.isEmpty)
        Text(
          w.text(
            'Play an activity to see a trend here.',
            'ইয়াত তথ্য চাবলৈ এটা খেল খেলক।',
            'এখানে তথ্য দেখতে একটি খেলা খেলুন।',
          ),
        ),
      ...catalog
          .where((g) => s.sessions.any((e) => e['game'] == g.id))
          .map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.title(w)),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (s.step(g.id) + 1) / 12,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${w.text('Comfort step', 'স্তৰ', 'স্তর')} ${w.number(s.step(g.id) + 1)} / ${w.number(12)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
    ];
  }

  Future<void> removeItem(
    List<Map<String, dynamic>> list,
    Map<String, dynamic> item,
  ) async {
    final w = widget.store.w;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          w.text('Remove this item?', 'এইটো আঁতৰাবনে?', 'এটি সরাবেন?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(w.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(w.text('Remove', 'আঁতৰাওক', 'সরান')),
          ),
        ],
      ),
    );
    if (yes == true) {
      list.remove(item);
      await widget.store.save();
    }
  }

  Future<void> addMemory() async {
    setState(() => importing = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        imageQuality: 75,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 1500000) {
        throw StateError('Choose a smaller photo (under 1.5 MB).');
      }
      if (!mounted) return;
      await editMemory({
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'image': base64Encode(bytes),
        'person': '',
        'place': '',
        'date': '',
        'caption': '',
        'others': '',
      }, fresh: true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.store.w.text(
                'Could not add the photo. Try a smaller image.',
                'ফটো যোগ নহ’ল। সৰু ফটো বাছক।',
                'ছবি যোগ হয়নি। ছোট ছবি বাছুন।',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => importing = false);
    }
  }

  Future<void> editMemory(Map<String, dynamic> m, {bool fresh = false}) async {
    final w = widget.store.w;
    final form = GlobalKey<FormState>();
    final fields = {
      for (final key in ['person', 'place', 'date', 'caption', 'others'])
        key: TextEditingController(text: m[key] ?? ''),
    };
    final labels = [
      w.text('Person’s name', 'ব্যক্তিৰ নাম', 'ব্যক্তির নাম'),
      w.text('Place', 'ঠাই', 'স্থান'),
      w.text(
        'Date (YYYY-MM-DD, optional)',
        'তাৰিখ (YYYY-MM-DD, ঐচ্ছিক)',
        'তারিখ (YYYY-MM-DD, ঐচ্ছিক)',
      ),
      w.text('Story / relationship', 'কাহিনী / সম্পৰ্ক', 'গল্প / সম্পর্ক'),
      w.text(
        'Others in this memory (optional)',
        'লগত থকা আন লোক (ঐচ্ছিক)',
        'সঙ্গে থাকা অন্যরা (ঐচ্ছিক)',
      ),
    ];
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(w.memories),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(fields.length, (i) {
                  final key = fields.keys.elementAt(i);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: TextFormField(
                      controller: fields[key],
                      maxLines: key == 'caption' ? 3 : 1,
                      decoration: InputDecoration(labelText: labels[i]),
                      validator: (v) {
                        if (key == 'person' && (v ?? '').trim().isEmpty) {
                          return w.text(
                            'Enter a name',
                            'নাম লিখক',
                            'নাম লিখুন',
                          );
                        }
                        if (key == 'date' &&
                            (v ?? '').isNotEmpty &&
                            (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v!) ||
                                DateTime.tryParse(v) == null ||
                                DateTime.parse(
                                      v,
                                    ).toIso8601String().substring(0, 10) !=
                                    v)) {
                          return w.text(
                            'Use a valid YYYY-MM-DD date',
                            'সঠিক YYYY-MM-DD তাৰিখ লিখক',
                            'সঠিক YYYY-MM-DD তারিখ লিখুন',
                          );
                        }
                        return null;
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(w.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: Text(w.save),
          ),
        ],
      ),
    );
    if (saved == true) {
      for (final e in fields.entries) {
        m[e.key] = e.value.text.trim();
      }
      if (fresh) widget.store.memories.add(m);
      await widget.store.save();
    }
    // Controllers belong to the closing dialog and are disposed after its transition.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final c in fields.values) {
      c.dispose();
    }
  }

  Future<void> editReminder([Map<String, dynamic>? reminder]) async {
    final w = widget.store.w;
    final title = TextEditingController(text: reminder?['title'] ?? '');
    final form = GlobalKey<FormState>();
    final time = TextEditingController(text: reminder?['time'] ?? '09:00');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          w.text('Daily reminder', 'দৈনিক সোঁৱৰণী', 'প্রতিদিনের কাজ'),
        ),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: title,
                decoration: InputDecoration(
                  labelText: w.text(
                    'What to do',
                    'কৰিবলগীয়া কাম',
                    'কী করতে হবে',
                  ),
                ),
                validator: (v) => v!.trim().isEmpty
                    ? w.text('Enter a reminder', 'কাম লিখক', 'কাজ লিখুন')
                    : null,
              ),
              gap,
              TextFormField(
                controller: time,
                decoration: InputDecoration(
                  labelText: w.text(
                    'Time (24-hour HH:mm)',
                    'সময় (HH:mm)',
                    'সময় (HH:mm)',
                  ),
                ),
                validator: (v) =>
                    !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(v ?? '')
                    ? w.text(
                        'Use HH:mm, e.g. 09:30',
                        'উদাহৰণ: 09:30',
                        'উদাহরণ: 09:30',
                      )
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(w.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: Text(w.save),
          ),
        ],
      ),
    );
    if (saved == true) {
      final r =
          reminder ?? {'id': DateTime.now().microsecondsSinceEpoch.toString()};
      r['title'] = title.text.trim();
      r['time'] = time.text;
      if (reminder == null) widget.store.reminders.add(r);
      await widget.store.save();
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    title.dispose();
    time.dispose();
  }
}
