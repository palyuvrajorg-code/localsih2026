/// User roles supported in SMRITI prototype
enum UserRole { elder, caregiver, doctor }

class AppUser {
  final String id;
  final String name;
  final UserRole role;
  final String avatarUrl;
  final String? phone;
  final String? relation;
  final String? specialization;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl = '',
    this.phone,
    this.relation,
    this.specialization,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'avatarUrl': avatarUrl,
        'phone': phone,
        'relation': relation,
        'specialization': specialization,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => UserRole.elder,
        ),
        avatarUrl: json['avatarUrl'] as String? ?? '',
        phone: json['phone'] as String?,
        relation: json['relation'] as String?,
        specialization: json['specialization'] as String?,
      );
}

class ElderProfile {
  final String id;
  final String name;
  final int age;
  final String primaryLanguage;
  final String caregiverName;
  final String doctorName;
  final String emergencyPhone;
  final String address;

  const ElderProfile({
    required this.id,
    required this.name,
    required this.age,
    this.primaryLanguage = 'as',
    required this.caregiverName,
    required this.doctorName,
    required this.emergencyPhone,
    this.address = 'Guwahati, Assam',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'primaryLanguage': primaryLanguage,
        'caregiverName': caregiverName,
        'doctorName': doctorName,
        'emergencyPhone': emergencyPhone,
        'address': address,
      };

  factory ElderProfile.fromJson(Map<String, dynamic> json) => ElderProfile(
        id: json['id'] as String? ?? 'elder-1',
        name: json['name'] as String? ?? 'Kamala Devi',
        age: (json['age'] as num?)?.toInt() ?? 76,
        primaryLanguage: json['primaryLanguage'] as String? ?? 'as',
        caregiverName: json['caregiverName'] as String? ?? 'Ananya',
        doctorName: json['doctorName'] as String? ?? 'Dr. R. Sharma',
        emergencyPhone: json['emergencyPhone'] as String? ?? '+91 98765 43210',
        address: json['address'] as String? ?? 'Guwahati, Assam',
      );
}

/// Closed-loop care task status
enum TaskStatus {
  scheduled,
  reminded,
  acknowledged,
  completed,
  missed,
  escalated,
}

enum TaskCategory {
  medication,
  hydration,
  meal,
  cognitive,
  family,
  appointment,
  custom,
}

class CareTask {
  final String id;
  final String title;
  final String time; // HH:mm
  final TaskCategory category;
  TaskStatus status;
  final String? instructions;
  final String? dosage;
  final DateTime scheduledDate;
  DateTime? completedAt;
  int missedCount;

  CareTask({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    this.status = TaskStatus.scheduled,
    this.instructions,
    this.dosage,
    required this.scheduledDate,
    this.completedAt,
    this.missedCount = 0,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isMissed => status == TaskStatus.missed || status == TaskStatus.escalated;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'time': time,
        'category': category.name,
        'status': status.name,
        'instructions': instructions,
        'dosage': dosage,
        'scheduledDate': scheduledDate.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'missedCount': missedCount,
      };

  factory CareTask.fromJson(Map<String, dynamic> json) => CareTask(
        id: json['id'] as String,
        title: json['title'] as String,
        time: json['time'] as String,
        category: TaskCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => TaskCategory.custom,
        ),
        status: TaskStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => TaskStatus.scheduled,
        ),
        instructions: json['instructions'] as String?,
        dosage: json['dosage'] as String?,
        scheduledDate: DateTime.tryParse(json['scheduledDate'] as String? ?? '') ?? DateTime.now(),
        completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null,
        missedCount: (json['missedCount'] as num?)?.toInt() ?? 0,
      );

  CareTask copyWith({
    String? id,
    String? title,
    String? time,
    TaskCategory? category,
    TaskStatus? status,
    String? instructions,
    String? dosage,
    DateTime? scheduledDate,
    DateTime? completedAt,
    int? missedCount,
  }) {
    return CareTask(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      category: category ?? this.category,
      status: status ?? this.status,
      instructions: instructions ?? this.instructions,
      dosage: dosage ?? this.dosage,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
      missedCount: missedCount ?? this.missedCount,
    );
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final List<String> scheduleTimes; // ["08:00", "20:00"]
  final String purpose;
  final String colorHex;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.scheduleTimes,
    required this.purpose,
    this.colorHex = '#315C49',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'instructions': instructions,
        'scheduleTimes': scheduleTimes,
        'purpose': purpose,
        'colorHex': colorHex,
      };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        name: json['name'] as String,
        dosage: json['dosage'] as String,
        instructions: json['instructions'] as String? ?? '',
        scheduleTimes: List<String>.from(json['scheduleTimes'] as List? ?? []),
        purpose: json['purpose'] as String? ?? '',
        colorHex: json['colorHex'] as String? ?? '#315C49',
      );
}

enum AppointmentStatus { upcoming, completed, missed, rescheduled }

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String location;
  final bool isTelehealth;
  final String notes;

  const Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.status = AppointmentStatus.upcoming,
    this.location = 'Guwahati Medical Center',
    this.isTelehealth = true,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorName': doctorName,
        'specialty': specialty,
        'dateTime': dateTime.toIso8601String(),
        'status': status.name,
        'location': location,
        'isTelehealth': isTelehealth,
        'notes': notes,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        doctorName: json['doctorName'] as String,
        specialty: json['specialty'] as String,
        dateTime: DateTime.tryParse(json['dateTime'] as String? ?? '') ?? DateTime.now(),
        status: AppointmentStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => AppointmentStatus.upcoming,
        ),
        location: json['location'] as String? ?? 'Guwahati Medical Center',
        isTelehealth: json['isTelehealth'] as bool? ?? true,
        notes: json['notes'] as String? ?? '',
      );
}

class GameResult {
  final String gameId;
  final String gameName;
  final DateTime timestamp;
  final int level;
  final double accuracy;
  final int responseTime; // milliseconds
  final int attempts;
  final int assistanceNeeded; // hints used
  final bool completed;
  final String difficulty;

  const GameResult({
    required this.gameId,
    required this.gameName,
    required this.timestamp,
    required this.level,
    required this.accuracy,
    required this.responseTime,
    required this.attempts,
    required this.assistanceNeeded,
    required this.completed,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'gameName': gameName,
        'timestamp': timestamp.toIso8601String(),
        'level': level,
        'accuracy': accuracy,
        'responseTime': responseTime,
        'attempts': attempts,
        'assistanceNeeded': assistanceNeeded,
        'completed': completed,
        'difficulty': difficulty,
      };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
        gameId: json['gameId'] as String,
        gameName: json['gameName'] as String,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        level: (json['level'] as num?)?.toInt() ?? 0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
        responseTime: (json['responseTime'] as num?)?.toInt() ?? 0,
        attempts: (json['attempts'] as num?)?.toInt() ?? 1,
        assistanceNeeded: (json['assistanceNeeded'] as num?)?.toInt() ?? 0,
        completed: json['completed'] as bool? ?? true,
        difficulty: json['difficulty'] as String? ?? 'Gentle',
      );
}

class MemoryItem {
  final String id;
  final String title;
  final String year;
  final String person;
  final String place;
  final String occasion;
  final String description;
  final String? imageBase64;
  final String? imageAsset;
  final List<String> tags;
  final String? voiceNote;

  const MemoryItem({
    required this.id,
    required this.title,
    required this.year,
    required this.person,
    required this.place,
    required this.occasion,
    required this.description,
    this.imageBase64,
    this.imageAsset,
    this.tags = const [],
    this.voiceNote,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'year': year,
        'person': person,
        'place': place,
        'occasion': occasion,
        'description': description,
        'imageBase64': imageBase64,
        'imageAsset': imageAsset,
        'tags': tags,
        'voiceNote': voiceNote,
      };

  factory MemoryItem.fromJson(Map<String, dynamic> json) => MemoryItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        year: json['year'] as String? ?? '',
        person: json['person'] as String? ?? '',
        place: json['place'] as String? ?? '',
        occasion: json['occasion'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imageBase64: json['imageBase64'] as String?,
        imageAsset: json['imageAsset'] as String?,
        tags: List<String>.from(json['tags'] as List? ?? []),
        voiceNote: json['voiceNote'] as String?,
      );
}

class Story {
  final String id;
  final String title;
  final String category; // childhood, family, village, festivals, recipes, traditions
  final String narration;
  final int durationSeconds;
  final String recordedDate;
  final List<String> tags;
  final String? audioPath;

  const Story({
    required this.id,
    required this.title,
    required this.category,
    required this.narration,
    required this.durationSeconds,
    required this.recordedDate,
    this.tags = const [],
    this.audioPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'narration': narration,
        'durationSeconds': durationSeconds,
        'recordedDate': recordedDate,
        'tags': tags,
        'audioPath': audioPath,
      };

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        narration: json['narration'] as String,
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 60,
        recordedDate: json['recordedDate'] as String,
        tags: List<String>.from(json['tags'] as List? ?? []),
        audioPath: json['audioPath'] as String?,
      );
}

class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final String photoAsset;
  final String phoneNumber;
  final String note;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.photoAsset,
    required this.phoneNumber,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relationship': relationship,
        'photoAsset': photoAsset,
        'phoneNumber': phoneNumber,
        'note': note,
      };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        id: json['id'] as String,
        name: json['name'] as String,
        relationship: json['relationship'] as String,
        photoAsset: json['photoAsset'] as String? ?? 'assets/images/courtyard.jpg',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        note: json['note'] as String? ?? '',
      );
}

enum FamilyActivityStatus { sent, opened, completed }

class FamilyActivity {
  final String id;
  final String title;
  final String senderName;
  final String type; // quiz, photo_id, recipe, story_sharing
  final String prompt;
  FamilyActivityStatus status;
  final DateTime sentAt;
  DateTime? completedAt;

  FamilyActivity({
    required this.id,
    required this.title,
    required this.senderName,
    required this.type,
    required this.prompt,
    this.status = FamilyActivityStatus.sent,
    required this.sentAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'senderName': senderName,
        'type': type,
        'prompt': prompt,
        'status': status.name,
        'sentAt': sentAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory FamilyActivity.fromJson(Map<String, dynamic> json) => FamilyActivity(
        id: json['id'] as String,
        title: json['title'] as String,
        senderName: json['senderName'] as String,
        type: json['type'] as String,
        prompt: json['prompt'] as String,
        status: FamilyActivityStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => FamilyActivityStatus.sent,
        ),
        sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
        completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null,
      );
}

class SafetyEvent {
  final String id;
  final String type; // anomaly, missed_action, inactivity
  final DateTime timestamp;
  final String description;
  final bool isResolved;
  final String resolutionNotes;

  const SafetyEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.description,
    this.isResolved = false,
    this.resolutionNotes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'description': description,
        'isResolved': isResolved,
        'resolutionNotes': resolutionNotes,
      };

  factory SafetyEvent.fromJson(Map<String, dynamic> json) => SafetyEvent(
        id: json['id'] as String,
        type: json['type'] as String,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        description: json['description'] as String,
        isResolved: json['isResolved'] as bool? ?? false,
        resolutionNotes: json['resolutionNotes'] as String? ?? '',
      );
}

class LocationEvent {
  final String id;
  final double latitude;
  final double longitude;
  final String locationName;
  final bool isInsideSafeZone;
  final DateTime timestamp;
  final String details;

  const LocationEvent({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.isInsideSafeZone,
    required this.timestamp,
    this.details = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'isInsideSafeZone': isInsideSafeZone,
        'timestamp': timestamp.toIso8601String(),
        'details': details,
      };

  factory LocationEvent.fromJson(Map<String, dynamic> json) => LocationEvent(
        id: json['id'] as String,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 26.1445,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 91.7362,
        locationName: json['locationName'] as String? ?? 'Home, Ulubari, Guwahati',
        isInsideSafeZone: json['isInsideSafeZone'] as bool? ?? true,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        details: json['details'] as String? ?? '',
      );
}

enum AlertSeverity { gentle, medium, high, emergency }

class CareAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  bool isResolved;

  CareAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isResolved = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'severity': severity.name,
        'timestamp': timestamp.toIso8601String(),
        'isResolved': isResolved,
      };

  factory CareAlert.fromJson(Map<String, dynamic> json) => CareAlert(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        severity: AlertSeverity.values.firstWhere(
          (s) => s.name == json['severity'],
          orElse: () => AlertSeverity.medium,
        ),
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        isResolved: json['isResolved'] as bool? ?? false,
      );
}

class CarePlan {
  final String elderId;
  final String summary;
  final int targetHydrationGlasses;
  final int targetCognitiveSessions;
  final List<Medication> medications;

  const CarePlan({
    required this.elderId,
    required this.summary,
    this.targetHydrationGlasses = 6,
    this.targetCognitiveSessions = 2,
    this.medications = const [],
  });
}

class CareReport {
  final String id;
  final DateTime generatedAt;
  final double medicationAdherence;
  final double hydrationAdherence;
  final int gamesPlayed;
  final double cognitiveEngagement;
  final String doctorSummary;

  const CareReport({
    required this.id,
    required this.generatedAt,
    required this.medicationAdherence,
    required this.hydrationAdherence,
    required this.gamesPlayed,
    required this.cognitiveEngagement,
    required this.doctorSummary,
  });
}

class SyncQueueItem {
  final String id;
  final String action;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  bool synced;

  SyncQueueItem({
    required this.id,
    required this.action,
    required this.payload,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        id: json['id'] as String,
        action: json['action'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        synced: json['synced'] as bool? ?? false,
      );
}
