# Test Data System

This folder contains a clean, functional test data generation system for the ReflectFlutter app.

## Files Overview

### ✅ Working Files (No Flutter Analyze Issues)

- **`simple_test_data.dart`** - Main test data generator (RECOMMENDED)
  - Generates sample goals, daily entries, moments, and analytics
  - No database dependencies, pure data generation
  - Perfect for UI testing and development
  - ✅ Fully functional and error-free

- **`goals_test_data.dart`** - Specialized goals test data
  - Generates realistic goal progression patterns
  - Includes notes and completion states
  - Good for testing goal management features
  - ✅ Fully functional and error-free

### ⚠️ Incomplete Files

- **`test_data_seeder.dart`** - Database integration seeder
  - Requires database method compatibility fixes
  - Contains good logic but needs method signature updates

- **`test_runner.dart`** - Test system runner
  - Needs database method fixes to work properly
  - Good structure for comprehensive testing

## Quick Start

For immediate testing, use the simple test data:

```dart
import 'test_data/simple_test_data.dart';

// Generate sample data for UI testing
final goals = SimpleTestData.generateSampleGoals();
final entries = SimpleTestData.generateSampleDailyEntries(days: 30);
final moments = SimpleTestData.generateSampleMoments(count: 50);
final analytics = SimpleTestData.generateSampleAnalytics();

// Run a quick test
SimpleTestData.runSimpleTest();
```

## Features

### Sample Goals
- 5 predefined goals with varying progress
- Includes notes and completion states
- Covers all goal types (consistency, mood, positive moments, stress reduction)

### Sample Daily Entries
- Realistic mood, sleep, stress, and energy patterns
- Weekend vs weekday variations
- Gradual improvement trends over time

### Sample Moments
- Mix of positive, neutral, and negative moments
- Realistic emotional impact scores
- Appropriate tags and descriptions

### Sample Analytics
- Correlation data between metrics
- Trend analysis (improving, stable, declining)
- Insights and recommendations

## Usage Tips

1. **For UI Development**: Use `SimpleTestData` for quick mockups
2. **For Feature Testing**: Use specialized generators for specific features
3. **For Database Testing**: Fix the seeder methods first
4. **For Analytics**: Use the analytics generator for realistic patterns

## Next Steps

To make the database integration work:
1. Fix method signatures in `test_data_seeder.dart`
2. Update database service calls to match actual methods
3. Test with real database integration
4. Add error handling and validation

This system provides a solid foundation for testing and development without the complexity and errors of the previous implementation.