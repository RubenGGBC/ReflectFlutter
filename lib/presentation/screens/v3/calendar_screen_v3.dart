// ============================================================================
// calendar_screen_v3.dart - CALENDARIO SIMPLIFICADO SIN AI
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

// Core
import '../../../core/themes/app_theme.dart';

// Data Models
import '../../../data/models/daily_entry_model.dart';
import '../../../data/models/goal_model.dart';

// Providers
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/enhanced_goals_provider.dart';

// Screens
import 'daily_detail_screen_v3.dart';
import 'daily_review_screen_v3.dart';

class CalendarScreenV3 extends StatefulWidget {
  const CalendarScreenV3({super.key});

  @override
  State<CalendarScreenV3> createState() => _CalendarScreenV3State();
}

class _CalendarScreenV3State extends State<CalendarScreenV3>
    with TickerProviderStateMixin {

  // ============================================================================
  // ESTADO Y CONTROLADORES
  // ============================================================================

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  final PageController _monthPageController = PageController(initialPage: 1000);

  late AnimationController _headerController;
  late AnimationController _calendarController;
  late AnimationController _statsController;

  late Animation<double> _headerAnimation;
  late Animation<double> _calendarAnimation;
  late Animation<double> _statsAnimation;

  // Estado de vista
  CalendarViewMode _viewMode = CalendarViewMode.month;
  bool _showStatistics = true;
  int _currentMonthPage = 1000;

  // Filtros
  final Set<String> _selectedMetrics = {'mood', 'energy', 'stress'};

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
    _monthPageController.dispose();
    super.dispose();
  }

  // ============================================================================
  // CONFIGURACIÓN
  // ============================================================================

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _calendarController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _calendarAnimation = CurvedAnimation(
      parent: _calendarController,
      curve: Curves.elasticOut,
    );

    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutBack,
    );

    // Iniciar animaciones secuencialmente
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _calendarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _statsController.forward();
    });
  }

  void _loadData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id);
      context.read<EnhancedGoalsProvider>().loadGoals(user.id);
    }
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.currentColors;

    return Scaffold(
      backgroundColor: colors.primaryBg,
      body: Stack(
        children: [
          _buildGradientBackground(colors),
          _buildContent(colors),
        ],
      ),
      floatingActionButton: _buildFAB(colors),
    );
  }

  Widget _buildGradientBackground(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryBg,
            colors.secondaryBg.withValues(alpha: 0.8),
            colors.primaryBg,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(AppColors colors) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(colors),
          _buildViewModeSelector(colors),
          Expanded(
            child: _buildCalendarView(colors),
          ),
          if (_showStatistics) _buildStatisticsPanel(colors),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.glassBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.borderColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: colors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      'Calendario',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getHeaderSubtitle(),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildThemeToggle(colors),
              ],
            ),
            const SizedBox(height: 16),
            _buildMonthNavigation(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(AppColors colors) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
            HapticFeedback.selectionClick();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.glassBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                colors.isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(colors.isDark),
                color: colors.accentPrimary,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthNavigation(AppColors colors) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _previousMonth(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.glassBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.chevron_left,
              color: colors.textPrimary,
              size: 20,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _getMonthYearText(),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _nextMonth(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.glassBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.chevron_right,
              color: colors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeSelector(AppColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _buildViewModeButton(colors, CalendarViewMode.month, 'Mes', Icons.calendar_view_month),
          const Spacer(),
          _buildToggleButton(colors, 'Stats', Icons.analytics, _showStatistics, (value) {
            setState(() => _showStatistics = value);
          }),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(AppColors colors, CalendarViewMode mode, String label, IconData icon) {
    final isSelected = _viewMode == mode;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _viewMode = mode);
          HapticFeedback.selectionClick();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.accentPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : colors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(AppColors colors, String label, IconData icon, bool isSelected, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () {
        onChanged(!isSelected);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? colors.accentSecondary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? colors.accentSecondary : colors.textHint,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildCalendarView(AppColors colors) {
    return FadeTransition(
      opacity: _calendarAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.borderColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildWeekdayHeaders(colors),
            const SizedBox(height: 8),
            Expanded(
              child: _buildMonthGrid(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders(AppColors colors) {
    final weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthGrid(AppColors colors) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    final List<DateTime?> days = [];
    
    // Días del mes anterior
    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final lastDayPrevMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;
    for (int i = firstDayWeekday - 1; i > 0; i--) {
      days.add(DateTime(prevMonth.year, prevMonth.month, lastDayPrevMonth - i + 1));
    }
    
    // Días del mes actual
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    
    // Días del mes siguiente
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    while (days.length < 42) {
      days.add(DateTime(nextMonth.year, nextMonth.month, days.length - daysInMonth - (firstDayWeekday - 1) + 1));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final date = days[index];
        if (date == null) return const SizedBox.shrink();
        
        return _buildCalendarDay(colors, date);
      },
    );
  }

  Widget _buildCalendarDay(AppColors colors, DateTime date) {
    final isCurrentMonth = date.month == _focusedMonth.month;
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, _selectedDate);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        HapticFeedback.selectionClick();
        _showDayDetails(colors, date);
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getDayBackgroundColor(colors, isCurrentMonth, isToday, isSelected),
          borderRadius: BorderRadius.circular(8),
          border: _getDayBorder(colors, isToday, isSelected),
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              color: _getDayTextColor(colors, isCurrentMonth, isToday, isSelected),
              fontSize: 14,
              fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsPanel(AppColors colors) {
    return FadeTransition(
      opacity: _statsAnimation,
      child: Container(
        height: 120,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas del Mes',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<OptimizedDailyEntriesProvider>(
              builder: (context, entriesProvider, child) {
                final entries = entriesProvider.entries;
                final monthEntries = entries.where((entry) => 
                  entry.createdAt.year == _focusedMonth.year && 
                  entry.createdAt.month == _focusedMonth.month
                ).toList();
                
                if (monthEntries.isEmpty) {
                  return Text(
                    'Sin datos para este mes',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                  );
                }
                
                final avgMood = monthEntries.fold<double>(0, (sum, entry) => sum + entry.moodScore) / monthEntries.length;
                final avgEnergy = monthEntries.fold<double>(0, (sum, entry) => sum + entry.energyLevel) / monthEntries.length;
                
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ánimo promedio',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${avgMood.toStringAsFixed(1)}/10',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Energía promedio',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${avgEnergy.toStringAsFixed(1)}/10',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${monthEntries.length} días',
                      style: TextStyle(
                        color: colors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(AppColors colors) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToReview(),
      backgroundColor: colors.accentPrimary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Nueva Entrada'),
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  String _getHeaderSubtitle() {
    return 'Vista mensual';
  }

  String _getMonthYearText() {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  Color _getDayBackgroundColor(AppColors colors, bool isCurrentMonth, bool isToday, bool isSelected) {
    if (isSelected) return colors.accentPrimary.withValues(alpha: 0.2);
    if (isToday) return colors.accentSecondary.withValues(alpha: 0.1);
    if (!isCurrentMonth) return colors.glassBg.withValues(alpha: 0.5);
    return Colors.transparent;
  }

  Border? _getDayBorder(AppColors colors, bool isToday, bool isSelected) {
    if (isSelected) return Border.all(color: colors.accentPrimary, width: 2);
    if (isToday) return Border.all(color: colors.accentSecondary, width: 1);
    return null;
  }

  Color _getDayTextColor(AppColors colors, bool isCurrentMonth, bool isToday, bool isSelected) {
    if (isSelected) return colors.accentPrimary;
    if (isToday) return colors.accentSecondary;
    if (!isCurrentMonth) return colors.textHint;
    return colors.textPrimary;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
    _monthPageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
    _monthPageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  void _showDayDetails(AppColors colors, DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyDetailScreenV3(date: date),
      ),
    );
  }

  void _navigateToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReviewScreenV3(selectedDate: _selectedDate),
      ),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }
}

// ============================================================================
// ENUMS
// ============================================================================

enum CalendarViewMode {
  month,
  week,
  year,
}