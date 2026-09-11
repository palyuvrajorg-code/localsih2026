# SMRITI

A Flutter cognitive-care **local demo**, built around an intentionally minimal patient experience. Assamese is the default, with Bengali and English. The patient home offers one suggested activity, memories and today's tasks. Family management is behind a caregiver-created PIN.

## Run

```powershell
cd 'D:\Jagdish\SIH- AARYAN'
flutter pub get
flutter run -d chrome
# Or connect an Android device with USB debugging:
flutter run
```

```powershell
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug
```

Android and web projects are included. iOS project files are included, but an iOS build requires macOS and Xcode. The debug APK, when built, is at `build/app/outputs/flutter-apk/app-debug.apk`.

## Demo walkthrough

1. Pick Assamese, Bengali or English. Choose **Set up with family** to add a name, optional family phone, and your own four-digit PIN. **Try the activities** opens the patient experience without requiring a profile.
2. From Family settings, add real family pictures with people, places, dates, a written story and optionally other people in the memory. Photos are resized on import. Add daily tasks and adjust text size or speech.
3. Return home and play a picture puzzle. All three supplied images are selectable. Pieces and destinations are tapped, so dragging is not required.
4. Explore **More activities** for the catalog. Complete activities to populate actual engagement history. Family games unlock when relevant tagged memories exist; there are no fictional family members.
5. **My day** records task completion for the current date. **Call for help** opens the configured family's number in the device dialer. A desktop without a dialer displays the number instead.

## Included

- A calm cream/sage interface, large buttons, a shared game shell, positive feedback, persistent help access, and 20–28 base text settings that also respect device text scaling.
- Authored Assamese/Bengali/English strings and a bundled Noto Sans Bengali font. Translation copy should receive native-speaker review before a public pilot. Flutter's built-in Assamese Material translations are unavailable, so generic Material controls use Bengali; app-authored patient copy is Assamese.
- All 24 catalog entries route to local activities or a clear content prerequisite. Three difficulty anchors are used by the main mechanics. Some catalog mechanics are deliberately simplified for this demo (see below).
- A photo puzzle with 4/9/16 pieces; repeat patterns; seed-to-meal ordering; drum-pad sequences; shopping arithmetic; spatial orientation matching; family recognition/place/association/timeline/crop/story activities; audio matching; proverb completion; memory chains; picture/shape matching and number ordering.
- A caregiver-managed photo vault, caption reading, editable daily reminders, family contact, settings, real weekly engagement bars and per-game comfort levels.
- Local JSON persistence in SharedPreferences. Photo bytes are stored locally rather than temporary picker paths, with a 1.5 MB per-photo import limit. This storage is for a bounded demo, not a large production vault. Native installed-app game assets work offline. The web build needs its assets loaded/served and is not a guaranteed offline PWA.
- A salted PIN hash with attempt throttling, no default PIN and no stored plain-text PIN. This is a casual role gate, not encrypted medical-record storage. Forgot-PIN recovery is not implemented.
- Session history records attempts, completion/abandonment, accuracy, elapsed response averages and hints. A rolling five-attempt rule considers the latest three sessions and nudges a bounded 0–11 level by at most one step. UI variants currently change at the three anchor boundaries; fine-step interpolation and time-of-day recommendation are future work.
- Platform TTS, speech recognition for home commands and free answers, and six original synthesized local WAV sounds. Assamese/Bengali voice availability and offline speech recognition depend on installed device engines. Voice navigation currently covers the home actions, not every catalog action. Missing voice support leaves touch controls usable.

## Scope and deliberate simplifications

This is a functional first demo, **not full implementation of every production requirement in the supplied brief**.

- Traditional Pattern uses the repeat-pattern engine. Bamboo Builder uses shape/orientation matching rather than freeform construction. Find It uses visible object choices rather than scene hotspots. Rapid Recall currently asks for one remembered picture. Sound Match and Name That Tune use generated training sounds/motifs, not licensed regional recordings. Rhythm validates pad order rather than tap timing. These activities do not implement every specified hard-tier rule.
- Family Quiz is a local caption-based activity, not an online grandparent call. Memory Chain is a single-device sequence activity. Then & Now requires two dated photos of the same place and prompts a conversation; it does not infer visual changes or grade narration.
- Speed Jigsaw intentionally shares the untimed puzzle engine. No stress-inducing timers or numeric patient scores are used.
- Reminders appear in My day, with date-specific completion. **Background notifications, takeover alerts and snoozing are not implemented.**
- **No live GPS sharing, walk-home guidance, automatic emergency messaging, online multiplayer, invitations, voice-note recording, cloud accounts, remote caregiver monitoring, backend sync or video calling is connected.** The help action opens a phone dialer; it does not claim a call was connected or a location was sent.
- The original temple and courtyard photos are used as supplied; they are not identified as Northeast landmarks. Northeast localization currently means Assamese/Bengali interface copy, not a validated content pack for all eight states.
- No weather feed, medical diagnoses or fabricated wellbeing data. Charts report activity engagement only.

## Files

- `lib/main.dart`: onboarding, minimal patient home, memory viewer, daily tasks and help.
- `lib/games.dart`, `lib/catalog.dart`: game registry, mechanics, feedback and completion.
- `lib/caregiver.dart`: PIN gate, setup, memory/reminder management and trends.
- `lib/store.dart`: persistence, role-gate hashing, rolling session adaptation.
- `lib/strings.dart`, `lib/voice.dart`, `lib/ui.dart`: language, platform speech and visual system.
- `assets/images/`: unchanged copies of the three user-provided pictures; originals remain in the project root.
- `assets/fonts/OFL.txt`: bundled font license.
- `test/widget_test.dart`: persistence/adaptation tests, 24 game screens at all three anchor levels, large Assamese patient layout, completion and reminder checks.

Dependencies follow the package-maintainer documentation: [Flutter TTS](https://pub.dev/packages/flutter_tts), [Speech to Text](https://pub.dev/packages/speech_to_text), [Image Picker](https://pub.dev/packages/image_picker), [URL Launcher](https://pub.dev/packages/url_launcher) and [Shared Preferences](https://pub.dev/packages/shared_preferences).
