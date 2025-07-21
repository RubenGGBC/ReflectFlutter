// ============================================================================
// daily_roadmap_screen.dart - PANTALLA PRINCIPAL DEL ROADMAP DIARIO CORREGIDA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// Models and providers
import '../../../data/models/roadmap_activity_model.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/optimized_providers.dart';

// Components
import 'components/visual_timeline_widget.dart';
import 'components/add_activity_modal.dart';
import 'components/edit_activity_modal.dart';
import 'components/minimal_colors.dart';

class DailyRoadmapScreen extends StatefulWidget {
  const DailyRoadmapScreen({super.key});

  @override
  State<DailyRoadmapScreen> createState() => _DailyRoadmapScreenState();
}

class _DailyRoadmapScreenState extends State<DailyRoadmapScreen>
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
  bool _isPullToRefreshing = false;

  // Import the consistent colors from home screen v2 and goals screen
  // Using MinimalColors for consistency

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

        // Iniciar animaciones después del primer frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _fadeController.forward();
            _slideController.forward();
          }
        });
      }
    } catch (e) {
      debugPrint('Error inicializando DailyRoadmapScreen: $e');
    }
  }

  void _updateControllers() {
    final provider = context.read<DailyRoadmapProvider>();
    _dailyGoalController.text = provider.currentRoadmap?.dailyGoal ?? '';
    _morningNotesController.text = provider.currentRoadmap?.morningNotes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    return Consumer<DailyRoadmapProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: MinimalColors.backgroundPrimary(context),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MinimalColors.backgroundPrimary(context),
                  MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
                  MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: RefreshIndicator(
                    onRefresh: () => _handleRefresh(provider),
                    color: MinimalColors.primaryGradient(context)[0],
                    backgroundColor: MinimalColors.backgroundCard(context),
                    strokeWidth: 3,
                    child: _buildMainContent(provider),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(provider),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MinimalColors.backgroundPrimary(context),
              MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
              MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Preparando tu roadmap...',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  MinimalColors.primaryGradient(context)[0],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(DailyRoadmapProvider provider) {
    return Column(
      children: [
        // Header fijo - sin scroll
        _buildHeader(provider),
        const SizedBox(height: 8),
        _buildDateSelector(provider),
        const SizedBox(height: 16),
        _buildProgressIndicator(provider),
        const SizedBox(height: 8), // Reducido de 16 a 8
        // Timeline expandible
        Expanded(
          child: _buildTimelineView(provider),
        ),
      ],
    );
  }

  Widget _buildHeader(DailyRoadmapProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: MinimalColors.accentGradient(context),
                      ).createShader(bounds),
                      child: Text(
                        'Roadmap Diario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'Planifica tu día hora por hora',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildOptionsButton(),
            ],
          ),
          if (provider.error != null) ...[
            const SizedBox(height: 12),
            _buildErrorMessage(provider.error!),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(DailyRoadmapProvider provider) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                    : null,
                color: !isSelected ? MinimalColors.backgroundCard(context) : null,
                borderRadius: BorderRadius.circular(16),
                border: isToday 
                    ? Border.all(color: MinimalColors.accentGradient(context)[0], width: 2)
                    : Border.all(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                        width: 1,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : MinimalColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : MinimalColors.accentGradient(context)[0],
                        shape: BoxShape.circle,
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

  Widget _buildProgressIndicator(DailyRoadmapProvider provider) {
    final progress = provider.completionPercentage / 100;
    final isFullyCompleted = progress >= 1.0 && provider.totalActivities > 0;
    
    return Stack(
      children: [
        Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: MinimalColors.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${provider.completedActivities}/${provider.totalActivities}',
                style: TextStyle(
                  color: MinimalColors.primaryGradient(context)[0],
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
                  color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                height: 8,
                width: MediaQuery.of(context).size.width * 0.8 * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  boxShadow: progress > 0 ? [
                    BoxShadow(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: progress > 0.8 ? _buildProgressShimmer() : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.completionPercentage.toInt()}% completado',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
        // Celebration animation overlay
        if (isFullyCompleted)
          Positioned.fill(
            child: _buildCelebrationOverlay(),
          ),
      ],
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(
                alpha: 0.3 + (_pulseAnimation.value - 0.95) * 2,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.primaryGradient(context)[0].withValues(
                  alpha: 0.2 + (_pulseAnimation.value - 0.95) * 1.5,
                ),
                blurRadius: 20,
                spreadRadius: 5,
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
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¡Día completado!',
                  style: TextStyle(
                    color: MinimalColors.primaryGradient(context)[0],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineView(DailyRoadmapProvider provider) {
    return VisualTimelineWidget(
      provider: provider,
      onAddActivity: (hour, minute) => _showAddActivityModal(provider, hour, minute),
      onActivityTap: (activity) => _showActivityDetailsModal(provider, activity),
    );
  }


  Widget _buildFloatingActionButton(DailyRoadmapProvider provider) {
    return AnimatedBuilder(
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
                      gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 12),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () => _showAddActivityModal(provider, DateTime.now().hour, 0),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      heroTag: "add_activity_fab",
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text(
                        'Actividad',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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
    );
  }

  Widget _buildOptionsButton() {
    return IconButton(
      onPressed: () => _showOptionsModal(),
      icon: Icon(
        Icons.more_horiz,
        color: MinimalColors.textSecondary(context).withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildErrorMessage(String errorText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFEF4444),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
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

  void _showOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionsModal(),
    );
  }

  // ============================================================================
  // FUNCIONES DE INTERACCIÓN
  // ============================================================================

  Future<void> _handleRefresh(DailyRoadmapProvider provider) async {
    setState(() {
      _isPullToRefreshing = true;
    });
    
    HapticFeedback.mediumImpact();
    
    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      if (authProvider.currentUser != null) {
        await provider.loadRoadmapForDate(authProvider.currentUser!.id, provider.selectedDate);
        _updateControllers();
      }
    } catch (e) {
      debugPrint('Error al refrescar roadmap: $e');
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isPullToRefreshing = false;
      });
    }
  }

  Widget _buildProgressShimmer() {
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
                Colors.white.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  void _selectDate(DailyRoadmapProvider provider, DateTime date) {
    if (!_isSameDay(date, provider.selectedDate)) {
      HapticFeedback.lightImpact();
      provider.changeSelectedDate(date);
      _updateControllers();
      
      // Reiniciar animaciones suavemente
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
// MODALES AUXILIARES (implementación básica)
// ============================================================================


class _OptionsModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Modal de opciones\n(Implementación pendiente)',
          textAlign: TextAlign.center,
          style: TextStyle(color: MinimalColors.textPrimary(context)),
        ),
      ),
    );
  }
}