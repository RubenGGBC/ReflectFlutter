// ============================================================================
// data/services/optimized_database_service.dart - VERSIÓN CORREGIDA
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

// ✅ SOLO imports de modelos optimizados
import '../models/optimized_models.dart';

class OptimizedDatabaseService {
  static const String _databaseName = 'reflect_optimized.db';
  static const int _databaseVersion = 2;

  static Database? _database;
  static final OptimizedDatabaseService _instance = OptimizedDatabaseService._internal();

  final Logger _logger = Logger();

  factory OptimizedDatabaseService() => _instance;
  OptimizedDatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ============================================================================
  // INICIALIZACIÓN Y ESQUEMA OPTIMIZADO
  // ============================================================================

  Future<Database> _initDatabase() async {
    _logger.i('🗄️ Inicializando base de datos optimizada');

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createOptimizedSchema,
      onUpgrade: _upgradeSchema,
      onConfigure: _configureDatabase,
    );
  }

  Future<void> _configureDatabase(Database db) async {
    // Optimizaciones de rendimiento
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA journal_mode = WAL');
    await db.execute('PRAGMA cache_size = -2000'); // 2MB cache
    await db.execute('PRAGMA temp_store = MEMORY');
    await db.execute('PRAGMA synchronous = NORMAL');
  }

  Future<void> _createOptimizedSchema(Database db, int version) async {
    await db.transaction((txn) async {
      // TABLA USUARIOS - Optimizada
      await txn.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          name TEXT NOT NULL,
          avatar_emoji TEXT DEFAULT '🧘‍♀️',
          bio TEXT,
          preferences TEXT DEFAULT '{}',
          created_at INTEGER NOT NULL DEFAULT (unixepoch()),
          last_login INTEGER,
          is_active BOOLEAN DEFAULT 1
        )
      ''');

      // TABLA ENTRADAS DIARIAS - Con todos los campos de analytics
      await txn.execute('''
        CREATE TABLE daily_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          entry_date TEXT NOT NULL,
          free_reflection TEXT NOT NULL,
          positive_tags TEXT DEFAULT '[]',
          negative_tags TEXT DEFAULT '[]',
          worth_it INTEGER, -- 0=no, 1=yes, NULL=not answered
          overall_sentiment TEXT,
          mood_score INTEGER CHECK (mood_score >= 1 AND mood_score <= 10),
          ai_summary TEXT,
          word_count INTEGER DEFAULT 0,
          
          -- Analytics expandidos
          energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
          stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 10),
          sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 10),
          anxiety_level INTEGER CHECK (anxiety_level >= 1 AND anxiety_level <= 10),
          motivation_level INTEGER CHECK (motivation_level >= 1 AND motivation_level <= 10),
          social_interaction INTEGER CHECK (social_interaction >= 1 AND social_interaction <= 10),
          physical_activity INTEGER CHECK (physical_activity >= 1 AND physical_activity <= 10),
          work_productivity INTEGER CHECK (work_productivity >= 1 AND work_productivity <= 10),
          sleep_hours REAL CHECK (sleep_hours >= 0 AND sleep_hours <= 24),
          water_intake INTEGER CHECK (water_intake >= 0),
          meditation_minutes INTEGER CHECK (meditation_minutes >= 0),
          exercise_minutes INTEGER CHECK (exercise_minutes >= 0),
          screen_time_hours REAL CHECK (screen_time_hours >= 0),
          gratitude_items TEXT,
          weather_mood_impact INTEGER CHECK (weather_mood_impact >= -5 AND weather_mood_impact <= 5),
          social_battery INTEGER CHECK (social_battery >= 1 AND social_battery <= 10),
          creative_energy INTEGER CHECK (creative_energy >= 1 AND creative_energy <= 10),
          emotional_stability INTEGER CHECK (emotional_stability >= 1 AND emotional_stability <= 10),
          focus_level INTEGER CHECK (focus_level >= 1 AND focus_level <= 10),
          life_satisfaction INTEGER CHECK (life_satisfaction >= 1 AND life_satisfaction <= 10),
          
          created_at INTEGER NOT NULL DEFAULT (unixepoch()),
          updated_at INTEGER NOT NULL DEFAULT (unixepoch()),
          
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(user_id, entry_date)
        )
      ''');

      // TABLA MOMENTOS INTERACTIVOS - Optimizada
      await txn.execute('''
        CREATE TABLE interactive_moments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          entry_date TEXT NOT NULL,
          emoji TEXT NOT NULL,
          text TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('positive', 'negative', 'neutral')),
          intensity INTEGER DEFAULT 5 CHECK (intensity >= 1 AND intensity <= 10),
          category TEXT DEFAULT 'general',
          
          -- Contexto enriquecido
          context_location TEXT,
          context_weather TEXT,
          context_social TEXT,
          energy_before INTEGER CHECK (energy_before >= 1 AND energy_before <= 10),
          energy_after INTEGER CHECK (energy_after >= 1 AND energy_after <= 10),
          mood_before INTEGER CHECK (mood_before >= 1 AND mood_before <= 10),
          mood_after INTEGER CHECK (mood_after >= 1 AND mood_after <= 10),
          
          timestamp INTEGER NOT NULL DEFAULT (unixepoch()),
          created_at INTEGER NOT NULL DEFAULT (unixepoch()),
          
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // TABLA TAGS - Para análisis avanzado
      await txn.execute('''
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('positive', 'negative', 'neutral')),
          category TEXT DEFAULT 'general',
          emoji TEXT DEFAULT '🏷️',
          usage_count INTEGER DEFAULT 1,
          last_used INTEGER NOT NULL DEFAULT (unixepoch()),
          created_at INTEGER NOT NULL DEFAULT (unixepoch()),
          
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(user_id, name, type)
        )
      ''');

      await _createOptimizedIndexes(txn);
    });

    _logger.i('✅ Esquema optimizado creado exitosamente');
  }

  Future<void> _createOptimizedIndexes(Transaction txn) async {
    // Índices para usuarios
    await txn.execute('CREATE INDEX idx_users_email ON users (email)');
    await txn.execute('CREATE INDEX idx_users_active ON users (is_active, last_login)');

    // Índices para entradas diarias
    await txn.execute('CREATE INDEX idx_daily_entries_user_date ON daily_entries (user_id, entry_date)');
    await txn.execute('CREATE INDEX idx_daily_entries_created ON daily_entries (created_at DESC)');
    await txn.execute('CREATE INDEX idx_daily_entries_mood ON daily_entries (user_id, mood_score, entry_date)');

    // Índices para momentos interactivos
    await txn.execute('CREATE INDEX idx_moments_user_date ON interactive_moments (user_id, entry_date)');
    await txn.execute('CREATE INDEX idx_moments_type ON interactive_moments (user_id, type, timestamp)');
    await txn.execute('CREATE INDEX idx_moments_category ON interactive_moments (user_id, category)');
    await txn.execute('CREATE INDEX idx_moments_timeline ON interactive_moments (user_id, timestamp DESC)');

    // Índices para tags
    await txn.execute('CREATE INDEX idx_tags_user_type ON tags (user_id, type)');
    await txn.execute('CREATE INDEX idx_tags_usage ON tags (usage_count DESC, last_used DESC)');
  }

  Future<void> _upgradeSchema(Database db, int oldVersion, int newVersion) async {
    _logger.i('🔄 Actualizando esquema desde v$oldVersion a v$newVersion');

    if (oldVersion < 2) {
      // Migración de v1 a v2
      await _migrateToV2(db);
    }
  }

  Future<void> _migrateToV2(Database db) async {
    // Implementar migración si es necesario
    _logger.i('📦 Migración a v2 completada');
  }

  // ============================================================================
  // MÉTODOS OPTIMIZADOS PARA USUARIOS
  // ============================================================================

  Future<OptimizedUserModel?> createUser({
    required String email,
    required String password,
    required String name,
    String avatarEmoji = '🧘‍♀️',
    String bio = '',
  }) async {
    try {
      final db = await database;
      final passwordHash = _hashPassword(password);

      final userId = await db.insert('users', {
        'email': email.toLowerCase().trim(),
        'password_hash': passwordHash,
        'name': name.trim(),
        'avatar_emoji': avatarEmoji,
        'bio': bio,
      });

      _logger.i('✨ Usuario creado exitosamente: $name (ID: $userId)');

      return OptimizedUserModel(
        id: userId,
        email: email,
        name: name,
        avatarEmoji: avatarEmoji,
        bio: bio,
        createdAt: DateTime.now(),
        lastLogin: null,
      );
    } catch (e) {
      _logger.e('❌ Error creando usuario: $e');
      return null;
    }
  }

  Future<OptimizedUserModel?> authenticateUser(String email, String password) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'email = ? AND is_active = 1',
        whereArgs: [email.toLowerCase().trim()],
        limit: 1,
      );

      if (results.isEmpty) return null;

      final userData = results.first;
      final storedHash = userData['password_hash'] as String;

      if (!_verifyPassword(password, storedHash)) return null;

      // Actualizar último login
      await db.update(
        'users',
        {'last_login': DateTime.now().millisecondsSinceEpoch ~/ 1000},
        where: 'id = ?',
        whereArgs: [userData['id']],
      );

      // ✅ CORREGIDO: Usar modelo optimizado
      return OptimizedUserModel.fromDatabase(userData);
    } catch (e) {
      _logger.e('❌ Error en autenticación: $e');
      return null;
    }
  }

  Future<OptimizedUserModel?> getUserById(int userId) async {
    try {
      final db = await database;
      final results = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
          limit: 1
      );

      if (results.isEmpty) return null;

      // ✅ CORREGIDO: Usar modelo optimizado
      return OptimizedUserModel.fromDatabase(results.first);
    } catch (e) {
      _logger.e('❌ Error obteniendo usuario $userId: $e');
      return null;
    }
  }

  // ============================================================================
  // MÉTODOS OPTIMIZADOS PARA ENTRADAS DIARIAS
  // ============================================================================

  Future<int?> saveDailyEntry(OptimizedDailyEntryModel entry) async {
    try {
      final db = await database;
      // ✅ CORREGIDO: Usar método del modelo optimizado
      final entryData = entry.toOptimizedDatabase();

      final existingEntry = await db.query(
        'daily_entries',
        where: 'user_id = ? AND entry_date = ?',
        whereArgs: [entry.userId, entry.entryDate.toIso8601String().split('T')[0]],
        limit: 1,
      );

      int entryId;
      if (existingEntry.isNotEmpty) {
        entryId = existingEntry.first['id'] as int;
        entryData['updated_at'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        await db.update(
          'daily_entries',
          entryData,
          where: 'id = ?',
          whereArgs: [entryId],
        );
        _logger.d('📝 Entrada diaria actualizada (ID: $entryId)');
      } else {
        entryId = await db.insert('daily_entries', entryData);
        _logger.d('📝 Nueva entrada diaria creada (ID: $entryId)');
      }

      return entryId;
    } catch (e) {
      _logger.e('❌ Error guardando entrada diaria: $e');
      return null;
    }
  }

  Future<List<OptimizedDailyEntryModel>> getDailyEntries({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final db = await database;

      String whereClause = 'user_id = ?';
      List<dynamic> whereArgs = [userId];

      if (startDate != null) {
        whereClause += ' AND entry_date >= ?';
        whereArgs.add(startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        whereClause += ' AND entry_date <= ?';
        whereArgs.add(endDate.toIso8601String().split('T')[0]);
      }

      final results = await db.query(
        'daily_entries',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'entry_date DESC',
        limit: limit,
      );

      // ✅ CORREGIDO: Usar modelo optimizado
      return results.map((row) => OptimizedDailyEntryModel.fromDatabase(row)).toList();
    } catch (e) {
      _logger.e('❌ Error obteniendo entradas diarias: $e');
      return [];
    }
  }

  // ============================================================================
  // MÉTODOS OPTIMIZADOS PARA MOMENTOS INTERACTIVOS
  // ============================================================================

  Future<int?> saveInteractiveMoment(int userId, OptimizedInteractiveMomentModel moment) async {
    try {
      final db = await database;
      // ✅ CORREGIDO: Usar método del modelo optimizado
      final momentData = moment.toOptimizedDatabase();
      momentData['user_id'] = userId;

      final momentId = await db.insert('interactive_moments', momentData);
      _logger.d('✨ Momento guardado: ${moment.emoji} ${moment.text} (ID: $momentId)');

      return momentId;
    } catch (e) {
      _logger.e('❌ Error guardando momento: $e');
      return null;
    }
  }

  Future<List<OptimizedInteractiveMomentModel>> getInteractiveMoments({
    required int userId,
    DateTime? date,
    String? type,
    String? category,
    int? limit,
  }) async {
    try {
      final db = await database;

      String whereClause = 'user_id = ?';
      List<dynamic> whereArgs = [userId];

      if (date != null) {
        whereClause += ' AND entry_date = ?';
        whereArgs.add(date.toIso8601String().split('T')[0]);
      }

      if (type != null) {
        whereClause += ' AND type = ?';
        whereArgs.add(type);
      }

      if (category != null) {
        whereClause += ' AND category = ?';
        whereArgs.add(category);
      }

      final results = await db.query(
        'interactive_moments',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      // ✅ CORREGIDO: Usar modelo optimizado
      return results.map((row) => OptimizedInteractiveMomentModel.fromDatabase(row)).toList();
    } catch (e) {
      _logger.e('❌ Error obteniendo momentos: $e');
      return [];
    }
  }

  // ============================================================================
  // ANÁLISIS Y ESTADÍSTICAS OPTIMIZADAS
  // ============================================================================

  Future<Map<String, dynamic>> getUserAnalytics(int userId, {int days = 30}) async {
    try {
      final db = await database;
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      // Análisis paralelo para mejor rendimiento
      final results = await Future.wait([
        _getBasicStats(db, userId, startDate, endDate),
        _getMoodTrends(db, userId, startDate, endDate),
        _getMomentStats(db, userId, startDate, endDate),
        _getStreakData(db, userId),
      ]);

      return {
        'basic_stats': results[0],
        'mood_trends': results[1],
        'moment_stats': results[2],
        'streak_data': results[3],
        'period_days': days,
      };
    } catch (e) {
      _logger.e('❌ Error obteniendo analytics: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _getBasicStats(
      Database db, int userId, DateTime start, DateTime end) async {

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_entries,
        AVG(mood_score) as avg_mood,
        AVG(energy_level) as avg_energy,
        AVG(stress_level) as avg_stress,
        SUM(CASE WHEN worth_it = 1 THEN 1 ELSE 0 END) as worthit_days,
        AVG(sleep_hours) as avg_sleep,
        SUM(meditation_minutes) as total_meditation,
        SUM(exercise_minutes) as total_exercise
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
    ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);

    return result.first;
  }

  Future<List<Map<String, dynamic>>> _getMoodTrends(
      Database db, int userId, DateTime start, DateTime end) async {

    return await db.rawQuery('''
      SELECT 
        entry_date,
        mood_score,
        energy_level,
        stress_level,
        sleep_quality
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
      ORDER BY entry_date ASC
    ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);
  }

  Future<Map<String, dynamic>> _getMomentStats(
      Database db, int userId, DateTime start, DateTime end) async {

    final result = await db.rawQuery('''
      SELECT 
        type,
        COUNT(*) as count,
        AVG(intensity) as avg_intensity,
        category
      FROM interactive_moments 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
      GROUP BY type, category
    ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);

    return {'moments_by_type_category': result};
  }

  Future<Map<String, dynamic>> _getStreakData(Database db, int userId) async {
    final results = await db.rawQuery('''
      SELECT entry_date 
      FROM daily_entries 
      WHERE user_id = ? 
      ORDER BY entry_date DESC 
      LIMIT 365
    ''', [userId]);

    return _calculateStreaks(results.map((r) => r['entry_date'] as String).toList());
  }

  Map<String, dynamic> _calculateStreaks(List<String> dates) {
    if (dates.isEmpty) return {'current_streak': 0, 'longest_streak': 0};

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;

    final today = DateTime.now();
    final sortedDates = dates.map((d) => DateTime.parse(d)).toList()..sort();

    // Calcular streak actual
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      if (i == 0) {
        if (date.difference(today).inDays.abs() <= 1) {
          currentStreak = 1;
        }
      } else {
        final prevDate = sortedDates[i - 1];
        if (date.difference(prevDate).inDays == 1) {
          if (currentStreak > 0) currentStreak++;
          tempStreak++;
        } else {
          longestStreak = math.max(longestStreak, tempStreak);
          tempStreak = 1;
          currentStreak = 0;
        }
      }
    }

    longestStreak = math.max(longestStreak, tempStreak);

    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }

  // ============================================================================
  // UTILIDADES Y HELPERS
  // ============================================================================

  String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'reflect_salt_2024');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  Future<bool> clearUserData(int userId) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete('interactive_moments', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('daily_entries', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('tags', where: 'user_id = ?', whereArgs: [userId]);
      });

      _logger.i('🗑️ Datos del usuario $userId eliminados');
      return true;
    } catch (e) {
      _logger.e('❌ Error eliminando datos: $e');
      return false;
    }
  }

  Future<void> optimizeDatabase() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
      await db.execute('ANALYZE');
      _logger.i('🔧 Base de datos optimizada');
    } catch (e) {
      _logger.e('❌ Error optimizando BD: $e');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
  // ... dentro de la clase OptimizedDatabaseService

  // ✅ NUEVO: Método principal para la cuenta de desarrollador
  Future<OptimizedUserModel?> createDeveloperAccount() async {
    try {
      final db = await database;
      _logger.i('🧪 Creando/accediendo a cuenta de desarrollador...');

      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['dev@reflect.com'],
      );

      int userId;
      if (existing.isNotEmpty) {
        userId = existing.first['id'] as int;
        _logger.i('🔄 Usando cuenta de desarrollador existente: $userId');
      } else {
        final defaultPassword = 'devpassword123';
        final passwordHash = _hashPassword(defaultPassword);

        userId = await db.insert('users', {
          'name': 'Alex Developer',
          'email': 'dev@reflect.com',
          'password_hash': passwordHash,
          'avatar_emoji': '👨‍💻',
          'bio': 'Explorando los límites de Reflect. Creando datos para un futuro mejor.',
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });
        _logger.i('✅ Cuenta de desarrollador creada: $userId');
      }

      await generateComprehensiveTestData(userId);
      return await getUserById(userId);

    } catch (e) {
      _logger.e('❌ Error creando cuenta desarrollador: $e');
      rethrow;
    }
  }

  // ✅ NUEVO: Orquestador para generar todos los datos de prueba
  Future<void> generateComprehensiveTestData(int userId) async {
    try {
      final db = await database;
      _logger.i('📊 Generando datos comprehensivos para usuario: $userId');

      await db.delete('daily_entries', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('interactive_moments', where: 'user_id = ?', whereArgs: [userId]);
      _logger.i('🗑️ Datos previos del desarrollador limpiados.');

      await _generateHistoricalData(userId, db);
      await _generateInteractiveMoments(userId, db);

      _logger.i('✅ Datos comprehensivos generados exitosamente');
    } catch (e) {
      _logger.e('❌ Error generando datos de prueba: $e');
      rethrow;
    }
  }


  // ✅ NUEVO: Genera 90 días de datos con patrones
  Future<void> _generateHistoricalData(int userId, Database db) async {
    _logger.i('📈 Generando datos históricos con patrones...');

    final now = DateTime.now();
    final random = math.Random();

    // Fases para simular una historia realista
    final phases = [
      _PersonalityPhase('Período Difícil', -90, -61, 3.5, 4.0, 7.5), // Estrés alto, mood bajo
      _PersonalityPhase('Recuperación Gradual', -60, -31, 5.0, 5.5, 6.0), // Mejora
      _PersonalityPhase('Fase de Crecimiento', -30, -1, 7.5, 8.0, 3.5), // Estado óptimo
    ];

    for (final phase in phases) {
      for (int dayOffset = phase.startDay; dayOffset <= phase.endDay; dayOffset++) {
        final date = now.add(Duration(days: dayOffset));

        final weekendBoost = (date.weekday >= 6) ? 0.5 : 0.0;
        final mondayDip = (date.weekday == 1) ? -0.8 : 0.0;
        final variation = (random.nextDouble() - 0.5) * 2;

        final mood = (phase.baseMood + variation + weekendBoost + mondayDip).clamp(1.0, 10.0);
        final energy = (phase.baseEnergy + variation + weekendBoost).clamp(1.0, 10.0);
        final stress = (phase.baseStress - variation + mondayDip).clamp(1.0, 10.0);

        final entry = OptimizedDailyEntryModel.create(
            userId: userId,
            entryDate: date,
            freeReflection: _generateReflection(mood, energy, stress, phase.name),
            moodScore: mood.round(),
            energyLevel: energy.round(),
            stressLevel: stress.round(),
            sleepQuality: (energy - (stress * 0.2) + random.nextDouble() * 2).clamp(1, 10).round(),
            anxietyLevel: (stress - (mood * 0.1) + random.nextDouble() * 1.5).clamp(1, 10).round(),
            motivationLevel: ((mood + energy) / 2 + random.nextDouble() * 1.5).clamp(1, 10).round(),
            socialInteraction: (mood * 0.6 + weekendBoost * 2 + random.nextDouble() * 2).clamp(1, 10).round(),
            physicalActivity: (energy * 0.7 + weekendBoost + random.nextDouble() * 2).clamp(1, 10).round(),
            workProductivity: date.weekday >= 6 ? (random.nextInt(3) + 1) : (energy - (stress * 0.4) + random.nextDouble() * 2).clamp(1, 10).round(),
            sleepHours: (7.5 - stress * 0.3 + energy * 0.1 + (random.nextDouble() - 0.5) * 2).clamp(4.0, 10.0),
            waterIntake: (6 + energy * 0.3 + random.nextDouble() * 3).clamp(3, 12).round(),
            meditationMinutes: (stress > 6 || mood < 4) ? (10 + random.nextDouble() * 20).round() : (random.nextDouble() * 10).round(),
            exerciseMinutes: date.weekday >=6 ? (random.nextDouble() * 90).round() : (energy * 5 + (random.nextDouble()-0.5) * 20).clamp(0,120).round(),
            screenTimeHours: (6 - mood * 0.2 + stress * 0.3 + random.nextDouble() * 3).clamp(2.0, 14.0),
            gratitudeItems: mood > 6 ? 'Mi familia, el progreso en mis proyectos, la salud.' : 'El café de la mañana.',
            weatherMoodImpact: (random.nextDouble() * 10 - 5).round(),
            socialBattery: (mood * 0.8 - (date.weekday == 1 ? 2:0) + random.nextDouble() * 2).clamp(1, 10).round(),
            creativeEnergy: ((mood + energy) / 2.2 + random.nextDouble() * 2).clamp(1, 10).round(),
            emotionalStability: (mood - stress * 0.3 + random.nextDouble() * 1.5).clamp(1, 10).round(),
            focusLevel: (energy - stress * 0.4 + random.nextDouble() * 2).clamp(1, 10).round(),
            lifeSatisfaction: (mood - stress * 0.2 + random.nextDouble()).clamp(1, 10).round()
        );

        await db.insert('daily_entries', entry.toOptimizedDatabase(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    _logger.i('✅ ${phases.length} fases de datos históricos generadas.');
  }

  // ✅ NUEVO: Genera momentos interactivos para los últimos días
  Future<void> _generateInteractiveMoments(int userId, Database db) async {
    _logger.i('🎭 Generando momentos interactivos...');
    final random = math.Random();
    final momentsData = [
      _MomentData('😄', 'Completé una funcionalidad compleja sin bugs', 'positive', 8, 'trabajo'),
      _MomentData('🎉', 'El cliente quedó encantado con la demo de la app', 'positive', 9, 'trabajo'),
      _MomentData('☕', 'Disfrutando de un café perfecto mientras programo', 'positive', 6, 'personal'),
      _MomentData('🧘', 'Una meditación de 20 minutos me centró por completo', 'positive', 7, 'salud'),
      _MomentData('📚', 'Aprendí un nuevo patrón de diseño muy útil hoy', 'positive', 7, 'estudio'),
      _MomentData('😰', 'Encontré un bug crítico justo antes del release', 'negative', 8, 'trabajo'),
      _MomentData('🥱', 'Noche de poco sueño, me siento realmente agotado', 'negative', 6, 'salud'),
      _MomentData('😤', 'Reunión improductiva de 2 horas que pudo ser un email', 'negative', 7, 'trabajo'),
      _MomentData('🚶', 'Una caminata corta durante el almuerzo para despejar la mente', 'positive', 5, 'salud'),
      _MomentData('📱', 'Perdí 30 minutos haciendo scroll sin propósito en redes', 'neutral', 3, 'personal'),
      _MomentData('🍕', 'La pizza de la cena estaba deliciosa', 'positive', 7, 'personal'),
      _MomentData('🏋️‍♂️', 'Buen entrenamiento en el gimnasio, me siento con energía', 'positive', 8, 'salud'),
      _MomentData('❤️', 'Conversación profunda y bonita con mi pareja', 'positive', 9, 'amor'),
      _MomentData('🤔', 'Reflexionando sobre mis metas para el próximo trimestre', 'neutral', 5, 'estudio'),
    ];

    for (int i=0; i < momentsData.length; i++) {
      final data = momentsData[i];
      final timestamp = DateTime.now().subtract(Duration(hours: i*3, minutes: random.nextInt(60)));
      final moment = OptimizedInteractiveMomentModel.create(
          userId: userId,
          emoji: data.emoji,
          text: data.text,
          type: data.type,
          intensity: data.intensity,
          category: data.category,
          timestamp: timestamp
      );
      await db.insert('interactive_moments', moment.toOptimizedDatabase());
    }
    _logger.i('✅ ${momentsData.length} momentos interactivos generados.');
  }

  // ✅ NUEVO: Helper para generar texto de reflexión
  String _generateReflection(double mood, double energy, double stress, String phaseName) {
    if (phaseName == 'Período Difícil') {
      return 'Hoy fue un día complicado. El estrés ha sido alto y la energía baja. Intentando mantenerme a flote y ser paciente.';
    }
    if (phaseName == 'Recuperación Gradual') {
      return 'Las cosas están mejorando. Aún hay días difíciles, pero siento que estoy recuperando el control y la energía poco a poco.';
    }
    if (phaseName == 'Fase de Crecimiento') {
      return 'Me siento genial. Lleno de energía y motivación. He sido muy productivo y he disfrutado de mis actividades personales.';
    }
    return 'Un día normal, con sus altibajos, pero en general bien.';
  }
  // Agregar al final de la clase OptimizedDatabaseService
  Future<Map<String, dynamic>> getWeeklyDataForAI(int userId) async {
    try {
      final db = await database;
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));

      // Obtener entradas de la semana
      final entriesQuery = '''
      SELECT entry_date, free_reflection, mood_score, energy_level, 
             stress_level, worth_it, sleep_hours, meditation_minutes
      FROM daily_entries 
      WHERE user_id = ? AND entry_date >= ? AND entry_date <= ?
      ORDER BY entry_date DESC
    ''';

      final entries = await db.rawQuery(entriesQuery, [
        userId,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ]);

      // Obtener momentos de la semana
      final momentsQuery = '''
      SELECT entry_date, type, emoji, text, category
      FROM interactive_moments 
      WHERE user_id = ? AND entry_date >= ? AND entry_date <= ?
      ORDER BY timestamp DESC
    ''';

      final moments = await db.rawQuery(momentsQuery, [
        userId,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ]);

      return {
        'entries': entries,
        'moments': moments,
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        }
      };

    } catch (e) {
      _logger.e('❌ Error obteniendo datos semanales para IA: $e');
      return {'entries': [], 'moments': [], 'period': {}};
    }
  }
}
// ... al final del archivo optimized_database_service.dart

class _PersonalityPhase {
  final String name;
  final int startDay;
  final int endDay;
  final double baseMood;
  final double baseEnergy;
  final double baseStress;

  _PersonalityPhase(this.name, this.startDay, this.endDay, this.baseMood, this.baseEnergy, this.baseStress);
}

class _MomentData {
  final String emoji;
  final String text;
  final String type;
  final int intensity;
  final String category;

  _MomentData(this.emoji, this.text, this.type, this.intensity, this.category);
}

class _MilestoneData {
  final int daysAgo;
  final String emoji;
  final String description;
  final String type;
  final int intensity;

  _MilestoneData(this.daysAgo, this.emoji, this.description, this.type, this.intensity);
}
