// ============================================================================
// test_data/analytics_data_seeder.dart
// SEEDER DE DATOS PARA PRUEBAS RÁPIDAS DE ANALYTICS
// ============================================================================

import '../data/services/optimized_database_service.dart';
import '../data/models/optimized_models.dart';
import '../data/models/interactive_moment_model.dart';
import '../data/models/goal_model.dart';
import 'analytics_test_data_generator.dart';
import '../presentation/providers/optimized_providers.dart';

class AnalyticsDataSeeder {
  final OptimizedDatabaseService _databaseService;
  final OptimizedAuthProvider? _authProvider;
  
  AnalyticsDataSeeder(this._databaseService, [this._authProvider]);
  
  // ============================================================================
  // MÉTODO PRINCIPAL: SEMBRAR DATOS DE PRUEBA
  // ============================================================================
  
  Future<Map<String, dynamic>> seedAnalyticsData({
    required int userId,
    bool clearExisting = true,
    int daysOfData = 30,
    UserProfile profile = UserProfile.stable,
  }) async {
    
    print('🌱 Sembrando datos de prueba para usuario $userId...');
    print('📅 Días de datos: $daysOfData');
    print('👤 Perfil: ${profile.name}');
    
    try {
      // 1. Limpiar datos existentes si es necesario
      if (clearExisting) {
        await _clearExistingData(userId);
      }
      
      // 2. Generar datos de prueba
      final testData = await AnalyticsTestDataGenerator.generateCompleteTestData(
        userId: userId,
        profile: profile,
        daysOfData: daysOfData,
        momentsPerDay: 3,
        numberOfGoals: 5,
      );
      
      // 3. Insertar datos en la base de datos
      await _insertAllData(testData);
      
      // 4. Generar estadísticas finales
      final stats = await _generateDataStats(userId);
      
      print('✅ Datos sembrados exitosamente');
      return {
        'success': true,
        'userId': userId,
        'profile': profile.name,
        'daysOfData': daysOfData,
        'stats': stats,
        'message': 'Datos de prueba insertados correctamente'
      };
      
    } catch (e) {
      print('❌ Error sembrando datos: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al insertar datos de prueba'
      };
    }
  }
  
  // ============================================================================
  // MÉTODOS DE SEEDING DIRECTO CON AUTO-LOGIN
  // ============================================================================
  
  /// Poblar como usuario ESTABLE y hacer login automático
  Future<Map<String, dynamic>> seedAndLoginAsStable() async {
    return await _seedAndLoginAsProfile(
      profile: UserProfile.stable,
      name: 'Ana Estable',
      email: 'ana.estable@reflect.app',
      password: 'estable123',
      avatar: '😌',
      bio: 'Usuario con rutinas consistentes y bienestar equilibrado',
      daysOfData: 30,
    );
  }
  
  /// Poblar como usuario ANSIOSO y hacer login automático
  Future<Map<String, dynamic>> seedAndLoginAsAnxious() async {
    return await _seedAndLoginAsProfile(
      profile: UserProfile.anxious,
      name: 'Carlos Ansioso',
      email: 'carlos.ansioso@reflect.app',
      password: 'ansioso123',
      avatar: '😰',
      bio: 'Usuario que experimenta patrones de ansiedad frecuentes',
      daysOfData: 45,
    );
  }
  
  /// Poblar como usuario DEPRIMIDO y hacer login automático
  Future<Map<String, dynamic>> seedAndLoginAsDepressed() async {
    return await _seedAndLoginAsProfile(
      profile: UserProfile.depressed,
      name: 'María Melancólica',
      email: 'maria.melancolica@reflect.app',
      password: 'melancolica123',
      avatar: '😔',
      bio: 'Usuario con tendencias depresivas en proceso de recuperación',
      daysOfData: 50,
    );
  }
  
  /// Poblar como usuario EN MEJORA y hacer login automático
  Future<Map<String, dynamic>> seedAndLoginAsImproving() async {
    return await _seedAndLoginAsProfile(
      profile: UserProfile.improving,
      name: 'Luis Progreso',
      email: 'luis.progreso@reflect.app',
      password: 'progreso123',
      avatar: '🌱',
      bio: 'Usuario en proceso activo de mejora y crecimiento personal',
      daysOfData: 60,
    );
  }
  
  /// Poblar como usuario CAÓTICO y hacer login automático
  Future<Map<String, dynamic>> seedAndLoginAsChaotic() async {
    return await _seedAndLoginAsProfile(
      profile: UserProfile.chaotic,
      name: 'Emma Caótica',
      email: 'emma.caotica@reflect.app',
      password: 'caotica123',
      avatar: '🌪️',
      bio: 'Usuario con patrones inconsistentes y vida poco estructurada',
      daysOfData: 35,
    );
  }
  
  /// Método privado que hace el trabajo real de crear usuario y hacer login
  Future<Map<String, dynamic>> _seedAndLoginAsProfile({
    required UserProfile profile,
    required String name,
    required String email,
    required String password,
    required String avatar,
    required String bio,
    required int daysOfData,
  }) async {
    try {
      print('🎭 Poblando datos para perfil: ${profile.name}');
      print('👤 Usuario: $name ($email)');
      
      // 1. Crear o obtener el usuario
      OptimizedUserModel? user = await _databaseService.createUser(
        name: name,
        email: email,
        password: password,
        avatarEmoji: avatar,
        bio: bio,
      );
      
      // Si ya existe, obtenerlo por autenticación
      user ??= await _databaseService.authenticateUser(email, password);
      
      if (user == null) {
        return {
          'success': false,
          'error': 'No se pudo crear o encontrar el usuario',
          'message': 'Error al configurar usuario $name'
        };
      }
      
      print('✅ Usuario configurado: $name (ID: ${user.id})');
      
      // 2. Limpiar datos existentes
      await _clearExistingData(user.id);
      
      // 3. Sembrar datos de prueba
      final seedResult = await seedAnalyticsData(
        userId: user.id,
        profile: profile,
        daysOfData: daysOfData,
        clearExisting: false, // Ya limpiamos arriba
      );
      
      if (!seedResult['success']) {
        return seedResult;
      }
      
      // 4. Hacer login automático si el AuthProvider está disponible
      bool loginSuccess = false;
      if (_authProvider != null) {
        loginSuccess = await _authProvider!.login(email, password);
        if (loginSuccess) {
          print('🔑 Login automático exitoso como: $name');
        } else {
          print('❌ Error en login automático para: $name');
        }
      } else {
        print('⚠️ AuthProvider no disponible, login manual requerido');
      }
      
      return {
        'success': true,
        'user_id': user.id,
        'user_name': name,
        'user_email': email,
        'user_password': password,
        'profile': profile.name,
        'days_of_data': daysOfData,
        'auto_login': loginSuccess,
        'login_required': !loginSuccess,
        'stats': seedResult['stats'],
        'message': loginSuccess 
            ? 'Usuario $name creado y login exitoso'
            : 'Usuario $name creado, login manual requerido',
      };
      
    } catch (e) {
      print('❌ Error poblando perfil ${profile.name}: $e');
      return {
        'success': false,
        'error': e.toString(),
        'profile': profile.name,
        'message': 'Error al poblar datos para $name'
      };
    }
  }
  
  // ============================================================================
  // MÉTODO DE SEEDING CON AUTO-LOGIN
  // ============================================================================
  
  /// Crea usuarios para cada perfil y permite login automático
  Future<Map<String, dynamic>> seedUsersAndLogin({
    UserProfile? profileToLogin,
    bool clearExisting = true,
    int daysOfData = 30,
  }) async {
    
    print('🎭 Creando usuarios para todos los perfiles...');
    
    try {
      // Definir datos de usuarios para cada perfil
      final profileUsers = {
        UserProfile.stable: {
          'name': 'Ana Estable',
          'email': 'ana.estable@reflect.app',
          'password': 'estable123',
          'avatar': '😌',
          'bio': 'Usuario con rutinas consistentes y bienestar equilibrado'
        },
        UserProfile.anxious: {
          'name': 'Carlos Ansioso',
          'email': 'carlos.ansioso@reflect.app',
          'password': 'ansioso123',
          'avatar': '😰',
          'bio': 'Usuario que experimenta patrones de ansiedad frecuentes'
        },
        UserProfile.depressed: {
          'name': 'María Melancólica',
          'email': 'maria.melancolica@reflect.app',
          'password': 'melancolica123',
          'avatar': '😔',
          'bio': 'Usuario con tendencias depresivas en proceso de recuperación'
        },
        UserProfile.improving: {
          'name': 'Luis Progreso',
          'email': 'luis.progreso@reflect.app',
          'password': 'progreso123',
          'avatar': '🌱',
          'bio': 'Usuario en proceso activo de mejora y crecimiento personal'
        },
        UserProfile.chaotic: {
          'name': 'Emma Caótica',
          'email': 'emma.caotica@reflect.app',
          'password': 'caotica123',
          'avatar': '🌪️',
          'bio': 'Usuario con patrones inconsistentes y vida poco estructurada'
        },
      };

      Map<UserProfile, int> createdUsers = {};
      
      // Crear usuarios para cada perfil
      for (final profile in UserProfile.values) {
        final userData = profileUsers[profile]!;
        
        // Intentar crear el usuario
        OptimizedUserModel? user = await _databaseService.createUser(
          name: userData['name']!,
          email: userData['email']!,
          password: userData['password']!,
          avatarEmoji: userData['avatar']!,
          bio: userData['bio']!,
        );
        
        // Si el usuario ya existe, intentar obtenerlo
        user ??= await _databaseService.authenticateUser(
          userData['email']!,
          userData['password']!,
        );
        
        if (user != null) {
          createdUsers[profile] = user.id;
          print('✅ Usuario creado: ${userData['name']} (ID: ${user.id})');
          
          // Sembrar datos para este usuario
          if (clearExisting) {
            await _clearExistingData(user.id);
          }
          
          await seedAnalyticsData(
            userId: user.id,
            profile: profile,
            daysOfData: daysOfData,
            clearExisting: false, // Ya lo limpiamos arriba
          );
        }
      }
      
      // Auto-login si se especificó un perfil
      bool loginSuccess = false;
      int? loggedInUserId;
      
      if (profileToLogin != null && _authProvider != null && createdUsers.containsKey(profileToLogin)) {
        final userData = profileUsers[profileToLogin]!;
        loginSuccess = await _authProvider!.login(
          userData['email']!,
          userData['password']!,
        );
        
        if (loginSuccess) {
          loggedInUserId = _authProvider!.currentUser?.id;
          print('🔑 Auto-login exitoso como: ${userData['name']}');
        }
      }
      
      return {
        'success': true,
        'created_users': createdUsers.map((profile, userId) => MapEntry(profile.name, userId)),
        'total_users': createdUsers.length,
        'auto_login': loginSuccess,
        'logged_in_user_id': loggedInUserId,
        'profile_credentials': profileUsers.map((profile, data) => 
          MapEntry(profile.name, {
            'email': data['email'],
            'password': data['password'],
            'name': data['name'],
          })
        ),
        'message': 'Usuarios creados y datos sembrados exitosamente'
      };
      
    } catch (e) {
      print('❌ Error creando usuarios: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al crear usuarios y sembrar datos'
      };
    }
  }
  
  /// Login rápido con credenciales de perfil
  Future<bool> quickLoginAs(UserProfile profile) async {
    if (_authProvider == null) {
      print('❌ AuthProvider no disponible para login');
      return false;
    }
    
    final credentials = {
      UserProfile.stable: {'email': 'ana.estable@reflect.app', 'password': 'estable123'},
      UserProfile.anxious: {'email': 'carlos.ansioso@reflect.app', 'password': 'ansioso123'},
      UserProfile.depressed: {'email': 'maria.melancolica@reflect.app', 'password': 'melancolica123'},
      UserProfile.improving: {'email': 'luis.progreso@reflect.app', 'password': 'progreso123'},
      UserProfile.chaotic: {'email': 'emma.caotica@reflect.app', 'password': 'caotica123'},
    };
    
    final creds = credentials[profile];
    if (creds == null) return false;
    
    return await _authProvider!.login(creds['email']!, creds['password']!);
  }
  
  // ============================================================================
  // MÉTODOS DE SEEDING ESPECÍFICO
  // ============================================================================
  
  /// Siembra solo entradas diarias
  Future<Map<String, dynamic>> seedDailyEntriesOnly(int userId, int days) async {
    print('📅 Sembrando solo entradas diarias...');
    
    final entries = await AnalyticsTestDataGenerator.generateDailyEntries(
      userId: userId,
      profile: UserProfile.stable,
      days: days,
    );
    
    for (final entry in entries) {
      await _databaseService.saveDailyEntry(entry);
    }
    
    return {
      'success': true,
      'inserted': entries.length,
      'type': 'daily_entries_only'
    };
  }
  
  /// Siembra solo momentos interactivos
  Future<Map<String, dynamic>> seedMomentsOnly(int userId, int days) async {
    print('💭 Sembrando solo momentos interactivos...');
    
    final moments = await AnalyticsTestDataGenerator.generateInteractiveMoments(
      userId: userId,
      profile: UserProfile.stable,
      days: days,
      momentsPerDay: 3,
    );
    
    for (final moment in moments) {
      // Convert to OptimizedInteractiveMomentModel and save
      final optimizedMoment = OptimizedInteractiveMomentModel(
        id: int.tryParse(moment.id),
        userId: userId,
        text: moment.text,
        type: moment.type,
        intensity: moment.intensity,
        category: moment.category,
        emoji: moment.emoji,
        timestamp: moment.timestamp,
        createdAt: moment.timestamp,
        entryDate: moment.entryDate,
      );
      await _databaseService.saveInteractiveMoment(userId, optimizedMoment);
    }
    
    return {
      'success': true,
      'inserted': moments.length,
      'type': 'moments_only'
    };
  }
  
  /// Siembra solo metas
  Future<Map<String, dynamic>> seedGoalsOnly(int userId, int numberOfGoals) async {
    print('🎯 Sembrando solo metas...');
    
    final goals = await AnalyticsTestDataGenerator.generateGoals(
      userId: userId,
      profile: UserProfile.stable,
      numberOfGoals: numberOfGoals,
    );
    
    for (final goal in goals) {
      await _databaseService.createGoalSafe(
        userId: goal.userId,
        title: goal.title,
        description: goal.description,
        type: goal.type.name,
        targetValue: goal.targetValue,
        currentValue: goal.currentValue,
      );
    }
    
    return {
      'success': true,
      'inserted': goals.length,
      'type': 'goals_only'
    };
  }
  
  // ============================================================================
  // MÉTODOS DE LIMPIEZA
  // ============================================================================
  
  Future<void> _clearExistingData(int userId) async {
    print('🧹 Limpiando datos existentes...');
    
    try {
      // Limpiar entradas diarias
      await _databaseService.deleteDailyEntriesForUser(userId);
      
      // Limpiar momentos interactivos
      await _databaseService.deleteInteractiveMomentsForUser(userId);
      
      // Limpiar metas
      await _databaseService.deleteGoalsForUser(userId);
      
      print('✅ Datos existentes limpiados');
    } catch (e) {
      print('⚠️  Error limpiando datos: $e');
    }
  }
  
  /// Limpia todos los datos de un usuario
  Future<void> clearAllUserData(int userId) async {
    await _databaseService.deleteAllTestDataForUser(userId);
  }
  
  // ============================================================================
  // INSERCIÓN DE DATOS
  // ============================================================================
  
  Future<void> _insertAllData(Map<String, dynamic> testData) async {
    print('📝 Insertando datos en la base de datos...');
    
    final dailyEntries = testData['dailyEntries'] as List<OptimizedDailyEntryModel>;
    final interactiveMoments = testData['interactiveMoments'] as List<InteractiveMomentModel>;
    final goals = testData['goals'] as List<GoalModel>;
    
    int insertedEntries = 0;
    int insertedMoments = 0;
    int insertedGoals = 0;
    
    // Insertar entradas diarias
    for (final entry in dailyEntries) {
      try {
        await _databaseService.saveDailyEntry(entry);
        insertedEntries++;
      } catch (e) {
        print('⚠️  Error insertando entrada: $e');
      }
    }
    
    // Insertar momentos interactivos
    if (dailyEntries.isNotEmpty) {
      for (final moment in interactiveMoments) {
        try {
          // Convert to OptimizedInteractiveMomentModel and save
          final optimizedMoment = OptimizedInteractiveMomentModel(
            id: int.tryParse(moment.id),
            userId: dailyEntries.first.userId, // Use userId from the daily entries
          text: moment.text,
          type: moment.type,
          intensity: moment.intensity,
          category: moment.category,
          emoji: moment.emoji,
          timestamp: moment.timestamp,
          createdAt: moment.timestamp,
          entryDate: moment.entryDate,
        );
        await _databaseService.saveInteractiveMoment(dailyEntries.first.userId, optimizedMoment);
        insertedMoments++;
        } catch (e) {
          print('⚠️  Error insertando momento: $e');
        }
      }
    }
    
    // Insertar metas
    for (final goal in goals) {
      try {
        await _databaseService.createGoalSafe(
          userId: goal.userId,
          title: goal.title,
          description: goal.description,
          type: goal.type.name,
          targetValue: goal.targetValue,
          currentValue: goal.currentValue,
        );
        insertedGoals++;
      } catch (e) {
        print('⚠️  Error insertando meta: $e');
      }
    }
    
    print('✅ Datos insertados:');
    print('  📅 Entradas diarias: $insertedEntries');
    print('  💭 Momentos interactivos: $insertedMoments');
    print('  🎯 Metas: $insertedGoals');
  }
  
  // ============================================================================
  // ESTADÍSTICAS DE DATOS
  // ============================================================================
  
  Future<Map<String, dynamic>> _generateDataStats(int userId) async {
    try {
      // Obtener estadísticas de la base de datos
      final dailyEntries = await _databaseService.getDailyEntries(userId: userId);
      final interactiveMoments = await _databaseService.getInteractiveMoments(userId: userId);
      final goals = await _databaseService.getUserGoals(userId);
      
      // Calcular estadísticas básicas
      final stats = {
        'totalDailyEntries': dailyEntries.length,
        'totalInteractiveMoments': interactiveMoments.length,
        'totalGoals': goals.length,
        'dateRange': _calculateDateRange(dailyEntries),
        'averageMoodScore': _calculateAverageMood(dailyEntries),
        'moodDistribution': _calculateMoodDistribution(dailyEntries),
        'momentTypes': _calculateMomentTypes(interactiveMoments),
        'goalProgress': _calculateGoalProgress(goals),
      };
      
      return stats;
      
    } catch (e) {
      print('⚠️  Error generando estadísticas: $e');
      return {};
    }
  }
  
  Map<String, String> _calculateDateRange(List<OptimizedDailyEntryModel> entries) {
    if (entries.isEmpty) return {'start': 'N/A', 'end': 'N/A'};
    
    final dates = entries.map((e) => e.entryDate).toList()..sort();
    return {
      'start': dates.first.toIso8601String().split('T')[0],
      'end': dates.last.toIso8601String().split('T')[0],
    };
  }
  
  double _calculateAverageMood(List<OptimizedDailyEntryModel> entries) {
    if (entries.isEmpty) return 0.0;
    
    final totalMood = entries.fold(0, (sum, entry) => sum + (entry.moodScore ?? 5));
    return totalMood / entries.length;
  }
  
  Map<String, int> _calculateMoodDistribution(List<OptimizedDailyEntryModel> entries) {
    final distribution = <String, int>{
      'muy_bajo': 0,  // 1-2
      'bajo': 0,      // 3-4
      'medio': 0,     // 5-6
      'alto': 0,      // 7-8
      'muy_alto': 0,  // 9-10
    };
    
    for (final entry in entries) {
      final moodScore = entry.moodScore ?? 5;
      if (moodScore <= 2) {
        distribution['muy_bajo'] = distribution['muy_bajo']! + 1;
      } else if (moodScore <= 4) {
        distribution['bajo'] = distribution['bajo']! + 1;
      } else if (moodScore <= 6) {
        distribution['medio'] = distribution['medio']! + 1;
      } else if (moodScore <= 8) {
        distribution['alto'] = distribution['alto']! + 1;
      } else {
        distribution['muy_alto'] = distribution['muy_alto']! + 1;
      }
    }
    
    return distribution;
  }
  
  Map<String, int> _calculateMomentTypes(List<OptimizedInteractiveMomentModel> moments) {
    final types = <String, int>{
      'positive': 0,
      'negative': 0,
      'neutral': 0,
    };
    
    for (final moment in moments) {
      types[moment.type] = (types[moment.type] ?? 0) + 1;
    }
    
    return types;
  }
  
  Map<String, dynamic> _calculateGoalProgress(List<Map<String, dynamic>> goals) {
    if (goals.isEmpty) {
      return {
        'completed': 0,
        'in_progress': 0,
        'average_progress': 0.0,
      };
    }
    
    int completed = 0;
    int inProgress = 0;
    double totalProgress = 0.0;
    
    for (final goal in goals) {
      final isCompleted = (goal['is_completed'] as int?) == 1;
      if (isCompleted) {
        completed++;
        totalProgress += 1.0;
      } else {
        inProgress++;
        final targetValue = (goal['target_value'] as num?)?.toDouble() ?? 0.0;
        final currentValue = (goal['current_value'] as num?)?.toDouble() ?? 0.0;
        final progress = targetValue > 0 ? (currentValue / targetValue) : 0.0;
        totalProgress += progress;
      }
    }
    
    return {
      'completed': completed,
      'in_progress': inProgress,
      'average_progress': totalProgress / goals.length,
    };
  }
  
  // ============================================================================
  // UTILIDADES
  // ============================================================================
  
  /// Obtiene estadísticas actuales de un usuario
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    return await _generateDataStats(userId);
  }
  
  /// Verifica si un usuario tiene datos suficientes para análisis
  Future<bool> hasEnoughDataForAnalysis(int userId) async {
    final stats = await _generateDataStats(userId);
    
    final dailyEntries = stats['totalDailyEntries'] as int? ?? 0;
    final moments = stats['totalInteractiveMoments'] as int? ?? 0;
    
    // Criterios mínimos para análisis
    return dailyEntries >= 7 && moments >= 5;
  }
  
  /// Genera un reporte de datos sembrados
  Future<String> generateSeedReport(int userId) async {
    final stats = await _generateDataStats(userId);
    
    final report = StringBuffer();
    report.writeln('📊 REPORTE DE DATOS SEMBRADOS');
    report.writeln('=' * 40);
    report.writeln('👤 Usuario: $userId');
    report.writeln('📅 Entradas diarias: ${stats['totalDailyEntries']}');
    report.writeln('💭 Momentos interactivos: ${stats['totalInteractiveMoments']}');
    report.writeln('🎯 Metas: ${stats['totalGoals']}');
    
    final dateRange = stats['dateRange'] as Map<String, String>;
    report.writeln('📆 Rango de fechas: ${dateRange['start']} - ${dateRange['end']}');
    
    final avgMood = stats['averageMoodScore'] as double? ?? 0.0;
    report.writeln('😊 Humor promedio: ${avgMood.toStringAsFixed(1)}/10');
    
    final moodDist = stats['moodDistribution'] as Map<String, int>;
    report.writeln('📊 Distribución de humor:');
    moodDist.forEach((level, count) {
      report.writeln('  $level: $count días');
    });
    
    final momentTypes = stats['momentTypes'] as Map<String, int>;
    report.writeln('💭 Tipos de momentos:');
    momentTypes.forEach((type, count) {
      report.writeln('  $type: $count momentos');
    });
    
    final goalProgress = stats['goalProgress'] as Map<String, dynamic>;
    report.writeln('🎯 Progreso de metas:');
    report.writeln('  Completadas: ${goalProgress['completed']}');
    report.writeln('  En progreso: ${goalProgress['in_progress']}');
    report.writeln('  Progreso promedio: ${((goalProgress['average_progress'] as double) * 100).toStringAsFixed(1)}%');
    
    return report.toString();
  }
  
  // ============================================================================
  // MÉTODOS ESTÁTICOS PARA USO DIRECTO DESDE LA APP
  // ============================================================================
  
  /// POBLAR ESTABLE - Crea usuario estable y hace login automático
  static Future<Map<String, dynamic>> poblarEstable(OptimizedDatabaseService databaseService, OptimizedAuthProvider authProvider) async {
    final seeder = AnalyticsDataSeeder(databaseService, authProvider);
    return await seeder.seedAndLoginAsStable();
  }
  
  /// POBLAR ANSIOSO - Crea usuario ansioso y hace login automático
  static Future<Map<String, dynamic>> poblarAnsioso(OptimizedDatabaseService databaseService, OptimizedAuthProvider authProvider) async {
    final seeder = AnalyticsDataSeeder(databaseService, authProvider);
    return await seeder.seedAndLoginAsAnxious();
  }
  
  /// POBLAR DEPRIMIDO - Crea usuario deprimido y hace login automático
  static Future<Map<String, dynamic>> poblarDeprimido(OptimizedDatabaseService databaseService, OptimizedAuthProvider authProvider) async {
    final seeder = AnalyticsDataSeeder(databaseService, authProvider);
    return await seeder.seedAndLoginAsDepressed();
  }
  
  /// POBLAR EN MEJORA - Crea usuario en mejora y hace login automático
  static Future<Map<String, dynamic>> poblarEnMejora(OptimizedDatabaseService databaseService, OptimizedAuthProvider authProvider) async {
    final seeder = AnalyticsDataSeeder(databaseService, authProvider);
    return await seeder.seedAndLoginAsImproving();
  }
  
  /// POBLAR CAÓTICO - Crea usuario caótico y hace login automático
  static Future<Map<String, dynamic>> poblarCaotico(OptimizedDatabaseService databaseService, OptimizedAuthProvider authProvider) async {
    final seeder = AnalyticsDataSeeder(databaseService, authProvider);
    return await seeder.seedAndLoginAsChaotic();
  }
  
  /// Ejemplo de uso completo: crea todos los usuarios y loguea como uno específico
  static Future<void> exampleUsage(OptimizedDatabaseService databaseService, OptimizedAuthProvider authProvider) async {
    final seeder = AnalyticsDataSeeder(databaseService, authProvider);
    
    print('🚀 EJEMPLO DE USO: Auto-seeding con login');
    print('=' * 50);
    
    // Crear todos los usuarios y loguear automáticamente como usuario estable
    final result = await seeder.seedUsersAndLogin(
      profileToLogin: UserProfile.stable,
      clearExisting: true,
      daysOfData: 45,
    );
    
    if (result['success']) {
      print('✅ Proceso completado exitosamente!');
      print('👥 Usuarios creados: ${result['total_users']}');
      print('🔑 Auto-login: ${result['auto_login'] ? 'Exitoso' : 'Fallido'}');
      print('👤 Usuario logueado ID: ${result['logged_in_user_id']}');
      
      print('\n📧 CREDENCIALES DISPONIBLES:');
      final credentials = result['profile_credentials'] as Map<String, dynamic>;
      credentials.forEach((profile, data) {
        final profileData = data as Map<String, dynamic>;
        print('  $profile: ${profileData['email']} / ${profileData['password']}');
      });
      
      print('\n💡 Para cambiar de usuario, usa:');
      print('await seeder.quickLoginAs(UserProfile.anxious);');
      
    } else {
      print('❌ Error: ${result['message']}');
    }
  }
}