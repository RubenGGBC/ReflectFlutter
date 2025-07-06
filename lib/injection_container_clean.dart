// ============================================================================
// injection_container_clean.dart - DEPENDENCY INJECTION OPTIMIZADO + NOTIFICATIONS
// ============================================================================

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Services optimizados
import 'data/services/optimized_database_service.dart';
import '../../data/services/notification_service.dart'; // ✅ NUEVO

// Providers optimizados
import 'presentation/providers/optimized_providers.dart';
import 'presentation/providers/extended_daily_entries_provider.dart';
import 'presentation/providers/notifications_provider.dart'; // ✅ NUEVO
import 'presentation/providers/image_moments_provider.dart'; // ✅ NUEVO PROVIDER AÑADIDO
import 'ai/provider/ai_provider.dart';
import '../../../ai/provider/predective_analysis_provider.dart'; // ✅ NUEVO: Análisis Predictivo
import 'ai/provider/chat_provider.dart'; // ✅ NUEVO: Chat con IA
import 'ai/provider/mental_health_chat_provider.dart'; // ✅ NUEVO: Mental Health Chat

// Theme provider (reutilizado del original)
import 'presentation/providers/theme_provider.dart';

final sl = GetIt.instance;

/// Inicializar todas las dependencias de la app limpia
Future<void> initCleanDependencies() async {
  final logger = Logger();
  logger.i('🧹 Inicializando dependencias limpias...');

  try {
    // ============================================================================
    // CORE SERVICES (Singletons - solo una instancia)
    // ============================================================================
    sl.registerLazySingleton<Logger>(() => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: false,
      ),
    ));

    sl.registerLazySingleton<OptimizedDatabaseService>(
          () => OptimizedDatabaseService(),
    );

    // ✅ NUEVO: Inicializar servicio de notificaciones como singleton
    sl.registerLazySingleton<NotificationService>(() {
      // El servicio se inicializa de forma estática, pero registramos la instancia
      return NotificationService();
    });

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

    sl.registerFactory<AIProvider>(
          () => AIProvider(),
    );

    sl.registerFactory<GoalsProvider>(
          () => GoalsProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: NotificationsProvider
    sl.registerFactory<NotificationsProvider>(
          () => NotificationsProvider(),
    );

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

    logger.i('✅ Dependencias limpias inicializadas correctamente');

  } catch (e) {
    logger.e('❌ Error inicializando dependencias limpias: $e');
    rethrow;
  }
}

/// Inicializar servicios críticos al startup
Future<void> initCriticalServices() async {
  final logger = sl<Logger>();
  logger.i('🚀 Inicializando servicios críticos...');

  try {
    // ✅ NUEVO: Inicializar servicio de notificaciones
    await NotificationService.initialize();
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
    sl<NotificationService>(); // ✅ NUEVO

    // Verificar providers
    sl<OptimizedAuthProvider>();
    sl<ThemeProvider>();
    sl<OptimizedDailyEntriesProvider>();
    sl<ExtendedDailyEntriesProvider>();
    sl<OptimizedMomentsProvider>();
    sl<OptimizedAnalyticsProvider>();
    sl<AIProvider>();
    sl<GoalsProvider>();
    sl<NotificationsProvider>(); // ✅ NUEVO
    sl<ImageMomentsProvider>(); // ✅ NUEVO
    sl<PredictiveAnalysisProvider>(); // ✅ NUEVO
    sl<ChatProvider>(); // ✅ NUEVO
    sl<MentalHealthChatProvider>(); // ✅ NUEVO

    return true;
  } catch (e) {
    return false;
  }
}

/// Información del contenedor limpio
Map<String, dynamic> getCleanContainerInfo() {
  return {
    'total_services': 14, // ✅ ACTUALIZADO (era 13, ahora 14)
    'services_ready': areCleanServicesRegistered(),
    'core_services': [
      'Logger',
      'OptimizedDatabaseService',
      'NotificationService', // ✅ NUEVO
    ],
    'providers': [
      'OptimizedAuthProvider',
      'ThemeProvider',
      'OptimizedDailyEntriesProvider',
      'ExtendedDailyEntriesProvider',
      'OptimizedMomentsProvider',
      'OptimizedAnalyticsProvider',
      'AIProvider',
      'GoalsProvider',
      'NotificationsProvider', // ✅ NUEVO
      'ImageMomentsProvider', // ✅ NUEVO
      'PredictiveAnalysisProvider', // ✅ NUEVO
      'ChatProvider', // ✅ NUEVO
      'MentalHealthChatProvider', // ✅ NUEVO
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
    final isLegacyPresent = false;
    final isOptimizedPresent = sl.isRegisteredClean<OptimizedAuthProvider>();
    return {
      'legacy_present': isLegacyPresent,
      'optimized_present': isOptimizedPresent,
      'migration_complete': !isLegacyPresent && isOptimizedPresent,
      'conflicts': isLegacyPresent && isOptimizedPresent,
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
        printTime: true,
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
        printTime: false,
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
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createProductionLogger());
  await initCleanDependencies();
  await initCriticalServices(); // ✅ NUEVO
}

Future<void> initForDevelopment() async {
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