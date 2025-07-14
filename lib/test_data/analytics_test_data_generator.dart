// ============================================================================
// test_data/analytics_test_data_generator.dart
// GENERADOR DE DATOS DE PRUEBA PARA ANÁLISIS AVANZADOS
// ============================================================================

import 'dart:math';
import '../data/models/daily_entry_model.dart';
import '../data/models/interactive_moment_model.dart';
import '../data/models/goal_model.dart';
import '../data/models/tag_model.dart';
import '../data/models/optimized_models.dart';

// ============================================================================
// CONFIGURACIÓN DE PERFILES DE USUARIO
// ============================================================================

enum UserProfile {
  stable,      // Usuario estable con rutinas consistentes
  anxious,     // Usuario con patrones de ansiedad
  depressed,   // Usuario con tendencias depresivas
  improving,   // Usuario en proceso de mejora
  chaotic,     // Usuario con patrones inconsistentes
}

class AnalyticsTestDataGenerator {
  static final Random _random = Random();
  
  // ============================================================================
  // MÉTODO PRINCIPAL: GENERAR DATASET COMPLETO
  // ============================================================================
  
  static Future<Map<String, dynamic>> generateCompleteTestData({
    int userId = 1,
    UserProfile profile = UserProfile.stable,
    int daysOfData = 45,
    int momentsPerDay = 3,
    int numberOfGoals = 5,
  }) async {
    
    print('🎯 Generando datos de prueba para perfil: $profile');
    print('📅 Días de datos: $daysOfData');
    print('💭 Momentos por día: $momentsPerDay');
    print('🎯 Número de metas: $numberOfGoals');
    
    final dailyEntries = await generateDailyEntries(
      userId: userId,
      profile: profile,
      days: daysOfData,
    );
    
    final interactiveMoments = await generateInteractiveMoments(
      userId: userId,
      profile: profile,
      days: daysOfData,
      momentsPerDay: momentsPerDay,
    );
    
    final goals = await generateGoals(
      userId: userId,
      profile: profile,
      numberOfGoals: numberOfGoals,
    );
    
    final tags = await generateTags(userId: userId);
    
    return {
      'dailyEntries': dailyEntries,
      'interactiveMoments': interactiveMoments,
      'goals': goals,
      'tags': tags,
      'profile': profile.toString(),
      'summary': {
        'totalDays': daysOfData,
        'totalMoments': interactiveMoments.length,
        'totalGoals': goals.length,
        'totalTags': tags.length,
        'dateRange': {
          'start': dailyEntries.first.entryDate.toIso8601String(),
          'end': dailyEntries.last.entryDate.toIso8601String(),
        }
      }
    };
  }
  
  // ============================================================================
  // GENERACIÓN DE ENTRADAS DIARIAS
  // ============================================================================
  
  static Future<List<OptimizedDailyEntryModel>> generateDailyEntries({
    required int userId,
    required UserProfile profile,
    required int days,
  }) async {
    
    final entries = <OptimizedDailyEntryModel>[];
    final baseDate = DateTime.now().subtract(Duration(days: days));
    
    // Configuración base según perfil
    final profileConfig = _getProfileConfig(profile);
    
    for (int i = 0; i < days; i++) {
      final date = baseDate.add(Duration(days: i));
      final dayOfWeek = date.weekday;
      
      // Aplicar variaciones según día de la semana
      final weekdayModifier = _getWeekdayModifier(dayOfWeek, profile);
      
      // Generar tendencia temporal (mejora/empeora con el tiempo)
      final progressModifier = _getProgressModifier(i, days, profile);
      
      // Calcular métricas con variación natural
      final entry = OptimizedDailyEntryModel(
        id: i + 1,
        userId: userId,
        entryDate: date,
        
        // Métricas principales con variación realista
        moodScore: _generateMetric(
          base: profileConfig['moodScore']!,
          weekdayMod: weekdayModifier,
          progressMod: progressModifier,
          variance: 1.5,
        ),
        
        energyLevel: _generateMetric(
          base: profileConfig['energyLevel']!,
          weekdayMod: weekdayModifier,
          progressMod: progressModifier,
          variance: 1.2,
        ),
        
        stressLevel: _generateMetric(
          base: profileConfig['stressLevel']!,
          weekdayMod: -weekdayModifier, // Inverso para estrés
          progressMod: -progressModifier,
          variance: 1.8,
        ),
        
        // Métricas de sueño con patrones realistas
        sleepHours: _generateSleepHours(profile, dayOfWeek),
        sleepQuality: _generateMetric(
          base: profileConfig['sleepQuality']!,
          weekdayMod: weekdayModifier * 0.5,
          progressMod: progressModifier * 0.3,
          variance: 1.0,
        ),
        
        // Métricas de ansiedad según perfil
        anxietyLevel: _generateAnxietyLevel(profile, dayOfWeek, i),
        
        // Métricas de bienestar
        motivationLevel: _generateMetric(
          base: profileConfig['motivationLevel']!,
          weekdayMod: weekdayModifier * 0.8,
          progressMod: progressModifier * 1.2,
          variance: 1.4,
        ),
        
        socialInteraction: _generateSocialInteraction(profile, dayOfWeek),
        physicalActivity: _generatePhysicalActivity(profile, dayOfWeek),
        workProductivity: _generateWorkProductivity(profile, dayOfWeek),
        
        // Métricas numéricas
        waterIntake: _generateWaterIntake(profile),
        meditationMinutes: _generateMeditationMinutes(profile, i),
        exerciseMinutes: _generateExerciseMinutes(profile, dayOfWeek),
        screenTimeHours: _generateScreenTime(profile, dayOfWeek),
        
        // Métricas avanzadas
        emotionalStability: _generateMetric(
          base: profileConfig['emotionalStability']!,
          weekdayMod: weekdayModifier * 0.6,
          progressMod: progressModifier * 0.9,
          variance: 1.3,
        ),
        
        focusLevel: _generateMetric(
          base: profileConfig['focusLevel']!,
          weekdayMod: weekdayModifier * 0.7,
          progressMod: progressModifier * 0.8,
          variance: 1.1,
        ),
        
        lifeSatisfaction: _generateMetric(
          base: profileConfig['lifeSatisfaction']!,
          weekdayMod: weekdayModifier * 0.4,
          progressMod: progressModifier * 1.5,
          variance: 1.0,
        ),
        
        // Textos opcionales
        freeReflection: _generateReflection(profile, i) ?? 'Día de reflexión',
        gratitudeItems: _generateGratitude(profile, i) ?? 'Agradecimiento diario',
        positiveTags: () {
          final positiveTag = _generatePositiveTags(profile);
          return positiveTag != null ? [positiveTag] : <String>[];
        }(),
        negativeTags: () {
          final negativeTag = _generateNegativeTags(profile);
          return negativeTag != null ? [negativeTag] : <String>[];
        }(),
        
        // Métricas binarias
        worthIt: _generateWorthIt(profile, i),
        
        createdAt: date,
        updatedAt: date,
      );
      
      entries.add(entry);
    }
    
    return entries;
  }
  
  // ============================================================================
  // GENERACIÓN DE MOMENTOS INTERACTIVOS
  // ============================================================================
  
  static Future<List<InteractiveMomentModel>> generateInteractiveMoments({
    required int userId,
    required UserProfile profile,
    required int days,
    required int momentsPerDay,
  }) async {
    
    final moments = <InteractiveMomentModel>[];
    final baseDate = DateTime.now().subtract(Duration(days: days));
    
    int momentId = 1;
    
    for (int day = 0; day < days; day++) {
      final date = baseDate.add(Duration(days: day));
      final dayMoments = _random.nextInt(momentsPerDay) + 1;
      
      for (int moment = 0; moment < dayMoments; moment++) {
        final momentTime = _generateMomentTime(date, moment, dayMoments);
        final momentData = _generateMomentData(profile, day, moment);
        
        final momentModel = InteractiveMomentModel(
          id: momentId.toString(),
          emoji: momentData['emoji'],
          text: momentData['description'],
          type: momentData['type'],
          intensity: momentData['intensity'],
          category: momentData['category'],
          timeStr: '${momentTime.hour.toString().padLeft(2, '0')}:${momentTime.minute.toString().padLeft(2, '0')}',
          timestamp: momentTime,
          entryDate: momentTime,
        );
        
        moments.add(momentModel);
        momentId++;
      }
    }
    
    return moments;
  }
  
  // ============================================================================
  // GENERACIÓN DE METAS
  // ============================================================================
  
  static Future<List<GoalModel>> generateGoals({
    required int userId,
    required UserProfile profile,
    required int numberOfGoals,
  }) async {
    
    final goals = <GoalModel>[];
    final goalTemplates = _getGoalTemplates(profile);
    
    for (int i = 0; i < numberOfGoals; i++) {
      final template = goalTemplates[i % goalTemplates.length];
      final createdDate = DateTime.now().subtract(Duration(days: _random.nextInt(30) + 1));
      
      final goal = GoalModel(
        id: i + 1,
        userId: userId,
        title: template['title'] as String? ?? 'Meta por defecto',
        description: template['description'] as String? ?? 'Descripción por defecto',
        type: GoalType.values[_random.nextInt(GoalType.values.length)],
        targetValue: (template['targetValue'] as num?)?.toDouble() ?? 1.0,
        currentValue: _generateGoalProgress((template['targetValue'] as num?)?.toDouble() ?? 1.0, profile),
        createdAt: createdDate,
      );
      
      goals.add(goal);
    }
    
    return goals;
  }
  
  // ============================================================================
  // GENERACIÓN DE TAGS
  // ============================================================================
  
  static Future<List<TagModel>> generateTags({
    required int userId,
  }) async {
    
    final tags = <TagModel>[];
    final tagNames = [
      'trabajo', 'familia', 'ejercicio', 'meditación', 'socializar',
      'estudiar', 'cocinar', 'música', 'naturaleza', 'creatividad',
      'estrés', 'ansiedad', 'cansancio', 'preocupación', 'frustración',
      'alegría', 'gratitud', 'paz', 'esperanza', 'confianza'
    ];
    
    for (int i = 0; i < tagNames.length; i++) {
      final tag = TagModel(
        name: tagNames[i],
        context: 'test_context',
        emoji: _getEmojiForTag(tagNames[i]),
        type: _getTagType(tagNames[i]),
      );
      
      tags.add(tag);
    }
    
    return tags;
  }
  
  // ============================================================================
  // MÉTODOS AUXILIARES DE CONFIGURACIÓN
  // ============================================================================
  
  static Map<String, double> _getProfileConfig(UserProfile profile) {
    switch (profile) {
      case UserProfile.stable:
        return {
          'moodScore': 7.0,
          'energyLevel': 7.0,
          'stressLevel': 4.0,
          'sleepQuality': 7.0,
          'motivationLevel': 7.0,
          'emotionalStability': 8.0,
          'focusLevel': 7.0,
          'lifeSatisfaction': 7.5,
        };
      
      case UserProfile.anxious:
        return {
          'moodScore': 5.5,
          'energyLevel': 5.0,
          'stressLevel': 7.5,
          'sleepQuality': 5.0,
          'motivationLevel': 5.5,
          'emotionalStability': 4.5,
          'focusLevel': 5.0,
          'lifeSatisfaction': 5.0,
        };
      
      case UserProfile.depressed:
        return {
          'moodScore': 4.0,
          'energyLevel': 3.5,
          'stressLevel': 6.0,
          'sleepQuality': 4.0,
          'motivationLevel': 3.0,
          'emotionalStability': 3.5,
          'focusLevel': 4.0,
          'lifeSatisfaction': 3.5,
        };
      
      case UserProfile.improving:
        return {
          'moodScore': 6.0,
          'energyLevel': 6.0,
          'stressLevel': 5.5,
          'sleepQuality': 6.0,
          'motivationLevel': 6.5,
          'emotionalStability': 6.0,
          'focusLevel': 6.0,
          'lifeSatisfaction': 6.5,
        };
      
      case UserProfile.chaotic:
        return {
          'moodScore': 5.0,
          'energyLevel': 5.0,
          'stressLevel': 6.0,
          'sleepQuality': 5.0,
          'motivationLevel': 5.0,
          'emotionalStability': 4.0,
          'focusLevel': 4.5,
          'lifeSatisfaction': 5.0,
        };
    }
  }
  
  static double _getWeekdayModifier(int dayOfWeek, UserProfile profile) {
    // Lunes = 1, Domingo = 7
    final weekendBonus = (dayOfWeek == 6 || dayOfWeek == 7) ? 0.8 : 0.0;
    final mondayPenalty = (dayOfWeek == 1) ? -0.5 : 0.0;
    final fridayBonus = (dayOfWeek == 5) ? 0.4 : 0.0;
    
    return weekendBonus + mondayPenalty + fridayBonus;
  }
  
  static double _getProgressModifier(int day, int totalDays, UserProfile profile) {
    final progress = day / totalDays;
    
    switch (profile) {
      case UserProfile.improving:
        return progress * 2.0; // Mejora constante
      case UserProfile.depressed:
        return progress * -0.5; // Ligero empeoramiento
      case UserProfile.chaotic:
        return sin(progress * 8 * pi) * 0.5; // Oscilación
      default:
        return 0.0;
    }
  }
  
  static int _generateMetric({
    required double base,
    required double weekdayMod,
    required double progressMod,
    required double variance,
  }) {
    final randomVariation = (_random.nextDouble() - 0.5) * variance;
    final result = base + weekdayMod + progressMod + randomVariation;
    return result.clamp(1.0, 10.0).round();
  }
  
  // ============================================================================
  // MÉTODOS ESPECÍFICOS DE GENERACIÓN
  // ============================================================================
  
  static double _generateSleepHours(UserProfile profile, int dayOfWeek) {
    final baseHours = profile == UserProfile.anxious ? 6.5 : 7.5;
    final weekendBonus = (dayOfWeek == 6 || dayOfWeek == 7) ? 1.0 : 0.0;
    final variation = (_random.nextDouble() - 0.5) * 2.0;
    
    return (baseHours + weekendBonus + variation).clamp(4.0, 12.0);
  }
  
  static int _generateAnxietyLevel(UserProfile profile, int dayOfWeek, int day) {
    final baseAnxiety = profile == UserProfile.anxious ? 7.0 : 4.0;
    final mondayStress = (dayOfWeek == 1) ? 2.0 : 0.0;
    final randomSpike = (_random.nextDouble() < 0.15) ? 3.0 : 0.0;
    
    return (baseAnxiety + mondayStress + randomSpike).clamp(1.0, 10.0).round();
  }
  
  static int _generateSocialInteraction(UserProfile profile, int dayOfWeek) {
    final baseInteraction = profile == UserProfile.depressed ? 3.0 : 6.0;
    final weekendBonus = (dayOfWeek == 6 || dayOfWeek == 7) ? 2.0 : 0.0;
    final variation = (_random.nextDouble() - 0.5) * 2.0;
    
    return (baseInteraction + weekendBonus + variation).clamp(1.0, 10.0).round();
  }
  
  static int _generatePhysicalActivity(UserProfile profile, int dayOfWeek) {
    final baseActivity = profile == UserProfile.stable ? 7.0 : 5.0;
    final weekendBonus = (dayOfWeek == 6 || dayOfWeek == 7) ? 1.5 : 0.0;
    final variation = (_random.nextDouble() - 0.5) * 2.0;
    
    return (baseActivity + weekendBonus + variation).clamp(1.0, 10.0).round();
  }
  
  static int _generateWorkProductivity(UserProfile profile, int dayOfWeek) {
    if (dayOfWeek == 6 || dayOfWeek == 7) return 1; // Fin de semana
    
    final baseProductivity = profile == UserProfile.chaotic ? 5.0 : 7.0;
    final mondayPenalty = (dayOfWeek == 1) ? -1.0 : 0.0;
    final fridayPenalty = (dayOfWeek == 5) ? -0.5 : 0.0;
    final variation = (_random.nextDouble() - 0.5) * 1.5;
    
    return (baseProductivity + mondayPenalty + fridayPenalty + variation).clamp(1.0, 10.0).round();
  }
  
  static int _generateWaterIntake(UserProfile profile) {
    final baseIntake = profile == UserProfile.stable ? 8.0 : 6.0;
    final variation = (_random.nextDouble() - 0.5) * 4.0;
    
    return (baseIntake + variation).clamp(2.0, 15.0).round();
  }
  
  static int _generateMeditationMinutes(UserProfile profile, int day) {
    if (profile == UserProfile.improving) {
      // Mejora gradual en meditación
      return (day * 0.5 + _random.nextDouble() * 20).clamp(0.0, 60.0).round();
    }
    
    final baseMeditation = profile == UserProfile.anxious ? 10.0 : 5.0;
    final variation = _random.nextDouble() * 20.0;
    
    return (baseMeditation + variation).clamp(0.0, 60.0).round();
  }
  
  static int _generateExerciseMinutes(UserProfile profile, int dayOfWeek) {
    final baseExercise = profile == UserProfile.stable ? 45.0 : 20.0;
    final weekendBonus = (dayOfWeek == 6 || dayOfWeek == 7) ? 30.0 : 0.0;
    final variation = _random.nextDouble() * 40.0;
    
    return (baseExercise + weekendBonus + variation).clamp(0.0, 180.0).round();
  }
  
  static double _generateScreenTime(UserProfile profile, int dayOfWeek) {
    final baseScreen = profile == UserProfile.chaotic ? 8.0 : 5.0;
    final weekendPenalty = (dayOfWeek == 6 || dayOfWeek == 7) ? 2.0 : 0.0;
    final variation = (_random.nextDouble() - 0.5) * 3.0;
    
    return (baseScreen + weekendPenalty + variation).clamp(1.0, 16.0);
  }
  
  // ============================================================================
  // GENERACIÓN DE TEXTOS
  // ============================================================================
  
  static String? _generateReflection(UserProfile profile, int day) {
    if (_random.nextDouble() < 0.7) { // 70% de probabilidad
      final reflections = _getReflectionTemplates(profile);
      return reflections[_random.nextInt(reflections.length)];
    }
    return null;
  }
  
  static String? _generateGratitude(UserProfile profile, int day) {
    if (_random.nextDouble() < 0.6) { // 60% de probabilidad
      final gratitudes = _getGratitudeTemplates(profile);
      return gratitudes[_random.nextInt(gratitudes.length)];
    }
    return null;
  }
  
  static String? _generatePositiveTags(UserProfile profile) {
    if (_random.nextDouble() < 0.8) {
      final tags = ['alegría', 'gratitud', 'paz', 'esperanza', 'confianza', 'logro'];
      return tags[_random.nextInt(tags.length)];
    }
    return null;
  }
  
  static String? _generateNegativeTags(UserProfile profile) {
    if (profile == UserProfile.anxious && _random.nextDouble() < 0.6) {
      final tags = ['estrés', 'ansiedad', 'preocupación', 'nerviosismo'];
      return tags[_random.nextInt(tags.length)];
    }
    if (profile == UserProfile.depressed && _random.nextDouble() < 0.5) {
      final tags = ['tristeza', 'cansancio', 'desmotivación', 'soledad'];
      return tags[_random.nextInt(tags.length)];
    }
    return null;
  }
  
  static bool? _generateWorthIt(UserProfile profile, int day) {
    final probability = profile == UserProfile.stable ? 0.8 : 0.6;
    if (_random.nextDouble() < probability) {
      return _random.nextBool();
    }
    return null;
  }
  
  // ============================================================================
  // GENERACIÓN DE MOMENTOS
  // ============================================================================
  
  static DateTime _generateMomentTime(DateTime date, int moment, int totalMoments) {
    final startHour = 7; // 7 AM
    final endHour = 22; // 10 PM
    final timeRange = endHour - startHour;
    
    final momentHour = startHour + ((moment + 1) * timeRange / (totalMoments + 1)).floor();
    final momentMinute = _random.nextInt(60);
    
    return DateTime(date.year, date.month, date.day, momentHour, momentMinute);
  }
  
  static Map<String, dynamic> _generateMomentData(UserProfile profile, int day, int moment) {
    final momentTypes = _getMomentTypes(profile);
    final selectedType = momentTypes[_random.nextInt(momentTypes.length)];
    
    return {
      'emoji': selectedType['emoji'],
      'type': selectedType['type'],
      'description': selectedType['description'],
      'category': selectedType['category'],
      'intensity': _random.nextInt(10) + 1,
      'location': _generateLocation(),
      'imagePath': null, // Opcional
    };
  }
  
  static String? _generateLocation() {
    if (_random.nextDouble() < 0.3) {
      final locations = ['Casa', 'Trabajo', 'Gimnasio', 'Parque', 'Cafetería', 'Universidad'];
      return locations[_random.nextInt(locations.length)];
    }
    return null;
  }
  
  // ============================================================================
  // PLANTILLAS DE DATOS
  // ============================================================================
  
  static List<String> _getReflectionTemplates(UserProfile profile) {
    switch (profile) {
      case UserProfile.stable:
        return [
          'Hoy fue un día productivo y equilibrado.',
          'Me siento satisfecho con lo que logré hoy.',
          'Mantuve un buen balance entre trabajo y descanso.',
          'Pude manejar bien las situaciones que se presentaron.',
        ];
      
      case UserProfile.anxious:
        return [
          'Hoy me sentí un poco abrumado, pero logré salir adelante.',
          'La ansiedad estuvo presente, pero pude controlarla.',
          'Necesito trabajar en técnicas de relajación.',
          'Algunos momentos fueron difíciles, pero otros mejores.',
        ];
      
      case UserProfile.depressed:
        return [
          'Fue un día difícil, pero lo completé.',
          'Me costó encontrar motivación, pero hice lo que pude.',
          'Pequeños pasos, pero son pasos al fin.',
          'Mañana intentaré hacer algo diferente.',
        ];
      
      case UserProfile.improving:
        return [
          'Cada día me siento un poco mejor.',
          'Hoy practiqué nuevas técnicas de bienestar.',
          'Puedo ver progreso en mi estado de ánimo.',
          'Estoy orgulloso de mi dedicación al crecimiento personal.',
        ];
      
      case UserProfile.chaotic:
        return [
          'Fue un día de altibajos, como siempre.',
          'Mi estado de ánimo cambió varias veces hoy.',
          'Necesito más estructura en mi día.',
          'Algunos momentos fueron geniales, otros no tanto.',
        ];
    }
  }
  
  static List<String> _getGratitudeTemplates(UserProfile profile) {
    return [
      'Agradezco por mi familia y amigos.',
      'Estoy agradecido por mi salud.',
      'Valoro las pequeñas cosas de la vida.',
      'Agradezco por las oportunidades que tengo.',
      'Estoy agradecido por poder aprender y crecer.',
      'Valoro los momentos de paz y tranquilidad.',
    ];
  }
  
  static List<Map<String, dynamic>> _getMomentTypes(UserProfile profile) {
    final commonMoments = [
      {'emoji': '😊', 'type': 'positive', 'description': 'Momento de alegría', 'category': 'emocional'},
      {'emoji': '💪', 'type': 'positive', 'description': 'Logro personal', 'category': 'logro'},
      {'emoji': '🌅', 'type': 'positive', 'description': 'Momento de calma', 'category': 'bienestar'},
      {'emoji': '❤️', 'type': 'positive', 'description': 'Conexión social', 'category': 'social'},
      {'emoji': '😔', 'type': 'negative', 'description': 'Momento de tristeza', 'category': 'emocional'},
      {'emoji': '😰', 'type': 'negative', 'description': 'Momento de estrés', 'category': 'estrés'},
    ];
    
    if (profile == UserProfile.anxious) {
      commonMoments.addAll([
        {'emoji': '😨', 'type': 'negative', 'description': 'Crisis de ansiedad', 'category': 'ansiedad'},
        {'emoji': '😌', 'type': 'positive', 'description': 'Momento de relajación', 'category': 'bienestar'},
      ]);
    }
    
    if (profile == UserProfile.depressed) {
      commonMoments.addAll([
        {'emoji': '😞', 'type': 'negative', 'description': 'Sentimiento de vacío', 'category': 'emocional'},
        {'emoji': '🌱', 'type': 'positive', 'description': 'Pequeña victoria', 'category': 'logro'},
      ]);
    }
    
    return commonMoments;
  }
  
  static List<Map<String, dynamic>> _getGoalTemplates(UserProfile profile) {
    return [
      {
        'title': 'Meditación diaria',
        'description': 'Meditar al menos 10 minutos cada día',
        'targetValue': 30.0,
        'unit': 'días',
        'category': 'bienestar',
        'priority': 'alta',
      },
      {
        'title': 'Ejercicio regular',
        'description': 'Hacer ejercicio 3 veces por semana',
        'targetValue': 12.0,
        'unit': 'sesiones',
        'category': 'físico',
        'priority': 'media',
      },
      {
        'title': 'Lectura',
        'description': 'Leer 2 libros este mes',
        'targetValue': 2.0,
        'unit': 'libros',
        'category': 'personal',
        'priority': 'baja',
      },
      {
        'title': 'Conexión social',
        'description': 'Pasar tiempo con amigos semanalmente',
        'targetValue': 4.0,
        'unit': 'encuentros',
        'category': 'social',
        'priority': 'media',
      },
      {
        'title': 'Dormir mejor',
        'description': 'Dormir 8 horas por noche',
        'targetValue': 30.0,
        'unit': 'noches',
        'category': 'salud',
        'priority': 'alta',
      },
    ];
  }
  
  static double _generateGoalProgress(double targetValue, UserProfile profile) {
    final progressPercentage = profile == UserProfile.improving ? 0.7 : 0.4;
    return (targetValue * progressPercentage * _random.nextDouble()).clamp(0.0, targetValue);
  }
  
  static String _getEmojiForTag(String tagName) {
    final emojiMap = {
      'trabajo': '💼',
      'familia': '👨‍👩‍👧‍👦',
      'ejercicio': '🏃‍♂️',
      'meditación': '🧘‍♀️',
      'socializar': '👥',
      'estudiar': '📚',
      'cocinar': '🍳',
      'música': '🎵',
      'naturaleza': '🌳',
      'creatividad': '🎨',
      'estrés': '😰',
      'ansiedad': '😟',
      'cansancio': '😴',
      'preocupación': '😕',
      'frustración': '😤',
      'alegría': '😊',
      'gratitud': '🙏',
      'paz': '☮️',
      'esperanza': '🌟',
      'confianza': '💪',
    };
    
    return emojiMap[tagName] ?? '📝';
  }

  static String? _getTagType(String tagName) {
    final positiveWords = ['alegría', 'gratitud', 'paz', 'esperanza', 'confianza'];
    final negativeWords = ['estrés', 'ansiedad', 'cansancio', 'preocupación', 'frustración'];
    
    if (positiveWords.contains(tagName)) {
      return 'positive';
    } else if (negativeWords.contains(tagName)) {
      return 'negative';
    } else {
      return 'neutral';
    }
  }
}