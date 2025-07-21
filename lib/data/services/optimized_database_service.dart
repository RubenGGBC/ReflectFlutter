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

// Asegúrate de que la ruta de importación sea correcta para tu proyecto.
import '../models/goal_model.dart';
import '../models/optimized_models.dart';
import '../models/daily_roadmap_model.dart';
import '../models/roadmap_activity_model.dart';

class OptimizedDatabaseService {
  static const String _databaseName = 'reflect_optimized_v2.db';
  static const int _databaseVersion = 11;

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

    // Try multiple database paths for better compatibility
    final possiblePaths = await _getDatabasePaths();
    
    for (final path in possiblePaths) {
      try {
        debugPrint('📁 Intentando ruta de base de datos: $path');
        
        final db = await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _createOptimizedSchema,
          onUpgrade: _upgradeSchema,
          onConfigure: _configureDatabase,
          singleInstance: true,
        );
        
        // Test database write capability
        await _testDatabaseWrite(db);
        
        _logger.i('✅ Base de datos inicializada exitosamente en: $path');
        return db;
        
      } catch (e) {
        _logger.w('⚠️ Error en ruta $path: $e');
        continue;
      }
    }
    
    // If all paths fail, throw error
    throw Exception('❌ No se pudo inicializar la base de datos en ninguna ruta');
  }
  
  Future<List<String>> _getDatabasePaths() async {
    final paths = <String>[];
    
    try {
      // Primary path: Application documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      paths.add(join(documentsDir.path, _databaseName));
    } catch (e) {
      _logger.w('⚠️ Error obteniendo documents directory: $e');
    }
    
    try {
      // Secondary path: Application support directory
      final supportDir = await getApplicationSupportDirectory();
      paths.add(join(supportDir.path, _databaseName));
    }
    catch (e) {
      _logger.w('⚠️ Error obteniendo support directory: $e');
    }
    
    try {
      // Last resort: Internal storage (Android specific)
      if (Platform.isAndroid) {
        final internalPath = '/data/data/${Platform.environment['PACKAGE_NAME'] ?? 'com.example.reflect'}/databases';
        paths.add(join(internalPath, _databaseName));
      }
    }
    catch (e) {
      _logger.w('⚠️ Error obteniendo internal directory: $e');
    }
    
    return paths;
  }
  
  Future<void> _testDatabaseWrite(Database db) async {
    try {
      // Test if we can write to the database
      await db.execute('CREATE TABLE IF NOT EXISTS test_table (id INTEGER PRIMARY KEY)');
      await db.insert('test_table', {'id': 1});
      await db.delete('test_table', where: 'id = ?', whereArgs: [1]);
      await db.execute('DROP TABLE IF EXISTS test_table');
    } catch (e) {
      throw Exception('Database write test failed: $e');
    }
  }

  Future<void> _configureDatabase(Database db) async {
    try {
      // ✅ CONFIGURACIONES SEGURAS PARA APK
      await db.execute('PRAGMA foreign_keys = ON');
      
      // Try WAL mode first, fallback to DELETE mode if it fails
      try {
        await db.execute('PRAGMA journal_mode = WAL');
        _logger.d('✅ WAL mode enabled');
      } catch (walError) {
        _logger.w('⚠️ WAL mode failed, using DELETE mode: $walError');
        await db.execute('PRAGMA journal_mode = DELETE');
      }
      
      await db.execute(
          'PRAGMA cache_size = -1000'); // 1MB cache (reducido para APK)
      await db.execute('PRAGMA temp_store = MEMORY');
      
      // Use FULL synchronization for mobile devices to ensure data persistence
      await db.execute('PRAGMA synchronous = FULL');
      
      // Set busy timeout for better concurrency handling
      await db.execute('PRAGMA busy_timeout = 30000'); // 30 seconds

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
          age INTEGER,
          is_first_time_user INTEGER DEFAULT 1,
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
          inner_reflection TEXT,

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
          completed_activities_today TEXT DEFAULT '[]',
          goals_summary TEXT DEFAULT '[]',
          voice_recording_path TEXT,

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
            type TEXT NOT NULL CHECK (type IN ('consistency', 'mood', 'positiveMoments', 'stressReduction', 'habits')),
            status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused', 'cancelled')),
            target_value REAL NOT NULL CHECK (target_value > 0),
            current_value REAL NOT NULL DEFAULT 0.0 CHECK (current_value >= 0),
            progress_notes TEXT,

            -- Timestamps
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            completed_at INTEGER,
            last_updated INTEGER,

            -- Goal Metadata
            category TEXT,
            difficulty TEXT,
            estimated_days INTEGER,

            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // ✅ NUEVA TABLA: DAILY_ROADMAPS - Para la funcionalidad de roadmap diario
        await txn.execute('''
          CREATE TABLE daily_roadmaps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            target_date TEXT NOT NULL,
            activities_json TEXT NOT NULL DEFAULT '[]',
            daily_goal TEXT,
            morning_notes TEXT,
            evening_reflection TEXT,
            status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed', 'partially_completed', 'cancelled')),
            completion_percentage REAL DEFAULT 0.0 CHECK (completion_percentage >= 0.0 AND completion_percentage <= 100.0),
            overall_mood TEXT CHECK (overall_mood IN ('very_bad', 'bad', 'neutral', 'good', 'very_good', 'excited')),
            total_activities INTEGER DEFAULT 0,
            completed_activities INTEGER DEFAULT 0,
            total_estimated_minutes INTEGER DEFAULT 0,
            actual_spent_minutes INTEGER DEFAULT 0,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),

            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(user_id, target_date)
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
      if (oldVersion < 3) {
        await _migrateToV3(db);
      }
      if (oldVersion < 4) {
        await _migrateToV4(db);
      }
      if (oldVersion < 5) {
        await _migrateToV5(db);
      }
      if (oldVersion < 6) {
        await _migrateToV6(db);
      }
      if (oldVersion < 7) {
        await _migrateToV7(db);
      }
      if (oldVersion < 8) {
        await _migrateToV8(db);
      }
      if (oldVersion < 9) {
        await _migrateToV9(db);
      }
      if (oldVersion < 10) {
        await _migrateToV10(db);
      }
      if (oldVersion < 11) {
        await _migrateToV11(db);
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
            type TEXT NOT NULL CHECK (type IN ('consistency', 'mood', 'positiveMoments', 'stressReduction', 'habits')),
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

      // ✅ Migración para agregar columnas faltantes a daily_entries
      await _addMissingColumnsToDaily(db);

    } catch (e) {
      _logger.e('❌ Error en migración v2: $e');
      rethrow;
    }
  }

  Future<void> _addMissingColumnsToDaily(Database db) async {
    final columnsToAdd = [
      'overall_sentiment TEXT',
      'ai_summary TEXT',
      'word_count INTEGER DEFAULT 0',
      'sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 10)',
      'anxiety_level INTEGER CHECK (anxiety_level >= 1 AND anxiety_level <= 10)',
      'motivation_level INTEGER CHECK (motivation_level >= 1 AND motivation_level <= 10)',
      'social_interaction INTEGER CHECK (social_interaction >= 1 AND social_interaction <= 10)',
      'physical_activity INTEGER CHECK (physical_activity >= 1 AND physical_activity <= 10)',
      'work_productivity INTEGER CHECK (work_productivity >= 1 AND work_productivity <= 10)',
      'sleep_hours REAL CHECK (sleep_hours >= 0 AND sleep_hours <= 24)',
      'water_intake INTEGER CHECK (water_intake >= 0 AND water_intake <= 20)',
      'meditation_minutes INTEGER CHECK (meditation_minutes >= 0 AND meditation_minutes <= 600)',
      'exercise_minutes INTEGER CHECK (exercise_minutes >= 0 AND exercise_minutes <= 600)',
      'screen_time_hours REAL CHECK (screen_time_hours >= 0 AND screen_time_hours <= 24)',
      'weather_mood_impact INTEGER CHECK (weather_mood_impact >= -5 AND weather_mood_impact <= 5)',
      'social_battery INTEGER CHECK (social_battery >= 1 AND social_battery <= 10)',
      'creative_energy INTEGER CHECK (creative_energy >= 1 AND creative_energy <= 10)',
      'emotional_stability INTEGER CHECK (emotional_stability >= 1 AND emotional_stability <= 10)',
      'focus_level INTEGER CHECK (focus_level >= 1 AND focus_level <= 10)',
      'life_satisfaction INTEGER CHECK (life_satisfaction >= 1 AND life_satisfaction <= 10)',
      'gratitude_items TEXT',
      'positive_tags TEXT DEFAULT "[]"',
      'negative_tags TEXT DEFAULT "[]"',
      'completed_activities_today TEXT DEFAULT "[]"',
      'goals_summary TEXT DEFAULT "[]"',
      'voice_recording_path TEXT',
      'inner_reflection TEXT',
      'updated_at INTEGER NOT NULL DEFAULT (strftime("%s", "now"))',
    ];

    for (final column in columnsToAdd) {
      try {
        await db.execute('ALTER TABLE daily_entries ADD COLUMN $column');
        _logger.i('✅ Columna agregada: $column');
      } catch (e) {
        // Column might already exist, this is fine
        _logger.w('⚠️ Columna ya existe o error: $column - $e');
      }
    }

    _logger.i('✅ Migración de columnas de daily_entries completada');
  }

  Future<void> _migrateToV3(Database db) async {
    try {
      // Ensure all missing columns are added for v3
      await _addMissingColumnsToDaily(db);
      _logger.i('✅ Migración v3 completada');
    } catch (e) {
      _logger.e('❌ Error en migración v3: $e');
      rethrow;
    }
  }

  Future<void> _migrateToV4(Database db) async {
    try {
      // Ensure all missing columns are added for v4 (includes focus_level and life_satisfaction)
      await _addMissingColumnsToDaily(db);
      _logger.i('✅ Migración v4 completada - Agregadas columnas focus_level y life_satisfaction');
    } catch (e) {
      _logger.e('❌ Error en migración v4: $e');
      rethrow;
    }
  }

  Future<void> _migrateToV5(Database db) async {
    try {
      // Add voice recording path column to daily_entries table
      await db.execute('''
        ALTER TABLE daily_entries ADD COLUMN voice_recording_path TEXT;
      ''');
      _logger.i('✅ Migración v5 completada - Agregada columna voice_recording_path');
    } catch (e) {
      _logger.e('❌ Error en migración v5: $e');
      rethrow;
    }
  }

  Future<void> _migrateToV6(Database db) async {
    try {
      await db.execute('ALTER TABLE user_goals ADD COLUMN last_updated INTEGER;');
      await db.execute('ALTER TABLE user_goals ADD COLUMN category TEXT;');
      await db.execute('ALTER TABLE user_goals ADD COLUMN difficulty TEXT;');
      await db.execute('ALTER TABLE user_goals ADD COLUMN estimated_days INTEGER;');
      await db.execute('ALTER TABLE user_goals ADD COLUMN milestones TEXT;');
      await db.execute('ALTER TABLE user_goals ADD COLUMN metrics TEXT;');
      await db.execute('ALTER TABLE user_goals ADD COLUMN progress_notes TEXT;');
      _logger.i('✅ Migración v6 completada - Agregadas columnas a user_goals');
    } catch (e) {
      _logger.e('❌ Error en migración v6: $e');
      rethrow;
    }
  }

  Future<void> _migrateToV7(Database db) async {
    try {
      // Add inner_reflection column to daily_entries table
      await db.execute('ALTER TABLE daily_entries ADD COLUMN inner_reflection TEXT;');
      _logger.i('✅ Migración v7 completada - Agregada columna inner_reflection a daily_entries');
    } catch (e) {
      // If column already exists, ignore the error
      if (e.toString().contains('duplicate column name')) {
        _logger.i('ℹ️ Columna inner_reflection ya existe en daily_entries');
      }
      else {
        _logger.e('❌ Error en migración v7: $e');
        rethrow;
      }
    }
  }

  Future<void> _migrateToV8(Database db) async {
    try {
      // Add completed_activities_today and goals_summary columns to daily_entries table
      await db.execute('ALTER TABLE daily_entries ADD COLUMN completed_activities_today TEXT DEFAULT "[]"');
      await db.execute('ALTER TABLE daily_entries ADD COLUMN goals_summary TEXT DEFAULT "[]"');
      _logger.i('✅ Migración v8 completada - Agregadas columnas completed_activities_today y goals_summary a daily_entries');
    } catch (e) {
      // If columns already exist, ignore the error
      if (e.toString().contains('duplicate column name')) {
        _logger.i('ℹ️ Columnas completed_activities_today y goals_summary ya existen en daily_entries');
      }
      else {
        _logger.e('❌ Error en migración v8: $e');
        rethrow;
      }
    }
  }

  Future<void> _migrateToV9(Database db) async {
    try {
      // Check if daily_roadmaps table already exists
      final result = await db.rawQuery('''
        SELECT name FROM sqlite_master
        WHERE type='table' AND name='daily_roadmaps'
      ''');
      
      if (result.isEmpty) {
        _logger.i('📦 Agregando tabla daily_roadmaps en migración v9');
        await db.execute('''
          CREATE TABLE daily_roadmaps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            target_date TEXT NOT NULL,
            activities_json TEXT NOT NULL DEFAULT '[]',
            daily_goal TEXT,
            morning_notes TEXT,
            evening_reflection TEXT,
            status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed', 'partially_completed', 'cancelled')),
            completion_percentage REAL DEFAULT 0.0 CHECK (completion_percentage >= 0.0 AND completion_percentage <= 100.0),
            overall_mood TEXT CHECK (overall_mood IN ('very_bad', 'bad', 'neutral', 'good', 'very_good', 'excited')),
            total_activities INTEGER DEFAULT 0,
            completed_activities INTEGER DEFAULT 0,
            total_estimated_minutes INTEGER DEFAULT 0,
            actual_spent_minutes INTEGER DEFAULT 0,
            created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(user_id, target_date)
          )
        ''');
        _logger.i('✅ Migración v9 completada - Tabla daily_roadmaps creada');
      } else {
        _logger.i('ℹ️ Tabla daily_roadmaps ya existe');
      }
    } catch (e) {
      _logger.e('❌ Error en migración v9: $e');
      rethrow;
    }
  }

  Future<void> _migrateToV10(Database db) async {
    try {
      _logger.i('📦 Actualizando restricción de tipos en user_goals en migración v10');
      
      // Since SQLite doesn't support ALTER TABLE for CHECK constraints,
      // we need to recreate the table with the new constraint
      await db.execute('''
        CREATE TABLE user_goals_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('consistency', 'mood', 'positiveMoments', 'stressReduction', 'habits')),
          status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused', 'cancelled')),
          target_value REAL NOT NULL CHECK (target_value > 0),
          current_value REAL NOT NULL DEFAULT 0.0 CHECK (current_value >= 0),
          progress_notes TEXT,
          created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
          category TEXT DEFAULT 'habits',
          icon_name TEXT DEFAULT 'emoji_events',
          color_hex TEXT DEFAULT 'FF6B6B',
          milestones_json TEXT DEFAULT '[]',
          priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
          difficulty INTEGER DEFAULT 3 CHECK (difficulty >= 1 AND difficulty <= 5),
          tags_json TEXT DEFAULT '[]',
          due_date TEXT,
          estimated_duration INTEGER DEFAULT 30,
          resources_json TEXT DEFAULT '[]',
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      
      // Copy existing data
      await db.execute('''
        INSERT INTO user_goals_new SELECT * FROM user_goals
      ''');
      
      // Drop old table and rename new one
      await db.execute('DROP TABLE user_goals');
      await db.execute('ALTER TABLE user_goals_new RENAME TO user_goals');
      
      _logger.i('✅ Migración v10 completada - Constraint actualizado para incluir "habits"');
    } catch (e) {
      _logger.e('❌ Error en migración v10: $e');
      rethrow;
    }
  }

  Future<void> _migrateToV11(Database db) async {
    try {
      _logger.i('📦 Agregando columnas faltantes a daily_roadmaps en migración v11');
      
      // Check if the columns already exist
      final tableInfo = await db.rawQuery('PRAGMA table_info(daily_roadmaps)');
      final columnNames = tableInfo.map((row) => row['name'] as String).toSet();
      
      if (!columnNames.contains('total_activities')) {
        await db.execute('ALTER TABLE daily_roadmaps ADD COLUMN total_activities INTEGER DEFAULT 0');
        _logger.i('✅ Columna total_activities agregada');
      }
      
      if (!columnNames.contains('completed_activities')) {
        await db.execute('ALTER TABLE daily_roadmaps ADD COLUMN completed_activities INTEGER DEFAULT 0');
        _logger.i('✅ Columna completed_activities agregada');
      }
      
      if (!columnNames.contains('total_estimated_minutes')) {
        await db.execute('ALTER TABLE daily_roadmaps ADD COLUMN total_estimated_minutes INTEGER DEFAULT 0');
        _logger.i('✅ Columna total_estimated_minutes agregada');
      }
      
      if (!columnNames.contains('actual_spent_minutes')) {
        await db.execute('ALTER TABLE daily_roadmaps ADD COLUMN actual_spent_minutes INTEGER DEFAULT 0');
        _logger.i('✅ Columna actual_spent_minutes agregada');
      }
      
      _logger.i('✅ Migración v11 completada - Columnas de daily_roadmaps actualizadas');
    } catch (e) {
      _logger.e('❌ Error en migración v11: $e');
      rethrow;
    }
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
      
      // Use transaction for atomic operations
      return await db.transaction((txn) async {
        final entryData = entry.toOptimizedDatabase();
        final dateStr = entry.entryDate.toIso8601String().split('T')[0];

        final existingEntry = await txn.query(
          'daily_entries',
          where: 'user_id = ? AND entry_date = ?',
          whereArgs: [entry.userId, dateStr],
          limit: 1,
        );

        int entryId;
        if (existingEntry.isNotEmpty) {
          entryId = existingEntry.first['id'] as int;
          entryData['updated_at'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;

          final updatedRows = await txn.update(
            'daily_entries',
            entryData,
            where: 'id = ?',
            whereArgs: [entryId],
          );
          
          if (updatedRows == 0) {
            throw Exception('Failed to update daily entry');
          }
          
          _logger.d('📝 Entrada diaria actualizada (ID: $entryId)');
        } else {
          entryId = await txn.insert('daily_entries', entryData);
          if (entryId <= 0) {
            throw Exception('Failed to insert daily entry');
          }
          _logger.d('📝 Nueva entrada diaria creada (ID: $entryId)');
        }

        return entryId;
      });
    } catch (e) {
      _logger.e('❌ Error guardando entrada diaria: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
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
  // MÉTODOS PARA DAILY ROADMAPS
  // ============================================================================

  Future<int?> saveDailyRoadmap(DailyRoadmapModel roadmap) async {
    try {
      final db = await database;
      
      return await db.transaction((txn) async {
        final roadmapData = roadmap.toDatabase();
        // Remove 'id' from roadmapData to avoid UNIQUE constraint violations
        roadmapData.remove('id');
        final dateStr = roadmap.targetDate.toIso8601String().split('T')[0];

        final existingRoadmap = await txn.query(
          'daily_roadmaps',
          where: 'user_id = ? AND target_date = ?',
          whereArgs: [roadmap.userId, dateStr],
          limit: 1,
        );

        int roadmapId;
        if (existingRoadmap.isNotEmpty) {
          roadmapId = existingRoadmap.first['id'] as int;
          roadmapData['updated_at'] = DateTime.now().toIso8601String();

          final updatedRows = await txn.update(
            'daily_roadmaps',
            roadmapData,
            where: 'id = ?',
            whereArgs: [roadmapId],
          );
          
          if (updatedRows == 0) {
            throw Exception('Failed to update daily roadmap');
          }
          
          _logger.d('🗓️ Roadmap diario actualizado (ID: $roadmapId)');
        } else {
          roadmapId = await txn.insert('daily_roadmaps', roadmapData);
          if (roadmapId <= 0) {
            throw Exception('Failed to insert daily roadmap');
          }
          _logger.d('🗓️ Nuevo roadmap diario creado (ID: $roadmapId)');
        }

        return roadmapId;
      });
    } catch (e) {
      _logger.e('❌ Error guardando roadmap diario: $e');
      return null;
    }
  }

  Future<DailyRoadmapModel?> getDailyRoadmap({
    required int userId,
    required DateTime targetDate,
  }) async {
    try {
      final db = await database;
      final dateStr = targetDate.toIso8601String().split('T')[0];

      final results = await db.query(
        'daily_roadmaps',
        where: 'user_id = ? AND target_date = ?',
        whereArgs: [userId, dateStr],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return DailyRoadmapModel.fromDatabase(results.first);
      }
      return null;
    } catch (e) {
      _logger.e('❌ Error obteniendo roadmap diario: $e');
      return null;
    }
  }

  Future<List<DailyRoadmapModel>> getDailyRoadmaps({
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
        whereClause += ' AND target_date >= ?';
        whereArgs.add(startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        whereClause += ' AND target_date <= ?';
        whereArgs.add(endDate.toIso8601String().split('T')[0]);
      }

      final results = await db.query(
        'daily_roadmaps',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'target_date DESC',
        limit: limit,
      );

      return results.map((row) => DailyRoadmapModel.fromDatabase(row)).toList();
    } catch (e) {
      _logger.e('❌ Error obteniendo roadmaps diarios: $e');
      return [];
    }
  }

  Future<bool> deleteDailyRoadmap({
    required int userId,
    required DateTime targetDate,
  }) async {
    try {
      final db = await database;
      final dateStr = targetDate.toIso8601String().split('T')[0];

      final deletedRows = await db.delete(
        'daily_roadmaps',
        where: 'user_id = ? AND target_date = ?',
        whereArgs: [userId, dateStr],
      );

      if (deletedRows > 0) {
        _logger.d('🗑️ Roadmap diario eliminado para fecha: $dateStr');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('❌ Error eliminando roadmap diario: $e');
      return false;
    }
  }

  Future<List<DailyRoadmapModel>> getRoadmapsByStatus({
    required int userId,
    required RoadmapStatus status,
    int? limit,
  }) async {
    try {
      final db = await database;

      final results = await db.query(
        'daily_roadmaps',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, status.name],
        orderBy: 'target_date DESC',
        limit: limit,
      );

      return results.map((row) => DailyRoadmapModel.fromDatabase(row)).toList();
    } catch (e) {
      _logger.e('❌ Error obteniendo roadmaps por estado: $e');
      return [];
    }
  }

  // ============================================================================
  // MÉTODOS OPTIMIZADOS PARA MOMENTOS INTERACTIVOS
  // ============================================================================

  Future<int?> saveInteractiveMoment(int userId, OptimizedInteractiveMomentModel moment) async {
    try {
      final db = await database;
      
      // Use transaction for atomic operations
      return await db.transaction((txn) async {
        final momentData = moment.toOptimizedDatabase();
        momentData['user_id'] = userId;

        final momentId = await txn.insert('interactive_moments', momentData);
        if (momentId <= 0) {
          throw Exception('Failed to insert interactive moment');
        }
        
        _logger.d('✨ Momento guardado: ${moment.emoji} ${moment.text} (ID: $momentId)');
        return momentId;
      });
    } catch (e) {
      _logger.e('❌ Error guardando momento: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
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
      
      // ✅ NEW: Enhanced intelligent analytics
      final intelligentInsights = await _getIntelligentInsights(db, userId, startDate, endDate);
      final personalizedRecommendations = await _getPersonalizedRecommendations(db, userId, days);
      final wellbeingPrediction = await getWellbeingPredictionData(userId, days: days);
      final habitsAnalysis = await getHealthyHabitsAnalysis(userId, days: days);
      final emotionalPatterns = await _getEmotionalPatterns(db, userId, startDate, endDate);
      final lifestyleCorrelations = await _getLifestyleCorrelations(db, userId, startDate, endDate);

      return {
        'basic_stats': basicStats,
        'mood_trends': moodTrends,
        'moment_stats': momentStats,
        'streak_data': streakData,
        'period_days': days,
        // ✅ Enhanced analytics
        'intelligent_insights': intelligentInsights,
        'personalized_recommendations': personalizedRecommendations,
        'wellbeing_prediction': wellbeingPrediction,
        'habits_analysis': habitsAnalysis,
        'emotional_patterns': emotionalPatterns,
        'lifestyle_correlations': lifestyleCorrelations,
        'metadata': {
          'generated_at': DateTime.now().toIso8601String(),
          'analytics_version': '2.0_intelligent',
          'data_quality_score': await _calculateDataQualityScore(db, userId, startDate, endDate),
        },
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
      SELECT DISTINCT entry_date
      FROM daily_entries
      WHERE user_id = ?
        AND entry_date >= date('now', '-365 days')
      ORDER BY entry_date DESC
    ''', [userId]);

    return _calculateStreaksOptimized(results.map((r) => r['entry_date'] as String).toList());
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

  /// Optimized streak calculation with proper midnight handling
  Map<String, dynamic> _calculateStreaksOptimized(List<String> dateStrings) {
    if (dateStrings.isEmpty) {
      return {'current_streak': 0, 'longest_streak': 0};
    }

    // Parse all dates and normalize to midnight (removes time component)
    final dates = dateStrings.map((dateStr) {
      final date = DateTime.parse(dateStr);
      // Ensure we're working with date-only (midnight) for proper comparison
      return DateTime(date.year, date.month, date.day);
    }).toList();

    // Sort in descending order (most recent first)
    dates.sort((a, b) => b.compareTo(a));

    // Get today's date normalized to midnight
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    // Check if we have an entry for today or yesterday to start current streak
    final mostRecentDate = dates.first;
    bool hasCurrentStreak = mostRecentDate.isAtSameMomentAs(today) || 
                           mostRecentDate.isAtSameMomentAs(yesterday);

    if (hasCurrentStreak) {
      currentStreak = 1;
      tempStreak = 1;
      
      // Calculate current streak going backwards from the most recent entry
      DateTime expectedDate = mostRecentDate.subtract(const Duration(days: 1));
      
      for (int i = 1; i < dates.length; i++) {
        final currentDate = dates[i];
        
        if (currentDate.isAtSameMomentAs(expectedDate)) {
          // Consecutive day found
          currentStreak++;
          tempStreak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else {
          // Gap found - current streak ends
          break;
        }
      }
    }

    // Calculate longest streak in the entire dataset
    tempStreak = 1;
    DateTime expectedDate = dates[0].subtract(const Duration(days: 1));
    
    for (int i = 1; i < dates.length; i++) {
      final currentDate = dates[i];
      
      if (currentDate.isAtSameMomentAs(expectedDate)) {
        // Consecutive day found
        tempStreak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        // Gap found - update longest if current temp is longer
        longestStreak = math.max(longestStreak, tempStreak);
        tempStreak = 1;
        expectedDate = currentDate.subtract(const Duration(days: 1));
      }
    }
    
    // Check final streak
    longestStreak = math.max(longestStreak, tempStreak);
    
    // Ensure longest streak includes current streak
    longestStreak = math.max(longestStreak, currentStreak);

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
  /// ✅ NEW: Get intelligent insights based on user data patterns
  Future<Map<String, dynamic>> _getIntelligentInsights(Database db, int userId, DateTime start, DateTime end) async {
    try {
      final insights = <String, dynamic>{};
      
      // Analyze mood volatility
      final moodVolatility = await _analyzeMoodVolatility(db, userId, start, end);
      insights['mood_volatility'] = moodVolatility;
      
      // Detect stress patterns
      final stressPatterns = await _detectStressPatterns(db, userId, start, end);
      insights['stress_patterns'] = stressPatterns;
      
      // Energy optimization opportunities
      final energyOptimization = await _findEnergyOptimization(db, userId, start, end);
      insights['energy_optimization'] = energyOptimization;
      
      // Best performance days analysis
      final bestDays = await _analyzeBestPerformanceDays(db, userId, start, end);
      insights['best_performance_days'] = bestDays;
      
      return insights;
    } catch (e) {
      _logger.e('❌ Error generating intelligent insights: $e');
      return {};
    }
  }
  
  /// ✅ NEW: Get personalized recommendations based on user patterns
  Future<List<Map<String, dynamic>>> _getPersonalizedRecommendations(Database db, int userId, int days) async {
    try {
      final recommendations = <Map<String, dynamic>>[];
      
      // Analyze recent trends
      final recentTrends = await _analyzeRecentTrends(db, userId, days);
      
      // Generate recommendations based on patterns
      if (recentTrends['declining_mood'] == true) {
        recommendations.add({
          'type': 'mood_support',
          'priority': 'high',
          'title': 'Apoyo para el Estado de Ánimo',
          'description': 'Hemos notado una tendencia descendente en tu estado de ánimo. Considera estas estrategias.',
          'actions': [
            'Practica ejercicios de respiración profunda',
            'Conecta con un amigo o familiar',
            'Dedica tiempo a actividades que disfrutes'
          ],
          'estimated_impact': 'alto',
          'timeframe': '3-7 días'
        });
      }
      
      if (recentTrends['high_stress'] == true) {
        recommendations.add({
          'type': 'stress_management',
          'priority': 'high',
          'title': 'Gestión del Estrés',
          'description': 'Tus niveles de estrés han estado altos. Prueba estas técnicas.',
          'actions': [
            'Meditación de 10 minutos diarios',
            'Establece límites en el trabajo',
            'Practica la técnica 4-7-8 de respiración'
          ],
          'estimated_impact': 'alto',
          'timeframe': '1-2 semanas'
        });
      }
      
      if (recentTrends['low_energy'] == true) {
        recommendations.add({
          'type': 'energy_boost',
          'priority': 'medium',
          'title': 'Aumento de Energía',
          'description': 'Tu energía ha estado baja. Considera estos cambios.',
          'actions': [
            'Revisa tu horario de sueño',
            'Incorpora ejercicio ligero',
            'Evalúa tu alimentación'
          ],
          'estimated_impact': 'medio',
          'timeframe': '1-3 semanas'
        });
      }
      
      return recommendations;
    } catch (e) {
      _logger.e('❌ Error generating personalized recommendations: $e');
      return [];
    }
  }
  
  /// ✅ NEW: Analyze emotional patterns and cycles
  Future<Map<String, dynamic>> _getEmotionalPatterns(Database db, int userId, DateTime start, DateTime end) async {
    try {
      // Weekly patterns
      final weeklyPatterns = await db.rawQuery('''
        SELECT 
          CASE 
            WHEN strftime('%w', entry_date) = '0' THEN 'Sunday'
            WHEN strftime('%w', entry_date) = '1' THEN 'Monday'
            WHEN strftime('%w', entry_date) = '2' THEN 'Tuesday'
            WHEN strftime('%w', entry_date) = '3' THEN 'Wednesday'
            WHEN strftime('%w', entry_date) = '4' THEN 'Thursday'
            WHEN strftime('%w', entry_date) = '5' THEN 'Friday'
            WHEN strftime('%w', entry_date) = '6' THEN 'Saturday'
          END as day_of_week,
          AVG(mood_score) as avg_mood,
          AVG(energy_level) as avg_energy,
          AVG(stress_level) as avg_stress,
          COUNT(*) as entries_count
        FROM daily_entries 
        WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        GROUP BY strftime('%w', entry_date)
        ORDER BY strftime('%w', entry_date)
      ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);
      
      // Monthly patterns (if enough data)
      final monthlyPatterns = await _getMonthlyEmotionalPatterns(db, userId);
      
      // Emotional stability index
      final stabilityIndex = await _calculateEmotionalStability(db, userId, start, end);
      
      return {
        'weekly_patterns': weeklyPatterns,
        'monthly_patterns': monthlyPatterns,
        'emotional_stability_index': stabilityIndex,
        'pattern_insights': _generatePatternInsights(weeklyPatterns),
      };
    } catch (e) {
      _logger.e('❌ Error analyzing emotional patterns: $e');
      return {};
    }
  }
  
  /// ✅ NEW: Analyze lifestyle correlations with wellbeing
  Future<Map<String, dynamic>> _getLifestyleCorrelations(Database db, int userId, DateTime start, DateTime end) async {
    try {
      final correlations = <String, dynamic>{};
      
      // Sleep quality vs mood correlation
      final sleepMoodCorr = await _calculateCorrelation(db, userId, 'sleep_quality', 'mood_score', start, end);
      correlations['sleep_mood_correlation'] = sleepMoodCorr;
      
      // Exercise vs energy correlation
      final exerciseEnergyCorr = await _calculateCorrelation(db, userId, 'physical_activity', 'energy_level', start, end);
      correlations['exercise_energy_correlation'] = exerciseEnergyCorr;
      
      // Social interaction vs mood correlation
      final socialMoodCorr = await _calculateCorrelation(db, userId, 'social_interaction', 'mood_score', start, end);
      correlations['social_mood_correlation'] = socialMoodCorr;
      
      // Screen time vs stress correlation
      final screenStressCorr = await _calculateCorrelation(db, userId, 'screen_time_hours', 'stress_level', start, end);
      correlations['screen_stress_correlation'] = screenStressCorr;
      
      // Generate insights from correlations
      correlations['insights'] = _generateCorrelationInsights(correlations);
      
      return correlations;
    } catch (e) {
      _logger.e('❌ Error analyzing lifestyle correlations: $e');
      return {};
    }
  }
  
  /// ✅ NEW: Calculate data quality score
  Future<double> _calculateDataQualityScore(Database db, int userId, DateTime start, DateTime end) async {
    try {
      final totalDays = end.difference(start).inDays;
      
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as entries_with_data,
          COUNT(CASE WHEN mood_score IS NOT NULL THEN 1 END) as mood_entries,
          COUNT(CASE WHEN energy_level IS NOT NULL THEN 1 END) as energy_entries,
          COUNT(CASE WHEN stress_level IS NOT NULL THEN 1 END) as stress_entries,
          COUNT(CASE WHEN free_reflection IS NOT NULL AND free_reflection != '' THEN 1 END) as reflection_entries
        FROM daily_entries 
        WHERE user_id = ? AND entry_date BETWEEN ? AND ?
      ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);
      
      if (result.isEmpty) return 0.0;
      
      final data = result.first;
      final entriesWithData = (data['entries_with_data'] as int?) ?? 0;
      final moodEntries = (data['mood_entries'] as int?) ?? 0;
      final energyEntries = (data['energy_entries'] as int?) ?? 0;
      final stressEntries = (data['stress_entries'] as int?) ?? 0;
      final reflectionEntries = (data['reflection_entries'] as int?) ?? 0;
      
      // Calculate completeness scores
      final completenessScore = entriesWithData / totalDays;
      final dataRichnessScore = (moodEntries + energyEntries + stressEntries + reflectionEntries) / (totalDays * 4);
      
      return ((completenessScore + dataRichnessScore) / 2).clamp(0.0, 1.0);
    } catch (e) {
      _logger.e('❌ Error calculating data quality score: $e');
      return 0.0;
    }
  }
  
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
  
  // ============================================================================
  // 🧠 INTELLIGENT ANALYTICS HELPER METHODS
  // ============================================================================
  
  /// Analyze mood volatility patterns
  Future<Map<String, dynamic>> _analyzeMoodVolatility(Database db, int userId, DateTime start, DateTime end) async {
    final moodData = await db.rawQuery('''
      SELECT mood_score, entry_date
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ? AND mood_score IS NOT NULL
      ORDER BY entry_date
    ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);
    
    if (moodData.length < 3) {
      return {'volatility_level': 'insufficient_data', 'stability_score': 0.0};
    }
    
    final moods = moodData.map((e) => (e['mood_score'] as int).toDouble()).toList();
    final mean = moods.reduce((a, b) => a + b) / moods.length;
    final variance = moods.map((m) => math.pow(m - mean, 2)).reduce((a, b) => a + b) / moods.length;
    final stdDev = math.sqrt(variance);
    
    String volatilityLevel;
    if (stdDev < 1.0) {
      volatilityLevel = 'very_stable';
    } else if (stdDev < 1.5) {
      volatilityLevel = 'stable';
    } else if (stdDev < 2.0) {
      volatilityLevel = 'moderate';
    } else if (stdDev < 2.5) {
      volatilityLevel = 'volatile';
    } else {
      volatilityLevel = 'very_volatile';
    }
    
    return {
      'volatility_level': volatilityLevel,
      'stability_score': (1.0 - (stdDev / 5.0)).clamp(0.0, 1.0),
      'standard_deviation': stdDev,
      'mean_mood': mean,
      'data_points': moods.length,
    };
  }
  
  /// Detect stress patterns and triggers
  Future<Map<String, dynamic>> _detectStressPatterns(Database db, int userId, DateTime start, DateTime end) async {
    final stressData = await db.rawQuery('''
      SELECT 
        stress_level, 
        entry_date,
        strftime('%w', entry_date) as day_of_week,
        (SELECT GROUP_CONCAT(value) FROM (SELECT DISTINCT value FROM json_each(positive_tags) UNION SELECT DISTINCT value FROM json_each(negative_tags))) as tags
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ? AND stress_level IS NOT NULL
    ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);
    
    if (stressData.length < 5) {
      return {'stress_level': 'insufficient_data', 'common_triggers': []};
    }
    
    final highStressDays = stressData.where((s) => (s['stress_level'] as int) >= 7).toList();
    
    if (highStressDays.isEmpty) {
      return {'stress_level': 'low', 'common_triggers': []};
    }
    
    // Analyze common triggers on high-stress days
    final triggerCounts = <String, int>{};
    for (final day in highStressDays) {
      final tags = (day['tags'] as String? ?? '').split(',');
      for (final tag in tags) {
        if (tag.isNotEmpty) {
          triggerCounts[tag] = (triggerCounts[tag] ?? 0) + 1;
        }
      }
    }
    
    final sortedTriggers = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return {
      'stress_level': 'high',
      'high_stress_days': highStressDays.length,
      'common_triggers': sortedTriggers.take(3).map((e) => e.key).toList(),
    };
  }
  
  /// Find energy optimization opportunities
  Future<Map<String, dynamic>> _findEnergyOptimization(Database db, int userId, DateTime start, DateTime end) async {
    final energyData = await db.rawQuery('''
      SELECT 
        energy_level, 
        physical_activity, 
        sleep_hours, 
        social_interaction
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ? 
        AND energy_level IS NOT NULL
    ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);
    
    if (energyData.length < 5) {
      return {'optimization_areas': ['insufficient_data']};
    }
    
    final lowEnergyDays = energyData.where((e) => (e['energy_level'] as int) <= 4).toList();
    
    if (lowEnergyDays.isEmpty) {
      return {'optimization_areas': ['none']};
    }
    
    // Analyze factors on low-energy days
    final optimizationAreas = <String>{};
    for (final day in lowEnergyDays) {
      if ((day['sleep_hours'] as double? ?? 8.0) < 7.0) {
        optimizationAreas.add('sleep');
      }
      if ((day['physical_activity'] as int? ?? 5) < 5) {
        optimizationAreas.add('exercise');
      }
      if ((day['social_interaction'] as int? ?? 5) < 5) {
        optimizationAreas.add('social_balance');
      }
    }
    
    return {
      'optimization_areas': optimizationAreas.toList(),
      'low_energy_day_count': lowEnergyDays.length,
    };
  }
  
  /// Analyze characteristics of best performance days
  Future<Map<String, dynamic>> _analyzeBestPerformanceDays(Database db, int userId, DateTime start, DateTime end) async {
    final performanceData = await db.rawQuery('''
      SELECT 
        (mood_score + energy_level + (10 - stress_level)) / 3.0 as performance_score,
        physical_activity, 
        sleep_hours, 
        social_interaction, 
        meditation_minutes
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ? 
        AND mood_score IS NOT NULL AND energy_level IS NOT NULL AND stress_level IS NOT NULL
      ORDER BY performance_score DESC
      LIMIT 5
    ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);
    
    if (performanceData.isEmpty) {
      return {'common_factors': ['insufficient_data']};
    }
    
    // Analyze common factors on best days
    final commonFactors = <String, int>{};
    for (final day in performanceData) {
      if ((day['sleep_hours'] as double? ?? 0.0) >= 7.5) {
        commonFactors['good_sleep'] = (commonFactors['good_sleep'] ?? 0) + 1;
      }
      if ((day['physical_activity'] as int? ?? 0) >= 7) {
        commonFactors['high_exercise'] = (commonFactors['high_exercise'] ?? 0) + 1;
      }
      if ((day['meditation_minutes'] as int? ?? 0) > 0) {
        commonFactors['meditation'] = (commonFactors['meditation'] ?? 0) + 1;
      }
      if ((day['social_interaction'] as int? ?? 0) >= 7) {
        commonFactors['quality_social_time'] = (commonFactors['quality_social_time'] ?? 0) + 1;
      }
    }
    
    final sortedFactors = commonFactors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return {
      'common_factors': sortedFactors.map((e) => e.key).toList(),
      'average_top_performance_score': performanceData.map((d) => d['performance_score'] as double).reduce((a, b) => a + b) / performanceData.length,
    };
  }
  
  /// Analyze recent trends for recommendations
  Future<Map<String, bool>> _analyzeRecentTrends(Database db, int userId, int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    final trends = await db.rawQuery('''
      SELECT 
        AVG(mood_score) as avg_mood,
        AVG(stress_level) as avg_stress,
        AVG(energy_level) as avg_energy
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
    ''', [userId, startDate.toIso8601String().split('T')[0], endDate.toIso8601String().split('T')[0]]);
    
    if (trends.isEmpty || trends.first['avg_mood'] == null) {
      return {'declining_mood': false, 'high_stress': false, 'low_energy': false};
    }
    
    final data = trends.first;
    return {
      'declining_mood': (data['avg_mood'] as double) < 5.0,
      'high_stress': (data['avg_stress'] as double) >= 7.0,
      'low_energy': (data['avg_energy'] as double) < 5.0,
    };
  }
  
  /// Get monthly emotional patterns
  Future<List<Map<String, dynamic>>> _getMonthlyEmotionalPatterns(Database db, int userId) async {
    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', entry_date) as month,
        AVG(mood_score) as avg_mood
      FROM daily_entries 
      WHERE user_id = ?
      GROUP BY month
      ORDER BY month DESC
      LIMIT 6
    ''', [userId]);
  }
  
  /// Calculate emotional stability index
  Future<double> _calculateEmotionalStability(Database db, int userId, DateTime start, DateTime end) async {
    final result = await db.rawQuery('''
      SELECT mood_score FROM daily_entries
      WHERE user_id = ? AND entry_date BETWEEN ? AND ? AND mood_score IS NOT NULL
    ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);
    
    if (result.length < 2) return 0.5; // Neutral stability if not enough data
    
    final moods = result.map((r) => (r['mood_score'] as int).toDouble()).toList();
    final mean = moods.reduce((a, b) => a + b) / moods.length;
    final variance = moods.map((m) => math.pow(m - mean, 2)).reduce((a, b) => a + b) / moods.length;
    final stdDev = math.sqrt(variance);
    
    // Normalize to a 0-1 scale where 1 is very stable
    return (1 - (stdDev / 5.0)).clamp(0.0, 1.0);
  }
  
  /// Calculate Pearson correlation between two variables
  Future<double> _calculateCorrelation(Database db, int userId, String var1, String var2, DateTime start, DateTime end) async {
    final data = await db.rawQuery('''
      SELECT $var1, $var2 FROM daily_entries
      WHERE user_id = ? AND entry_date BETWEEN ? AND ? AND $var1 IS NOT NULL AND $var2 IS NOT NULL
    ''', [userId, start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]]);
    
    if (data.length < 5) return 0.0; // Not enough data for meaningful correlation
    
    final n = data.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
    
    for (final row in data) {
      final x = (row[var1] as num).toDouble();
      final y = (row[var2] as num).toDouble();
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
      sumY2 += y * y;
    }
    
    final numerator = n * sumXY - sumX * sumY;
    final denominator = math.sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
    
    if (denominator == 0) return 0.0;
    
    return (numerator / denominator).clamp(-1.0, 1.0);
  }
  
  /// Generate insights from correlation data
  List<String> _generateCorrelationInsights(Map<String, dynamic> correlations) {
    final insights = <String>[];
    
    if ((correlations['sleep_mood_correlation'] ?? 0.0) > 0.3) {
      insights.add('Dormir mejor parece mejorar tu estado de ánimo.');
    }
    if ((correlations['exercise_energy_correlation'] ?? 0.0) > 0.3) {
      insights.add('El ejercicio es un gran impulsor de tu energía.');
    }
    if ((correlations['social_mood_correlation'] ?? 0.0) > 0.3) {
      insights.add('Las interacciones sociales tienen un impacto positivo en ti.');
    }
    if ((correlations['screen_stress_correlation'] ?? 0.0) > 0.3) {
      insights.add('El tiempo de pantalla podría estar relacionado con tu estrés.');
    }
    
    if (insights.isEmpty) {
      insights.add('No se encontraron correlaciones fuertes en tus datos recientes.');
    }
    
    return insights;
  }
  
  /// Generate insights from weekly patterns
  List<String> _generatePatternInsights(List<Map<String, dynamic>> weeklyPatterns) {
    if (weeklyPatterns.isEmpty) return [];
    
    final insights = <String>[];
    final bestDay = weeklyPatterns.reduce((a, b) => (a['avg_mood'] as double) > (b['avg_mood'] as double) ? a : b);
    final worstDay = weeklyPatterns.reduce((a, b) => (a['avg_mood'] as double) < (b['avg_mood'] as double) ? a : b);
    
    insights.add('Tu mejor día de la semana suele ser el ${bestDay['day_of_week']}.');
    insights.add('El ${worstDay['day_of_week']} podría ser un buen día para planificar autocuidado.');
    
    return insights;
  }

  // ============================================================================
  // MÉTODOS PARA GOALS
  // ============================================================================

  /// ✅ **MÉTODO CORREGIDO Y SEGURO**
  /// Crea un nuevo objetivo validando el tipo y usando transacciones.
  Future<int?> createGoalSafe({
    required int userId,
    required String title,
    required String description,
    required String type,
    required double targetValue,
  }) async {
    try {
      final db = await database;

      // ✅ **PASO 1: VALIDAR EL TIPO DE GOAL**
      final allowedTypes = [
        'consistency',
        'mood',
        'positiveMoments',
        'stressReduction'
      ];
      final normalizedType = type.trim();

      if (!allowedTypes.contains(normalizedType)) {
        _logger.e('❌ Tipo de goal no válido: $normalizedType');
        return null;
      }

      // ✅ **PASO 2: USAR TRANSACCIÓN PARA INSERCIÓN SEGURA**
      return await db.transaction((txn) async {
        final goalId = await txn.insert('user_goals', {
          'user_id': userId,
          'title': title.trim(),
          'description': description.trim(),
          'type': normalizedType, // ✅ Tipo validado y normalizado
          'target_value': targetValue,
        });

        if (goalId > 0) {
          _logger.i('✅ Goal creado con ID: $goalId, tipo: $normalizedType');
          return goalId;
        } else {
          _logger.e('❌ Fallo al insertar el goal en la base de datos');
          return null;
        }
      });
    } catch (e) {
      _logger.e('❌ Error creando goal: $e');
      return null;
    }
  }

  /// ✅ **MÉTODO CORREGIDO**
  /// Obtiene todos los objetivos de un usuario.
  Future<List<GoalModel>> getUserGoals(int userId) async {
    try {
      final db = await database;
      final results = await db.query(
        'user_goals',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return results.map((row) => GoalModel.fromDatabase(row)).toList();
    } catch (e) {
      _logger.e('❌ Error obteniendo goals: $e');
      return [];
    }
  }

  /// ✅ **MÉTODO CORREGIDO**
  /// Actualiza el progreso de un objetivo.
  Future<bool> updateGoalProgress(int goalId, double newProgress) async {
    try {
      final db = await database;
      final rowsAffected = await db.update(
        'user_goals',
        {'current_value': newProgress},
        where: 'id = ?',
        whereArgs: [goalId],
      );

      return rowsAffected > 0;
    } catch (e) {
      _logger.e('❌ Error actualizando progreso del goal: $e');
      return false;
    }
  }

  /// ✅ **MÉTODO CORREGIDO**
  /// Añade un objetivo a la base de datos.
  Future<int?> addGoal(int userId, GoalModel goal) async {
    try {
      final db = await database;
      final goalId = await db.insert('user_goals', {
        'user_id': userId,
        'title': goal.title,
        'description': goal.description,
        'type': goal.category.name,
        'target_value': goal.targetValue,
        'current_value': goal.currentValue,
        'status': goal.status.name,
        'created_at': goal.createdAt.millisecondsSinceEpoch ~/ 1000,
      });
      return goalId;
    } catch (e) {
      _logger.e('❌ Error añadiendo goal: $e');
      return null;
    }
  }

  // ============================================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================================

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
      _logger.i('✅ Base de datos cerrada');
    }
  }

  Future<void> deleteDatabase() async {
    try {
      final dbPath = join((await getApplicationDocumentsDirectory()).path, _databaseName);
      await databaseFactory.deleteDatabase(dbPath);
      _database = null;
      _logger.i('🗑️ Base de datos eliminada');
    } catch (e) {
      _logger.e('❌ Error eliminando base de datos: $e');
    }
  }

  Future<bool> hasAnyUsers() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      return (result.first['count'] as int) > 0;
    } catch (e) {
      _logger.e('Error checking for users: $e');
      return false;
    }
  }

  Future<OptimizedUserModel?> getFirstUser() async {
    try {
      final db = await database;
      final results = await db.query('users', limit: 1);
      if (results.isNotEmpty) {
        return OptimizedUserModel.fromDatabase(results.first);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting first user: $e');
      return null;
    }
  }

  Future<OptimizedUserModel?> createDeveloperAccount() async {
    final devEmail = 'dev@test.com';
    final existingUser = await getUserById(1);
    if (existingUser != null) {
      return existingUser;
    }

    return await createUser(
      email: devEmail,
      password: 'devpassword',
      name: 'Developer',
      bio: 'App developer and tester',
    );
  }

  // ============================================================================
  // ADVANCED ANALYTICS METHODS - PLACEHOLDERS
  // ============================================================================

  Future<Map<String, dynamic>> getAdvancedTimeSeriesAnalysis(int userId) async {
    // Placeholder for advanced time series analysis
    await Future.delayed(const Duration(milliseconds: 150));
    return {
      'seasonal_trends': {'weekly': 'peak_on_fridays', 'monthly': 'stable'},
      'anomaly_detection': ['2023-10-28'],
    };
  }

  Future<Map<String, dynamic>> getMLInspiredPatternAnalysis(int userId) async {
    // Placeholder for ML-inspired pattern analysis
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'top_pattern': {
        'day_of_week': 'saturday',
        'mood_description': 'high_energy_positive_mood',
        'confidence': 0.85,
      },
      'cluster_analysis': ['work-focused', 'social-relaxed'],
    };
  }

  Future<Map<String, dynamic>> getCausalInferenceAnalysis(int userId) async {
    // Placeholder for causal inference analysis
    await Future.delayed(const Duration(milliseconds: 180));
    return {
      'significant_correlations': [
        {'variable1': 'exercise', 'variable2': 'energy_level', 'correlation': 0.65},
        {'variable1': 'sleep_hours', 'variable2': 'mood_score', 'correlation': 0.55},
      ],
    };
  }

  Future<Map<String, dynamic>> getUltraAdvancedPrediction(int userId) async {
    // Placeholder for ultra-advanced prediction
    await Future.delayed(const Duration(milliseconds: 250));
    return {
      'forecast': [
        {'day': 1, 'predicted_wellbeing': 7.8, 'confidence_interval': {'lower': 7.2, 'upper': 8.4}},
        {'day': 2, 'predicted_wellbeing': 8.1, 'confidence_interval': {'lower': 7.5, 'upper': 8.7}},
      ],
      'overall_trend': 'positive',
      'confidence_score': 0.92,
    };
  }

  Future<List<Map<String, dynamic>>> getMoodCalendarData(int userId, {int days = 30}) async {
    // Placeholder for mood calendar data
    await Future.delayed(const Duration(milliseconds: 100));
    final random = math.Random();
    return List.generate(days, (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      return {
        'date': date.toIso8601String(),
        'mood_score': 3 + random.nextInt(7),
      };
    });
  }

  /// Clear all users from the database
  Future<bool> clearAllUsers() async {
    try {
      final db = await database;
      await db.delete('users');
      _logger.i('✅ All users cleared from database');
      return true;
    } catch (e) {
      _logger.e('❌ Error clearing all users: $e');
      return false;
    }
  }
}