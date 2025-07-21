// TODO: Fix this test file with new GoalModel structure
// lib/test_data/goals_test_data.dart

import "../data/models/goal_model.dart";

class GoalsTestData {
  static List<GoalModel> getSampleGoals({int userId = 1}) {
    // TODO: Reimplement with new GoalModel structure
    return [];
  }
  
  static GoalModel createSampleGoal(String category) {
    return GoalModel(
      userId: 1,
      title: "Sample Goal",
      description: "Sample description",
      category: GoalCategory.mindfulness,
      targetValue: 30,
      createdAt: DateTime.now(),
      durationDays: 30,
      milestones: [],
      metrics: {},
      frequency: FrequencyType.daily,
      tags: [],
      customSettings: {},
      motivationalQuotes: [],
      reminderSettings: {},
      isTemplate: false,
    );
  }
}
