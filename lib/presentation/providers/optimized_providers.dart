// lib/presentation/providers/optimized_providers.dart - UPDATED WITH PROFILE PICTURE
// ============================================================================
// AUTH PROVIDER ACTUALIZADO CON SOPORTE PARA FOTOS DE PERFIL
// ============================================================================

export 'analytics_provider_optimized.dart';

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
  bool _isFirstTimeUser = false;

  OptimizedAuthProvider(this._databaseService);

  // Getters
  OptimizedUserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isFirstTimeUser => _isFirstTimeUser;

  // ✅ MÉTODO ACTUALIZADO PARA REGISTRO CON FOTO Y ONBOARDING
  Future<OptimizedUserModel?> register({
    required String email,
    required String password,
    required String name,
    String avatarEmoji = '🧘‍♀️',
    String? profilePicturePath,
    int? age,
    String bio = '',
    bool isFirstTimeUser = false,
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
        profilePicturePath: profilePicturePath,
        bio: bio,
      );

      if (user != null) {
        _currentUser = user;
        _isFirstTimeUser = false; // Mark as not first time after registration
        _logger.i('✅ Usuario registrado exitosamente: ${user.name}');
        notifyListeners();
        return user;
      } else {
        _setError('No se pudo crear el usuario');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error en registro: $e');
      _setError('Error durante el registro');
      return null;
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

  /// Check if this is a first time user by checking if any users exist in the database
  Future<void> checkFirstTimeUser() async {
    _setLoading(true);
    try {
      final hasUsers = await _databaseService.hasAnyUsers();
      _isFirstTimeUser = !hasUsers;
      _logger.i('🔍 First time user check: ${_isFirstTimeUser ? "Yes" : "No"}');
      
      // If there are users but no one is logged in, automatically log in the first user
      if (hasUsers && _currentUser == null) {
        await _autoLoginExistingUser();
      }
      
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error checking first time user: $e');
      _isFirstTimeUser = false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Automatically log in the existing user (single profile per device)
  Future<void> _autoLoginExistingUser() async {
    try {
      final user = await _databaseService.getFirstUser();
      if (user != null) {
        _currentUser = user;
        _logger.i('✅ Auto-logged in existing user: ${user.name}');
      }
    } catch (e) {
      _logger.e('❌ Error auto-logging in existing user: $e');
    }
  }
  
  /// Create default profile after onboarding (single profile per device)
  Future<bool> createDefaultProfile({
    required String name,
    String avatarEmoji = '🧘‍♀️',
    String? profilePicturePath,
    int? age,
    String bio = '',
    List<GoalModel>? goals,
  }) async {
    _logger.i('👤 Creating default profile for device');
    _setLoading(true);
    _clearError();

    try {
      // Create user with default email based on device
      final deviceEmail = 'user@device.local';
      final user = await _databaseService.createUser(
        email: deviceEmail,
        password: 'device_user', // Not used for authentication in single profile mode
        name: name,
        avatarEmoji: avatarEmoji,
        profilePicturePath: profilePicturePath,
        bio: bio,
      );

      if (user != null) {
        _currentUser = user;
        _isFirstTimeUser = false;
        
        // Add goals if provided
        if (goals != null && goals.isNotEmpty) {
          for (final goal in goals) {
            await _databaseService.addGoal(user.id, goal);
          }
        }
        
        _logger.i('✅ Default profile created successfully: ${user.name}');
        notifyListeners();
        return true;
      } else {
        _setError('No se pudo crear el perfil');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error creating default profile: $e');
      _setError('Error creando el perfil');
      return false;
    } finally {
      _setLoading(false);
    }
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
    String? voiceRecordingPath,
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
        voiceRecordingPath: voiceRecordingPath,
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
  // ========================================================================
  // FIX: Cambiado el tipo de retorno de Future<bool>
  // a Future<OptimizedInteractiveMomentModel?>
  // ========================================================================
  Future<OptimizedInteractiveMomentModel?> addMoment({
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

        // ========================================================================
        // FIX: Devolver el objeto del momento guardado en lugar de 'true'
        // ========================================================================
        return savedMoment;
      } else {
        _setError('No se pudo guardar el momento');

        // ========================================================================
        // FIX: Devolver null en caso de error en lugar de 'false'
        // ========================================================================
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error añadiendo momento: $e');
      _setError('Error añadiendo momento');
      return null;
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
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Aquí implementarías el método clearTodayMoments en el database service
      // await _databaseService.clearMomentsBetween(userId, startOfDay, endOfDay);

      _todayMoments.clear();
      _moments.removeWhere((m) => m.timestamp.isAfter(startOfDay) && m.timestamp.isBefore(endOfDay));
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
  int get wellbeingScore => ((_analytics['basic_stats']?['avg_wellbeing'] as num?)?.toDouble() ?? 0.0).round();
  String get wellbeingLevel {
    final score = wellbeingScore;
    if (score >= 8) return 'Excelente';
    if (score >= 6) return 'Bueno';
    if (score >= 4) return 'Regular';
    return 'Necesita Atención';
  }

  /// Cargar analytics completos del usuario
  /// ✅ ENHANCED: Carga analytics completos con inteligencia mejorada
  Future<void> loadCompleteAnalytics(int userId, {int days = 30}) async {
    _logger.d('📊 Cargando analytics inteligentes para usuario: $userId');
    _setLoading(true);
    _clearError();

    try {
      // ✅ NEW: Get enhanced analytics with intelligent insights
      _analytics = await _databaseService.getUserAnalytics(userId, days: days);
      
      // ✅ ADD: Generate additional intelligent insights
      _analytics['enhanced_summary'] = _generateEnhancedSummary();
      _analytics['personalized_tips'] = _generatePersonalizedTips();
      _analytics['wellness_forecast'] = _generateWellnessForecast();
      
      _logger.i('✅ Analytics inteligentes cargados para $days días');
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
      // FIX: Safer type casting
      final avgWellbeing = (basicStats['avg_wellbeing'] as num?)?.toDouble() ?? 0.0;
      final consistencyRate = (basicStats['consistency_rate'] as num?)?.toDouble() ?? 0.0;

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
      final currentStreak = (streakData['current_streak'] as num?)?.toInt() ?? 0;
      if (currentStreak >= 7) {
        insights.add({
          // FIX: Corrected broken emoji character
          'icon': '🔥',
          'title': 'Racha Impresionante',
          'description': '$currentStreak días consecutivos registrando'
        });
      }
    }

    return insights;
  }

  /// Obtener insights destacados (basado en datos reales)
  List<Map<String, String>> getHighlightedInsights() {
    final insights = <Map<String, String>>[];
    if (_analytics.isEmpty) return insights;

    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (basicStats != null) {
      // FIX: Safer type casting
      final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;
      final totalEntries = (basicStats['total_entries'] as num?)?.toInt() ?? 0;
      final avgEnergy = (basicStats['avg_energy'] as num?)?.toDouble() ?? 5.0;
      final avgStress = (basicStats['avg_stress'] as num?)?.toDouble() ?? 5.0;

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
      final currentStreak = (streakData['current_streak'] as num?)?.toInt() ?? 0;
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

    // FIX: Safer type casting
    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;

    // Análisis de tendencia de los últimos 7 días
    final recentTrends = moodTrends.take(7).toList();
    double trendDirection = 0.0;

    if (recentTrends.length >= 3) {
      final recent = recentTrends.take(3).map((t) => (t['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
      final older = recentTrends.skip(3).map((t) => (t['mood_score'] as num?)?.toDouble() ?? 5.0).toList();

      if (older.isNotEmpty && recent.isNotEmpty) {
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

    // FIX: Safer type casting
    final avgSleep = (basicStats['avg_sleep_quality'] as num?)?.toDouble() ?? 5.0;
    final avgPhysical = (basicStats['avg_physical_activity'] as num?)?.toDouble() ?? 5.0;
    final avgMeditation = (basicStats['avg_meditation_minutes'] as num?)?.toDouble() ?? 0.0;
    final avgSocial = (basicStats['avg_social_interaction'] as num?)?.toDouble() ?? 5.0;

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

    // FIX: Safer type casting and check for empty lists before reducing
    final thisWeekMood = thisWeek.isEmpty ? 5.0 : thisWeek.map((t) => (t['mood_score'] as num?)?.toDouble() ?? 5.0).reduce((a, b) => a + b) / thisWeek.length;
    final lastWeekMood = lastWeek.isEmpty ? 5.0 : lastWeek.map((t) => (t['mood_score'] as num?)?.toDouble() ?? 5.0).reduce((a, b) => a + b) / lastWeek.length;

    final thisWeekEnergy = thisWeek.isEmpty ? 5.0 : thisWeek.map((t) => (t['energy_level'] as num?)?.toDouble() ?? 5.0).reduce((a, b) => a + b) / thisWeek.length;
    final lastWeekEnergy = lastWeek.isEmpty ? 5.0 : lastWeek.map((t) => (t['energy_level'] as num?)?.toDouble() ?? 5.0).reduce((a, b) => a + b) / lastWeek.length;

    final thisWeekStress = thisWeek.isEmpty ? 5.0 : thisWeek.map((t) => (t['stress_level'] as num?)?.toDouble() ?? 5.0).reduce((a, b) => a + b) / thisWeek.length;
    final lastWeekStress = lastWeek.isEmpty ? 5.0 : lastWeek.map((t) => (t['stress_level'] as num?)?.toDouble() ?? 5.0).reduce((a, b) => a + b) / lastWeek.length;


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

    getWellbeingStatus(); // Call function for side effects
    final habitsAnalysis = getHealthyHabitsAnalysis();
    final stressAlerts = getStressAlerts();
    final prediction = getWellbeingPrediction();

    // FIX: Safer type casting
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
    final sleepScore = (habitsAnalysis['sleep_score'] as num?)?.toDouble() ?? 0.5;
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
    final exerciseScore = (habitsAnalysis['exercise_score'] as num?)?.toDouble() ?? 0.5;
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
    final socialScore = (habitsAnalysis['social_score'] as num?)?.toDouble() ?? 0.5;
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
      // FIX: Safer type casting
      final mood = (trend['mood_score'] as num?)?.toDouble() ?? 5.0;
      final energy = (trend['energy_level'] as num?)?.toDouble() ?? 5.0;
      final stress = (trend['stress_level'] as num?)?.toDouble() ?? 5.0;
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
    final currentStreak = (streakData['current'] as num?)?.toInt() ?? 0;

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
    final meditationScore = (habitsAnalysis['meditation_score'] as num?)?.toDouble() ?? 0.0;
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
    final exerciseScore = (habitsAnalysis['exercise_score'] as num?)?.toDouble() ?? 0.0;
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

    // FIX: Safer type casting
    final currentStreak = (streakData?['current_streak'] as num?)?.toInt() ?? 0;
    final totalEntries = (basicStats['total_entries'] as num?)?.toInt() ?? 0;
    final totalMeditation = (basicStats['total_meditation'] as num?)?.toInt() ?? 0;

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

    // FIX: Safer type casting
    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;
    final avgEnergy = (basicStats['avg_energy'] as num?)?.toDouble() ?? 5.0;
    final avgStress = (basicStats['avg_stress'] as num?)?.toDouble() ?? 5.0;

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
        // FIX: Safer type casting
        'mood': (trend['mood_score'] as num?)?.toDouble() ?? 5.0,
        'energy': (trend['energy_level'] as num?)?.toDouble() ?? 5.0,
        'stress': (trend['stress_level'] as num?)?.toDouble() ?? 5.0,
      };
    }).toList();
  }

  /// Obtener datos de racha (basado en datos reales)
  Map<String, dynamic> getStreakData() {
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    return {
      // FIX: Safer type casting
      'current': (streakData?['current_streak'] as num?)?.toInt() ?? 0,
      'longest': (streakData?['longest_streak'] as num?)?.toInt() ?? 0,
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

    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;

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

    final avgStress = (basicStats['avg_stress'] as num?)?.toDouble() ?? 5.0;

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

    // FIX: Safer type casting
    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;
    final avgEnergy = (basicStats['avg_energy'] as num?)?.toDouble() ?? 5.0;
    final avgStress = (basicStats['avg_stress'] as num?)?.toDouble() ?? 5.0;
    final totalEntries = (basicStats['total_entries'] as num?)?.toInt() ?? 0;
    final currentStreak = (streakData?['current_streak'] as num?)?.toInt() ?? 0;

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

    // FIX: Safer type casting
    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;
    final avgEnergy = (basicStats['avg_energy'] as num?)?.toDouble() ?? 5.0;
    final avgStress = (basicStats['avg_stress'] as num?)?.toDouble() ?? 5.0;
    final avgSleep = (basicStats['avg_sleep'] as num?)?.toDouble() ?? 8.0;
    final totalMeditation = (basicStats['total_meditation'] as num?)?.toInt() ?? 0;

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

  // ============================================================================
  // NEW METHODS FOR HIGH PRIORITY ENHANCEMENTS
  // ============================================================================

  /// Get mood calendar data for heatmap visualization - async version
  Future<List<Map<String, dynamic>>> getMoodCalendarDataAsync({int days = 30}) async {
    try {
      final userId = 1; // TODO: Get from auth provider
      final data = await _databaseService.getMoodCalendarData(userId, days: days);
      return data;
    } catch (e) {
      _logger.e('Error getting mood calendar data: $e');
      return [];
    }
  }

  /// Get wellbeing prediction insights
  Future<Map<String, dynamic>> getWellbeingPredictions({int days = 30}) async {
    try {
      final userId = 1; // TODO: Get from auth provider
      final data = await _databaseService.getWellbeingPredictionData(userId, days: days);
      return data;
    } catch (e) {
      _logger.e('Error getting wellbeing predictions: $e');
      return {};
    }
  }

  /// Get processed mood calendar data for UI
  List<Map<String, dynamic>> get moodCalendarData {
    final now = DateTime.now();
    final List<Map<String, dynamic>> calendarData = [];
    
    // Generate 7 days of data (last week)
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // ✅ FIX: Look for mood data with correct field name 'entry_date'
      final moodData = _analytics['mood_trends'] as List<dynamic>? ?? [];
      dynamic dayMood;
      try {
        dayMood = moodData.firstWhere(
          (m) => m != null && m['entry_date'] == dateStr,
          orElse: () => <String, dynamic>{},
        );
        if (dayMood.isEmpty) dayMood = null;
      } catch (e) {
        dayMood = null;
      }
      
      double? intensity;
      String type = 'empty';
      
      if (dayMood != null) {
        // ✅ FIX: Use correct field name 'mood_score' instead of 'mood'
        final mood = (dayMood['mood_score'] as num?)?.toDouble() ?? 5.0;
        if (mood >= 7.0) {
          type = 'positive';
          intensity = ((mood - 7.0) / 3.0).clamp(0.0, 1.0);
        } else if (mood <= 4.0) {
          type = 'negative';
          intensity = ((4.0 - mood) / 4.0).clamp(0.0, 1.0);
        } else {
          type = 'neutral';
          intensity = 0.5;
        }
      }
      
      calendarData.add({
        'date': date,
        'dateStr': dateStr,
        'type': type,
        'intensity': intensity ?? 0.0,
        'mood': dayMood?['mood_score'],
        'isToday': date.day == now.day && date.month == now.month && date.year == now.year,
        'dayOfWeek': date.weekday,
      });
    }
    
    return calendarData;
  }

  /// Get prediction insights with confidence levels
  Map<String, dynamic> get predictionInsights {
    final moodTrends = _analytics['mood_trends'] as List<dynamic>? ?? [];
    
    if (moodTrends.length < 7) {
      return {
        'hasEnoughData': false,
        'message': 'Necesitas al menos 7 días de datos para predicciones',
      };
    }
    
    // Simple trend analysis
    final recentMoods = moodTrends.take(7).map((m) => (m['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
    final avgRecent = recentMoods.reduce((a, b) => a + b) / recentMoods.length;
    
    final olderMoods = moodTrends.skip(7).take(7).map((m) => (m['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
    final avgOlder = olderMoods.isNotEmpty ? olderMoods.reduce((a, b) => a + b) / olderMoods.length : avgRecent;
    
    final trend = avgRecent - avgOlder;
    
    String trendDirection;
    String insight;
    String recommendation;
    double confidence;
    
    if (trend > 0.5) {
      trendDirection = 'improving';
      insight = 'Tu bienestar está mejorando consistentemente';
      recommendation = 'Mantén tus hábitos actuales, están funcionando';
      confidence = 0.8;
    } else if (trend < -0.5) {
      trendDirection = 'declining';
      insight = 'Tu bienestar ha mostrado algunos desafíos';
      recommendation = 'Considera incorporar más actividades de autocuidado';
      confidence = 0.7;
    } else {
      trendDirection = 'stable';
      insight = 'Tu bienestar se mantiene estable';
      recommendation = 'Explora nuevas actividades para impulsar tu crecimiento';
      confidence = 0.6;
    }
    
    return {
      'hasEnoughData': true,
      'trend': trendDirection,
      'insight': insight,
      'recommendation': recommendation,
      'confidence': confidence,
      'avgRecent': avgRecent,
      'avgOlder': avgOlder,
      'trendValue': trend,
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

  // ============================================================================
  // 🚀 ULTRA-SOPHISTICATED ANALYTICS METHODS
  // ============================================================================

  /// Comprehensive AI-Powered Analytics Dashboard
  Future<Map<String, dynamic>> getComprehensiveAIAnalytics(int userId) async {
    _logger.d('🤖 Generando dashboard de analytics AI completo');
    _setLoading(true);

    try {
      // Execute all advanced analytics in parallel
      final futures = await Future.wait([
        _databaseService.getAdvancedTimeSeriesAnalysis(userId),
        _databaseService.getMLInspiredPatternAnalysis(userId),
        _databaseService.getCausalInferenceAnalysis(userId),
        _databaseService.getUltraAdvancedPrediction(userId),
        _databaseService.getUserAnalytics(userId),
      ]);

      final comprehensiveAnalytics = {
        'time_series_analysis': futures[0],
        'ml_pattern_analysis': futures[1],
        'causal_inference': futures[2],
        'ultra_advanced_prediction': futures[3],
        'basic_analytics': futures[4],
        'generated_at': DateTime.now().toIso8601String(),
        'analysis_quality': _calculateAnalysisQuality(futures),
        'key_insights': _generateKeyInsights(futures),
        'actionable_recommendations': _generateActionableRecommendations(futures),
        'risk_alerts': _generateRiskAlerts(futures),
      };

      _analytics = comprehensiveAnalytics;
      _logger.i('✅ Dashboard de analytics AI completado');
      return comprehensiveAnalytics;

    } catch (e) {
      _logger.e('❌ Error en analytics AI completo: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Machine Learning-Inspired Pattern Recognition
  Future<Map<String, dynamic>> getMLPatternAnalysis(int userId) async {
    _logger.d('🧠 Iniciando análisis de patrones ML');
    _setLoading(true);

    try {
      final analysis = await _databaseService.getMLInspiredPatternAnalysis(userId);
      _logger.i('✅ Análisis de patrones ML completado');
      return analysis;
    } catch (e) {
      _logger.e('❌ Error en análisis de patrones ML: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Advanced Causal Inference Analysis
  Future<Map<String, dynamic>> getCausalInferenceAnalysis(int userId) async {
    _logger.d('🔗 Iniciando análisis de inferencia causal');
    _setLoading(true);

    try {
      final analysis = await _databaseService.getCausalInferenceAnalysis(userId);
      _logger.i('✅ Análisis de inferencia causal completado');
      return analysis;
    } catch (e) {
      _logger.e('❌ Error en análisis de inferencia causal: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Ultra-Advanced Prediction with Multiple Algorithms
  Future<Map<String, dynamic>> getUltraAdvancedPrediction(int userId, {int forecastDays = 7}) async {
    _logger.d('🔮 Iniciando predicción ultra-avanzada');
    _setLoading(true);

    try {
      final prediction = await _databaseService.getUltraAdvancedPrediction(userId);
      _logger.i('✅ Predicción ultra-avanzada completada');
      return prediction;
    } catch (e) {
      _logger.e('❌ Error en predicción ultra-avanzada: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Advanced Time Series Analysis with Machine Learning Insights
  Future<Map<String, dynamic>> getAdvancedTimeSeriesAnalysis(int userId, {int days = 90}) async {
    _logger.d('🔬 Iniciando análisis de series temporales avanzado');
    _setLoading(true);

    try {
      final analysis = await _databaseService.getAdvancedTimeSeriesAnalysis(userId);
      _logger.i('✅ Análisis de series temporales completado');
      return analysis;
    } catch (e) {
      _logger.e('❌ Error en análisis de series temporales: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Emotional Intelligence Score with Advanced Metrics
  Map<String, dynamic> getEmotionalIntelligenceScore() {
    final mlData = _analytics['ml_pattern_analysis'] as Map<String, dynamic>?;
    final causalData = _analytics['causal_inference'] as Map<String, dynamic>?;
    final timeSeriesData = _analytics['time_series_analysis'] as Map<String, dynamic>?;

    if (mlData == null && causalData == null && timeSeriesData == null) {
      return {'available': false, 'score': 0.0};
    }

    double emotionalStability = 0.5;
    double selfAwareness = 0.5;
    double adaptability = 0.5;
    double resilience = 0.5;

    // Calculate from volatility index
    if (timeSeriesData != null) {
      final volatility = timeSeriesData['volatility_index'] as double? ?? 0.5;
      emotionalStability = (1.0 - volatility).clamp(0.0, 1.0);
    }

    // Calculate from pattern confidence
    if (mlData != null) {
      final patternConfidence = mlData['pattern_confidence'] as double? ?? 0.5;
      selfAwareness = patternConfidence;
    }

    // Calculate from regulation effectiveness
    if (mlData != null) {
      final regulation = mlData['regulation_effectiveness'] as Map<String, dynamic>?;
      if (regulation != null) {
        adaptability = regulation['effectiveness_score'] as double? ?? 0.5;
      }
    }

    // Calculate from causal understanding
    if (causalData != null) {
      final causalStrength = causalData['causal_strength_overall'] as double? ?? 0.5;
      resilience = causalStrength;
    }

    final overallScore = (emotionalStability + selfAwareness + adaptability + resilience) / 4.0;

    return {
      'available': true,
      'overall_score': (overallScore * 100).round(),
      'components': {
        'emotional_stability': (emotionalStability * 100).round(),
        'self_awareness': (selfAwareness * 100).round(),
        'adaptability': (adaptability * 100).round(),
        'resilience': (resilience * 100).round(),
      },
      'level': _getEILevel(overallScore),
      'recommendations': _getEIRecommendations(emotionalStability, selfAwareness, adaptability, resilience),
    };
  }

  /// Advanced Mood Prediction with Confidence Intervals
  Map<String, dynamic> getAdvancedMoodPrediction() {
    final predictionData = _analytics['ultra_advanced_prediction'] as Map<String, dynamic>?;
    
    if (predictionData == null || predictionData.containsKey('error')) {
      return {
        'available': false,
        'error': 'Prediction data not available',
      };
    }

    final ensemble = predictionData['ensemble_prediction'] as Map<String, dynamic>?;
    if (ensemble == null) return {'available': false};

    final predictions = ensemble['predictions'] as List<dynamic>? ?? [];
    if (predictions.isEmpty) return {'available': false};

    return {
      'available': true,
      'predictions': predictions,
      'confidence': ensemble['ensemble_confidence'],
      'model_accuracy': predictionData['prediction_accuracy_score'],
      'risk_assessment': predictionData['risk_assessment'],
      'recommended_actions': predictionData['recommended_actions'],
      'prediction_range': predictions.map((p) => p['prediction_range']).toList(),
    };
  }


  // Helper methods for sophisticated analytics
  Map<String, dynamic> _calculateAnalysisQuality(List<Map<String, dynamic>> futures) {
    int validAnalyses = 0;
    int totalAnalyses = futures.length;
    double totalConfidence = 0.0;

    for (final analysis in futures) {
      if (analysis.isNotEmpty && !analysis.containsKey('error')) {
        validAnalyses++;
        // Try to extract confidence from each analysis
        final confidence = analysis['confidence'] as double? ?? 
                          analysis['pattern_confidence'] as double? ?? 
                          analysis['ensemble_confidence'] as double? ?? 
                          0.5;
        totalConfidence += confidence;
      }
    }

    final qualityScore = validAnalyses / totalAnalyses;
    final avgConfidence = validAnalyses > 0 ? totalConfidence / validAnalyses : 0.0;

    return {
      'overall_quality_score': (qualityScore * 100).round(),
      'confidence_level': (avgConfidence * 100).round(),
      'valid_analyses': validAnalyses,
      'total_analyses': totalAnalyses,
    };
  }

  List<Map<String, dynamic>> _generateKeyInsights(List<Map<String, dynamic>> futures) {
    final insights = <Map<String, dynamic>>[];

    try {
      // Extract insights from each analysis type
      for (int i = 0; i < futures.length; i++) {
        final analysis = futures[i];
        if (analysis.isEmpty || analysis.containsKey('error')) continue;

        switch (i) {
          case 0: // Time series
            if (analysis['trend_analysis'] != null) {
              insights.add({
                'type': 'trend',
                'insight': 'Tu tendencia de bienestar muestra ${analysis['trend_analysis']['overall_trend']}',
                'confidence': analysis['trend_analysis']['trend_confidence'] ?? 0.5,
              });
            }
            break;
          case 1: // ML patterns
            if (analysis['behavior_clusters'] != null) {
              final clusters = analysis['behavior_clusters']['num_clusters'] ?? 0;
              insights.add({
                'type': 'pattern',
                'insight': 'Se identificaron $clusters patrones de comportamiento distintos',
                'confidence': analysis['pattern_confidence'] ?? 0.5,
              });
            }
            break;
          case 2: // Causal analysis
            if (analysis['causal_relationships'] != null) {
              final relationships = analysis['causal_relationships'] as List? ?? [];
              if (relationships.isNotEmpty) {
                insights.add({
                  'type': 'causal',
                  'insight': 'Se detectaron ${relationships.length} relaciones causa-efecto importantes',
                  'confidence': analysis['causal_strength_overall'] ?? 0.5,
                });
              }
            }
            break;
          case 3: // Prediction
            if (analysis['ensemble_prediction'] != null) {
              final confidence = analysis['ensemble_prediction']['ensemble_confidence'] ?? 0.5;
              insights.add({
                'type': 'prediction',
                'insight': 'El modelo de predicción tiene ${(confidence * 100).toStringAsFixed(1)}% de confianza',
                'confidence': confidence,
              });
            }
            break;
        }
      }
    } catch (e) {
      _logger.w('Error generando insights: $e');
    }

    return insights;
  }

  List<String> _generateActionableRecommendations(List<Map<String, dynamic>> futures) {
    final recommendations = <String>[];

    try {
      // Extract recommendations from analyses
      for (final analysis in futures) {
        if (analysis.isEmpty || analysis.containsKey('error')) continue;

        final recs = analysis['recommendations'] as List<dynamic>? ?? 
                    analysis['recommended_actions'] as List<dynamic>? ?? [];
        
        for (final rec in recs.take(2)) {
          if (rec is String) {
            recommendations.add(rec);
          } else if (rec is Map && rec['action'] != null) {
            recommendations.add(rec['action'].toString());
          }
        }
      }
    } catch (e) {
      _logger.w('Error generando recomendaciones: $e');
    }

    return recommendations.take(5).toList();
  }

  List<Map<String, dynamic>> _generateRiskAlerts(List<Map<String, dynamic>> futures) {
    final alerts = <Map<String, dynamic>>[];

    try {
      for (final analysis in futures) {
        if (analysis.isEmpty || analysis.containsKey('error')) continue;

        // Check for risk indicators
        final riskAssessment = analysis['risk_assessment'] as Map<String, dynamic>?;
        if (riskAssessment != null) {
          final riskLevel = riskAssessment['risk_level'] as String? ?? 'low';
          if (riskLevel == 'high' || riskLevel == 'medium') {
            alerts.add({
              'level': riskLevel,
              'message': riskAssessment['description'] ?? 'Se detectó un área que requiere atención',
              'action': riskAssessment['recommended_action'] ?? 'Considera buscar apoyo profesional',
            });
          }
        }

        // Check for anomalies
        final anomalies = analysis['anomalies'] as List<dynamic>?;
        if (anomalies != null && anomalies.isNotEmpty) {
          alerts.add({
            'level': 'medium',
            'message': 'Se detectaron ${anomalies.length} anomalías en tus patrones',
            'action': 'Revisa qué factores pudieron haber influido en estos días',
          });
        }
      }
    } catch (e) {
      _logger.w('Error generando alertas: $e');
    }

    return alerts;
  }

  String _getEILevel(double score) {
    if (score >= 0.8) return 'Excepcional';
    if (score >= 0.7) return 'Alto';
    if (score >= 0.6) return 'Bueno';
    if (score >= 0.4) return 'Promedio';
    return 'En desarrollo';
  }

  List<String> _getEIRecommendations(double stability, double awareness, double adaptability, double resilience) {
    final recommendations = <String>[];
    
    if (stability < 0.6) recommendations.add('Practica técnicas de regulación emocional');
    if (awareness < 0.6) recommendations.add('Dedica tiempo a la autorreflexión diaria');
    if (adaptability < 0.6) recommendations.add('Experimenta con nuevas estrategias de afrontamiento');
    if (resilience < 0.6) recommendations.add('Fortalece tu red de apoyo social');
    
    if (recommendations.isEmpty) {
      recommendations.add('Mantén tu excelente inteligencia emocional');
    }
    
    return recommendations;
  }
  
  // ============================================================================
  // 🧠 INTELLIGENT ANALYTICS METHODS
  // ============================================================================
  
  /// ✅ NEW: Generate enhanced summary with intelligent insights
  Map<String, dynamic> _generateEnhancedSummary() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final intelligentInsights = _analytics['intelligent_insights'] as Map<String, dynamic>?;
    _analytics['emotional_patterns'] as Map<String, dynamic>?; // Access for side effects
    
    if (basicStats == null) return {};
    
    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;
    final avgEnergy = (basicStats['avg_energy'] as num?)?.toDouble() ?? 5.0;
    final avgStress = (basicStats['avg_stress'] as num?)?.toDouble() ?? 5.0;
    
    String overallTrend = 'stable';
    String primaryFocus = 'balance';
    
    // Analyze intelligent insights if available
    if (intelligentInsights != null) {
      final moodVolatility = intelligentInsights['mood_volatility'] as Map<String, dynamic>?;
      final stressPatterns = intelligentInsights['stress_patterns'] as Map<String, dynamic>?;
      
      if (moodVolatility != null) {
        final stabilityScore = (moodVolatility['stability_score'] as num?)?.toDouble() ?? 0.5;
        if (stabilityScore < 0.4) {
          overallTrend = 'volatile';
          primaryFocus = 'emotional_stability';
        } else if (stabilityScore > 0.8) {
          overallTrend = 'very_stable';
        }
      }
      
      if (stressPatterns != null) {
        final alertLevel = stressPatterns['alert_level'] as String?;
        if (alertLevel == 'high') {
          primaryFocus = 'stress_management';
        }
      }
    }
    
    return {
      'overall_wellbeing_score': ((avgMood + avgEnergy + (10 - avgStress)) / 3).clamp(1.0, 10.0),
      'primary_strength': _identifyPrimaryStrength(avgMood, avgEnergy, avgStress),
      'primary_opportunity': _identifyPrimaryOpportunity(avgMood, avgEnergy, avgStress),
      'overall_trend': overallTrend,
      'primary_focus': primaryFocus,
      'confidence_level': _calculateConfidenceLevel(),
    };
  }
  
  /// ✅ NEW: Generate personalized tips based on user data
  List<Map<String, dynamic>> _generatePersonalizedTips() {
    final tips = <Map<String, dynamic>>[];
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    _analytics['habits_analysis'] as Map<String, dynamic>?; // Access for side effects
    final personalizedRecommendations = _analytics['personalized_recommendations'] as List?;
    
    if (basicStats == null) return tips;
    
    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;
    final avgEnergy = (basicStats['avg_energy'] as num?)?.toDouble() ?? 5.0;
    final avgStress = (basicStats['avg_stress'] as num?)?.toDouble() ?? 5.0;
    
    // Mood-based tips
    if (avgMood < 6.0) {
      tips.add({
        'category': 'mood_boost',
        'icon': '🌅',
        'title': 'Mejora tu Estado de Ánimo',
        'description': 'Prueba actividades que te hagan sonreír',
        'actions': [
          'Escucha tu música favorita por 15 minutos',
          'Llama a un amigo que te haga reír',
          'Sal a caminar al aire libre'
        ],
        'priority': 'high',
        'estimated_impact': 'medium',
      });
    }
    
    // Energy-based tips
    if (avgEnergy < 6.0) {
      tips.add({
        'category': 'energy_boost',
        'icon': '⚡',
        'title': 'Aumenta tu Energía',
        'description': 'Pequeños cambios para más vitalidad',
        'actions': [
          'Toma un vaso de agua al despertar',
          'Haz 5 minutos de ejercicio ligero',
          'Revisa tu horario de sueño'
        ],
        'priority': 'medium',
        'estimated_impact': 'high',
      });
    }
    
    // Stress-based tips
    if (avgStress > 6.0) {
      tips.add({
        'category': 'stress_relief',
        'icon': '🧘‍♀️',
        'title': 'Manejo del Estrés',
        'description': 'Técnicas para reducir la tensión',
        'actions': [
          'Practica respiración profunda 4-7-8',
          'Dedica 10 minutos a una actividad relajante',
          'Organiza tu espacio personal'
        ],
        'priority': 'high',
        'estimated_impact': 'high',
      });
    }
    
    // Include database-generated recommendations if available
    if (personalizedRecommendations != null) {
      for (final rec in personalizedRecommendations) {
        if (rec is Map<String, dynamic>) {
          tips.add({
            'category': rec['type'] ?? 'general',
            'icon': _getIconForRecommendationType(rec['type'] as String?),
            'title': rec['title'] ?? 'Recomendación Personalizada',
            'description': rec['description'] ?? '',
            'actions': rec['actions'] ?? [],
            'priority': rec['priority'] ?? 'medium',
            'estimated_impact': rec['estimated_impact'] ?? 'medium',
          });
        }
      }
    }
    
    return tips.take(4).toList(); // Limit to 4 most relevant tips
  }
  
  /// ✅ NEW: Generate wellness forecast based on trends
  Map<String, dynamic> _generateWellnessForecast() {
    final wellbeingPrediction = _analytics['wellbeing_prediction'] as Map<String, dynamic>?;
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    
    if (wellbeingPrediction == null || basicStats == null) {
      return {
        'forecast_available': false,
        'message': 'Necesitas más datos para generar un pronóstico',
      };
    }
    
    final trendDirection = (wellbeingPrediction['trend_direction'] as num?)?.toDouble() ?? 0.0;
    final confidence = (wellbeingPrediction['confidence'] as num?)?.toDouble() ?? 0.0;
    final predictedScore = (wellbeingPrediction['predicted_score'] as num?)?.toDouble() ?? 5.0;
    
    String forecastMessage;
    String recommendation;
    String timeframe;
    
    if (trendDirection > 0.1) {
      forecastMessage = 'Tu bienestar está en tendencia ascendente';
      recommendation = 'Mantén tus hábitos actuales y considera añadir nuevos desafíos positivos';
      timeframe = 'próximos 7-14 días';
    } else if (trendDirection < -0.1) {
      forecastMessage = 'Tu bienestar muestra una tendencia descendente';
      recommendation = 'Es un buen momento para implementar estrategias de autocuidado';
      timeframe = 'próximos 5-10 días';
    } else {
      forecastMessage = 'Tu bienestar se mantiene estable';
      recommendation = 'Explora nuevas actividades para potenciar tu crecimiento personal';
      timeframe = 'próximas 2 semanas';
    }
    
    return {
      'forecast_available': true,
      'trend_direction': trendDirection > 0.1 ? 'improving' : trendDirection < -0.1 ? 'declining' : 'stable',
      'confidence_level': confidence > 0.7 ? 'high' : confidence > 0.4 ? 'medium' : 'low',
      'predicted_score': predictedScore,
      'forecast_message': forecastMessage,
      'recommendation': recommendation,
      'timeframe': timeframe,
      'confidence_percentage': (confidence * 100).round(),
    };
  }
  
  /// Helper: Identify primary strength
  String _identifyPrimaryStrength(double mood, double energy, double stress) {
    final scores = {
      'mood': mood,
      'energy': energy,
      'stress_management': 10 - stress,
    };
    
    final highest = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    switch (highest.key) {
      case 'mood':
        return 'estado_de_animo';
      case 'energy':
        return 'energia';
      case 'stress_management':
        return 'manejo_del_estres';
      default:
        return 'equilibrio_general';
    }
  }
  
  /// Helper: Identify primary opportunity
  String _identifyPrimaryOpportunity(double mood, double energy, double stress) {
    final scores = {
      'mood': mood,
      'energy': energy,
      'stress_management': 10 - stress,
    };
    
    final lowest = scores.entries.reduce((a, b) => a.value < b.value ? a : b);
    
    switch (lowest.key) {
      case 'mood':
        return 'mejorar_estado_de_animo';
      case 'energy':
        return 'aumentar_energia';
      case 'stress_management':
        return 'reducir_estres';
      default:
        return 'mantener_equilibrio';
    }
  }
  
  /// Helper: Calculate confidence level based on data quality
  double _calculateConfidenceLevel() {
    final metadata = _analytics['metadata'] as Map<String, dynamic>?;
    final dataQualityScore = (metadata?['data_quality_score'] as num?)?.toDouble() ?? 0.5;
    
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final totalEntries = (basicStats?['total_entries'] as num?)?.toInt() ?? 0;
    
    // Base confidence on data quality and quantity
    final quantityFactor = math.min(totalEntries / 20.0, 1.0); // Max confidence at 20+ entries
    return (dataQualityScore * quantityFactor).clamp(0.0, 1.0);
  }
  
  /// Helper: Get icon for recommendation type
  String _getIconForRecommendationType(String? type) {
    switch (type) {
      case 'mood_support':
        return '💚';
      case 'stress_management':
        return '🧘‍♀️';
      case 'energy_boost':
        return '⚡';
      case 'sleep_improvement':
        return '😴';
      case 'exercise':
        return '🏃‍♀️';
      case 'social':
        return '👥';
      default:
        return '💡';
    }
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

  List<String> get dailyGoalsSummary {
    final summary = <String>[];
    final today = DateTime.now();

    for (final goal in _goals) {
      // Check if the goal is active and has progress
      if (goal.isActive && goal.currentValue > 0) {
        summary.add(
            '${goal.title}: ${goal.progressPercentage.toStringAsFixed(0)}% completado');
      } else if (goal.isCompleted && goal.completedAt != null &&
          goal.completedAt!.year == today.year &&
          goal.completedAt!.month == today.month &&
          goal.completedAt!.day == today.day) {
        summary.add('${goal.title}: ¡Completado hoy!');
      }
    }
    return summary;
  }

  double get averageProgress {
    if (activeGoals.isEmpty) return 0.0;
    final totalProgress = activeGoals.fold<double>(
      0.0,
          (sum, goal) => sum + goal.progress,
    );
    return totalProgress / activeGoals.length;
  }

  int get totalGoalsCount => _goals.length;

  Map<GoalCategory, int> get goalsByType {
    final Map<GoalCategory, int> result = {};
    for (final goal in _goals) {
      result[goal.category] = (result[goal.category] ?? 0) + 1;
    }
    return result;
  }

  /// Cargar objetivos del usuario
  // lib/presentation/providers/optimized_providers.dart

  /// Cargar objetivos del usuario
  Future<void> loadUserGoals(int userId) async {
    _logger.d('🎯 Cargando objetivos para usuario: $userId');
    _setLoading(true);
    _clearError();

    try {
      // CORRECTED LINE:
      // Simply await the result, as getUserGoals already returns the correct type.
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
      final goalCategory = _parseGoalCategory(type);

      final goal = GoalModel(
        userId: userId,
        title: title,
        description: description,
        category: goalCategory,
        targetValue: targetValue.toInt(),
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
        category: type != null ? _parseGoalCategory(type) : GoalCategory.emotional,
        targetValue: targetValue?.toInt(),
        currentValue: currentValue?.toInt(),
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
      final updatedGoal = goal.copyWith(currentValue: newValue.toInt());

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

        switch (goal.category) {
          case GoalCategory.mindfulness:
            newProgress = await _calculateConsistencyProgress(userId, goal);
            break;
          case GoalCategory.emotional:
            newProgress = await _calculateMoodProgress(userId, goal);
            break;
          case GoalCategory.social:
            newProgress = await _calculatePositiveMomentsProgress(userId, goal);
            break;
          case GoalCategory.stress:
            newProgress = await _calculateStressReductionProgress(userId, goal);
            break;
          default:
            newProgress = await _calculateConsistencyProgress(userId, goal);
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
      return goal.currentValue.toDouble();
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
      return goal.currentValue.toDouble();
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
      return goal.currentValue.toDouble();
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
      return goal.currentValue.toDouble();
    }
  }

  /// Obtener objetivos por tipo específico
  List<GoalModel> getGoalsByCategory(GoalCategory category) {
    return _goals.where((goal) => goal.category == category).toList();
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
  GoalCategory _parseGoalCategory(String type) {
    switch (type.toLowerCase()) {
      case 'consistency':
      case 'mindfulness':
        return GoalCategory.mindfulness;
      case 'mood':
      case 'emotional':
        return GoalCategory.emotional;
      case 'positivemoments':
      case 'social':
        return GoalCategory.social;
      case 'stressreduction':
      case 'stress':
        return GoalCategory.stress;
      case 'sleep':
        return GoalCategory.sleep;
      case 'physical':
        return GoalCategory.physical;
      case 'productivity':
        return GoalCategory.productivity;
      case 'habits':
        return GoalCategory.habits;
      default:
        return GoalCategory.emotional;
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
  Future<List<GoalModel>> getGoalsByCategory(int userId, GoalCategory category) async {
    try {
      final db = await database;
      final results = await db.query(
        'user_goals',
        where: 'user_id = ? AND type = ?',
        whereArgs: [userId, category.name],
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

