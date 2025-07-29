// ============================================================================
// streak_provider.dart - PROVIDER FOR STREAK TRACKING AND MILESTONES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/services/optimized_database_service.dart';

class StreakMilestone {
  final int days;
  final String title;
  final String emoji;
  final String description;
  final bool isAchieved;

  const StreakMilestone({
    required this.days,
    required this.title,
    required this.emoji,
    required this.description,
    required this.isAchieved,
  });
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final List<StreakMilestone> milestones;
  final StreakMilestone? nextMilestone;
  final double progressToNext;
  final bool isActive;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.milestones,
    this.nextMilestone,
    required this.progressToNext,
    required this.isActive,
  });
}

class StreakProvider extends ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  StreakData? _streakData;
  bool _isLoading = false;
  String? _errorMessage;

  // Predefined milestones
  static const List<Map<String, dynamic>> _milestoneDefinitions = [
    {
      'days': 3,
      'title': 'Primer Paso',
      'emoji': '🌱',
      'description': '¡Comenzaste tu viaje de bienestar!',
    },
    {
      'days': 7,
      'title': 'Una Semana',
      'emoji': '🔥',
      'description': '¡Una semana completa de constancia!',
    },
    {
      'days': 14,
      'title': 'Dos Semanas',
      'emoji': '⚡',
      'description': '¡Tu disciplina está creciendo!',
    },
    {
      'days': 30,
      'title': 'Un Mes',
      'emoji': '💎',
      'description': '¡Un mes de dedicación excepcional!',
    },
    {
      'days': 60,
      'title': 'Dos Meses',
      'emoji': '🌟',
      'description': '¡Tu constancia es inspiradora!',
    },
    {
      'days': 100,
      'title': 'Centenario',
      'emoji': '👑',
      'description': '¡Eres un maestro de la consistencia!',
    },
    {
      'days': 365,
      'title': 'Un Año Completo',
      'emoji': '🏆',
      'description': '¡Logro legendario alcanzado!',
    },
  ];

  StreakProvider(this._databaseService);

  // Getters
  StreakData? get streakData => _streakData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int get currentStreak => _streakData?.currentStreak ?? 0;
  int get longestStreak => _streakData?.longestStreak ?? 0;
  bool get isActiveStreak => _streakData?.isActive ?? false;
  StreakMilestone? get nextMilestone => _streakData?.nextMilestone;
  double get progressToNext => _streakData?.progressToNext ?? 0.0;

  /// Load streak data for user
  Future<void> loadStreakData(int userId) async {
    _logger.i('🔥 Loading streak data for user: $userId');
    _setLoading(true);
    _clearError();

    try {
      // Get streak data from database service
      final rawStreakData = await _databaseService.getUserAnalytics(userId);
      final streakData = rawStreakData['streak_data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      
      final currentStreak = streakData['current_streak'] as int? ?? 0;
      final longestStreak = streakData['longest_streak'] as int? ?? 0;

      // Generate milestones based on current progress
      final milestones = _generateMilestones(currentStreak, longestStreak);
      
      // Find next milestone
      final nextMilestone = _findNextMilestone(currentStreak);
      
      // Calculate progress to next milestone
      double progressToNext = 0.0;
      if (nextMilestone != null) {
        final previousMilestone = _findPreviousMilestone(currentStreak);
        final previousDays = previousMilestone?.days ?? 0;
        final range = nextMilestone.days - previousDays;
        final progress = currentStreak - previousDays;
        progressToNext = range > 0 ? (progress / range).clamp(0.0, 1.0) : 0.0;
      }

      _streakData = StreakData(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        milestones: milestones,
        nextMilestone: nextMilestone,
        progressToNext: progressToNext,
        isActive: currentStreak > 0,
      );

      _logger.i('✅ Loaded streak data: current=$currentStreak, longest=$longestStreak');
    } catch (e) {
      _logger.e('❌ Error loading streak data: $e');
      _setError('Error cargando datos de racha');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate milestone list with achievement status
  List<StreakMilestone> _generateMilestones(int currentStreak, int longestStreak) {
    return _milestoneDefinitions.map((def) {
      final days = def['days'] as int;
      final isAchieved = longestStreak >= days;
      
      return StreakMilestone(
        days: days,
        title: def['title'] as String,
        emoji: def['emoji'] as String,
        description: def['description'] as String,
        isAchieved: isAchieved,
      );
    }).toList();
  }

  /// Find the next milestone to achieve
  StreakMilestone? _findNextMilestone(int currentStreak) {
    for (final def in _milestoneDefinitions) {
      final days = def['days'] as int;
      if (currentStreak < days) {
        return StreakMilestone(
          days: days,
          title: def['title'] as String,
          emoji: def['emoji'] as String,
          description: def['description'] as String,
          isAchieved: false,
        );
      }
    }
    return null; // All milestones achieved
  }

  /// Find the previous milestone (for progress calculation)
  StreakMilestone? _findPreviousMilestone(int currentStreak) {
    StreakMilestone? previous;
    for (final def in _milestoneDefinitions) {
      final days = def['days'] as int;
      if (currentStreak >= days) {
        previous = StreakMilestone(
          days: days,
          title: def['title'] as String,
          emoji: def['emoji'] as String,
          description: def['description'] as String,
          isAchieved: true,
        );
      } else {
        break;
      }
    }
    return previous;
  }

  /// Get achieved milestones
  List<StreakMilestone> get achievedMilestones {
    return _streakData?.milestones.where((m) => m.isAchieved).toList() ?? [];
  }

  /// Get upcoming milestones
  List<StreakMilestone> get upcomingMilestones {
    return _streakData?.milestones.where((m) => !m.isAchieved).toList() ?? [];
  }

  /// Get streak level based on current streak
  String get streakLevel {
    final current = currentStreak;
    if (current >= 365) return 'Legendario';
    if (current >= 100) return 'Maestro';
    if (current >= 60) return 'Experto';
    if (current >= 30) return 'Avanzado';
    if (current >= 14) return 'Intermedio';
    if (current >= 7) return 'Principiante';
    if (current >= 3) return 'Novato';
    return 'Comenzando';
  }

  /// Get flame intensity for animation (0.0 to 1.0)
  double get flameIntensity {
    final current = currentStreak;
    if (current == 0) return 0.0;
    if (current >= 100) return 1.0;
    if (current >= 30) return 0.8;
    if (current >= 14) return 0.6;
    if (current >= 7) return 0.4;
    return 0.2;
  }

  /// Get streak statistics
  Map<String, dynamic> getStreakStats() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'is_active': isActiveStreak,
      'level': streakLevel,
      'flame_intensity': flameIntensity,
      'achieved_milestones': achievedMilestones.length,
      'total_milestones': _milestoneDefinitions.length,
      'next_milestone_days': nextMilestone?.days,
      'days_to_next': nextMilestone != null ? nextMilestone!.days - currentStreak : 0,
      'progress_to_next': progressToNext,
    };
  }

  /// Simulate streak increment (for testing/demo)
  void incrementStreak() {
    if (_streakData != null) {
      final newStreak = _streakData!.currentStreak + 1;
      final newLongest = newStreak > _streakData!.longestStreak ? newStreak : _streakData!.longestStreak;
      
      // Regenerate milestones
      final milestones = _generateMilestones(newStreak, newLongest);
      final nextMilestone = _findNextMilestone(newStreak);
      
      double progressToNext = 0.0;
      if (nextMilestone != null) {
        final previousMilestone = _findPreviousMilestone(newStreak);
        final previousDays = previousMilestone?.days ?? 0;
        final range = nextMilestone.days - previousDays;
        final progress = newStreak - previousDays;
        progressToNext = range > 0 ? (progress / range).clamp(0.0, 1.0) : 0.0;
      }

      _streakData = StreakData(
        currentStreak: newStreak,
        longestStreak: newLongest,
        milestones: milestones,
        nextMilestone: nextMilestone,
        progressToNext: progressToNext,
        isActive: true,
      );
      
      notifyListeners();
      _logger.i('🔥 Streak incremented to: $newStreak');
    }
  }

  /// Refresh streak data
  Future<void> refresh(int userId) async {
    await loadStreakData(userId);
  }

  // Private methods
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