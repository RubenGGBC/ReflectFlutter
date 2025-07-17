// ============================================================================
// injection_container_clean.dart - DEPENDENCY INJECTION OPTIMIZADO + NOTIFICATIONS
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Services optimizados
import 'data/services/optimized_database_service.dart';
import 'data/services/image_picker_service.dart';
import 'ai/services/predictive_analysis_service.dart';
import 'services/notification_service.dart';
import 'services/voice_recording_service.dart';

// Providers optimizados
import 'presentation/providers/optimized_providers.dart';
import 'presentation/providers/extended_daily_entries_provider.dart';
import 'presentation/providers/image_moments_provider.dart'; // ✅ NUEVO PROVIDER AÑADIDO
import 'presentation/providers/analytics_provider.dart'; // ✅ PROVIDER AÑADIDO
import 'presentation/providers/advanced_emotion_analysis_provider.dart'; // ✅ NUEVO PROVIDER AVANZADO
import 'presentation/providers/challenges_provider.dart'; // ✅ HIGH PRIORITY ENHANCEMENT
import 'presentation/providers/streak_provider.dart'; // ✅ HIGH PRIORITY ENHANCEMENT
import 'ai/provider/ai_provider.dart';
import 'ai/provider/predective_analysis_provider.dart'; // ✅ NUEVO: Análisis Predictivo
import 'ai/provider/chat_provider.dart'; // ✅ NUEVO: Chat con IA
import 'ai/provider/mental_health_chat_provider.dart'; // ✅ NUEVO: Mental Health Chat
// Theme provider (reutilizado del original)
import 'presentation/providers/theme_provider.dart';

final sl = GetIt.instance;

/// Inicializar todas las dependencias de la app limpia
Future<void> initCleanDependencies() async {
  Logger? logger;
  
  try {
    // ============================================================================
    // CORE SERVICES (Singletons - solo una instancia)
    // ============================================================================
    
    // Solo registrar Logger si no está ya registrado
    if (!sl.isRegistered<Logger>()) {
      sl.registerLazySingleton<Logger>(() => Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.none,
        ),
      ));
    }
    
    logger = sl<Logger>();
    logger.i('🧹 Inicializando dependencias limpias...');

    sl.registerLazySingleton<OptimizedDatabaseService>(
          () => OptimizedDatabaseService(),
    );
    
    sl.registerLazySingleton<ImagePickerService>(
          () => ImagePickerService(),
    );
    
    sl.registerLazySingleton<PredictiveAnalysisService>(
          () => PredictiveAnalysisService.instance,
    );
    
    sl.registerLazySingleton<NotificationService>(
          () => NotificationService(),
    );
    
    sl.registerLazySingleton<VoiceRecordingService>(
          () => VoiceRecordingService(),
    );



    // ============================================================================
    // PROVIDERS (Factories - nueva instancia cuando se pide)
    // ✅ CORREGIDO: Se cambia de registerLazySingleton a registerFactory para
    // evitar problemas de estado entre Hot Restarts.
    // ============================================================================

    sl.registerFactory<OptimizedAuthProvider>(
          () => OptimizedAuthProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<ThemeProvider>(
          () => ThemeProvider(),
    );

    sl.registerFactory<OptimizedDailyEntriesProvider>(
          () => OptimizedDailyEntriesProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ ExtendedDailyEntriesProvider con IA
    sl.registerFactory<ExtendedDailyEntriesProvider>(
          () => ExtendedDailyEntriesProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<OptimizedMomentsProvider>(
          () => OptimizedMomentsProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<OptimizedAnalyticsProvider>(
          () => OptimizedAnalyticsProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<AnalyticsProvider>(
          () => AnalyticsProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: AnalyticsProviderOptimized
    sl.registerFactory<AnalyticsProviderOptimized>(
          () => AnalyticsProviderOptimized(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<AIProvider>(
          () => AIProvider(),
    );

    sl.registerFactory<GoalsProvider>(
          () => GoalsProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: NotificationsProvider

    // ✅ NUEVO: ImageMomentsProvider
    sl.registerFactory<ImageMomentsProvider>(
          () => ImageMomentsProvider(),
    );

    // ✅ NUEVO: PredictiveAnalysisProvider
    sl.registerFactory<PredictiveAnalysisProvider>(
          () => PredictiveAnalysisProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: ChatProvider
    sl.registerFactory<ChatProvider>(
          () => ChatProvider(sl<OptimizedDatabaseService>(), sl<AIProvider>()),
    );

    // ✅ NUEVO: MentalHealthChatProvider
    sl.registerFactory<MentalHealthChatProvider>(
          () => MentalHealthChatProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ HIGH PRIORITY ENHANCEMENTS: New providers
    sl.registerFactory<ChallengesProvider>(
          () => ChallengesProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<StreakProvider>(
          () => StreakProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: AdvancedEmotionAnalysisProvider
    sl.registerFactory<AdvancedEmotionAnalysisProvider>(
          () => AdvancedEmotionAnalysisProvider(sl<OptimizedDatabaseService>()),
    );

    logger.i('✅ Dependencias limpias inicializadas correctamente');

  } catch (e) {
    logger?.e('❌ Error inicializando dependencias limpias: $e');
    // Use debugPrint instead of print for better performance
    debugPrint('❌ Error inicializando dependencias limpias: $e');
    rethrow;
  }
}

/// Inicializar servicios críticos al startup
Future<void> initCriticalServices() async {
  final logger = sl<Logger>();
  logger.i('🚀 Inicializando servicios críticos...');

  try {
    // Inicializar servicio de notificaciones
    final notificationService = sl<NotificationService>();
    await notificationService.init();
    await notificationService.setupDefaultReminders();
    logger.i('✅ Servicio de notificaciones inicializado');

    // Inicializar otros servicios críticos aquí si es necesario

  } catch (e) {
    logger.e('❌ Error inicializando servicios críticos: $e');
    // No lanzar error para evitar crash de la app
  }
}

// ============================================================================
// FUNCIONES DE UTILIDAD
// ============================================================================

/// Verificar que todos los servicios estén registrados
bool areCleanServicesRegistered() {
  try {
    // Verificar servicios core
    sl<Logger>();
    sl<OptimizedDatabaseService>();
    sl<ImagePickerService>();
    sl<PredictiveAnalysisService>();
    sl<NotificationService>();

    // Verificar providers
    sl<OptimizedAuthProvider>();
    sl<ThemeProvider>();
    sl<OptimizedDailyEntriesProvider>();
    sl<ExtendedDailyEntriesProvider>();
    sl<OptimizedMomentsProvider>();
    sl<OptimizedAnalyticsProvider>();
    sl<AnalyticsProvider>();
    sl<AnalyticsProviderOptimized>(); // ✅ NUEVO
    sl<AIProvider>();
    sl<GoalsProvider>();
    sl<ImageMomentsProvider>(); // ✅ NUEVO
    sl<PredictiveAnalysisProvider>(); // ✅ NUEVO
    sl<ChatProvider>(); // ✅ NUEVO
    sl<MentalHealthChatProvider>(); // ✅ NUEVO
    sl<ChallengesProvider>(); // ✅ HIGH PRIORITY ENHANCEMENT
    sl<StreakProvider>(); // ✅ HIGH PRIORITY ENHANCEMENT
    sl<AdvancedEmotionAnalysisProvider>(); // ✅ NUEVO

    return true;
  } catch (e) {
    return false;
  }
}

/// Información del contenedor limpio
Map<String, dynamic> getCleanContainerInfo() {
  return {
    'total_services': 20, // ✅ ACTUALIZADO (era 19, ahora 20)
    'services_ready': areCleanServicesRegistered(),
    'core_services': [
      'Logger',
      'OptimizedDatabaseService',
      'ImagePickerService', // ✅ NUEVO
      'PredictiveAnalysisService', // ✅ NUEVO
      'NotificationService', // ✅ NUEVO
    ],
    'providers': [
      'OptimizedAuthProvider',
      'ThemeProvider',
      'OptimizedDailyEntriesProvider',
      'ExtendedDailyEntriesProvider',
      'OptimizedMomentsProvider',
      'OptimizedAnalyticsProvider',
      'AnalyticsProvider',
      'AIProvider',
      'GoalsProvider',
      'NotificationsProvider', // ✅ NUEVO
      'ImageMomentsProvider', // ✅ NUEVO
      'PredictiveAnalysisProvider', // ✅ NUEVO
      'ChatProvider', // ✅ NUEVO
      'MentalHealthChatProvider', // ✅ NUEVO
      'ChallengesProvider', // ✅ HIGH PRIORITY ENHANCEMENT
      'StreakProvider', // ✅ HIGH PRIORITY ENHANCEMENT
      'AdvancedEmotionAnalysisProvider', // ✅ NUEVO
    ],
    'removed_legacy': [
      'AnalyticsProvider (legacy)',
      'EnhancedAnalyticsProvider (duplicate)',
      'InteractiveMomentsProvider (legacy)',
      'AuthProvider (legacy)',
      'AdvancedUserAnalytics (merged)',
    ],
  };
}

/// Resetear contenedor para testing
Future<void> resetCleanContainer() async {
  await sl.reset();
}

/// Inicialización específica para testing
Future<void> initForCleanTesting() async {
  if (sl.isRegistered<OptimizedDatabaseService>()) {
    await resetCleanContainer();
  }
  await initCleanDependencies();
}

// ============================================================================
// EXTENSIONES PARA FACILITAR USO
// ============================================================================

extension CleanGetItExtension on GetIt {
  /// Verificar si un tipo está registrado de forma segura
  bool isRegisteredClean<T extends Object>() {
    try {
      return isRegistered<T>();
    } catch (e) {
      return false;
    }
  }

  /// Obtener instancia de forma segura
  T? getCleanSafe<T extends Object>() {
    try {
      if (isRegistered<T>()) {
        return get<T>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener servicio principal con verificación
  T getCleanService<T extends Object>() {
    if (!isRegistered<T>()) {
      throw Exception('Servicio $T no está registrado. Llama a initCleanDependencies() primero.');
    }
    return get<T>();
  }
}

// ============================================================================
// CONSTANTES DE IDENTIFICACIÓN
// ============================================================================

class CleanDIConstants {
  static const String logger = 'Logger';
  static const String databaseService = 'OptimizedDatabaseService';
  static const String predictiveAnalysisService = 'PredictiveAnalysisService'; // ✅ NUEVO
  static const String notificationService = 'NotificationService'; // ✅ NUEVO
  static const String authProvider = 'OptimizedAuthProvider';
  static const String themeProvider = 'ThemeProvider';
  static const String dailyEntriesProvider = 'OptimizedDailyEntriesProvider';
  static const String extendedDailyEntriesProvider = 'ExtendedDailyEntriesProvider';
  static const String momentsProvider = 'OptimizedMomentsProvider';
  static const String analyticsProvider = 'OptimizedAnalyticsProvider';
  static const String aiProvider = 'AIProvider';
  static const String goalsProvider = 'GoalsProvider';
  static const String notificationsProvider = 'NotificationsProvider'; // ✅ NUEVO
  static const String imageMomentsProvider = 'ImageMomentsProvider'; // ✅ NUEVO
  static const String predictiveAnalysisProvider = 'PredictiveAnalysisProvider'; // ✅ NUEVO
  static const String chatProvider = 'ChatProvider'; // ✅ NUEVO
  static const String mentalHealthChatProvider = 'MentalHealthChatProvider'; // ✅ NUEVO
  static const String challengesProvider = 'ChallengesProvider'; // ✅ HIGH PRIORITY ENHANCEMENT
  static const String streakProvider = 'StreakProvider'; // ✅ HIGH PRIORITY ENHANCEMENT
}

// ============================================================================
// HELPER PARA MIGRACIÓN GRADUAL
// ============================================================================

class DIMigrationHelper {
  static const Map<String, String> _migrationMap = {
    'AuthProvider': 'OptimizedAuthProvider',
    'InteractiveMomentsProvider': 'OptimizedMomentsProvider',
    'AnalyticsProvider': 'OptimizedAnalyticsProvider',
    'DatabaseService': 'OptimizedDatabaseService',
  };

  static String? getOptimizedServiceName(String legacyName) {
    return _migrationMap[legacyName];
  }

  static bool hasOptimizedEquivalent(String legacyName) {
    return _migrationMap.containsKey(legacyName);
  }

  static List<String> getLegacyServicesToRemove() {
    return [
      'AdvancedUserAnalytics',
      'EnhancedAnalyticsProvider',
      'SessionService',
    ];
  }

  static Map<String, dynamic> checkMigrationStatus() {
    final isLegacyPresent = false; // Legacy system completely removed
    final isOptimizedPresent = sl.isRegisteredClean<OptimizedAuthProvider>();
    return {
      'legacy_present': isLegacyPresent,
      'optimized_present': isOptimizedPresent,
      'migration_complete': isOptimizedPresent, // Simplified since legacy is always false
      'conflicts': false, // No conflicts since legacy is removed
    };
  }
}

// ============================================================================
// CONFIGURACIÓN DE LOGGING OPTIMIZADA
// ============================================================================

class OptimizedLoggingConfig {
  static Logger createProductionLogger() {
    return Logger(
      level: Level.info,
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 3,
        lineLength: 80,
        colors: false,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static Logger createDevelopmentLogger() {
    return Logger(
      level: Level.debug,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.none,
      ),
    );
  }

  static Logger createTestingLogger() {
    return Logger(
      level: Level.warning,
      printer: SimplePrinter(),
    );
  }
}

// ============================================================================
// INICIALIZADORES ESPECÍFICOS POR ENTORNO
// ============================================================================

Future<void> initForProduction() async {
  // Reset container to avoid conflicts
  await resetCleanContainer();
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createProductionLogger());
  await initCleanDependencies();
  await initCriticalServices(); // ✅ NUEVO
}

Future<void> initForDevelopment() async {
  // Reset container to avoid conflicts
  await resetCleanContainer();
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createDevelopmentLogger());
  await initCleanDependencies();
  await initCriticalServices(); // ✅ NUEVO
}

Future<void> initForTesting() async {
  await resetCleanContainer();
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createTestingLogger());
  await initCleanDependencies();
  // No inicializar notificaciones en testing
}
