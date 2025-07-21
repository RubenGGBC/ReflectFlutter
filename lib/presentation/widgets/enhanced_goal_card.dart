// lib/presentation/widgets/enhanced_goal_card.dart
// ============================================================================
// ENHANCED GOAL CARD - PHASE 1 IMPLEMENTATION
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../data/models/goal_model.dart';
import '../screens/v2/components/minimal_colors.dart';
import 'progress_visualizations.dart';

class EnhancedGoalCard extends StatefulWidget {
  final GoalModel goal;
  final StreakData? streakData;
  final VoidCallback? onTap;
  final VoidCallback? onProgressUpdate;
  final VoidCallback? onAddNote;
  final bool showFullDetails;

  const EnhancedGoalCard({
    super.key,
    required this.goal,
    this.streakData,
    this.onTap,
    this.onProgressUpdate,
    this.onAddNote,
    this.showFullDetails = false,
  });

  @override
  State<EnhancedGoalCard> createState() => _EnhancedGoalCardState();
}

class _EnhancedGoalCardState extends State<EnhancedGoalCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _progressController;
  late AnimationController _milestoneController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _milestoneAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _milestoneController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.goal.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _milestoneAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _milestoneController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _progressController.forward();
    _milestoneController.forward();
  }

  @override
  void didUpdateWidget(EnhancedGoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.goal.progress != widget.goal.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.goal.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    _progressController.dispose();
    _milestoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _cardController.forward(),
            onTapUp: (_) {
              _cardController.reverse();
              widget.onTap?.call();
            },
            onTapCancel: () => _cardController.reverse(),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getBorderColor(context),
                  width: widget.goal.shouldCelebrateMilestone ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getShadowColor(context),
                    blurRadius: widget.goal.shouldCelebrateMilestone ? 25 : 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMainContent(context),
                  if (_isExpanded || widget.showFullDetails) 
                    _buildExpandedContent(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildProgressSection(context),
          const SizedBox(height: 16),
          _buildMetricsRow(context),
          const SizedBox(height: 12),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Category icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getCategoryGradient(),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIconData(widget.goal.categoryIcon),
            color: MinimalColors.textPrimaryStatic,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        
        // Title and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.goal.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                  ),
                  if (widget.goal.shouldCelebrateMilestone)
                    _buildCelebrationIndicator(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.goal.categoryDisplayName,
                style: TextStyle(
                  fontSize: 12,
                  color: MinimalColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.goal.difficultyDisplayName,
                style: TextStyle(
                  fontSize: 11,
                  color: _getDifficultyColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Progress ring
        ProgressRingWidget(
          progress: widget.goal.progress,
          size: 60,
          strokeWidth: 6,
          colors: _getCategoryGradient(),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            Text(
              '${widget.goal.currentValue}/${widget.goal.targetValue} ${widget.goal.suggestedUnit}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MinimalColors.textSecondary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Milestone timeline
        MilestoneTimelineWidget(
          milestones: widget.goal.effectiveMilestones,
          currentValue: widget.goal.currentValue,
          targetValue: widget.goal.targetValue,
        ),
        
        const SizedBox(height: 8),
        
        // Next milestone info
        if (widget.goal.nextMilestone != null)
          _buildNextMilestoneInfo(context),
      ],
    );
  }

  Widget _buildNextMilestoneInfo(BuildContext context) {
    final nextMilestone = widget.goal.nextMilestone!;
    final remaining = nextMilestone.targetValue - widget.goal.currentValue;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag,
            size: 16,
            color: MinimalColors.primaryGradient(context)[0],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Próximo: ${nextMilestone.title} ($remaining más)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MinimalColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context) {
    return Row(
      children: [
        // Streak indicator
        if (widget.streakData != null)
          Expanded(
            child: _buildMetricCard(
              context,
              'Racha',
              '${widget.streakData!.currentStreak}',
              Icons.local_fire_department,
              widget.streakData!.isStreakActive 
                  ? [MinimalColors.error, MinimalColors.warning]
                  : MinimalColors.textMuted(context).withValues(alpha: 0.3),
            ),
          ),
        
        const SizedBox(width: 12),
        
        // Days remaining
        Expanded(
          child: _buildMetricCard(
            context,
            'Días est.',
            '${widget.goal.estimatedDaysRemaining}',
            Icons.schedule,
            MinimalColors.accentGradient(context),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Difficulty
        Expanded(
          child: _buildMetricCard(
            context,
            'Nivel',
            widget.goal.difficultyDisplayName,
            Icons.trending_up,
            _getDifficultyGradient(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    dynamic colors,
  ) {
    final gradient = colors is List<Color> 
        ? colors 
        : [colors, colors.withValues(alpha: 0.7)];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map<Color>((c) => c.withValues(alpha: 0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradient.first.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: gradient.first,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: MinimalColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Progress update button
        Expanded(
          child: _buildActionButton(
            context,
            'Actualizar',
            Icons.add_circle_outline,
            MinimalColors.primaryGradient(context),
            widget.onProgressUpdate,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Add note button
        Expanded(
          child: _buildActionButton(
            context,
            'Nota',
            Icons.edit_note,
            MinimalColors.accentGradient(context),
            widget.onAddNote,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Expand button
        _buildExpandButton(context),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    List<Color> gradient,
    VoidCallback? onPressed,
  ) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: MinimalColors.textPrimaryStatic,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: MinimalColors.textPrimaryStatic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: MinimalColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 20,
            color: MinimalColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.goal.description,
            style: TextStyle(
              fontSize: 13,
              color: MinimalColors.textSecondary(context),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notes section
          if (widget.goal.hasNotes) ...[
            Text(
              'Notas de Progreso',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.goal.progressNotes ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: MinimalColors.textSecondary(context),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCelebrationIndicator() {
    return AnimatedBuilder(
      animation: _milestoneAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (math.sin(_milestoneAnimation.value * math.pi * 4) * 0.1),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [MinimalColors.warning, const Color(0xFFFF8C00)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration,
              size: 16,
              color: MinimalColors.textPrimaryStatic,
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  Color _getBorderColor(BuildContext context) {
    if (widget.goal.shouldCelebrateMilestone) {
      return MinimalColors.warning;
    }
    return MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3);
  }

  Color _getShadowColor(BuildContext context) {
    if (widget.goal.shouldCelebrateMilestone) {
      return MinimalColors.warning.withValues(alpha: 0.4);
    }
    return MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2);
  }

  List<Color> _getCategoryGradient() {
    final colorHex = widget.goal.categoryColorHex;
    final baseColor = Color(int.parse('FF$colorHex', radix: 16));
    return [
      baseColor,
      baseColor.withValues(alpha: 0.8),
    ];
  }

  Color _getDifficultyColor(BuildContext context) {
    switch (widget.goal.difficulty) {
      case 'easy':
        return MinimalColors.success;
      case 'medium':
        return MinimalColors.warning;
      case 'hard':
        return MinimalColors.error;
      case 'expert':
        return MinimalColors.accent;
      default:
        return MinimalColors.warning;
    }
  }

  List<Color> _getDifficultyGradient() {
    final baseColor = _getDifficultyColor(context);
    return [baseColor, baseColor.withValues(alpha: 0.7)];
  }

  IconData _getCategoryIconData(String iconName) {
    switch (iconName) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'psychology':
        return Icons.psychology;
      case 'bedtime':
        return Icons.bedtime;
      case 'people':
        return Icons.people;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'favorite':
        return Icons.favorite;
      case 'trending_up':
        return Icons.trending_up;
      case 'repeat':
        return Icons.repeat;
      default:
        return Icons.flag;
    }
  }
}