// lib/presentation/widgets/progress_visualizations.dart
// ============================================================================
// PROGRESS VISUALIZATION COMPONENTS - PHASE 1
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../data/models/goal_model.dart';
import '../screens/v2/components/minimal_colors.dart';

// ============================================================================
// PROGRESS RING WIDGET
// ============================================================================

class ProgressRingWidget extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color>? colors;
  final Widget? centerChild;
  final bool animated;
  final Duration animationDuration;

  const ProgressRingWidget({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.colors,
    this.centerChild,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<ProgressRingWidget> createState() => _ProgressRingWidgetState();
}

class _ProgressRingWidgetState extends State<ProgressRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    if (widget.animated) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MinimalColors.primaryGradient(context);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProgressRingPainter(
              progress: widget.animated ? _animation.value : widget.progress,
              strokeWidth: widget.strokeWidth,
              colors: colors,
              backgroundColor: MinimalColors.textMuted(context).withValues(alpha: 0.2),
            ),
            child: widget.centerChild != null
                ? Center(child: widget.centerChild!)
                : Center(
                    child: Text(
                      '${(widget.animated ? _animation.value * 100 : widget.progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: widget.size * 0.15,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> colors;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// MILESTONE TIMELINE WIDGET
// ============================================================================

class MilestoneTimelineWidget extends StatelessWidget {
  final List<Milestone> milestones;
  final int currentValue;
  final int targetValue;
  final double height;

  const MilestoneTimelineWidget({
    super.key,
    required this.milestones,
    required this.currentValue,
    required this.targetValue,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Background line
          Positioned(
            top: height / 2 - 2,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Progress line
          Positioned(
            top: height / 2 - 2,
            left: 0,
            child: Container(
              height: 4,
              width: _getProgressWidth(context),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.primaryGradient(context),
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Milestone markers
          ...milestones.asMap().entries.map((entry) {
            final index = entry.key;
            final milestone = entry.value;
            return _buildMilestoneMarker(context, milestone, index);
          }).toList(),
          
          // Current progress indicator
          _buildCurrentProgressIndicator(context),
        ],
      ),
    );
  }

  Widget _buildMilestoneMarker(BuildContext context, Milestone milestone, int index) {
    final isCompleted = milestone.isCompleted;
    final position = (milestone.targetValue / targetValue).clamp(0.0, 1.0);
    
    return Positioned(
      left: position * (MediaQuery.of(context).size.width - 32) - 12,
      top: height / 2 - 12,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isCompleted
              ? LinearGradient(colors: MinimalColors.positiveGradient(context))
              : LinearGradient(colors: [
                  MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  MinimalColors.textMuted(context).withValues(alpha: 0.5),
                ]),
          border: Border.all(
            color: MinimalColors.backgroundPrimary(context),
            width: 2,
          ),
        ),
        child: Icon(
          isCompleted ? Icons.check : Icons.flag_outlined,
          size: 12,
          color: isCompleted ? Colors.white : MinimalColors.textSecondary(context),
        ),
      ),
    );
  }

  Widget _buildCurrentProgressIndicator(BuildContext context) {
    final position = (currentValue / targetValue).clamp(0.0, 1.0);
    
    return Positioned(
      left: position * (MediaQuery.of(context).size.width - 32) - 8,
      top: height / 2 - 8,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
          border: Border.all(
            color: MinimalColors.backgroundPrimary(context),
            width: 2,
          ),
        ),
      ),
    );
  }

  double _getProgressWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 32;
    final progressRatio = (currentValue / targetValue).clamp(0.0, 1.0);
    return screenWidth * progressRatio;
  }
}

// ============================================================================
// STREAK COUNTER WIDGET
// ============================================================================

class StreakCounterWidget extends StatefulWidget {
  final StreakData streakData;
  final double size;

  const StreakCounterWidget({
    super.key,
    required this.streakData,
    this.size = 80,
  });

  @override
  State<StreakCounterWidget> createState() => _StreakCounterWidgetState();
}

class _StreakCounterWidgetState extends State<StreakCounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.streakData.isStreakActive;
    final currentStreak = widget.streakData.currentStreak;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isActive && currentStreak > 0
                      ? [const Color(0xFFFF6B35), const Color(0xFFFF8E53)]
                      : MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.3)).toList(),
                ),
                boxShadow: isActive && currentStreak > 0
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive && currentStreak > 0 ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                    color: Colors.white,
                    size: widget.size * 0.3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentStreak',
                    style: TextStyle(
                      fontSize: widget.size * 0.2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// PROGRESS CHART WIDGET
// ============================================================================

class ProgressChartWidget extends StatelessWidget {
  final List<ProgressEntry> entries;
  final double height;
  final String title;

  const ProgressChartWidget({
    super.key,
    required this.entries,
    this.height = 200,
    this.title = 'Progreso',
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              _createChartData(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: MinimalColors.textMuted(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin datos de progreso aún',
              style: TextStyle(
                fontSize: 16,
                color: MinimalColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createChartData(BuildContext context) {
    final spots = entries.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.primaryValue.toDouble(),
      );
    }).toList();

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: MinimalColors.primaryGradient(context),
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: MinimalColors.primaryGradient(context)[1],
                strokeWidth: 2,
                strokeColor: MinimalColors.backgroundPrimary(context),
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: MinimalColors.primaryGradient(context)
                  .map((c) => c.withValues(alpha: 0.1))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MULTI-METRIC PROGRESS WIDGET
// ============================================================================

class MultiMetricProgressWidget extends StatelessWidget {
  final Map<String, double> metrics;
  final double height;

  const MultiMetricProgressWidget({
    super.key,
    required this.metrics,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: metrics.entries.map((entry) {
          return Expanded(
            child: _buildMetricRing(context, entry.key, entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricRing(BuildContext context, String label, double value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProgressRingWidget(
          progress: value,
          size: 50,
          strokeWidth: 4,
          colors: _getMetricColors(label),
          centerChild: Text(
            '${(value * 100).round()}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: MinimalColors.textPrimary(context),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getMetricDisplayName(label),
          style: TextStyle(
            fontSize: 12,
            color: MinimalColors.textSecondary(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Color> _getMetricColors(String metric) {
    switch (metric.toLowerCase()) {
      case 'quality':
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
      case 'mood':
        return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      case 'energy':
        return [const Color(0xFFEF4444), const Color(0xFFF87171)];
      case 'stress':
        return [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)];
      default:
        return [const Color(0xFF3B82F6), const Color(0xFF60A5FA)];
    }
  }

  String _getMetricDisplayName(String metric) {
    switch (metric.toLowerCase()) {
      case 'quality':
        return 'Calidad';
      case 'mood':
        return 'Humor';
      case 'energy':
        return 'Energía';
      case 'stress':
        return 'Estrés';
      default:
        return metric;
    }
  }
}