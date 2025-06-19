// ============================================================================
// data/services/database_service.dart - VERSIÓN CORREGIDA Y ROBUSTA
// ============================================================================

import 'dart:async';
import 'dart:convert';

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
}
