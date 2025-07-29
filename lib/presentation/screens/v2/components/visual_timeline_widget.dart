// ============================================================================
// visual_timeline_widget.dart - TIMELINE VISUAL CON PROGRESO TEMPORAL
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../../data/models/roadmap_activity_model.dart';
import '../../../providers/daily_roadmap_provider.dart';

class VisualTimelineWidget extends StatefulWidget {
  final DailyRoadmapProvider provider;
  final Function(int hour, int minute) onAddActivity;
  final Function(RoadmapActivityModel activity) onActivityTap;

  const VisualTimelineWidget({
    super.key,
    required this.provider,
    required this.onAddActivity,
    required this.onActivityTap,
  });

  @override
  State<VisualTimelineWidget> createState() => _VisualTimelineWidgetState();
}

class _VisualTimelineWidgetState extends State<VisualTimelineWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _emojiPulseController;
  late AnimationController _completionController;
  late AnimationController _shimmerController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _emojiPulseAnimation;
  late Animation<double> _completionAnimation;
  late Animation<double> _shimmerAnimation;

  final ScrollController _scrollController = ScrollController();
  final Map<String, AnimationController> _activityControllers = {};
  final Map<String, Animation<double>> _activityAnimations = {};
  
  // Constants
  static const double timelineWidth = 80.0;
  static const double hourDotSize = 16.0;
  static const double hourSpacing = 60.0;
  static const double lineWidth = 3.0;

  // Colors
  static const Color pastColor = Color(0xFF10B981);
  static const Color currentColor = Color(0xFF3B82F6);
  static const Color futureColor = Color(0xFF374151);
  static const Color lineColor = Color(0xFF1F2937);
  static const Color textPrimary = Color(0xFFE8EAF0);
  static const Color textSecondary = Color(0xFFB3B8C8);
  static const Color surface = Color(0xFF141B2D);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _emojiPulseController.dispose();
    _completionController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    
    // Dispose activity controllers
    for (final controller in _activityControllers.values) {
      controller.dispose();
    }
    _activityControllers.clear();
    _activityAnimations.clear();
    
    super.dispose();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _emojiPulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _emojiPulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _emojiPulseController,
      curve: Curves.easeInOut,
    ));

    _completionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animación después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  void _autoScrollToCurrentTime() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final currentHour = now.hour;
      final scrollPosition = (currentHour * hourSpacing) - 200; // Center current time
      
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          math.max(0, scrollPosition),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SizedBox(
              height: 24 * hourSpacing,
              child: Stack(
                children: [
                  _buildTimelineBackground(),
                  _buildProgressLine(),
                  _buildHourDots(),
                  _buildCurrentTimeIndicator(),
                  _buildActivitiesColumn(),
                  // Add floating celebration particles
                  if (widget.provider.completionPercentage >= 100)
                    _buildFloatingParticles(),
                ],
              ),
            ),
            const SizedBox(height: 20), // Padding bottom
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineBackground() {
    return Positioned(
      left: timelineWidth / 2 - lineWidth / 2,
      top: 0,
      child: Container(
        width: lineWidth,
        height: 24 * hourSpacing,
        decoration: BoxDecoration(
          color: lineColor,
          borderRadius: BorderRadius.circular(lineWidth / 2),
        ),
      ),
    );
  }

  Widget _buildProgressLine() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final totalMinutesInDay = 24 * 60;
    final currentMinutesInDay = (currentHour * 60) + currentMinute;
    final progressPercentage = currentMinutesInDay / totalMinutesInDay;
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final animatedProgress = (progressPercentage * _progressAnimation.value).clamp(0.0, 1.0);
        
        return Positioned(
          left: timelineWidth / 2 - lineWidth / 2,
          top: 0,
          child: Stack(
            children: [
              // Glow effect
              Positioned(
                left: -2,
                child: Container(
                  width: lineWidth + 4,
                  height: ((24 * hourSpacing) * animatedProgress).clamp(0.0, double.infinity),
                  decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      pastColor.withValues(alpha: 0.3),
                      currentColor.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular((lineWidth + 4) / 2),
                  ),
                ),
              ),
              // Main progress line
              Container(
                width: lineWidth,
                height: ((24 * hourSpacing) * animatedProgress).clamp(0.0, double.infinity),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [pastColor, currentColor],
                    stops: [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(lineWidth / 2),
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: _buildProgressShimmer(animatedProgress),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressShimmer(double progress) {
    if (progress < 0.2) return const SizedBox();
    
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.0, -1.0 + _shimmerAnimation.value * 2),
              end: Alignment(0.0, 1.0 + _shimmerAnimation.value * 2),
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(lineWidth / 2),
          ),
        );
      },
    );
  }

  Widget _buildHourDots() {
    final now = DateTime.now();
    final currentHour = now.hour;

    return Column(
      children: List.generate(24, (index) {
        final hour = index;
        final isPast = hour < currentHour;
        final isCurrent = hour == currentHour;
        final isFuture = hour > currentHour;

        return Container(
          height: hourSpacing,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              // Hour label
              SizedBox(
                width: 50,
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    color: isCurrent 
                        ? currentColor 
                        : isPast 
                            ? pastColor 
                            : textSecondary.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Hour dot
              _buildHourDot(hour, isPast, isCurrent, isFuture),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHourDot(int hour, bool isPast, bool isCurrent, bool isFuture) {
    final activities = widget.provider.currentRoadmap?.getActivitiesInHour(hour) ?? [];
    final hasActivities = activities.isNotEmpty;
    final completedActivities = activities.where((a) => a.isCompleted).length;
    
    Widget dot = GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final isHourInPast = _isHourInPast(hour);
        if (isHourInPast) {
          _showPastHourDetails(hour);
        } else {
          widget.onAddActivity(hour, 0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: hourDotSize,
        height: hourDotSize,
        decoration: BoxDecoration(
          color: _getDotColor(isPast, isCurrent, isFuture, hasActivities),
          shape: BoxShape.circle,
          border: Border.all(
            color: _getDotBorderColor(isPast, isCurrent, isFuture),
            width: 2,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: currentColor.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: currentColor.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 6,
                  ),
                ]
              : hasActivities
                  ? [
                      BoxShadow(
                        color: _getDotBorderColor(isPast, isCurrent, isFuture).withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
        ),
        child: hasActivities
            ? Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    activities.length.toString(),
                    key: ValueKey('${hour}_${activities.length}'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );

    // Add pulsing animation for current hour
    if (isCurrent && mounted) {
      try {
        dot = AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            if (!mounted) return child ?? dot;
            try {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: child ?? dot,
              );
            } catch (e) {
              return child ?? dot;
            }
          },
          child: dot,
        );
      } catch (e) {
        // Fallback to non-animated dot if animation fails
      }
    }

    // Add completion ring if has activities
    if (hasActivities) {
      final completionPercentage = completedActivities / activities.length;
      dot = Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: hourDotSize + 8,
            height: hourDotSize + 8,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: completionPercentage),
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 2.5,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    value == 1.0 ? pastColor : currentColor,
                  ),
                );
              },
            ),
          ),
          dot,
        ],
      );
    }

    return dot;
  }

  Color _getDotColor(bool isPast, bool isCurrent, bool isFuture, bool hasActivities) {
    if (isCurrent) return currentColor;
    if (isPast) return hasActivities ? pastColor : pastColor.withValues(alpha: 0.6);
    return hasActivities ? futureColor : Colors.transparent;
  }

  Color _getDotBorderColor(bool isPast, bool isCurrent, bool isFuture) {
    if (isCurrent) return currentColor;
    if (isPast) return pastColor;
    return futureColor;
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final minutesFromTop = (currentHour * 60) + currentMinute;
    final pixelsFromTop = (minutesFromTop / 60.0) * hourSpacing;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        if (!mounted) return const SizedBox();
        try {
          return Positioned(
            left: timelineWidth / 2 + 10,
            top: pixelsFromTop - 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: currentColor.withValues(alpha: 0.8 + (_pulseAnimation.value * 0.2)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: currentColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        } catch (e) {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildActivitiesColumn() {
    final activities = widget.provider.activitiesByTime;
    
    return Positioned(
      left: timelineWidth + 20,
      top: 0,
      right: 0,
      child: Column(
        children: List.generate(24, (index) {
          final hour = index;
          final hourActivities = widget.provider.currentRoadmap?.getActivitiesInHour(hour) ?? [];
          
          return Container(
            height: hourSpacing,
            alignment: Alignment.centerLeft,
            child: hourActivities.isEmpty 
                ? _buildEmptyHourSlot(hour)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: hourActivities.map((activity) {
                      return _buildActivityCard(activity);
                    }).toList(),
                  ),
          );
        }),
      ),
    );
  }

  /// Helper method to check if a given hour is in the past
  bool _isHourInPast(int hour) {
    final now = DateTime.now();
    final selectedDate = widget.provider.selectedDate;
    
    // If selected date is in the past, all hours are in the past
    if (selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return true;
    }
    
    // If selected date is today, check if hour has passed
    if (selectedDate.day == now.day && 
        selectedDate.month == now.month && 
        selectedDate.year == now.year) {
      return hour < now.hour;
    }
    
    // If selected date is in the future, no hours are in the past
    return false;
  }

  /// Show details for past hours instead of creating new activities
  void _showPastHourDetails(int hour) {
    final selectedDate = widget.provider.selectedDate;
    final activities = widget.provider.currentRoadmap?.getActivitiesInHour(hour) ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        title: Text(
          'Hora ${hour.toString().padLeft(2, '0')}:00',
          style: const TextStyle(color: textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              Text(
                'No hubo actividades programadas para esta hora.',
                style: TextStyle(color: textSecondary.withValues(alpha: 0.8)),
              )
            else ...[
              Text(
                'Actividades en esta hora:',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...activities.map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      activity.isCompleted ? Icons.check_circle : Icons.cancel,
                      color: activity.isCompleted ? pastColor : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 13,
                              decoration: activity.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                          if (activity.description?.isNotEmpty == true)
                            Text(
                              activity.description!,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(color: currentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHourSlot(int hour) {
    final isHourInPast = _isHourInPast(hour);
    
    return GestureDetector(
      onTap: () {
        if (isHourInPast) {
          // For past hours, show details or do nothing
          _showPastHourDetails(hour);
        } else {
          // For current/future hours, allow creating new activities
          widget.onAddActivity(hour, 0);
        }
      },
      child: Container(
        width: double.infinity,
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isHourInPast 
              ? pastColor.withValues(alpha: 0.1)
              : surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHourInPast 
                ? pastColor.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Text(
            isHourInPast ? 'Hora pasada' : 'Agregar actividad',
            style: TextStyle(
              color: isHourInPast 
                  ? pastColor.withValues(alpha: 0.7)
                  : textSecondary.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(RoadmapActivityModel activity) {
    final isCompleted = activity.isCompleted;
    final isOverdue = activity.isPast && !isCompleted;
    final isInProgress = activity.isInProgress;

    return Dismissible(
      key: ValueKey(activity.id),
      background: _buildSwipeBackground(
        color: pastColor,
        icon: Icons.check_circle,
        text: 'Completar',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: Colors.red,
        icon: Icons.delete,
        text: 'Eliminar',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right to complete
          HapticFeedback.mediumImpact();
          widget.provider.toggleActivityCompletion(activity.id);
          return false; // Don't actually dismiss
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left to delete
          HapticFeedback.heavyImpact();
          return await _showDeleteConfirmation(activity);
        }
        return false;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted 
              ? pastColor.withValues(alpha: 0.15)
              : isOverdue 
                  ? Colors.red.withValues(alpha: 0.12)
                  : isInProgress
                      ? Colors.orange.withValues(alpha: 0.12)
                      : surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted 
                ? pastColor
                : isOverdue 
                    ? Colors.red
                    : isInProgress
                        ? Colors.orange
                        : Colors.grey.withValues(alpha: 0.3),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: pastColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : isInProgress
                  ? [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
        ),
      child: Row(
        children: [
          // Completion checkbox
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.provider.toggleActivityCompletion(activity.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isCompleted ? pastColor : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? pastColor : textSecondary.withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: pastColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isCompleted
                  ? TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Activity content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (activity.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.description!,
                    style: TextStyle(
                      color: textSecondary.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                Row(
                  children: [
                    Text(
                      activity.timeString,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedBuilder(
                      animation: _emojiPulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _emojiPulseAnimation.value,
                          child: Text(
                            activity.priority.emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                    if (activity.plannedMood != null || activity.actualMood != null) ...[
                      const SizedBox(width: 6),
                      AnimatedBuilder(
                        animation: _emojiPulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _emojiPulseAnimation.value,
                            child: Text(
                              (activity.actualMood ?? activity.plannedMood)!.emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // More options
          GestureDetector(
            onTap: () => widget.onActivityTap(activity),
            child: Icon(
              Icons.more_vert,
              color: textSecondary.withValues(alpha: 0.6),
              size: 16,
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ============================================================================
  // FUNCIONES AUXILIARES PARA GESTOS
  // ============================================================================

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String text,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (alignment == Alignment.centerLeft) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(RoadmapActivityModel activity) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '¿Eliminar actividad?',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${activity.title}"?',
          style: const TextStyle(
            color: textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final offset = (index * 0.3 + _shimmerAnimation.value) % 2.0 - 1.0;
            final scale = (math.sin((_shimmerAnimation.value + index * 0.5) * math.pi) + 1) / 2;
            
            return Positioned(
              left: 50 + index * 40.0,
              top: 100 + offset * 200 + index * 80.0,
              child: Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: 0.3 + scale * 0.7,
                  child: Text(
                    ['✨', '🌟', '⭐', '💫', '🎊', '🎉'][index % 6],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}