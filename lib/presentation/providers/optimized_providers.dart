// ============================================================================
// presentation/providers/optimized_providers.dart - PROVIDERS OPTIMIZADOS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/services/optimized_database_service.dart';
import '../../data/models/optimized_models.dart';

// ============================================================================
// AUTH PROVIDER OPTIMIZADO
// ============================================================================

class OptimizedAuthProvider with ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  OptimizedUserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  OptimizedAuthProvider(this._databaseService);

  // Getters
  OptimizedUserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  /// Inicializar provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.i('🔑 Inicializando AuthProvider optimizado');
    _setLoading(true);

    try {
      // Verificar sesión guardada aquí si implementas SessionService
      // final hasSession = await _sessionService.hasActiveSession();
      // if (hasSession) { ... }

      _isInitialized = true;
      _logger.i('✅ AuthProvider inicializado');
    } catch (e) {
      _logger.e('❌ Error inicializando AuthProvider: $e');
      _setError('Error de inicialización');
    } finally {
      _setLoading(false);
    }
  }

  /// Registrar nuevo usuario
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String avatarEmoji = '🧘‍♀️',
    String bio = '',
  }) async {
    _logger.i('📝 Registrando usuario: $email');
    _setLoading(true);
    _clearError();

    try {
      final user = await _databaseService.createUser(
        email: email,
        password: password,
        name: name,
        avatarEmoji: avatarEmoji,
        bio: bio,
      );

      if (user != null) {
        _currentUser = user;
        _logger.i('✅ Usuario registrado exitosamente: ${user.name}');
        notifyListeners();
        return true;
      } else {
        _setError('No se pudo crear el usuario');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error en registro: $e');
      _setError('Error durante el registro');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Iniciar sesión
  Future<bool> login(String email, String password) async {
    _logger.i('🔐 Iniciando sesión: $email');
    _setLoading(true);
    _clearError();

    try {
      final user = await _databaseService.authenticateUser(email, password);

      if (user != null) {
        _currentUser = user;
        _logger.i('✅ Sesión iniciada: ${user.name}');
        notifyListeners();
        return true;
      } else {
        _setError('Credenciales incorrectas');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error en login: $e');
      _setError('Error durante el login');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    _logger.i('🚪 Cerrando sesión');
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  /// Actualizar perfil de usuario
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? avatarEmoji,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        bio: bio,
        avatarEmoji: avatarEmoji,
      );

      // Aquí implementarías el método updateUser en el database service
      // final success = await _databaseService.updateUser(updatedUser);

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('❌ Error actualizando perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// ============================================================================
// DAILY ENTRIES PROVIDER OPTIMIZADO
// ============================================================================

class OptimizedDailyEntriesProvider with ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  List<OptimizedDailyEntryModel> _entries = [];
  OptimizedDailyEntryModel? _todayEntry;
  bool _isLoading = false;
  String? _errorMessage;

  OptimizedDailyEntriesProvider(this._databaseService);

  // Getters
  List<OptimizedDailyEntryModel> get entries => List.unmodifiable(_entries);
  OptimizedDailyEntryModel? get todayEntry => _todayEntry;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Analytics getters
  double get averageWellbeingScore => _entries.averageWellbeingScore;
  List<OptimizedDailyEntryModel> get recentEntries => _entries.recentEntries;
  Map<String, int> get wellbeingDistribution => _entries.wellbeingLevelDistribution;

  /// Cargar entradas del usuario
  Future<void> loadEntries(int userId, {int? limitDays}) async {
    _logger.d('📚 Cargando entradas para usuario: $userId');
    _setLoading(true);
    _clearError();

    try {
      final endDate = DateTime.now();
      final startDate = limitDays != null
          ? endDate.subtract(Duration(days: limitDays))
          : null;

      _entries = await _databaseService.getDailyEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Buscar entrada de hoy
      final today = DateTime.now();
      final todayStr = DateTime(today.year, today.month, today.day);

      // *** FIX: Use try-catch to avoid error when no entry is found ***
      try {
        _todayEntry = _entries.firstWhere(
              (entry) => entry.entryDate.isAtSameMomentAs(todayStr),
        );
      } catch (e) {
        _todayEntry = null;
      }


      _logger.i('✅ Cargadas ${_entries.length} entradas');
    } catch (e) {
      _logger.e('❌ Error cargando entradas: $e');
      _setError('Error cargando entradas');
    } finally {
      _setLoading(false);
    }
  }

  /// Guardar entrada diaria
  Future<bool> saveDailyEntry({
    required int userId,
    required String freeReflection,
    List<String> positiveTags = const [],
    List<String> negativeTags = const [],
    bool? worthIt,
    int? moodScore,

    // Analytics
    int? energyLevel,
    int? stressLevel,
    int? sleepQuality,
    int? anxietyLevel,
    int? motivationLevel,
    int? socialInteraction,
    int? physicalActivity,
    int? workProductivity,
    double? sleepHours,
    int? waterIntake,
    int? meditationMinutes,
    int? exerciseMinutes,
    double? screenTimeHours,
    String? gratitudeItems,
    int? weatherMoodImpact,
    int? socialBattery,
    int? creativeEnergy,
    int? emotionalStability,
    int? focusLevel,
    int? lifeSatisfaction,
  }) async {
    _logger.i('💾 Guardando entrada diaria');
    _setLoading(true);
    _clearError();

    try {
      final entry = OptimizedDailyEntryModel.create(
        userId: userId,
        freeReflection: freeReflection,
        positiveTags: positiveTags,
        negativeTags: negativeTags,
        worthIt: worthIt,
        moodScore: moodScore,
        energyLevel: energyLevel,
        stressLevel: stressLevel,
        sleepQuality: sleepQuality,
        anxietyLevel: anxietyLevel,
        motivationLevel: motivationLevel,
        socialInteraction: socialInteraction,
        physicalActivity: physicalActivity,
        workProductivity: workProductivity,
        sleepHours: sleepHours,
        waterIntake: waterIntake,
        meditationMinutes: meditationMinutes,
        exerciseMinutes: exerciseMinutes,
        screenTimeHours: screenTimeHours,
        gratitudeItems: gratitudeItems,
        weatherMoodImpact: weatherMoodImpact,
        socialBattery: socialBattery,
        creativeEnergy: creativeEnergy,
        emotionalStability: emotionalStability,
        focusLevel: focusLevel,
        lifeSatisfaction: lifeSatisfaction,
      );

      final entryId = await _databaseService.saveDailyEntry(entry);

      if (entryId != null) {
        _todayEntry = entry.copyWith(id: entryId);
        await loadEntries(userId); // Recargar para mantener sincronía
        _logger.i('✅ Entrada guardada exitosamente');
        return true;
      } else {
        _setError('No se pudo guardar la entrada');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error guardando entrada: $e');
      _setError('Error guardando entrada');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener entrada de una fecha específica
  OptimizedDailyEntryModel? getEntryByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    try {
      return _entries.firstWhere(
            (entry) => entry.entryDate.isAtSameMomentAs(targetDate),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtener estadísticas del período
  Map<String, dynamic> getPeriodStats({int days = 30}) {
    final recentEntries = this.recentEntries;

    if (recentEntries.isEmpty) {
      return {
        'total_entries': 0,
        'avg_wellbeing': 0.0,
        'consistency_rate': 0.0,
        'mood_trend': 'stable',
      };
    }

    final avgWellbeing = recentEntries.averageWellbeingScore;
    final consistencyRate = recentEntries.length / days;

    // Calcular tendencia de mood
    final sortedEntries = recentEntries..sort((a, b) => a.entryDate.compareTo(b.entryDate));
    final firstHalf = sortedEntries.take(sortedEntries.length ~/ 2).toList();
    final secondHalf = sortedEntries.skip(sortedEntries.length ~/ 2).toList();

    final firstHalfAvg = firstHalf.averageWellbeingScore;
    final secondHalfAvg = secondHalf.averageWellbeingScore;

    String moodTrend = 'stable';
    if (secondHalfAvg > firstHalfAvg + 0.5) {
      moodTrend = 'improving';
    } else if (secondHalfAvg < firstHalfAvg - 0.5) {
      moodTrend = 'declining';
    }

    return {
      'total_entries': recentEntries.length,
      'avg_wellbeing': avgWellbeing,
      'consistency_rate': consistencyRate,
      'mood_trend': moodTrend,
      'wellbeing_distribution': wellbeingDistribution,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// ============================================================================
// INTERACTIVE MOMENTS PROVIDER OPTIMIZADO
// ============================================================================

class OptimizedMomentsProvider with ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  List<OptimizedInteractiveMomentModel> _moments = [];
  List<OptimizedInteractiveMomentModel> _todayMoments = [];
  bool _isLoading = false;
  String? _errorMessage;

  OptimizedMomentsProvider(this._databaseService);

  // Getters
  List<OptimizedInteractiveMomentModel> get moments => List.unmodifiable(_moments);
  List<OptimizedInteractiveMomentModel> get todayMoments => List.unmodifiable(_todayMoments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Analytics getters
  int get totalCount => _moments.length;
  int get todayCount => _todayMoments.length;
  int get positiveCount => _moments.where((m) => m.type == 'positive').length;
  int get negativeCount => _moments.where((m) => m.type == 'negative').length;

  List<OptimizedInteractiveMomentModel> get positiveMoments => _moments.positivesMoments;
  List<OptimizedInteractiveMomentModel> get negativeMoments => _moments.negativeMoments;
  Map<String, double> get intensityByCategory => _moments.averageIntensityByCategory;

  /// Cargar momentos del usuario
  Future<void> loadMoments(int userId, {DateTime? date, int? limitDays}) async {
    _logger.d('📚 Cargando momentos para usuario: $userId');
    _setLoading(true);
    _clearError();

    try {
      if (date != null) {
        // Cargar momentos de un día específico
        _moments = await _databaseService.getInteractiveMoments(
          userId: userId,
          date: date,
        );
      } else {
        // Cargar momentos recientes
        _moments = await _databaseService.getInteractiveMoments(
          userId: userId,
          limit: limitDays != null ? limitDays * 10 : 100, // Estimación
        );
      }

      // Actualizar momentos de hoy
      _todayMoments = _moments.todayMoments;

      _logger.i('✅ Cargados ${_moments.length} momentos (${_todayMoments.length} de hoy)');
    } catch (e) {
      _logger.e('❌ Error cargando momentos: $e');
      _setError('Error cargando momentos');
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar solo momentos de hoy
  Future<void> loadTodayMoments(int userId) async {
    final today = DateTime.now();
    await loadMoments(userId, date: today);
  }

  /// Añadir nuevo momento
  Future<bool> addMoment({
    required int userId,
    required String emoji,
    required String text,
    required String type,
    int intensity = 5,
    String category = 'general',
    String? contextLocation,
    String? contextWeather,
    String? contextSocial,
    int? energyBefore,
    int? energyAfter,
    int? moodBefore,
    int? moodAfter,
  }) async {
    _logger.i('✨ Añadiendo momento: $emoji $text');
    _setLoading(true);
    _clearError();

    try {
      final moment = OptimizedInteractiveMomentModel.create(
        userId: userId,
        emoji: emoji,
        text: text,
        type: type,
        intensity: intensity,
        category: category,
        contextLocation: contextLocation,
        contextWeather: contextWeather,
        contextSocial: contextSocial,
        energyBefore: energyBefore,
        energyAfter: energyAfter,
        moodBefore: moodBefore,
        moodAfter: moodAfter,
      );

      final momentId = await _databaseService.saveInteractiveMoment(userId, moment);

      if (momentId != null) {
        final savedMoment = moment.copyWith(id: momentId);
        _moments.insert(0, savedMoment); // Añadir al principio
        _todayMoments = _moments.todayMoments; // Actualizar lista de hoy

        _logger.i('✅ Momento añadido exitosamente');
        notifyListeners();
        return true;
      } else {
        _setError('No se pudo guardar el momento');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error añadiendo momento: $e');
      _setError('Error añadiendo momento');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Filtrar momentos por tipo
  List<OptimizedInteractiveMomentModel> getMomentsByType(String type) {
    return _moments.where((m) => m.type == type).toList();
  }

  /// Filtrar momentos por categoría
  List<OptimizedInteractiveMomentModel> getMomentsByCategory(String category) {
    return _moments.where((m) => m.category == category).toList();
  }

  /// Obtener estadísticas de momentos
  Map<String, dynamic> getMomentsStats() {
    if (_moments.isEmpty) {
      return {
        'total': 0,
        'today': 0,
        'positive_ratio': 0.0,
        'avg_intensity': 0.0,
        'categories': <String, int>{},
      };
    }

    final positiveRatio = positiveCount / totalCount;
    final avgIntensity = OptimizedInteractiveMomentModel.calculateAverageIntensity(_moments);

    // Estadísticas por categoría
    final categoryStats = <String, int>{};
    for (final moment in _moments) {
      categoryStats[moment.category] = (categoryStats[moment.category] ?? 0) + 1;
    }

    return {
      'total': totalCount,
      'today': todayCount,
      'positive_ratio': positiveRatio,
      'negative_ratio': 1.0 - positiveRatio,
      'avg_intensity': avgIntensity,
      'categories': categoryStats,
      'intensity_by_category': intensityByCategory,
    };
  }

  /// Obtener tendencias horarias de hoy
  Map<int, List<OptimizedInteractiveMomentModel>> getTodayHourlyBreakdown() {
    final hourlyBreakdown = <int, List<OptimizedInteractiveMomentModel>>{};

    for (final moment in _todayMoments) {
      final hour = moment.timestamp.hour;
      hourlyBreakdown.putIfAbsent(hour, () => []).add(moment);
    }

    return hourlyBreakdown;
  }

  /// Limpiar momentos de hoy
  Future<bool> clearTodayMoments(int userId) async {
    _logger.i('🗑️ Limpiando momentos de hoy');
    try {
      // Aquí implementarías el método clearTodayMoments en el database service
      _todayMoments.clear();
      _moments.removeWhere((m) => m.entryDate.isAtSameMomentAs(DateTime.now()));
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('❌ Error limpiando momentos: $e');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// ============================================================================
// ANALYTICS PROVIDER OPTIMIZADO
// ============================================================================

class OptimizedAnalyticsProvider with ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  Map<String, dynamic> _analytics = {};
  bool _isLoading = false;
  String? _errorMessage;

  OptimizedAnalyticsProvider(this._databaseService);

  // Getters
  Map<String, dynamic> get analytics => Map.unmodifiable(_analytics);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters específicos para compatibilidad
  int get wellbeingScore => (_analytics['basic_stats']?['avg_wellbeing'] as double?)?.round() ?? 0;
  String get wellbeingLevel {
    final score = wellbeingScore;
    if (score >= 8) return 'Excelente';
    if (score >= 6) return 'Bueno';
    if (score >= 4) return 'Regular';
    return 'Necesita Atención';
  }

  /// Cargar analytics completos del usuario
  Future<void> loadCompleteAnalytics(int userId, {int days = 30}) async {
    _logger.d('📊 Cargando analytics para usuario: $userId');
    _setLoading(true);
    _clearError();

    try {
      _analytics = await _databaseService.getUserAnalytics(userId, days: days);
      _logger.i('✅ Analytics cargados para $days días');
    } catch (e) {
      _logger.e('❌ Error cargando analytics: $e');
      _setError('Error cargando estadísticas');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener insights basados en los datos
  List<Map<String, String>> getInsights() {
    final insights = <Map<String, String>>[];

    if (_analytics.isEmpty) return insights;

    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (basicStats != null) {
      final avgWellbeing = basicStats['avg_wellbeing'] as double? ?? 0.0;
      final consistencyRate = basicStats['consistency_rate'] as double? ?? 0.0;

      // Insight sobre bienestar
      if (avgWellbeing >= 7.0) {
        insights.add({
          'icon': '🌟',
          'title': 'Excelente Bienestar',
          'description': 'Tu puntuación de bienestar promedio es alta'
        });
      } else if (avgWellbeing < 4.0) {
        insights.add({
          'icon': '💪',
          'title': 'Oportunidad de Mejora',
          'description': 'Considera practicar más autocuidado'
        });
      }

      // Insight sobre consistencia
      if (consistencyRate >= 0.8) {
        insights.add({
          'icon': '🎯',
          'title': 'Muy Consistente',
          'description': 'Mantienes un registro muy regular'
        });
      }
    }

    // Insight sobre racha
    if (streakData != null) {
      final currentStreak = streakData['current_streak'] as int? ?? 0;
      if (currentStreak >= 7) {
        insights.add({
          'icon': '�',
          'title': 'Racha Impresionante',
          'description': '$currentStreak días consecutivos registrando'
        });
      }
    }

    return insights;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}