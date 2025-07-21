// ============================================================================
// challenges_provider.dart - PROVIDER FOR PERSONALIZED CHALLENGES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/services/optimized_database_service.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final double progress;
  final int target;
  final int current;
  final String reward;
  final String emoji;
  final bool isCompleted;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.progress,
    required this.target,
    required this.current,
    required this.reward,
    required this.emoji,
    this.isCompleted = false,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    final progress = ((map['current'] as num? ?? 0) / (map['target'] as num? ?? 1)).clamp(0.0, 1.0);
    return Challenge(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      progress: progress,
      target: map['target'] as int? ?? 1,
      current: map['current'] as int? ?? 0,
      reward: map['reward'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '🎯',
      isCompleted: progress >= 1.0,
    );
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    double? progress,
    int? target,
    int? current,
    String? reward,
    String? emoji,
    bool? isCompleted,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      current: current ?? this.current,
      reward: reward ?? this.reward,
      emoji: emoji ?? this.emoji,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ChallengesProvider extends ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  List<Challenge> _challenges = [];
  bool _isLoading = false;
  String? _errorMessage;

  ChallengesProvider(this._databaseService);

  // Getters
  List<Challenge> get challenges => List.unmodifiable(_challenges);
  List<Challenge> get activeChallenges => _challenges.where((c) => !c.isCompleted).toList();
  List<Challenge> get completedChallenges => _challenges.where((c) => c.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Analytics getters
  int get totalChallenges => _challenges.length;
  int get completedCount => completedChallenges.length;
  double get overallProgress {
    if (_challenges.isEmpty) return 0.0;
    return _challenges.map((c) => c.progress).reduce((a, b) => a + b) / _challenges.length;
  }

  /// Load personalized challenges for user
  Future<void> loadChallenges(int userId) async {
    _logger.i('🎯 Loading personalized challenges for user: $userId');
    _setLoading(true);
    _clearError();

    try {
      final challengeData = <Map<String, dynamic>>[]; // TODO: Implement personalized challenges
      
      _challenges = challengeData.map((data) {
        // Add emoji based on challenge type
        String emoji = '🎯';
        switch (data['type'] as String? ?? '') {
          case 'streak':
            emoji = '🔥';
            break;
          case 'meditation':
            emoji = '🧘‍♀️';
            break;
          case 'exercise':
            emoji = '💪';
            break;
          case 'wellbeing':
            emoji = '🌟';
            break;
          case 'social':
            emoji = '🤝';
            break;
          case 'mood':
            emoji = '😊';
            break;
        }
        
        return Challenge.fromMap({
          ...data,
          'emoji': emoji,
        });
      }).toList();

      _logger.i('✅ Loaded ${_challenges.length} challenges (${completedCount} completed)');
    } catch (e) {
      _logger.e('❌ Error loading challenges: $e');
      _setError('Error cargando desafíos');
    } finally {
      _setLoading(false);
    }
  }

  /// Mark challenge as completed
  Future<void> completeChallenge(String challengeId) async {
    try {
      final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        _challenges[challengeIndex] = _challenges[challengeIndex].copyWith(
          progress: 1.0,
          isCompleted: true,
        );
        notifyListeners();
        _logger.i('✅ Challenge completed: $challengeId');
      }
    } catch (e) {
      _logger.e('❌ Error completing challenge: $e');
    }
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress(String challengeId, int newCurrent) async {
    try {
      final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        final challenge = _challenges[challengeIndex];
        final newProgress = (newCurrent / challenge.target).clamp(0.0, 1.0);
        
        _challenges[challengeIndex] = challenge.copyWith(
          current: newCurrent,
          progress: newProgress,
          isCompleted: newProgress >= 1.0,
        );
        
        notifyListeners();
        _logger.i('📈 Challenge progress updated: $challengeId ($newCurrent/${challenge.target})');
      }
    } catch (e) {
      _logger.e('❌ Error updating challenge progress: $e');
    }
  }

  /// Get challenges by type
  List<Challenge> getChallengesByType(String type) {
    return _challenges.where((c) => c.type == type).toList();
  }

  /// Get next challenge to focus on
  Challenge? get nextChallenge {
    final active = activeChallenges;
    if (active.isEmpty) return null;
    
    // Return the challenge with highest progress (closest to completion)
    active.sort((a, b) => b.progress.compareTo(a.progress));
    return active.first;
  }

  /// Get challenge statistics
  Map<String, dynamic> getChallengeStats() {
    final byType = <String, List<Challenge>>{};
    for (final challenge in _challenges) {
      byType.putIfAbsent(challenge.type, () => []).add(challenge);
    }

    return {
      'total_challenges': totalChallenges,
      'completed_challenges': completedCount,
      'overall_progress': overallProgress,
      'by_type': byType.map((type, challenges) => MapEntry(type, {
        'total': challenges.length,
        'completed': challenges.where((c) => c.isCompleted).length,
        'progress': challenges.isEmpty ? 0.0 : 
          challenges.map((c) => c.progress).reduce((a, b) => a + b) / challenges.length,
      })),
      'next_challenge': nextChallenge?.id,
    };
  }

  /// Refresh challenges data
  Future<void> refresh(int userId) async {
    await loadChallenges(userId);
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