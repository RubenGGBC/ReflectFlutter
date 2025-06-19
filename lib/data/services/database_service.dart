// ============================================================================
// data/services/database_service.dart - VERSIÓN CORREGIDA Y ROBUSTA
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
          moment_id TEXT NOT NULL,
          emoji TEXT NOT NULL,
          text TEXT NOT NULL,
          moment_type TEXT NOT NULL CHECK (moment_type IN ('positive', 'negative')),
          intensity INTEGER NOT NULL CHECK (intensity >= 1 AND intensity <= 10),
          category TEXT NOT NULL,
          time_str TEXT NOT NULL,
          created_at TEXT DEFAULT (datetime('now')),
          entry_date TEXT DEFAULT (date('now')),
          timestamp_data TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
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
      final List<Map<String, dynamic>> results = await db.query('interactive_moments', where: 'user_id = ? AND entry_date = ?', whereArgs: [userId, today], orderBy: 'time_str, created_at');
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
      final today = DateTime.now().toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> existing = await db.query('daily_entries', where: 'user_id = ? AND entry_date = ?', whereArgs: [entry.userId, today], limit: 1);
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
      // FIX: Safely cast the count, providing 0 as a fallback if null.
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
        combinedPositiveTags.addAll(existingEntry.positiveTags);
        combinedNegativeTags.addAll(existingEntry.negativeTags);
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
        positiveTags: combinedPositiveTags,
        negativeTags: combinedNegativeTags,
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
      final List<Map<String, dynamic>> momentsResults = await db.query('interactive_moments', where: 'user_id = ? AND entry_date = ?', whereArgs: [userId, dateStr], orderBy: 'time_str ASC, created_at ASC');
      final timeline = momentsResults.map((row) => {
        'time': row['time_str'] as String,
        'emoji': row['emoji'] as String,
        'text': row['text'] as String,
        'type': row['moment_type'] as String,
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
        SELECT time_str, moment_type, COUNT(*) as count, intensity
        FROM interactive_moments 
        WHERE user_id = ? AND entry_date = ?
        GROUP BY time_str, moment_type
        ORDER BY time_str ASC
      ''', [userId, dateStr]);
      final Map<String, Map<String, dynamic>> hourlyStats = {};
      for (final row in results) {
        final hour = row['time_str'] as String;
        if (!hourlyStats.containsKey(hour)) {
          hourlyStats[hour] = {'positive': 0, 'negative': 0, 'total': 0};
        }
        final type = row['moment_type'] as String;
        // FIX: Safely cast the count, providing 0 as a fallback if null.
        final count = (row['count'] as int?) ?? 0;
        hourlyStats[hour]![type] = count;
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
      // FIX: Safely cast the total, providing 0 as a fallback.
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

  Future<bool> updateUserProfile(int userId, {String? name, String? avatarEmoji, String? bio, Map<String, dynamic>? preferences}) async {
    try {
      final db = await database;
      final List<String> updateFields = [];
      final List<dynamic> values = [];
      if (name != null) { updateFields.add('name = ?'); values.add(name); }
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
  // ============================================================================
// MÉTODOS AVANZADOS DE ANÁLISIS PARA REFUERZO POSITIVO Y INSIGHTS PROFUNDOS
// ============================================================================

// Agregar estos métodos al DatabaseService existente

  /// 🕐 Análisis de patrones de humor por hora del día
  Future<Map<String, dynamic>> getMoodPatternsByHour(int userId) async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
      SELECT 
        CAST(substr(time_str, 1, 2) AS INTEGER) as hour,
        moment_type,
        AVG(intensity) as avg_intensity,
        COUNT(*) as count
      FROM interactive_moments 
      WHERE user_id = ? AND entry_date >= date('now', '-30 days')
      GROUP BY hour, moment_type
      ORDER BY hour ASC
    ''', [userId]);

      final Map<int, Map<String, dynamic>> hourlyData = {};
      String? bestHour, worstHour;
      double bestScore = 0, worstScore = 10;

      for (final row in results) {
        final hour = row['hour'] as int;
        final type = row['moment_type'] as String;
        final avgIntensity = (row['avg_intensity'] as num).toDouble();
        final count = row['count'] as int;

        if (!hourlyData.containsKey(hour)) {
          hourlyData[hour] = {'positive': 0.0, 'negative': 0.0, 'total': 0};
        }

        hourlyData[hour]![type] = avgIntensity;
        hourlyData[hour]!['total'] = hourlyData[hour]!['total']! + count;

        // Calcular score general (positivos - negativos)
        final score = (hourlyData[hour]!['positive'] as double) -
            (hourlyData[hour]!['negative'] as double);

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

  /// 📈 Evolución del mood a lo largo del tiempo (últimos 30 días)
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

        // Calcular tendencia
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

  /// 🏆 Sistema de logros y hitos personalizados
  Future<Map<String, dynamic>> getUserAchievements(int userId) async {
    try {
      final db = await database;

      // Consultas para diferentes logros
      final basicStats = await getUserComprehensiveStatistics(userId);
      final streakDays = basicStats['streak_days'] ?? 0;
      final totalEntries = basicStats['total_entries'] ?? 0;
      final totalMoments = basicStats['total_moments'] ?? 0;

      // Logros específicos
      final consistencyResult = await db.rawQuery('''
      SELECT COUNT(DISTINCT entry_date) as consistent_days
      FROM daily_entries 
      WHERE user_id = ? AND entry_date >= date('now', '-7 days')
    ''', [userId]);

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

      // 🔥 Logros de Consistencia
      if (streakDays >= 1) achievements.add(_createAchievement('🌱', 'Primer Paso', 'Comenzaste tu viaje de reflexión', true, 'bronze'));
      if (streakDays >= 3) achievements.add(_createAchievement('🔥', 'En Racha', 'Mantuviste consistencia por 3 días', true, 'bronze'));
      if (streakDays >= 7) achievements.add(_createAchievement('💪', 'Semana Completa', 'Una semana de reflexión diaria', true, 'silver'));
      if (streakDays >= 30) achievements.add(_createAchievement('💎', 'Dedicación Diamond', '30 días consecutivos', streakDays >= 30, 'gold'));

      // ✨ Logros de Volumen
      if (totalMoments >= 10) achievements.add(_createAchievement('📝', 'Capturador', '10 momentos registrados', true, 'bronze'));
      if (totalMoments >= 50) achievements.add(_createAchievement('🌟', 'Observador', '50 momentos capturados', true, 'silver'));
      if (totalMoments >= 100) achievements.add(_createAchievement('🚀', 'Experto en Momentos', '100 momentos registrados', totalMoments >= 100, 'gold'));

      // 📊 Logros de Mejora
      final recentMood = (moodImprovementResult.first['recent_mood'] as num?)?.toDouble() ?? 5.0;
      final prevMood = (moodImprovementResult.first['prev_mood'] as num?)?.toDouble() ?? 5.0;
      final moodImprovement = recentMood - prevMood;

      if (moodImprovement > 1) achievements.add(_createAchievement('📈', 'En Ascenso', 'Tu mood mejoró esta semana', true, 'silver'));
      if (recentMood >= 8) achievements.add(_createAchievement('😊', 'Estado Zen', 'Mood promedio excelente', true, 'gold'));

      // 🎨 Logros de Diversidad
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

  /// 📊 Análisis de palabras y sentimientos más frecuentes
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

        // Analizar palabras positivas comunes
        for (final word in _getPositiveKeywords()) {
          if (reflection.contains(word)) {
            positiveWords[word] = (positiveWords[word] ?? 0) + 1;
          }
        }

        // Analizar desafíos/áreas de mejora
        for (final word in _getChallengeKeywords()) {
          if (reflection.contains(word)) {
            challengeWords[word] = (challengeWords[word] ?? 0) + 1;
          }
        }
      }

      // Ordenar por frecuencia
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

  /// 🗓️ Análisis de patrones por día de la semana
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

  /// 🎯 Predicciones y recomendaciones personalizadas
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

      // Generar insights basados en datos reales
      final streak = basicStats['streak_days'] ?? 0;
      final avgMood = basicStats['avg_mood_score'] ?? 5.0;
      final trend = moodEvolution['overall_trend'] ?? 'stable';

      // 🔮 Predicciones
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

      // 💡 Recomendaciones personalizadas
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

      // Recomendación basada en consistencia
      if (streak < 3) {
        recommendations.add({
          'type': 'consistency',
          'emoji': '🎯',
          'title': 'Construye consistencia',
          'description': 'Intenta reflexionar a la misma hora cada día para crear un hábito fuerte.'
        });
      }

      // 🌟 Insights motivacionales
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

  /// 📊 Score general de bienestar (0-100)
  int _calculateWellbeingScore(Map<String, dynamic> basicStats, Map<String, dynamic> moodEvolution, Map<String, dynamic> achievements) {
    double score = 0;

    // Consistencia (30 puntos)
    final streak = basicStats['streak_days'] ?? 0;
    score += (streak / 30 * 30).clamp(0, 30);

    // Mood promedio (25 puntos)
    final avgMood = basicStats['avg_mood_score'] ?? 5.0;
    score += (avgMood / 10 * 25).clamp(0, 25);

    // Tendencia (20 puntos)
    final trend = moodEvolution['overall_trend'] ?? 'stable';
    if (trend == 'improving') score += 20;
    else if (trend == 'stable') score += 15;
    else score += 5;

    // Logros (15 puntos)
    final achievementPercentage = achievements['completion_percentage'] ?? 0;
    score += (achievementPercentage / 100 * 15).clamp(0, 15);

    // Actividad (10 puntos)
    final entriesThisMonth = basicStats['entries_this_month'] ?? 0;
    score += (entriesThisMonth / 20 * 10).clamp(0, 10);

    return score.round().clamp(0, 100);
  }

// ============================================================================
// HELPER METHODS
// ============================================================================

  Map<String, dynamic> _createAchievement(String emoji, String title, String description, bool unlocked, String tier) {
    return {
      'emoji': emoji,
      'title': title,
      'description': description,
      'unlocked': unlocked,
      'tier': tier, // bronze, silver, gold
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

  String _getHourlyRecommendation(String? bestHour, String? worstHour) {
    if (bestHour != null && worstHour != null) {
      return 'Tu energía pico es a las $bestHour. Evita tareas demandantes cerca de las $worstHour.';
    }
    return 'Registra más momentos para obtener recomendaciones personalizadas.';
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
    // Encontrar el próximo logro no desbloqueado
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
// ============================================================================
// AGREGAR AL FINAL de lib/data/services/database_service.dart
// Solo copiar y pegar estos métodos al final de la clase DatabaseService
// ============================================================================

  /// 🔥 Análisis de racha más preciso
  Future<Map<String, dynamic>> getAdvancedStreakAnalysis(int userId) async {
    try {
      final db = await database;

      // Obtener todas las rachas históricas
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
            entry_date - ROW_NUMBER() OVER (ORDER BY entry_date) as streak_group
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

      // Calcular consistencia semanal
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
      weeklyConsistency.map((w) => w['days_active'] as int).reduce((a, b) => a + b) / weeklyConsistency.length : 0;

      return {
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_streaks': streakData.length,
        'avg_streak_length': streakData.isNotEmpty ?
        streakData.map((s) => s['streak_length'] as int).reduce((a, b) => a + b) / streakData.length : 0,
        'weekly_consistency': avgDaysPerWeek,
        'streak_stability': longestStreak > 0 ? currentStreak / longestStreak : 0,
        'all_streaks': streakData,
      };
    } catch (e) {
      _logger.e('Error en análisis de racha: $e');
      return {'current_streak': 0, 'longest_streak': 0};
    }
  }

  /// 📊 Score de bienestar mejorado con más factores
  Future<Map<String, dynamic>> getEnhancedWellbeingScore(int userId) async {
    try {
      final basicStats = await getUserComprehensiveStatistics(userId);
      final streakAnalysis = await getAdvancedStreakAnalysis(userId);
      final moodAnalysis = await getDetailedMoodAnalysis(userId);
      final consistencyAnalysis = await getConsistencyAnalysis(userId);

      // 1. FACTOR CONSISTENCIA (30 puntos)
      final currentStreak = streakAnalysis['current_streak'] ?? 0;
      final weeklyConsistency = streakAnalysis['weekly_consistency'] ?? 0;
      final consistencyScore = (
          (currentStreak / 30).clamp(0, 1) * 0.6 +  // Racha actual (60%)
              (weeklyConsistency / 7).clamp(0, 1) * 0.4   // Consistencia semanal (40%)
      ) * 30;

      // 2. FACTOR BIENESTAR EMOCIONAL (25 puntos)
      final avgMood = basicStats['avg_mood_score'] ?? 5.0;
      final moodStability = moodAnalysis['stability_score'] ?? 0.5;
      final positiveRatio = moodAnalysis['positive_days_ratio'] ?? 0.5;
      final emotionalScore = (
          (avgMood / 10) * 0.5 +           // Mood promedio (50%)
              moodStability * 0.3 +            // Estabilidad (30%)
              positiveRatio * 0.2              // Días positivos (20%)
      ) * 25;

      // 3. FACTOR PROGRESO (20 puntos)
      final recentTrend = moodAnalysis['recent_trend'] ?? 0;
      final improvementRate = moodAnalysis['improvement_rate'] ?? 0;
      final progressScore = (
          (recentTrend + 1) / 2 * 0.6 +    // Tendencia (-1 a 1, normalizada)
              improvementRate * 0.4            // Rate de mejora
      ) * 20;

      // 4. FACTOR ACTIVIDAD (15 puntos)
      final entriesThisMonth = basicStats['entries_this_month'] ?? 0;
      final totalMoments = basicStats['total_moments'] ?? 0;
      final activityScore = (
          (entriesThisMonth / 25).clamp(0, 1) * 0.7 +  // Entradas este mes
              (totalMoments / 100).clamp(0, 1) * 0.3       // Total de momentos
      ) * 15;

      // 5. FACTOR DIVERSIDAD (10 puntos)
      final diversityAnalysis = await getDiversityAnalysis(userId);
      final diversityScore = diversityAnalysis['diversity_score'] * 10;

      final totalScore = (consistencyScore + emotionalScore + progressScore +
          activityScore + diversityScore).round().clamp(0, 100);

      // Determinar nivel
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

  /// 😊 Análisis detallado del mood
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
        };
      }

      final moods = moodData.map((row) => (row['mood_score'] as num).toDouble()).toList();

      // 1. Calcular estabilidad (menor varianza = mayor estabilidad)
      final avgMood = moods.reduce((a, b) => a + b) / moods.length;
      final variance = moods.map((mood) => (mood - avgMood) * (mood - avgMood))
          .reduce((a, b) => a + b) / moods.length;
      final stabilityScore = (1 - (variance / 9)).clamp(0, 1); // Normalizado

      // 2. Ratio de días positivos
      final positiveDays = moods.where((mood) => mood >= 6).length;
      final positiveRatio = positiveDays / moods.length;

      // 3. Tendencia reciente (últimos 14 días vs anteriores)
      final recentMoods = moods.length > 14 ? moods.sublist(moods.length - 14) : moods;
      final olderMoods = moods.length > 14 ? moods.sublist(0, moods.length - 14) : [];

      double recentTrend = 0;
      if (olderMoods.isNotEmpty) {
        final recentAvg = recentMoods.reduce((a, b) => a + b) / recentMoods.length;
        final olderAvg = olderMoods.reduce((a, b) => a + b) / olderMoods.length;
        recentTrend = (recentAvg - olderAvg) / 5; // Normalizado entre -1 y 1
      }

      // 4. Rate de mejora (tendencia lineal)
      double improvementRate = 0;
      if (moods.length >= 7) {
        // Regresión lineal simple
        final n = moods.length.toDouble();
        final sumX = (n * (n - 1)) / 2; // 0 + 1 + 2 + ... + (n-1)
        final sumY = moods.reduce((a, b) => a + b);
        final sumXY = moods.asMap().entries.map((e) => e.key * e.value).reduce((a, b) => a + b);
        final sumX2 = ((n - 1) * n * (2 * n - 1)) / 6; // 0² + 1² + 2² + ... + (n-1)²

        final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
        improvementRate = (slope / 0.1).clamp(-1, 1); // Normalizar
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

  /// ⏰ Análisis de consistencia avanzado
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

      // 1. Consistencia general (días activos / días totales)
      final activeDays = consistencyData.length;
      final totalDays = 30; // Últimos 30 días
      final generalConsistency = activeDays / totalDays;

      // 2. Regularidad temporal (consistencia en horarios)
      final hours = consistencyData.map((row) => int.parse(row['hour'] as String)).toList();
      final hourVariance = hours.isNotEmpty ?
      _calculateVariance(hours.map((h) => h.toDouble()).toList()) : 24;
      final timeRegularity = (1 - (hourVariance / 24)).clamp(0, 1);

      // 3. Balance semanal (distribución entre días de la semana)
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

  /// 🌈 Análisis de diversidad de experiencias
  Future<Map<String, dynamic>> getDiversityAnalysis(int userId) async {
    try {
      final db = await database;

      final diversityData = await db.rawQuery('''
        SELECT 
          category,
          moment_type,
          COUNT(*) as frequency
        FROM interactive_moments 
        WHERE user_id = ? AND entry_date >= date('now', '-30 days')
        GROUP BY category, moment_type
      ''', [userId]);

      if (diversityData.isEmpty) {
        return {'diversity_score': 0.3, 'categories_used': 0, 'variety_index': 0};
      }

      // 1. Número de categorías únicas
      final uniqueCategories = diversityData.map((row) => row['category']).toSet().length;
      final maxCategories = 6; // Asumiendo 6 categorías máximo
      final categoryDiversity = (uniqueCategories / maxCategories).clamp(0, 1);

      // 2. Índice de variedad (distribución uniforme es mejor)
      final frequencies = diversityData.map((row) => (row['frequency'] as int).toDouble()).toList();
      final totalMoments = frequencies.reduce((a, b) => a + b);
      final proportions = frequencies.map((f) => f / totalMoments).toList();

      // Calcular índice de Shannon (diversidad)
      final shannonIndex = proportions.map((p) => p > 0 ? -p * (math.log(p) / math.log(2)) : 0).reduce((a, b) => a + b);
      final maxShannon = math.log(proportions.length) / math.log(2);
      final varietyIndex = maxShannon > 0 ? shannonIndex / maxShannon : 0;

      // 3. Score general de diversidad
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

  /// 🚨 Detector simple de estrés elevado
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
        return {'stress_level': 'unknown', 'requires_attention': false};
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
            break; // Solo contar una vez por día
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
      return {'stress_level': 'unknown', 'requires_attention': false};
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((value) => (value - mean) * (value - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  int _getMostCommonHour(List<int> hours) {
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
    final insights = <String>[];

    // Encontrar la componente más fuerte
    final strongest = components.entries.reduce((a, b) => a.value > b.value ? a : b);
    final strongestName = _getComponentName(strongest.key);
    insights.add('Tu mayor fortaleza es $strongestName con ${strongest.value.round()} puntos');

    // Encontrar área de mejora
    final weakest = components.entries.reduce((a, b) => a.value < b.value ? a : b);
    if (weakest.value < 15) {
      final weakestName = _getComponentName(weakest.key);
      insights.add('$weakestName es tu área de mayor oportunidad (${weakest.value.round()} puntos)');
    }

    // Insight general
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

}
