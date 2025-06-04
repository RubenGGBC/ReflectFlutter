// ============================================================================
// presentation/screens/calendar_screen.dart - VERSIÓN SIMPLIFICADA SIN DEPENDENCIAS EXTERNAS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/themed_container.dart';
import '../widgets/themed_button.dart';
import '../../data/services/database_service.dart';
import 'daily_detail_screen.dart';

enum CalendarView {
  months,
  days,
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  final Logger _logger = Logger();
  final DatabaseService _databaseService = DatabaseService();

  CalendarView _currentView = CalendarView.months;
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  Map<int, Map<String, int>> _monthsData = {};
  Map<int, Map<String, dynamic>> _daysData = {};
  bool _isLoading = false;

  // Animation Controllers simplificados
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadYearData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    if (authProvider.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.currentColors.primaryBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(context, themeProvider),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(themeProvider)
                  : _currentView == CalendarView.months
                  ? _buildMonthsView(themeProvider)
                  : _buildDaysView(themeProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.currentColors.accentPrimary,
            themeProvider.currentColors.accentSecondary,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.currentColors.accentPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Botón volver
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/interactive_moments'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('Momentos', style: TextStyle(color: Colors.white)),
                  ),

                  Expanded(
                    child: Text(
                      _currentView == CalendarView.months
                          ? '📅 Tu Año Zen'
                          : '🗓️ Días de ${_getMonthName(_selectedMonth ?? 1)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Botón perfil
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/profile'),
                    icon: const Icon(Icons.person, color: Colors.white),
                    label: const Text('Perfil', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Estadísticas del año
              _buildYearStats(themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearStats(ThemeProvider themeProvider) {
    final totalEntries = _monthsData.values.fold<int>(
      0, (sum, month) => sum + (month['total'] ?? 0),
    );

    final totalPositive = _monthsData.values.fold<int>(
      0, (sum, month) => sum + (month['positive'] ?? 0),
    );

    final totalNegative = _monthsData.values.fold<int>(
      0, (sum, month) => sum + (month['negative'] ?? 0),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatBubble('Total', totalEntries.toString(), Colors.white),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          _buildStatBubble('Positivos', totalPositive.toString(), themeProvider.currentColors.positiveMain),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          _buildStatBubble('Difíciles', totalNegative.toString(), themeProvider.currentColors.negativeMain),
        ],
      ),
    );
  }

  Widget _buildStatBubble(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: themeProvider.currentColors.accentPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: themeProvider.currentColors.accentPrimary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando tu historia zen...',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.currentColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthsView(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Selector de año
          _buildYearSelector(themeProvider),
          const SizedBox(height: 30),

          // Grid de meses
          _buildMonthsGrid(themeProvider),
          const SizedBox(height: 30),

          // Leyenda
          _buildLegend(themeProvider),
        ],
      ),
    );
  }

  Widget _buildYearSelector(ThemeProvider themeProvider) {
    return ThemedContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _changeYear(-1),
            icon: Icon(
              Icons.chevron_left,
              color: themeProvider.currentColors.accentPrimary,
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  _selectedYear.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.accentPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Tu año de reflexiones',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => _changeYear(1),
            icon: Icon(
              Icons.chevron_right,
              color: themeProvider.currentColors.accentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthsGrid(ThemeProvider themeProvider) {
    final monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Column(
      children: List.generate(4, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: List.generate(3, (colIndex) {
              final monthIndex = rowIndex * 3 + colIndex + 1;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildMonthCard(
                    monthIndex,
                    monthNames[monthIndex - 1],
                    themeProvider,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildMonthCard(int monthNum, String monthName, ThemeProvider themeProvider) {
    final monthData = _monthsData[monthNum] ?? {'positive': 0, 'negative': 0, 'total': 0};
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final isCurrent = monthNum == currentMonth && _selectedYear == currentYear;

    final positive = monthData['positive'] ?? 0;
    final negative = monthData['negative'] ?? 0;
    final total = monthData['total'] ?? 0;

    Color primaryColor;
    String statusEmoji;

    if (total == 0) {
      primaryColor = themeProvider.currentColors.surfaceVariant;
      statusEmoji = '○';
    } else if (positive > negative) {
      primaryColor = themeProvider.currentColors.positiveMain;
      statusEmoji = '✨';
    } else if (negative > positive) {
      primaryColor = themeProvider.currentColors.negativeMain;
      statusEmoji = '☁️';
    } else {
      primaryColor = themeProvider.currentColors.accentPrimary;
      statusEmoji = '⚖️';
    }

    return GestureDetector(
      onTap: () => _selectMonth(monthNum),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: isCurrent
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(statusEmoji, style: const TextStyle(fontSize: 16)),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'HOY',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              Text(
                monthName.substring(0, 3).toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              Column(
                children: [
                  Text(
                    total.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  if (total > 0)
                    Text(
                      '+$positive  -$negative',
                      style: TextStyle(
                        fontSize: 9,
                        color: themeProvider.currentColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysView(ThemeProvider themeProvider) {
    if (_selectedMonth == null) return const SizedBox();

    final monthNames = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header del mes
          _buildMonthHeader(monthNames[_selectedMonth!], themeProvider),
          const SizedBox(height: 20),

          // Calendario de días
          _buildDaysCalendar(themeProvider),
          const SizedBox(height: 30),

          // Leyenda
          _buildLegend(themeProvider),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String monthName, ThemeProvider themeProvider) {
    return ThemedContainer(
      child: Row(
        children: [
          ThemedButton(
            onPressed: _goToMonthsView,
            type: ThemedButtonType.outlined,
            child: const Text('← Meses'),
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  '$monthName $_selectedYear',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Días de reflexión',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildDaysCalendar(ThemeProvider themeProvider) {
    if (_selectedMonth == null) return const SizedBox();

    // Días de la semana
    final weekdaysRow = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: themeProvider.currentColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.currentColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((day) {
          return Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.accentPrimary,
            ),
          );
        }).toList(),
      ),
    );

    // Calcular días del mes
    final firstDay = DateTime(_selectedYear, _selectedMonth!, 1);
    final lastDay = DateTime(_selectedYear, _selectedMonth! + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = (firstDay.weekday - 1) % 7;

    // Crear grid de días
    final weeks = <List<int?>>[];
    var currentWeek = <int?>[...List.filled(firstWeekday, null)];

    for (int day = 1; day <= daysInMonth; day++) {
      currentWeek.add(day);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = <int?>[];
      }
    }

    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    return Column(
      children: [
        weekdaysRow,
        ...weeks.map((week) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: week.map((day) {
                if (day == null) {
                  return Expanded(child: Container(height: 50));
                }

                return Expanded(
                  child: _buildDayCell(day, themeProvider),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDayCell(int day, ThemeProvider themeProvider) {
    final dayData = _daysData[day] ?? {'positive': 0, 'negative': 0, 'submitted': false};
    final isToday = _isCurrentDay(day);
    final isFuture = _isFutureDay(day);
    final hasData = dayData['submitted'] == true;

    final positive = dayData['positive'] as int? ?? 0;
    final negative = dayData['negative'] as int? ?? 0;
    final total = positive + negative;

    Color primaryColor;
    String statusEmoji = '';

    if (isFuture) {
      primaryColor = themeProvider.currentColors.surface;
      statusEmoji = '○';
    } else if (isToday && !hasData) {
      primaryColor = themeProvider.currentColors.accentSecondary;
      statusEmoji = '⭐';
    } else if (hasData && total > 0) {
      if (positive > negative) {
        primaryColor = themeProvider.currentColors.positiveMain;
        statusEmoji = '✨';
      } else if (negative > positive) {
        primaryColor = themeProvider.currentColors.negativeMain;
        statusEmoji = '☁️';
      } else {
        primaryColor = themeProvider.currentColors.accentPrimary;
        statusEmoji = '⚖️';
      }
    } else {
      primaryColor = themeProvider.currentColors.surfaceVariant;
      statusEmoji = '○';
    }

    return GestureDetector(
      onTap: isFuture ? null : () => _onDayTap(day),
      child: Container(
        width: 45,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(color: primaryColor, width: 2)
              : Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (statusEmoji.isNotEmpty)
              Text(statusEmoji, style: const TextStyle(fontSize: 10)),
            Text(
              day.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isFuture
                    ? themeProvider.currentColors.textHint
                    : themeProvider.currentColors.textPrimary,
              ),
            ),
            if (total > 0)
              Text(
                '$total',
                style: TextStyle(
                  fontSize: 8,
                  color: primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeProvider themeProvider) {
    return ThemedContainer(
      child: Column(
        children: [
          Text(
            'Leyenda:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('✨', 'Días positivos', themeProvider.currentColors.positiveMain),
              _buildLegendItem('☁️', 'Días difíciles', themeProvider.currentColors.negativeMain),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('⭐', 'Día actual', themeProvider.currentColors.accentSecondary),
              _buildLegendItem('○', 'Sin actividad', themeProvider.currentColors.surfaceVariant),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String emoji, String label, Color color) {
    final themeProvider = context.read<ThemeProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 8)),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: themeProvider.currentColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // MÉTODOS DE NEGOCIO
  // ============================================================================

  Future<void> _loadYearData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final yearData = await _databaseService.getYearSummary(
        authProvider.currentUser!.id!,
        _selectedYear,
      );

      setState(() {
        _monthsData = yearData;
        _isLoading = false;
      });

    } catch (e) {
      _logger.e('Error cargando datos del año: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMonthData(int month) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final monthData = await _databaseService.getMonthSummary(
        authProvider.currentUser!.id!,
        _selectedYear,
        month,
      );

      setState(() {
        _daysData = monthData;
        _isLoading = false;
      });

    } catch (e) {
      _logger.e('Error cargando datos del mes: $e');
      setState(() => _isLoading = false);
    }
  }

  void _changeYear(int direction) {
    setState(() {
      _selectedYear += direction;
    });
    _loadYearData();
  }

  void _selectMonth(int month) {
    setState(() {
      _selectedMonth = month;
      _currentView = CalendarView.days;
    });
    _loadMonthData(month);
  }

  void _goToMonthsView() {
    setState(() {
      _selectedMonth = null;
      _currentView = CalendarView.months;
    });
  }

  void _onDayTap(int day) {
    if (_isFutureDay(day)) return;

    if (_isCurrentDay(day)) {
      Navigator.of(context).pushReplacementNamed('/interactive_moments');
    } else {
      _viewPastDay(day);
    }
  }

  void _viewPastDay(int day) {
    if (_selectedMonth == null) return;

    final selectedDate = DateTime(_selectedYear, _selectedMonth!, day);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyDetailScreen(selectedDate: selectedDate),
      ),
    );
  }

  bool _isCurrentDay(int day) {
    if (_selectedMonth == null) return false;

    final today = DateTime.now();
    return _selectedYear == today.year &&
        _selectedMonth == today.month &&
        day == today.day;
  }

  bool _isFutureDay(int day) {
    if (_selectedMonth == null) return false;

    final today = DateTime.now();
    final checkDate = DateTime(_selectedYear, _selectedMonth!, day);
    return checkDate.isAfter(today);
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month];
  }
}