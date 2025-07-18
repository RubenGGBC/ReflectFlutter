// data/models/optimized_models.dart - MODELOS OPTIMIZADOS PARA LA NUEVA BD
// ============================================================================

import 'dart:convert';

// ============================================================================
// USER MODEL OPTIMIZADO
// ============================================================================

// lib/data/models/optimized_models.dart - UPDATED WITH PROFILE PICTURE SUPPORT
// ============================================================================

import 'dart:convert';

// ============================================================================
// USER MODEL OPTIMIZADO CON FOTO DE PERFIL
// ============================================================================

class OptimizedUserModel {
  final int id;
  final String email;
  final String name;
  final String avatarEmoji;
  final String? profilePicturePath; // ✅ NUEVO: Ruta de la imagen de perfil
  final String bio;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  const OptimizedUserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarEmoji,
    this.profilePicturePath, // ✅ NUEVO: Campo opcional para imagen
    required this.bio,
    this.preferences = const {},
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  factory OptimizedUserModel.create({
    required String email,
    required String name,
    String avatarEmoji = '🧘‍♀️',
    String? profilePicturePath, // ✅ NUEVO
    String bio = '',
    Map<String, dynamic> preferences = const {},
  }) {
    return OptimizedUserModel(
      id: 0, // Se asignará por la BD
      email: email.toLowerCase().trim(),
      name: name.trim(),
      avatarEmoji: avatarEmoji,
      profilePicturePath: profilePicturePath, // ✅ NUEVO
      bio: bio,
      preferences: preferences,
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  factory OptimizedUserModel.fromDatabase(Map<String, dynamic> map) {
    return OptimizedUserModel(
      id: map['id'] as int,
      email: map['email'] as String,
      name: map['name'] as String,
      avatarEmoji: map['avatar_emoji'] as String,
      profilePicturePath: map['profile_picture_path'] as String?, // ✅ NUEVO
      bio: map['bio'] as String? ?? '',
      preferences: _parseJsonMap(map['preferences'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
      lastLogin: map['last_login'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['last_login'] as int) * 1000)
          : null,
      isActive: (map['is_active'] as int) == 1,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'email': email,
      'name': name,
      'avatar_emoji': avatarEmoji,
      'profile_picture_path': profilePicturePath, // ✅ NUEVO
      'bio': bio,
      'preferences': jsonEncode(preferences),
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'last_login': lastLogin?.millisecondsSinceEpoch != null
          ? lastLogin!.millisecondsSinceEpoch ~/ 1000
          : null,
      'is_active': isActive ? 1 : 0,
    };
  }

  OptimizedUserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? avatarEmoji,
    String? profilePicturePath, // ✅ NUEVO
    String? bio,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return OptimizedUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath, // ✅ NUEVO
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get hasProfilePicture => profilePicturePath != null && profilePicturePath!.isNotEmpty;

  static Map<String, dynamic> _parseJsonMap(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return {};
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}

// ============================================================================
// DAILY ENTRY MODEL OPTIMIZADO
// ============================================================================

class OptimizedDailyEntryModel {
final int? id;
final int userId;
final DateTime entryDate;
final String freeReflection;
final String? innerReflection;
final List<String> positiveTags;
final List<String> negativeTags;
final List<String> completedActivitiesToday;
final List<String> goalsSummary;
final bool? worthIt;
final String? overallSentiment;
final int? moodScore;
final String? aiSummary;
final int wordCount;

// Analytics expandidos
final int? energyLevel;
final int? stressLevel;
final int? sleepQuality;
final int? anxietyLevel;
final int? motivationLevel;
final int? socialInteraction;
final int? physicalActivity;
final int? workProductivity;
final double? sleepHours;
final int? waterIntake;
final int? meditationMinutes;
final int? exerciseMinutes;
final double? screenTimeHours;
final String? gratitudeItems;
final int? weatherMoodImpact;
final int? socialBattery;
final int? creativeEnergy;
final int? emotionalStability;
final int? focusLevel;
final int? lifeSatisfaction;
final String? voiceRecordingPath;

final DateTime createdAt;
final DateTime updatedAt;

const OptimizedDailyEntryModel({
this.id,
required this.userId,
required this.entryDate,
required this.freeReflection,
this.innerReflection,
this.positiveTags = const [],
this.negativeTags = const [],
this.completedActivitiesToday = const [],
this.goalsSummary = const [],
this.worthIt,
this.overallSentiment,
this.moodScore,
this.aiSummary,
this.wordCount = 0,
this.energyLevel,
this.stressLevel,
this.sleepQuality,
this.anxietyLevel,
this.motivationLevel,
this.socialInteraction,
this.physicalActivity,
this.workProductivity,
this.sleepHours,
this.waterIntake,
this.meditationMinutes,
this.exerciseMinutes,
this.screenTimeHours,
this.gratitudeItems,
this.weatherMoodImpact,
this.socialBattery,
this.creativeEnergy,
this.emotionalStability,
this.focusLevel,
this.lifeSatisfaction,
this.voiceRecordingPath,
required this.createdAt,
required this.updatedAt,
});

factory OptimizedDailyEntryModel.create({
required int userId,
required String freeReflection,
String? innerReflection,
DateTime? entryDate,
List<String> positiveTags = const [],
List<String> negativeTags = const [],
List<String> completedActivitiesToday = const [],
List<String> goalsSummary = const [],
bool? worthIt,
int? moodScore,
int? energyLevel,
int? stressLevel,
int? sleepQuality,
int? anxietyLevel,
int? motivationLevel,
int? socialInteraction,
int? physicalActivity,
int? workProductivity,
double? sleepHours,
int? waterIntake,
int? meditationMinutes,
int? exerciseMinutes,
double? screenTimeHours,
String? gratitudeItems,
int? weatherMoodImpact,
int? socialBattery,
int? creativeEnergy,
int? emotionalStability,
int? focusLevel,
int? lifeSatisfaction,
String? voiceRecordingPath,
}) {
final now = DateTime.now();
final entry = entryDate ?? DateTime(now.year, now.month, now.day);

return OptimizedDailyEntryModel(
userId: userId,
entryDate: entry,
freeReflection: freeReflection.trim(),
innerReflection: innerReflection,
positiveTags: positiveTags,
negativeTags: negativeTags,
completedActivitiesToday: completedActivitiesToday,
goalsSummary: goalsSummary,
worthIt: worthIt,
moodScore: moodScore,
wordCount: freeReflection.trim().split(' ').length,
energyLevel: energyLevel,
stressLevel: stressLevel,
sleepQuality: sleepQuality,
anxietyLevel: anxietyLevel,
motivationLevel: motivationLevel,
socialInteraction: socialInteraction,
physicalActivity: physicalActivity,
workProductivity: workProductivity,
sleepHours: sleepHours,
waterIntake: waterIntake,
meditationMinutes: meditationMinutes,
exerciseMinutes: exerciseMinutes,
screenTimeHours: screenTimeHours,
gratitudeItems: gratitudeItems,
weatherMoodImpact: weatherMoodImpact,
socialBattery: socialBattery,
creativeEnergy: creativeEnergy,
emotionalStability: emotionalStability,
focusLevel: focusLevel,
lifeSatisfaction: lifeSatisfaction,
voiceRecordingPath: voiceRecordingPath,
createdAt: now,
updatedAt: now,
);
}

factory OptimizedDailyEntryModel.fromDatabase(Map<String, dynamic> map) {
return OptimizedDailyEntryModel(
id: map['id'] as int,
userId: map['user_id'] as int,
entryDate: DateTime.parse(map['entry_date'] as String),
freeReflection: map['free_reflection'] as String,
innerReflection: map['inner_reflection'] as String?,
positiveTags: _parseTagsList(map['positive_tags'] as String?),
negativeTags: _parseTagsList(map['negative_tags'] as String?),
completedActivitiesToday: _parseTagsList(map['completed_activities_today'] as String?),
goalsSummary: _parseTagsList(map['goals_summary'] as String?),
worthIt: map['worth_it'] != null ? (map['worth_it'] as int) == 1 : null,
overallSentiment: map['overall_sentiment'] as String?,
moodScore: map['mood_score'] as int?,
aiSummary: map['ai_summary'] as String?,
wordCount: map['word_count'] as int? ?? 0,
energyLevel: map['energy_level'] as int?,
stressLevel: map['stress_level'] as int?,
sleepQuality: map['sleep_quality'] as int?,
anxietyLevel: map['anxiety_level'] as int?,
motivationLevel: map['motivation_level'] as int?,
socialInteraction: map['social_interaction'] as int?,
physicalActivity: map['physical_activity'] as int?,
workProductivity: map['work_productivity'] as int?,
sleepHours: map['sleep_hours'] as double?,
waterIntake: map['water_intake'] as int?,
meditationMinutes: map['meditation_minutes'] as int?,
exerciseMinutes: map['exercise_minutes'] as int?,
screenTimeHours: map['screen_time_hours'] as double?,
gratitudeItems: map['gratitude_items'] as String?,
weatherMoodImpact: map['weather_mood_impact'] as int?,
socialBattery: map['social_battery'] as int?,
creativeEnergy: map['creative_energy'] as int?,
emotionalStability: map['emotional_stability'] as int?,
focusLevel: map['focus_level'] as int?,
lifeSatisfaction: map['life_satisfaction'] as int?,
voiceRecordingPath: map['voice_recording_path'] as String?,
createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int) * 1000),
);
}

Map<String, dynamic> toOptimizedDatabase() {
return {
'user_id': userId,
'entry_date': entryDate.toIso8601String().split('T')[0],
'free_reflection': freeReflection,
'inner_reflection': innerReflection,
'positive_tags': jsonEncode(positiveTags),
'negative_tags': jsonEncode(negativeTags),
'completed_activities_today': jsonEncode(completedActivitiesToday),
'goals_summary': jsonEncode(goalsSummary),
'worth_it': worthIt != null ? (worthIt! ? 1 : 0) : null,
'overall_sentiment': overallSentiment,
'mood_score': moodScore,
'ai_summary': aiSummary,
'word_count': wordCount,
'energy_level': energyLevel,
'stress_level': stressLevel,
'sleep_quality': sleepQuality,
'anxiety_level': anxietyLevel,
'motivation_level': motivationLevel,
'social_interaction': socialInteraction,
'physical_activity': physicalActivity,
'work_productivity': workProductivity,
'sleep_hours': sleepHours,
'water_intake': waterIntake,
'meditation_minutes': meditationMinutes,
'exercise_minutes': exerciseMinutes,
'screen_time_hours': screenTimeHours,
'gratitude_items': gratitudeItems,
'weather_mood_impact': weatherMoodImpact,
'social_battery': socialBattery,
'creative_energy': creativeEnergy,
'emotional_stability': emotionalStability,
'focus_level': focusLevel,
'life_satisfaction': lifeSatisfaction,
'voice_recording_path': voiceRecordingPath,
'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
};
}

// *** FIX: Added the missing copyWith method ***
OptimizedDailyEntryModel copyWith({
int? id,
int? userId,
DateTime? entryDate,
String? freeReflection,
String? innerReflection,
List<String>? positiveTags,
List<String>? negativeTags,
List<String>? completedActivitiesToday,
List<String>? goalsSummary,
bool? worthIt,
String? overallSentiment,
int? moodScore,
String? aiSummary,
int? wordCount,
int? energyLevel,
int? stressLevel,
int? sleepQuality,
int? anxietyLevel,
int? motivationLevel,
int? socialInteraction,
int? physicalActivity,
int? workProductivity,
double? sleepHours,
int? waterIntake,
int? meditationMinutes,
int? exerciseMinutes,
double? screenTimeHours,
String? gratitudeItems,
int? weatherMoodImpact,
int? socialBattery,
int? creativeEnergy,
int? emotionalStability,
int? focusLevel,
int? lifeSatisfaction,
String? voiceRecordingPath,
DateTime? createdAt,
DateTime? updatedAt,
}) {
return OptimizedDailyEntryModel(
id: id ?? this.id,
userId: userId ?? this.userId,
entryDate: entryDate ?? this.entryDate,
freeReflection: freeReflection ?? this.freeReflection,
innerReflection: innerReflection ?? this.innerReflection,
positiveTags: positiveTags ?? this.positiveTags,
negativeTags: negativeTags ?? this.negativeTags,
completedActivitiesToday: completedActivitiesToday ?? this.completedActivitiesToday,
goalsSummary: goalsSummary ?? this.goalsSummary,
worthIt: worthIt ?? this.worthIt,
overallSentiment: overallSentiment ?? this.overallSentiment,
moodScore: moodScore ?? this.moodScore,
aiSummary: aiSummary ?? this.aiSummary,
wordCount: wordCount ?? this.wordCount,
energyLevel: energyLevel ?? this.energyLevel,
stressLevel: stressLevel ?? this.stressLevel,
sleepQuality: sleepQuality ?? this.sleepQuality,
anxietyLevel: anxietyLevel ?? this.anxietyLevel,
motivationLevel: motivationLevel ?? this.motivationLevel,
socialInteraction: socialInteraction ?? this.socialInteraction,
physicalActivity: physicalActivity ?? this.physicalActivity,
workProductivity: workProductivity ?? this.workProductivity,
sleepHours: sleepHours ?? this.sleepHours,
waterIntake: waterIntake ?? this.waterIntake,
meditationMinutes: meditationMinutes ?? this.meditationMinutes,
exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
screenTimeHours: screenTimeHours ?? this.screenTimeHours,
gratitudeItems: gratitudeItems ?? this.gratitudeItems,
weatherMoodImpact: weatherMoodImpact ?? this.weatherMoodImpact,
socialBattery: socialBattery ?? this.socialBattery,
creativeEnergy: creativeEnergy ?? this.creativeEnergy,
emotionalStability: emotionalStability ?? this.emotionalStability,
focusLevel: focusLevel ?? this.focusLevel,
lifeSatisfaction: lifeSatisfaction ?? this.lifeSatisfaction,
voiceRecordingPath: voiceRecordingPath ?? this.voiceRecordingPath,
createdAt: createdAt ?? this.createdAt,
updatedAt: updatedAt ?? this.updatedAt,
);
}


double get wellbeingScore {
final metrics = [
moodScore,
energyLevel,
(10 - (stressLevel ?? 5)), // Invertir stress
sleepQuality,
motivationLevel,
socialInteraction,
emotionalStability,
focusLevel,
lifeSatisfaction,
].where((m) => m != null).map((m) => m!.toDouble());

if (metrics.isEmpty) return 5.0;
return metrics.reduce((a, b) => a + b) / metrics.length;
}

String get wellbeingLevel {
final score = wellbeingScore;
if (score >= 8.5) return 'Excelente';
if (score >= 7.0) return 'Muy Bueno';
if (score >= 5.5) return 'Bueno';
if (score >= 4.0) return 'Regular';
return 'Necesita Atención';
}

static List<String> _parseTagsList(String? jsonString) {
if (jsonString == null || jsonString.isEmpty) return [];
try {
final parsed = jsonDecode(jsonString);
if (parsed is List) {
return parsed.map((e) => e.toString()).toList();
}
return [];
} catch (e) {
return [];
}
}
}

// ============================================================================
// INTERACTIVE MOMENT MODEL OPTIMIZADO
// ============================================================================

class OptimizedInteractiveMomentModel {
final int? id;
final int userId;
final DateTime entryDate;
final String emoji;
final String text;
final String type; // positive, negative, neutral
final int intensity; // 1-10
final String category;

// Contexto enriquecido
final String? contextLocation;
final String? contextWeather;
final String? contextSocial;
final int? energyBefore;
final int? energyAfter;
final int? moodBefore;
final int? moodAfter;

final DateTime timestamp;
final DateTime createdAt;

const OptimizedInteractiveMomentModel({
this.id,
required this.userId,
required this.entryDate,
required this.emoji,
required this.text,
required this.type,
this.intensity = 5,
this.category = 'general',
this.contextLocation,
this.contextWeather,
this.contextSocial,
this.energyBefore,
this.energyAfter,
this.moodBefore,
this.moodAfter,
required this.timestamp,
required this.createdAt,
});

factory OptimizedInteractiveMomentModel.create({
required int userId,
required String emoji,
required String text,
required String type,
int intensity = 5,
String category = 'general',
String? contextLocation,
String? contextWeather,
String? contextSocial,
int? energyBefore,
int? energyAfter,
int? moodBefore,
int? moodAfter,
DateTime? timestamp,
}) {
final now = DateTime.now();
final momentTime = timestamp ?? now;

return OptimizedInteractiveMomentModel(
userId: userId,
entryDate: DateTime(now.year, now.month, now.day),
emoji: emoji,
text: text.trim(),
type: type,
intensity: intensity.clamp(1, 10),
category: category,
contextLocation: contextLocation,
contextWeather: contextWeather,
contextSocial: contextSocial,
energyBefore: energyBefore,
energyAfter: energyAfter,
moodBefore: moodBefore,
moodAfter: moodAfter,
timestamp: momentTime,
createdAt: now,
);
}

factory OptimizedInteractiveMomentModel.fromDatabase(Map<String, dynamic> map) {
return OptimizedInteractiveMomentModel(
id: map['id'] as int,
userId: map['user_id'] as int,
entryDate: DateTime.parse(map['entry_date'] as String),
emoji: map['emoji'] as String,
text: map['text'] as String,
type: map['type'] as String,
intensity: map['intensity'] as int? ?? 5,
category: map['category'] as String? ?? 'general',
contextLocation: map['context_location'] as String?,
contextWeather: map['context_weather'] as String?,
contextSocial: map['context_social'] as String?,
energyBefore: map['energy_before'] as int?,
energyAfter: map['energy_after'] as int?,
moodBefore: map['mood_before'] as int?,
moodAfter: map['mood_after'] as int?,
timestamp: DateTime.fromMillisecondsSinceEpoch((map['timestamp'] as int) * 1000),
createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
);
}

Map<String, dynamic> toOptimizedDatabase() {
return {
'user_id': userId,
'entry_date': entryDate.toIso8601String().split('T')[0],
'emoji': emoji,
'text': text,
'type': type,
'intensity': intensity,
'category': category,
'context_location': contextLocation,
'context_weather': contextWeather,
'context_social': contextSocial,
'energy_before': energyBefore,
'energy_after': energyAfter,
'mood_before': moodBefore,
'mood_after': moodAfter,
'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
};
}

String get timeOfDay {
final hour = timestamp.hour;
if (hour >= 5 && hour < 12) return 'Mañana';
if (hour >= 12 && hour < 17) return 'Tarde';
if (hour >= 17 && hour < 21) return 'Atardecer';
return 'Noche';
}

String get timeStr => '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

String get intensityDescription {
if (intensity >= 9) return 'Muy intenso';
if (intensity >= 7) return 'Intenso';
if (intensity >= 5) return 'Moderado';
if (intensity >= 3) return 'Leve';
return 'Muy leve';
}

String get colorHex {
if (type == 'positive') {
if (intensity >= 8) return '#10B981'; // Verde intenso
if (intensity >= 6) return '#34D399'; // Verde medio
return '#6EE7B7'; // Verde suave
} else if (type == 'negative') {
if (intensity >= 8) return '#EF4444'; // Rojo intenso
if (intensity >= 6) return '#F87171'; // Rojo medio
return '#FCA5A5'; // Rojo suave
} else {
return '#9CA3AF'; // Gris neutro
}
}

bool get hasContext => contextLocation != null || contextWeather != null || contextSocial != null;

bool get hasEnergyData => energyBefore != null && energyAfter != null;

bool get hasMoodData => moodBefore != null && moodAfter != null;

int? get energyChange => hasEnergyData ? energyAfter! - energyBefore! : null;

int? get moodChange => hasMoodData ? moodAfter! - moodBefore! : null;

OptimizedInteractiveMomentModel copyWith({
int? id,
int? userId,
DateTime? entryDate,
String? emoji,
String? text,
String? type,
int? intensity,
String? category,
String? contextLocation,
String? contextWeather,
String? contextSocial,
int? energyBefore,
int? energyAfter,
int? moodBefore,
int? moodAfter,
DateTime? timestamp,
DateTime? createdAt,
}) {
return OptimizedInteractiveMomentModel(
id: id ?? this.id,
userId: userId ?? this.userId,
entryDate: entryDate ?? this.entryDate,
emoji: emoji ?? this.emoji,
text: text ?? this.text,
type: type ?? this.type,
intensity: intensity ?? this.intensity,
category: category ?? this.category,
contextLocation: contextLocation ?? this.contextLocation,
contextWeather: contextWeather ?? this.contextWeather,
contextSocial: contextSocial ?? this.contextSocial,
energyBefore: energyBefore ?? this.energyBefore,
energyAfter: energyAfter ?? this.energyAfter,
moodBefore: moodBefore ?? this.moodBefore,
moodAfter: moodAfter ?? this.moodAfter,
timestamp: timestamp ?? this.timestamp,
createdAt: createdAt ?? this.createdAt,
);
}

// Métodos de análisis estático
static Map<String, List<OptimizedInteractiveMomentModel>> groupByCategory(
List<OptimizedInteractiveMomentModel> moments) {
final Map<String, List<OptimizedInteractiveMomentModel>> grouped = {};
for (final moment in moments) {
grouped.putIfAbsent(moment.category, () => []).add(moment);
}
return grouped;
}

static Map<String, List<OptimizedInteractiveMomentModel>> groupByType(
List<OptimizedInteractiveMomentModel> moments) {
final Map<String, List<OptimizedInteractiveMomentModel>> grouped = {};
for (final moment in moments) {
grouped.putIfAbsent(moment.type, () => []).add(moment);
}
return grouped;
}

static Map<String, List<OptimizedInteractiveMomentModel>> groupByTimeOfDay(
List<OptimizedInteractiveMomentModel> moments) {
final Map<String, List<OptimizedInteractiveMomentModel>> grouped = {};
for (final moment in moments) {
grouped.putIfAbsent(moment.timeOfDay, () => []).add(moment);
}
return grouped;
}

static double calculateAverageIntensity(List<OptimizedInteractiveMomentModel> moments) {
if (moments.isEmpty) return 0.0;
return moments.fold<int>(0, (sum, m) => sum + m.intensity) / moments.length;
}

static OptimizedInteractiveMomentModel? getMostIntense(
List<OptimizedInteractiveMomentModel> moments) {
if (moments.isEmpty) return null;
return moments.reduce((current, next) =>
current.intensity > next.intensity ? current : next);
}

static List<OptimizedInteractiveMomentModel> filterByIntensity(
List<OptimizedInteractiveMomentModel> moments,
int minIntensity,
[int? maxIntensity]) {
return moments.where((m) =>
m.intensity >= minIntensity &&
(maxIntensity == null || m.intensity <= maxIntensity)
).toList();
}
}

// ============================================================================
// TAG MODEL OPTIMIZADO
// ============================================================================

class OptimizedTagModel {
final int? id;
final int userId;
final String name;
final String type; // positive, negative, neutral
final String category;
final String emoji;
final int usageCount;
final DateTime lastUsed;
final DateTime createdAt;

const OptimizedTagModel({
this.id,
required this.userId,
required this.name,
required this.type,
this.category = 'general',
this.emoji = '🏷️',
this.usageCount = 1,
required this.lastUsed,
required this.createdAt,
});

factory OptimizedTagModel.create({
required int userId,
required String name,
required String type,
String category = 'general',
String emoji = '🏷️',
}) {
final now = DateTime.now();
return OptimizedTagModel(
userId: userId,
name: name.trim().toLowerCase(),
type: type,
category: category,
emoji: emoji,
usageCount: 1,
lastUsed: now,
createdAt: now,
);
}

factory OptimizedTagModel.fromDatabase(Map<String, dynamic> map) {
return OptimizedTagModel(
id: map['id'] as int,
userId: map['user_id'] as int,
name: map['name'] as String,
type: map['type'] as String,
category: map['category'] as String? ?? 'general',
emoji: map['emoji'] as String? ?? '🏷️',
usageCount: map['usage_count'] as int? ?? 1,
lastUsed: DateTime.fromMillisecondsSinceEpoch((map['last_used'] as int) * 1000),
createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
);
}

Map<String, dynamic> toDatabase() {
return {
'user_id': userId,
'name': name,
'type': type,
'category': category,
'emoji': emoji,
'usage_count': usageCount,
'last_used': lastUsed.millisecondsSinceEpoch ~/ 1000,
'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
};
}

OptimizedTagModel copyWith({
int? id,
int? userId,
String? name,
String? type,
String? category,
String? emoji,
int? usageCount,
DateTime? lastUsed,
DateTime? createdAt,
}) {
return OptimizedTagModel(
id: id ?? this.id,
userId: userId ?? this.userId,
name: name ?? this.name,
type: type ?? this.type,
category: category ?? this.category,
emoji: emoji ?? this.emoji,
usageCount: usageCount ?? this.usageCount,
lastUsed: lastUsed ?? this.lastUsed,
createdAt: createdAt ?? this.createdAt,
);
}

OptimizedTagModel incrementUsage() {
return copyWith(
usageCount: usageCount + 1,
lastUsed: DateTime.now(),
);
}

bool get isRecent => DateTime.now().difference(lastUsed).inDays <= 7;

bool get isFrequent => usageCount >= 5;

String get displayName => name[0].toUpperCase() + name.substring(1);
}

// ============================================================================
// EXTENSIONES Y UTILIDADES
// ============================================================================

extension OptimizedModelExtensions on List<OptimizedDailyEntryModel> {
double get averageWellbeingScore {
if (isEmpty) return 0.0;
return map((e) => e.wellbeingScore).reduce((a, b) => a + b) / length;
}

List<OptimizedDailyEntryModel> get recentEntries {
final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
return where((entry) => entry.entryDate.isAfter(thirtyDaysAgo)).toList();
}

Map<String, int> get wellbeingLevelDistribution {
final distribution = <String, int>{};
for (final entry in this) {
distribution[entry.wellbeingLevel] = (distribution[entry.wellbeingLevel] ?? 0) + 1;
}
return distribution;
}
}

extension OptimizedMomentExtensions on List<OptimizedInteractiveMomentModel> {
List<OptimizedInteractiveMomentModel> get positivesMoments =>
where((m) => m.type == 'positive').toList();

List<OptimizedInteractiveMomentModel> get negativeMoments =>
where((m) => m.type == 'negative').toList();

Map<String, double> get averageIntensityByCategory {
final grouped = OptimizedInteractiveMomentModel.groupByCategory(this);
return grouped.map((category, moments) => MapEntry(
category,
OptimizedInteractiveMomentModel.calculateAverageIntensity(moments)
));
}

List<OptimizedInteractiveMomentModel> get todayMoments {
final today = DateTime.now();
final todayDate = DateTime(today.year, today.month, today.day);
return where((m) {
  final momentDate = DateTime(m.entryDate.year, m.entryDate.month, m.entryDate.day);
  return momentDate.isAtSameMomentAs(todayDate);
}).toList();
}
}
