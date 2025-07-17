// ============================================================================
// home_enhancement_widgets.dart - HIGH PRIORITY ENHANCEMENT WIDGETS
// ============================================================================

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../providers/challenges_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/optimized_providers.dart';

// Colors (matching home screen theme)
class EnhancementColors {
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundCard = Color(0xFF0F0F0F);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);

  static const List<Color> primaryGradient = [
    Color(0xFF1e3a8a), // Azul oscuro
    Color(0xFF581c87), // Morado oscuro
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3b82f6), // Azul
    Color(0xFF8b5cf6), // Morado
  ];

  static const List<Color> lightGradient = [
    Color(0xFF60a5fa), // Azul claro
    Color(0xFFa855f7), // Morado claro
  ];

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);

  // Enhancement specific colors
  static const Color positive = Color(0xFF10b981);
  static const Color negative = Color(0xFFef4444);
  static const Color neutral = Color(0xFFf59e0b);
  static const Color empty = Color(0xFF374151);
}

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
                    color: EnhancementColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: EnhancementColors.primaryGradient[0].withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: EnhancementColors.primaryGradient[0].withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(-5, 5),
                      ),
                      BoxShadow(
                        color: EnhancementColors.primaryGradient[1].withOpacity(0.3),
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
                              gradient: const LinearGradient(
                                colors: EnhancementColors.accentGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Desafíos Personales',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: EnhancementColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: EnhancementColors.lightGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${challengesProvider.completedCount}/${challengesProvider.totalChallenges}',
                              style: const TextStyle(
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
                      }).toList(),
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
            color: EnhancementColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: EnhancementColors.primaryGradient[0].withOpacity(0.2),
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
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: EnhancementColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: EnhancementColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${challenge.current}/${challenge.target}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: EnhancementColors.textSecondary,
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
                  color: EnhancementColors.backgroundPrimary,
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
                style: const TextStyle(
                  fontSize: 11,
                  color: EnhancementColors.textTertiary,
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
        return EnhancementColors.accentGradient;
    }
  }

  Widget _buildEmptyChallengesWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EnhancementColors.backgroundCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EnhancementColors.primaryGradient[0].withOpacity(0.2),
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
                colors: EnhancementColors.primaryGradient.map((c) => c.withOpacity(0.3)).toList(),
              ),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: EnhancementColors.textSecondary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Desafíos llegando pronto',
            style: TextStyle(
              fontSize: 14,
              color: EnhancementColors.textSecondary,
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

    // Create staggered animations for each cell
    _cellAnimations = List.generate(30, (index) {
      final start = (index * 0.02).clamp(0.0, 0.6);
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
                    color: EnhancementColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: EnhancementColors.primaryGradient[0].withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: EnhancementColors.primaryGradient[0].withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(-5, 5),
                      ),
                      BoxShadow(
                        color: EnhancementColors.primaryGradient[1].withOpacity(0.3),
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
                              gradient: const LinearGradient(
                                colors: EnhancementColors.accentGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_view_month,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Mapa de Bienestar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: EnhancementColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: EnhancementColors.lightGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '30 días',
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
    // Create 6 rows x 5 columns grid (30 days)
    return SizedBox(
      height: 120,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: math.min(calendarData.length, 30),
        itemBuilder: (context, index) {
          if (index >= _cellAnimations.length) return const SizedBox();
          
          final dayData = calendarData[index];
          return AnimatedBuilder(
            animation: _cellAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _cellAnimations[index].value,
                child: _buildHeatmapCell(dayData),
              );
            },
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
        cellColor = EnhancementColors.positive.withOpacity(0.3 + (intensity * 0.7));
        break;
      case 'negative':
        cellColor = EnhancementColors.negative.withOpacity(0.3 + (intensity * 0.7));
        break;
      case 'neutral':
        cellColor = EnhancementColors.neutral.withOpacity(0.3 + (intensity * 0.7));
        break;
      default:
        cellColor = EnhancementColors.empty.withOpacity(0.3);
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
        const Text(
          'Menos',
          style: TextStyle(
            fontSize: 12,
            color: EnhancementColors.textTertiary,
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
              color: EnhancementColors.positive.withOpacity(opacity),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        const Text(
          'Más',
          style: TextStyle(
            fontSize: 12,
            color: EnhancementColors.textTertiary,
          ),
        ),
        const Spacer(),
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: EnhancementColors.positive.withOpacity(0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Text(
          'Positivo',
          style: TextStyle(
            fontSize: 10,
            color: EnhancementColors.textTertiary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: EnhancementColors.negative.withOpacity(0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Text(
          'Negativo',
          style: TextStyle(
            fontSize: 10,
            color: EnhancementColors.textTertiary,
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
                    color: EnhancementColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: EnhancementColors.primaryGradient[0].withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: EnhancementColors.primaryGradient[0].withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(-5, 5),
                      ),
                      BoxShadow(
                        color: EnhancementColors.primaryGradient[1].withOpacity(0.3),
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
                              gradient: const LinearGradient(
                                colors: [Color(0xFFf97316), Color(0xFFea580c)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Racha de Constancia',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: EnhancementColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFf97316), Color(0xFFea580c)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              streakProvider.streakLevel,
                              style: const TextStyle(
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
                                            const Color(0xFFfbbf24).withOpacity(0.8),
                                            const Color(0xFFf97316).withOpacity(0.6),
                                            const Color(0xFFea580c).withOpacity(0.4),
                                          ]
                                        : [
                                            EnhancementColors.textTertiary.withOpacity(0.3),
                                            EnhancementColors.textTertiary.withOpacity(0.2),
                                            EnhancementColors.textTertiary.withOpacity(0.1),
                                          ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      streakData.isActive ? '🔥' : '💤',
                                      style: const TextStyle(fontSize: 32),
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
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: EnhancementColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'días',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: EnhancementColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Racha actual',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: EnhancementColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Récord: ${streakData.longestStreak} días',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: EnhancementColors.textTertiary,
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
        color: EnhancementColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EnhancementColors.primaryGradient[0].withOpacity(0.2),
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
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Próximo: ${milestone.title}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: EnhancementColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$daysLeft días',
                style: const TextStyle(
                  fontSize: 12,
                  color: EnhancementColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: streakData.progressToNext,
              backgroundColor: EnhancementColors.backgroundPrimary,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFf97316)),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            milestone.description,
            style: const TextStyle(
              fontSize: 11,
              color: EnhancementColors.textTertiary,
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
        color: EnhancementColors.backgroundCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EnhancementColors.primaryGradient[0].withOpacity(0.2),
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
                    color: EnhancementColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: EnhancementColors.primaryGradient[0].withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: EnhancementColors.primaryGradient[0].withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(-5, 5),
                      ),
                      BoxShadow(
                        color: EnhancementColors.primaryGradient[1].withOpacity(0.3),
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
                              gradient: const LinearGradient(
                                colors: EnhancementColors.accentGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Predicciones IA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: EnhancementColors.textPrimary,
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
                                    colors: EnhancementColors.lightGradient.map(
                                      (c) => c.withOpacity(0.7 + (_insightAnimation.value * 0.3))
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
                                      color: Colors.white.withOpacity(0.8 + (_insightAnimation.value * 0.2)),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${((insights['confidence'] as double? ?? 0.0) * 100).round()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.8 + (_insightAnimation.value * 0.2)),
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
        trendColor = EnhancementColors.positive;
        trendText = 'Mejorando';
        break;
      case 'declining':
        trendIcon = Icons.trending_down;
        trendColor = EnhancementColors.negative;
        trendText = 'Desafiante';
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = EnhancementColors.neutral;
        trendText = 'Estable';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: trendColor.withOpacity(0.3),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: EnhancementColors.textSecondary,
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
        color: EnhancementColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EnhancementColors.primaryGradient[0].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: EnhancementColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Insight',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EnhancementColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insights['insight'] as String? ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: EnhancementColors.textPrimary,
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
          colors: EnhancementColors.primaryGradient.map((c) => c.withOpacity(0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EnhancementColors.primaryGradient[1].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.recommend,
                color: EnhancementColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recomendación',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EnhancementColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insights['recommendation'] as String? ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: EnhancementColors.textPrimary,
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
        color: EnhancementColors.backgroundCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EnhancementColors.primaryGradient[0].withOpacity(0.2),
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
                colors: EnhancementColors.primaryGradient.map((c) => c.withOpacity(0.3)).toList(),
              ),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: EnhancementColors.textSecondary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: EnhancementColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}