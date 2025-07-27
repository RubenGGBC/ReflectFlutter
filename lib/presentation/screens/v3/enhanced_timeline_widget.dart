// ============================================================================
// enhanced_timeline_widget.dart - TIMELINE MEJORADO CON CÍRCULOS CLICABLES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../data/models/roadmap_activity_model.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class EnhancedTimelineWidget extends StatefulWidget {
  final DailyRoadmapProvider provider;
  final Function(int hour, int minute) onAddActivity;
  final Function(RoadmapActivityModel activity) onActivityTap;
  final Function(int hour) onHourTap; // Nueva función para cuando se toca una hora

  const EnhancedTimelineWidget({
    super.key,
    required this.provider,
    required this.onAddActivity,
    required this.onActivityTap,
    required this.onHourTap,
  });

  @override
  State<EnhancedTimelineWidget> createState() => _EnhancedTimelineWidgetState();
}

class _EnhancedTimelineWidgetState extends State<EnhancedTimelineWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  final ScrollController _scrollController = ScrollController();
  
  // Constants
  static const double hourSpacing = 80.0;
  static const double hourCircleSize = 24.0;
  static const double lineWidth = 3.0;

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
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);


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

    _progressController.forward();
  }

  void _autoScrollToCurrentTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Scroll to show current hour with some context
    final targetOffset = math.max(0.0, (currentHour - 2) * hourSpacing);
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentColors;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode 
                ? theme.surface 
                : theme.surface.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeProvider.isDarkMode 
                  ? theme.borderColor.withValues(alpha: 0.3)
                  : theme.borderColor.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: themeProvider.isDarkMode ? 0.1 : 0.12),
                blurRadius: themeProvider.isDarkMode ? 16 : 20,
                offset: Offset(0, themeProvider.isDarkMode ? 6 : 8),
              ),
              if (!themeProvider.isDarkMode)
                BoxShadow(
                  color: theme.borderColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            children: [
              // Header del timeline
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: theme.gradientHeader,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cronograma del Día',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getCurrentTimeString(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          
              // Timeline scrollable
              Expanded(
                child: _buildTimeline(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 24, // 24 horas
      itemBuilder: (context, index) {
        final hour = index;
        final isCurrentHour = _isCurrentHour(hour);
        final isPastHour = _isPastHour(hour);
        final activities = _getActivitiesForHour(hour);
        
        return _buildHourSection(hour, isCurrentHour, isPastHour, activities);
      },
    );
  }

  Widget _buildHourSection(int hour, bool isCurrentHour, bool isPastHour, List<RoadmapActivityModel> activities) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentColors;
        return SizedBox(
          height: hourSpacing,
          child: Row(
            children: [
          // Time column
          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatHour(hour),
                  style: TextStyle(
                    color: isCurrentHour 
                        ? theme.accentPrimary
                        : themeProvider.isDarkMode 
                            ? theme.textPrimary
                            : theme.textPrimary.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: isCurrentHour ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    color: themeProvider.isDarkMode 
                        ? theme.textSecondary
                        : theme.textSecondary.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Timeline line and circle
          SizedBox(
            width: 40,
            child: Stack(
              children: [
                // Vertical line
                Positioned(
                  left: 18,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: lineWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isPastHour 
                            ? [theme.positiveMain, theme.positiveMain.withValues(alpha: 0.5)]
                            : themeProvider.isDarkMode
                                ? [theme.borderColor.withValues(alpha: 0.3), theme.borderColor.withValues(alpha: 0.1)]
                                : [theme.borderColor.withValues(alpha: 0.6), theme.borderColor.withValues(alpha: 0.3)],
                      ),
                    ),
                  ),
                ),
                
                // Hour circle (clickable)
                Positioned(
                  left: 8,
                  top: 20,
                  child: _buildHourCircle(hour, isCurrentHour, isPastHour, activities.isNotEmpty),
                ),
              ],
            ),
          ),
          
              // Activities column
              Expanded(
                child: activities.isEmpty 
                    ? _buildEmptyHourSlot(hour, isPastHour)
                    : _buildActivitiesColumn(activities, isPastHour),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHourCircle(int hour, bool isCurrentHour, bool isPastHour, bool hasActivities) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentColors;
        
        Color circleColor;
        Color iconColor = Colors.white;
        IconData icon;
        
        if (hasActivities) {
          circleColor = isPastHour ? theme.positiveMain : theme.accentPrimary;
          icon = isPastHour ? Icons.check_circle : Icons.event;
        } else {
          circleColor = isCurrentHour 
              ? theme.accentPrimary 
              : theme.borderColor.withValues(alpha: 0.6);
          icon = Icons.add_circle_outline;
          iconColor = isCurrentHour ? Colors.white : theme.textSecondary;
        }

        Widget circle = GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onHourTap(hour);
          },
          child: Container(
            width: hourCircleSize,
            height: hourCircleSize,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrentHour 
                    ? theme.accentSecondary
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: hasActivities || isCurrentHour ? [
                BoxShadow(
                  color: circleColor.withValues(alpha: themeProvider.isDarkMode ? 0.4 : 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                if (!themeProvider.isDarkMode)
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
              ] : null,
            ),
            child: Icon(
              icon,
              size: 14,
              color: iconColor,
            ),
          ),
        );

        // Add pulse animation for current hour
        if (isCurrentHour) {
          return AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: circle,
              );
            },
          );
        }

        return circle;
      },
    );
  }

  Widget _buildEmptyHourSlot(int hour, bool isPastHour) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentColors;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onAddActivity(hour, 0);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode 
                  ? theme.surfaceVariant.withValues(alpha: 0.3)
                  : theme.surfaceVariant.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode 
                    ? theme.borderColor.withValues(alpha: 0.2)
                    : theme.borderColor.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: themeProvider.isDarkMode ? null : [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isPastHour ? Icons.history : Icons.add,
                  size: 16,
                  color: themeProvider.isDarkMode 
                      ? theme.textSecondary
                      : theme.textSecondary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  isPastHour ? 'Sin actividad' : 'Agregar actividad',
                  style: TextStyle(
                    color: themeProvider.isDarkMode 
                        ? theme.textSecondary
                        : theme.textSecondary.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivitiesColumn(List<RoadmapActivityModel> activities, bool isPastHour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        return Container(
          margin: EdgeInsets.only(
            right: 16,
            top: index == 0 ? 8 : 4,
            bottom: index == activities.length - 1 ? 8 : 4,
          ),
          child: _buildActivityCard(activity, isPastHour),
        );
      }).toList(),
    );
  }

  Widget _buildActivityCard(RoadmapActivityModel activity, bool isPastHour) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentColors;
        final isCompleted = activity.isCompleted;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onActivityTap(activity);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isCompleted 
                  ? LinearGradient(
                      colors: themeProvider.isDarkMode ? [
                        theme.positiveMain.withValues(alpha: 0.1),
                        theme.positiveMain.withValues(alpha: 0.05),
                      ] : [
                        theme.positiveLight,
                        theme.positiveLight.withValues(alpha: 0.7),
                      ],
                    )
                  : null,
              color: !isCompleted 
                  ? (themeProvider.isDarkMode 
                      ? theme.surfaceVariant 
                      : theme.surfaceVariant.withValues(alpha: 0.9))
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted 
                    ? theme.positiveMain.withValues(alpha: themeProvider.isDarkMode ? 0.3 : 0.5)
                    : theme.borderColor.withValues(alpha: themeProvider.isDarkMode ? 0.3 : 0.6),
                width: 1,
              ),
              boxShadow: themeProvider.isDarkMode ? null : [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? theme.positiveMain
                    : theme.accentPrimary,
                shape: BoxShape.circle,
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
                      color: theme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activity.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      activity.description!,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Time and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activity.timeString,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 2),
                  Icon(
                    Icons.check_circle,
                    size: 12,
                    color: theme.positiveMain,
                  ),
                ],
              ],
            ),
          ],
        ),
          ),
        );
      },
    );
  }

  // Helper methods
  bool _isCurrentHour(int hour) {
    return DateTime.now().hour == hour;
  }

  bool _isPastHour(int hour) {
    return DateTime.now().hour > hour;
  }

  List<RoadmapActivityModel> _getActivitiesForHour(int hour) {
    return widget.provider.activitiesByTime
        .where((activity) => activity.hour == hour)
        .toList();
  }

  String _formatHour(int hour) {
    if (hour == 0) return 'Medianoche';
    if (hour == 12) return 'Mediodía';
    if (hour < 12) return '${hour}AM';
    return '${hour - 12}PM';
  }

  String _getCurrentTimeString() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}