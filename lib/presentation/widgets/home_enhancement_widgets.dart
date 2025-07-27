// ============================================================================
// home_enhancement_widgets.dart - HIGH PRIORITY ENHANCEMENT WIDGETS
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../providers/challenges_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/optimized_providers.dart';

// Import theme-aware colors
import '../screens/v2/components/minimal_colors.dart';

// ============================================================================
// 1. PERSONALIZED CHALLENGES WIDGET
// ============================================================================


class PersonalizedChallengesWidget extends StatefulWidget {
  final AnimationController animationController;

  const PersonalizedChallengesWidget({
    super.key,
    required this.animationController,
  });

  @override
  State<PersonalizedChallengesWidget> createState() => _PersonalizedChallengesWidgetState();
}

class _PersonalizedChallengesWidgetState extends State<PersonalizedChallengesWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic));

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengesProvider>(
      builder: (context, challengesProvider, child) {
        final activeChallenges = challengesProvider.activeChallenges.take(3).toList();
        
        if (activeChallenges.isEmpty) {
          return _buildEmptyChallengesWidget();
        }

        return AnimatedBuilder(
          animation: widget.animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - widget.animationController.value) * 20),
              child: Opacity(
                opacity: widget.animationController.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(-5, 5),
                      ),
                      BoxShadow(
                        color: MinimalColors.coloredShadow(context, MinimalColors.primaryGradient(context)[1], alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: MinimalColors.accentGradient(context),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Desafíos Personales',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: MinimalColors.lightGradient(context),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${challengesProvider.completedCount}/${challengesProvider.totalChallenges}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...activeChallenges.asMap().entries.map((entry) {
                        final index = entry.key;
                        final challenge = entry.value;
                        return _buildChallengeCard(challenge, index);
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge, int index) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundSecondary(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    challenge.emoji,
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MinimalColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: MinimalColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${challenge.current}/${challenge.target}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Animated progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: MinimalColors.backgroundPrimary(context),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value * challenge.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getChallengeGradient(challenge.type),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                challenge.reward,
                style: TextStyle(
                  fontSize: 11,
                  color: MinimalColors.textTertiary(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Color> _getChallengeGradient(String type) {
    switch (type) {
      case 'streak':
        return [const Color(0xFFf97316), const Color(0xFFea580c)];
      case 'meditation':
        return [const Color(0xFF8b5cf6), const Color(0xFF7c3aed)];
      case 'exercise':
        return [const Color(0xFF10b981), const Color(0xFF059669)];
      case 'wellbeing':
        return [const Color(0xFF3b82f6), const Color(0xFF2563eb)];
      default:
        return MinimalColors.accentGradientStatic;
    }
  }

  Widget _buildEmptyChallengesWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.3)).toList(),
              ),
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: MinimalColors.textSecondary(context),
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Desafíos llegando pronto',
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. MOOD CALENDAR HEATMAP WIDGET
// ============================================================================

class MoodCalendarHeatmapWidget extends StatefulWidget {
  final AnimationController animationController;

  const MoodCalendarHeatmapWidget({
    super.key,
    required this.animationController,
  });

  @override
  State<MoodCalendarHeatmapWidget> createState() => _MoodCalendarHeatmapWidgetState();
}

class _MoodCalendarHeatmapWidgetState extends State<MoodCalendarHeatmapWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _heatmapController;
  late List<Animation<double>> _cellAnimations;

  @override
  void initState() {
    super.initState();
    _heatmapController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create staggered animations for each cell (7 days)
    _cellAnimations = List.generate(7, (index) {
      final start = (index * 0.1).clamp(0.0, 0.6);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _heatmapController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _heatmapController.forward();
  }

  @override
  void dispose() {
    _heatmapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        final calendarData = analyticsProvider.moodCalendarData;

        return AnimatedBuilder(
          animation: widget.animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - widget.animationController.value) * 20),
              child: Opacity(
                opacity: widget.animationController.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(-5, 5),
                      ),
                      BoxShadow(
                        color: MinimalColors.coloredShadow(context, MinimalColors.primaryGradient(context)[1], alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: MinimalColors.accentGradient(context),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_view_month,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mapa de Bienestar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: MinimalColors.lightGradient(context),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '7 días',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildHeatmapGrid(calendarData),
                      const SizedBox(height: 12),
                      _buildDayLabels(calendarData),
                      const SizedBox(height: 16),
                      _buildHeatmapLegend(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeatmapGrid(List<Map<String, dynamic>> calendarData) {
    // Create single row for 7 days
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          math.min(calendarData.length, 7),
          (index) {
            if (index >= _cellAnimations.length) return const SizedBox();
            
            final dayData = calendarData[index];
            return Expanded(
              child: AnimatedBuilder(
                animation: _cellAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cellAnimations[index].value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildHeatmapCell(dayData),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayLabels(List<Map<String, dynamic>> calendarData) {
    const dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        math.min(calendarData.length, 7),
        (index) {
          final dayData = calendarData[index];
          final date = dayData['date'] as DateTime;
          final isToday = dayData['isToday'] as bool? ?? false;
          final dayName = dayNames[date.weekday - 1];
          
          return Expanded(
            child: Text(
              dayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday
                    ? MinimalColors.accentGradient(context)[0]
                    : MinimalColors.textSecondary(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeatmapCell(Map<String, dynamic> dayData) {
    final type = dayData['type'] as String;
    final intensity = dayData['intensity'] as double? ?? 0.0;
    final isToday = dayData['isToday'] as bool? ?? false;

    Color cellColor;
    switch (type) {
      case 'positive':
        cellColor = MinimalColors.positiveGradient(context)[0].withValues(alpha: 0.3 + (intensity * 0.7));
        break;
      case 'negative':
        cellColor = MinimalColors.negativeGradient(context)[0].withValues(alpha: 0.3 + (intensity * 0.7));
        break;
      case 'neutral':
        cellColor = MinimalColors.neutralGradient(context)[0].withValues(alpha: 0.3 + (intensity * 0.7));
        break;
      default:
        cellColor = MinimalColors.textMuted(context).withValues(alpha: 0.3);
    }

    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(4),
        border: isToday ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: isToday
          ? const Center(
              child: Icon(
                Icons.circle,
                color: Colors.white,
                size: 8,
              ),
            )
          : null,
    );
  }

  Widget _buildHeatmapLegend() {
    return Row(
      children: [
        Text(
          'Menos',
          style: TextStyle(
            fontSize: 12,
            color: MinimalColors.textTertiary(context),
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(4, (index) {
          final opacity = 0.3 + (index * 0.2);
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: MinimalColors.positiveGradient(context)[0].withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          'Más',
          style: TextStyle(
            fontSize: 12,
            color: MinimalColors.textTertiary(context),
          ),
        ),
        const Spacer(),
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: MinimalColors.positiveGradient(context)[0].withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          'Positivo',
          style: TextStyle(
            fontSize: 10,
            color: MinimalColors.textTertiary(context),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: MinimalColors.negativeGradient(context)[0].withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          'Negativo',
          style: TextStyle(
            fontSize: 10,
            color: MinimalColors.textTertiary(context),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 3. STREAK TRACKER WIDGET
// ============================================================================

class StreakTrackerWidget extends StatefulWidget {
  final AnimationController animationController;

  const StreakTrackerWidget({
    super.key,
    required this.animationController,
  });

  @override
  State<StreakTrackerWidget> createState() => _StreakTrackerWidgetState();
}

class _StreakTrackerWidgetState extends State<StreakTrackerWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _flameAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _flameController, curve: Curves.easeInOut));

    _flameController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StreakProvider>(
      builder: (context, streakProvider, child) {
        final streakData = streakProvider.streakData;
        
        if (streakData == null) {
          return _buildLoadingWidget();
        }

        return AnimatedBuilder(
          animation: widget.animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - widget.animationController.value) * 5),
              child: Opacity(
                opacity: 1.0, // Fixed opacity instead of animationController.value
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(-5, 5),
                      ),
                      BoxShadow(
                        color: MinimalColors.coloredShadow(context, MinimalColors.primaryGradient(context)[1], alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFf97316), Color(0xFFea580c)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Racha de Constancia',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFf97316), Color(0xFFea580c)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              streakProvider.streakLevel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Flame animation
                          AnimatedBuilder(
                            animation: _flameAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _flameAnimation.value * streakProvider.flameIntensity.clamp(0.5, 1.0),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: streakData.isActive 
                                        ? [
                                            const Color(0xFFfbbf24).withValues(alpha: 0.8),
                                            const Color(0xFFf97316).withValues(alpha: 0.6),
                                            const Color(0xFFea580c).withValues(alpha: 0.4),
                                          ]
                                        : [
                                            MinimalColors.textTertiary(context).withValues(alpha: 0.3),
                                            MinimalColors.textTertiary(context).withValues(alpha: 0.2),
                                            MinimalColors.textTertiary(context).withValues(alpha: 0.1),
                                          ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      streakData.isActive ? '🔥' : '💤',
                                      style: TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${streakData.currentStreak}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: MinimalColors.textPrimary(context),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'días',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: MinimalColors.textSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Racha actual',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: MinimalColors.textSecondary(context),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Récord: ${streakData.longestStreak} días',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: MinimalColors.textTertiary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (streakData.nextMilestone != null) ...[
                        const SizedBox(height: 20),
                        _buildNextMilestone(streakData),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNextMilestone(StreakData streakData) {
    final milestone = streakData.nextMilestone!;
    final daysLeft = milestone.days - streakData.currentStreak;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                milestone.emoji,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Próximo: ${milestone.title}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MinimalColors.textPrimary(context),
                  ),
                ),
              ),
              Text(
                '$daysLeft días',
                style: TextStyle(
                  fontSize: 12,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: streakData.progressToNext,
              backgroundColor: MinimalColors.backgroundPrimary(context),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFf97316)),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            milestone.description,
            style: TextStyle(
              fontSize: 11,
              color: MinimalColors.textTertiary(context),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFf97316)),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. WELLBEING PREDICTION INSIGHTS WIDGET
// ============================================================================

class WellbeingPredictionWidget extends StatefulWidget {
  final AnimationController animationController;

  const WellbeingPredictionWidget({
    super.key,
    required this.animationController,
  });

  @override
  State<WellbeingPredictionWidget> createState() => _WellbeingPredictionWidgetState();
}

class _WellbeingPredictionWidgetState extends State<WellbeingPredictionWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _insightController;
  late Animation<double> _insightAnimation;

  @override
  void initState() {
    super.initState();
    _insightController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _insightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _insightController, curve: Curves.easeInOut));

    _insightController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _insightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        final insights = analyticsProvider.predictionInsights;

        if (!(insights['hasEnoughData'] as bool? ?? false)) {
          return _buildInsufficientDataWidget(insights['message'] as String? ?? '');
        }

        return AnimatedBuilder(
          animation: widget.animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - widget.animationController.value) * 20),
              child: Opacity(
                opacity: widget.animationController.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(-5, 5),
                      ),
                      BoxShadow(
                        color: MinimalColors.coloredShadow(context, MinimalColors.primaryGradient(context)[1], alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: MinimalColors.accentGradient(context),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Predicciones IA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _insightAnimation,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: MinimalColors.lightGradient(context).map(
                                      (c) => c.withValues(alpha: 0.7 + (_insightAnimation.value * 0.3))
                                    ).toList(),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 12,
                                      color: Colors.white.withValues(alpha: 0.8 + (_insightAnimation.value * 0.2)),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${((insights['confidence'] as double? ?? 0.0) * 100).round()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.8 + (_insightAnimation.value * 0.2)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTrendIndicator(insights),
                      const SizedBox(height: 16),
                      _buildInsightCard(insights),
                      const SizedBox(height: 16),
                      _buildRecommendationCard(insights),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendIndicator(Map<String, dynamic> insights) {
    final trend = insights['trend'] as String? ?? 'stable';
    final trendValue = insights['trendValue'] as double? ?? 0.0;

    IconData trendIcon;
    Color trendColor;
    String trendText;

    switch (trend) {
      case 'improving':
        trendIcon = Icons.trending_up;
        trendColor = MinimalColors.positiveGradient(context)[0];
        trendText = 'Mejorando';
        break;
      case 'declining':
        trendIcon = Icons.trending_down;
        trendColor = MinimalColors.negativeGradient(context)[0];
        trendText = 'Desafiante';
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = MinimalColors.neutralGradient(context)[0];
        trendText = 'Estable';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: trendColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            trendIcon,
            color: trendColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tendencia: $trendText',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
                Text(
                  'Cambio: ${trendValue > 0 ? '+' : ''}${trendValue.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: MinimalColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insights) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: MinimalColors.textSecondary(context),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Insight',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insights['insight'] as String? ?? '',
            style: TextStyle(
              fontSize: 16,
              color: MinimalColors.textPrimary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> insights) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: MinimalColors.textSecondary(context),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Recomendación',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insights['recommendation'] as String? ?? '',
            style: TextStyle(
              fontSize: 16,
              color: MinimalColors.textPrimary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsufficientDataWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.3)).toList(),
              ),
            ),
            child: Icon(
              Icons.psychology_outlined,
              color: MinimalColors.textSecondary(context),
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}