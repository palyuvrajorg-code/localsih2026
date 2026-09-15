import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'strings.dart';
import 'data/models/models.dart';
import 'core/services/closed_loop_engine.dart';
import 'core/services/safety_engine.dart';
import 'core/services/location_engine.dart';
import 'core/services/sync_engine.dart';
import 'core/services/voice_engine.dart';

const gameImages = [
  'assets/images/lotus.jpg',
  'assets/images/courtyard.jpg',
  'assets/images/temple.jpg',
];

class AppStore extends ChangeNotifier {
  static AppStore? _instance;
  static AppStore? get current => _instance;

  final SharedPreferences prefs;
  String language = 'as', name = 'Kamala Devi', phone = '+91 98765 43210', pinHash = '', salt = '';
  double fontSize = 20;
  bool voice = true, onboarded = true;
  List<Map<String, dynamic>> memories = [], reminders = [], sessions = [];
  Map<String, dynamic> levels = {};
  String? storageError;
  Future<void> _writes = Future.value();

  // Multi-role state
  UserRole currentRole = UserRole.elder;
  final ElderProfile elderProfile = const ElderProfile(
    id: 'elder-1',
    name: 'Kamala Devi',
    age: 76,
    primaryLanguage: 'as',
    caregiverName: 'Ananya',
    doctorName: 'Dr. R. Sharma',
    emergencyPhone: '+91 98765 43210',
    address: 'Ulubari, Guwahati, Assam',
  );

  // Dementia care tasks (Closed-loop)
  List<CareTask> careTasks = [];
  List<Medication> medications = [];
  List<Appointment> appointments = [];
  List<Story> stories = [];
  List<FamilyMember> familyMembers = [];
  List<FamilyActivity> familyActivities = [];
  List<CareAlert> alerts = [];
  int hydrationGlassesTaken = 4;
  final int targetHydration = 6;

  // Services
  late final ClosedLoopEngine closedLoopEngine;
  late final SafetyEngine safetyEngine;
  late final LocationEngine locationEngine;
  late final SyncEngine syncEngine;
  late final ConversationService voiceService;

  AppStore(this.prefs) {
    _instance = this;
    _initServices();
    _loadFromPrefs();
    _seedDefaultDataIfEmpty();
  }

  void _initServices() {
    closedLoopEngine = ClosedLoopEngine(
      onAlert: (alert) {
        alerts.insert(0, alert);
        notifyListeners();
      },
      onStateChanged: () {
        save();
        notifyListeners();
      },
    );

    safetyEngine = SafetyEngine(
      onAlertTriggered: (alert) {
        alerts.insert(0, alert);
        notifyListeners();
      },
    );

    locationEngine = LocationEngine(
      onAlertTriggered: (alert) {
        alerts.insert(0, alert);
        notifyListeners();
      },
    );

    syncEngine = SyncEngine();
    voiceService = LocalMockConversationService();
  }

  void _loadFromPrefs() {
    try {
      final raw = prefs.getString('xopun.v1');
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      language = data['language'] ?? 'as';
      name = data['name'] ?? 'Kamala Devi';
      phone = data['phone'] ?? '+91 98765 43210';
      pinHash = data['pinHash'] ?? '';
      salt = data['salt'] ?? '';
      fontSize = (data['fontSize'] as num? ?? 20).toDouble();
      voice = data['voice'] ?? true;
      onboarded = data['onboarded'] ?? true;
      memories = List<Map<String, dynamic>>.from(data['memories'] ?? []);
      reminders = List<Map<String, dynamic>>.from(data['reminders'] ?? []);
      sessions = List<Map<String, dynamic>>.from(data['sessions'] ?? []);
      levels = Map<String, dynamic>.from(data['levels'] ?? {});

      if (data['hydration'] != null) {
        hydrationGlassesTaken = (data['hydration'] as num).toInt();
      }
    } catch (_) {
      storageError = 'Stored data could not be read. Please ask your family for help.';
    }
  }

  void _seedDefaultDataIfEmpty() {
    // Medications
    if (medications.isEmpty) {
      medications = [
        const Medication(
          id: 'med-1',
          name: 'Amlodipine (Blood Pressure)',
          dosage: '5mg tablet',
          instructions: 'Take with warm water after light breakfast',
          scheduleTimes: ['08:00'],
          purpose: 'Hypertension support',
        ),
        const Medication(
          id: 'med-2',
          name: 'Vitamin B12 + D3',
          dosage: '1 capsule',
          instructions: 'Take with midday lunch',
          scheduleTimes: ['13:00'],
          purpose: 'Nerve & Bone Vitality',
        ),
        const Medication(
          id: 'med-3',
          name: 'Donepezil (Cognitive Support)',
          dosage: '5mg tablet',
          instructions: 'Take 30 minutes before bedtime',
          scheduleTimes: ['20:00'],
          purpose: 'Memory & focus care',
        ),
      ];
    }

    // Daily Care Tasks
    if (careTasks.isEmpty) {
      careTasks = [
        CareTask(
          id: 'task-med-morning',
          title: 'Morning Medicine (Amlodipine 5mg)',
          time: '08:00',
          category: TaskCategory.medication,
          instructions: 'Take with warm water after light breakfast',
          dosage: '1 tablet',
          scheduledDate: DateTime.now(),
          status: TaskStatus.scheduled,
        ),
        CareTask(
          id: 'task-water-morning',
          title: 'Drink Fresh Water (Glass 3)',
          time: '09:30',
          category: TaskCategory.hydration,
          instructions: 'Warm or room temperature water from copper jug',
          scheduledDate: DateTime.now(),
          status: TaskStatus.completed,
        ),
        CareTask(
          id: 'task-brain-activity',
          title: 'Gentle Brain Activity (Memory Matrix)',
          time: '10:00',
          category: TaskCategory.cognitive,
          instructions: 'Spend 5 calm minutes enjoying traditional patterns',
          scheduledDate: DateTime.now(),
          status: TaskStatus.scheduled,
        ),
        CareTask(
          id: 'task-lunch',
          title: 'Midday Meal & Vitamin B12',
          time: '13:00',
          category: TaskCategory.meal,
          instructions: 'Rice, dal, and steamed vegetables with medication',
          scheduledDate: DateTime.now(),
          status: TaskStatus.scheduled,
        ),
        CareTask(
          id: 'task-family-story',
          title: 'Family Story Activity with Ananya',
          time: '16:00',
          category: TaskCategory.family,
          instructions: 'Review memories together or listen to folklore',
          scheduledDate: DateTime.now(),
          status: TaskStatus.scheduled,
        ),
        CareTask(
          id: 'task-med-night',
          title: 'Evening Medicine (Donepezil 5mg)',
          time: '20:00',
          category: TaskCategory.medication,
          instructions: 'Take with half glass of water before sleep',
          dosage: '1 tablet',
          scheduledDate: DateTime.now(),
          status: TaskStatus.scheduled,
        ),
      ];
    }

    // Seed Appointments
    if (appointments.isEmpty) {
      appointments = [
        Appointment(
          id: 'apt-1',
          doctorName: 'Dr. R. Sharma',
          specialty: 'Geriatric Neurologist',
          dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          status: AppointmentStatus.upcoming,
          location: 'SMRITI Telehealth Video Consultation',
          isTelehealth: true,
          notes: 'Routine memory review and daily activity discussion.',
        ),
        Appointment(
          id: 'apt-2',
          doctorName: 'Dr. P. Baruah',
          specialty: 'General Physician',
          dateTime: DateTime.now().subtract(const Duration(days: 14)),
          status: AppointmentStatus.completed,
          location: 'Guwahati City Clinic',
          isTelehealth: false,
          notes: 'Blood pressure stable (124/82). Continue Amlodipine regimen.',
        ),
      ];
    }

    // Seed Family Members
    if (familyMembers.isEmpty) {
      familyMembers = [
        const FamilyMember(
          id: 'fam-1',
          name: 'Ananya',
          relationship: 'Granddaughter & Primary Caregiver',
          photoAsset: 'assets/images/courtyard.jpg',
          phoneNumber: '+91 98765 11223',
          note: 'Visits every evening and helps with evening medications.',
        ),
        const FamilyMember(
          id: 'fam-2',
          name: 'Bhaskar',
          relationship: 'Son (Living in Bangalore)',
          photoAsset: 'assets/images/temple.jpg',
          phoneNumber: '+91 98765 44556',
          note: 'Video calls every Sunday at 4:00 PM.',
        ),
        const FamilyMember(
          id: 'fam-3',
          name: 'Meena',
          relationship: 'Daughter-in-law',
          photoAsset: 'assets/images/lotus.jpg',
          phoneNumber: '+91 98765 77889',
          note: 'Loves cooking traditional Assamese Jolpan with Kamala.',
        ),
      ];
    }

    // Seed Family Activities
    if (familyActivities.isEmpty) {
      familyActivities = [
        FamilyActivity(
          id: 'fa-1',
          title: 'Who is this in the Jorhat photo?',
          senderName: 'Ananya',
          type: 'photo_id',
          prompt: 'Look at the festive photo from 1992. Do you remember who was playing the Pepa?',
          status: FamilyActivityStatus.sent,
          sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        FamilyActivity(
          id: 'fa-2',
          title: 'Traditional Narikol Pitha Recipe',
          senderName: 'Meena',
          type: 'recipe',
          prompt: 'Which festival did we make the coconut pitha for?',
          status: FamilyActivityStatus.completed,
          sentAt: DateTime.now().subtract(const Duration(days: 2)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    }

    // Seed Stories
    if (stories.isEmpty) {
      stories = [
        const Story(
          id: 'story-1',
          title: 'Grandmother’s Traditional Pitha Recipe',
          category: 'recipes',
          narration: 'Every Magh Bihu, our entire courtyard in Jorhat smelled of roasted sesame and grated jaggery. We sat around the clay hearth making Til Pitha while the winter mist settled.',
          durationSeconds: 95,
          recordedDate: 'Recorded by Ananya on 12 Jan 2026',
          tags: ['Bihu', 'Pitha', 'Childhood'],
        ),
        const Story(
          id: 'story-2',
          title: 'The Legend of the Brahmaputra River',
          category: 'traditions',
          narration: 'From the heights of the Himalayas down through the red river valley, the mighty Brahmaputra brings life to the paddies. In monsoons, we listened to its grand song.',
          durationSeconds: 120,
          recordedDate: 'Recorded by Kamala Devi',
          tags: ['River', 'Heritage', 'Assam'],
        ),
        const Story(
          id: 'story-3',
          title: 'First Day at Guwahati University',
          category: 'childhood',
          narration: 'Walking along the banks of the river with old books, feeling so proud to learn literature. We would share black tea and discuss Assamese poetry under the mango trees.',
          durationSeconds: 85,
          recordedDate: 'Recorded on 4 Feb 2026',
          tags: ['University', 'Youth', 'Guwahati'],
        ),
      ];
    }

    // Seed Care Alerts
    if (alerts.isEmpty) {
      alerts = [
        CareAlert(
          id: 'alert-seed-1',
          title: 'Hydration Goal Alert',
          message: 'Kamala has recorded 4 of 6 target water glasses today. A gentle prompt has been scheduled.',
          severity: AlertSeverity.gentle,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        CareAlert(
          id: 'alert-seed-2',
          title: 'Routine Check-in',
          message: 'Morning blood pressure medication marked as completed on schedule at 08:12 AM.',
          severity: AlertSeverity.gentle,
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          isResolved: true,
        ),
      ];
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
      'hydration': hydrationGlassesTaken,
    });
    notifyListeners();
    _writes = _writes.then((_) async {
      try {
        if (!await prefs.setString('xopun.v1', payload)) {
          throw StateError('Storage full');
        }
        storageError = null;
      } catch (_) {
        storageError = 'Changes could not be saved. Device storage may be full.';
      }
      notifyListeners();
    });
    return _writes;
  }

  void switchRole(UserRole role) {
    currentRole = role;
    notifyListeners();
  }

  void completeTask(String taskId) {
    final idx = careTasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      closedLoopEngine.complete(careTasks[idx]);
      syncEngine.enqueue('complete_task', {'taskId': taskId, 'time': DateTime.now().toIso8601String()});
      save();
    }
  }

  void missTask(String taskId) {
    final idx = careTasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      closedLoopEngine.miss(careTasks[idx]);
      syncEngine.enqueue('miss_task', {'taskId': taskId, 'time': DateTime.now().toIso8601String()});
      save();
    }
  }

  void logHydration() {
    hydrationGlassesTaken = min(targetHydration + 2, hydrationGlassesTaken + 1);
    syncEngine.enqueue('log_hydration', {'count': hydrationGlassesTaken});
    save();
    notifyListeners();
  }

  void addMemory(MemoryItem item) {
    memories.insert(0, item.toJson());
    syncEngine.enqueue('add_memory', item.toJson());
    save();
  }

  void deleteMemory(String id) {
    memories.removeWhere((m) => m['id'] == id);
    syncEngine.enqueue('delete_memory', {'id': id});
    save();
  }

  void addStory(Story story) {
    stories.insert(0, story);
    syncEngine.enqueue('add_story', story.toJson());
    save();
  }

  void resolveAlert(String alertId) {
    final idx = alerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      alerts[idx].isResolved = true;
      notifyListeners();
    }
  }

  void completeFamilyActivity(String id) {
    final idx = familyActivities.indexWhere((a) => a.id == id);
    if (idx != -1) {
      familyActivities[idx].status = FamilyActivityStatus.completed;
      familyActivities[idx].completedAt = DateTime.now();
      notifyListeners();
    }
  }

  // SIH DEMO ACTIONS
  void simulateMedicationMissed() {
    final morningMed = careTasks.firstWhere(
      (t) => t.category == TaskCategory.medication,
      orElse: () => careTasks.first,
    );
    morningMed.missedCount++;
    closedLoopEngine.escalate(
      morningMed,
      reason: 'Repeated missed medication: ${morningMed.title} (Simulated in SIH Demo)',
    );
    notifyListeners();
  }

  void simulateCaregiverAlert() {
    final alert = CareAlert(
      id: 'alert-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Caregiver Attention Needed',
      message: 'Kamala Devi requires assistance with afternoon routine. (SIH Demo Simulation)',
      severity: AlertSeverity.high,
      timestamp: DateTime.now(),
    );
    alerts.insert(0, alert);
    notifyListeners();
  }

  void simulateSafetyEvent() {
    safetyEngine.triggerSafetyAnomaly(details: 'Simulated sudden tilt and 15-minute inactivity event.');
  }

  void simulateSafeZoneExit() {
    locationEngine.simulateSafeZoneExit();
  }

  void simulateOfflineMode() {
    syncEngine.setOfflineMode(true);
  }

  void restoreInternet() {
    syncEngine.setOfflineMode(false);
  }

  void simulateDoctorAppointment() {
    appointments.insert(
      0,
      Appointment(
        id: 'apt-sim-${DateTime.now().millisecondsSinceEpoch}',
        doctorName: 'Dr. R. Sharma',
        specialty: 'Geriatric Neurologist',
        dateTime: DateTime.now().add(const Duration(minutes: 5)),
        status: AppointmentStatus.upcoming,
        location: 'Telehealth Live Video Consultation',
        isTelehealth: true,
        notes: 'Priority clinical review for cognitive & medication adherence.',
      ),
    );
    notifyListeners();
  }

  void simulateFamilyInteraction() {
    familyActivities.insert(
      0,
      FamilyActivity(
        id: 'fa-sim-${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Family Photo Shared',
        senderName: 'Ananya',
        type: 'photo_id',
        prompt: 'Look at this photo from last Bihu festival! Can you recognize your favorite yellow saree?',
        status: FamilyActivityStatus.sent,
        sentAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void resetDemoData() {
    careTasks.clear();
    medications.clear();
    appointments.clear();
    stories.clear();
    familyMembers.clear();
    familyActivities.clear();
    alerts.clear();
    hydrationGlassesTaken = 4;
    _seedDefaultDataIfEmpty();
    notifyListeners();
  }

  // Legacy & test compatibility methods
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
