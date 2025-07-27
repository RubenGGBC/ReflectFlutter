// ============================================================================
// calendar_screen_v2.dart - CALENDARIO CON ESTILO VISUAL MEJORADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Pantallas relacionadas
import 'daily_detail_screen_v2.dart';
import 'daily_review_screen_v2.dart';

// Sistema de colores
import 'components/minimal_colors.dart';

class CalendarScreenV2 extends StatefulWidget {
  const CalendarScreenV2({super.key});

  @override
  State<CalendarScreenV2> createState() => _CalendarScreenV2State();
}

class _CalendarScreenV2State extends State<CalendarScreenV2>
    with TickerProviderStateMixin {

  // ============================================================================
  // ESTADO Y CONTROLADORES
  // ============================================================================

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  late AnimationController _headerController;
  late AnimationController _calendarController;
  late AnimationController _statsController;
  late AnimationController _pulseController;
  
  late Animation<double> _pulseAnimation;

  // Estado de vista
  bool _showYearView = false;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _calendarController.dispose();
    _statsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ============================================================================
  // CONFIGURACIÓN
  // ============================================================================

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _calendarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Iniciar animaciones
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _calendarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _statsController.forward();
    });
    _pulseController.repeat(reverse: true);
  }

  void _loadData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id);
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id, days: 365);
    }
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildNavigationControls(),
            Expanded(
              child: _showYearView ? _buildYearView() : _buildMonthView(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MinimalColors.backgroundCard(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MinimalColors.textMuted(context).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: MinimalColors.textPrimary(context),
                  size: 18,
                ),
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
                      'Mi Calendario',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _showYearView
                        ? 'Año $_selectedYear'
                        : _getMonthYearText(_focusedMonth),
                    style: TextStyle(
                      fontSize: 16,
                      color: MinimalColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            _buildViewToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousPeriod,
            icon: Icon(
              Icons.chevron_left, 
              color: MinimalColors.textPrimary(context), 
              size: 32
            ),
          ),
          GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MinimalColors.textMuted(context).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                _showYearView
                    ? '$_selectedYear'
                    : _getMonthYearText(_focusedMonth),
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _nextPeriod,
            icon: Icon(
              Icons.chevron_right, 
              color: MinimalColors.textPrimary(context), 
              size: 32
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value * 0.02),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showYearView = !_showYearView;
              });
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.accentGradient(context),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _showYearView ? Icons.calendar_month : Icons.calendar_view_month,
                color: MinimalColors.textPrimary(context),
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // VISTA DE MES
  // ============================================================================

  Widget _buildMonthView() {
    return Consumer2<OptimizedDailyEntriesProvider, OptimizedAnalyticsProvider>(
      builder: (context, entriesProvider, analyticsProvider, child) {
        return FadeTransition(
          opacity: _calendarController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMonthStats(entriesProvider),
                const SizedBox(height: 20),
                _buildCalendarGrid(entriesProvider),
                const SizedBox(height: 20),
                _buildSelectedDateInfo(entriesProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthStats(OptimizedDailyEntriesProvider entriesProvider) {
    final monthEntries = entriesProvider.entries.where((entry) {
      return entry.entryDate.year == _focusedMonth.year &&
          entry.entryDate.month == _focusedMonth.month;
    }).toList();

    final avgMood = monthEntries.isNotEmpty
        ? monthEntries.map((e) => e.moodScore ?? 5).reduce((a, b) => a + b) / monthEntries.length
        : 0.0;

    final daysWithReflections = monthEntries.length;
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: MinimalColors.gradientShadow(context, alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Estadísticas del Mes',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildStatCard('📊', 'Promedio', '${avgMood.toStringAsFixed(1)}/10')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('📝', 'Reflexiones', '$daysWithReflections/$daysInMonth')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('🔥', 'Constancia', '${(daysWithReflections/daysInMonth*100).round()}%')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: MinimalColors.accentGradient(context).map((c) => c.withValues(alpha: 0.1)).toList()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(OptimizedDailyEntriesProvider entriesProvider) {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                .map((day) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.lightGradient(context).map((c) => c.withValues(alpha: 0.2)).toList()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ))
                .toList(),
          ),

          const SizedBox(height: 16),

          // Grid de días
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 42, // 6 semanas máximo
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayWeekday + 2;

              if (dayNumber <= 0 || dayNumber > daysInMonth) {
                return const SizedBox(); // Días vacíos
              }

              final dayDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final entry = _getEntryForDate(dayDate, entriesProvider.entries);
              final isSelected = _isSameDay(dayDate, _selectedDate);
              final isToday = _isSameDay(dayDate, DateTime.now());

              return _buildDayCell(dayNumber, entry, isSelected, isToday, dayDate);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int dayNumber, dynamic entry, bool isSelected, bool isToday, DateTime dayDate) {
    Color backgroundColor = Colors.transparent;
    Color borderColor = MinimalColors.textMuted(context).withValues(alpha: 0.3);
    Color textColor = MinimalColors.textSecondary(context);

    if (isSelected) {
      backgroundColor = MinimalColors.accentGradient(context)[0];
      borderColor = MinimalColors.accentGradient(context)[1];
      textColor = Colors.white;
    } else if (isToday) {
      borderColor = MinimalColors.lightGradient(context)[0];
      textColor = MinimalColors.lightGradient(context)[0];
    } else if (entry != null) {
      final moodScore = entry.moodScore ?? 5;
      backgroundColor = _getMoodColor(moodScore).withValues(alpha: 0.3);
      borderColor = _getMoodColor(moodScore);
      textColor = MinimalColors.textPrimary(context);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = dayDate;
        });
        HapticFeedback.lightImpact();

        if (entry != null) {
          _showDayDetail(dayDate);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [
            BoxShadow(
              color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),

            if (entry != null)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getMoodColor(entry.moodScore ?? 5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo(OptimizedDailyEntriesProvider entriesProvider) {
    final entry = _getEntryForDate(_selectedDate, entriesProvider.entries);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: MinimalColors.accentGradient(context)[0],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatSelectedDate(_selectedDate),
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (entry != null) ...[
              _buildEntryPreview(entry),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.visibility,
                      label: 'Ver Detalle',
                      onTap: () => _showDayDetail(_selectedDate),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit,
                      label: 'Editar',
                      onTap: () => _editReflection(_selectedDate),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: MinimalColors.textMuted(context),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin reflexión registrada',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.add,
                      label: 'Crear Reflexión',
                      onTap: () => _createReflection(_selectedDate),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEntryPreview(dynamic entry) {
    final moodScore = entry.moodScore ?? 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getMoodColor(moodScore).withValues(alpha: 0.1),
            _getMoodColor(moodScore).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getMoodColor(moodScore).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMoodColor(moodScore),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${moodScore}/10',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getMoodLabel(moodScore),
                  style: TextStyle(
                    color: _getMoodColor(moodScore),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (entry.freeReflection.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              entry.freeReflection,
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: MinimalColors.textPrimary(context), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // VISTA DE AÑO
  // ============================================================================

  Widget _buildYearView() {
    return Consumer<OptimizedDailyEntriesProvider>(
      builder: (context, entriesProvider, child) {
        return FadeTransition(
          opacity: _calendarController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildYearStats(entriesProvider),
                const SizedBox(height: 20),
                _buildMonthsGrid(entriesProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearStats(OptimizedDailyEntriesProvider entriesProvider) {
    final yearEntries = entriesProvider.entries.where((entry) {
      return entry.entryDate.year == _selectedYear;
    }).toList();

    final avgMood = yearEntries.isNotEmpty
        ? yearEntries.map((e) => e.moodScore ?? 5).reduce((a, b) => a + b) / yearEntries.length
        : 0.0;

    final totalDays = 365;
    final reflectionDays = yearEntries.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Resumen del Año $_selectedYear',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildStatCard('📈', 'Promedio Anual', '${avgMood.toStringAsFixed(1)}/10')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('📅', 'Días Registrados', '$reflectionDays')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('🏆', 'Consistencia', '${(reflectionDays/totalDays*100).round()}%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthsGrid(OptimizedDailyEntriesProvider entriesProvider) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthNumber = index + 1;
        final monthEntries = entriesProvider.entries.where((entry) {
          return entry.entryDate.year == _selectedYear &&
              entry.entryDate.month == monthNumber;
        }).toList();

        final avgMood = monthEntries.isNotEmpty
            ? monthEntries.map((e) => e.moodScore ?? 5).reduce((a, b) => a + b) / monthEntries.length
            : 0.0;

        return GestureDetector(
          onTap: () {
            setState(() {
              _focusedMonth = DateTime(_selectedYear, monthNumber);
              _showYearView = false;
            });
            HapticFeedback.lightImpact();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
              gradient: monthEntries.isNotEmpty
                  ? LinearGradient(
                colors: [
                  _getMoodColor(avgMood.round()).withValues(alpha: 0.1),
                  _getMoodColor(avgMood.round()).withValues(alpha: 0.05),
                ],
              )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  months[index],
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                if (monthEntries.isNotEmpty) ...[
                  Text(
                    '${avgMood.toStringAsFixed(1)}/10',
                    style: TextStyle(
                      color: _getMoodColor(avgMood.round()),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${monthEntries.length} días',
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 10,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.remove_circle_outline,
                    color: MinimalColors.textMuted(context),
                    size: 20,
                  ),
                  Text(
                    'Sin datos',
                    style: TextStyle(
                      color: MinimalColors.textMuted(context),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // FLOATING ACTION BUTTON
  // ============================================================================

  Widget _buildFloatingActionButton() {
    // FIX: Replaced 'children' with 'label' and passed the widget directly.
    return FloatingActionButton.extended(
      onPressed: () => _createReflection(DateTime.now()),
      backgroundColor: Colors.transparent,
      elevation: 0,
      label: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              'Nueva Reflexión',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // LÓGICA DE NEGOCIO Y NAVEGACIÓN
  // ============================================================================

  void _previousPeriod() {
    setState(() {
      if (_showYearView) {
        _selectedYear--;
      } else {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _nextPeriod() {
    setState(() {
      if (_showYearView) {
        _selectedYear++;
      } else {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _showYearView ? DateTime(_selectedYear) : _focusedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: MinimalColors.accentGradient(context)[0],
              surface: MinimalColors.backgroundCard(context),
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: MinimalColors.backgroundSecondary(context),
          ),
          child: child!,
        );
      },
    ).then((date) {
      if (date != null) {
        setState(() {
          if (_showYearView) {
            _selectedYear = date.year;
          } else {
            _focusedMonth = DateTime(date.year, date.month);
          }
        });
      }
    });
  }

  void _showDayDetail(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyDetailScreenV2(date: date),
      ),
    );
  }

  void _editReflection(DateTime date) {
    // FIX: Removed 'date' parameter as DailyReviewScreenV2 does not accept it.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyReviewScreenV2(),
      ),
    );
  }

  void _createReflection(DateTime date) {
    // FIX: Removed 'date' parameter as DailyReviewScreenV2 does not accept it.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyReviewScreenV2(),
      ),
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  dynamic _getEntryForDate(DateTime date, List<dynamic> entries) {
    try {
      return entries.firstWhere(
            (entry) => _isSameDay(entry.entryDate, date),
      );
    } catch (e) {
      return null;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthYearText(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedDate(DateTime date) {
    const weekDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

    final dayName = weekDays[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, ${date.day} de $monthName de ${date.year}';
  }

  Color _getMoodColor(int score) {
    if (score <= 3) return const Color(0xFFef4444);
    if (score <= 5) return const Color(0xFFf59e0b);
    if (score <= 7) return const Color(0xFF3b82f6);
    return const Color(0xFF10b981);
  }

  String _getMoodLabel(int score) {
    if (score <= 3) return 'Día difícil';
    if (score <= 5) return 'Día regular';
    if (score <= 7) return 'Buen día';
    return 'Excelente día';
  }
}
