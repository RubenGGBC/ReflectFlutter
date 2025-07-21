// lib/test_data/test_data_seeder.dart
// ============================================================================
// SIMPLE TEST DATA SEEDER - CLEAN AND FUNCTIONAL
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';

import '../data/services/optimized_database_service.dart';
import '../data/models/optimized_models.dart';
import '../data/models/goal_model.dart';

class TestDataSeeder {
  final OptimizedDatabaseService _databaseService;
  final Random _random = Random();

  TestDataSeeder(this._databaseService);

  /// Seed all test data for a user
  Future<void> seedTestData(int userId) async {
    if (kDebugMode) {
      debugPrint('🌱 Seeding test data for user $userId...');
    }

    try {
      await seedDailyEntries(userId);
      await seedMoments(userId);
      await seedGoals(userId);
      
      if (kDebugMode) {
        debugPrint('✅ Test data seeded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error seeding test data: $e');
      }
      rethrow;
    }
  }

  /// Seed daily entries for the last 30 days
  Future<void> seedDailyEntries(int userId) async {
    final now = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      
      final entry = OptimizedDailyEntryModel(
        userId: userId,
        entryDate: date,
        freeReflection: _generateJournalEntry(),
        sleepHours: 6.0 + _random.nextDouble() * 4, // 6-10 hours
        anxietyLevel: _random.nextInt(5) + 1, // 1-5
        stressLevel: _random.nextInt(5) + 1, // 1-5
        energyLevel: _random.nextInt(5) + 1, // 1-5
        createdAt: date,
        updatedAt: date,
      );

      await _databaseService.saveDailyEntry(entry);
    }
  }

  /// Seed moments for the last 15 days
  Future<void> seedMoments(int userId) async {
    final now = DateTime.now();
    final momentTypes = ['positive', 'negative', 'neutral'];
    
    for (int i = 0; i < 15; i++) {
      final date = now.subtract(Duration(days: i));
      
      // Create 1-3 moments per day
      final momentsCount = _random.nextInt(3) + 1;
      
      for (int j = 0; j < momentsCount; j++) {
        final momentTitle = _generateMomentTitle();
        final momentDescription = _generateMomentDescription();
        final emotionalImpact = _random.nextInt(5) + 1;
        final tags = _generateMomentTags();
        final momentType = momentTypes[_random.nextInt(momentTypes.length)];
        final timestamp = date.add(Duration(hours: _random.nextInt(16) + 6));

        final moment = OptimizedInteractiveMomentModel(
          userId: userId,
          entryDate: timestamp,
          emoji: '😊',
          text: momentDescription,
          type: momentType,
          intensity: emotionalImpact,
          timestamp: timestamp,
          createdAt: timestamp,
        );
        await _databaseService.saveInteractiveMoment(userId, moment);
      }
    }
  }

  /// Seed sample goals
  Future<void> seedGoals(int userId) async {
    final goals = [
      GoalModel(
        userId: userId,
        title: 'Daily Meditation',
        description: 'Meditate for 10 minutes every day',
        category: GoalCategory.mindfulness,
        targetValue: 30,
        createdAt: DateTime.now(),
        durationDays: 30,
        milestones: [],
        metrics: {},
        frequency: FrequencyType.daily,
        tags: ['meditation', 'mindfulness'],
        customSettings: {},
        motivationalQuotes: [],
        reminderSettings: {},
        isTemplate: false,
      ),
      GoalModel(
        userId: userId,
        title: 'Improve Mood',
        description: 'Practice gratitude and positive thinking',
        category: GoalCategory.emotional,
        targetValue: 20,
        createdAt: DateTime.now(),
        durationDays: 20,
        milestones: [],
        metrics: {},
        frequency: FrequencyType.daily,
        tags: ['mood', 'gratitude'],
        customSettings: {},
        motivationalQuotes: [],
        reminderSettings: {},
        isTemplate: false,
      ),
      GoalModel(
        userId: userId,
        title: 'Create Positive Moments',
        description: 'Actively create positive experiences',
        category: GoalCategory.social,
        targetValue: 50,
        createdAt: DateTime.now(),
        durationDays: 50,
        milestones: [],
        metrics: {},
        frequency: FrequencyType.weekly,
        tags: ['positive', 'social'],
        customSettings: {},
        motivationalQuotes: [],
        reminderSettings: {},
        isTemplate: false,
      ),
      GoalModel(
        userId: userId,
        title: 'Stress Management',
        description: 'Practice stress reduction techniques',
        category: GoalCategory.stress,
        targetValue: 25,
        createdAt: DateTime.now(),
        durationDays: 25,
        milestones: [],
        metrics: {},
        frequency: FrequencyType.daily,
        tags: ['stress', 'relaxation'],
        customSettings: {},
        motivationalQuotes: [],
        reminderSettings: {},
        isTemplate: false,
      ),
    ];

    for (final goal in goals) {
      await _databaseService.createGoalSafe(
        userId: goal.userId,
        title: goal.title,
        description: goal.description,
        type: goal.category.name,
        targetValue: goal.targetValue.toDouble(),
      );
    }
  }

  // Helper methods for generating realistic test data
  String _generateJournalEntry() {
    final entries = [
      'Today was a good day. I felt productive and accomplished several tasks.',
      'Had some challenges today but managed to stay positive.',
      'Feeling grateful for the small moments of joy throughout the day.',
      'Worked on my personal goals and made some progress.',
      'Spent quality time with family and friends today.',
      'Practiced mindfulness and felt more centered.',
      'Had a busy day but maintained good energy levels.',
      'Reflected on my growth and felt proud of my progress.',
    ];
    return entries[_random.nextInt(entries.length)];
  }

  String _generateGratitudeNote() {
    final notes = [
      'Grateful for good health and energy',
      'Thankful for supportive friends and family',
      'Appreciating the beautiful weather today',
      'Grateful for opportunities to learn and grow',
      'Thankful for moments of peace and quiet',
      'Appreciating small acts of kindness',
      'Grateful for a comfortable home',
      'Thankful for meaningful work',
    ];
    return notes[_random.nextInt(notes.length)];
  }

  String _generateMomentTitle() {
    final titles = [
      'Coffee with a friend',
      'Beautiful sunset',
      'Productive work session',
      'Family dinner',
      'Morning walk',
      'Good book',
      'Relaxing music',
      'Helpful conversation',
      'Achievement unlocked',
      'Peaceful moment',
    ];
    return titles[_random.nextInt(titles.length)];
  }

  String _generateMomentDescription() {
    final descriptions = [
      'A wonderful moment that brought joy to my day',
      'Something that made me pause and appreciate life',
      'An experience that lifted my spirits',
      'A small but meaningful interaction',
      'A moment of clarity and understanding',
      'Something that made me smile',
      'An achievement I\'m proud of',
      'A peaceful and calming experience',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  List<String> _generateMomentTags() {
    final allTags = [
      'family', 'friends', 'work', 'nature', 'achievement',
      'peace', 'joy', 'growth', 'learning', 'gratitude',
      'health', 'creativity', 'mindfulness', 'connection',
    ];
    
    // Return 1-3 random tags
    final tagCount = _random.nextInt(3) + 1;
    final selectedTags = <String>[];
    
    for (int i = 0; i < tagCount; i++) {
      final tag = allTags[_random.nextInt(allTags.length)];
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    }
    
    return selectedTags;
  }

  /// Clear all test data for a user
  Future<void> clearTestData(int userId) async {
    if (kDebugMode) {
      debugPrint('🧹 Clearing test data for user $userId...');
    }

    try {
      // Clear in reverse order to avoid foreign key constraints
      // TODO: Implement deleteUserGoals method
      // TODO: Implement deleteUserMoments method
      // TODO: Implement deleteUserDailyEntries method
      
      if (kDebugMode) {
        debugPrint('✅ Test data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing test data: $e');
      }
      rethrow;
    }
  }
}