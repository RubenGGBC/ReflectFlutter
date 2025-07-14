// lib/test_data/simple_test_data.dart
// ============================================================================
// SIMPLE TEST DATA SYSTEM - MINIMAL AND FUNCTIONAL
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';

/// Simple test data generator that doesn't depend on complex database methods
class SimpleTestData {
  static final Random _random = Random();

  /// Generate sample goal data for testing UI
  static List<Map<String, dynamic>> generateSampleGoals() {
    return [
      {
        'id': 1,
        'title': 'Daily Meditation',
        'description': 'Practice mindfulness meditation for 10 minutes every day',
        'type': 'consistency',
        'targetValue': 30,
        'currentValue': 22,
        'progressNotes': '2024-01-15: Feeling more centered each day\n2024-01-10: Building the habit',
        'status': 'active',
        'progress': 0.73,
      },
      {
        'id': 2,
        'title': 'Practice Gratitude',
        'description': 'Write down 3 things I\'m grateful for',
        'type': 'mood',
        'targetValue': 25,
        'currentValue': 18,
        'progressNotes': '2024-01-12: Noticing more positive things',
        'status': 'active',
        'progress': 0.72,
      },
      {
        'id': 3,
        'title': 'Read Before Bed',
        'description': 'Read for 20 minutes before going to sleep',
        'type': 'consistency',
        'targetValue': 14,
        'currentValue': 14,
        'progressNotes': '2024-01-13: Completed! Sleep quality improved',
        'status': 'completed',
        'progress': 1.0,
      },
      {
        'id': 4,
        'title': 'Connect with Friends',
        'description': 'Reach out to friends and family regularly',
        'type': 'positiveMoments',
        'targetValue': 15,
        'currentValue': 12,
        'progressNotes': '2024-01-11: Had great conversations this week',
        'status': 'active',
        'progress': 0.8,
      },
      {
        'id': 5,
        'title': 'Deep Breathing',
        'description': 'Practice deep breathing exercises when stressed',
        'type': 'stressReduction',
        'targetValue': 30,
        'currentValue': 8,
        'progressNotes': '2024-01-09: Starting to help with anxiety',
        'status': 'active',
        'progress': 0.27,
      },
    ];
  }

  /// Generate sample daily entries for analytics testing
  static List<Map<String, dynamic>> generateSampleDailyEntries({int days = 30}) {
    final entries = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      
      entries.add({
        'id': i + 1,
        'date': date.toIso8601String(),
        'moodRating': isWeekend ? _random.nextInt(3) + 3 : _random.nextInt(4) + 2, // 2-5, higher on weekends
        'sleepHours': isWeekend ? 7.5 + _random.nextDouble() * 1.5 : 6.5 + _random.nextDouble() * 1.5,
        'anxietyLevel': _random.nextInt(4) + 1, // 1-4
        'stressLevel': isWeekend ? _random.nextInt(3) + 1 : _random.nextInt(4) + 2, // Lower on weekends
        'energyLevel': _random.nextInt(4) + 2, // 2-5
        'journalEntry': _generateSampleJournalEntry(isWeekend),
        'gratitudeNote': _generateSampleGratitudeNote(),
      });
    }

    return entries.reversed.toList(); // Chronological order
  }

  /// Generate sample moments for testing
  static List<Map<String, dynamic>> generateSampleMoments({int count = 50}) {
    final moments = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    final positiveActivities = [
      'Coffee with a friend', 'Beautiful sunset', 'Good conversation',
      'Finished a project', 'Relaxing music', 'Delicious meal',
      'Funny movie', 'Peaceful walk', 'Achievement at work',
    ];
    
    final neutralActivities = [
      'Regular commute', 'Grocery shopping', 'Weekly planning',
      'Household chores', 'Regular meeting', 'Normal workout',
    ];

    for (int i = 0; i < count; i++) {
      final daysAgo = _random.nextInt(30);
      final date = now.subtract(Duration(days: daysAgo));
      
      final isPositive = _random.nextDouble() < 0.7; // 70% positive
      final title = isPositive 
        ? positiveActivities[_random.nextInt(positiveActivities.length)]
        : neutralActivities[_random.nextInt(neutralActivities.length)];
      
      moments.add({
        'id': i + 1,
        'title': title,
        'description': isPositive 
          ? 'A wonderful moment that brought joy to my day'
          : 'A routine part of my day',
        'emotionalImpact': isPositive ? _random.nextInt(2) + 4 : _random.nextInt(2) + 2, // 4-5 or 2-3
        'tags': _generateSampleTags(isPositive),
        'momentType': isPositive ? 'positive' : 'neutral',
        'timestamp': date.toIso8601String(),
      });
    }

    return moments;
  }

  /// Generate analytics summary for testing
  static Map<String, dynamic> generateSampleAnalytics() {
    return {
      'period': 'Last 30 days',
      'averages': {
        'mood': 3.4,
        'stress': 2.8,
        'anxiety': 2.3,
        'energy': 3.6,
        'sleep': 7.2,
      },
      'trends': {
        'mood_trend': 'improving',
        'stress_trend': 'stable',
        'anxiety_trend': 'improving',
        'energy_trend': 'stable',
      },
      'insights': [
        'Your mood has been gradually improving over the past month',
        'Sleep quality shows positive correlation with energy levels',
        'Weekend mood ratings are consistently higher',
        'Stress management techniques seem to be working well',
      ],
      'correlations': {
        'sleep_energy': 0.73,
        'mood_stress': -0.61,
        'anxiety_mood': -0.58,
      }
    };
  }

  static String _generateSampleJournalEntry(bool isWeekend) {
    if (isWeekend) {
      final weekendEntries = [
        'Enjoyed a relaxing weekend day. Took time to recharge.',
        'Had a nice break from the usual routine today.',
        'Weekend vibes - felt more relaxed and present.',
        'Good to have some downtime and focus on personal things.',
      ];
      return weekendEntries[_random.nextInt(weekendEntries.length)];
    } else {
      final weekdayEntries = [
        'Today was productive. I felt energized and accomplished a lot.',
        'Had some challenges today but managed to stay positive.',
        'Feeling grateful for the progress I made on my goals.',
        'Worked through some tasks and maintained good energy.',
      ];
      return weekdayEntries[_random.nextInt(weekdayEntries.length)];
    }
  }

  static String _generateSampleGratitudeNote() {
    final notes = [
      'Grateful for good health and energy today',
      'Thankful for supportive friends and family',
      'Appreciating the beautiful weather',
      'Grateful for opportunities to learn and grow',
      'Thankful for moments of peace and quiet',
      'Appreciating small acts of kindness',
    ];
    return notes[_random.nextInt(notes.length)];
  }

  static List<String> _generateSampleTags(bool isPositive) {
    final positiveTags = ['joy', 'achievement', 'connection', 'gratitude', 'growth'];
    final neutralTags = ['routine', 'work', 'daily', 'normal'];
    final tags = isPositive ? positiveTags : neutralTags;
    
    final tagCount = _random.nextInt(2) + 1; // 1-2 tags
    final selectedTags = <String>[];
    
    for (int i = 0; i < tagCount; i++) {
      final tag = tags[_random.nextInt(tags.length)];
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    }
    
    return selectedTags;
  }

  /// Simple test to verify the data generation works
  static void runSimpleTest() {
    if (kDebugMode) {
      debugPrint('🧪 Running simple test data generation...');
      
      final goals = generateSampleGoals();
      debugPrint('✅ Generated ${goals.length} sample goals');
      
      final entries = generateSampleDailyEntries(days: 7);
      debugPrint('✅ Generated ${entries.length} sample daily entries');
      
      final moments = generateSampleMoments(count: 10);
      debugPrint('✅ Generated ${moments.length} sample moments');
      
      final analytics = generateSampleAnalytics();
      debugPrint('✅ Generated analytics summary with ${analytics['insights'].length} insights');
      
      debugPrint('🎉 Simple test data generation completed successfully!');
    }
  }
}