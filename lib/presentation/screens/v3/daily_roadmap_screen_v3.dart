// ============================================================================
// daily_roadmap_screen_v3.dart - ENHANCED DAILY ROADMAP WITH THEME SUPPORT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Core theme imports
import '../../../core/themes/app_theme.dart' as app_theme;
import '../../providers/theme_provider.dart';

// Models and providers
import '../../../data/models/roadmap_activity_model.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/optimized_providers.dart';

// Components
import 'enhanced_timeline_widget.dart';
import '../v2/components/add_activity_modal.dart';
import '../v2/components/edit_activity_modal.dart';

class DailyRoadmapScreenV3 extends StatefulWidget {
  const DailyRoadmapScreenV3({super.key});

  @override
  State<DailyRoadmapScreenV3> createState() => _DailyRoadmapScreenV3State();
}

class _DailyRoadmapScreenV3State extends State<DailyRoadmapScreenV3>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _dailyGoalController = TextEditingController();
  final TextEditingController _morningNotesController = TextEditingController();

  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeProvider();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    _dailyGoalController.dispose();
    _morningNotesController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeProvider() async {
    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final roadmapProvider = context.read<DailyRoadmapProvider>();

      if (authProvider.currentUser != null) {
        await roadmapProvider.initialize(authProvider.currentUser!.id);
        _updateControllers();
        
        setState(() {
          _isInitialized = true;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _fadeController.forward();
            _slideController.forward();
          }
        });
      }
    } catch (e) {
      debugPrint('Error inicializando DailyRoadmapScreenV3: $e');
    }
  }

  void _updateControllers() {
    final provider = context.read<DailyRoadmapProvider>();
    _dailyGoalController.text = provider.currentRoadmap?.dailyGoal ?? '';
    _morningNotesController.text = provider.currentRoadmap?.morningNotes ?? '';
  }

  // Helper method removed - now using themeProvider.currentColors directly

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isInitialized) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return _buildLoadingScreen(themeProvider);
        },
      );
    }

    return Consumer2<DailyRoadmapProvider, ThemeProvider>(
      builder: (context, provider, themeProvider, child) {
        final theme = themeProvider.currentColors;
        return Scaffold(
          backgroundColor: theme.primaryBg,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryBg,
                  theme.secondaryBg.withValues(alpha: 0.8),
                  theme.gradientHeader[0].withValues(alpha: 0.1),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: RefreshIndicator(
                        onRefresh: () => _handleRefresh(provider),
                        color: theme.gradientHeader[0],
                        backgroundColor: theme.surface,
                        strokeWidth: 3,
                        child: _buildMainContent(provider, themeProvider),
                      ),
                    ),
                  ),
                ),
                _buildFloatingActionButton(provider, themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen(ThemeProvider theme) {
    return Scaffold(
      backgroundColor: theme.primaryBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryBg,
              theme.secondaryBg.withValues(alpha: 0.8),
              theme.gradientHeader[0].withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: theme.gradientHeader),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.map_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Preparando tu roadmap...',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.gradientHeader[0]),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(DailyRoadmapProvider provider, ThemeProvider theme) {
    return Column(
      children: [
        _buildHeader(provider, theme),
        const SizedBox(height: 12),
        _buildDateSelector(provider, theme),
        const SizedBox(height: 12),
        _buildProgressIndicator(provider, theme),
        const SizedBox(height: 12),
        Expanded(
          child: _buildTimelineView(provider, theme),
        ),
      ],
    );
  }

  Widget _buildHeader(DailyRoadmapProvider provider, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: theme.gradientHeader),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.map_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: theme.gradientHeader,
                      ).createShader(bounds),
                      child: Text(
                        'Roadmap Diario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Planifica tu día hora por hora',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildOptionsButton(theme),
            ],
          ),
          if (provider.error != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(provider.error!, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(DailyRoadmapProvider provider, ThemeProvider theme) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 3));
          final isSelected = _isSameDay(date, provider.selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => _selectDate(provider, date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(colors: theme.gradientHeader)
                    : null,
                color: !isSelected ? theme.surface : null,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: theme.accentPrimary, width: 2)
                    : Border.all(
                        color: theme.borderColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.gradientHeader[0].withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: theme.gradientHeader[0].withValues(alpha: 0.2),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                          spreadRadius: 4,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : theme.accentPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? Colors.white.withValues(alpha: 0.5) : theme.accentPrimary.withValues(alpha: 0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(DailyRoadmapProvider provider, ThemeProvider theme) {
    final progress = provider.completionPercentage / 100;
    final isFullyCompleted = progress >= 1.0 && provider.totalActivities > 0;
    
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.borderColor.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso del día',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: theme.gradientHeader),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.completedActivities}/${provider.totalActivities}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    height: 8,
                    width: MediaQuery.of(context).size.width * 0.8 * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: theme.gradientHeader,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: progress > 0 ? [
                        BoxShadow(
                          color: theme.gradientHeader[0].withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ] : null,
                    ),
                    child: progress > 0.8 ? _buildProgressShimmer(theme) : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${provider.completionPercentage.toInt()}% completado',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (isFullyCompleted)
          Positioned.fill(
            child: _buildCelebrationOverlay(theme),
          ),
      ],
    );
  }

  Widget _buildCelebrationOverlay(ThemeProvider theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.gradientHeader[0].withValues(
                alpha: 0.3 + (_pulseAnimation.value - 0.95) * 2,
              ),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.gradientHeader[0].withValues(
                  alpha: 0.3 + (_pulseAnimation.value - 0.95) * 2,
                ),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: const Text(
                    '🎉',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¡Día completado!',
                  style: TextStyle(
                    color: theme.gradientHeader[0],
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineView(DailyRoadmapProvider provider, ThemeProvider theme) {
    return EnhancedTimelineWidget(
      provider: provider,
      onAddActivity: (hour, minute) => _showAddActivityModal(provider, hour, minute),
      onActivityTap: (activity) => _showActivityDetailsModal(provider, activity),
      onHourTap: (hour) => _handleHourTap(provider, hour),
    );
  }

  Widget _buildFloatingActionButton(DailyRoadmapProvider provider, ThemeProvider theme) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini FAB para agregar actividad rápida
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_pulseAnimation.value - 0.95) * 2,
                child: FloatingActionButton(
                  heroTag: "quick_add_fab",
                  mini: true,
                  onPressed: () => _showQuickAddModal(provider),
                  backgroundColor: theme.accentSecondary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add, size: 20),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          
          // FAB principal mejorado
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: GestureDetector(
                  onTapDown: (_) {
                    _scaleController.forward();
                    HapticFeedback.lightImpact();
                  },
                  onTapUp: (_) => _scaleController.reverse(),
                  onTapCancel: () => _scaleController.reverse(),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: theme.gradientButton),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.gradientButton[0].withValues(alpha: 0.6),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: theme.gradientButton[0].withValues(alpha: 0.3),
                                blurRadius: 40,
                                offset: const Offset(0, 12),
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showEnhancedAddActivityModal(provider),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.event_available,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Programar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsButton(ThemeProvider theme) {
    return IconButton(
      onPressed: () => _showOptionsModal(theme),
      icon: Icon(
        Icons.more_horiz,
        color: theme.textSecondary.withValues(alpha: 0.7),
        size: 28,
      ),
    );
  }

  Widget _buildErrorMessage(String errorText, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.negativeLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.negativeMain.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.negativeMain,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorText,
              style: TextStyle(
                color: theme.negativeMain,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressShimmer(ThemeProvider theme) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _shimmerAnimation.value * 2, 0.0),
              end: Alignment(1.0 + _shimmerAnimation.value * 2, 0.0),
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      },
    );
  }

  // ============================================================================
  // MODALES Y DIÁLOGOS
  // ============================================================================

  void _showAddActivityModal(DailyRoadmapProvider provider, int hour, int minute) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddActivityModal(
        provider: provider,
        initialHour: hour,
        initialMinute: minute,
      ),
    );
  }

  void _showActivityDetailsModal(DailyRoadmapProvider provider, RoadmapActivityModel activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditActivityModal(
        provider: provider,
        activity: activity,
      ),
    );
  }

  void _showOptionsModal(ThemeProvider theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionsModal(theme: theme),
    );
  }

  void _showActivitySummaryModal(DailyRoadmapProvider provider, RoadmapActivityModel activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivitySummaryModal(
        activity: activity,
        theme: Provider.of<ThemeProvider>(context, listen: false),
        provider: provider,
      ),
    );
  }

  void _showActivitySelectorModal(DailyRoadmapProvider provider, List<RoadmapActivityModel> activities, bool isPast) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivitySelectorModal(
        activities: activities,
        theme: Provider.of<ThemeProvider>(context, listen: false),
        isPast: isPast,
        onActivityTap: (activity) {
          Navigator.pop(context);
          if (isPast) {
            _showActivitySummaryModal(provider, activity);
          } else {
            _showActivityDetailsModal(provider, activity);
          }
        },
      ),
    );
  }

  void _showQuickAddModal(DailyRoadmapProvider provider) {
    final now = DateTime.now();
    _showAddActivityModal(provider, now.hour, now.minute);
  }

  void _showEnhancedAddActivityModal(DailyRoadmapProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnhancedAddActivityModal(
        provider: provider,
        theme: Provider.of<ThemeProvider>(context, listen: false),
      ),
    );
  }

  // ============================================================================
  // FUNCIONES DE INTERACCIÓN
  // ============================================================================

  void _handleHourTap(DailyRoadmapProvider provider, int hour) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final activities = provider.activitiesByTime
        .where((activity) => activity.hour == hour)
        .toList();

    if (activities.isEmpty) {
      // No hay actividades, mostrar modal para crear nueva
      _showAddActivityModal(provider, hour, 0);
    } else if (activities.length == 1) {
      // Solo una actividad, mostrar modal apropiado
      final activity = activities.first;
      if (hour < currentHour) {
        // Hora pasada - mostrar resumen
        _showActivitySummaryModal(provider, activity);
      } else {
        // Hora futura o actual - mostrar edición
        _showActivityDetailsModal(provider, activity);
      }
    } else {
      // Múltiples actividades, mostrar selector
      _showActivitySelectorModal(provider, activities, hour < currentHour);
    }
  }

  Future<void> _handleRefresh(DailyRoadmapProvider provider) async {
    HapticFeedback.mediumImpact();
    
    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      if (authProvider.currentUser != null) {
        await provider.loadRoadmapForDate(authProvider.currentUser!.id, provider.selectedDate);
        _updateControllers();
      }
    } catch (e) {
      debugPrint('Error al refrescar roadmap: $e');
    }
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  void _selectDate(DailyRoadmapProvider provider, DateTime date) {
    if (!_isSameDay(date, provider.selectedDate)) {
      HapticFeedback.lightImpact();
      provider.changeSelectedDate(date);
      _updateControllers();
      
      _fadeController.reset();
      _slideController.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fadeController.forward();
          _slideController.forward();
        }
      });
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _getDayName(DateTime date) {
    const days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    return days[date.weekday % 7];
  }
}

// ============================================================================
// MODAL DE OPCIONES CON SOPORTE DE TEMA
// ============================================================================

class _OptionsModal extends StatelessWidget {
  final ThemeProvider theme;
  
  const _OptionsModal({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: theme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Opciones del Roadmap',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildOptionItem(
                  icon: Icons.edit_outlined,
                  title: 'Editar objetivo diario',
                  subtitle: 'Cambia tu meta para hoy',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
                _buildOptionItem(
                  icon: Icons.history,
                  title: 'Ver historial',
                  subtitle: 'Revisa roadmaps anteriores',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
                _buildOptionItem(
                  icon: Icons.share_outlined,
                  title: 'Compartir roadmap',
                  subtitle: 'Comparte tu planificación',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: theme.gradientHeader),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODAL DE RESUMEN DE ACTIVIDAD (PARA MOMENTOS PASADOS)
// ============================================================================

class _ActivitySummaryModal extends StatelessWidget {
  final RoadmapActivityModel activity;
  final ThemeProvider theme;
  final DailyRoadmapProvider provider;
  
  const _ActivitySummaryModal({
    required this.activity,
    required this.theme,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: theme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: activity.isCompleted 
                    ? [theme.positiveMain, theme.positiveMain.withValues(alpha: 0.8)]
                    : [theme.negativeMain, theme.negativeMain.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    activity.isCompleted ? Icons.check_circle : Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.isCompleted ? 'Actividad Completada' : 'Actividad No Completada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        activity.timeString,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  _buildSummarySection(
                    'Actividad',
                    activity.title,
                    Icons.event,
                  ),
                  
                  if (activity.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    _buildSummarySection(
                      'Descripción',
                      activity.description!,
                      Icons.description,
                    ),
                  ],
                  
                  if (activity.category?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    _buildSummarySection(
                      'Categoría',
                      activity.category!,
                      Icons.category,
                    ),
                  ],
                  
                  if (activity.estimatedDuration != null) ...[
                    const SizedBox(height: 24),
                    _buildSummarySection(
                      'Duración Estimada',
                      '${activity.estimatedDuration} minutos',
                      Icons.timer,
                    ),
                  ],
                  
                  if (activity.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    _buildSummarySection(
                      'Notas',
                      activity.notes!,
                      Icons.note,
                    ),
                  ],
                  
                  if (activity.feelingsNotes?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    _buildSummarySection(
                      'Sentimientos',
                      activity.feelingsNotes!,
                      Icons.mood,
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Status summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: activity.isCompleted 
                          ? theme.positiveLight
                          : theme.negativeLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: activity.isCompleted 
                            ? theme.positiveMain.withValues(alpha: 0.3)
                            : theme.negativeMain.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          activity.isCompleted ? Icons.celebration : Icons.info_outline,
                          color: activity.isCompleted ? theme.positiveMain : theme.negativeMain,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activity.isCompleted 
                              ? '¡Excelente trabajo! Completaste esta actividad.'
                              : 'Esta actividad no se completó a tiempo.',
                          style: TextStyle(
                            color: activity.isCompleted ? theme.positiveMain : theme.negativeMain,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Close button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: theme.accentPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MODAL SELECTOR DE ACTIVIDADES (PARA HORAS CON MÚLTIPLES ACTIVIDADES)
// ============================================================================

class _ActivitySelectorModal extends StatelessWidget {
  final List<RoadmapActivityModel> activities;
  final ThemeProvider theme;
  final bool isPast;
  final Function(RoadmapActivityModel) onActivityTap;
  
  const _ActivitySelectorModal({
    required this.activities,
    required this.theme,
    required this.isPast,
    required this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: theme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: theme.gradientHeader),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPast ? Icons.history : Icons.schedule,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actividades de esta hora',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${activities.length} actividades ${isPast ? 'completadas' : 'programadas'}',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Activities list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildActivityItem(activity),
                );
              },
            ),
          ),
          
          // Close button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.accentPrimary,
                  side: BorderSide(color: theme.accentPrimary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(RoadmapActivityModel activity) {
    return GestureDetector(
      onTap: () => onActivityTap(activity),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: activity.isCompleted 
                    ? theme.positiveMain
                    : theme.accentPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            
            // Activity content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (activity.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      activity.description!,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Time and arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activity.timeString,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  isPast ? Icons.summarize : Icons.edit,
                  color: theme.accentPrimary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODAL MEJORADO PARA AGREGAR NUEVA ACTIVIDAD
// ============================================================================

class _EnhancedAddActivityModal extends StatefulWidget {
  final DailyRoadmapProvider provider;
  final ThemeProvider theme;

  const _EnhancedAddActivityModal({
    required this.provider,
    required this.theme,
  });

  @override
  State<_EnhancedAddActivityModal> createState() => _EnhancedAddActivityModalState();
}

class _EnhancedAddActivityModalState extends State<_EnhancedAddActivityModal>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  
  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = 0;
  int _estimatedDuration = 60;
  ActivityPriority _selectedPriority = ActivityPriority.medium;
  
  final List<String> _quickCategories = [
    'Trabajo', 'Personal', 'Ejercicio', 'Comida', 'Descanso', 'Social', 'Estudio', 'Hogar'
  ];
  
  final List<String> _quickTitles = [
    'Reunión', 'Llamada', 'Ejercicio', 'Almuerzo', 'Descanso', 'Estudio', 'Revisar emails'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: widget.theme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: widget.theme.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.theme.shadowColor.withValues(alpha: widget.theme.isDark ? 0.2 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
            if (!widget.theme.isDark)
              BoxShadow(
                color: widget.theme.borderColor.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: widget.theme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.theme.gradientHeader),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nueva Actividad',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Programa tu próxima actividad',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick titles
                    _buildQuickSection(
                      'Títulos Rápidos',
                      Icons.flash_on,
                      _quickTitles,
                      (title) => _titleController.text = title,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title input
                    _buildInputField(
                      'Título de la actividad',
                      _titleController,
                      Icons.event,
                      'ej. Reunión con equipo',
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description input
                    _buildInputField(
                      'Descripción (opcional)',
                      _descriptionController,
                      Icons.description,
                      'ej. Revisar avances del proyecto',
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Time picker
                    _buildTimeSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Quick categories
                    _buildQuickSection(
                      'Categorías',
                      Icons.category,
                      _quickCategories,
                      (category) => _categoryController.text = category,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Category input
                    _buildInputField(
                      'Categoría (opcional)',
                      _categoryController,
                      Icons.folder,
                      'ej. Trabajo, Personal',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Duration and priority
                    Row(
                      children: [
                        Expanded(child: _buildDurationSection()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPrioritySection()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.theme.accentPrimary,
                        side: BorderSide(color: widget.theme.accentPrimary, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canSave() ? _saveActivity : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.theme.accentPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Programar Actividad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSection(String title, IconData icon, List<String> items, Function(String) onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: widget.theme.accentPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: widget.theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _buildQuickChip(item, onTap)).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickChip(String text, Function(String) onTap) {
    return GestureDetector(
      onTap: () {
        onTap(text);
        setState(() {});
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.theme.isDark 
              ? widget.theme.surfaceVariant
              : widget.theme.surfaceVariant.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.theme.borderColor.withValues(alpha: widget.theme.isDark ? 0.3 : 0.5),
          ),
          boxShadow: widget.theme.isDark ? null : [
            BoxShadow(
              color: widget.theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: widget.theme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: widget.theme.accentPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: widget.theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: widget.theme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: widget.theme.textHint),
            filled: true,
            fillColor: widget.theme.isDark 
                ? widget.theme.surfaceVariant
                : widget.theme.surfaceVariant.withValues(alpha: 0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.theme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.theme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.theme.accentPrimary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              color: widget.theme.accentPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Hora programada',
              style: TextStyle(
                color: widget.theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTimePickerButton(
                'Hora',
                '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                _showTimePicker,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePickerButton(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.theme.isDark 
              ? widget.theme.surfaceVariant
              : widget.theme.surfaceVariant.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.theme.borderColor.withValues(alpha: widget.theme.isDark ? 0.3 : 0.6),
          ),
          boxShadow: widget.theme.isDark ? null : [
            BoxShadow(
              color: widget.theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: widget.theme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: widget.theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duración (min)',
          style: TextStyle(
            color: widget.theme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.theme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.theme.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButton<int>(
            value: _estimatedDuration,
            underline: Container(),
            isExpanded: true,
            dropdownColor: widget.theme.surface,
            style: TextStyle(color: widget.theme.textPrimary),
            items: [15, 30, 45, 60, 90, 120, 180].map((duration) {
              return DropdownMenuItem<int>(
                value: duration,
                child: Text('$duration min'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _estimatedDuration = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioridad',
          style: TextStyle(
            color: widget.theme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.theme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.theme.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButton<ActivityPriority>(
            value: _selectedPriority,
            underline: Container(),
            isExpanded: true,
            dropdownColor: widget.theme.surface,
            style: TextStyle(color: widget.theme.textPrimary),
            items: ActivityPriority.values.map((priority) {
              return DropdownMenuItem<ActivityPriority>(
                value: priority,
                child: Text(_getPriorityLabel(priority)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPriority = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.theme.accentPrimary,
              onPrimary: Colors.white,
              surface: widget.theme.surface,
              onSurface: widget.theme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedMinute = picked.minute;
      });
    }
  }

  bool _canSave() {
    return _titleController.text.trim().isNotEmpty;
  }

  Future<void> _saveActivity() async {
    if (!_canSave()) return;

    final success = await widget.provider.addActivity(
      title: _titleController.text.trim(),
      hour: _selectedHour,
      minute: _selectedMinute,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      category: _categoryController.text.trim().isEmpty 
          ? null 
          : _categoryController.text.trim(),
      estimatedDuration: _estimatedDuration,
    );

    if (success && mounted) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Actividad programada para las ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}'),
          backgroundColor: widget.theme.positiveMain,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getPriorityLabel(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.low:
        return 'Baja';
      case ActivityPriority.medium:
        return 'Media';
      case ActivityPriority.high:
        return 'Alta';
      case ActivityPriority.urgent:
        return 'Urgente';
    }
  }
}