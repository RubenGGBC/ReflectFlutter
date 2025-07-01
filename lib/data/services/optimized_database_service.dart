// ============================================================================
// data/services/optimized_database_service.dart - VERSIÓN FINAL PARA APK
// ============================================================================
import 'package:flutter/material.dart'; // Para los Colors en getMoodCalendarData

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

// ✅ SOLO imports de modelos optimizados
import '../models/optimized_models.dart';

class OptimizedDatabaseService {
  static const String _databaseName = 'reflect_optimized2.db';
  static const int _databaseVersion = 3;

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
      await db.execute('PRAGMA cache_size = -1000'); // 1MB cache (reducido para APK)
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

        // TABLA ENTRADAS DIARIAS - Compatible con APK
        await txn.execute('''
          CREATE TABLE daily_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            entry_date TEXT NOT NULL,
            free_reflection TEXT NOT NULL,
            positive_tags TEXT DEFAULT '[]',
            negative_tags TEXT DEFAULT '[]',
            worth_it INTEGER,
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

        await _createOptimizedIndexes(txn);

        _logger.i('✅ Esquema optimizado creado exitosamente para APK');

      } catch (e) {
        _logger.e('❌ Error creando esquema: $e');
        rethrow;
      }
    });
  }

  Future<void> _createOptimizedIndexes(Transaction txn) async {
    // Índices optimizados para APK
    await txn.execute('CREATE INDEX idx_users_email ON users (email)');
    await txn.execute('CREATE INDEX idx_users_active ON users (is_active, last_login)');
    await txn.execute('CREATE INDEX idx_daily_entries_user_date ON daily_entries (user_id, entry_date)');
    await txn.execute('CREATE INDEX idx_daily_entries_created ON daily_entries (created_at DESC)');
    await txn.execute('CREATE INDEX idx_daily_entries_mood ON daily_entries (user_id, mood_score, entry_date)');
    await txn.execute('CREATE INDEX idx_moments_user_date ON interactive_moments (user_id, entry_date)');
    await txn.execute('CREATE INDEX idx_moments_type ON interactive_moments (user_id, type, timestamp)');
    await txn.execute('CREATE INDEX idx_moments_category ON interactive_moments (user_id, category)');
    await txn.execute('CREATE INDEX idx_moments_timeline ON interactive_moments (user_id, timestamp DESC)');
    await txn.execute('CREATE INDEX idx_tags_user_type ON tags (user_id, type)');
    await txn.execute('CREATE INDEX idx_tags_usage ON tags (usage_count DESC, last_used DESC)');
  }

  Future<void> _upgradeSchema(Database db, int oldVersion, int newVersion) async {
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
    String? profilePicturePath,
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
    String? profilePicturePath, // ✅ NUEVO PARÁMETRO
  }) async {
    try {
      final db = await database;
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name.trim();
      if (bio != null) updates['bio'] = bio;
      if (avatarEmoji != null) updates['avatar_emoji'] = avatarEmoji;
      if (profilePicturePath != null) {
        updates['profile_picture_path'] = profilePicturePath; // ✅ NUEVO
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
  // 🚀 MÉTODOS DE ANALYTICS AVANZADOS - AGREGAR ESTA SECCIÓN COMPLETA AQUÍ
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

      // ✅ MANEJO SEGURO DE GENERACIÓN DE DATOS PARA APK
      try {
        await generateComprehensiveTestData(userId);
      } catch (e) {
        _logger.w('⚠️ Error generando datos de prueba (no crítico): $e');
      }

      return await getUserById(userId);

    } catch (e) {
      _logger.e('❌ Error creando cuenta desarrollador: $e');

      // ✅ RETORNAR NULL EN LUGAR DE RETHROW PARA APK
      return null;
    }
  }

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
      // No rethrow para no romper la creación de usuario
    }
  }

  Future<void> _generateHistoricalData(int userId, Database db) async {
    _logger.i('📈 Generando datos históricos con patrones...');

    final now = DateTime.now();
    final random = math.Random();

    // Fases para simular una historia realista
    final phases = [
      _PersonalityPhase('Período Difícil', -90, -61, 3.5, 4.0, 7.5),
      _PersonalityPhase('Recuperación Gradual', -60, -31, 5.0, 5.5, 6.0),
      _PersonalityPhase('Fase de Crecimiento', -30, -1, 7.5, 8.0, 3.5),
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

}


// ============================================================================
// CLASES DE DATOS AUXILIARES
// ============================================================================

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

