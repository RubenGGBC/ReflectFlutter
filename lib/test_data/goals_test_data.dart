// lib/test_data/goals_test_data.dart
// ============================================================================
// GOALS TEST DATA GENERATOR
// ============================================================================

import 'dart:math';
import '../data/models/goal_model.dart';

class GoalsTestData {
  static final Random _random = Random();

  /// Generate realistic test goals with varying progress
  static List<GoalModel> generateTestGoals(int userId) {
    final goals = <GoalModel>[];
    
    // Consistency Goals
    goals.addAll([
      GoalModel.createConsistencyGoal(
        userId: userId,
        title: 'Daily Meditation',
        description: 'Practice mindfulness meditation for 10 minutes every day',
        targetDays: 30,
      ).updateProgress(22, notes: '2024-01-15: Feeling more centered each day'),
      
      GoalModel.createConsistencyGoal(
        userId: userId,
        title: 'Morning Workout',
        description: 'Exercise for 30 minutes every morning',
        targetDays: 21,
      ).updateProgress(15, notes: '2024-01-14: Building the habit slowly'),
      
      GoalModel.createConsistencyGoal(
        userId: userId,
        title: 'Read Before Bed',
        description: 'Read for 20 minutes before going to sleep',
        targetDays: 14,
      ).updateProgress(14, notes: '2024-01-13: Completed! Sleep quality improved')
        .markAsCompleted(completionNote: 'Reading habit established successfully'),
    ]);

    // Mood Improvement Goals
    goals.addAll([
      GoalModel.createMoodGoal(
        userId: userId,
        title: 'Practice Gratitude',
        description: 'Write down 3 things I\'m grateful for',
        targetTimes: 25,
      ).updateProgress(18, notes: '2024-01-12: Noticing more positive things'),
      
      GoalModel.createMoodGoal(
        userId: userId,
        title: 'Positive Affirmations',
        description: 'Say positive affirmations every morning',
        targetTimes: 20,
      ).updateProgress(8, notes: '2024-01-10: Still working on consistency'),
    ]);

    // Positive Moments Goals
    goals.addAll([
      GoalModel.createPositiveMomentsGoal(
        userId: userId,
        title: 'Connect with Friends',
        description: 'Reach out to friends and family regularly',
        targetMoments: 15,
      ).updateProgress(12, notes: '2024-01-11: Had great conversations this week'),
      
      GoalModel.createPositiveMomentsGoal(
        userId: userId,
        title: 'Try New Things',
        description: 'Experience something new each week',
        targetMoments: 8,
      ).updateProgress(3, notes: '2024-01-09: Tried a new recipe and art class'),
    ]);

    // Stress Reduction Goals
    goals.addAll([
      GoalModel.createStressReductionGoal(
        userId: userId,
        title: 'Deep Breathing',
        description: 'Practice deep breathing exercises when stressed',
        targetTimes: 30,
      ).updateProgress(25, notes: '2024-01-08: Really helping with anxiety'),
      
      GoalModel.createStressReductionGoal(
        userId: userId,
        title: 'Organize Workspace',
        description: 'Keep workspace clean and organized',
        targetTimes: 10,
      ).updateProgress(10, notes: '2024-01-07: Much more productive now')
        .markAsCompleted(completionNote: 'Workspace organization mastered'),
    ]);

    // Add some variety in creation dates
    for (int i = 0; i < goals.length; i++) {
      final daysAgo = _random.nextInt(60) + 1; // 1-60 days ago
      final createdAt = DateTime.now().subtract(Duration(days: daysAgo));
      
      goals[i] = goals[i].copyWith(
        createdAt: createdAt,
        lastUpdated: createdAt.add(Duration(days: _random.nextInt(daysAgo))),
      );
    }

    return goals;
  }

  /// Generate goal progress notes for testing
  static List<String> generateProgressNotes() {
    return [
      '2024-01-15: Made great progress today, feeling motivated',
      '2024-01-14: Had some challenges but stayed committed',
      '2024-01-13: Excellent day, exceeded my expectations',
      '2024-01-12: Steady progress, building good habits',
      '2024-01-11: Took a rest day but staying focused',
      '2024-01-10: Back on track after a difficult period',
      '2024-01-09: Celebrating small wins along the way',
      '2024-01-08: Learning to be patient with myself',
      '2024-01-07: Starting to see real positive changes',
      '2024-01-06: Consistency is key, one day at a time',
    ];
  }

  /// Generate realistic goal titles by category
  static Map<GoalType, List<String>> getGoalTitlesByType() {
    return {
      GoalType.consistency: [
        'Daily Meditation',
        'Morning Workout',
        'Evening Walk',
        'Read Before Bed',
        'Journal Writing',
        'Hydration Goal',
        'Healthy Breakfast',
        'Yoga Practice',
        'Stretching Routine',
        'Digital Detox Hour',
      ],
      GoalType.mood: [
        'Practice Gratitude',
        'Positive Affirmations',
        'Smile More Often',
        'Listen to Uplifting Music',
        'Practice Self-Compassion',
        'Celebrate Small Wins',
        'Focus on Strengths',
        'Mindful Breathing',
        'Connect with Nature',
        'Express Feelings',
      ],
      GoalType.positiveMoments: [
        'Connect with Friends',
        'Try New Things',
        'Help Others',
        'Create Art',
        'Learn Something New',
        'Enjoy Nature',
        'Practice Hobbies',
        'Share Meals',
        'Listen to Music',
        'Capture Memories',
      ],
      GoalType.stressReduction: [
        'Deep Breathing',
        'Organize Workspace',
        'Take Breaks',
        'Set Boundaries',
        'Declutter Home',
        'Plan Ahead',
        'Practice Saying No',
        'Use Time Blocks',
        'Limit Multitasking',
        'Create Routines',
      ],
    };
  }

  /// Generate a random goal based on type
  static GoalModel generateRandomGoal(int userId, GoalType type) {
    final titles = getGoalTitlesByType()[type]!;
    final title = titles[_random.nextInt(titles.length)];
    final target = _random.nextInt(25) + 5; // 5-30
    final current = _random.nextInt(target);
    
    GoalModel goal;
    
    switch (type) {
      case GoalType.consistency:
        goal = GoalModel.createConsistencyGoal(
          userId: userId,
          title: title,
          description: 'Build a healthy daily habit of $title',
          targetDays: target,
        );
        break;
      case GoalType.mood:
        goal = GoalModel.createMoodGoal(
          userId: userId,
          title: title,
          description: 'Improve mood through $title practice',
          targetTimes: target,
        );
        break;
      case GoalType.positiveMoments:
        goal = GoalModel.createPositiveMomentsGoal(
          userId: userId,
          title: title,
          description: 'Create positive experiences with $title',
          targetMoments: target,
        );
        break;
      case GoalType.stressReduction:
        goal = GoalModel.createStressReductionGoal(
          userId: userId,
          title: title,
          description: 'Reduce stress by practicing $title',
          targetTimes: target,
        );
        break;
    }

    // Add progress and notes
    if (current > 0) {
      final notes = generateProgressNotes();
      goal = goal.updateProgress(
        current,
        notes: notes[_random.nextInt(notes.length)],
      );
    }

    // Mark some goals as completed
    if (current >= target && _random.nextBool()) {
      goal = goal.markAsCompleted(
        completionNote: 'Successfully achieved this goal!',
      );
    }

    return goal;
  }
}