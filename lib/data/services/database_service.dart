// ============================================================================
// data/services/database_service.dart
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../models/daily_entry_model.dart';
import '../models/interative_moment_model.dart';
import '../models/tag_model.dart';

class DatabaseService {
  static const String _databaseName = 'reflect_zen.db';
  static const int _databaseVersion = 1;

  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  final Logger _logger = Logger();

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Getter para la base de datos, inicializa si es necesario
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Inicializar la base de datos
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

  /// Crear tablas cuando se crea la base de datos por primera vez
  Future<void> _onCreate(Database db, int version) async {
    _logger.i('✨ Creando esquema de base de datos zen');

    await db.transaction((txn) async {
      // Tabla de usuarios zen
      await txn.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          name TEXT NOT NULL,
          avatar_emoji TEXT DEFAULT '🧘‍♀️',
          preferences TEXT DEFAULT '{}',
          created_at TEXT DEFAULT (datetime('now')),
          last_login TEXT
        )
      ''');

      // Tabla de entradas diarias zen
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

      // Tabla de momentos interactivos
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

      // Índices para rendimiento zen
      await txn.execute('''
        CREATE INDEX idx_daily_entries_user_date 
        ON daily_entries(user_id, entry_date)
      ''');

      await txn.execute('''
        CREATE INDEX idx_interactive_moments_user_date 
        ON interactive_moments(user_id, entry_date)
      ''');
    });

    _logger.i('✅ Esquema de base de datos zen creado correctamente');
  }

  /// Actualizar base de datos cuando hay una nueva versión
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('🔄 Actualizando base de datos de v$oldVersion a v$newVersion');
    // Aquí irían las migraciones futuras
  }

  /// Callback cuando se abre la base de datos
  Future<void> _onOpen(Database db) async {
    _logger.d('🔓 Base de datos zen abierta');
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Cerrar la base de datos
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _logger.i('🔒 Base de datos zen cerrada');
    }
  }

  // ============================================================================
  // 👤 MÉTODOS DE USUARIOS
  // ============================================================================

  /// Crear nuevo usuario zen
  Future<int?> createUser(String email, String password, String name, {String avatarEmoji = '🧘‍♀️'}) async {
    try {
      final db = await database;
      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      final userId = await db.insert(
        'users',
        {
          'email': email,
          'password_hash': passwordHash,
          'name': name,
          'avatar_emoji': avatarEmoji,
          'preferences': '{}',
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

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

  /// Autenticar usuario zen
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final db = await database;
      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'email = ? AND password_hash = ?',
        whereArgs: [email, passwordHash],
        limit: 1,
      );

      if (results.isEmpty) {
        _logger.w('❌ Credenciales incorrectas para: $email');
        return null;
      }

      final userData = results.first;

      // Actualizar último login zen
      await db.update(
        'users',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [userData['id']],
      );

      final user = UserModel.fromDatabase(userData);
      _logger.i('🌺 Bienvenido de vuelta: ${user.name}');
      return user;

    } catch (e) {
      _logger.e('❌ Error en login zen: $e');
      return null;
    }
  }

  /// Obtener usuario por ID
  Future<UserModel?> getUserById(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isEmpty) return null;

      return UserModel.fromDatabase(results.first);
    } catch (e) {
      _logger.e('❌ Error obteniendo usuario $userId: $e');
      return null;
    }
  }

  // ============================================================================
  // 🎮 MÉTODOS DE MOMENTOS INTERACTIVOS
  // ============================================================================

  /// Guardar momento interactivo individual
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

  /// Obtener momentos interactivos del día actual
  Future<List<InteractiveMomentModel>> getInteractiveMomentsToday(int userId) async {
    try {
      final db = await database;
      final today = DateTime.now().toIso8601String().split('T')[0];

      final List<Map<String, dynamic>> results = await db.query(
        'interactive_moments',
        where: 'user_id = ? AND entry_date = ?',
        whereArgs: [userId, today],
        orderBy: 'time_str, created_at',
      );

      final moments = results.map((row) => InteractiveMomentModel.fromDatabase(row)).toList();

      _logger.d('📚 Cargados ${moments.length} momentos interactivos de hoy');
      return moments;

    } catch (e) {
      _logger.e('❌ Error obteniendo momentos interactivos: $e');
      return [];
    }
  }

  /// Eliminar todos los momentos interactivos del día
  Future<bool> clearInteractiveMomentsToday(int userId) async {
    try {
      final db = await database;
      final today = DateTime.now().toIso8601String().split('T')[0];

      final deletedCount = await db.delete(
        'interactive_moments',
        where: 'user_id = ? AND entry_date = ?',
        whereArgs: [userId, today],
      );

      _logger.i('🗑️ Eliminados $deletedCount momentos interactivos de hoy');
      return true;

    } catch (e) {
      _logger.e('❌ Error eliminando momentos interactivos: $e');
      return false;
    }
  }

  /// Convertir momentos interactivos del día en entrada diaria
  Future<int?> saveInteractiveMomentsAsEntry(int userId, {String? reflection, bool? worthIt}) async {
    try {
      _logger.i('🔄 Convirtiendo momentos interactivos en entrada diaria para usuario $userId');

      // Obtener momentos del día
      final moments = await getInteractiveMomentsToday(userId);

      if (moments.isEmpty) {
        _logger.w('⚠️ No hay momentos para convertir');
        return null;
      }

      // Separar por tipo
      final positiveTags = moments
          .where((moment) => moment.type == 'positive')
          .map((moment) => moment.toTag())
          .toList();

      final negativeTags = moments
          .where((moment) => moment.type == 'negative')
          .map((moment) => moment.toTag())
          .toList();

      _logger.d('📊 Convertidos: ${positiveTags.length} positivos, ${negativeTags.length} negativos');

      // Crear entrada diaria
      final entry = DailyEntryModel.create(
        userId: userId,
        freeReflection: reflection ?? 'Entrada creada desde Momentos Interactivos',
        positiveTags: positiveTags,
        negativeTags: negativeTags,
        worthIt: worthIt,
      );

      // Guardar entrada
      final entryId = await saveDailyEntry(entry);

      if (entryId != null) {
        _logger.i('✅ Entrada diaria creada con ID: $entryId');
        return entryId;
      } else {
        _logger.e('❌ Error creando entrada diaria');
        return null;
      }

    } catch (e) {
      _logger.e('❌ Error convirtiendo momentos a entrada: $e');
      return null;
    }
  }

  // ============================================================================
  // 📝 MÉTODOS DE ENTRADAS DIARIAS
  // ============================================================================

  /// Guardar entrada diaria zen completa
  Future<int?> saveDailyEntry(DailyEntryModel entry) async {
    try {
      final db = await database;

      _logger.d('💾 Guardando entrada para usuario ${entry.userId}');

      // Verificar si ya existe entrada para hoy
      final today = DateTime.now().toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> existing = await db.query(
        'daily_entries',
        where: 'user_id = ? AND entry_date = ?',
        whereArgs: [entry.userId, today],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // ACTUALIZAR entrada existente
        final existingId = existing.first['id'] as int;
        _logger.d('🔄 Actualizando entrada existente $existingId');

        final updateData = entry.toDatabase();
        updateData['updated_at'] = DateTime.now().toIso8601String();
        updateData.remove('id'); // No actualizar el ID
        updateData.remove('created_at'); // No actualizar fecha de creación

        await db.update(
          'daily_entries',
          updateData,
          where: 'id = ?',
          whereArgs: [existingId],
        );

        _logger.i('🌸 Entrada zen actualizada (ID: $existingId, Mood: ${entry.moodScore}/10)');
        return existingId;

      } else {
        // CREAR nueva entrada
        _logger.d('✨ Creando nueva entrada');

        final entryData = entry.toDatabase();
        entryData.remove('id'); // Dejar que SQLite genere el ID

        final entryId = await db.insert('daily_entries', entryData);

        _logger.i('🌸 Entrada zen guardada (ID: $entryId, Mood: ${entry.moodScore}/10)');
        return entryId;
      }

    } catch (e) {
      _logger.e('❌ Error guardando entrada zen: $e');
      return null;
    }
  }

  /// Obtener entradas zen del usuario
  Future<List<DailyEntryModel>> getUserEntries(int userId, {int limit = 20, int offset = 0}) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> results = await db.query(
        'daily_entries',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'entry_date DESC, created_at DESC',
        limit: limit,
        offset: offset,
      );

      final entries = results.map((row) => DailyEntryModel.fromDatabase(row)).toList();

      _logger.d('🔍 Encontradas ${entries.length} entradas para usuario $userId');
      return entries;

    } catch (e) {
      _logger.e('❌ Error obteniendo entradas zen: $e');
      return [];
    }
  }

  /// Verificar si el usuario ya submiteó una entrada hoy
  Future<bool> hasSubmittedToday(int userId) async {
    try {
      final db = await database;
      final today = DateTime.now().toIso8601String().split('T')[0];

      final List<Map<String, dynamic>> results = await db.query(
        'daily_entries',
        where: 'user_id = ? AND entry_date = ?',
        whereArgs: [userId, today],
        limit: 1,
      );

      return results.isNotEmpty;

    } catch (e) {
      _logger.e('❌ Error verificando entrada de hoy: $e');
      return false;
    }
  }

  /// Obtener entrada de un día específico
  Future<DailyEntryModel?> getDayEntry(int userId, DateTime date) async {
    try {
      final db = await database;
      final dateStr = date.toIso8601String().split('T')[0];

      final List<Map<String, dynamic>> results = await db.query(
        'daily_entries',
        where: 'user_id = ? AND entry_date = ?',
        whereArgs: [userId, dateStr],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (results.isEmpty) return null;

      return DailyEntryModel.fromDatabase(results.first);

    } catch (e) {
      _logger.e('❌ Error obteniendo entrada del día $date: $e');
      return null;
    }
  }

  // ============================================================================
  // 📊 MÉTODOS DE RESÚMENES Y ESTADÍSTICAS
  // ============================================================================

  /// Obtener resumen de todo el año por meses
  Future<Map<int, Map<String, int>>> getYearSummary(int userId, int year) async {
    try {
      final db = await database;
      final firstDay = '$year-01-01';
      final lastDay = '$year-12-31';

      final List<Map<String, dynamic>> results = await db.query(
        'daily_entries',
        columns: ['entry_date', 'positive_tags', 'negative_tags'],
        where: 'user_id = ? AND entry_date >= ? AND entry_date <= ?',
        whereArgs: [userId, firstDay, lastDay],
        orderBy: 'entry_date',
      );

      // Inicializar datos para todos los meses
      final Map<int, Map<String, int>> yearData = {};
      for (int month = 1; month <= 12; month++) {
        yearData[month] = {'positive': 0, 'negative': 0, 'total': 0};
      }

      // Procesar resultados
      for (final row in results) {
        final entryDate = DateTime.parse(row['entry_date'] as String);
        final month = entryDate.month;

        // Contar tags
        int positiveCount = 0;
        int negativeCount = 0;

        try {
          final positiveTagsJson = row['positive_tags'] as String?;
          if (positiveTagsJson != null && positiveTagsJson.isNotEmpty) {
            final List<dynamic> positiveTags = json.decode(positiveTagsJson);
            positiveCount = positiveTags.length;
          }
        } catch (e) {
          // Error parseando, continuar con 0
        }

        try {
          final negativeTagsJson = row['negative_tags'] as String?;
          if (negativeTagsJson != null && negativeTagsJson.isNotEmpty) {
            final List<dynamic> negativeTags = json.decode(negativeTagsJson);
            negativeCount = negativeTags.length;
          }
        } catch (e) {
          // Error parseando, continuar con 0
        }

        yearData[month]!['positive'] = yearData[month]!['positive']! + positiveCount;
        yearData[month]!['negative'] = yearData[month]!['negative']! + negativeCount;
        yearData[month]!['total'] = yearData[month]!['total']! + positiveCount + negativeCount;
      }

      return yearData;

    } catch (e) {
      _logger.e('❌ Error obteniendo resumen del año $year: $e');
      // Retornar estructura vacía
      final Map<int, Map<String, int>> emptyData = {};
      for (int month = 1; month <= 12; month++) {
        emptyData[month] = {'positive': 0, 'negative': 0, 'total': 0};
      }
      return emptyData;
    }
  }

  /// Obtener resumen de días específicos de un mes
  Future<Map<int, Map<String, dynamic>>> getMonthSummary(int userId, int year, int month) async {
    try {
      final db = await database;
      final firstDay = '$year-${month.toString().padLeft(2, '0')}-01';

      // Calcular último día del mes
      final DateTime lastDayDate = month == 12
          ? DateTime(year + 1, 1, 0)
          : DateTime(year, month + 1, 0);
      final lastDay = lastDayDate.toIso8601String().split('T')[0];

      final List<Map<String, dynamic>> results = await db.query(
        'daily_entries',
        columns: ['entry_date', 'positive_tags', 'negative_tags', 'worth_it'],
        where: 'user_id = ? AND entry_date >= ? AND entry_date <= ?',
        whereArgs: [userId, firstDay, lastDay],
        orderBy: 'entry_date',
      );

      final Map<int, Map<String, dynamic>> monthData = {};

      for (final row in results) {
        final entryDate = DateTime.parse(row['entry_date'] as String);
        final day = entryDate.day;

        // Contar tags
        int positiveCount = 0;
        int negativeCount = 0;

        try {
          final positiveTagsJson = row['positive_tags'] as String?;
          if (positiveTagsJson != null && positiveTagsJson.isNotEmpty) {
            final List<dynamic> positiveTags = json.decode(positiveTagsJson);
            positiveCount = positiveTags.length;
          }
        } catch (e) {
          // Error parseando, continuar con 0
        }

        try {
          final negativeTagsJson = row['negative_tags'] as String?;
          if (negativeTagsJson != null && negativeTagsJson.isNotEmpty) {
            final List<dynamic> negativeTags = json.decode(negativeTagsJson);
            negativeCount = negativeTags.length;
          }
        } catch (e) {
          // Error parseando, continuar con 0
        }

        bool? worthItBool;
        final worthItInt = row['worth_it'] as int?;
        if (worthItInt == 1) {
          worthItBool = true;
        } else if (worthItInt == 0) {
          worthItBool = false;
        }

        monthData[day] = {
          'positive': positiveCount,
          'negative': negativeCount,
          'submitted': true,
          'worth_it': worthItBool,
        };
      }

      return monthData;

    } catch (e) {
      _logger.e('❌ Error obteniendo resumen del mes $year-$month: $e');
      return {};
    }
  }

  /// Obtener total de entradas del usuario
  Future<int> getEntryCount(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM daily_entries WHERE user_id = ?',
        [userId],
      );

      return results.first['count'] as int;

    } catch (e) {
      _logger.e('❌ Error obteniendo contador zen: $e');
      return 0;
    }
  }
}