// lib/presentation/providers/optimized_providers.dart - UPDATED WITH PROFILE PICTURE
// ============================================================================
// AUTH PROVIDER ACTUALIZADO CON SOPORTE PARA FOTOS DE PERFIL
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../data/models/goal_model.dart';

import '../../data/services/optimized_database_service.dart';
import '../../data/services/image_picker_service.dart'; // ✅ NUEVO IMPORT
import '../../data/models/optimized_models.dart';

class OptimizedAuthProvider with ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final ImagePickerService _imagePickerService = ImagePickerService(); // ✅ NUEVO
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

  // ✅ MÉTODO ACTUALIZADO PARA REGISTRO CON FOTO
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String avatarEmoji = '🧘‍♀️',
    String? profilePicturePath, // ✅ NUEVO PARÁMETRO
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
        profilePicturePath: profilePicturePath, // ✅ NUEVO
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

  // ✅ MÉTODO ACTUALIZADO PARA ACTUALIZAR PERFIL CON FOTO
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? avatarEmoji,
    String? profilePicturePath, // ✅ NUEVO PARÁMETRO
  }) async {
    if (_currentUser == null) return false;

    _logger.i('📝 Actualizando perfil del usuario: ${_currentUser!.name}');
    _setLoading(true);
    _clearError();

    try {
      // Si hay una nueva imagen y ya existe una anterior, eliminar la anterior
      if (profilePicturePath != null &&
          _currentUser!.profilePicturePath != null &&
          _currentUser!.profilePicturePath != profilePicturePath) {
        await _imagePickerService.deleteProfilePicture(_currentUser!.profilePicturePath);
      }

      final success = await _databaseService.updateUserProfile(
        userId: _currentUser!.id,
        name: name,
        bio: bio,
        avatarEmoji: avatarEmoji,
        profilePicturePath: profilePicturePath, // ✅ NUEVO
      );

      if (success) {
        _currentUser = _currentUser!.copyWith(
          name: name,
          bio: bio,
          avatarEmoji: avatarEmoji,
          profilePicturePath: profilePicturePath, // ✅ NUEVO
        );
        _logger.i('✅ Perfil actualizado exitosamente');
        notifyListeners();
        return true;
      } else {
        _setError('No se pudo actualizar el perfil');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error actualizando perfil: $e');
      _setError('Error durante la actualización');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ✅ NUEVO: Método para seleccionar foto de perfil
  Future<String?> selectProfilePicture(BuildContext context) async {
    try {
      _logger.i('📸 Iniciando selección de foto de perfil');
      final imagePath = await _imagePickerService.showImageSourceDialog(context);

      if (imagePath != null) {
        _logger.i('✅ Foto de perfil seleccionada: $imagePath');
      } else {
        _logger.i('❌ Selección de foto cancelada por el usuario');
      }

      return imagePath;
    } catch (e) {
      _logger.e('❌ Error seleccionando foto de perfil: $e');
      _setError('Error al seleccionar la imagen');
      return null;
    }
  }

  // ✅ NUEVO: Método para actualizar solo la foto de perfil
  Future<bool> updateProfilePicture(String imagePath) async {
    if (_currentUser == null) return false;

    return await updateProfile(profilePicturePath: imagePath);
  }

  // ✅ NUEVO: Método para eliminar foto de perfil
  Future<bool> removeProfilePicture() async {
    if (_currentUser == null || _currentUser!.profilePicturePath == null) return false;

    try {
      await _imagePickerService.deleteProfilePicture(_currentUser!.profilePicturePath);
      return await updateProfile(profilePicturePath: ''); // String vacío para eliminar
    } catch (e) {
      _logger.e('❌ Error eliminando foto de perfil: $e');
      return false;
    }
  }

  /// Inicializar provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.i('🔑 Inicializando AuthProvider optimizado');
    _setLoading(true);

    try {
      _isInitialized = true;
      _logger.i('✅ AuthProvider inicializado');
    } catch (e) {
      _logger.e('❌ Error inicializando AuthProvider: $e');
      _setError('Error de inicialización');
    } finally {
      _setLoading(false);
    }
  }

  /// Iniciar sesión como desarrollador
  Future<bool> loginAsDeveloper() async {
    _logger.i('🚀 Iniciando sesión como desarrollador...');
    _setLoading(true);
    _clearError();

    try {
      final devUser = await _databaseService.createDeveloperAccount();

      if (devUser != null) {
        _currentUser = devUser;
        _logger.i('✅ Sesión iniciada como desarrollador: ${devUser.name}');
        notifyListeners();
        return true;
      } else {
        _setError('No se pudo crear o iniciar sesión como desarrollador');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error en login de desarrollador: $e');
      _setError('Error fatal en el modo desarrollador');
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

  // Métodos privados
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
  // ============================================================================
// MÉTODOS QUE TRABAJAN CON LOS DATOS QUE SÍ EXISTEN
// ============================================================================

// Añadir estos métodos al OptimizedAnalyticsProvider

// Getter corregido para wellbeingScore


  /// Obtener insights destacados (basado en datos reales)
  List<Map<String, String>> getHighlightedInsights() {
    final insights = <Map<String, String>>[];
    if (_analytics.isEmpty) return insights;

    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (basicStats != null) {
      final avgMood = basicStats['avg_mood'] as double? ?? 5.0;
      final totalEntries = basicStats['total_entries'] as int? ?? 0;
      final avgEnergy = basicStats['avg_energy'] as double? ?? 5.0;
      final avgStress = basicStats['avg_stress'] as double? ?? 5.0;

      // Insight sobre mood
      if (avgMood >= 7.0) {
        insights.add({
          'emoji': '😊',
          'type': 'mood',
          'title': 'Excelente Estado de Ánimo',
          'description': 'Tu mood promedio es ${avgMood.toStringAsFixed(1)}/10'
        });
      } else if (avgMood < 4.0) {
        insights.add({
          'emoji': '💪',
          'type': 'improvement',
          'title': 'Espacio para Crecer',
          'description': 'Tu mood puede mejorar con pequeños cambios'
        });
      }

      // Insight sobre energía
      if (avgEnergy >= 7.0) {
        insights.add({
          'emoji': '⚡',
          'type': 'energy',
          'title': 'Energía Alta',
          'description': 'Mantienes buenos niveles de energía'
        });
      }

      // Insight sobre estrés
      if (avgStress <= 3.0) {
        insights.add({
          'emoji': '🧘',
          'type': 'stress',
          'title': 'Estrés Bajo',
          'description': 'Manejas bien el estrés diario'
        });
      } else if (avgStress >= 7.0) {
        insights.add({
          'emoji': '⚠️',
          'type': 'stress',
          'title': 'Estrés Alto',
          'description': 'Considera técnicas de relajación'
        });
      }

      // Insight sobre actividad
      if (totalEntries >= 20) {
        insights.add({
          'emoji': '📊',
          'type': 'activity',
          'title': 'Muy Activo',
          'description': 'Has registrado $totalEntries entradas'
        });
      }
    }

    // Insight sobre racha
    if (streakData != null) {
      final currentStreak = streakData['current_streak'] as int? ?? 0;
      if (currentStreak >= 7) {
        insights.add({
          'emoji': '🔥',
          'type': 'streak',
          'title': 'Racha Impresionante',
          'description': '$currentStreak días consecutivos'
        });
      }
    }

    return insights;
  }
  // ============================================================================
// presentation/providers/analytics_extensions.dart - NUEVAS FUNCIONALIDADES
// ============================================================================

// Métodos adicionales para el OptimizedAnalyticsProvider
// Agregar estos métodos al provider existente

  /// Predicción de bienestar para los próximos días basada en patrones
  Map<String, dynamic> getWellbeingPrediction() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final moodTrends = _analytics['mood_trends'] as List? ?? [];

    if (basicStats == null || moodTrends.isEmpty) {
      return {
        'prediction': 'neutral',
        'confidence': 0.0,
        'trend': 'stable',
        'recommendation': 'Registra más días para obtener predicciones',
        'predicted_score': 5.0,
      };
    }

    final avgMood = basicStats['avg_mood'] as double? ?? 5.0;
    final avgEnergy = basicStats['avg_energy'] as double? ?? 5.0;
    final avgStress = basicStats['avg_stress'] as double? ?? 5.0;

    // Análisis de tendencia de los últimos 7 días
    final recentTrends = moodTrends.take(7).toList();
    double trendDirection = 0.0;

    if (recentTrends.length >= 3) {
      final recent = recentTrends.take(3).map((t) => t['mood_score'] as double? ?? 5.0).toList();
      final older = recentTrends.skip(3).map((t) => t['mood_score'] as double? ?? 5.0).toList();

      if (older.isNotEmpty) {
        final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
        final olderAvg = older.reduce((a, b) => a + b) / older.length;
        trendDirection = recentAvg - olderAvg;
      }
    }

    // Predicción basada en patrones
    final predictedScore = (avgMood + (trendDirection * 0.5)).clamp(1.0, 10.0);
    final confidence = (recentTrends.length / 7.0).clamp(0.0, 1.0);

    String prediction, trend, recommendation;

    if (trendDirection > 0.5) {
      prediction = 'improving';
      trend = 'ascending';
      recommendation = 'Continúa con tus hábitos actuales';
    } else if (trendDirection < -0.5) {
      prediction = 'declining';
      trend = 'descending';
      recommendation = 'Considera dedicar tiempo al autocuidado';
    } else {
      prediction = 'stable';
      trend = 'stable';
      recommendation = 'Mantén el equilibrio actual';
    }

    return {
      'prediction': prediction,
      'confidence': confidence,
      'trend': trend,
      'recommendation': recommendation,
      'predicted_score': predictedScore,
      'current_score': avgMood,
    };
  }

  /// Análisis de hábitos saludables basado en registros
  Map<String, dynamic> getHealthyHabitsAnalysis() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;

    if (basicStats == null) {
      return {
        'sleep_score': 0.0,
        'exercise_score': 0.0,
        'meditation_score': 0.0,
        'social_score': 0.0,
        'overall_score': 0.0,
        'recommendations': ['Registra más días para análisis de hábitos'],
      };
    }

    final avgSleep = basicStats['avg_sleep_quality'] as double? ?? 5.0;
    final avgPhysical = basicStats['avg_physical_activity'] as double? ?? 5.0;
    final avgMeditation = basicStats['avg_meditation_minutes'] as double? ?? 0.0;
    final avgSocial = basicStats['avg_social_interaction'] as double? ?? 5.0;

    // Normalizar puntuaciones a 0-1
    final sleepScore = (avgSleep / 10.0).clamp(0.0, 1.0);
    final exerciseScore = (avgPhysical / 10.0).clamp(0.0, 1.0);
    final meditationScore = (avgMeditation / 30.0).clamp(0.0, 1.0); // 30 min = máximo
    final socialScore = (avgSocial / 10.0).clamp(0.0, 1.0);

    final overallScore = (sleepScore + exerciseScore + meditationScore + socialScore) / 4.0;

    final recommendations = <String>[];

    if (sleepScore < 0.6) recommendations.add('Mejora tu calidad de sueño');
    if (exerciseScore < 0.6) recommendations.add('Incrementa tu actividad física');
    if (meditationScore < 0.3) recommendations.add('Prueba la meditación diaria');
    if (socialScore < 0.6) recommendations.add('Conecta más con otros');

    if (recommendations.isEmpty) {
      recommendations.add('¡Excelente! Mantén tus hábitos saludables');
    }

    return {
      'sleep_score': sleepScore,
      'exercise_score': exerciseScore,
      'meditation_score': meditationScore,
      'social_score': socialScore,
      'overall_score': overallScore,
      'recommendations': recommendations,
    };
  }

  /// Comparación con semanas anteriores
  Map<String, dynamic> getWeeklyComparison() {
    final moodTrends = _analytics['mood_trends'] as List? ?? [];

    if (moodTrends.length < 14) {
      return {
        'has_data': false,
        'message': 'Necesitas al menos 2 semanas de datos',
        'mood_change': 0.0,
        'energy_change': 0.0,
        'stress_change': 0.0,
      };
    }

    // Última semana vs anterior
    final thisWeek = moodTrends.take(7).toList();
    final lastWeek = moodTrends.skip(7).take(7).toList();

    final thisWeekMood = thisWeek.map((t) => t['mood_score'] as double? ?? 5.0)
        .reduce((a, b) => a + b) / thisWeek.length;
    final lastWeekMood = lastWeek.map((t) => t['mood_score'] as double? ?? 5.0)
        .reduce((a, b) => a + b) / lastWeek.length;

    final thisWeekEnergy = thisWeek.map((t) => t['energy_level'] as double? ?? 5.0)
        .reduce((a, b) => a + b) / thisWeek.length;
    final lastWeekEnergy = lastWeek.map((t) => t['energy_level'] as double? ?? 5.0)
        .reduce((a, b) => a + b) / lastWeek.length;

    final thisWeekStress = thisWeek.map((t) => t['stress_level'] as double? ?? 5.0)
        .reduce((a, b) => a + b) / thisWeek.length;
    final lastWeekStress = lastWeek.map((t) => t['stress_level'] as double? ?? 5.0)
        .reduce((a, b) => a + b) / lastWeek.length;

    return {
      'has_data': true,
      'mood_change': thisWeekMood - lastWeekMood,
      'energy_change': thisWeekEnergy - lastWeekEnergy,
      'stress_change': thisWeekStress - lastWeekStress,
      'current_week': {
        'mood': thisWeekMood,
        'energy': thisWeekEnergy,
        'stress': thisWeekStress,
      },
      'previous_week': {
        'mood': lastWeekMood,
        'energy': lastWeekEnergy,
        'stress': lastWeekStress,
      },
    };
  }

  /// Recomendaciones personalizadas basadas en IA
  List<Map<String, dynamic>> getPersonalizedRecommendations() {
    final recommendations = <Map<String, dynamic>>[];

    final wellbeingStatus = getWellbeingStatus();
    final habitsAnalysis = getHealthyHabitsAnalysis();
    final stressAlerts = getStressAlerts();
    final prediction = getWellbeingPrediction();

    final currentScore = wellbeingStatus['score'] as int? ?? 5;
    final stressLevel = stressAlerts['level'] as String? ?? 'sin datos';
    final trend = prediction['trend'] as String? ?? 'stable';

    // Recomendaciones basadas en estrés
    if (stressLevel == 'alto') {
      recommendations.add({
        'icon': '🧘‍♀️',
        'title': 'Sesión de Mindfulness',
        'description': 'Dedica 10 minutos a la meditación',
        'type': 'stress_relief',
        'priority': 'high',
        'action': 'meditate',
        'estimated_time': '10 min',
      });
    }

    // Recomendaciones basadas en hábitos
    final sleepScore = habitsAnalysis['sleep_score'] as double? ?? 0.5;
    if (sleepScore < 0.6) {
      recommendations.add({
        'icon': '😴',
        'title': 'Rutina de Sueño',
        'description': 'Establece una hora fija para dormir',
        'type': 'sleep',
        'priority': 'medium',
        'action': 'plan_sleep',
        'estimated_time': '5 min',
      });
    }

    // Recomendaciones basadas en tendencia
    if (trend == 'descending') {
      recommendations.add({
        'icon': '🌱',
        'title': 'Momento de Gratitud',
        'description': 'Escribe 3 cosas por las que estás agradecido',
        'type': 'mood_boost',
        'priority': 'medium',
        'action': 'gratitude',
        'estimated_time': '5 min',
      });
    }

    // Recomendación de ejercicio
    final exerciseScore = habitsAnalysis['exercise_score'] as double? ?? 0.5;
    if (exerciseScore < 0.6) {
      recommendations.add({
        'icon': '🏃‍♀️',
        'title': 'Actividad Física',
        'description': 'Una caminata corta puede mejorar tu energía',
        'type': 'exercise',
        'priority': 'low',
        'action': 'walk',
        'estimated_time': '15 min',
      });
    }

    // Recomendación social
    final socialScore = habitsAnalysis['social_score'] as double? ?? 0.5;
    if (socialScore < 0.5) {
      recommendations.add({
        'icon': '👥',
        'title': 'Conexión Social',
        'description': 'Llama a un amigo o familiar',
        'type': 'social',
        'priority': 'low',
        'action': 'connect',
        'estimated_time': '10 min',
      });
    }

    // Ordenar por prioridad
    recommendations.sort((a, b) {
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      return priorityOrder[a['priority']]!.compareTo(priorityOrder[b['priority']]!);
    });

    return recommendations.take(3).toList(); // Máximo 3 recomendaciones
  }

  /// Calendario de estados de ánimo para los últimos días
  List<Map<String, dynamic>> getMoodCalendarData() {
    final moodTrends = _analytics['mood_trends'] as List? ?? [];

    return moodTrends.take(30).map((trend) {
      final mood = trend['mood_score'] as double? ?? 5.0;
      final energy = trend['energy_level'] as double? ?? 5.0;
      final stress = trend['stress_level'] as double? ?? 5.0;
      final date = DateTime.tryParse(trend['entry_date'] as String? ?? '') ?? DateTime.now();

      String emoji;
      Color color;

      final avgScore = (mood + energy + (10 - stress)) / 3;

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
        'mood': mood,
        'energy': energy,
        'stress': stress,
        'avg_score': avgScore,
        'emoji': emoji,
        'color': color,
      };
    }).toList();
  }

  /// Challenges personalizados basados en datos del usuario
  List<Map<String, dynamic>> getPersonalizedChallenges() {
    final challenges = <Map<String, dynamic>>[];

    final streakData = getStreakData();
    final habitsAnalysis = getHealthyHabitsAnalysis();
    final currentStreak = streakData['current'] as int? ?? 0;

    // Challenge de racha
    if (currentStreak < 7) {
      challenges.add({
        'id': 'weekly_streak',
        'title': 'Racha Semanal',
        'description': 'Completa 7 días seguidos de registro',
        'icon': '🔥',
        'progress': currentStreak / 7.0,
        'target': 7,
        'current': currentStreak,
        'type': 'streak',
        'reward': '¡Insignia de Constancia!',
      });
    }

    // Challenge de meditación
    final meditationScore = habitsAnalysis['meditation_score'] as double? ?? 0.0;
    if (meditationScore < 0.5) {
      challenges.add({
        'id': 'meditation_week',
        'title': 'Semana Mindful',
        'description': 'Medita 5 minutos por 5 días',
        'icon': '🧘‍♀️',
        'progress': meditationScore * 2, // Convertir a progreso del challenge
        'target': 5,
        'current': (meditationScore * 5).round(),
        'type': 'meditation',
        'reward': '¡Maestro del Mindfulness!',
      });
    }

    // Challenge de actividad física
    final exerciseScore = habitsAnalysis['exercise_score'] as double? ?? 0.0;
    if (exerciseScore < 0.7) {
      challenges.add({
        'id': 'active_week',
        'title': 'Semana Activa',
        'description': 'Haz ejercicio 4 días esta semana',
        'icon': '💪',
        'progress': exerciseScore,
        'target': 4,
        'current': (exerciseScore * 4).round(),
        'type': 'exercise',
        'reward': '¡Guerrero del Fitness!',
      });
    }

    return challenges.take(2).toList(); // Máximo 2 challenges activos
  }


  /// Obtener siguiente logro (basado en datos reales)
  Map<String, dynamic>? getNextAchievementToUnlock() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (basicStats == null) return null;

    final currentStreak = streakData?['current_streak'] as int? ?? 0;
    final totalEntries = basicStats['total_entries'] as int? ?? 0;
    final totalMeditation = basicStats['total_meditation'] as int? ?? 0;
    final totalExercise = basicStats['total_exercise'] as int? ?? 0;

    // Logros basados en rachas
    if (currentStreak < 3) {
      return {
        'emoji': '🌱',
        'title': 'Primer Paso',
        'description': 'Mantén una racha de 3 días',
        'progress': currentStreak / 3,
        'target': 3,
        'current': currentStreak,
        'type': 'streak'
      };
    } else if (currentStreak < 7) {
      return {
        'emoji': '🔥',
        'title': 'Una Semana',
        'description': 'Alcanza 7 días consecutivos',
        'progress': currentStreak / 7,
        'target': 7,
        'current': currentStreak,
        'type': 'streak'
      };
    } else if (currentStreak < 30) {
      return {
        'emoji': '💎',
        'title': 'Un Mes Completo',
        'description': 'Logra 30 días consecutivos',
        'progress': currentStreak / 30,
        'target': 30,
        'current': currentStreak,
        'type': 'streak'
      };
    }

    // Logros basados en entradas
    if (totalEntries < 50) {
      return {
        'emoji': '📚',
        'title': 'Medio Centenar',
        'description': 'Completa 50 entradas totales',
        'progress': totalEntries / 50,
        'target': 50,
        'current': totalEntries,
        'type': 'entries'
      };
    }

    // Logros basados en meditación
    if (totalMeditation < 300) { // 5 horas = 300 minutos
      return {
        'emoji': '🧘',
        'title': 'Meditador',
        'description': 'Acumula 5 horas de meditación',
        'progress': totalMeditation / 300,
        'target': 300,
        'current': totalMeditation,
        'type': 'meditation'
      };
    }

    return {
      'emoji': '🏆',
      'title': 'Maestro del Bienestar',
      'description': '¡Has alcanzado todos los logros!',
      'progress': 1.0,
      'target': 1,
      'current': 1,
      'type': 'mastery'
    };
  }

  /// Obtener estado de bienestar (basado en datos reales)
  Map<String, dynamic> getWellbeingStatus() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;

    if (basicStats == null) {
      return {
        'score': 0,
        'level': 'Sin datos',
        'emoji': '📊',
        'message': 'Registra algunos días para ver tu estado',
      };
    }

    final avgMood = basicStats['avg_mood'] as double? ?? 5.0;
    final avgEnergy = basicStats['avg_energy'] as double? ?? 5.0;
    final avgStress = basicStats['avg_stress'] as double? ?? 5.0;

    // Calcular score combinado (mood + energía - estrés)
    final combinedScore = (avgMood + avgEnergy + (10 - avgStress)) / 3;
    final score = combinedScore.round();

    String level, emoji, message;

    if (score >= 8) {
      level = 'Excelente';
      emoji = '🌟';
      message = '¡Tu bienestar está en un nivel excepcional!';
    } else if (score >= 6) {
      level = 'Bueno';
      emoji = '😊';
      message = 'Mantienes un buen equilibrio general';
    } else if (score >= 4) {
      level = 'Regular';
      emoji = '🌱';
      message = 'Hay espacio para mejorar tu bienestar';
    } else {
      level = 'Necesita Atención';
      emoji = '🔥';
      message = 'Enfócate en cuidar tu bienestar';
    }

    return {
      'score': score,
      'level': level,
      'emoji': emoji,
      'message': message,
      'mood': avgMood,
      'energy': avgEnergy,
      'stress': avgStress,
    };
  }

  /// Obtener datos para gráfico de mood (basado en datos reales)
  List<Map<String, dynamic>> getMoodChartData() {
    final moodTrends = _analytics['mood_trends'] as List? ?? [];

    return moodTrends.map((trend) {
      return {
        'date': trend['entry_date'] ?? DateTime.now().toIso8601String(),
        'mood': trend['mood_score'] ?? 5.0,
        'energy': trend['energy_level'] ?? 5.0,
        'stress': trend['stress_level'] ?? 5.0,
      };
    }).toList();
  }

  /// Obtener datos de racha (basado en datos reales)
  Map<String, dynamic> getStreakData() {
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    return {
      'current': streakData?['current_streak'] ?? 0,
      'longest': streakData?['longest_streak'] ?? 0,
    };
  }

  /// Obtener insights rápidos de mood (basado en datos reales)
  Map<String, dynamic> getQuickStatsMoodInsights() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;

    if (basicStats == null) {
      return {
        'avg_mood': 0.0,
        'trend_icon': '📊',
        'trend_description': 'Sin datos',
        'trend_color': Colors.grey,
      };
    }

    final avgMood = basicStats['avg_mood'] as double? ?? 5.0;

    String trendIcon, trendDescription;
    Color trendColor;

    if (avgMood >= 7) {
      trendIcon = '😊';
      trendDescription = 'Excelente';
      trendColor = Colors.green;
    } else if (avgMood >= 5) {
      trendIcon = '😐';
      trendDescription = 'Estable';
      trendColor = Colors.blue;
    } else {
      trendIcon = '😔';
      trendDescription = 'Bajo';
      trendColor = Colors.orange;
    }

    return {
      'avg_mood': avgMood,
      'trend_icon': trendIcon,
      'trend_description': trendDescription,
      'trend_color': trendColor,
    };
  }

  /// Obtener alertas de estrés (basado en datos reales)
  Map<String, dynamic> getStressAlerts() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;

    if (basicStats == null) {
      return {
        'requires_attention': false,
        'level': 'sin datos',
        'alert_color': Colors.grey,
        'alert_icon': '📊',
        'alert_title': 'Sin datos',
        'recommendations': ['Registra algunos días para ver alertas'],
      };
    }

    final avgStress = basicStats['avg_stress'] as double? ?? 5.0;

    if (avgStress >= 7) {
      return {
        'requires_attention': true,
        'level': 'alto',
        'alert_color': Colors.red,
        'alert_icon': '🚨',
        'alert_title': 'Nivel de estrés alto',
        'recommendations': [
          'Practica técnicas de respiración',
          'Toma descansos regulares',
          'Considera reducir la carga de trabajo'
        ],
      };
    } else if (avgStress >= 5) {
      return {
        'requires_attention': true,
        'level': 'moderado',
        'alert_color': Colors.orange,
        'alert_icon': '⚠️',
        'alert_title': 'Estrés moderado',
        'recommendations': [
          'Organiza mejor tu tiempo',
          'Practica mindfulness',
          'Asegúrate de dormir bien'
        ],
      };
    }

    return {
      'requires_attention': false,
      'level': 'bajo',
      'alert_color': Colors.green,
      'alert_icon': '✅',
      'alert_title': 'Estrés bajo',
      'recommendations': ['Mantén tus hábitos actuales'],
    };
  }

  /// Obtener resumen del dashboard (basado en datos reales)
  Map<String, dynamic> getDashboardSummary() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (basicStats == null) {
      return {
        'wellbeing_score': 0,
        'current_streak': 0,
        'total_entries': 0,
        'avg_mood': 0.0,
        'avg_energy': 0.0,
        'avg_stress': 0.0,
        'main_message': 'Comienza registrando tu primer día',
      };
    }

    final avgMood = basicStats['avg_mood'] as double? ?? 5.0;
    final avgEnergy = basicStats['avg_energy'] as double? ?? 5.0;
    final avgStress = basicStats['avg_stress'] as double? ?? 5.0;
    final totalEntries = basicStats['total_entries'] as int? ?? 0;
    final currentStreak = streakData?['current_streak'] as int? ?? 0;

    // Calcular score de bienestar
    final wellbeingScore = ((avgMood + avgEnergy + (10 - avgStress)) / 3).round();

    String mainMessage;
    if (wellbeingScore >= 8) {
      mainMessage = '¡Excelente! Tu bienestar está en un nivel óptimo';
    } else if (wellbeingScore >= 6) {
      mainMessage = 'Buen progreso. Mantén el equilibrio';
    } else if (wellbeingScore >= 4) {
      mainMessage = 'Vas por buen camino. Sigue mejorando';
    } else {
      mainMessage = 'Enfócate en cuidar tu bienestar día a día';
    }

    return {
      'wellbeing_score': wellbeingScore,
      'current_streak': currentStreak,
      'total_entries': totalEntries,
      'avg_mood': avgMood,
      'avg_energy': avgEnergy,
      'avg_stress': avgStress,
      'main_message': mainMessage,
    };
  }

  /// Obtener insights de diversidad (simulado por ahora)
  Map<String, dynamic> getQuickStatsDiversityInsights() {
    // Por ahora simulamos, pero se podría calcular basado en moment_stats
    return {
      'categories_used': 3,
      'max_categories': 5,
      'diversity_score': 0.6,
      'message': 'Explora más categorías',
    };
  }

  /// Obtener recomendaciones prioritarias (basado en datos reales)
  List<Map<String, dynamic>> getPriorityRecommendations() {
    final recommendations = <Map<String, dynamic>>[];
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;

    if (basicStats == null) {
      recommendations.add({
        'emoji': '📝',
        'title': 'Comienza a Registrar',
        'description': 'Crea tu primera entrada diaria',
        'priority': 'high',
      });
      return recommendations;
    }

    final avgMood = basicStats['avg_mood'] as double? ?? 5.0;
    final avgEnergy = basicStats['avg_energy'] as double? ?? 5.0;
    final avgStress = basicStats['avg_stress'] as double? ?? 5.0;
    final avgSleep = basicStats['avg_sleep'] as double? ?? 8.0;
    final totalMeditation = basicStats['total_meditation'] as int? ?? 0;

    // Recomendación basada en mood bajo
    if (avgMood < 5.0) {
      recommendations.add({
        'emoji': '😊',
        'title': 'Mejora tu Estado de Ánimo',
        'description': 'Dedica tiempo a actividades que disfrutes',
        'priority': 'high',
      });
    }

    // Recomendación basada en energía baja
    if (avgEnergy < 5.0) {
      recommendations.add({
        'emoji': '⚡',
        'title': 'Aumenta tu Energía',
        'description': 'Revisa tu alimentación y ejercicio',
        'priority': 'medium',
      });
    }

    // Recomendación basada en estrés alto
    if (avgStress >= 7.0) {
      recommendations.add({
        'emoji': '🧘',
        'title': 'Reduce el Estrés',
        'description': 'Practica técnicas de relajación',
        'priority': 'high',
      });
    }

    // Recomendación basada en sueño
    if (avgSleep < 7.0) {
      recommendations.add({
        'emoji': '😴',
        'title': 'Mejora tu Sueño',
        'description': 'Apunta a 7-8 horas de sueño diario',
        'priority': 'medium',
      });
    }

    // Recomendación basada en meditación
    if (totalMeditation < 60) {
      recommendations.add({
        'emoji': '🧘‍♀️',
        'title': 'Inicia con Meditación',
        'description': 'Comienza con 5 minutos diarios',
        'priority': 'low',
      });
    }

    // Si todo va bien
    if (recommendations.isEmpty) {
      recommendations.add({
        'emoji': '🎯',
        'title': 'Mantén el Equilibrio',
        'description': 'Continúa con tus excelentes hábitos',
        'priority': 'low',
      });
    }

    return recommendations;
  }

  /// Obtener temas dominantes (simulado por ahora)
  List<Map<String, dynamic>> getDominantThemes() {
    // Por ahora retornamos datos simulados
    // Se podría implementar analizando moment_stats cuando exista
    return [
      {'word': 'trabajo', 'count': 15, 'type': 'neutral', 'emoji': '💼'},
      {'word': 'familia', 'count': 12, 'type': 'positive', 'emoji': '👨‍👩‍👧‍👦'},
      {'word': 'ejercicio', 'count': 8, 'type': 'positive', 'emoji': '🏃‍♀️'},
      {'word': 'estrés', 'count': 6, 'type': 'negative', 'emoji': '😰'},
    ];
  }

  /// Obtener análisis del día actual (simulado)
  Map<String, dynamic> getCurrentDayAnalysis() {
    return {
      'has_entry': false,
      'message': 'Aún no has registrado hoy',
      'recommendation': 'Toma un momento para reflexionar sobre tu día',
    };
  }

  /// Obtener top recomendaciones
  List<Map<String, dynamic>> getTopRecommendations() {
    return getPriorityRecommendations().take(3).toList();
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
// lib/presentation/providers/goals_provider.dart
// ============================================================================
// GOALS PROVIDER - GESTIÓN COMPLETA DE OBJETIVOS CON AUTO-TRACKING
// ============================================================================



class GoalsProvider with ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  GoalsProvider(this._databaseService);

  // Getters principales
  List<GoalModel> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters específicos
  List<GoalModel> get activeGoals =>
      _goals.where((goal) => goal.status == GoalStatus.active).toList();

  List<GoalModel> get completedGoals =>
      _goals.where((goal) => goal.status == GoalStatus.completed).toList();

  List<GoalModel> get archivedGoals =>
      _goals.where((goal) => goal.status == GoalStatus.archived).toList();

  // Métricas agregadas
  double get averageProgress {
    if (activeGoals.isEmpty) return 0.0;
    final totalProgress = activeGoals.fold<double>(
      0.0,
          (sum, goal) => sum + goal.progress,
    );
    return totalProgress / activeGoals.length;
  }

  int get totalGoalsCount => _goals.length;

  Map<GoalType, int> get goalsByType {
    final Map<GoalType, int> result = {};
    for (final goal in _goals) {
      result[goal.type] = (result[goal.type] ?? 0) + 1;
    }
    return result;
  }

  /// Cargar objetivos del usuario
  Future<void> loadUserGoals(int userId) async {
    _logger.d('🎯 Cargando objetivos para usuario: $userId');
    _setLoading(true);
    _clearError();

    try {
      _goals = await _databaseService.getUserGoals(userId);
      _logger.i('✅ Cargados ${_goals.length} objetivos');
    } catch (e) {
      _logger.e('❌ Error cargando objetivos: $e');
      _setError('Error cargando objetivos');
    } finally {
      _setLoading(false);
    }
  }

  /// Crear nuevo objetivo
  Future<bool> createGoal({
    required int userId,
    required String title,
    required String description,
    required String type,
    required double targetValue,
  }) async {
    _logger.i('🎯 Creando objetivo: $title');
    _setLoading(true);
    _clearError();

    try {
      // Convertir string a enum
      final goalType = _parseGoalType(type);

      final goal = GoalModel(
        userId: userId,
        title: title,
        description: description,
        type: goalType,
        targetValue: targetValue,
        createdAt: DateTime.now(),
      );

      final goalId = await _databaseService.createGoal(goal);

      if (goalId != null) {
        final savedGoal = goal.copyWith(id: goalId);
        _goals.insert(0, savedGoal);

        _logger.i('✅ Objetivo creado exitosamente: $title');
        notifyListeners();
        return true;
      } else {
        _setError('No se pudo crear el objetivo');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error creando objetivo: $e');
      _setError('Error creando objetivo');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar objetivo existente
  Future<bool> updateGoal(
      int goalId, {
        String? title,
        String? description,
        String? type,
        double? targetValue,
        double? currentValue,
      }) async {
    _logger.i('📝 Actualizando objetivo: $goalId');
    _setLoading(true);
    _clearError();

    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) {
        _setError('Objetivo no encontrado');
        return false;
      }

      final existingGoal = _goals[goalIndex];
      final updatedGoal = existingGoal.copyWith(
        title: title,
        description: description,
        type: type != null ? _parseGoalType(type) : null,
        targetValue: targetValue,
        currentValue: currentValue,
      );

      final success = await _databaseService.updateGoal(updatedGoal);

      if (success) {
        _goals[goalIndex] = updatedGoal;
        _logger.i('✅ Objetivo actualizado exitosamente');
        notifyListeners();
        return true;
      } else {
        _setError('No se pudo actualizar el objetivo');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error actualizando objetivo: $e');
      _setError('Error actualizando objetivo');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar progreso de un objetivo
  Future<bool> updateGoalProgress(int goalId, double newValue) async {
    _logger.d('📊 Actualizando progreso objetivo $goalId: $newValue');

    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return false;

      final goal = _goals[goalIndex];
      final updatedGoal = goal.copyWith(currentValue: newValue);

      // Verificar si se completó automáticamente
      if (updatedGoal.progress >= 1.0 && goal.status == GoalStatus.active) {
        final completedGoal = updatedGoal.copyWith(
          status: GoalStatus.completed,
          completedAt: DateTime.now(),
        );

        final success = await _databaseService.updateGoal(completedGoal);
        if (success) {
          _goals[goalIndex] = completedGoal;
          _logger.i('🎉 ¡Objetivo completado automáticamente!: ${goal.title}');
        }
      } else {
        final success = await _databaseService.updateGoal(updatedGoal);
        if (success) {
          _goals[goalIndex] = updatedGoal;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('❌ Error actualizando progreso: $e');
      return false;
    }
  }

  /// Completar objetivo manualmente
  Future<bool> completeGoal(int goalId) async {
    _logger.i('✅ Completando objetivo: $goalId');

    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return false;

      final goal = _goals[goalIndex];
      final completedGoal = goal.copyWith(
        status: GoalStatus.completed,
        completedAt: DateTime.now(),
        currentValue: goal.targetValue, // Marcar como 100% completado
      );

      final success = await _databaseService.updateGoal(completedGoal);

      if (success) {
        _goals[goalIndex] = completedGoal;
        _logger.i('🎉 Objetivo completado: ${goal.title}');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('❌ Error completando objetivo: $e');
      return false;
    }
  }

  /// Reactivar objetivo completado
  Future<bool> reactivateGoal(int goalId) async {
    _logger.i('🔄 Reactivando objetivo: $goalId');

    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return false;

      final goal = _goals[goalIndex];
      final reactivatedGoal = goal.copyWith(
        status: GoalStatus.active,
        completedAt: null,
      );

      final success = await _databaseService.updateGoal(reactivatedGoal);

      if (success) {
        _goals[goalIndex] = reactivatedGoal;
        _logger.i('🔄 Objetivo reactivado: ${goal.title}');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('❌ Error reactivando objetivo: $e');
      return false;
    }
  }

  /// Archivar objetivo
  Future<bool> archiveGoal(int goalId) async {
    _logger.i('📦 Archivando objetivo: $goalId');

    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return false;

      final goal = _goals[goalIndex];
      final archivedGoal = goal.copyWith(status: GoalStatus.archived);

      final success = await _databaseService.updateGoal(archivedGoal);

      if (success) {
        _goals[goalIndex] = archivedGoal;
        _logger.i('📦 Objetivo archivado: ${goal.title}');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('❌ Error archivando objetivo: $e');
      return false;
    }
  }

  /// Eliminar objetivo
  Future<bool> deleteGoal(int goalId) async {
    _logger.i('🗑️ Eliminando objetivo: $goalId');

    try {
      final success = await _databaseService.deleteGoal(goalId);

      if (success) {
        _goals.removeWhere((g) => g.id == goalId);
        _logger.i('🗑️ Objetivo eliminado exitosamente');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('❌ Error eliminando objetivo: $e');
      return false;
    }
  }

  /// Auto-actualizar progreso basado en datos del usuario
  Future<void> updateGoalsProgress(int userId) async {
    _logger.d('🔄 Auto-actualizando progreso de objetivos');

    try {
      for (final goal in activeGoals) {
        double newProgress = 0.0;

        switch (goal.type) {
          case GoalType.consistency:
            newProgress = await _calculateConsistencyProgress(userId, goal);
            break;
          case GoalType.mood:
            newProgress = await _calculateMoodProgress(userId, goal);
            break;
          case GoalType.positiveMoments:
            newProgress = await _calculatePositiveMomentsProgress(userId, goal);
            break;
          case GoalType.stressReduction:
            newProgress = await _calculateStressReductionProgress(userId, goal);
            break;
        }

        if (newProgress != goal.currentValue) {
          await updateGoalProgress(goal.id!, newProgress);
        }
      }
    } catch (e) {
      _logger.e('❌ Error auto-actualizando progreso: $e');
    }
  }

  /// Calcular progreso de consistencia (días consecutivos)
  Future<double> _calculateConsistencyProgress(int userId, GoalModel goal) async {
    try {
      // Obtener datos de streak del analytics
      final analytics = await _databaseService.getUserAnalytics(userId, days: 30);
      final streakData = analytics['streak_data'] as Map<String, dynamic>?;
      final currentStreak = streakData?['current_streak'] as int? ?? 0;

      return currentStreak.toDouble();
    } catch (e) {
      _logger.e('Error calculando progreso de consistencia: $e');
      return goal.currentValue;
    }
  }

  /// Calcular progreso de mood (puntuación promedio)
  Future<double> _calculateMoodProgress(int userId, GoalModel goal) async {
    try {
      final analytics = await _databaseService.getUserAnalytics(userId, days: 30);
      final basicStats = analytics['basic_stats'] as Map<String, dynamic>?;
      final avgMood = basicStats?['avg_mood'] as double? ?? 0.0;

      // Convertir mood de 0-10 a valor de progreso
      return avgMood;
    } catch (e) {
      _logger.e('Error calculando progreso de mood: $e');
      return goal.currentValue;
    }
  }

  /// Calcular progreso de momentos positivos
  Future<double> _calculatePositiveMomentsProgress(int userId, GoalModel goal) async {
    try {
      // Obtener momentos positivos del último mes
      final moments = await _databaseService.getInteractiveMoments(
        userId: userId,
        type: 'positive',
        limit: 1000,
      );

      final positiveMomentsCount = moments.length;
      return positiveMomentsCount.toDouble();
    } catch (e) {
      _logger.e('Error calculando progreso de momentos positivos: $e');
      return goal.currentValue;
    }
  }

  /// Calcular progreso de reducción de estrés
  Future<double> _calculateStressReductionProgress(int userId, GoalModel goal) async {
    try {
      final analytics = await _databaseService.getUserAnalytics(userId, days: 30);
      final basicStats = analytics['basic_stats'] as Map<String, dynamic>?;
      final avgStress = basicStats?['avg_stress'] as double? ?? 5.0;

      // Para reducción de estrés, menor valor = mejor progreso
      // Convertir: si objetivo es reducir estrés a 3, y actual es 7, progreso sería bajo
      final stressReduction = math.max(0.0, 10.0 - avgStress); // ✅ FIXED: Usar double explícitamente
      return stressReduction.toDouble(); // ✅ FIXED: Conversión explícita a double
    } catch (e) {
      _logger.e('Error calculando progreso de reducción de estrés: $e');
      return goal.currentValue;
    }
  }

  /// Obtener objetivos por tipo específico
  List<GoalModel> getGoalsByType(GoalType type) {
    return _goals.where((goal) => goal.type == type).toList();
  }

  /// Obtener estadísticas de objetivos
  Map<String, dynamic> getGoalsStatistics() {
    final total = _goals.length;
    final active = activeGoals.length;
    final completed = completedGoals.length;
    final archived = archivedGoals.length;

    return {
      'total': total,
      'active': active,
      'completed': completed,
      'archived': archived,
      'completion_rate': total > 0 ? completed / total : 0.0,
      'average_progress': averageProgress,
      'goals_by_type': goalsByType,
    };
  }

  // Métodos privados de utilidad
  GoalType _parseGoalType(String type) {
    switch (type.toLowerCase()) {
      case 'consistency':
        return GoalType.consistency;
      case 'mood':
        return GoalType.mood;
      case 'positivemoments':
        return GoalType.positiveMoments;
      case 'stressreduction':
        return GoalType.stressReduction;
      default:
        return GoalType.consistency;
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
// EXTENSIÓN PARA EL OPTIMIZED DATABASE SERVICE - MÉTODOS DE GOALS
// ============================================================================

extension GoalsDatabase on OptimizedDatabaseService {

  /// Obtener objetivos del usuario
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
      throw Exception('Error obteniendo objetivos: $e');
    }
  }

  /// Crear nuevo objetivo
  Future<int?> createGoal(GoalModel goal) async {
    try {
      final db = await database;
      return await db.insert('user_goals', goal.toDatabase());
    } catch (e) {
      throw Exception('Error creando objetivo: $e');
    }
  }

  /// Actualizar objetivo
  Future<bool> updateGoal(GoalModel goal) async {
    try {
      final db = await database;
      final rowsAffected = await db.update(
        'user_goals',
        goal.toDatabase(),
        where: 'id = ?',
        whereArgs: [goal.id],
      );
      return rowsAffected > 0;
    } catch (e) {
      throw Exception('Error actualizando objetivo: $e');
    }
  }

  /// Eliminar objetivo
  Future<bool> deleteGoal(int goalId) async {
    try {
      final db = await database;
      final rowsAffected = await db.delete(
        'user_goals',
        where: 'id = ?',
        whereArgs: [goalId],
      );
      return rowsAffected > 0;
    } catch (e) {
      throw Exception('Error eliminando objetivo: $e');
    }
  }

  /// Obtener objetivos por tipo
  Future<List<GoalModel>> getGoalsByType(int userId, GoalType type) async {
    try {
      final db = await database;
      final results = await db.query(
        'user_goals',
        where: 'user_id = ? AND type = ?',
        whereArgs: [userId, type.toString()],
        orderBy: 'created_at DESC',
      );

      return results.map((row) => GoalModel.fromDatabase(row)).toList();
    } catch (e) {
      throw Exception('Error obteniendo objetivos por tipo: $e');
    }
  }

  /// Obtener objetivos por estado
  Future<List<GoalModel>> getGoalsByStatus(int userId, GoalStatus status) async {
    try {
      final db = await database;
      final results = await db.query(
        'user_goals',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, status.toString()],
        orderBy: 'created_at DESC',
      );

      return results.map((row) => GoalModel.fromDatabase(row)).toList();
    } catch (e) {
      throw Exception('Error obteniendo objetivos por estado: $e');
    }
  }
}