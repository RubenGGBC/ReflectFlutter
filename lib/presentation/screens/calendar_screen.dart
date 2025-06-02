// ============================================================================
// presentation/screens/calendar_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/themed_container.dart';
import '../widgets/themed_button.dart';
import '../../data/services/database_service.dart';

enum CalendarView {
  months,
  days,
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final Logger _logger = Logger();
  final DatabaseService _databaseService = DatabaseService();

  CalendarView _currentView = CalendarView.months;
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  Map<int, Map<String, int>> _monthsData = {};
  Map<int, Map<String, dynamic>> _daysData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadYearData();
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
      body: Column(
        children: [
          _buildHeader(context, themeProvider),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentView == CalendarView.months
                ? _buildMonthsView(themeProvider)
                : _buildDaysView(themeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    return GradientHeader(
      title: '📅 Calendario Zen',
      leftButton: TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/interactive_moments'),
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white),
            SizedBox(width: 4),
            Text('Volver', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthsView(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header del año con navegación
          _buildYearHeader(themeProvider),

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

  Widget _buildYearHeader(ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ThemedButton(
          onPressed: () => _changeYear(-1),
          width: 50,
          height: 50,
          child: const Icon(Icons.chevron_left, color: Colors.white),
        ),

        Expanded(
          child: Text(
            _selectedYear.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        ThemedButton(
          onPressed: () => _changeYear(1),
          width: 50,
          height: 50,
          child: const Icon(Icons.chevron_right, color: Colors.white),
        ),
      ],
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
            mainAxisAlignment: MainAxisAlignment.center,
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
    final monthColor = _calculateMonthColor(monthData, themeProvider);

    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final isCurrent = monthNum == currentMonth && _selectedYear == currentYear;

    final textColor = monthColor == themeProvider.currentColors.positiveMain ||
        monthColor == themeProvider.currentColors.negativeMain
        ? Colors.white
        : themeProvider.currentColors.textPrimary;

    return GestureDetector(
      onTap: () => _selectMonth(monthNum),
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          color: monthColor,
          borderRadius: BorderRadius.circular(12),
          border: isCurrent ? Border.all(color: themeProvider.currentColors.accentPrimary, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: themeProvider.currentColors.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                monthName.substring(0, 3).toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                monthData['total'].toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '+${monthData['positive']} -${monthData['negative']}',
                style: TextStyle(
                  fontSize: 10,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header del mes
          _buildMonthHeader(monthNames[_selectedMonth!], themeProvider),

          const SizedBox(height: 20),

          // Días de la semana
          _buildWeekdaysHeader(themeProvider),

          const SizedBox(height: 10),

          // Grid de días
          _buildDaysGrid(themeProvider),

          const SizedBox(height: 30),

          // Leyenda
          _buildLegend(themeProvider),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String monthName, ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ThemedButton(
          onPressed: _goToMonthsView,
          width: 100,
          height: 40,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('Meses', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),

        Expanded(
          child: Text(
            '$monthName $_selectedYear',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(width: 100),
      ],
    );
  }

  Widget _buildWeekdaysHeader(ThemeProvider themeProvider) {
    const weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: weekdays.map((day) {
        return SizedBox(
          width: 40,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid(ThemeProvider themeProvider) {
    if (_selectedMonth == null) return const SizedBox();

    // Calcular días del mes
    final firstDay = DateTime(_selectedYear, _selectedMonth!, 1);
    final lastDay = DateTime(_selectedYear, _selectedMonth! + 1, 0);
    final daysInMonth = lastDay.day;

    // Calcular día de la semana del primer día (0 = lunes)
    final firstWeekday = (firstDay.weekday - 1) % 7;

    // Crear lista de días
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
      children: weeks.map((week) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: week.map((day) {
              if (day == null) {
                return const SizedBox(width: 40, height: 40);
              }
              return _buildDayCell(day, themeProvider);
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(int day, ThemeProvider themeProvider) {
    final dayData = _daysData[day] ?? {'positive': 0, 'negative': 0, 'submitted': false};
    final dayColor = _calculateDayColor(dayData, day, themeProvider);

    final isToday = _isCurrentDay(day);
    final isFuture = _isFutureDay(day);

    final textColor = dayColor == themeProvider.currentColors.surface
        ? themeProvider.currentColors.textHint
        : (dayColor == themeProvider.currentColors.positiveMain ||
        dayColor == themeProvider.currentColors.negativeMain)
        ? Colors.white
        : themeProvider.currentColors.textPrimary;

    return GestureDetector(
      onTap: isFuture ? null : () => _onDayTap(day),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: dayColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: themeProvider.currentColors.accentPrimary, width: 2) : null,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(themeProvider.currentColors.positiveMain, 'Positivos'),
              const SizedBox(width: 16),
              _buildLegendItem(themeProvider.currentColors.negativeMain, 'Negativos'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(themeProvider.currentColors.accentSecondary, 'Hoy'),
              const SizedBox(width: 16),
              _buildLegendItem(themeProvider.currentColors.surface, 'Futuros'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    final themeProvider = context.read<ThemeProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
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
      // Ir a Interactive Moments para el día actual
      Navigator.of(context).pushReplacementNamed('/interactive_moments');
    } else {
      // Ver detalles del día pasado
      _viewPastDay(day);
    }
  }

  void _viewPastDay(int day) {
    if (_selectedMonth == null) return;

    // TODO: Implementar navegación a pantalla de detalles del día
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver día $_selectedYear-$_selectedMonth-$day'),
        backgroundColor: context.read<ThemeProvider>().currentColors.accentPrimary,
      ),
    );
  }

  Color _calculateMonthColor(Map<String, int> monthData, ThemeProvider themeProvider) {
    if (monthData['total'] == 0) {
      return themeProvider.currentColors.surfaceVariant;
    }

    if (monthData['positive']! > monthData['negative']!) {
      return themeProvider.currentColors.positiveMain;
    } else if (monthData['negative']! > monthData['positive']!) {
      return themeProvider.currentColors.negativeMain;
    } else {
      return themeProvider.currentColors.surfaceVariant;
    }
  }

  Color _calculateDayColor(Map<String, dynamic> dayData, int day, ThemeProvider themeProvider) {
    // Día futuro
    if (_isFutureDay(day)) {
      return themeProvider.currentColors.surface;
    }

    // Día actual sin submitear
    if (_isCurrentDay(day) && !(dayData['submitted'] ?? false)) {
      return themeProvider.currentColors.accentSecondary;
    }

    // Día con datos
    if (dayData['submitted'] ?? false) {
      final positive = dayData['positive'] as int? ?? 0;
      final negative = dayData['negative'] as int? ?? 0;

      if (positive > negative) {
        return themeProvider.currentColors.positiveMain;
      } else if (negative > positive) {
        return themeProvider.currentColors.negativeMain;
      } else {
        return themeProvider.currentColors.surfaceVariant;
      }
    }

    // Sin datos
    return themeProvider.currentColors.surfaceVariant;
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
}