// lib/data/services/optimized_database_service.dart - VERSIÓN FINAL CON CORRECCIÓN DE DUPLICADOS Y NUEVOS MÉTODOS
// =======================================================================================
// SERVICIO DE BASE DE DATOS OPTIMIZADO PARA APK CON ANALYTICS AVANZADOS
// =======================================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

// Asegúrate de que la ruta de importación sea correcta para tu proyecto.
import '../models/goal_model.dart';
import '../models/optimized_models.dart';

class OptimizedDatabaseService {
  static const String _databaseName = 'reflect_optimized_v2.db';
  static const int _databaseVersion = 2;

  static Database? _database;
  static final OptimizedDatabaseService _instance = OptimizedDatabaseService
      ._internal();

  final Logger _logger = Logger();

  factory OptimizedDatabaseService() => _instance;

  OptimizedDatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ============================================================================
  // INICIALIZACIÓN MEJORADA PARA APK
  // ============================================================================

  Future<Database> _initDatabase() async {
    _logger.i('🗄️ Inicializando base de datos optimizada para APK');

    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);

      debugPrint('📁 Ruta de base de datos: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createOptimizedSchema,
        onUpgrade: _upgradeSchema,
        onConfigure: _configureDatabase,
        singleInstance: true,
      );
    } catch (e) {
      _logger.e('❌ Error inicializando base de datos: $e');

      // ✅ FALLBACK ROBUSTO PARA APK
      try {
        _logger.i('🔄 Intentando inicialización de fallback...');

        final tempDir = await getTemporaryDirectory();
        final fallbackPath = join(tempDir.path, 'reflect_fallback.db');

        return await openDatabase(
          fallbackPath,
          version: 1,
          onCreate: (db, version) async {
            await _createMinimalSchema(db);
          },
        );
      } catch (e2) {
        _logger.e('❌ Error crítico en fallback: $e2');
        rethrow;
      }
    }
  }

  Future<void> _configureDatabase(Database db) async {
    try {
      // ✅ CONFIGURACIONES SEGURAS PARA APK
      await db.execute('PRAGMA foreign_keys = ON');
      await db.execute('PRAGMA journal_mode = WAL');
      await db.execute(
          'PRAGMA cache_size = -1000'); // 1MB cache (reducido para APK)
      await db.execute('PRAGMA temp_store = MEMORY');
      await db.execute('PRAGMA synchronous = NORMAL');

      _logger.d('✅ Base de datos configurada para APK');
    } catch (e) {
      _logger.w('⚠️ Advertencia en configuración de BD: $e');
      // Continuar sin configuraciones avanzadas si fallan
    }
  }

  // ✅ ESQUEMA MÍNIMO PARA FALLBACK
  Future<void> _createMinimalSchema(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        name TEXT NOT NULL,
        avatar_emoji TEXT DEFAULT '🧘‍♀️',
        profile_picture_path TEXT,
        bio TEXT,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        is_active BOOLEAN DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        entry_date TEXT NOT NULL,
        free_reflection TEXT NOT NULL,
        mood_score INTEGER DEFAULT 5,
        energy_level INTEGER DEFAULT 5,
        stress_level INTEGER DEFAULT 5,
        worth_it INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id, entry_date)
      )
    ''');

    await db.execute('''
      CREATE TABLE interactive_moments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        entry_date TEXT NOT NULL,
        emoji TEXT NOT NULL,
        text TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('positive', 'negative', 'neutral')),
        intensity INTEGER DEFAULT 5,
        category TEXT DEFAULT 'general',
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // ✅ NUEVO: Tabla user_goals agregada al esquema mínimo
    await db.execute('''
      CREATE TABLE user_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        target_value REAL NOT NULL,
        current_value REAL NOT NULL DEFAULT 0.0,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        completed_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // ✅ NUEVO: Tabla personalized_challenges agregada al esquema mínimo
    await db.execute('''
      CREATE TABLE personalized_challenges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        challenge_type TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'medium',
        target_value REAL NOT NULL,
        current_progress REAL NOT NULL DEFAULT 0.0,
        reward_points INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        completed_at INTEGER,
        expires_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    _logger.i('✅ Esquema mínimo creado para fallback');
  }

  Future<void> _createOptimizedSchema(Database db, int version) async {
    await db.transaction((txn) async {
      try {
        // TABLA USUARIOS - Optimizada para APK
        await txn.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          name TEXT NOT NULL,
          avatar_emoji TEXT DEFAULT '🧘‍♀️',
          profile_picture_path TEXT,
          bio TEXT,
          preferences TEXT DEFAULT '{}',
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
          last_login INTEGER,
          is_active BOOLEAN DEFAULT 1
        )
      ''');

        // TABLA ENTRADAS DIARIAS - CON TODAS LAS COLUMNAS NECESARIAS
        await txn.execute('''
        CREATE TABLE daily_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          entry_date TEXT NOT NULL,
          free_reflection TEXT NOT NULL,

          -- Métricas básicas
          mood_score INTEGER DEFAULT 5 CHECK (mood_score >= 1 AND mood_score <= 10),
          energy_level INTEGER DEFAULT 5 CHECK (energy_level >= 1 AND energy_level <= 10),
          stress_level INTEGER DEFAULT 5 CHECK (stress_level >= 1 AND stress_level <= 10),
          worth_it INTEGER DEFAULT 1 CHECK (worth_it IN (0, 1)),

          -- Campos de AI y análisis
          overall_sentiment TEXT,
          ai_summary TEXT,
          word_count INTEGER DEFAULT 0,

          -- Métricas avanzadas de bienestar
          sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 10),
          anxiety_level INTEGER CHECK (anxiety_level >= 1 AND anxiety_level <= 10),
          motivation_level INTEGER CHECK (motivation_level >= 1 AND motivation_level <= 10),
          social_interaction INTEGER CHECK (social_interaction >= 1 AND social_interaction <= 10),
          physical_activity INTEGER CHECK (physical_activity >= 1 AND physical_activity <= 10),
          work_productivity INTEGER CHECK (work_productivity >= 1 AND work_productivity <= 10),

          -- Métricas cuantitativas
          sleep_hours REAL CHECK (sleep_hours >= 0 AND sleep_hours <= 24),
          water_intake INTEGER CHECK (water_intake >= 0 AND water_intake <= 20),
          meditation_minutes INTEGER CHECK (meditation_minutes >= 0 AND meditation_minutes <= 600),
          exercise_minutes INTEGER CHECK (exercise_minutes >= 0 AND exercise_minutes <= 600),
          screen_time_hours REAL CHECK (screen_time_hours >= 0 AND screen_time_hours <= 24),

          -- Métricas adicionales
          weather_mood_impact INTEGER CHECK (weather_mood_impact >= -5 AND weather_mood_impact <= 5),
          social_battery INTEGER CHECK (social_battery >= 1 AND social_battery <= 10),
          creative_energy INTEGER CHECK (creative_energy >= 1 AND creative_energy <= 10),
          emotional_stability INTEGER CHECK (emotional_stability >= 1 AND emotional_stability <= 10),
          focus_level INTEGER CHECK (focus_level >= 1 AND focus_level <= 10),
          life_satisfaction INTEGER CHECK (life_satisfaction >= 1 AND life_satisfaction <= 10),

          -- Campos de texto
          gratitude_items TEXT,
          positive_tags TEXT DEFAULT '[]',
          negative_tags TEXT DEFAULT '[]',

          -- Timestamps
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
          updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),

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

            timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),

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
            last_used INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),

            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(user_id, name, type)
          )
        ''');

        // ✅ NUEVA TABLA: USER_GOALS - Agregada al esquema optimizado
        await txn.execute('''
          CREATE TABLE user_goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            type TEXT NOT NULL CHECK (type IN ('consistency', 'mood', 'positiveMoments', 'stressReduction')),
            status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused', 'cancelled')),
            target_value REAL NOT NULL CHECK (target_value > 0),
            current_value REAL NOT NULL DEFAULT 0.0 CHECK (current_value >= 0),

            -- Timestamps
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            completed_at INTEGER,

            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // ✅ NUEVA TABLA: PERSONALIZED_CHALLENGES - Para los desafíos personalizados
        await txn.execute('''
          CREATE TABLE personalized_challenges (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            challenge_type TEXT NOT NULL CHECK (challenge_type IN ('streak', 'mood_average', 'moments', 'consistency', 'stress_reduction')),
            difficulty TEXT NOT NULL DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),
            target_value REAL NOT NULL CHECK (target_value > 0),
            current_progress REAL NOT NULL DEFAULT 0.0 CHECK (current_progress >= 0),
            reward_points INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
            
            -- Timestamps
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            completed_at INTEGER,
            expires_at INTEGER,

            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        await _createOptimizedIndexes(txn);

        _logger.i('✅ Esquema optimizado creado exitosamente para APK');
      } catch (e) {
        _logger.e('❌ Error creando esquema: $e');
        rethrow;
      }
    });
  }

  Future<void> _createOptimizedIndexes(Transaction txn) async {
    // Índices para usuarios
    await txn.execute('CREATE INDEX idx_users_email ON users (email)');
    await txn.execute(
        'CREATE INDEX idx_users_active ON users (is_active, last_login)');

    // Índices para entradas diarias
    await txn.execute(
        'CREATE INDEX idx_daily_entries_user_date ON daily_entries (user_id, entry_date)');
    await txn.execute(
        'CREATE INDEX idx_daily_entries_created ON daily_entries (created_at DESC)');
    await txn.execute(
        'CREATE INDEX idx_daily_entries_mood ON daily_entries (user_id, mood_score, entry_date)');

    // Índices para momentos
    await txn.execute(
        'CREATE INDEX idx_moments_user_date ON interactive_moments (user_id, entry_date)');
    await txn.execute(
        'CREATE INDEX idx_moments_type ON interactive_moments (user_id, type, timestamp)');
    await txn.execute(
        'CREATE INDEX idx_moments_category ON interactive_moments (user_id, category)');
    await txn.execute(
        'CREATE INDEX idx_moments_timeline ON interactive_moments (user_id, timestamp DESC)');

    // Índices para tags
    await txn.execute(
        'CREATE INDEX idx_tags_user_type ON tags (user_id, type)');
    await txn.execute(
        'CREATE INDEX idx_tags_usage ON tags (usage_count DESC, last_used DESC)');

    // Índices para goals
    await txn.execute(
        'CREATE INDEX idx_user_goals_user_status ON user_goals (user_id, status)');
    await txn.execute(
        'CREATE INDEX idx_user_goals_created ON user_goals (created_at DESC)');

    // Índices para personalized_challenges
    await txn.execute(
        'CREATE INDEX idx_challenges_user_active ON personalized_challenges (user_id, is_active)');
    await txn.execute(
        'CREATE INDEX idx_challenges_type ON personalized_challenges (user_id, challenge_type)');
    await txn.execute(
        'CREATE INDEX idx_challenges_difficulty ON personalized_challenges (difficulty, reward_points DESC)');
  }

  Future<void> _upgradeSchema(Database db, int oldVersion,
      int newVersion) async {
    _logger.i('🔄 Actualizando esquema desde v$oldVersion a v$newVersion');

    try {
      if (oldVersion < 2) {
        await _migrateToV2(db);
      }
    } catch (e) {
      _logger.e('❌ Error en migración: $e');
      // En APK, mejor recrear la BD si hay errores críticos
    }
  }


  Future<void> _migrateToV2(Database db) async {
    // ✅ Migración para agregar tabla user_goals si no existe
    try {
      // Verificar si la tabla user_goals ya existe
      final result = await db.rawQuery('''
        SELECT name FROM sqlite_master
        WHERE type='table' AND name='user_goals'
      ''');

      if (result.isEmpty) {
        _logger.i('📦 Agregando tabla user_goals en migración v2');

        await db.execute('''
          CREATE TABLE user_goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            type TEXT NOT NULL CHECK (type IN ('consistency', 'mood', 'positiveMoments', 'stressReduction')),
            status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused', 'cancelled')),
            target_value REAL NOT NULL CHECK (target_value > 0),
            current_value REAL NOT NULL DEFAULT 0.0 CHECK (current_value >= 0),
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            completed_at INTEGER,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // Crear índices para user_goals
        await db.execute('CREATE INDEX idx_user_goals_user_status ON user_goals (user_id, status)');
        await db.execute('CREATE INDEX idx_user_goals_created ON user_goals (user_id, created_at DESC)');
        await db.execute('CREATE INDEX idx_user_goals_type ON user_goals (user_id, type)');
        await db.execute('CREATE INDEX idx_user_goals_progress ON user_goals (user_id, status, current_value, target_value)');

        _logger.i('✅ Tabla user_goals agregada exitosamente');
      }
    } catch (e) {
      _logger.e('❌ Error en migración v2: $e');
    }

    _logger.i('📦 Migración a v2 completada');
  }

  // ============================================================================
  // MÉTODOS OPTIMIZADOS PARA USUARIOS
  // ============================================================================

  /// **MÉTODO CORREGIDO**
  /// Crea un nuevo usuario solo si el email no existe previamente.
  Future<OptimizedUserModel?> createUser({
    required String email,
    required String password,
    required String name,
    String avatarEmoji = '🧘‍♀️',
    String? profilePicturePath,
    String bio = '',
  }) async {
    try {
      final db = await database;
      final normalizedEmail = email.toLowerCase().trim();

      // ✅ **PASO 1: VERIFICAR SI EL USUARIO YA EXISTE**
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [normalizedEmail],
        limit: 1,
      );

      // Si la lista no está vacía, el usuario ya existe.
      if (existingUser.isNotEmpty) {
        _logger.w('⚠️ Intento de crear un usuario duplicado con el email: $normalizedEmail');
        // Retorna null para indicar que la creación falló por duplicado.
        return null;
      }

      // Si no existe, procede con la inserción.
      final passwordHash = _hashPassword(password);

      final userId = await db.insert('users', {
        'email': normalizedEmail,
        'password_hash': passwordHash,
        'name': name.trim(),
        'avatar_emoji': avatarEmoji,
        'profile_picture_path': profilePicturePath,
        'bio': bio,
      });

      _logger.i('✨ Usuario creado exitosamente: $name (ID: $userId)');

      return OptimizedUserModel(
        id: userId,
        email: email,
        name: name,
        avatarEmoji: avatarEmoji,
        profilePicturePath: profilePicturePath,
        bio: bio,
        createdAt: DateTime.now(),
        lastLogin: null,
      );
    } catch (e) {
      // El catch general ahora manejará otros errores inesperados.
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

      return OptimizedUserModel.fromDatabase(userData);
    } catch (e) {
      _logger.e('❌ Error en autenticación: $e');
      return null;
    }
  }
  Future<bool> updateUserProfile({
    required int userId,
    String? name,
    String? bio,
    String? avatarEmoji,
    String? profilePicturePath,
  }) async {
    try {
      final db = await database;
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name.trim();
      if (bio != null) updates['bio'] = bio;
      if (avatarEmoji != null) updates['avatar_emoji'] = avatarEmoji;
      if (profilePicturePath != null) {
        updates['profile_picture_path'] = profilePicturePath;
      }

      if (updates.isEmpty) return true;

      final rowsAffected = await db.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );

      _logger.i('✅ Perfil actualizado para usuario ID: $userId');
      return rowsAffected > 0;
    } catch (e) {
      _logger.e('❌ Error actualizando perfil: $e');
      return false;
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

      return results.map((row) => OptimizedInteractiveMomentModel.fromDatabase(row)).toList();
    } catch (e) {
      _logger.e('❌ Error obteniendo momentos: $e');
      return [];
    }
  }

  // ============================================================================
  // ANÁLISIS Y ESTADÍSTICAS OPTIMIZADAS PARA APK
  // ============================================================================

  Future<Map<String, dynamic>> getUserAnalytics(int userId, {int days = 30}) async {
    try {
      final db = await database;
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      // Análisis básico optimizado para APK
      final basicStats = await _getBasicStats(db, userId, startDate, endDate);
      final moodTrends = await _getMoodTrends(db, userId, startDate, endDate);
      final momentStats = await _getMomentStats(db, userId, startDate, endDate);
      final streakData = await _getStreakData(db, userId);

      return {
        'basic_stats': basicStats,
        'mood_trends': moodTrends,
        'moment_stats': momentStats,
        'streak_data': streakData,
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

  Map<String, dynamic> _calculateStreaks(List<String> dateStrings) {
    if (dateStrings.isEmpty) {
      return {'current_streak': 0, 'longest_streak': 0};
    }

    // 1. Parse and sort dates in descending order (most recent first)
    final dates = dateStrings.map((d) => DateTime.parse(d)).toList();
    dates.sort((a, b) => b.compareTo(a));

    int currentStreak = 0;
    int longestStreak = 0;

    // 2. Check if the most recent entry is today or yesterday
    final today = DateTime.now();
    final mostRecentDate = dates.first;
    if (DateUtils.isSameDay(mostRecentDate, today) ||
        DateUtils.isSameDay(mostRecentDate, today.subtract(const Duration(days: 1)))) {
      currentStreak = 1;
    }

    // 3. Iterate to calculate streaks
    int tempStreak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final date = dates[i];
      final prevDate = dates[i + 1];

      if (DateUtils.isSameDay(date, prevDate.add(const Duration(days: 1)))) {
        // Dates are consecutive
        tempStreak++;
      } else {
        // Gap found, streak is broken
        longestStreak = math.max(longestStreak, tempStreak);
        tempStreak = 1; // Reset for the next potential streak
      }
    }

    // 4. Final check for the longest streak
    longestStreak = math.max(longestStreak, tempStreak);

    // 5. If the most recent streak is not the current one, reset currentStreak
    if (currentStreak == 0) {
      // No entry today or yesterday, so current streak is 0
    } else {
      // The current streak is the last one calculated
      currentStreak = tempStreak;
    }

    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }
  // ============================================================================
  // 🚀 MÉTODOS DE ANALYTICS AVANZADOS
  // ============================================================================

  /// Obtener datos para predicción de bienestar basada en patrones
  Future<Map<String, dynamic>> getWellbeingPredictionData(int userId, {int days = 30}) async {
    try {
      final db = await database;

      // Obtener tendencias de mood de los últimos días
      final moodTrends = await db.rawQuery('''
        SELECT
          entry_date,
          mood_score,
          energy_level,
          stress_level,
          sleep_quality,
          physical_activity,
          JULIANDAY(entry_date) as day_number
        FROM daily_entries
        WHERE user_id = ?
          AND entry_date >= date('now', '-$days days')
        ORDER BY entry_date DESC
      ''', [userId]);

      if (moodTrends.isEmpty) {
        return {
          'has_data': false,
          'trend_direction': 0.0,
          'confidence': 0.0,
          'predicted_score': 5.0,
          'pattern_strength': 0.0,
        };
      }

      // Calcular tendencia usando regresión lineal simple
      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
      int n = moodTrends.length;

      for (int i = 0; i < n; i++) {
        final x = i.toDouble(); // Día (índice)
        final y = (moodTrends[i]['mood_score'] as int? ?? 5).toDouble();

        sumX += x;
        sumY += y;
        sumXY += x * y;
        sumX2 += x * x;
      }

      // Calcular pendiente de la línea de tendencia
      final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
      final intercept = (sumY - slope * sumX) / n;

      // Predicción para el siguiente día
      final nextDay = n.toDouble();
      final predictedScore = (slope * nextDay + intercept).clamp(1.0, 10.0);

      // Calcular confianza basada en consistencia de datos
      final consistency = _calculateDataConsistency(moodTrends);
      final confidence = (consistency * (n / 30.0)).clamp(0.0, 1.0);

      return {
        'has_data': true,
        'trend_direction': slope,
        'confidence': confidence,
        'predicted_score': predictedScore,
        'pattern_strength': math.cos(slope),
        'data_points': n,
        'recent_average': sumY / n,
      };

    } catch (e) {
      _logger.e('❌ Error obteniendo predicción de bienestar: $e');
      return {
        'has_data': false,
        'trend_direction': 0.0,
        'confidence': 0.0,
        'predicted_score': 5.0,
        'pattern_strength': 0.0,
      };
    }
  }

  /// Calcular consistencia de datos para determinar confianza en predicciones
  double _calculateDataConsistency(List<Map<String, dynamic>> data) {
    if (data.length < 2) return 0.0;

    final values = data.map((e) => (e['mood_score'] as int? ?? 5).toDouble()).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;

    // Calcular desviación estándar
    final variance = values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    final stdDev = math.sqrt(variance);

    // Consistencia inversa a la variabilidad (normalizada)
    return (1.0 - (stdDev / 5.0)).clamp(0.0, 1.0);
  }

  /// Obtener análisis detallado de hábitos saludables
  Future<Map<String, dynamic>> getHealthyHabitsAnalysis(int userId, {int days = 30}) async {
    try {
      final db = await database;

      final habitsData = await db.rawQuery('''
        SELECT
          AVG(CAST(sleep_quality as REAL)) as avg_sleep_quality,
          AVG(CAST(sleep_hours as REAL)) as avg_sleep_hours,
          AVG(CAST(physical_activity as REAL)) as avg_physical_activity,
          AVG(CAST(exercise_minutes as REAL)) as avg_exercise_minutes,
          AVG(CAST(meditation_minutes as REAL)) as avg_meditation_minutes,
          AVG(CAST(social_interaction as REAL)) as avg_social_interaction,
          AVG(CAST(water_intake as REAL)) as avg_water_intake,
          AVG(CAST(screen_time_hours as REAL)) as avg_screen_time,
          COUNT(*) as total_entries
        FROM daily_entries
        WHERE user_id = ?
          AND entry_date >= date('now', '-$days days')
          AND (sleep_quality IS NOT NULL
               OR physical_activity IS NOT NULL
               OR meditation_minutes IS NOT NULL
               OR social_interaction IS NOT NULL)
      ''', [userId]);

      if (habitsData.isEmpty || habitsData.first['total_entries'] == 0) {
        return _getDefaultHabitsAnalysis();
      }

      final data = habitsData.first;

      // Normalizar puntuaciones a escala 0-1
      final sleepScore = _normalizeHabitScore(data['avg_sleep_quality'] as double? ?? 5.0, 10.0);
      final exerciseScore = _normalizeHabitScore(data['avg_physical_activity'] as double? ?? 5.0, 10.0);
      final meditationScore = _normalizeHabitScore(data['avg_meditation_minutes'] as double? ?? 0.0, 30.0);
      final socialScore = _normalizeHabitScore(data['avg_social_interaction'] as double? ?? 5.0, 10.0);

      // Calcular puntuaciones de hábitos específicos
      final sleepHoursScore = _calculateSleepHoursScore(data['avg_sleep_hours'] as double? ?? 7.0);
      final exerciseMinutesScore = _calculateExerciseScore(data['avg_exercise_minutes'] as double? ?? 0.0);
      final hydrationScore = _calculateHydrationScore(data['avg_water_intake'] as double? ?? 6.0);
      final screenTimeScore = _calculateScreenTimeScore(data['avg_screen_time_hours'] as double? ?? 6.0);

      // Puntuación general de hábitos
      final overallScore = (sleepScore + exerciseScore + meditationScore + socialScore +
          sleepHoursScore + exerciseMinutesScore + hydrationScore + screenTimeScore) / 8.0;

      // Generar recomendaciones basadas en los datos
      final recommendations = _generateHabitsRecommendations({
        'sleep': sleepScore,
        'exercise': exerciseScore,
        'meditation': meditationScore,
        'social': socialScore,
        'hydration': hydrationScore,
        'screen_time': screenTimeScore,
      });

      return {
        'sleep_score': sleepScore,
        'exercise_score': exerciseScore,
        'meditation_score': meditationScore,
        'social_score': socialScore,
        'hydration_score': hydrationScore,
        'screen_time_score': screenTimeScore,
        'sleep_hours_score': sleepHoursScore,
        'exercise_minutes_score': exerciseMinutesScore,
        'overall_score': overallScore,
        'recommendations': recommendations,
        'data_quality': (data['total_entries'] as int? ?? 0) / days.toDouble(),
        'raw_data': {
          'avg_sleep_quality': data['avg_sleep_quality'],
          'avg_sleep_hours': data['avg_sleep_hours'],
          'avg_physical_activity': data['avg_physical_activity'],
          'avg_exercise_minutes': data['avg_exercise_minutes'],
          'avg_meditation_minutes': data['avg_meditation_minutes'],
          'avg_social_interaction': data['avg_social_interaction'],
          'avg_water_intake': data['avg_water_intake'],
          'avg_screen_time': data['avg_screen_time_hours'],
        },
      };

    } catch (e) {
      _logger.e('❌ Error obteniendo análisis de hábitos: $e');
      return _getDefaultHabitsAnalysis();
    }
  }

  /// Normalizar puntuación de hábito a escala 0-1
  double _normalizeHabitScore(double value, double maxValue) {
    return (value / maxValue).clamp(0.0, 1.0);
  }

  /// Calcular puntuación de horas de sueño (óptimo: 7-9 horas)
  double _calculateSleepHoursScore(double hours) {
    if (hours >= 7.0 && hours <= 9.0) return 1.0;
    if (hours >= 6.0 && hours <= 10.0) return 0.8;
    if (hours >= 5.0 && hours <= 11.0) return 0.6;
    return 0.3;
  }

  /// Calcular puntuación de ejercicio (objetivo: 30+ minutos)
  double _calculateExerciseScore(double minutes) {
    if (minutes >= 30.0) return 1.0;
    if (minutes >= 20.0) return 0.8;
    if (minutes >= 10.0) return 0.6;
    if (minutes > 0.0) return 0.4;
    return 0.0;
  }

  /// Calcular puntuación de hidratación (objetivo: 8+ vasos)
  double _calculateHydrationScore(double glasses) {
    if (glasses >= 8.0) return 1.0;
    if (glasses >= 6.0) return 0.8;
    if (glasses >= 4.0) return 0.6;
    if (glasses >= 2.0) return 0.4;
    return 0.2;
  }

  /// Calcular puntuación de tiempo de pantalla (menos es mejor)
  double _calculateScreenTimeScore(double hours) {
    if (hours <= 2.0) return 1.0;
    if (hours <= 4.0) return 0.8;
    if (hours <= 6.0) return 0.6;
    if (hours <= 8.0) return 0.4;
    return 0.2;
  }

  /// Generar recomendaciones basadas en hábitos
  List<String> _generateHabitsRecommendations(Map<String, double> scores) {
    final recommendations = <String>[];

    if (scores['sleep']! < 0.6) {
      recommendations.add('Mejora tu calidad de sueño con una rutina nocturna');
    }
    if (scores['exercise']! < 0.6) {
      recommendations.add('Incrementa tu actividad física diaria');
    }
    if (scores['meditation']! < 0.3) {
      recommendations.add('Prueba la meditación para reducir el estrés');
    }
    if (scores['social']! < 0.6) {
      recommendations.add('Dedica más tiempo a las conexiones sociales');
    }
    if (scores['hydration']! < 0.6) {
      recommendations.add('Aumenta tu ingesta de agua diaria');
    }
    if (scores['screen_time']! < 0.6) {
      recommendations.add('Reduce el tiempo de pantalla para mejor bienestar');
    }

    if (recommendations.isEmpty) {
      recommendations.add('¡Excelente! Mantén tus hábitos saludables actuales');
    }

    return recommendations;
  }

  /// Datos por defecto cuando no hay información suficiente
  Map<String, dynamic> _getDefaultHabitsAnalysis() {
    return {
      'sleep_score': 0.5,
      'exercise_score': 0.5,
      'meditation_score': 0.0,
      'social_score': 0.5,
      'hydration_score': 0.5,
      'screen_time_score': 0.5,
      'sleep_hours_score': 0.5,
      'exercise_minutes_score': 0.0,
      'overall_score': 0.4,
      'recommendations': ['Registra más días para obtener análisis personalizado'],
      'data_quality': 0.0,
    };
  }

  /// Obtener comparación semanal detallada
  Future<Map<String, dynamic>> getWeeklyComparison(int userId) async {
    try {
      final db = await database;

      // Obtener datos de las últimas 2 semanas
      final weeklyData = await db.rawQuery('''
        SELECT
          entry_date,
          mood_score,
          energy_level,
          stress_level,
          sleep_quality,
          physical_activity,
          CASE
            WHEN entry_date >= date('now', '-7 days') THEN 'current'
            ELSE 'previous'
          END as week_period
        FROM daily_entries
        WHERE user_id = ?
          AND entry_date >= date('now', '-14 days')
        ORDER BY entry_date DESC
      ''', [userId]);

      if (weeklyData.length < 7) {
        return {
          'has_data': false,
          'message': 'Necesitas al menos una semana de datos para comparar',
          'current_week_entries': weeklyData.where((e) => e['week_period'] == 'current').length,
          'previous_week_entries': weeklyData.where((e) => e['week_period'] == 'previous').length,
        };
      }

      final currentWeek = weeklyData.where((e) => e['week_period'] == 'current').toList();
      final previousWeek = weeklyData.where((e) => e['week_period'] == 'previous').toList();

      if (currentWeek.isEmpty || previousWeek.isEmpty) {
        return {'has_data': false, 'message': 'Datos insuficientes para comparación'};
      }

      // Calcular promedios para cada semana
      final currentAvg = _calculateWeekAverages(currentWeek);
      final previousAvg = _calculateWeekAverages(previousWeek);

      // Calcular cambios
      final changes = {
        'mood_change': currentAvg['mood']! - previousAvg['mood']!,
        'energy_change': currentAvg['energy']! - previousAvg['energy']!,
        'stress_change': currentAvg['stress']! - previousAvg['stress']!,
        'sleep_change': currentAvg['sleep']! - previousAvg['sleep']!,
        'exercise_change': currentAvg['exercise']! - previousAvg['exercise']!,
      };

      // Determinar tendencia general
      final positiveChanges = changes.values.where((change) => change > 0.5).length;
      final negativeChanges = changes.values.where((change) => change < -0.5).length;

      String overallTrend;
      if (positiveChanges > negativeChanges) {
        overallTrend = 'improving';
      } else if (negativeChanges > positiveChanges) {
        overallTrend = 'declining';
      } else {
        overallTrend = 'stable';
      }

      return {
        'has_data': true,
        'current_week': currentAvg,
        'previous_week': previousAvg,
        'changes': changes,
        'overall_trend': overallTrend,
        'improvement_areas': _getImprovementAreas(changes),
        'current_week_entries': currentWeek.length,
        'previous_week_entries': previousWeek.length,
      };

    } catch (e) {
      _logger.e('❌ Error obteniendo comparación semanal: $e');
      return {'has_data': false, 'message': 'Error al obtener datos de comparación'};
    }
  }

  /// Calcular promedios de una semana
  Map<String, double> _calculateWeekAverages(List<Map<String, dynamic>> weekData) {
    if (weekData.isEmpty) {
      return {
        'mood': 5.0,
        'energy': 5.0,
        'stress': 5.0,
        'sleep': 5.0,
        'exercise': 5.0,
      };
    }

    final mood = weekData.map((e) => (e['mood_score'] as int? ?? 5).toDouble()).reduce((a, b) => a + b) / weekData.length;
    final energy = weekData.map((e) => (e['energy_level'] as int? ?? 5).toDouble()).reduce((a, b) => a + b) / weekData.length;
    final stress = weekData.map((e) => (e['stress_level'] as int? ?? 5).toDouble()).reduce((a, b) => a + b) / weekData.length;
    final sleep = weekData.map((e) => (e['sleep_quality'] as int? ?? 5).toDouble()).reduce((a, b) => a + b) / weekData.length;
    final exercise = weekData.map((e) => (e['physical_activity'] as int? ?? 5).toDouble()).reduce((a, b) => a + b) / weekData.length;

    return {
      'mood': mood,
      'energy': energy,
      'stress': stress,
      'sleep': sleep,
      'exercise': exercise,
    };
  }

  /// Identificar áreas de mejora basadas en cambios
  List<String> _getImprovementAreas(Map<String, double> changes) {
    final areas = <String>[];

    if (changes['mood_change']! < -0.5) areas.add('Estado de ánimo');
    if (changes['energy_change']! < -0.5) areas.add('Niveles de energía');
    if (changes['stress_change']! > 0.5) areas.add('Manejo del estrés');
    if (changes['sleep_change']! < -0.5) areas.add('Calidad del sueño');
    if (changes['exercise_change']! < -0.5) areas.add('Actividad física');

    return areas;
  }

  /// Obtener calendario de estados de ánimo para visualización
  Future<List<Map<String, dynamic>>> getMoodCalendarData(int userId, {int days = 30}) async {
    try {
      final db = await database;

      final calendarData = await db.rawQuery('''
        SELECT
          entry_date,
          mood_score,
          energy_level,
          stress_level,
          (CAST(mood_score as REAL) + CAST(energy_level as REAL) + (10 - CAST(stress_level as REAL))) / 3.0 as avg_score
        FROM daily_entries
        WHERE user_id = ?
          AND entry_date >= date('now', '-$days days')
        ORDER BY entry_date DESC
      ''', [userId]);

      return calendarData.map((day) {
        final date = DateTime.parse(day['entry_date'] as String);
        final avgScore = day['avg_score'] as double? ?? 5.0;

        String emoji;
        Color color;

        if (avgScore >= 7) {
          emoji = '😊';
          color = Colors.green;
        } else if (avgScore >= 5) {
          emoji = '😐';
          color = Colors.blue;
        } else {
          emoji = '😔';
          color = Colors.orange;
        }

        return {
          'date': date,
          'mood': day['mood_score'],
          'energy': day['energy_level'],
          'stress': day['stress_level'],
          'avg_score': avgScore,
          'emoji': emoji,
          'color': color,
        };
      }).toList();

    } catch (e) {
      _logger.e('❌ Error obteniendo datos del calendario: $e');
      return [];
    }
  }

  /// Obtener recomendaciones personalizadas basadas en patrones del usuario
  Future<List<Map<String, dynamic>>> getPersonalizedRecommendations(int userId) async {
    try {
      final db = await database;

      // Obtener análisis de las últimas 2 semanas
      final recentAnalysis = await db.rawQuery('''
        SELECT
          AVG(CAST(mood_score as REAL)) as avg_mood,
          AVG(CAST(energy_level as REAL)) as avg_energy,
          AVG(CAST(stress_level as REAL)) as avg_stress,
          AVG(CAST(sleep_quality as REAL)) as avg_sleep,
          AVG(CAST(physical_activity as REAL)) as avg_exercise,
          AVG(CAST(meditation_minutes as REAL)) as avg_meditation,
          AVG(CAST(social_interaction as REAL)) as avg_social,
          COUNT(*) as total_entries,
          COUNT(CASE WHEN mood_score >= 7 THEN 1 END) as good_mood_days,
          COUNT(CASE WHEN stress_level >= 7 THEN 1 END) as high_stress_days
        FROM daily_entries
        WHERE user_id = ?
          AND entry_date >= date('now', '-14 days')
      ''', [userId]);

      if (recentAnalysis.isEmpty) {
        return _getDefaultRecommendations();
      }

      final analysis = recentAnalysis.first;
      final recommendations = <Map<String, dynamic>>[];

      final avgMood = analysis['avg_mood'] as double? ?? 5.0;
      final avgStress = analysis['avg_stress'] as double? ?? 5.0;
      final avgSleep = analysis['avg_sleep'] as double? ?? 5.0;
      final avgExercise = analysis['avg_exercise'] as double? ?? 5.0;
      final avgMeditation = analysis['avg_meditation'] as double? ?? 0.0;
      final avgSocial = analysis['avg_social'] as double? ?? 5.0;
      final highStressDays = analysis['high_stress_days'] as int? ?? 0;

      // Recomendaciones basadas en estrés
      if (avgStress >= 7.0 || highStressDays >= 3) {
        recommendations.add({
          'icon': '🧘‍♀️',
          'title': 'Sesión de Mindfulness',
          'description': 'Tu nivel de estrés ha estado alto. Prueba 10 minutos de meditación',
          'type': 'stress_relief',
          'priority': 'high',
          'action': 'meditate',
          'estimated_time': '10 min',
          'urgency_score': 9,
        });
      }

      // Recomendaciones basadas en estado de ánimo
      if (avgMood < 5.0) {
        recommendations.add({
          'icon': '🌱',
          'title': 'Práctica de Gratitud',
          'description': 'Reflexiona sobre 3 cosas positivas de tu día para mejorar tu ánimo',
          'type': 'mood_boost',
          'priority': 'medium',
          'action': 'gratitude',
          'estimated_time': '5 min',
          'urgency_score': 7,
        });
      }

      // Recomendaciones basadas en sueño
      if (avgSleep < 6.0) {
        recommendations.add({
          'icon': '😴',
          'title': 'Higiene del Sueño',
          'description': 'Tu calidad de sueño puede mejorar. Establece una rutina nocturna',
          'type': 'sleep',
          'priority': 'medium',
          'action': 'plan_sleep',
          'estimated_time': '5 min',
          'urgency_score': 6,
        });
      }

      // Recomendaciones basadas en ejercicio
      if (avgExercise < 5.0) {
        recommendations.add({
          'icon': '🏃‍♀️',
          'title': 'Actividad Física',
          'description': 'Una caminata de 15 minutos puede aumentar tu energía y mejorar tu ánimo',
          'type': 'exercise',
          'priority': 'low',
          'action': 'walk',
          'estimated_time': '15 min',
          'urgency_score': 4,
        });
      }

      // Recomendaciones basadas en meditación
      if (avgMeditation < 5.0) {
        recommendations.add({
          'icon': '🎯',
          'title': 'Mindfulness Diario',
          'description': 'Incorpora 5 minutos de meditación a tu rutina diaria',
          'type': 'mindfulness',
          'priority': 'low',
          'action': 'start_meditation_habit',
          'estimated_time': '5 min',
          'urgency_score': 3,
        });
      }

      // Recomendaciones sociales
      if (avgSocial < 5.0) {
        recommendations.add({
          'icon': '👥',
          'title': 'Conexión Social',
          'description': 'Contacta con un amigo o familiar para fortalecer tus vínculos',
          'type': 'social',
          'priority': 'low',
          'action': 'connect',
          'estimated_time': '10 min',
          'urgency_score': 2,
        });
      }

      // Ordenar por urgencia y limitar a las top 3
      recommendations.sort((a, b) => (b['urgency_score'] as int).compareTo(a['urgency_score'] as int));

      return recommendations.take(3).toList();

    } catch (e) {
      _logger.e('❌ Error obteniendo recomendaciones: $e');
      return _getDefaultRecommendations();
    }
  }

  /// Recomendaciones por defecto cuando no hay datos suficientes
  List<Map<String, dynamic>> _getDefaultRecommendations() {
    return [
      {
        'icon': '📝',
        'title': 'Comienza tu registro',
        'description': 'Registra tu estado de ánimo para obtener recomendaciones personalizadas',
        'type': 'onboarding',
        'priority': 'medium',
        'action': 'start_entry',
        'estimated_time': '2 min',
        'urgency_score': 5,
      },
    ];
  }

  /// Obtener challenges personalizados basados en el progreso del usuario
  Future<List<Map<String, dynamic>>> getPersonalizedChallenges(int userId) async {
    try {
      final db = await database;

      // Obtener estadísticas del usuario
      final userStats = await db.rawQuery('''
        SELECT
          COUNT(*) as total_entries,
          COUNT(CASE WHEN entry_date >= date('now', '-7 days') THEN 1 END) as week_entries,
          AVG(CAST(meditation_minutes as REAL)) as avg_meditation,
          AVG(CAST(physical_activity as REAL)) as avg_exercise,
          AVG(CAST(sleep_quality as REAL)) as avg_sleep
        FROM daily_entries
        WHERE user_id = ?
      ''', [userId]);

      // Obtener racha actual
      final streakData = await getUserStreakData(userId);

      if (userStats.isEmpty) {
        return _getDefaultChallenges();
      }

      final stats = userStats.first;
      final challenges = <Map<String, dynamic>>[];
      final currentStreak = streakData['current_streak'] as int? ?? 0;
      final weekEntries = stats['week_entries'] as int? ?? 0;
      final avgMeditation = stats['avg_meditation'] as double? ?? 0.0;
      final avgExercise = stats['avg_exercise'] as double? ?? 0.0;

      // Challenge de racha diaria
      if (currentStreak < 7) {
        challenges.add({
          'id': 'weekly_streak',
          'title': 'Racha Semanal',
          'description': 'Completa 7 días seguidos registrando tu bienestar',
          'icon': '🔥',
          'progress': currentStreak / 7.0,
          'target': 7,
          'current': currentStreak,
          'type': 'streak',
          'reward': '¡Insignia de Constancia!',
          'priority': 'high',
        });
      } else if (currentStreak < 30) {
        challenges.add({
          'id': 'monthly_streak',
          'title': 'Racha del Mes',
          'description': 'Alcanza 30 días consecutivos de registro',
          'icon': '🏆',
          'progress': currentStreak / 30.0,
          'target': 30,
          'current': currentStreak,
          'type': 'streak',
          'reward': '¡Maestro de la Consistencia!',
          'priority': 'medium',
        });
      }

      // Challenge de meditación
      if (avgMeditation < 10.0) {
        challenges.add({
          'id': 'meditation_week',
          'title': 'Semana Mindful',
          'description': 'Medita al menos 10 minutos por 5 días esta semana',
          'icon': '🧘‍♀️',
          'progress': (avgMeditation / 10.0).clamp(0.0, 1.0),
          'target': 5,
          'current': (avgMeditation >= 10.0 ? weekEntries : 0),
          'type': 'meditation',
          'reward': '¡Guru del Mindfulness!',
          'priority': 'medium',
        });
      }

      // Challenge de ejercicio
      if (avgExercise < 7.0) {
        challenges.add({
          'id': 'active_week',
          'title': 'Semana Activa',
          'description': 'Mantén un nivel de actividad física alto por 4 días',
          'icon': '💪',
          'progress': (weekEntries > 0 ? math.min(weekEntries / 4.0, 1.0) : 0.0),
          'target': 4,
          'current': weekEntries,
          'type': 'exercise',
          'reward': '¡Campeón del Fitness!',
          'priority': 'low',
        });
      }

      // Challenge de bienestar general
      challenges.add({
        'id': 'wellbeing_balance',
        'title': 'Equilibrio Total',
        'description': 'Mantén todas tus métricas de bienestar balanceadas por una semana',
        'icon': '⚖️',
        'progress': 0.3, // Calcular basado en balance real
        'target': 7,
        'current': 2,
        'type': 'balance',
        'reward': '¡Maestro del Equilibrio!',
        'priority': 'high',
      });

      // Ordenar por prioridad y tomar máximo 2
      challenges.sort((a, b) {
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        return priorityOrder[a['priority']]!.compareTo(priorityOrder[b['priority']]!);
      });

      return challenges.take(2).toList();

    } catch (e) {
      _logger.e('❌ Error obteniendo challenges: $e');
      return _getDefaultChallenges();
    }
  }

  /// Challenges por defecto para nuevos usuarios
  List<Map<String, dynamic>> _getDefaultChallenges() {
    return [
      {
        'id': 'first_week',
        'title': 'Primeros Pasos',
        'description': 'Registra tu bienestar por 3 días esta semana',
        'icon': '🌱',
        'progress': 0.0,
        'target': 3,
        'current': 0,
        'type': 'beginner',
        'reward': '¡Bienvenido al bienestar!',
        'priority': 'high',
      },
    ];
  }

  /// Obtener datos de racha del usuario
  Future<Map<String, dynamic>> getUserStreakData(int userId) async {
    try {
      final db = await database;

      // Calcular racha actual
      final streakQuery = await db.rawQuery('''
        WITH RECURSIVE date_series AS (
          SELECT date('now') as check_date, 0 as days_back
          UNION ALL
          SELECT date(check_date, '-1 day'), days_back + 1
          FROM date_series
          WHERE days_back < 365
        ),
        user_entries AS (
          SELECT DISTINCT entry_date
          FROM daily_entries
          WHERE user_id = ?
        )
        SELECT COUNT(*) as current_streak
        FROM date_series ds
        LEFT JOIN user_entries ue ON ds.check_date = ue.entry_date
        WHERE ue.entry_date IS NOT NULL
        ORDER BY ds.check_date DESC
      ''', [userId]);

      final currentStreak = streakQuery.isNotEmpty ? (streakQuery.first['current_streak'] as int? ?? 0) : 0;

      // Calcular racha más larga (simplificado)
      final longestStreakQuery = await db.rawQuery('''
        SELECT COUNT(*) as longest_streak
        FROM daily_entries
        WHERE user_id = ?
      ''', [userId]);

      final longestStreak = longestStreakQuery.isNotEmpty ? (longestStreakQuery.first['longest_streak'] as int? ?? 0) : 0;

      return {
        'current_streak': currentStreak,
        'longest_streak': math.max(longestStreak, currentStreak),
      };

    } catch (e) {
      _logger.e('❌ Error obteniendo datos de racha: $e');
      return {
        'current_streak': 0,
        'longest_streak': 0,
      };
    }
  }

  // ============================================================================
  // MÉTODOS PARA DATOS DE PRUEBA - OPTIMIZADOS PARA APK
  // ============================================================================

  // ✅ MÉTODO PRINCIPAL CORREGIDO PARA APK
  Future<OptimizedUserModel?> createDeveloperAccount() async {
    try {
      final db = await database;
      _logger.i('🧪 Creando/accediendo a cuenta de desarrollador con datos avanzados...');

      // Verificar si existe la tabla personalized_challenges
      await _ensurePersonalizedChallengesTable(db);

      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['dev@reflect.com'],
      );

      int userId;
      if (existing.isNotEmpty) {
        userId = existing.first['id'] as int;
        _logger.i('🔄 Usando cuenta de desarrollador existente: $userId');
        // Regenerar datos para testing actualizado
        await generateComprehensiveTestData(userId);
      } else {
        final defaultPassword = 'devpassword123';
        final passwordHash = _hashPassword(defaultPassword);

        userId = await db.insert('users', {
          'name': 'Alex Developer',
          'email': 'dev@reflect.com',
          'password_hash': passwordHash,
          'avatar_emoji': '👨‍💻',
          'bio': 'Desarrollador explorando patrones de bienestar. Datos generados para análisis completo de casos de uso.',
          'profile_picture_path': null,
          'preferences': '{}',
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });
        _logger.i('✅ Cuenta de desarrollador creada: $userId');
        await generateComprehensiveTestData(userId);
      }

      return await getUserById(userId);

    } catch (e) {
      _logger.e('❌ Error creando cuenta desarrollador: $e');
      return null;
    }
  }

  /// Ensure personalized_challenges table exists (for existing databases)
  Future<void> _ensurePersonalizedChallengesTable(Database db) async {
    try {
      // Try to query the table to see if it exists
      await db.query('personalized_challenges', limit: 1);
      _logger.i('✅ Tabla personalized_challenges ya existe');
    } catch (e) {
      // Table doesn't exist, create it
      _logger.i('🔧 Creando tabla personalized_challenges...');
      await db.execute('''
        CREATE TABLE personalized_challenges (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          challenge_type TEXT NOT NULL,
          difficulty TEXT NOT NULL DEFAULT 'medium',
          target_value REAL NOT NULL,
          current_progress REAL NOT NULL DEFAULT 0.0,
          reward_points INTEGER DEFAULT 0,
          is_active INTEGER DEFAULT 1,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
          completed_at INTEGER,
          expires_at INTEGER,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      
      // Add indexes for the new table
      await db.execute('CREATE INDEX idx_challenges_user_active ON personalized_challenges (user_id, is_active)');
      await db.execute('CREATE INDEX idx_challenges_type ON personalized_challenges (user_id, challenge_type)');
      
      _logger.i('✅ Tabla personalized_challenges creada exitosamente');
    }
  }

  // ============================================================================
  // GENERADOR DE DATOS DE PRUEBA MEJORADO PARA ALEX DEVELOPER
  // ============================================================================

  // ✅ REEMPLAZA COMPLETAMENTE el método generateComprehensiveTestData()
// lib/data/services/optimized_database_service.dart

  // ============================================================================
  // GENERADOR DE DATOS DE PRUEBA SIMPLIFICADO PARA ALEX DEVELOPER
  // ============================================================================

  Future<void> generateComprehensiveTestData(int userId) async {
    try {
      final db = await database;
      _logger.i('📊 Generando datos AVANZADOS para Alex Developer (ID: $userId)');

      // Limpiar datos previos de forma segura
      try {
        await db.delete('daily_entries', where: 'user_id = ?', whereArgs: [userId]);
        await db.delete('interactive_moments', where: 'user_id = ?', whereArgs: [userId]);
        await db.delete('user_goals', where: 'user_id = ?', whereArgs: [userId]);
        await db.delete('personalized_challenges', where: 'user_id = ?', whereArgs: [userId]);
        _logger.i('🗑️ Datos previos limpiados');
      } catch (e) {
        _logger.w('⚠️ Error limpiando datos previos (continuando): $e');
      }

      // Generar casos de uso completos
      try {
        await _generateRealisticJourneyData(userId, db);
        _logger.i('✅ Datos de journey generados');
      } catch (e) {
        _logger.w('⚠️ Error generando journey data: $e');
      }

      try {
        await _generateAdvancedMoments(userId, db);
        _logger.i('✅ Momentos avanzados generados');
      } catch (e) {
        _logger.w('⚠️ Error generando momentos: $e');
      }

      try {
        await _generateProgressiveGoals(userId, db);
        _logger.i('✅ Objetivos progresivos generados');
      } catch (e) {
        _logger.w('⚠️ Error generando objetivos: $e');
      }

      try {
        await _generatePersonalizedChallenges(userId, db);
        _logger.i('✅ Desafíos personalizados generados');
      } catch (e) {
        _logger.w('⚠️ Error generando desafíos: $e');
      }

      try {
        await _generateMoodPatterns(userId, db);
        _logger.i('✅ Patrones de ánimo generados');
      } catch (e) {
        _logger.w('⚠️ Error generando patrones: $e');
      }

      _logger.i('✅ Datos AVANZADOS generados exitosamente - Casos de uso completos para análisis');
    } catch (e) {
      _logger.e('❌ Error generando datos avanzados: $e');
      // No hacer rethrow para no romper la creación de usuario
    }
  }

  // ============================================================================
  // ADVANCED DATA GENERATION METHODS FOR COMPREHENSIVE ANALYSIS
  // ============================================================================

  /// Generates realistic user journey data covering multiple scenarios
  Future<void> _generateRealisticJourneyData(int userId, Database db) async {
    _logger.i('🎭 Generando journey realista con múltiples escenarios...');
    
    final now = DateTime.now();
    final random = math.Random();
    
    // Generate 120 days of comprehensive data with realistic patterns
    for (int daysAgo = 120; daysAgo >= 0; daysAgo--) {
      final date = now.subtract(Duration(days: daysAgo));
      await _generateRealisticDayEntry(userId, db, date, daysAgo, random);
    }
  }

  /// Generate a realistic day entry with contextual factors
  Future<void> _generateRealisticDayEntry(int userId, Database db, DateTime date, int daysAgo, math.Random random) async {
    try {
      // Define life periods with different characteristics
      double baseMood, baseEnergy, baseStress;
      String contextualNote = '';
      
      if (daysAgo > 90) {
        // Crisis period (3+ months ago)
        baseMood = 2.5 + random.nextDouble() * 3.0; // 2.5-5.5
        baseEnergy = 2.0 + random.nextDouble() * 2.5; // 2.0-4.5
        baseStress = 7.0 + random.nextDouble() * 2.5; // 7.0-9.5
        contextualNote = _getCrisisPeriodNote(random);
      } else if (daysAgo > 60) {
        // Recovery period (2-3 months ago)
        baseMood = 4.0 + random.nextDouble() * 3.5; // 4.0-7.5
        baseEnergy = 3.5 + random.nextDouble() * 3.0; // 3.5-6.5
        baseStress = 5.5 + random.nextDouble() * 3.0; // 5.5-8.5
        contextualNote = _getRecoveryPeriodNote(random);
      } else if (daysAgo > 30) {
        // Improvement period (1-2 months ago)
        baseMood = 6.0 + random.nextDouble() * 2.5; // 6.0-8.5
        baseEnergy = 5.5 + random.nextDouble() * 3.0; // 5.5-8.5
        baseStress = 3.5 + random.nextDouble() * 4.0; // 3.5-7.5
        contextualNote = _getImprovementPeriodNote(random);
      } else {
        // Current thriving period (last month)
        baseMood = 7.0 + random.nextDouble() * 2.5; // 7.0-9.5
        baseEnergy = 6.5 + random.nextDouble() * 2.5; // 6.5-9.0
        baseStress = 2.0 + random.nextDouble() * 3.5; // 2.0-5.5
        contextualNote = _getThrivingPeriodNote(random);
      }

      // Add weekend/weekday variations
      final weekdayModifier = _getAdvancedWeekdayModifier(date.weekday, random);
      final mood = (baseMood + weekdayModifier.mood).clamp(1.0, 10.0);
      final energy = (baseEnergy + weekdayModifier.energy).clamp(1.0, 10.0);
      final stress = (baseStress + weekdayModifier.stress).clamp(1.0, 10.0);

      // Generate comprehensive reflection
      final reflection = _generateContextualReflection(mood, energy, stress, contextualNote, date, random);
      
      // Add seasonal adjustments
      final seasonalMood = _addSeasonalAdjustments(mood, date);
      
      final dateStr = date.toIso8601String().split('T')[0];
      final createdAtTimestamp = date.millisecondsSinceEpoch ~/ 1000;

      final entryData = {
        'user_id': userId,
        'entry_date': dateStr,
        'free_reflection': reflection,
        'mood_score': seasonalMood.round(),
        'energy_level': energy.round(),
        'stress_level': stress.round(),
        'worth_it': seasonalMood > 6.5 ? 1 : 0,
        'created_at': createdAtTimestamp,
      };

      await db.insert(
        'daily_entries',
        entryData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

    } catch (e) {
      _logger.e('❌ Error insertando entrada realista para fecha $date: $e');
    }
  }

  /// Generate personalized challenges based on user patterns
  Future<void> _generatePersonalizedChallenges(int userId, Database db) async {
    _logger.i('🎯 Generando desafíos personalizados...');
    
    final challenges = [
      {
        'user_id': userId,
        'title': 'Streak de Consistencia',
        'description': 'Mantén una entrada diaria por 14 días consecutivos',
        'target_value': 14,
        'current_progress': 8,
        'challenge_type': 'streak',
        'difficulty': 'medium',
        'reward_points': 100,
        'is_active': 1,
        'created_at': DateTime.now().subtract(Duration(days: 10)).millisecondsSinceEpoch ~/ 1000,
      },
      {
        'user_id': userId,
        'title': 'Maestro del Estado de Ánimo',
        'description': 'Alcanza un promedio de estado de ánimo de 8+ por 7 días',
        'target_value': 8,
        'current_progress': 6,
        'challenge_type': 'mood_average',
        'difficulty': 'hard',
        'reward_points': 150,
        'is_active': 1,
        'created_at': DateTime.now().subtract(Duration(days: 5)).millisecondsSinceEpoch ~/ 1000,
      },
      {
        'user_id': userId,
        'title': 'Coleccionista de Momentos',
        'description': 'Captura 20 momentos positivos este mes',
        'target_value': 20,
        'current_progress': 12,
        'challenge_type': 'moments',
        'difficulty': 'easy',
        'reward_points': 75,
        'is_active': 1,
        'created_at': DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch ~/ 1000,
      },
    ];

    for (final challenge in challenges) {
      await db.insert('personalized_challenges', challenge);
    }
  }

  /// Generate mood patterns for advanced analytics
  Future<void> _generateMoodPatterns(int userId, Database db) async {
    _logger.i('📊 Generando patrones de estado de ánimo...');
    
    // This method creates additional metadata for analytics
    // We'll add some weekend vs weekday patterns, seasonal patterns, etc.
    // The patterns are already embedded in the realistic journey data
  }

  /// Generate advanced moments with rich context
  Future<void> _generateAdvancedMoments(int userId, Database db) async {
    _logger.i('✨ Generando momentos avanzados...');
    
    final now = DateTime.now();
    final random = math.Random();
    
    final momentCategories = [
      {'category': 'gratitude', 'weight': 0.3},
      {'category': 'achievement', 'weight': 0.25},
      {'category': 'connection', 'weight': 0.2},
      {'category': 'growth', 'weight': 0.15},
      {'category': 'nature', 'weight': 0.1},
    ];
    
    // Generate 45 moments over the last 60 days
    for (int i = 0; i < 45; i++) {
      final daysAgo = random.nextInt(60);
      final date = now.subtract(Duration(days: daysAgo));
      
      final category = _selectWeightedCategory(momentCategories, random);
      final moment = _generateAdvancedMoment(category, date, random);
      
      await db.insert('interactive_moments', {
        'user_id': userId,
        'entry_date': date.toIso8601String().split('T')[0],
        'emoji': '✨',
        'text': '${moment['title']}: ${moment['description']}',
        'type': 'positive',
        'category': category,
        'intensity': moment['intensity'],
        'timestamp': date.millisecondsSinceEpoch ~/ 1000,
        'created_at': date.millisecondsSinceEpoch ~/ 1000,
      });
    }
  }

  /// Generate progressive goals that show evolution
  Future<void> _generateProgressiveGoals(int userId, Database db) async {
    _logger.i('🎯 Generando objetivos progresivos...');
    
    final goals = [
      {
        'user_id': userId,
        'title': 'Consistencia Diaria Avanzada',
        'description': 'Mantener una práctica diaria de reflexión',
        'target_value': 30,
        'current_value': 23,
        'type': 'consistency',
        'status': 'active',
        'created_at': DateTime.now().subtract(Duration(days: 25)).millisecondsSinceEpoch ~/ 1000,
      },
      {
        'user_id': userId,
        'title': 'Equilibrio Emocional',
        'description': 'Mantener un promedio de estado de ánimo estable (7+)',
        'target_value': 7,
        'current_value': 7.2,
        'type': 'mood',
        'status': 'completed',
        'created_at': DateTime.now().subtract(Duration(days: 40)).millisecondsSinceEpoch ~/ 1000,
        'completed_at': DateTime.now().subtract(Duration(days: 5)).millisecondsSinceEpoch ~/ 1000,
      },
      {
        'user_id': userId,
        'title': 'Gestión de Estrés',
        'description': 'Reducir niveles de estrés promedio a menos de 4',
        'target_value': 4,
        'current_value': 3.8,
        'type': 'stressReduction',
        'status': 'completed',
        'created_at': DateTime.now().subtract(Duration(days: 35)).millisecondsSinceEpoch ~/ 1000,
        'completed_at': DateTime.now().subtract(Duration(days: 10)).millisecondsSinceEpoch ~/ 1000,
      },
      {
        'user_id': userId,
        'title': 'Explorador de Momentos',
        'description': 'Documentar 50 momentos significativos',
        'target_value': 50,
        'current_value': 38,
        'type': 'positiveMoments',
        'status': 'active',
        'created_at': DateTime.now().subtract(Duration(days: 20)).millisecondsSinceEpoch ~/ 1000,
      },
    ];

    for (final goal in goals) {
      await db.insert('user_goals', goal);
    }
  }

  // Helper methods for contextual content generation
  String _getCrisisPeriodNote(math.Random random) {
    final notes = [
      'Atravesando un período difícil, pero mantengo la esperanza',
      'Los días están siendo complicados, pero cada pequeño paso cuenta',
      'Buscando luz en medio de la tormenta',
      'Recordando que esto también pasará',
      'Enfocándome en lo básico: respirar, descansar, seguir',
    ];
    return notes[random.nextInt(notes.length)];
  }

  String _getRecoveryPeriodNote(math.Random random) {
    final notes = [
      'Empiezo a ver pequeñas mejoras en mi día a día',
      'Las cosas siguen siendo complicadas, pero hay momentos de claridad',
      'Estableciendo nuevas rutinas que me ayudan',
      'Aprendiendo a ser paciente conmigo mismo/a',
      'Cada día es una oportunidad para mejorar un poco',
    ];
    return notes[random.nextInt(notes.length)];
  }

  String _getImprovementPeriodNote(math.Random random) {
    final notes = [
      'Me siento más equilibrado/a y con mejor energía',
      'Las estrategias que he estado implementando funcionan',
      'Noto cambios positivos en mi perspectiva',
      'Construyendo momentum hacia mis objetivos',
      'Celebrando el progreso, por pequeño que sea',
    ];
    return notes[random.nextInt(notes.length)];
  }

  String _getThrivingPeriodNote(math.Random random) {
    final notes = [
      'Me siento en mi mejor momento, lleno/a de energía y propósito',
      'Todo parece fluir naturalmente hoy',
      'Agradecido/a por este período de claridad y bienestar',
      'Aprovechando esta energía positiva para crear y conectar',
      'Sintiendo una profunda sensación de equilibrio y paz',
    ];
    return notes[random.nextInt(notes.length)];
  }

  ({double mood, double energy, double stress}) _getAdvancedWeekdayModifier(int weekday, math.Random random) {
    switch (weekday) {
      case 1: // Monday
        return (mood: -0.5 + random.nextDouble() * 0.8, energy: -0.3 + random.nextDouble() * 0.6, stress: 0.2 + random.nextDouble() * 0.8);
      case 2: // Tuesday
        return (mood: -0.2 + random.nextDouble() * 0.7, energy: 0.0 + random.nextDouble() * 0.5, stress: 0.0 + random.nextDouble() * 0.6);
      case 3: // Wednesday
        return (mood: 0.1 + random.nextDouble() * 0.6, energy: 0.2 + random.nextDouble() * 0.4, stress: -0.1 + random.nextDouble() * 0.5);
      case 4: // Thursday
        return (mood: 0.3 + random.nextDouble() * 0.7, energy: 0.4 + random.nextDouble() * 0.6, stress: -0.2 + random.nextDouble() * 0.4);
      case 5: // Friday
        return (mood: 0.8 + random.nextDouble() * 0.9, energy: 0.6 + random.nextDouble() * 0.8, stress: -0.5 + random.nextDouble() * 0.3);
      case 6: // Saturday
        return (mood: 0.9 + random.nextDouble() * 0.8, energy: 0.3 + random.nextDouble() * 1.0, stress: -0.8 + random.nextDouble() * 0.2);
      case 7: // Sunday
        return (mood: 0.5 + random.nextDouble() * 0.9, energy: 0.0 + random.nextDouble() * 0.8, stress: -0.3 + random.nextDouble() * 0.4);
      default:
        return (mood: 0.0, energy: 0.0, stress: 0.0);
    }
  }

  String _generateContextualReflection(double mood, double energy, double stress, String contextNote, DateTime date, math.Random random) {
    final timeOfDay = random.nextBool() ? 'mañana' : (random.nextBool() ? 'tarde' : 'noche');
    final baseReflection = contextNote;
    
    if (mood > 7.5) {
      final positiveAddons = [
        'Siento una energía increíble esta $timeOfDay.',
        'Todo parece posible cuando me siento así.',
        'Quiero aprovechar este momento de claridad.',
        'Me siento conectado/a conmigo mismo/a y con mis objetivos.',
      ];
      return '$baseReflection ${positiveAddons[random.nextInt(positiveAddons.length)]}';
    } else if (mood < 4.0) {
      final challengingAddons = [
        'Esta $timeOfDay ha sido especialmente difícil.',
        'Necesito recordar que los sentimientos son temporales.',
        'Buscando pequeñas cosas por las que estar agradecido/a.',
        'Mañana puede ser un día completamente diferente.',
      ];
      return '$baseReflection ${challengingAddons[random.nextInt(challengingAddons.length)]}';
    } else {
      final neutralAddons = [
        'Una $timeOfDay tranquila para reflexionar.',
        'Tomando las cosas paso a paso.',
        'Aprendiendo a valorar estos momentos de calma.',
        'Construyendo lentamente hacia algo mejor.',
      ];
      return '$baseReflection ${neutralAddons[random.nextInt(neutralAddons.length)]}';
    }
  }

  double _addSeasonalAdjustments(double mood, DateTime date) {
    final month = date.month;
    double adjustment = 0.0;
    
    // Winter blues (December, January, February)
    if (month == 12 || month == 1 || month == 2) {
      adjustment = -0.3;
    }
    // Spring energy (March, April, May)
    else if (month >= 3 && month <= 5) {
      adjustment = 0.2;
    }
    // Summer high (June, July, August)
    else if (month >= 6 && month <= 8) {
      adjustment = 0.4;
    }
    // Fall reflection (September, October, November)
    else {
      adjustment = 0.1;
    }
    
    return (mood + adjustment).clamp(1.0, 10.0);
  }

  String _selectWeightedCategory(List<Map<String, dynamic>> categories, math.Random random) {
    final totalWeight = categories.fold(0.0, (sum, cat) => sum + cat['weight']);
    final randomValue = random.nextDouble() * totalWeight;
    
    double currentWeight = 0.0;
    for (final category in categories) {
      currentWeight += category['weight'];
      if (randomValue <= currentWeight) {
        return category['category'];
      }
    }
    return categories.first['category'];
  }

  Map<String, dynamic> _generateAdvancedMoment(String category, DateTime date, math.Random random) {
    switch (category) {
      case 'gratitude':
        final gratitudeMoments = [
          {'title': 'Momento de Gratitud', 'description': 'Agradecido/a por las pequeñas cosas que hacen la vida hermosa', 'intensity': 7 + random.nextInt(3)},
          {'title': 'Conexión Familiar', 'description': 'Una conversación profunda que me recordó lo importante que es estar presente', 'intensity': 8 + random.nextInt(2)},
          {'title': 'Belleza Cotidiana', 'description': 'Encontré belleza en lo ordinario y me sentí profundamente agradecido/a', 'intensity': 6 + random.nextInt(4)},
        ];
        return gratitudeMoments[random.nextInt(gratitudeMoments.length)];
      
      case 'achievement':
        final achievementMoments = [
          {'title': 'Logro Personal', 'description': 'Completé algo que había estado posponiendo y me siento increíblemente satisfecho/a', 'intensity': 8 + random.nextInt(2)},
          {'title': 'Superación Personal', 'description': 'Enfrenté un miedo y salí fortalecido/a de la experiencia', 'intensity': 9 + random.nextInt(1)},
          {'title': 'Progreso Constante', 'description': 'Pequeños pasos que se acumulan en un progreso significativo', 'intensity': 7 + random.nextInt(2)},
        ];
        return achievementMoments[random.nextInt(achievementMoments.length)];
      
      case 'connection':
        final connectionMoments = [
          {'title': 'Conexión Humana', 'description': 'Una conversación que me hizo sentir verdaderamente comprendido/a', 'intensity': 8 + random.nextInt(2)},
          {'title': 'Momento de Empatía', 'description': 'Pude estar presente para alguien que lo necesitaba', 'intensity': 7 + random.nextInt(3)},
          {'title': 'Comunidad', 'description': 'Me sentí parte de algo más grande que yo mismo/a', 'intensity': 6 + random.nextInt(4)},
        ];
        return connectionMoments[random.nextInt(connectionMoments.length)];
      
      case 'growth':
        final growthMoments = [
          {'title': 'Aprendizaje Profundo', 'description': 'Una revelación que cambió mi perspectiva sobre algo importante', 'intensity': 8 + random.nextInt(2)},
          {'title': 'Autoconocimiento', 'description': 'Descubrí algo nuevo sobre mí mismo/a que me ayuda a crecer', 'intensity': 7 + random.nextInt(3)},
          {'title': 'Sabiduría Práctica', 'description': 'Aplicé algo que había aprendido y funcionó perfectamente', 'intensity': 6 + random.nextInt(4)},
        ];
        return growthMoments[random.nextInt(growthMoments.length)];
      
      case 'nature':
        final natureMoments = [
          {'title': 'Conexión con la Naturaleza', 'description': 'Un momento de paz absoluta rodeado/a de la belleza natural', 'intensity': 8 + random.nextInt(2)},
          {'title': 'Renovación al Aire Libre', 'description': 'El aire fresco y el sol renovaron completamente mi energía', 'intensity': 7 + random.nextInt(3)},
          {'title': 'Contemplación Natural', 'description': 'Observando la naturaleza encontré perspectiva sobre mis propios desafíos', 'intensity': 6 + random.nextInt(4)},
        ];
        return natureMoments[random.nextInt(natureMoments.length)];
      
      default:
        return {'title': 'Momento Especial', 'description': 'Un momento que valió la pena recordar', 'intensity': 7};
    }
  }

  Future<void> _generateSimpleHistoricalData(int userId, Database db) async {
    _logger.i('📈 Generando datos históricos BÁSICOS...');

    final now = DateTime.now();
    final random = math.Random();

    // Generar datos para los últimos 90 días
    for (int daysAgo = 90; daysAgo >= 0; daysAgo--) {
      // Solo generar datos para el 70% de los días (más realista)
      if (random.nextDouble() < 0.7) {
        final date = now.subtract(Duration(days: daysAgo));
        await _generateSimpleDayEntry(userId, db, date, random);
      }
    }

    // Asegurar que HOY tiene una entrada
    await _generateTodayEntry(userId, db, now);
  }

  Future<void> _generateSimpleDayEntry(int userId, Database db, DateTime date, math.Random random) async {
    try {
      // Simular diferentes períodos de la vida
      final daysAgo = DateTime.now().difference(date).inDays;

      // Factores base según el período
      double baseMood, baseEnergy, baseStress;

      if (daysAgo > 60) {
        // Período más difícil (hace 2+ meses)
        baseMood = 3.5 + random.nextDouble() * 2.5; // 3.5-6
        baseEnergy = 3.0 + random.nextDouble() * 2.0; // 3-5
        baseStress = 6.0 + random.nextDouble() * 3.0; // 6-9
      } else if (daysAgo > 30) {
        // Período de mejora (último mes)
        baseMood = 5.0 + random.nextDouble() * 3.0; // 5-8
        baseEnergy = 5.0 + random.nextDouble() * 2.5; // 5-7.5
        baseStress = 4.0 + random.nextDouble() * 3.0; // 4-7
      } else {
        // Período actual (últimas 4 semanas)
        baseMood = 6.5 + random.nextDouble() * 2.5; // 6.5-9
        baseEnergy = 6.0 + random.nextDouble() * 3.0; // 6-9
        baseStress = 2.0 + random.nextDouble() * 4.0; // 2-6
      }

      // Factores del día de la semana
      final weekdayFactor = _getWeekdayMoodFactor(date.weekday, random);

      // Calcular valores finales
      final mood = (baseMood + weekdayFactor).clamp(1.0, 10.0);
      final energy = (baseEnergy + weekdayFactor * 0.7).clamp(1.0, 10.0);
      final stress = (baseStress - weekdayFactor * 0.5).clamp(1.0, 10.0);

      // Generar reflexión simple
      final reflection = _generateSimpleReflection(mood, energy, stress, date, random);

      // Formatear fecha para BD
      final dateStr = date.toIso8601String().split('T')[0];
      final createdAtTimestamp = date.millisecondsSinceEpoch ~/ 1000;

      // ✅ USAR SOLO COLUMNAS QUE REALMENTE EXISTEN
      final entryData = {
        'user_id': userId,
        'entry_date': dateStr,
        'free_reflection': reflection,
        'mood_score': mood.round(),
        'energy_level': energy.round(),
        'stress_level': stress.round(),
        'worth_it': mood > 6 ? 1 : 0,
        'created_at': createdAtTimestamp,
      };

      await db.insert(
        'daily_entries',
        entryData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _logger.d('✅ Entrada simple generada para $dateStr: Mood ${mood.round()}/10');

    } catch (e) {
      _logger.e('❌ Error insertando entrada simple para fecha $date: $e');
      // Continuar con otras fechas
    }
  }

  double _getWeekdayMoodFactor(int weekday, math.Random random) {
    switch (weekday) {
      case 1: // Lunes
        return -0.5 + random.nextDouble() * 0.5; // -0.5 a 0
      case 2: // Martes
        return -0.2 + random.nextDouble() * 0.6; // -0.2 a 0.4
      case 3: // Miércoles
        return 0.0 + random.nextDouble() * 0.4; // 0 a 0.4
      case 4: // Jueves
        return 0.2 + random.nextDouble() * 0.4; // 0.2 a 0.6
      case 5: // Viernes
        return 0.5 + random.nextDouble() * 0.8; // 0.5 a 1.3
      case 6: // Sábado
        return 0.8 + random.nextDouble() * 1.0; // 0.8 a 1.8
      case 7: // Domingo
        return 0.3 + random.nextDouble() * 0.8; // 0.3 a 1.1
      default:
        return 0.0;
    }
  }

  String _generateSimpleReflection(double mood, double energy, double stress, DateTime date, math.Random random) {
    // Reflexiones base según el estado de ánimo
    final List<String> highMoodReflections = [
      "Hoy ha sido un día realmente bueno. Me siento con energía y motivado para seguir adelante.",
      "Todo fluye naturalmente hoy. Estoy en una buena racha y aprovecho esta energía positiva.",
      "Me despierto con ganas de afrontar el día. Las cosas van bien y siento que estoy creciendo.",
      "Hoy he logrado varios objetivos pequeños que me hacen sentir orgulloso de mi progreso.",
      "La productividad está en su punto máximo. Me siento imparable y enfocado.",
      "Es increíble cómo algunas conversaciones pueden cambiar toda la perspectiva del día.",
      "Siento gratitud por las pequeñas cosas que hacen que la vida valga la pena.",
    ];

    final List<String> mediumMoodReflections = [
      "Un día normal, ni especialmente bueno ni malo. Estoy ok y eso también está bien.",
      "Hay altibajos, pero en general me siento equilibrado y en paz conmigo mismo.",
      "Algunos momentos buenos, otros más desafiantes. Así es la vida y lo acepto.",
      "Me siento estable hoy, sin grandes emociones en ninguna dirección.",
      "Ha sido un día productivo, aunque no extraordinario. Cada paso cuenta.",
      "Estoy aprendiendo a valorar los días tranquilos como este.",
      "Pequeños progresos, pero progresos al fin y al cabo. La constancia importa.",
    ];

    final List<String> lowMoodReflections = [
      "Hoy ha sido complicado. Me cuesta encontrar motivación, pero sé que es temporal.",
      "Siento que estoy en una mala racha. Espero que pase pronto y confío en que así será.",
      "No ha sido mi mejor día. Necesito descansar y reflexionar sobre lo que siento.",
      "Me siento abrumado por algunas situaciones. Necesito tomarme un respiro.",
      "Día difícil, pero recuerdo que es temporal. Mañana será diferente.",
      "A veces los días grises son necesarios para valorar los soleados.",
      "Estoy procesando algunas emociones difíciles. Es parte del crecimiento personal.",
    ];

    // Seleccionar reflexión según mood
    List<String> pool;
    if (mood >= 7) {
      pool = highMoodReflections;
    } else if (mood >= 4) {
      pool = mediumMoodReflections;
    } else {
      pool = lowMoodReflections;
    }

    String baseReflection = pool[random.nextInt(pool.length)];

    // Agregar contexto del día de la semana
    if (date.weekday == 1) {
      baseReflection += " Los lunes siempre son un nuevo comienzo.";
    } else if (date.weekday == 5) {
      baseReflection += " ¡Por fin viernes! El fin de semana se siente cerca.";
    } else if (date.weekday >= 6) {
      baseReflection += " Aprovecho el fin de semana para recargar energías.";
    }

    return baseReflection;
  }

  Future<void> _generateTodayEntry(int userId, Database db, DateTime now) async {
    _logger.i('📅 Generando entrada especial para HOY');

    final dateStr = now.toIso8601String().split('T')[0];
    final createdAtTimestamp = now.millisecondsSinceEpoch ~/ 1000;

    final todayReflection = '''¡Qué día tan increíble para estar trabajando en Reflect!

Como desarrollador, estoy fascinado por cómo esta app está evolucionando. Hoy me he centrado en optimizar la generación de datos de prueba y la verdad es que ver cómo los datos cobran vida es emocionante.

He estado experimentando con nuevos patrones de base de datos y me siento muy productivo. El feedback loop entre código-compilación-testing está fluyendo perfectamente.

Creo que estamos construyendo algo realmente valioso aquí. Una herramienta que no solo registra datos, sino que ayuda a las personas a entenderse mejor a sí mismas.

Físicamente me siento bien - he mantenido mi rutina de ejercicio y eso definitivamente impacta mi energía para programar.''';

    final entryData = {
      'user_id': userId,
      'entry_date': dateStr,
      'free_reflection': todayReflection,
      'mood_score': 8,
      'energy_level': 8,
      'stress_level': 3,
      'worth_it': 1,
      'created_at': createdAtTimestamp,
    };

    try {
      await db.insert(
        'daily_entries',
        entryData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.i('✅ Entrada de HOY generada exitosamente');
    } catch (e) {
      _logger.e('❌ Error generando entrada de hoy: $e');
    }
  }

  Future<void> _generateSimpleInteractiveMoments(int userId, Database db) async {
    _logger.i('🎭 Generando momentos interactivos BÁSICOS...');

    final now = DateTime.now();
    final random = math.Random();

    // Generar algunos momentos para los últimos días
    for (int daysAgo = 7; daysAgo >= 0; daysAgo--) {
      final date = now.subtract(Duration(days: daysAgo));
      final dateStr = date.toIso8601String().split('T')[0];

      // Generar 2-4 momentos por día
      final momentCount = 2 + random.nextInt(3);

      for (int i = 0; i < momentCount; i++) {
        final moment = _generateRandomMoment(userId, dateStr, date, random);
        try {
          await db.insert('interactive_moments', moment);
        } catch (e) {
          _logger.e('❌ Error insertando momento: $e');
        }
      }
    }

    _logger.i('✅ Momentos interactivos básicos generados');
  }

  Map<String, dynamic> _generateRandomMoment(int userId, String dateStr, DateTime date, math.Random random) {
    final moments = [
      {'emoji': '☕', 'text': 'Café perfecto para empezar el día', 'type': 'positive', 'category': 'routine'},
      {'emoji': '💻', 'text': 'Código funcionando a la primera', 'type': 'positive', 'category': 'work'},
      {'emoji': '😫', 'text': 'Bug difícil de resolver', 'type': 'negative', 'category': 'work'},
      {'emoji': '🌅', 'text': 'Hermoso amanecer', 'type': 'positive', 'category': 'nature'},
      {'emoji': '📚', 'text': 'Aprendiendo algo nuevo', 'type': 'positive', 'category': 'learning'},
      {'emoji': '🏃‍♂️', 'text': 'Ejercicio matutino completado', 'type': 'positive', 'category': 'health'},
      {'emoji': '😴', 'text': 'No dormí bien anoche', 'type': 'negative', 'category': 'health'},
      {'emoji': '🎵', 'text': 'Canción que me motivó', 'type': 'positive', 'category': 'entertainment'},
      {'emoji': '🍕', 'text': 'Pizza deliciosa para cenar', 'type': 'positive', 'category': 'food'},
      {'emoji': '📱', 'text': 'Demasiado tiempo en redes sociales', 'type': 'negative', 'category': 'technology'},
    ];

    final selectedMoment = moments[random.nextInt(moments.length)];
    final timestamp = date.add(Duration(
      hours: 8 + random.nextInt(12),
      minutes: random.nextInt(60),
    )).millisecondsSinceEpoch ~/ 1000;

    return {
      'user_id': userId,
      'entry_date': dateStr,
      'emoji': selectedMoment['emoji'],
      'text': selectedMoment['text'],
      'type': selectedMoment['type'],
      'intensity': 3 + random.nextInt(5), // 3-7
      'category': selectedMoment['category'],
      'timestamp': timestamp,
    };
  }

  // lib/data/services/optimized_database_service.dart
// ✅ MÉTODO _generateSimpleGoals COMPLETAMENTE ARREGLADO

  // ============================================================================
  // ✅ ARREGLADO: GENERADOR DE OBJETIVOS CON TIPOS CORRECTOS
  // ============================================================================

  // In lib/data/services/optimized_database_service.dart

  Future<void> _generateSimpleGoals(int userId, Database db) async {
    _logger.i('🎯 Generando objetivos BÁSICOS...');

    // Using a List<Map<String, Object>> for stricter type safety.
    final List<Map<String, Object>> goals = [
      {
        'title': 'Consistencia Diaria',
        'description': 'Mantener el hábito de reflexión diaria todos los días.',
        'type': 'consistency', // ✅ TIPO VÁLIDO
        'target_value': 7.0,
        'current_value': 5.0,
      },
      {
        'title': 'Mejora del Estado de Ánimo',
        'description': 'Mantener un nivel de ánimo estable y positivo.',
        'type': 'mood', // ✅ TIPO VÁLIDO
        'target_value': 8.0,
        'current_value': 6.5,
      },
      {
        'title': 'Capturar Momentos Positivos',
        'description': 'Registrar al menos 3 momentos positivos por día.',
        'type': 'positiveMoments', // ✅ TIPO VÁLIDO
        'target_value': 21.0, // Target for a week
        'current_value': 15.0,
      },
      {
        'title': 'Reducción de Estrés',
        'description': 'Mantener niveles bajos de estrés consistentemente.',
        'type': 'stressReduction', // ✅ TIPO VÁLIDO
        'target_value': 3.0, // Lower is better
        'current_value': 4.5,
      },
    ];

    final createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    for (final goal in goals) {
      try {
        await db.insert(
          'user_goals',
          {
            'user_id': userId,
            'title': goal['title'] as String,
            'description': goal['description'] as String,
            'type': goal['type'] as String, // Ensure it's a string
            'target_value': goal['target_value'] as double,
            'current_value': goal['current_value'] as double,
            'status': 'active', // Always a string
            'created_at': createdAt,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      } catch (e) {
        _logger.e('❌ Error insertando objetivo ${goal['title']}: $e');
      }
    }
  }

  // ============================================================================
  // ✅ MÉTODO HELPER PARA VALIDAR TIPOS DE GOALS
  // ============================================================================

  /// Valida si un tipo de goal es permitido por la base de datos
  bool _isValidGoalType(String type) {
    const validTypes = ['consistency', 'mood', 'positiveMoments', 'stressReduction'];
    return validTypes.contains(type);
  }

  /// Convierte tipos legacy a tipos válidos
  String _normalizeGoalType(String type) {
    switch (type.toLowerCase()) {
      case 'health':
      case 'exercise':
      case 'fitness':
        return 'consistency';
      case 'mindfulness':
      case 'meditation':
      case 'wellbeing':
        return 'mood';
      case 'learning':
      case 'education':
      case 'growth':
        return 'positiveMoments';
      case 'career':
      case 'work':
      case 'productivity':
        return 'stressReduction';
      default:
      // Si ya es un tipo válido, devolverlo tal como está
        return _isValidGoalType(type) ? type : 'consistency';
    }
  }

  // ============================================================================
  // ✅ MÉTODO PÚBLICO PARA CREAR GOALS CON VALIDACIÓN
  // ============================================================================

  /// Crea un nuevo goal con validación de tipos
  Future<int?> createGoalSafe({
    required int userId,
    required String title,
    required String description,
    required String type,
    required double targetValue,
    double currentValue = 0.0,
    String status = 'active',
  }) async {
    try {
      final db = await database;

      // ✅ Normalizar y validar el tipo
      final normalizedType = _normalizeGoalType(type);

      if (!_isValidGoalType(normalizedType)) {
        throw Exception('Tipo de objetivo no válido: $type. Tipos permitidos: consistency, mood, positiveMoments, stressReduction');
      }

      final goalData = {
        'user_id': userId,
        'title': title,
        'description': description,
        'type': normalizedType, // ✅ Tipo validado y normalizado
        'target_value': targetValue,
        'current_value': currentValue,
        'status': status,
        'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      final goalId = await db.insert('user_goals', goalData);
      _logger.i('✅ Goal creado con ID: $goalId, tipo: $normalizedType');

      return goalId;
    } catch (e) {
      _logger.e('❌ Error creando goal: $e');
      return null;
    }
  }

  // ============================================================================
  // ✅ RESTO DE MÉTODOS DE GOALS (SIN CAMBIOS NECESARIOS)
  // ============================================================================

  /// Obtener goals del usuario
  Future<List<Map<String, dynamic>>> getUserGoals(int userId) async {
    try {
      final db = await database;
      return await db.query(
        'user_goals',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      _logger.e('❌ Error obteniendo goals: $e');
      return [];
    }
  }

  /// Actualizar progreso de un goal
  Future<bool> updateGoalProgress(int goalId, double newValue) async {
    try {
      final db = await database;
      final rowsAffected = await db.update(
        'user_goals',
        {
          'current_value': newValue,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        where: 'id = ?',
        whereArgs: [goalId],
      );

      return rowsAffected > 0;
    } catch (e) {
      _logger.e('❌ Error actualizando progreso del goal: $e');
      return false;
    }
  }

  /// Marcar goal como completado
  Future<bool> completeGoal(int goalId) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final rowsAffected = await db.update(
        'user_goals',
        {
          'status': 'completed',
          'completed_at': now,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [goalId],
      );

      return rowsAffected > 0;
    } catch (e) {
      _logger.e('❌ Error completando goal: $e');
      return false;
    }
  }
  Future<void> _generateEnhancedHistoricalData(int userId, Database db) async {
    _logger.i('📈 Generando datos históricos MEJORADOS...');

    final now = DateTime.now();
    final random = math.Random();

    // Fases más realistas y detalladas
    final lifePeriods = [
      _LifePeriod('Crisis Personal', -120, -91, 2.8, 3.2, 8.5),
      _LifePeriod('Buscando Dirección', -90, -61, 4.2, 4.8, 7.0),
      _LifePeriod('Pequeñas Victorias', -60, -31, 6.5, 6.8, 5.5),
      _LifePeriod('Momentum Positivo', -30, -8, 8.2, 7.9, 3.2),
      _LifePeriod('Estabilidad Actual', -7, 0, 7.8, 8.1, 3.8),
    ];

    for (final period in lifePeriods) {
      await _generatePeriodData(userId, db, now, period, random);
    }

    // Generar datos para hoy
    await _generateTodayEntry(userId, db, now);
  }

  Future<void> _generatePeriodData(int userId, Database db, DateTime now, _LifePeriod period, math.Random random) async {
    _logger.i('📅 Generando período: ${period.name} (${period.endDay - period.startDay + 1} días)');

    for (int dayOffset = period.startDay; dayOffset <= period.endDay; dayOffset++) {
      // Solo generar datos para algunos días (no todos) para mayor realismo
      if (random.nextDouble() < 0.7) { // 70% de probabilidad de tener entrada
        final date = now.add(Duration(days: dayOffset));
        await _generateDayEntry(userId, db, date, period, random);
      }
    }
  }


  Future<void> _generateDayEntry(int userId, Database db, DateTime date, _LifePeriod period, math.Random random) async {
    try {
      // Factores que afectan el día
      final weekendBoost = (date.weekday >= 6) ? random.nextDouble() * 1.2 : 0.0;
      final mondayDip = (date.weekday == 1) ? -random.nextDouble() * 1.5 : 0.0;
      final fridayBoost = (date.weekday == 5) ? random.nextDouble() * 0.8 : 0.0;

      // Variación diaria natural
      final dailyVariation = (random.nextDouble() - 0.5) * 2.0;

      // Calcular métricas  as StringBÁSICAS basadas en el período
      final mood = (period.avgMood + weekendBoost + mondayDip + fridayBoost + dailyVariation).clamp(1.0, 10.0);
      final energy = (period.avgEnergy + weekendBoost + fridayBoost + dailyVariation).clamp(1.0, 10.0);
      final stress = (period.avgStress + mondayDip - weekendBoost + (random.nextDouble() - 0.5)).clamp(1.0, 10.0);

      // Generar reflexión realista basada en el período
      final reflection = _generateRealisticReflection(mood, energy, stress, period, date, random);

      // Formatear fecha para BD
      final dateStr = date.toIso8601String().split('T')[0];
      final createdAtTimestamp = date.millisecondsSinceEpoch ~/ 1000;

      // ✅ SOLO USAR COLUMNAS QUE REALMENTE EXISTEN
      final entryData = {
        'user_id': userId,
        'entry_date': dateStr,
        'free_reflection': reflection,
        'mood_score': mood.round(),
        'energy_level': energy.round(),
        'stress_level': stress.round(),
        'worth_it': mood > 6 ? 1 : 0, // Si mood > 6, worth_it = true
        'created_at': createdAtTimestamp,
      };

      // Insertar con manejo de conflictos
      await db.insert(
          'daily_entries',
          entryData,
          conflictAlgorithm: ConflictAlgorithm.replace
      );

      _logger.d('✅ Entrada generada para ${dateStr}: Mood ${mood.round()}/10');

    } catch (e) {
      _logger.e('❌ Error insertando entrada básica para fecha $date: $e');
      // No hacer rethrow para continuar con otras fechas
    }
  }



  Future<void> _generateEnhancedInteractiveMoments(int userId, Database db) async {
    _logger.i('💫 Generando momentos interactivos MEJORADOS...');

    final now = DateTime.now();
    final random = math.Random();

    // Generar momentos para los últimos 30 días
    for (int dayOffset = -30; dayOffset <= 0; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));

      // 2-5 momentos por día
      final momentsCount = 2 + random.nextInt(4);

      for (int i = 0; i < momentsCount; i++) {
        await _generateRandomMoment(userId, db as String, date, random);
      }
    }
  }



  Future<void> _generateSpecialEvents(int userId, Database db) async {
    _logger.i('🎉 Generando eventos especiales...');

    // Eventos especiales que crean patrones interesantes
    final specialEvents = [
      {
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'type': 'milestone',
        'emoji': '🚀',
        'text': 'Lanzamiento exitoso de nueva feature en Reflect',
        'intensity': 9,
        'category': 'trabajo',
        'location': 'Oficina',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 8)),
        'type': 'learning',
        'emoji': '📚',
        'text': 'Completé curso avanzado de Flutter',
        'intensity': 8,
        'category': 'aprendizaje',
        'location': 'Casa',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'type': 'social',
        'emoji': '🎂',
        'text': 'Cumpleaños de mi hermana - familia reunida',
        'intensity': 8,
        'category': 'personal',
        'location': 'Casa familiar',
      },
    ];

    for (final event in specialEvents) {
      final moment = OptimizedInteractiveMomentModel.create(
        userId: userId,
        emoji: event['emoji'] as String,
        text: event['text'] as String,
        type: 'positive',
        intensity: event['intensity'] as int,
        category: event['category'] as String,
        timestamp: event['date'] as DateTime,
        contextLocation: event['location'] as String,
      );

      await db.insert('interactive_moments', moment.toOptimizedDatabase());
    }
  }

  // ============================================================================
  // MÉTODOS HELPER PARA GENERAR CONTENIDO REALISTA
  // ============================================================================

  String _generateRealisticReflection(double mood, double energy, double stress, _LifePeriod period, DateTime date, math.Random random) {
    final reflections = _getReflectionsByPeriodAndMood(period.name, mood, energy, stress, date);
    return reflections[random.nextInt(reflections.length)];
  }

  List<String> _getReflectionsByPeriodAndMood(String period, double mood, double energy, double stress, DateTime date) {
    if (period == 'Crisis Personal') {
      return [
        'Hoy ha sido especialmente difícil. Me cuesta encontrar motivación y todo parece cuesta arriba. Pero sé que estos momentos pasan.',
        'Día complicado. He estado reflexionando sobre lo que realmente importa en mi vida. A veces las crisis nos ayudan a reenfocar.',
        'No ha sido mi mejor día, pero estoy intentando ser compasivo conmigo mismo. Mañana será diferente.',
        'Sensación de estar perdido, pero al menos estoy escribiendo esto. Escribir me ayuda a procesar.',
        'Lunes especialmente pesado. Me pregunto si estoy en el camino correcto, pero sé que dudar es parte del proceso.',
      ];
    } else if (period == 'Buscando Dirección') {
      return [
        'Poco a poco siento que voy encontrando mi rumbo. Aún hay días difíciles, pero también momentos de claridad.',
        'Hoy me he sentido más centrado. Estoy empezando a entender qué es lo que realmente quiero.',
        'He tenido una conversación interesante que me ha hecho pensar. Las perspectivas externas ayudan mucho.',
        'Día de pequeños progresos. No son cambios dramáticos, pero sí sostenibles.',
        'Me he dado cuenta de que el crecimiento no es lineal. Algunos días retrocedo, otros avanzo.',
      ];
    } else if (period == 'Pequeñas Victorias') {
      return [
        '¡Hoy he completado algo que había estado posponiendo durante semanas! Se siente increíble.',
        'Las cosas van mejorando gradualmente. Tengo más energía y las decisiones fluyen más fácil.',
        'He notado que mi productividad ha aumentado significativamente. Creo que finalmente estoy en un buen ritmo.',
        'Día productivo y satisfactorio. He encontrado un equilibrio entre trabajo y descanso que funciona.',
        'Me siento más confiado en mis decisiones. Los pequeños éxitos se van acumulando.',
      ];
    } else if (period == 'Momentum Positivo') {
      return [
        'Increíble día de desarrollo! He resuelto un bug complejo y implementado dos features nuevas. El flow de código está siendo fantástico.',
        'Hoy me levanté con una energía tremenda. Todo parece posible cuando estás en la zona correcta.',
        'Excelente sesión de brainstorming. Las ideas fluyen cuando tienes la mente clara y el equipo alineado.',
        'Me siento imparable. Cada desafío que aparece lo veo como una oportunidad de crecer.',
        'Día muy productivo. He logrado avanzar tanto en objetivos personales como profesionales.',
      ];
    } else { // Estabilidad Actual
      return [
        'Día equilibrado y tranquilo. Me siento cómodo con el ritmo que llevo actualmente.',
        'Hoy ha sido un buen día para reflexionar sobre todo lo que he crecido en estos meses.',
        'Productivo sin agobios. Creo que he encontrado un ritmo sostenible que me funciona.',
        'Sensación de estabilidad y claridad. Sé hacia dónde voy y cómo llegar.',
        'Día normal, pero en el buen sentido. A veces la normalidad es exactamente lo que necesitas.',
      ];
    }
  }

  Map<String, dynamic> _getMomentDataByType(String type, String category, math.Random random) {
    final positiveMoments = {
      'trabajo': [
        {'emoji': '✅', 'text': 'Bug resuelto en tiempo récord', 'intensity': 7, 'location': 'Oficina'},
        {'emoji': '🚀', 'text': 'Feature implementada sin problemas', 'intensity': 8, 'location': 'Casa'},
        {'emoji': '💡', 'text': 'Idea brillante para optimización', 'intensity': 6, 'location': 'Cafetería'},
        {'emoji': '🎯', 'text': 'Milestone alcanzado antes de deadline', 'intensity': 9, 'location': 'Oficina'},
      ],
      'personal': [
        {'emoji': '😊', 'text': 'Llamada sorpresa de un viejo amigo', 'intensity': 7, 'location': 'Casa'},
        {'emoji': '🌱', 'text': 'Mi planta finalmente tiene una nueva hoja', 'intensity': 5, 'location': 'Casa'},
        {'emoji': '📚', 'text': 'Terminé un libro muy interesante', 'intensity': 6, 'location': 'Parque'},
        {'emoji': '🎵', 'text': 'Descubrí una canción perfecta para programar', 'intensity': 6, 'location': 'Casa'},
      ],
      'salud': [
        {'emoji': '💪', 'text': 'Nuevo record personal en el gym', 'intensity': 8, 'location': 'Gimnasio'},
        {'emoji': '🧘', 'text': 'Meditación especialmente relajante', 'intensity': 7, 'location': 'Casa'},
        {'emoji': '🥗', 'text': 'Comida saludable y deliciosa', 'intensity': 6, 'location': 'Restaurante'},
        {'emoji': '😴', 'text': 'Desperté naturalmente sin alarma', 'intensity': 7, 'location': 'Casa'},
      ],
    };

    final negativeMoments = {
      'trabajo': [
        {'emoji': '😤', 'text': 'Reunión que podría haber sido un email', 'intensity': 4, 'location': 'Oficina'},
        {'emoji': '🐛', 'text': 'Bug misterioso que no logro resolver', 'intensity': 6, 'location': 'Casa'},
        {'emoji': '⏰', 'text': 'Deadline muy ajustado causando estrés', 'intensity': 7, 'location': 'Oficina'},
        {'emoji': '💻', 'text': 'Sistema caído justo cuando más lo necesitaba', 'intensity': 5, 'location': 'Oficina'},
      ],
      'personal': [
        {'emoji': '🌧️', 'text': 'Lluvia inesperada sin paraguas', 'intensity': 3, 'location': 'Calle'},
        {'emoji': '📱', 'text': 'Batería del móvil murió en momento crítico', 'intensity': 4, 'location': 'Transporte'},
        {'emoji': '🚌', 'text': 'Perdí el autobús por 30 segundos', 'intensity': 4, 'location': 'Parada'},
        {'emoji': '☕', 'text': 'Se acabó el café justo cuando lo necesitaba', 'intensity': 5, 'location': 'Casa'},
      ],
      'salud': [
        {'emoji': '😴', 'text': 'Noche de sueño irregular', 'intensity': 5, 'location': 'Casa'},
        {'emoji': '🤕', 'text': 'Dolor de espalda por mala postura', 'intensity': 4, 'location': 'Oficina'},
        {'emoji': '😵', 'text': 'Dolor de cabeza por demasiada pantalla', 'intensity': 5, 'location': 'Casa'},
      ],
    };

    final neutralMoments = {
      'trabajo': [
        {'emoji': '💼', 'text': 'Día normal de desarrollo', 'intensity': 5, 'location': 'Oficina'},
        {'emoji': '📊', 'text': 'Review de código rutinaria', 'intensity': 5, 'location': 'Casa'},
      ],
      'personal': [
        {'emoji': '🚶', 'text': 'Paseo tranquilo por el barrio', 'intensity': 5, 'location': 'Barrio'},
        {'emoji': '🛒', 'text': 'Compras semanales en el super', 'intensity': 5, 'location': 'Supermercado'},
      ],
    };

    Map<String, List<Map<String, dynamic>>> momentsMap;

    switch (type) {
      case 'positive':
        momentsMap = positiveMoments;
        break;
      case 'negative':
        momentsMap = negativeMoments;
        break;
      default:
        momentsMap = neutralMoments;
    }

    final categoryMoments = momentsMap[category] ?? momentsMap['personal']!;
    final selectedMoment = categoryMoments[random.nextInt(categoryMoments.length)];

    return {
      'emoji': selectedMoment['emoji'],
      'text': selectedMoment['text'],
      'intensity': selectedMoment['intensity'],
      'location': selectedMoment['location'],
    };
  }

  // Métodos helper adicionales
  double _getSeasonalFactor(DateTime date) {
    // Factor estacional simple
    final month = date.month;
    if (month >= 6 && month <= 8) return 0.3; // Verano
    if (month >= 12 || month <= 2) return -0.2; // Invierno
    return 0.0; // Primavera/Otoño
  }

  String _generateGratitudeItems(double mood, math.Random random) {
    final items = [
      'Salud y energía para enfrentar el día',
      'Familia que me apoya incondicionalmente',
      'Trabajo que me permite crecer',
      'Amigos que hacen la vida más divertida',
      'Oportunidad de aprender cosas nuevas',
      'Hogar cómodo donde descansar',
      'Comida deliciosa en la mesa',
      'Tecnología que facilita mi trabajo',
      'Momento presente y tranquilidad',
      'Capacidad de reflexionar y mejorar',
    ];

    final count = mood > 7 ? 3 : mood > 4 ? 2 : 1;
    final selected = <String>[];

    for (int i = 0; i < count; i++) {
      final item = items[random.nextInt(items.length)];
      if (!selected.contains(item)) selected.add(item);
    }

    return selected.join(', ');
  }

  // ✅ MÉTODO PARA AI COACH
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

  Future<void> clearUserData(int userId) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete('daily_entries', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('interactive_moments', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('tags', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('user_goals', where: 'user_id = ?', whereArgs: [userId]); // ✅ AÑADIDO
      });
      _logger.i('🗑️ Datos del usuario $userId eliminados');
    } catch (e) {
      _logger.e('❌ Error eliminando datos del usuario: $e');
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
      _logger.i('🔒 Base de datos cerrada');
    }
  }

  // ✅ VERIFICACIÓN DE SALUD DE BD PARA APK
  Future<bool> checkDatabaseHealth() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT 1');
      return result.isNotEmpty;
    } catch (e) {
      _logger.e('❌ Base de datos no saludable: $e');
      return false;
    }
  }
  // Fix these methods in your OptimizedDatabaseService

  /// Obtener objetivos por tipo
  // lib/data/services/optimized_database_service.dart

  /// Obtener objetivos por tipo
  Future<List<GoalModel>> getGoalsByType(int userId, GoalType type) async {
    try {
      final db = await database;
      final results = await db.query(
        'user_goals',
        where: 'user_id = ? AND type = ?',
        // CORRECT: Use .name to get the simple string 'consistency', 'mood', etc.
        whereArgs: [userId, type.name],
        orderBy: 'created_at DESC',
      );

      // This assumes GoalModel.fromDatabase can correctly parse the map
      return results.map((row) => GoalModel.fromDatabase(row)).toList();
    } catch (e) {
      _logger.e('Error getting goals by type: $e');
      throw Exception('Error getting goals by type: $e');
    }
  }

  /// Obtener objetivos por estado
  Future<List<GoalModel>> getGoalsByStatus(int userId, GoalStatus status) async {
    try {
      final db = await database;
      final results = await db.query(
        'user_goals',
        where: 'user_id = ? AND status = ?',
        // CORRECT: Use .name to get the simple string 'active', 'completed', etc.
        whereArgs: [userId, status.name],
        orderBy: 'created_at DESC',
      );

      // This assumes GoalModel.fromDatabase can correctly parse the map
      return results.map((row) => GoalModel.fromDatabase(row)).toList();
    } catch (e) {
      _logger.e('Error getting goals by status: $e');
      throw Exception('Error getting goals by status: $e');
    }
  }

}

// ============================================================================
// CLASE HELPER PARA PERÍODOS DE VIDA
// ============================================================================

class _LifePeriod {
  final String name;
  final int startDay;
  final int endDay;
  final double avgMood;
  final double avgEnergy;
  final double avgStress;

  _LifePeriod(this.name, this.startDay, this.endDay, this.avgMood,
      this.avgEnergy, this.avgStress);
}