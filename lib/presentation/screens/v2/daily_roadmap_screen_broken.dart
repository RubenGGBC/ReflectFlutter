// ============================================================================
// daily_roadmap_screen.dart - PANTALLA PRINCIPAL DEL ROADMAP DIARIO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Models and providers
import '../../../data/models/daily_roadmap_model.dart';
import '../../../data/models/roadmap_activity_model.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/optimized_providers.dart';

// Components
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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _dailyGoalController = TextEditingController();
  final TextEditingController _morningNotesController = TextEditingController();

  bool _isInitialized = false;
  DateTime _selectedDate = DateTime.now();

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
    _scrollController.dispose();
    _dailyGoalController.dispose();
    _morningNotesController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
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

        _fadeController.forward();
        _slideController.forward();
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
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildMainContent(provider),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MinimalColors.primary, MinimalColors.accent],
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
              valueColor: AlwaysStoppedAnimation<Color>(MinimalColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(DailyRoadmapProvider provider) {
    return Column(
      children: [
        _buildHeader(provider),
        const SizedBox(height: 8),
        _buildDateSelector(provider),
        const SizedBox(height: 16),
        _buildProgressIndicator(provider),
        const SizedBox(height: 16),
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
                  color: MinimalColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: MinimalColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roadmap Diario',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Planifica tu día hora por hora',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context).withValues(alpha: 0.8),
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
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? MinimalColors.primary 
                    : MinimalColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: isToday 
                    ? Border.all(color: MinimalColors.accent, width: 2)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: MinimalColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white 
                          : MinimalColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white 
                          : MinimalColors.textPrimary,
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
                        color: isSelected ? Colors.white : MinimalColors.accent,
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
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.border.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso del día',
                style: TextStyle(
                  color: MinimalColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${provider.completedActivities}/${provider.totalActivities}',
                style: TextStyle(
                  color: MinimalColors.primary,
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
                  color: MinimalColors.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 8,
                width: MediaQuery.of(context).size.width * 0.8 * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MinimalColors.primary,
                      MinimalColors.accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.completionPercentage.toInt()}% completado',
            style: TextStyle(
              color: MinimalColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView(DailyRoadmapProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: 24, // 24 horas
        itemBuilder: (context, index) {
          return _buildTimeSlot(provider, index);
        },
      ),
    );
  }

  Widget _buildTimeSlot(DailyRoadmapProvider provider, int hour) {
    final activities = provider.currentRoadmap?.getActivitiesInHour(hour) ?? [];
    final hasActivities = activities.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna de tiempo
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    color: hasActivities 
                        ? MinimalColors.primary 
                        : MinimalColors.textSecondary.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: hasActivities ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 2,
                  height: hasActivities ? 60 : 40,
                  decoration: BoxDecoration(
                    color: hasActivities 
                        ? MinimalColors.primary.withOpacity(0.3)
                        : MinimalColors.border.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Columna de actividades
          Expanded(
            child: hasActivities
                ? Column(
                    children: activities.map((activity) {
                      return _buildActivityCard(provider, activity);
                    }).toList(),
                  )
                : _buildEmptyTimeSlot(provider, hour),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(DailyRoadmapProvider provider, RoadmapActivityModel activity) {
    final isCompleted = activity.isCompleted;
    final isOverdue = activity.isPast && !isCompleted;
    final isInProgress = activity.isInProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCompleted 
            ? MinimalColors.success.withOpacity(0.1)
            : isOverdue 
                ? MinimalColors.error.withOpacity(0.1)
                : isInProgress
                    ? MinimalColors.warning.withOpacity(0.1)
                    : MinimalColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
              ? MinimalColors.success
              : isOverdue 
                  ? MinimalColors.error
                  : isInProgress
                      ? MinimalColors.warning
                      : MinimalColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: () => provider.toggleActivityCompletion(activity.id),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? MinimalColors.success : Colors.transparent,
              border: Border.all(
                color: isCompleted 
                    ? MinimalColors.success 
                    : MinimalColors.textSecondary.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        title: Text(
          activity.title,
          style: TextStyle(
            color: MinimalColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  activity.timeString,
                  style: TextStyle(
                    color: MinimalColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  activity.priority.emoji,
                  style: const TextStyle(fontSize: 12),
                ),
                if (activity.category != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: MinimalColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activity.category!,
                      style: TextStyle(
                        color: MinimalColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (activity.description?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                activity.description!,
                style: TextStyle(
                  color: MinimalColors.textSecondary.withOpacity(0.8),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (activity.plannedMood != null || activity.actualMood != null)
              Text(
                (activity.actualMood ?? activity.plannedMood)!.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.more_vert,
              color: MinimalColors.textSecondary.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
        onTap: () => _showActivityDetailsModal(provider, activity),
      ),
    );
  }

  Widget _buildEmptyTimeSlot(DailyRoadmapProvider provider, int hour) {
    return GestureDetector(
      onTap: () => _showAddActivityModal(provider, hour, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: MinimalColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: MinimalColors.border.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: MinimalColors.textSecondary.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Agregar actividad',
                style: TextStyle(
                  color: MinimalColors.textSecondary.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(DailyRoadmapProvider provider) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddActivityModal(provider, DateTime.now().hour, 0),
      backgroundColor: MinimalColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text(
        'Actividad',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildOptionsButton() {
    return IconButton(
      onPressed: () => _showOptionsModal(),
      icon: Icon(
        Icons.more_horiz,
        color: MinimalColors.textSecondary.withOpacity(0.7),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MinimalColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: MinimalColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: MinimalColors.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: MinimalColors.error,
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
      builder: (context) => _AddActivityModal(
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
      builder: (context) => _ActivityDetailsModal(
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
  // UTILIDADES
  // ============================================================================

  void _selectDate(DailyRoadmapProvider provider, DateTime date) {
    if (!_isSameDay(date, provider.selectedDate)) {
      provider.changeSelectedDate(date);
      _updateControllers();
      HapticFeedback.lightImpact();
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

class _AddActivityModal extends StatelessWidget {
  final DailyRoadmapProvider provider;
  final int initialHour;
  final int initialMinute;

  const _AddActivityModal({
    required this.provider,
    required this.initialHour,
    required this.initialMinute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: MinimalColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text(
          'Modal para agregar actividad\n(Implementación pendiente)',
          textAlign: TextAlign.center,
          style: TextStyle(color: MinimalColors.textPrimary),
        ),
      ),
    );
  }
}

class _ActivityDetailsModal extends StatelessWidget {
  final DailyRoadmapProvider provider;
  final RoadmapActivityModel activity;

  const _ActivityDetailsModal({
    required this.provider,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: MinimalColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Text(
          'Modal de detalles de actividad: ${activity.title}\n(Implementación pendiente)',
          textAlign: TextAlign.center,
          style: const TextStyle(color: MinimalColors.textPrimary),
        ),
      ),
    );
  }
}

class _OptionsModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: MinimalColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text(
          'Modal de opciones\n(Implementación pendiente)',
          textAlign: TextAlign.center,
          style: TextStyle(color: MinimalColors.textPrimary),
        ),
      ),
    );
  }
}