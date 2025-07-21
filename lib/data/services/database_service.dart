// ============================================================================
// data/services/database_service.dart - VERSIÓN CORREGIDA Y ROBUSTA
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../models/daily_entry_model.dart';
import '../models/interactive_moment_model.dart';
import '../models/tag_model.dart';

class DatabaseService {

  static const String _databaseName = 'reflect_zen.db';
  static const int _databaseVersion = 1;

  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  final Logger _logger = Logger();

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _logger.i('🧘‍♀️ Inicializando base de datos zen');
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);
      _logger.d('📁 Ruta de la base de datos: $path');
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      _logger.e('❌ Error inicializando base de datos: $e');
      rethrow;
    }
  }

  Future<void> _addMissingColumns(Database db) async {
    try {
      _logger.i('🔧 Verificando columnas de analytics avanzados...');

      final tableInfo = await db.rawQuery("PRAGMA table_info(daily_entries)");
      final existingColumns = tableInfo.map((row) => row['name'] as String).toSet();

      _logger.d('📋 Columnas existentes: $existingColumns');

      final requiredColumns = {
        'energy_level': 'INTEGER DEFAULT 5',
        'sleep_quality': 'INTEGER DEFAULT 5',
        'stress_level': 'INTEGER DEFAULT 5',
        'anxiety_level': 'INTEGER DEFAULT 5',
        'motivation_level': 'INTEGER DEFAULT 5',
        'social_interaction': 'INTEGER DEFAULT 5',
        'physical_activity': 'INTEGER DEFAULT 5',
        'work_productivity': 'INTEGER DEFAULT 5',
        'sleep_hours': 'REAL DEFAULT 7.0',
        'water_intake': 'INTEGER DEFAULT 8',
        'meditation_minutes': 'INTEGER DEFAULT 0',
        'exercise_minutes': 'INTEGER DEFAULT 0',
        'screen_time_hours': 'REAL DEFAULT 6.0',
        'gratitude_items': 'TEXT',
        'weather_mood_impact': 'INTEGER DEFAULT 5',
        'social_battery': 'INTEGER DEFAULT 5',
        'creative_energy': 'INTEGER DEFAULT 5',
        'emotional_stability': 'INTEGER DEFAULT 5',
        'focus_level': 'INTEGER DEFAULT 5',
        'life_satisfaction': 'INTEGER DEFAULT 5',
      };

      for (final entry in requiredColumns.entries) {
        final columnName = entry.key;
        final columnDefinition = entry.value;

        if (!existingColumns.contains(columnName)) {
          _logger.i('➕ Agregando columna: $columnName');
          await db.execute('''
          ALTER TABLE daily_entries 
          ADD COLUMN $columnName $columnDefinition
        ''');
        }
      }

      final momentsTableExists = await _tableExists(db, 'interactive_moments');
      if (!momentsTableExists) {
        _logger.i('📝 Creando tabla interactive_moments...');
        await _createInteractiveMomentsTable(db);
      } else {
        await _updateInteractiveMomentsTable(db);
      }

      _logger.i('✅ Base de datos actualizada con columnas de analytics avanzados');

    } catch (e) {
      _logger.e('❌ Error agregando columnas: $e');
    }
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery('''
    SELECT name FROM sqlite_master 
    WHERE type='table' AND name='$tableName'
  ''');
    return result.isNotEmpty;
  }

  Future<void> _createInteractiveMomentsTable(Database db) async {
    await db.execute('''
    CREATE TABLE interactive_moments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      emoji TEXT NOT NULL,
      text TEXT NOT NULL,
      type TEXT NOT NULL CHECK (type IN ('positive', 'negative', 'neutral')),
      intensity INTEGER DEFAULT 5 CHECK (intensity >= 1 AND intensity <= 10),
      category TEXT DEFAULT 'general',
      context TEXT,
      location TEXT,
      weather TEXT,
      social_context TEXT,
      energy_before INTEGER DEFAULT 5,
      energy_after INTEGER DEFAULT 5,
      mood_before INTEGER DEFAULT 5,
      mood_after INTEGER DEFAULT 5,
      timestamp TEXT NOT NULL DEFAULT (datetime('now')),
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now')),
      entry_date TEXT DEFAULT (date('now')),
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE INDEX idx_interactive_moments_user_date 
    ON interactive_moments (user_id, date(timestamp))
  ''');
  }

  Future<void> _updateInteractiveMomentsTable(Database db) async {
    try {
      final tableInfo = await db.rawQuery("PRAGMA table_info(interactive_moments)");
      final existingColumns = tableInfo.map((row) => row['name'] as String).toSet();

      final requiredMomentsColumns = {
        'intensity': 'INTEGER DEFAULT 5 CHECK (intensity >= 1 AND intensity <= 10)',
        'category': 'TEXT DEFAULT "general"',
        'context': 'TEXT',
        'location': 'TEXT',
        'weather': 'TEXT',
        'social_context': 'TEXT',
        'energy_before': 'INTEGER DEFAULT 5',
        'energy_after': 'INTEGER DEFAULT 5',
        'mood_before': 'INTEGER DEFAULT 5',
        'mood_after': 'INTEGER DEFAULT 5',
        'entry_date': 'TEXT DEFAULT (date(\'now\'))',
      };

      for (final entry in requiredMomentsColumns.entries) {
        final columnName = entry.key;
        final columnDefinition = entry.value;

        if (!existingColumns.contains(columnName)) {
          _logger.i('➕ Agregando columna a interactive_moments: $columnName');
          await db.execute('''
          ALTER TABLE interactive_moments 
          ADD COLUMN $columnName $columnDefinition
        ''');
        }
      }
    } catch (e) {
      _logger.e('❌ Error actualizando interactive_moments: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    _logger.i('✨ Creando esquema de base de datos zen');
    await db.transaction((txn) async {

      await txn.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          name TEXT NOT NULL,
          avatar_emoji TEXT DEFAULT '🧘‍♀️',
          bio TEXT, 
          preferences TEXT DEFAULT '{}',
          created_at TEXT DEFAULT (datetime('now')),
          last_login TEXT
        )
      ''');
      await txn.execute('''
        CREATE TABLE daily_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          free_reflection TEXT NOT NULL,
          positive_tags TEXT DEFAULT '[]',
          negative_tags TEXT DEFAULT '[]',
          worth_it INTEGER,
          overall_sentiment TEXT,
          mood_score INTEGER,
          ai_summary TEXT,
          word_count INTEGER DEFAULT 0,
          created_at TEXT DEFAULT (datetime('now')),
          updated_at TEXT DEFAULT (datetime('now')),
          entry_date TEXT DEFAULT (date('now')),
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      await txn.execute('''
        CREATE TABLE interactive_moments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          emoji TEXT NOT NULL,
          text TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('positive', 'negative', 'neutral')),
          intensity INTEGER DEFAULT 5 CHECK (intensity >= 1 AND intensity <= 10),
          category TEXT DEFAULT 'general',
          context TEXT,
          location TEXT,
          weather TEXT,
          social_context TEXT,
          energy_before INTEGER DEFAULT 5,
          entry_date TEXT DEFAULT (date('now')),
          energy_after INTEGER DEFAULT 5,
          mood_before INTEGER DEFAULT 5,
          mood_after INTEGER DEFAULT 5,
          timestamp TEXT NOT NULL DEFAULT (datetime('now')),
          created_at TEXT NOT NULL DEFAULT (datetime('now')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now')),
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      await txn.execute('''
        CREATE TABLE user_goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          target_value REAL NOT NULL,
          current_value REAL NOT NULL DEFAULT 0.0,
          created_at TEXT DEFAULT (datetime('now')),
          completed_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      await txn.execute('CREATE INDEX idx_user_goals_user_status ON user_goals(user_id, status)');
      await txn.execute('CREATE INDEX idx_daily_entries_user_date ON daily_entries(user_id, entry_date)');
      await txn.execute('CREATE INDEX idx_interactive_moments_user_date ON interactive_moments(user_id, entry_date)');
    });
    _logger.i('✅ Esquema de base de datos zen creado correctamente');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('🔄 Actualizando base de datos de v$oldVersion a v$newVersion');
  }

  Future<void> _onOpen(Database db) async {
    _logger.d('🔓 Base de datos zen abierta');
    await db.execute('PRAGMA foreign_keys = ON');
    await _addMissingColumns(db);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _logger.i('🔒 Base de datos zen cerrada');
    }
  }

  Future<int?> createUser(String email, String password, String name, {String avatarEmoji = '🧘‍♀️'}) async {
    try {
      final db = await database;
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      final userId = await db.insert('users', {
        'email': email,
        'password_hash': passwordHash,
        'name': name,
        'avatar_emoji': avatarEmoji,
        'preferences': '{}',
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      _logger.i('🌸 Usuario zen creado: $email (ID: $userId)');
      return userId;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        _logger.w('⚠️ El email $email ya existe en el santuario');
        return null;
      }
      _logger.e('❌ Error creando usuario zen: $e');
      return null;
    } catch (e) {
      _logger.e('❌ Error inesperado creando usuario: $e');
      return null;
    }
  }

  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final db = await database;
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      final List<Map<String, dynamic>> results = await db.query('users', where: 'email = ? AND password_hash = ?', whereArgs: [email, passwordHash], limit: 1);
      if (results.isEmpty) {
        _logger.w('❌ Credenciales incorrectas para: $email');
        return null;
      }
      final userData = results.first;
      await db.update('users', {'last_login': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [userData['id']]);
      final user = UserModel.fromDatabase(userData);
      _logger.i('🌺 Bienvenido de vuelta: ${user.name}');
      return user;
    } catch (e) {
      _logger.e('❌ Error en login zen: $e');
      return null;
    }
  }

  Future<UserModel?> getUserById(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
      if (results.isEmpty) return null;
      return UserModel.fromDatabase(results.first);
    } catch (e) {
      _logger.e('❌ Error obteniendo usuario $userId: $e');
      return null;
    }
  }

  Future<int?> saveInteractiveMoment(int userId, InteractiveMomentModel moment) async {
    try {
      final db = await database;
      final momentData = moment.toDatabase();
      momentData['user_id'] = userId;
      final momentId = await db.insert('interactive_moments', momentData);
      _logger.d('💾 Momento interactivo guardado: ${moment.emoji} ${moment.text} (ID: $momentId)');
      return momentId;
    } catch (e) {
      _logger.e('❌ Error guardando momento interactivo: $e');
      return null;
    }
  }

  Future<List<InteractiveMomentModel>> getInteractiveMomentsToday(int userId) async {
    try {
      final db = await database;
      final today = DateTime.now().toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> results = await db.query('interactive_moments', where: 'user_id = ? AND entry_date = ?', whereArgs: [userId, today], orderBy: 'timestamp, created_at');
      final moments = results.map((row) => InteractiveMomentModel.fromDatabase(row)).toList();
      _logger.d('📚 Cargados ${moments.length} momentos interactivos de hoy');
      return moments;
    } catch (e) {
      _logger.e('❌ Error obteniendo momentos interactivos: $e');
      return [];
    }
  }

  Future<bool> clearInteractiveMomentsToday(int userId) async {
    try {
      final db = await database;
      final today = DateTime.now().toIso8601String().split('T')[0];
      final deletedCount = await db.delete('interactive_moments', where: 'user_id = ? AND entry_date = ?', whereArgs: [userId, today]);
      _logger.i('🗑️ Eliminados $deletedCount momentos interactivos de hoy');
      return true;
    } catch (e) {
      _logger.e('❌ Error eliminando momentos interactivos: $e');
      return false;
    }
  }

  Future<int?> saveDailyEntry(DailyEntryModel entry) async {
    try {
      final db = await database;
      _logger.d('💾 Guardando entrada para usuario ${entry.userId}');
      final entryDateStr = entry.entryDate.toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> existing = await db.query('daily_entries', where: 'user_id = ? AND entry_date = ?', whereArgs: [entry.userId, entryDateStr], limit: 1);

      if (existing.isNotEmpty) {
        final existingId = existing.first['id'] as int;
        _logger.d('🔄 Actualizando entrada existente $existingId');
        final updateData = entry.toDatabase();
        updateData['updated_at'] = DateTime.now().toIso8601String();
        updateData.remove('id');
        updateData.remove('created_at');
        await db.update('daily_entries', updateData, where: 'id = ?', whereArgs: [existingId]);
        _logger.i('🌸 Entrada zen actualizada (ID: $existingId, Mood: ${entry.moodScore}/10)');
        return existingId;
      } else {
        _logger.d('✨ Creando nueva entrada');
        final entryData = entry.toDatabase();
        entryData.remove('id');
        final entryId = await db.insert('daily_entries', entryData);
        _logger.i('🌸 Entrada zen guardada (ID: $entryId, Mood: ${entry.moodScore}/10)');
        return entryId;
      }
    } catch (e) {
      _logger.e('❌ Error guardando entrada zen: $e');
      return null;
    }
  }

  Future<List<DailyEntryModel>> getUserEntries(int userId, {int limit = 20, int offset = 0}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query('daily_entries', where: 'user_id = ?', whereArgs: [userId], orderBy: 'entry_date DESC, created_at DESC', limit: limit, offset: offset);
      final entries = results.map((row) => DailyEntryModel.fromDatabase(row)).toList();
      _logger.d('🔍 Encontradas ${entries.length} entradas para usuario $userId');
      return entries;
    } catch (e) {
      _logger.e('❌ Error obteniendo entradas zen: $e');
      return [];
    }
  }

  Future<bool> hasSubmittedToday(int userId) async {
    try {
      final db = await database;
      final today = DateTime.now().toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> results = await db.query('daily_entries', where: 'user_id = ? AND entry_date = ?', whereArgs: [userId, today], limit: 1);
      return results.isNotEmpty;
    } catch (e) {
      _logger.e('❌ Error verificando entrada de hoy: $e');
      return false;
    }
  }

  Future<DailyEntryModel?> getDayEntry(int userId, DateTime date) async {
    try {
      final db = await database;
      final dateStr = date.toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> results = await db.query('daily_entries', where: 'user_id = ? AND entry_date = ?', whereArgs: [userId, dateStr], orderBy: 'created_at DESC', limit: 1);
      if (results.isEmpty) return null;
      return DailyEntryModel.fromDatabase(results.first);
    } catch (e) {
      _logger.e('❌ Error obteniendo entrada del día $date: $e');
      return null;
    }
  }

  Future<Map<int, Map<String, int>>> getYearSummary(int userId, int year) async {
    try {
      final db = await database;
      final firstDay = '$year-01-01';
      final lastDay = '$year-12-31';
      final List<Map<String, dynamic>> results = await db.query('daily_entries', columns: ['entry_date', 'positive_tags', 'negative_tags'], where: 'user_id = ? AND entry_date >= ? AND entry_date <= ?', whereArgs: [userId, firstDay, lastDay], orderBy: 'entry_date');
      final Map<int, Map<String, int>> yearData = { for (int m = 1; m <= 12; m++) m: {'positive': 0, 'negative': 0, 'total': 0} };
      for (final row in results) {
        final month = DateTime.parse(row['entry_date'] as String).month;
        int positiveCount = 0;
        int negativeCount = 0;
        try {
          final positiveTagsJson = row['positive_tags'] as String?;
          if (positiveTagsJson != null && positiveTagsJson.isNotEmpty) {
            positiveCount = (json.decode(positiveTagsJson) as List).length;
          }
        } catch (_) {}
        try {
          final negativeTagsJson = row['negative_tags'] as String?;
          if (negativeTagsJson != null && negativeTagsJson.isNotEmpty) {
            negativeCount = (json.decode(negativeTagsJson) as List).length;
          }
        } catch (_) {}
        yearData[month]!['positive'] = yearData[month]!['positive']! + positiveCount;
        yearData[month]!['negative'] = yearData[month]!['negative']! + negativeCount;
        yearData[month]!['total'] = yearData[month]!['total']! + positiveCount + negativeCount;
      }
      return yearData;
    } catch (e) {
      _logger.e('❌ Error obteniendo resumen del año $year: $e');
      return { for (int m = 1; m <= 12; m++) m: {'positive': 0, 'negative': 0, 'total': 0} };
    }
  }

  Future<Map<int, Map<String, dynamic>>> getMonthSummary(int userId, int year, int month) async {
    try {
      final db = await database;
      final firstDay = '$year-${month.toString().padLeft(2, '0')}-01';
      final lastDayDate = (month == 12) ? DateTime(year + 1, 1, 0) : DateTime(year, month + 1, 0);
      final lastDay = lastDayDate.toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> results = await db.query('daily_entries', columns: ['entry_date', 'positive_tags', 'negative_tags', 'worth_it'], where: 'user_id = ? AND entry_date >= ? AND entry_date <= ?', whereArgs: [userId, firstDay, lastDay], orderBy: 'entry_date');
      final Map<int, Map<String, dynamic>> monthData = {};
      for (final row in results) {
        final day = DateTime.parse(row['entry_date'] as String).day;
        int positiveCount = 0;
        int negativeCount = 0;
        try {
          final positiveTagsJson = row['positive_tags'] as String?;
          if (positiveTagsJson != null && positiveTagsJson.isNotEmpty) {
            positiveCount = (json.decode(positiveTagsJson) as List).length;
          }
        } catch (_) {}
        try {
          final negativeTagsJson = row['negative_tags'] as String?;
          if (negativeTagsJson != null && negativeTagsJson.isNotEmpty) {
            negativeCount = (json.decode(negativeTagsJson) as List).length;
          }
        } catch (_) {}
        bool? worthItBool;
        final worthItInt = row['worth_it'] as int?;
        if (worthItInt != null) worthItBool = worthItInt == 1;
        monthData[day] = {'positive': positiveCount, 'negative': negativeCount, 'submitted': true, 'worth_it': worthItBool};
      }
      return monthData;
    } catch (e) {
      _logger.e('❌ Error obteniendo resumen del mes $year-$month: $e');
      return {};
    }
  }

  Future<int> getEntryCount(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.rawQuery('SELECT COUNT(*) as count FROM daily_entries WHERE user_id = ?', [userId]);
      return (results.first['count'] as int?) ?? 0;
    } catch (e) {
      _logger.e('❌ Error obteniendo contador zen: $e');
      return 0;
    }
  }

  Future<int?> saveInteractiveMomentsAsEntry(int userId, {String? reflection, bool? worthIt}) async {
    try {
      _logger.i('🔄 Combinando momentos interactivos en entrada diaria para usuario $userId');
      final newMoments = await getInteractiveMomentsToday(userId);
      if (newMoments.isEmpty) {
        _logger.w('⚠️ No hay momentos nuevos para guardar');
        return null;
      }
      final existingEntry = await getDayEntry(userId, DateTime.now());
      List<TagModel> combinedPositiveTags = [];
      List<TagModel> combinedNegativeTags = [];
      String combinedReflection = reflection ?? '';
      if (existingEntry != null) {
        _logger.d('📝 Combinando con entrada existente');
        combinedPositiveTags.addAll(existingEntry.positiveTags.map((tag) => TagModel(name: tag, context: '', emoji: '')));
        combinedNegativeTags.addAll(existingEntry.negativeTags.map((tag) => TagModel(name: tag, context: '', emoji: '')));
        if (existingEntry.freeReflection.isNotEmpty) {
          combinedReflection = existingEntry.freeReflection;
          if (reflection != null && reflection.isNotEmpty) {
            combinedReflection += '\n\n--- Momentos añadidos ---\n$reflection';
          }
        }
      }
      final newPositiveTags = newMoments.where((m) => m.type == 'positive').map((m) => m.toTag()).toList();
      final newNegativeTags = newMoments.where((m) => m.type == 'negative').map((m) => m.toTag()).toList();
      combinedPositiveTags.addAll(newPositiveTags);
      combinedNegativeTags.addAll(newNegativeTags);
      _logger.d('📊 Total combinado: ${combinedPositiveTags.length} positivos, ${combinedNegativeTags.length} negativos');
      final entry = DailyEntryModel.create(
        userId: userId,
        freeReflection: combinedReflection.isNotEmpty ? combinedReflection : 'Momentos registrados a lo largo del día',
        positiveTags: combinedPositiveTags.map((tag) => tag.name).toList(),
        negativeTags: combinedNegativeTags.map((tag) => tag.name).toList(),
        worthIt: worthIt,
      );
      final entryId = await saveDailyEntry(entry);
      if (entryId != null) {
        await clearInteractiveMomentsToday(userId);
        _logger.i('✅ Entrada diaria actualizada con ID: $entryId');
        return entryId;
      } else {
        _logger.e('❌ Error actualizando entrada diaria');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error combinando momentos a entrada: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDayEntryWithTimeline(int userId, DateTime date) async {
    try {
      final db = await database;
      final dateStr = date.toIso8601String().split('T')[0];
      final entry = await getDayEntry(userId, date);
      if (entry == null) return null;
      final List<Map<String, dynamic>> momentsResults = await db.query('interactive_moments', where: 'user_id = ? AND entry_date = ?', whereArgs: [userId, dateStr], orderBy: 'timestamp ASC, created_at ASC');
      final timeline = momentsResults.map((row) => {
        'time': (row['timestamp'] as String).substring(11, 16),
        'emoji': row['emoji'] as String,
        'text': row['text'] as String,
        'type': row['type'] as String,
        'intensity': row['intensity'] as int,
        'category': row['category'] as String,
        'created_at': row['created_at'] as String,
      }).toList();
      return {
        'entry': entry,
        'timeline': timeline,
        'total_moments': entry.positiveTags.length + entry.negativeTags.length,
        'timeline_moments': timeline.length,
      };
    } catch (e) {
      _logger.e('❌ Error obteniendo entrada con timeline: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getMomentsHourlyStats(int userId, DateTime date) async {
    try {
      final db = await database;
      final dateStr = date.toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT strftime('%H:00', timestamp) as hour, type, COUNT(*) as count, AVG(intensity) as avg_intensity
        FROM interactive_moments 
        WHERE user_id = ? AND entry_date = ?
        GROUP BY hour, type
        ORDER BY hour ASC
      ''', [userId, dateStr]);
      final Map<String, Map<String, dynamic>> hourlyStats = {};
      for (final row in results) {
        final hour = row['hour'] as String;
        if (!hourlyStats.containsKey(hour)) {
          hourlyStats[hour] = {'positive': 0, 'negative': 0, 'neutral': 0, 'total': 0};
        }
        final type = row['type'] as String;
        final count = (row['count'] as int?) ?? 0;
        if (hourlyStats[hour]!.containsKey(type)) {
          hourlyStats[hour]![type] = count;
        }
        hourlyStats[hour]!['total'] = hourlyStats[hour]!['total']! + count;
      }
      return {'hourly_stats': hourlyStats, 'peak_hour': _findPeakHour(hourlyStats), 'total_hours_active': hourlyStats.length};
    } catch (e) {
      _logger.e('❌ Error obteniendo estadísticas por hora: $e');
      return {};
    }
  }

  String? _findPeakHour(Map<String, Map<String, dynamic>> hourlyStats) {
    if (hourlyStats.isEmpty) return null;
    String? peakHour;
    int maxTotal = 0;
    hourlyStats.forEach((hour, stats) {
      final total = (stats['total'] as int?) ?? 0;
      if (total > maxTotal) {
        maxTotal = total;
        peakHour = hour;
      }
    });
    return peakHour;
  }

  Future<Map<String, dynamic>> getUserComprehensiveStatistics(int userId) async {
    try {
      final db = await database;
      final basicResults = await db.rawQuery('SELECT COUNT(*) as total_entries, AVG(mood_score) as avg_mood, SUM(word_count) as total_words FROM daily_entries WHERE user_id = ?', [userId]);
      final basicStats = basicResults.first;
      final totalEntries = (basicStats['total_entries'] as int?) ?? 0;
      final avgMood = (basicStats['avg_mood'] as double?) ?? 5.0;
      final totalWords = (basicStats['total_words'] as int?) ?? 0;
      final tagResults = await db.query('daily_entries', columns: ['positive_tags', 'negative_tags'], where: 'user_id = ?', whereArgs: [userId]);
      int positiveCount = 0;
      int negativeCount = 0;
      for (final row in tagResults) {
        try {
          final positiveTagsJson = row['positive_tags'] as String?;
          if (positiveTagsJson != null && positiveTagsJson.isNotEmpty) positiveCount += (json.decode(positiveTagsJson) as List).length;
        } catch (_) {}
        try {
          final negativeTagsJson = row['negative_tags'] as String?;
          if (negativeTagsJson != null && negativeTagsJson.isNotEmpty) negativeCount += (json.decode(negativeTagsJson) as List).length;
        } catch (_) {}
      }
      final streakDays = await calculateCurrentStreak(userId);
      final currentMonth = DateTime.now().toIso8601String().substring(0, 7);
      final monthResults = await db.rawQuery('SELECT COUNT(*) as entries_this_month FROM daily_entries WHERE user_id = ? AND entry_date LIKE ?', [userId, '$currentMonth%']);
      final entriesThisMonth = (monthResults.first['entries_this_month'] as int?) ?? 0;
      final bestMoodResults = await db.query('daily_entries', columns: ['MAX(mood_score) as best_mood', 'entry_date'], where: 'user_id = ?', whereArgs: [userId], orderBy: 'mood_score DESC', limit: 1);
      final bestMood = bestMoodResults.isNotEmpty ? ((bestMoodResults.first['best_mood'] as int?) ?? 5) : 5;
      final bestMoodDate = bestMoodResults.isNotEmpty ? bestMoodResults.first['entry_date'] as String? : null;
      return {
        'total_entries': totalEntries, 'positive_count': positiveCount, 'negative_count': negativeCount,
        'avg_mood_score': double.parse(avgMood.toStringAsFixed(1)), 'total_words': totalWords, 'streak_days': streakDays,
        'entries_this_month': entriesThisMonth, 'best_mood_score': bestMood, 'best_mood_date': bestMoodDate,
        'total_moments': positiveCount + negativeCount,
      };
    } catch (e) {
      _logger.e('❌ Error obteniendo estadísticas completas: $e');
      return {
        'total_entries': 0, 'positive_count': 0, 'negative_count': 0, 'avg_mood_score': 5.0, 'total_words': 0,
        'streak_days': 0, 'entries_this_month': 0, 'best_mood_score': 5, 'best_mood_date': null, 'total_moments': 0,
      };
    }
  }

  Future<int> calculateCurrentStreak(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query('daily_entries', columns: ['DISTINCT entry_date'], where: 'user_id = ?', whereArgs: [userId], orderBy: 'entry_date DESC');
      if (results.isEmpty) return 0;
      final dates = results.map((row) => DateTime.parse(row['entry_date'] as String)).toList();
      int streak = 0;
      DateTime currentDate = DateTime.now();
      final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
      final latestEntry = DateTime(dates.first.year, dates.first.month, dates.first.day);
      if (latestEntry != today) {
        currentDate = today.subtract(const Duration(days: 1));
      } else {
        currentDate = today;
      }
      for (final entryDate in dates) {
        final entryDay = DateTime(entryDate.year, entryDate.month, entryDate.day);
        final checkDay = DateTime(currentDate.year, currentDate.month, currentDate.day);
        if (entryDay == checkDay) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      return streak;
    } catch (e) {
      _logger.e('❌ Error calculando racha: $e');
      return 0;
    }
  }

  Future<bool> updateUserProfile(int userId, {String? name, String? avatarEmoji,String? profilePicturePath, // ✅ NUEVO PARÁMETRO
    String? bio, Map<String, dynamic>? preferences}) async {
    try {
      final db = await database;
      final List<String> updateFields = [];
      final List<dynamic> values = [];
      if (name != null) { updateFields.add('name = ?'); values.add(name); }
      if (profilePicturePath != null) {
        updateFields.add('profile_picture_path = ?'); values.add(profilePicturePath);
      }
      if (avatarEmoji != null) { updateFields.add('avatar_emoji = ?'); values.add(avatarEmoji); }
      if (bio != null) { updateFields.add('bio = ?'); values.add(bio); }
      if (preferences != null) { updateFields.add('preferences = ?'); values.add(json.encode(preferences)); }
      if (updateFields.isEmpty) { _logger.w('⚠️ No hay campos para actualizar'); return false; }
      updateFields.add('last_login = ?');
      values.add(DateTime.now().toIso8601String());
      values.add(userId);
      final updateCount = await db.rawUpdate('UPDATE users SET ${updateFields.join(', ')} WHERE id = ?', values);
      if (updateCount > 0) { _logger.i('✅ Perfil actualizado para usuario $userId'); return true; }
      else { _logger.e('❌ Usuario $userId no encontrado'); return false; }
    } catch (e) {
      _logger.e('❌ Error actualizando perfil: $e');
      return false;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
      if (results.isEmpty) { _logger.w('❌ Usuario no encontrado: $email'); return null; }
      final user = UserModel.fromDatabase(results.first);
      _logger.d('👤 Usuario encontrado: ${user.name} ($email)');
      return user;
    } catch (e) {
      _logger.e('❌ Error obteniendo usuario por email: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getMoodPatternsByHour(int userId) async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
      SELECT 
        CAST(strftime('%H', timestamp) AS INTEGER) as hour,
        type,
        AVG(intensity) as avg_intensity,
        COUNT(*) as count
      FROM interactive_moments 
      WHERE user_id = ? AND entry_date >= date('now', '-30 days')
      GROUP BY hour, type
      ORDER BY hour ASC
    ''', [userId]);

      final Map<int, Map<String, dynamic>> hourlyData = {};
      String? bestHour, worstHour;
      double bestScore = -11, worstScore = 11;

      for (final row in results) {
        final hour = row['hour'] as int;
        final type = row['type'] as String;
        final avgIntensity = (row['avg_intensity'] as num).toDouble();
        final count = row['count'] as int;

        if (!hourlyData.containsKey(hour)) {
          hourlyData[hour] = {'positive': 0.0, 'negative': 0.0, 'total': 0};
        }

        if(type == 'positive' || type == 'negative') {
          hourlyData[hour]![type] = avgIntensity;
        }
        hourlyData[hour]!['total'] = hourlyData[hour]!['total']! + count;

        final score = (hourlyData[hour]!['positive'] as double) - (hourlyData[hour]!['negative'] as double);

        if (score > bestScore) {
          bestScore = score;
          bestHour = '${hour.toString().padLeft(2, '0')}:00';
        }
        if (score < worstScore) {
          worstScore = score;
          worstHour = '${hour.toString().padLeft(2, '0')}:00';
        }
      }

      return {
        'hourly_data': hourlyData,
        'best_hour': bestHour ?? 'No hay datos suficientes',
        'worst_hour': worstHour ?? 'No hay datos suficientes',
        'peak_energy_time': _findPeakEnergyTime(hourlyData),
        'recommendation': _getHourlyRecommendation(bestHour, worstHour),
      };
    } catch (e) {
      _logger.e('Error analizando patrones por hora: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getMoodEvolution(int userId) async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
      SELECT 
        entry_date,
        AVG(mood_score) as avg_mood,
        COUNT(*) as entries_count
      FROM daily_entries 
      WHERE user_id = ? AND entry_date >= date('now', '-30 days')
      GROUP BY entry_date
      ORDER BY entry_date ASC
    ''', [userId]);

      final List<Map<String, dynamic>> timeline = [];
      double bestMood = 0, worstMood = 10;
      String? bestDay, worstDay;
      double totalImprovement = 0;

      for (int i = 0; i < results.length; i++) {
        final row = results[i];
        final date = row['entry_date'] as String;
        final mood = (row['avg_mood'] as num).toDouble();

        timeline.add({
          'date': date,
          'mood': mood,
          'entries': row['entries_count'],
        });

        if (mood > bestMood) {
          bestMood = mood;
          bestDay = date;
        }
        if (mood < worstMood) {
          worstMood = mood;
          worstDay = date;
        }

        if (i > 0) {
          final prevMood = (results[i-1]['avg_mood'] as num).toDouble();
          totalImprovement += mood - prevMood;
        }
      }

      final trend = totalImprovement > 0 ? 'improving' :
      totalImprovement < -1 ? 'declining' : 'stable';

      return {
        'timeline': timeline,
        'best_day': bestDay,
        'worst_day': worstDay,
        'best_mood': bestMood,
        'worst_mood': worstMood,
        'overall_trend': trend,
        'improvement_score': totalImprovement.toStringAsFixed(1),
        'trend_message': _getTrendMessage(trend, totalImprovement),
      };
    } catch (e) {
      _logger.e('Error analizando evolución del mood: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getUserAchievements(int userId) async {
    try {
      final db = await database;

      final basicStats = await getUserComprehensiveStatistics(userId);
      final streakDays = basicStats['streak_days'] ?? 0;
      final totalEntries = basicStats['total_entries'] ?? 0;
      final totalMoments = basicStats['total_moments'] ?? 0;

      final moodImprovementResult = await db.rawQuery('''
      SELECT 
        AVG(CASE WHEN entry_date >= date('now', '-7 days') THEN mood_score END) as recent_mood,
        AVG(CASE WHEN entry_date < date('now', '-7 days') AND entry_date >= date('now', '-14 days') THEN mood_score END) as prev_mood
      FROM daily_entries 
      WHERE user_id = ?
    ''', [userId]);

      final diversityResult = await db.rawQuery('''
      SELECT COUNT(DISTINCT category) as categories_used
      FROM interactive_moments 
      WHERE user_id = ? AND entry_date >= date('now', '-30 days')
    ''', [userId]);

      final achievements = <Map<String, dynamic>>[];

      if (streakDays >= 1) achievements.add(_createAchievement('🌱', 'Primer Paso', 'Comenzaste tu viaje de reflexión', true, 'bronze'));
      if (streakDays >= 3) achievements.add(_createAchievement('🔥', 'En Racha', 'Mantuviste consistencia por 3 días', true, 'bronze'));
      if (streakDays >= 7) achievements.add(_createAchievement('💪', 'Semana Completa', 'Una semana de reflexión diaria', true, 'silver'));
      if (streakDays >= 30) achievements.add(_createAchievement('💎', 'Dedicación Diamond', '30 días consecutivos', streakDays >= 30, 'gold'));

      if (totalMoments >= 10) achievements.add(_createAchievement('📝', 'Capturador', '10 momentos registrados', true, 'bronze'));
      if (totalMoments >= 50) achievements.add(_createAchievement('🌟', 'Observador', '50 momentos capturados', true, 'silver'));
      if (totalMoments >= 100) achievements.add(_createAchievement('🚀', 'Experto en Momentos', '100 momentos registrados', totalMoments >= 100, 'gold'));

      final recentMood = (moodImprovementResult.first['recent_mood'] as num?)?.toDouble() ?? 5.0;
      final prevMood = (moodImprovementResult.first['prev_mood'] as num?)?.toDouble() ?? 5.0;
      final moodImprovement = recentMood - prevMood;

      if (moodImprovement > 1) achievements.add(_createAchievement('📈', 'En Ascenso', 'Tu mood mejoró esta semana', true, 'silver'));
      if (recentMood >= 8) achievements.add(_createAchievement('😊', 'Estado Zen', 'Mood promedio excelente', true, 'gold'));

      final categoriesUsed = (diversityResult.first['categories_used'] as int?) ?? 0;
      if (categoriesUsed >= 3) achievements.add(_createAchievement('🎨', 'Explorador', 'Usaste múltiples categorías', true, 'bronze'));
      if (categoriesUsed >= 5) achievements.add(_createAchievement('🌈', 'Diversidad Total', 'Exploraste todas las categorías', categoriesUsed >= 5, 'gold'));

      return {
        'achievements': achievements,
        'total_unlocked': achievements.where((a) => a['unlocked']).length,
        'total_possible': achievements.length,
        'completion_percentage': achievements.isEmpty ? 0 : (achievements.where((a) => a['unlocked']).length / achievements.length * 100).round(),
        'next_achievement': _getNextAchievement(achievements, streakDays, totalMoments),
      };
    } catch (e) {
      _logger.e('Error obteniendo logros: $e');
      return {'achievements': [], 'total_unlocked': 0, 'total_possible': 0};
    }
  }

  Future<Map<String, dynamic>> getSentimentAnalysis(int userId) async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
      SELECT free_reflection, positive_tags, negative_tags, mood_score, entry_date
      FROM daily_entries 
      WHERE user_id = ? AND entry_date >= date('now', '-30 days')
    ''', [userId]);

      final Map<String, int> positiveWords = {};
      final Map<String, int> challengeWords = {};
      final List<double> moodHistory = [];

      for (final row in results) {
        final reflection = (row['free_reflection'] as String).toLowerCase();
        final moodScore = (row['mood_score'] as num).toDouble();
        moodHistory.add(moodScore);

        for (final word in _getPositiveKeywords()) {
          if (reflection.contains(word)) {
            positiveWords[word] = (positiveWords[word] ?? 0) + 1;
          }
        }

        for (final word in _getChallengeKeywords()) {
          if (reflection.contains(word)) {
            challengeWords[word] = (challengeWords[word] ?? 0) + 1;
          }
        }
      }

      final topPositive = positiveWords.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topChallenges = challengeWords.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return {
        'top_positive_themes': topPositive.take(5).map((e) => {'word': e.key, 'count': e.value}).toList(),
        'top_challenge_areas': topChallenges.take(3).map((e) => {'word': e.key, 'count': e.value}).toList(),
        'dominant_sentiment': _calculateDominantSentiment(positiveWords, challengeWords),
        'mood_stability': _calculateMoodStability(moodHistory),
        'growth_indicators': _identifyGrowthIndicators(topPositive, moodHistory),
      };
    } catch (e) {
      _logger.e('Error en análisis de sentimiento: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getWeeklyPatterns(int userId) async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
      SELECT 
        CASE CAST(strftime('%w', entry_date) AS INTEGER)
          WHEN 0 THEN 'Domingo'
          WHEN 1 THEN 'Lunes' 
          WHEN 2 THEN 'Martes'
          WHEN 3 THEN 'Miércoles'
          WHEN 4 THEN 'Jueves'
          WHEN 5 THEN 'Viernes'
          WHEN 6 THEN 'Sábado'
        END as day_name,
        strftime('%w', entry_date) as day_num,
        AVG(mood_score) as avg_mood,
        COUNT(*) as entries_count
      FROM daily_entries 
      WHERE user_id = ? AND entry_date >= date('now', '-60 days')
      GROUP BY day_num
      ORDER BY day_num
    ''', [userId]);

      String? bestDay, worstDay;
      double bestMood = 0, worstMood = 10;

      final weeklyData = <Map<String, dynamic>>[];
      for (final row in results) {
        final dayName = row['day_name'] as String;
        final mood = (row['avg_mood'] as num).toDouble();

        weeklyData.add({
          'day': dayName,
          'mood': mood,
          'entries': row['entries_count'],
        });

        if (mood > bestMood) {
          bestMood = mood;
          bestDay = dayName;
        }
        if (mood < worstMood) {
          worstMood = mood;
          bestDay = dayName;
        }
      }

      return {
        'weekly_data': weeklyData,
        'best_day': bestDay ?? 'No hay datos',
        'worst_day': worstDay ?? 'No hay datos',
        'weekend_vs_weekday': _compareWeekendVsWeekday(weeklyData),
        'consistency_score': _calculateWeeklyConsistency(weeklyData),
        'recommendations': _getWeeklyRecommendations(bestDay, worstDay),
      };
    } catch (e) {
      _logger.e('Error analizando patrones semanales: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getPersonalizedInsights(int userId) async {
    try {
      final basicStats = await getUserComprehensiveStatistics(userId);
      final moodEvolution = await getMoodEvolution(userId);
      final hourlyPatterns = await getMoodPatternsByHour(userId);
      final weeklyPatterns = await getWeeklyPatterns(userId);
      final achievements = await getUserAchievements(userId);

      final insights = <Map<String, String>>[];
      final predictions = <Map<String, dynamic>>[];
      final recommendations = <Map<String, String>>[];

      final streak = basicStats['streak_days'] ?? 0;
      final avgMood = basicStats['avg_mood_score'] ?? 5.0;
      final trend = moodEvolution['overall_trend'] ?? 'stable';

      if (streak >= 7) {
        predictions.add({
          'type': 'streak_continuation',
          'probability': 0.85,
          'message': 'Tienes 85% probabilidad de mantener tu racha esta semana',
          'confidence': 'alta'
        });
      }

      if (trend == 'improving') {
        predictions.add({
          'type': 'mood_improvement',
          'probability': 0.75,
          'message': 'Tu mood continuará mejorando si mantienes tus hábitos actuales',
          'confidence': 'alta'
        });
      }

      final bestHour = hourlyPatterns['best_hour'];
      if (bestHour != null) {
        recommendations.add({
          'type': 'timing',
          'emoji': '⏰',
          'title': 'Optimiza tu horario',
          'description': 'Tu mejor momento es a las $bestHour. Planifica actividades importantes entonces.'
        });
      }

      final bestDay = weeklyPatterns['best_day'];
      if (bestDay != null) {
        recommendations.add({
          'type': 'weekly_planning',
          'emoji': '📅',
          'title': 'Planificación semanal',
          'description': 'Los $bestDay son tu mejor día. Úsalos para objetivos importantes.'
        });
      }

      if (streak < 3) {
        recommendations.add({
          'type': 'consistency',
          'emoji': '🎯',
          'title': 'Construye consistencia',
          'description': 'Intenta reflexionar a la misma hora cada día para crear un hábito fuerte.'
        });
      }

      insights.add({
        'emoji': '📈',
        'text': 'Has mostrado ${_getProgressDescription(trend)} en tu bienestar emocional.',
      });

      if (avgMood >= 6) {
        insights.add({
          'emoji': '😊',
          'text': 'Mantienes un equilibrio emocional positivo con ${avgMood.toStringAsFixed(1)}/10 de promedio.',
        });
      }

      final unlockedAchievements = achievements['total_unlocked'] ?? 0;
      if (unlockedAchievements > 0) {
        insights.add({
          'emoji': '🏆',
          'text': 'Has desbloqueado $unlockedAchievements logros. ¡Tu dedicación está dando frutos!',
        });
      }

      return {
        'insights': insights,
        'predictions': predictions,
        'recommendations': recommendations,
        'overall_score': _calculateWellbeingScore(basicStats, moodEvolution, achievements),
        'next_milestone': _getNextMilestone(basicStats, achievements),
      };
    } catch (e) {
      _logger.e('Error generando insights personalizados: $e');
      return {};
    }
  }

  int _calculateWellbeingScore(Map<String, dynamic> basicStats, Map<String, dynamic> moodEvolution, Map<String, dynamic> achievements) {
    double score = 0;

    final streak = basicStats['streak_days'] ?? 0;
    score += (streak / 30 * 30).clamp(0, 30);

    final avgMood = basicStats['avg_mood_score'] ?? 5.0;
    score += (avgMood / 10 * 25).clamp(0, 25);

    final trend = moodEvolution['overall_trend'] ?? 'stable';
    if (trend == 'improving') score += 20;
    else if (trend == 'stable') score += 15;
    else score += 5;

    final achievementPercentage = achievements['completion_percentage'] ?? 0;
    score += (achievementPercentage / 100 * 15).clamp(0, 15);

    final entriesThisMonth = basicStats['entries_this_month'] ?? 0;
    score += (entriesThisMonth / 20 * 10).clamp(0, 10);

    return score.round().clamp(0, 100);
  }

  Map<String, dynamic> _createAchievement(String emoji, String title, String description, bool unlocked, String tier) {
    return {
      'emoji': emoji,
      'title': title,
      'description': description,
      'unlocked': unlocked,
      'tier': tier,
    };
  }

  List<String> _getPositiveKeywords() {
    return [
      'feliz', 'alegre', 'contento', 'satisfecho', 'orgulloso', 'agradecido',
      'exitoso', 'logro', 'conseguí', 'cumplí', 'terminé', 'completé',
      'amor', 'familia', 'amigos', 'conexión', 'apoyo', 'compañía',
      'paz', 'tranquilo', 'relajado', 'sereno', 'equilibrio',
      'energía', 'motivado', 'inspirado', 'creativo', 'productivo'
    ];
  }

  List<String> _getChallengeKeywords() {
    return [
      'estrés', 'estresado', 'agobiado', 'presión', 'ansiedad', 'nervioso',
      'cansado', 'agotado', 'exhausto', 'fatiga', 'sueño',
      'triste', 'deprimido', 'solo', 'vacío', 'melancólico',
      'frustrado', 'molesto', 'irritado', 'enfadado', 'conflicto',
      'difícil', 'complicado', 'problema', 'desafío', 'obstáculo'
    ];
  }

  String _findPeakEnergyTime(Map<int, Map<String, dynamic>> hourlyData) {
    int bestHour = 12;
    double bestScore = 0;

    hourlyData.forEach((hour, data) {
      final score = (data['positive'] as double) - (data['negative'] as double);
      if (score > bestScore) {
        bestScore = score;
        bestHour = hour;
      }
    });

    return '${bestHour.toString().padLeft(2, '0')}:00';
  }

  String _getTrendMessage(String trend, double improvement) {
    switch (trend) {
      case 'improving':
        return '¡Excelente! Tu bienestar está en ascenso (+${improvement.abs().toStringAsFixed(1)})';
      case 'declining':
        return 'Tiempo de cuidarte más. Considera qué está afectando tu bienestar.';
      default:
        return 'Mantienes un estado emocional estable. ¡Bien por la consistencia!';
    }
  }

  String _calculateDominantSentiment(Map<String, int> positive, Map<String, int> challenges) {
    final positiveTotal = positive.values.fold(0, (sum, count) => sum + count);
    final challengeTotal = challenges.values.fold(0, (sum, count) => sum + count);

    if (positiveTotal > challengeTotal * 1.5) return 'muy_positivo';
    if (positiveTotal > challengeTotal) return 'positivo';
    if (challengeTotal > positiveTotal * 1.5) return 'reflexivo';
    return 'equilibrado';
  }

  double _calculateMoodStability(List<double> moodHistory) {
    if (moodHistory.length < 2) return 1.0;

    double variance = 0;
    final mean = moodHistory.reduce((a, b) => a + b) / moodHistory.length;

    for (final mood in moodHistory) {
      variance += (mood - mean) * (mood - mean);
    }

    return (10 - (variance / moodHistory.length)).clamp(0, 10) / 10;
  }

  List<String> _identifyGrowthIndicators(List<MapEntry<String, int>> positiveWords, List<double> moodHistory) {
    final indicators = <String>[];

    if (positiveWords.isNotEmpty && positiveWords.first.value >= 3) {
      indicators.add('Vocabulario positivo frecuente');
    }

    if (moodHistory.length >= 7) {
      final recentMood = moodHistory.skip(moodHistory.length - 3).reduce((a, b) => a + b) / 3;
      final olderMood = moodHistory.take(3).reduce((a, b) => a + b) / 3;
      if (recentMood > olderMood) {
        indicators.add('Tendencia de mejora reciente');
      }
    }

    return indicators;
  }

  Map<String, dynamic> _compareWeekendVsWeekday(List<Map<String, dynamic>> weeklyData) {
    double weekendMood = 0, weekdayMood = 0;
    int weekendCount = 0, weekdayCount = 0;

    for (final day in weeklyData) {
      final dayName = day['day'] as String;
      final mood = day['mood'] as double;

      if (dayName == 'Sábado' || dayName == 'Domingo') {
        weekendMood += mood;
        weekendCount++;
      } else {
        weekdayMood += mood;
        weekdayCount++;
      }
    }

    return {
      'weekend_avg': weekendCount > 0 ? weekendMood / weekendCount : 0,
      'weekday_avg': weekdayCount > 0 ? weekdayMood / weekdayCount : 0,
      'preference': weekendMood > weekdayMood ? 'weekend' : 'weekday',
    };
  }

  double _calculateWeeklyConsistency(List<Map<String, dynamic>> weeklyData) {
    if (weeklyData.length < 2) return 1.0;

    final moods = weeklyData.map((d) => d['mood'] as double).toList();
    final mean = moods.reduce((a, b) => a + b) / moods.length;

    double variance = 0;
    for (final mood in moods) {
      variance += (mood - mean) * (mood - mean);
    }

    return (10 - variance).clamp(0, 10) / 10;
  }

  List<Map<String, String>> _getWeeklyRecommendations(String? bestDay, String? worstDay) {
    final recommendations = <Map<String, String>>[];

    if (bestDay != null) {
      recommendations.add({
        'type': 'optimize',
        'title': 'Optimiza tu $bestDay',
        'description': 'Planifica actividades importantes para aprovechar tu mejor día.'
      });
    }

    if (worstDay != null) {
      recommendations.add({
        'type': 'support',
        'title': 'Cuídate los $worstDay',
        'description': 'Considera actividades relajantes y de autocuidado ese día.'
      });
    }

    return recommendations;
  }

  String _getProgressDescription(String trend) {
    switch (trend) {
      case 'improving': return 'una mejora constante';
      case 'declining': return 'algunos desafíos recientes';
      default: return 'estabilidad emocional';
    }
  }

  Map<String, dynamic>? _getNextAchievement(List<Map<String, dynamic>> achievements, int streak, int totalMoments) {
    final locked = achievements.where((a) => !a['unlocked']).toList();
    if (locked.isEmpty) return null;

    return locked.first;
  }

  Map<String, String>? _getNextMilestone(Map<String, dynamic> basicStats, Map<String, dynamic> achievements) {
    final streak = basicStats['streak_days'] ?? 0;
    final totalMoments = basicStats['total_moments'] ?? 0;

    if (streak < 7) {
      return {
        'type': 'streak',
        'title': 'Próximo hito: 7 días consecutivos',
        'description': 'Te faltan ${7 - streak} días para una semana completa.',
        'progress': '${(streak / 7 * 100).round()}%'
      };
    }

    if (totalMoments < 50) {
      return {
        'type': 'moments',
        'title': 'Próximo hito: 50 momentos',
        'description': 'Te faltan ${50 - totalMoments} momentos para el siguiente nivel.',
        'progress': '${(totalMoments / 50 * 100).round()}%'
      };
    }

    return null;
  }

  Future<Map<String, dynamic>> getAdvancedStreakAnalysis(int userId) async {
    try {
      final db = await database;

      // ✅ FIX: Corrected date arithmetic for streak calculation
      final streakData = await db.rawQuery('''
        WITH daily_activity AS (
          SELECT DISTINCT entry_date
          FROM daily_entries 
          WHERE user_id = ?
          ORDER BY entry_date
        ),
        streak_groups AS (
          SELECT 
            entry_date,
            date(entry_date, '-' || ROW_NUMBER() OVER (ORDER BY entry_date) || ' days') as streak_group
          FROM daily_activity
        ),
        streaks AS (
          SELECT 
            MIN(entry_date) as start_date,
            MAX(entry_date) as end_date,
            COUNT(*) as length,
            streak_group
          FROM streak_groups
          GROUP BY streak_group
        )
        SELECT 
          length as streak_length,
          start_date,
          end_date,
          julianday(end_date) - julianday(start_date) + 1 as actual_days
        FROM streaks
        WHERE length > 1
        ORDER BY length DESC
      ''', [userId]);

      final currentStreak = await calculateCurrentStreak(userId);
      final longestStreak = streakData.isNotEmpty ?
      streakData.map((s) => s['streak_length'] as int).reduce((a, b) => a > b ? a : b) : 0;

      final weeklyConsistency = await db.rawQuery('''
        SELECT 
          strftime('%Y-W%W', entry_date) as week,
          COUNT(DISTINCT entry_date) as days_active,
          COUNT(DISTINCT strftime('%w', entry_date)) as different_weekdays
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-12 weeks')
        GROUP BY week
        ORDER BY week DESC
      ''', [userId]);

      final avgDaysPerWeek = weeklyConsistency.isNotEmpty ?
      weeklyConsistency.map((w) => w['days_active'] as int).reduce((a, b) => a + b) / weeklyConsistency.length : 0.0;

      return {
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_streaks': streakData.length,
        'avg_streak_length': streakData.isNotEmpty ?
        streakData.map((s) => s['streak_length'] as int).reduce((a, b) => a + b) / streakData.length : 0.0,
        'weekly_consistency': avgDaysPerWeek,
        'streak_stability': longestStreak > 0 ? currentStreak / longestStreak : 0.0,
        'all_streaks': streakData,
      };
    } catch (e) {
      _logger.e('Error en análisis de racha: $e');
      return {'current_streak': 0, 'longest_streak': 0};
    }
  }

  Future<Map<String, dynamic>> getEnhancedWellbeingScore(int userId) async {
    try {
      final basicStats = await getUserComprehensiveStatistics(userId);
      final streakAnalysis = await getAdvancedStreakAnalysis(userId);
      final moodAnalysis = await getDetailedMoodAnalysis(userId);

      final currentStreak = (streakAnalysis['current_streak'] as num?)?.toInt() ?? 0;
      final weeklyConsistency = (streakAnalysis['weekly_consistency'] as num?)?.toDouble() ?? 0.0;
      final consistencyScore = (
          (currentStreak / 30).clamp(0, 1) * 0.6 +
              (weeklyConsistency / 7).clamp(0, 1) * 0.4
      ) * 30;

      final avgMood = (basicStats['avg_mood_score'] as num?)?.toDouble() ?? 5.0;
      final moodStability = (moodAnalysis['stability_score'] as num?)?.toDouble() ?? 0.5;
      final positiveRatio = (moodAnalysis['positive_days_ratio'] as num?)?.toDouble() ?? 0.5;
      final emotionalScore = (
          (avgMood / 10) * 0.5 +
              moodStability * 0.3 +
              positiveRatio * 0.2
      ) * 25;

      final recentTrend = (moodAnalysis['recent_trend'] as num?)?.toDouble() ?? 0.0;
      final improvementRate = (moodAnalysis['improvement_rate'] as num?)?.toDouble() ?? 0.0;
      final progressScore = (
          (recentTrend + 1) / 2 * 0.6 +
              improvementRate * 0.4
      ) * 20;

      final entriesThisMonth = (basicStats['entries_this_month'] as num?)?.toInt() ?? 0;
      final totalMoments = (basicStats['total_moments'] as num?)?.toInt() ?? 0;
      final activityScore = (
          (entriesThisMonth / 25).clamp(0, 1) * 0.7 +
              (totalMoments / 100).clamp(0, 1) * 0.3
      ) * 15;

      final diversityAnalysis = await getDiversityAnalysis(userId);
      final diversityScore = (diversityAnalysis['diversity_score'] as num?)?.toDouble() ?? 0.3 * 10;

      final totalScore = (consistencyScore + emotionalScore + progressScore +
          activityScore + diversityScore).round().clamp(0, 100);

      String level;
      String emoji;
      if (totalScore >= 85) {
        level = 'Maestro del Bienestar';
        emoji = '👑';
      } else if (totalScore >= 70) {
        level = 'Avanzado';
        emoji = '🌟';
      } else if (totalScore >= 55) {
        level = 'Progresando Bien';
        emoji = '🚀';
      } else if (totalScore >= 40) {
        level = 'En Desarrollo';
        emoji = '🌱';
      } else if (totalScore >= 25) {
        level = 'Aprendiz';
        emoji = '📚';
      } else {
        level = 'Iniciando';
        emoji = '🌅';
      }

      return {
        'total_score': totalScore,
        'level': level,
        'emoji': emoji,
        'component_scores': {
          'consistency': consistencyScore.round(),
          'emotional': emotionalScore.round(),
          'progress': progressScore.round(),
          'activity': activityScore.round(),
          'diversity': diversityScore.round(),
        },
        'insights': _generateScoreInsights(totalScore, {
          'consistency': consistencyScore,
          'emotional': emotionalScore,
          'progress': progressScore,
          'activity': activityScore,
          'diversity': diversityScore,
        }),
        'next_level_target': _getNextLevelTarget(totalScore),
      };
    } catch (e) {
      _logger.e('Error calculando score mejorado: $e');
      return {
        'total_score': 50,
        'level': 'En Desarrollo',
        'emoji': '🌱',
        'component_scores': {},
      };
    }
  }

  // ✅ METHOD WITH FIX FOR TYPE ERROR
  Future<Map<String, dynamic>> getDetailedMoodAnalysis(int userId) async {
    try {
      final db = await database;

      final moodData = await db.rawQuery('''
        SELECT 
          mood_score,
          entry_date,
          strftime('%w', entry_date) as weekday,
          strftime('%m', entry_date) as month
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-60 days')
        ORDER BY entry_date
      ''', [userId]);

      if (moodData.isEmpty) {
        return {
          'stability_score': 0.5,
          'positive_days_ratio': 0.5,
          'recent_trend': 0,
          'improvement_rate': 0,
          'avg_mood': 5.0,
          'mood_variance': 0.0,
          'total_days_analyzed': 0,
        };
      }

      // Safely map mood scores, providing a default value for nulls to prevent type errors.
      final moods = moodData.map((row) => (row['mood_score'] as num? ?? 5.0).toDouble()).toList();

      // Guard against empty list for reduce operations, even though guarded above, it's safer.
      if (moods.isEmpty) {
        // This case should not be reached due to the moodData.isEmpty check, but it's a good safeguard.
        return {'stability_score': 0.5, 'positive_days_ratio': 0.5, 'recent_trend': 0, 'improvement_rate': 0.0};
      }

      final avgMood = moods.reduce((a, b) => a + b) / moods.length;
      final variance = moods.length > 1 ? moods.map((mood) => (mood - avgMood) * (mood - avgMood))
          .reduce((a, b) => a + b) / moods.length : 0.0;
      final stabilityScore = (1 - (variance / 9)).clamp(0, 1);

      final positiveDays = moods.where((mood) => mood >= 6).length;
      final positiveRatio = positiveDays / moods.length;

      final recentMoods = moods.length > 14 ? moods.sublist(moods.length - 14) : moods;
      final olderMoods = moods.length > 14 ? moods.sublist(0, moods.length - 14) : [];

      double recentTrend = 0;
      if (olderMoods.isNotEmpty && recentMoods.isNotEmpty) {
        final recentAvg = recentMoods.reduce((a, b) => a + b) / recentMoods.length;
        final olderAvg = olderMoods.reduce((a, b) => a + b) / olderMoods.length;
        recentTrend = (recentAvg - olderAvg) / 5;
      }

      double improvementRate = 0;
      if (moods.length >= 7) {
        final n = moods.length.toDouble();
        final sumX = (n * (n - 1)) / 2;
        final sumY = moods.reduce((a, b) => a + b);
        final sumXY = moods.asMap().entries.map((e) => e.key * e.value).reduce((a, b) => a + b);
        final sumX2 = ((n - 1) * n * (2 * n - 1)) / 6;

        final denominator = (n * sumX2 - sumX * sumX);
        if (denominator.abs() > 0.001) {
          final slope = (n * sumXY - sumX * sumY) / denominator;
          improvementRate = (slope / 0.1).clamp(-1, 1);
        }
      }

      return {
        'stability_score': stabilityScore,
        'positive_days_ratio': positiveRatio,
        'recent_trend': recentTrend.clamp(-1, 1),
        'improvement_rate': improvementRate,
        'avg_mood': avgMood,
        'mood_variance': variance,
        'total_days_analyzed': moods.length,
      };
    } catch (e) {
      _logger.e('Error en análisis de mood: $e');
      return {
        'stability_score': 0.5,
        'positive_days_ratio': 0.5,
        'recent_trend': 0,
        'improvement_rate': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getConsistencyAnalysis(int userId) async {
    try {
      final db = await database;

      final consistencyData = await db.rawQuery('''
        SELECT 
          entry_date,
          strftime('%w', entry_date) as weekday,
          strftime('%H', created_at) as hour,
          COUNT(*) as entries_that_day
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-30 days')
        GROUP BY entry_date
        ORDER BY entry_date
      ''', [userId]);

      if (consistencyData.isEmpty) {
        return {'consistency_score': 0, 'time_regularity': 0, 'weekly_balance': 0};
      }

      final activeDays = consistencyData.length;
      final totalDays = 30;
      final generalConsistency = activeDays / totalDays;

      final hours = consistencyData.map((row) => int.parse(row['hour'] as String)).toList();
      final hourVariance = hours.isNotEmpty ?
      _calculateVariance(hours.map((h) => h.toDouble()).toList()) : 24;
      final timeRegularity = (1 - (hourVariance / 24)).clamp(0, 1);

      final weekdayCounts = <int, int>{};
      for (final row in consistencyData) {
        final weekday = int.parse(row['weekday'] as String);
        weekdayCounts[weekday] = (weekdayCounts[weekday] ?? 0) + 1;
      }

      final weekdayValues = List.generate(7, (i) => weekdayCounts[i]?.toDouble() ?? 0);
      final weekdayVariance = _calculateVariance(weekdayValues);
      final expectedAvg = activeDays / 7;
      final weeklyBalance = expectedAvg > 0 ? (1 - (weekdayVariance / (expectedAvg * expectedAvg))).clamp(0, 1) : 0;

      final overallConsistency = (
          generalConsistency * 0.5 +
              timeRegularity * 0.3 +
              weeklyBalance * 0.2
      );

      return {
        'consistency_score': overallConsistency,
        'general_consistency': generalConsistency,
        'time_regularity': timeRegularity,
        'weekly_balance': weeklyBalance,
        'active_days': activeDays,
        'total_days': totalDays,
        'most_common_hour': hours.isNotEmpty ? _getMostCommonHour(hours) : null,
        'weekday_distribution': weekdayCounts,
      };
    } catch (e) {
      _logger.e('Error en análisis de consistencia: $e');
      return {'consistency_score': 0, 'time_regularity': 0, 'weekly_balance': 0};
    }
  }

  Future<Map<String, dynamic>> getDiversityAnalysis(int userId) async {
    try {
      final db = await database;
      final diversityData = await db.rawQuery('''
        SELECT 
          category,
          type,
          COUNT(*) as frequency
        FROM interactive_moments 
        WHERE user_id = ? AND entry_date >= date('now', '-30 days')
        GROUP BY category, type
      ''', [userId]);

      if (diversityData.isEmpty) {
        return {'diversity_score': 0.3, 'categories_used': 0, 'variety_index': 0, 'total_moments': 0};
      }

      final uniqueCategories = diversityData.map((row) => row['category']).toSet().length;
      final maxCategories = 6;
      final categoryDiversity = (uniqueCategories / maxCategories).clamp(0, 1);

      final frequencies = diversityData.map((row) => (row['frequency'] as int).toDouble()).toList();
      if(frequencies.isEmpty) {
        return {'diversity_score': 0.3, 'categories_used': 0, 'variety_index': 0, 'total_moments': 0};
      }

      final totalMoments = frequencies.reduce((a, b) => a + b);
      final proportions = frequencies.map((f) => f / totalMoments).toList();

      final shannonIndex = proportions.map((p) => p > 0 ? -p * (math.log(p) / math.log(2)) : 0).reduce((a, b) => a + b);
      final maxShannon = proportions.length > 1 ? math.log(proportions.length) / math.log(2) : 1;
      final varietyIndex = maxShannon > 0 ? shannonIndex / maxShannon : 0;

      final diversityScore = (categoryDiversity * 0.6 + varietyIndex * 0.4);

      return {
        'diversity_score': diversityScore,
        'categories_used': uniqueCategories,
        'max_categories': maxCategories,
        'variety_index': varietyIndex,
        'total_moments': totalMoments.toInt(),
        'category_breakdown': _getCategoryBreakdown(diversityData),
      };
    } catch (e) {
      _logger.e('Error en análisis de diversidad: $e');
      return {'diversity_score': 0.3, 'categories_used': 0, 'variety_index': 0};
    }
  }

  Future<Map<String, dynamic>> detectStressPattern(int userId) async {
    try {
      final db = await database;

      final stressData = await db.rawQuery('''
        SELECT 
          entry_date,
          mood_score,
          free_reflection
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-14 days')
        ORDER BY entry_date DESC
      ''', [userId]);

      if (stressData.isEmpty) {
        return {'stress_level': 'unknown', 'requires_attention': false, 'recommendations': []};
      }

      final stressKeywords = [
        'estresado', 'estrés', 'agobiado', 'presión', 'ansiedad', 'nervioso',
        'abrumado', 'tensión', 'preocupado', 'agotado', 'cansado'
      ];

      int stressIndicators = 0;
      int lowMoodDays = 0;

      for (final row in stressData) {
        final mood = (row['mood_score'] as num).toDouble();
        final reflection = (row['free_reflection'] as String? ?? '').toLowerCase();

        if (mood <= 4) lowMoodDays++;

        for (final keyword in stressKeywords) {
          if (reflection.contains(keyword)) {
            stressIndicators++;
            break;
          }
        }
      }

      final totalDays = stressData.length;
      final stressFrequency = stressIndicators / totalDays;
      final lowMoodFrequency = lowMoodDays / totalDays;

      String stressLevel;
      bool requiresAttention = false;
      List<String> recommendations = [];

      if (stressFrequency >= 0.5 || lowMoodFrequency >= 0.6) {
        stressLevel = 'high';
        requiresAttention = true;
        recommendations = [
          'Considera técnicas de relajación como respiración profunda',
          'Intenta hacer ejercicio ligero o caminar',
          'Habla con alguien de confianza sobre lo que te preocupa',
          'Si persiste, considera buscar apoyo profesional',
        ];
      } else if (stressFrequency >= 0.3 || lowMoodFrequency >= 0.4) {
        stressLevel = 'moderate';
        recommendations = [
          'Mantén rutinas de autocuidado',
          'Asegúrate de dormir lo suficiente',
          'Toma descansos regulares durante el día',
        ];
      } else {
        stressLevel = 'low';
        recommendations = [
          'Continúa con tus hábitos actuales',
          'Sigue reflexionando regularmente',
        ];
      }

      return {
        'stress_level': stressLevel,
        'stress_frequency': (stressFrequency * 100).round(),
        'low_mood_frequency': (lowMoodFrequency * 100).round(),
        'requires_attention': requiresAttention,
        'recommendations': recommendations,
        'days_analyzed': totalDays,
      };
    } catch (e) {
      _logger.e('Error detectando patrón de estrés: $e');
      return {'stress_level': 'unknown', 'requires_attention': false, 'recommendations': []};
    }
  }

  double _calculateVariance(List<double> values) {
    if (values.length < 2) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((value) => (value - mean) * (value - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  int _getMostCommonHour(List<int> hours) {
    if (hours.isEmpty) return 12; // Default hour if list is empty
    final hourCounts = <int, int>{};
    for (final hour in hours) {
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    return hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Map<String, int> _getCategoryBreakdown(List<Map<String, dynamic>> diversityData) {
    final breakdown = <String, int>{};
    for (final row in diversityData) {
      final category = row['category'] as String;
      final frequency = row['frequency'] as int;
      breakdown[category] = (breakdown[category] ?? 0) + frequency;
    }
    return breakdown;
  }

  List<String> _generateScoreInsights(int totalScore, Map<String, double> components) {
    if (components.isEmpty) return ["Analizando tus datos..."];
    final insights = <String>[];

    final strongest = components.entries.reduce((a, b) => a.value > b.value ? a : b);
    final strongestName = _getComponentName(strongest.key);
    insights.add('Tu mayor fortaleza es $strongestName con ${strongest.value.round()} puntos');

    final weakest = components.entries.reduce((a, b) => a.value < b.value ? a : b);
    if (weakest.value < 15) {
      final weakestName = _getComponentName(weakest.key);
      insights.add('$weakestName es tu área de mayor oportunidad (${weakest.value.round()} puntos)');
    }

    if (totalScore >= 80) {
      insights.add('¡Excelente! Estás en el rango superior de bienestar');
    } else if (totalScore >= 60) {
      insights.add('Vas muy bien. Tu bienestar está por encima del promedio');
    } else if (totalScore >= 40) {
      insights.add('Estás construyendo una base sólida. Cada día cuenta');
    } else {
      insights.add('Cada reflexión es un paso valioso en tu crecimiento');
    }

    return insights;
  }

  String _getComponentName(String component) {
    switch (component) {
      case 'consistency': return 'Consistencia';
      case 'emotional': return 'Bienestar Emocional';
      case 'progress': return 'Progreso';
      case 'activity': return 'Actividad';
      case 'diversity': return 'Diversidad';
      default: return component;
    }
  }

  Map<String, dynamic> _getNextLevelTarget(int currentScore) {
    if (currentScore < 25) {
      return {'target_score': 25, 'target_level': 'Aprendiz', 'points_needed': 25 - currentScore};
    } else if (currentScore < 40) {
      return {'target_score': 40, 'target_level': 'En Desarrollo', 'points_needed': 40 - currentScore};
    } else if (currentScore < 55) {
      return {'target_score': 55, 'target_level': 'Progresando Bien', 'points_needed': 55 - currentScore};
    } else if (currentScore < 70) {
      return {'target_score': 70, 'target_level': 'Avanzado', 'points_needed': 70 - currentScore};
    } else if (currentScore < 85) {
      return {'target_score': 85, 'target_level': 'Maestro del Bienestar', 'points_needed': 85 - currentScore};
    } else {
      return {'target_score': 100, 'target_level': 'Perfección', 'points_needed': 100 - currentScore};
    }
  }

  Future<Map<String, int>> getTagCorrelations(int userId, {int limit = 10}) async {
    _logger.i('🔍 Analizando correlaciones de tags para el usuario $userId');
    try {
      final db = await database;
      final List<Map<String, dynamic>> entries = await db.query(
        'daily_entries',
        columns: ['positive_tags', 'negative_tags'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (entries.isEmpty) {
        _logger.d('No hay entradas para analizar correlaciones.');
        return {};
      }

      final Map<String, int> correlations = {};

      List<TagModel> _parseTags(String? jsonString) {
        if (jsonString == null || jsonString.isEmpty) return [];
        try {
          final List<dynamic> tagsList = json.decode(jsonString);
          return tagsList.map((tagJson) => TagModel.fromJson(tagJson as Map<String, dynamic>)).toList();
        } catch (e) {
          _logger.e('Error decodificando JSON de tags: $e');
          return [];
        }
      }

      for (final row in entries) {
        final positiveTags = _parseTags(row['positive_tags'] as String?);
        final negativeTags = _parseTags(row['negative_tags'] as String?);

        if (positiveTags.isEmpty || negativeTags.isEmpty) {
          continue;
        }

        for (final pTag in positiveTags) {
          for (final nTag in negativeTags) {
            final keyItems = [pTag.name, nTag.name]..sort();
            final key = keyItems.join('|');

            correlations[key] = (correlations[key] ?? 0) + 1;
          }
        }
      }

      final sortedCorrelations = correlations.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final limitedCorrelations = Map.fromEntries(sortedCorrelations.take(limit));

      _logger.i('✅ Correlaciones encontradas: ${limitedCorrelations.length}');
      return limitedCorrelations;

    } catch (e) {
      _logger.e('❌ Error obteniendo correlaciones de tags: $e');
      return {};
    }
  }
  Future<Map<String, dynamic>> getUserStatistics(int userId) async {
    return getUserComprehensiveStatistics(userId);
  }

  Future<int> createDeveloperAccount() async {
    try {
      final db = await database;
      _logger.i('🧪 Creando cuenta de desarrollador...');

      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['dev@reflect.com'],
      );

      int userId;
      if (existing.isNotEmpty) {
        userId = existing.first['id'] as int;
        _logger.i('🔄 Usando cuenta existente: $userId');
      } else {
        final defaultPassword = 'devpassword123';
        final passwordHash = sha256.convert(utf8.encode(defaultPassword)).toString();

        userId = await db.insert('users', {
          'name': 'Alex Developer',
          'email': 'dev@reflect.com',
          'password_hash': passwordHash,
          'avatar_emoji': '👨‍💻',
          'created_at': DateTime.now().toIso8601String(),
        });
        _logger.i('✅ Cuenta de desarrollador creada: $userId');
      }

      await generateComprehensiveTestData(userId);

      return userId;
    } catch (e) {
      _logger.e('❌ Error creando cuenta desarrollador: $e');
      rethrow;
    }
  }

  Future<void> generateComprehensiveTestData(int userId) async {
    try {
      final db = await database;
      _logger.i('📊 Generando datos comprehensivos para usuario: $userId');

      await _clearUserData(userId);

      await _generateHistoricalData(userId, db);
      await _generateInteractiveMoments(userId, db);
      await _generateMilestoneEvents(userId, db);

      _logger.i('✅ Datos comprehensivos generados exitosamente');
    } catch (e) {
      _logger.e('❌ Error generando datos de prueba: $e');
      rethrow;
    }
  }

  Future<void> _clearUserData(int userId) async {
    final db = await database;
    await db.delete('daily_entries', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('interactive_moments', where: 'user_id = ?', whereArgs: [userId]);
    _logger.i('🗑️ Datos previos limpiados');
  }

  Future<void> _generateHistoricalData(int userId, Database db) async {
    _logger.i('📈 Generando datos históricos con patrones...');

    final now = DateTime.now();
    final scenarios = [
      _PersonalityPhase('Período Difícil', -90, -61, 3.5, 2.0, 7.5),
      _PersonalityPhase('Recuperación', -60, -31, 5.0, 4.0, 6.0),
      _PersonalityPhase('Crecimiento', -30, -1, 7.5, 7.0, 4.0),
    ];

    for (final phase in scenarios) {
      await _generatePhaseData(userId, db, now, phase);
    }

    await _generateTodayData(userId, db, now);
  }

  Future<void> _generatePhaseData(int userId, Database db, DateTime now, _PersonalityPhase phase) async {
    _logger.i('📅 Generando fase: ${phase.name}');

    for (int dayOffset = phase.startDay; dayOffset <= phase.endDay; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final dateStr = date.toIso8601String().split('T')[0];

      final dailyVariation = (math.Random().nextDouble() - 0.5) * 2;
      final weekendBoost = date.weekday >= 6 ? 0.5 : 0.0;
      final mondayDip = date.weekday == 1 ? -0.8 : 0.0;

      final mood = (phase.baseMood + dailyVariation + weekendBoost + mondayDip).clamp(1.0, 10.0);
      final energy = (phase.baseEnergy + dailyVariation + weekendBoost + mondayDip).clamp(1.0, 10.0);
      final stress = (phase.baseStress - dailyVariation + mondayDip).clamp(1.0, 10.0);

      await db.insert('daily_entries', {
        'user_id': userId,
        'entry_date': dateStr,
        'mood_score': mood.round(),
        'energy_level': energy.round(),
        'stress_level': stress.round(),
        'sleep_quality': _generateSleepQuality(energy, stress),
        'anxiety_level': _generateAnxietyLevel(stress, mood),
        'motivation_level': _generateMotivationLevel(mood, energy),
        'social_interaction': _generateSocialLevel(mood, date.weekday),
        'physical_activity': _generatePhysicalActivity(energy, date.weekday),
        'work_productivity': _generateWorkProductivity(energy, stress, date.weekday),
        'sleep_hours': _generateSleepHours(stress, energy),
        'water_intake': _generateWaterIntake(energy),
        'meditation_minutes': _generateMeditationMinutes(stress, mood),
        'exercise_minutes': _generateExerciseMinutes(energy, date.weekday),
        'screen_time_hours': _generateScreenTime(mood, energy),
        'gratitude_items': _generateGratitudeItems(mood),
        'weather_mood_impact': _generateWeatherImpact(date),
        'social_battery': _generateSocialBattery(mood, date.weekday),
        'creative_energy': _generateCreativeEnergy(mood, energy),
        'emotional_stability': _generateEmotionalStability(mood, stress),
        'focus_level': _generateFocusLevel(energy, stress),
        'life_satisfaction': _generateLifeSatisfaction(mood, stress),
        'free_reflection': _generateReflection(mood, energy, stress, phase.name),
        'created_at': date.toIso8601String(),
      });
    }
  }

  Future<void> _generateTodayData(int userId, Database db, DateTime now) async {
    final dateStr = now.toIso8601String().split('T')[0];

    await db.insert('daily_entries', {
      'user_id': userId,
      'entry_date': dateStr,
      'mood_score': 8,
      'energy_level': 7,
      'stress_level': 3,
      'sleep_quality': 8,
      'anxiety_level': 2,
      'motivation_level': 8,
      'social_interaction': 7,
      'physical_activity': 6,
      'work_productivity': 8,
      'sleep_hours': 7.5,
      'water_intake': 9,
      'meditation_minutes': 15,
      'exercise_minutes': 45,
      'screen_time_hours': 5.0,
      'gratitude_items': 'Mi familia, el progreso en el proyecto, el buen tiempo',
      'weather_mood_impact': 8,
      'social_battery': 7,
      'creative_energy': 8,
      'emotional_stability': 8,
      'focus_level': 8,
      'life_satisfaction': 8,
      'free_reflection': 'Hoy fue un día excelente. Me siento muy productivo y en equilibrio. Los nuevos analytics están funcionando perfectamente y puedo ver claramente mi progreso. Es increíble cómo los datos me ayudan a entender mis patrones.',
      'created_at': now.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _generateInteractiveMoments(int userId, Database db) async {
    _logger.i('🎭 Generando momentos interactivos...');

    final moments = [
      _MomentData('😄', 'Completé una funcionalidad compleja sin bugs', 'positive', 8, 'profesional'),
      _MomentData('🎉', 'El cliente quedó encantado con la demo', 'positive', 9, 'profesional'),
      _MomentData('☕', 'Perfecto café de la mañana mientras programo', 'positive', 6, 'personal'),
      _MomentData('🧘', 'Meditación de 20 minutos me centró completamente', 'positive', 7, 'bienestar'),
      _MomentData('📚', 'Aprendí un nuevo patrón de diseño muy útil', 'positive', 7, 'crecimiento'),

      _MomentData('😰', 'Bug crítico justo antes del release', 'negative', 8, 'profesional'),
      _MomentData('🥱', 'Muy poco sueño, me siento agotado', 'negative', 6, 'bienestar'),
      _MomentData('😤', 'Reunión improductiva de 2 horas', 'negative', 7, 'profesional'),

      _MomentData('🚶', 'Caminata corta durante el almuerzo', 'positive', 5, 'bienestar'),
      _MomentData('📱', 'Scroll sin propósito en redes sociales', 'neutral', 3, 'personal'),
    ];

    for (int i = 0; i < moments.length; i++) {
      final moment = moments[i];
      final timestamp = DateTime.now().subtract(Duration(hours: i * 2));

      await db.insert('interactive_moments', {
        'user_id': userId,
        'emoji': moment.emoji,
        'text': moment.text,
        'type': moment.type,
        'intensity': moment.intensity,
        'category': moment.category,
        'context': _generateMomentContext(moment.category),
        'location': _generateLocation(),
        'weather': 'Soleado',
        'social_context': moment.category == 'profesional' ? 'Trabajo' : 'Solo',
        'energy_before': (moment.intensity + math.Random().nextInt(3) - 1).clamp(1, 10),
        'energy_after': moment.type == 'positive'
            ? (moment.intensity + 1).clamp(1, 10)
            : (moment.intensity - 1).clamp(1, 10),
        'mood_before': (moment.intensity + math.Random().nextInt(2) - 1).clamp(1, 10),
        'mood_after': moment.type == 'positive'
            ? (moment.intensity + 1).clamp(1, 10)
            : (moment.intensity - 1).clamp(1, 10),
        'timestamp': timestamp.toIso8601String(),
        'created_at': timestamp.toIso8601String(),
        'updated_at': timestamp.toIso8601String(),
      });
    }
  }

  Future<void> _generateMilestoneEvents(int userId, Database db) async {
    _logger.i('🏆 Generando eventos de milestone...');

    final milestones = [
      _MilestoneData(-7, '🔥', 'Semana completa de consistencia', 'positive', 9),
      _MilestoneData(-14, '💪', 'Superé una semana muy estresante', 'positive', 8),
      _MilestoneData(-21, '🎯', 'Alcancé mi objetivo de meditación diaria', 'positive', 7),
      _MilestoneData(-45, '📈', 'Mejor mes de productividad del año', 'positive', 9),
    ];

    for (final milestone in milestones) {
      final timestamp = DateTime.now().add(Duration(days: milestone.daysAgo));

      await db.insert('interactive_moments', {
        'user_id': userId,
        'emoji': milestone.emoji,
        'text': milestone.description,
        'type': milestone.type,
        'intensity': milestone.intensity,
        'category': 'milestone',
        'context': 'Logro personal importante',
        'location': 'Casa',
        'weather': 'Variable',
        'social_context': 'Reflexión personal',
        'energy_before': 6,
        'energy_after': milestone.intensity,
        'mood_before': 6,
        'mood_after': milestone.intensity,
        'timestamp': timestamp.toIso8601String(),
        'created_at': timestamp.toIso8601String(),
        'updated_at': timestamp.toIso8601String(),
      });
    }
  }

  int _generateSleepQuality(double energy, double stress) {
    final base = energy - (stress * 0.3);
    return (base + (math.Random().nextDouble() - 0.5) * 2).clamp(1, 10).round();
  }

  int _generateAnxietyLevel(double stress, double mood) {
    final base = stress - (mood * 0.2);
    return (base + (math.Random().nextDouble() - 0.5) * 1.5).clamp(1, 10).round();
  }

  int _generateMotivationLevel(double mood, double energy) {
    final base = (mood + energy) / 2;
    return (base + (math.Random().nextDouble() - 0.5) * 1.5).clamp(1, 10).round();
  }

  int _generateSocialLevel(double mood, int weekday) {
    final weekendBoost = weekday >= 6 ? 2 : 0;
    final base = mood * 0.7 + weekendBoost;
    return (base + (math.Random().nextDouble() - 0.5) * 2).clamp(1, 10).round();
  }

  int _generatePhysicalActivity(double energy, int weekday) {
    final weekendBoost = weekday >= 6 ? 1 : 0;
    final base = energy * 0.8 + weekendBoost;
    return (base + (math.Random().nextDouble() - 0.5) * 2).clamp(1, 10).round();
  }

  int _generateWorkProductivity(double energy, double stress, int weekday) {
    if (weekday >= 6) return math.Random().nextInt(3) + 1;
    final base = energy - (stress * 0.4);
    return (base + (math.Random().nextDouble() - 0.5) * 2).clamp(1, 10).round();
  }

  double _generateSleepHours(double stress, double energy) {
    final base = 7.5 - (stress * 0.3) + (energy * 0.1);
    return (base + (math.Random().nextDouble() - 0.5) * 1.5).clamp(4.0, 10.0);
  }

  int _generateWaterIntake(double energy) {
    final base = 6 + (energy * 0.3);
    return (base + (math.Random().nextDouble() - 0.5) * 2).clamp(3, 12).round();
  }

  int _generateMeditationMinutes(double stress, double mood) {
    if (stress > 7 || mood < 4) {
      return (10 + math.Random().nextDouble() * 20).round();
    }
    return (math.Random().nextDouble() * 15).round();
  }

  int _generateExerciseMinutes(double energy, int weekday) {
    if (weekday >= 6) return (math.Random().nextDouble() * 90).round();
    final base = energy * 5;
    return (base + (math.Random().nextDouble() - 0.5) * 20).clamp(0, 120).round();
  }

  double _generateScreenTime(double mood, double energy) {
    final base = 6 - (mood * 0.2) - (energy * 0.1);
    return (base + (math.Random().nextDouble() - 0.5) * 2).clamp(2.0, 12.0);
  }

  String _generateGratitudeItems(double mood) {
    final gratitudeOptions = [
      ['mi familia', 'la salud', 'el trabajo'],
      ['el café matutino', 'la música', 'los amigos'],
      ['el progreso', 'la tecnología', 'la naturaleza'],
      ['el aprendizaje', 'las oportunidades', 'la paz'],
      ['la creatividad', 'los desafíos', 'el crecimiento'],
    ];

    final items = gratitudeOptions[math.Random().nextInt(gratitudeOptions.length)];
    if (mood > 7) {
      return items.join(', ');
    } else if (mood > 4) {
      return items.take(2).join(', ');
    } else {
      return items.first;
    }
  }

  int _generateWeatherImpact(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return 7;
    if (month >= 6 && month <= 8) return 8;
    if (month >= 9 && month <= 11) return 6;
    return 5;
  }

  int _generateSocialBattery(double mood, int weekday) {
    if (weekday == 1) return 4;
    final base = mood * 0.8;
    return (base + (math.Random().nextDouble() - 0.5) * 2).clamp(1, 10).round();
  }

  int _generateCreativeEnergy(double mood, double energy) {
    final base = (mood + energy) / 2.2;
    return (base + (math.Random().nextDouble() - 0.5) * 2).clamp(1, 10).round();
  }

  int _generateEmotionalStability(double mood, double stress) {
    final base = mood - (stress * 0.3);
    return (base + (math.Random().nextDouble() - 0.5) * 1.5).clamp(1, 10).round();
  }

  int _generateFocusLevel(double energy, double stress) {
    final base = energy - (stress * 0.4);
    return (base + (math.Random().nextDouble() - 0.5) * 1.5).clamp(1, 10).round();
  }

  int _generateLifeSatisfaction(double mood, double stress) {
    final base = mood - (stress * 0.2);
    return (base + (math.Random().nextDouble() - 0.5) * 1.0).clamp(1, 10).round();
  }

  String _generateReflection(double mood, double energy, double stress, String phase) {
    final reflections = {
      'Período Difícil': [
        'Hoy fue un día complicado. Me siento agotado y estresado.',
        'Estoy pasando por un momento difícil, pero sé que es temporal.',
        'Necesito enfocarme en el autocuidado y ser paciente conmigo mismo.',
      ],
      'Recuperación': [
        'Siento que estoy mejorando poco a poco. Hay esperanza.',
        'Cada día es un pequeño paso hacia adelante.',
        'Empiezo a ver la luz al final del túnel.',
      ],
      'Crecimiento': [
        'Me siento realmente bien hoy. Todo fluye naturalmente.',
        'Estoy en mi mejor momento y aprovecho esta energía positiva.',
        'Tengo mucha claridad mental y motivación para mis proyectos.',
      ],
    };

    final options = reflections[phase] ?? ['Día normal, sin grandes altibajos.'];
    return options[math.Random().nextInt(options.length)];
  }

  String _generateMomentContext(String category) {
    final contexts = {
      'profesional': ['Durante trabajo remoto', 'En la oficina', 'En reunión virtual'],
      'personal': ['En casa', 'Durante tiempo libre', 'Con familia'],
      'bienestar': ['Durante rutina matutina', 'En pausa activa', 'Antes de dormir'],
      'crecimiento': ['Estudiando', 'Leyendo', 'Experimentando'],
    };

    final options = contexts[category] ?? ['Momento general'];
    return options[math.Random().nextInt(options.length)];
  }

  String _generateLocation() {
    final locations = ['Casa', 'Oficina', 'Cafetería', 'Parque', 'Gym', 'Transporte'];
    return locations[math.Random().nextInt(locations.length)];
  }

  Future<void> regenerateLastMonthData(int userId) async {
    try {
      final db = await database;
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      await db.delete(
        'daily_entries',
        where: 'user_id = ? AND entry_date >= ?',
        whereArgs: [userId, thirtyDaysAgo.toIso8601String().split('T')[0]],
      );

      await _generateHistoricalData(userId, db);
      _logger.i('✅ Datos del último mes regenerados');
    } catch (e) {
      _logger.e('❌ Error regenerando datos: $e');
    }
  }

  Future<Map<String, dynamic>> getDeveloperDataStats(int userId) async {
    try {
      final db = await database;

      final stats = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_entries,
        AVG(mood_score) as avg_mood,
        AVG(energy_level) as avg_energy,
        AVG(stress_level) as avg_stress,
        MIN(entry_date) as first_entry,
        MAX(entry_date) as last_entry
      FROM daily_entries 
      WHERE user_id = ?
    ''', [userId]);

      final momentsCount = await db.rawQuery('''
      SELECT COUNT(*) as total_moments
      FROM interactive_moments 
      WHERE user_id = ?
    ''', [userId]);

      return {
        'daily_entries': stats.first,
        'interactive_moments': momentsCount.first,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('❌ Error obteniendo estadísticas: $e');
      return {};
    }

  }


}

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
String _getHourlyRecommendation(String? bestHour, String? worstHour) {
  if (bestHour != null && worstHour != null && bestHour != worstHour) {
    return 'Tu energía pico es a las $bestHour. Evita tareas demandantes cerca de las $worstHour.';
  }
  return 'Registra más momentos para obtener recomendaciones horarias.';
}
