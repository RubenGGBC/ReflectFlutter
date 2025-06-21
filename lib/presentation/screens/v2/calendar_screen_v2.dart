// ============================================================================
// calendar_screen_v2.dart - VERSIÓN COMPLETA CON DATOS REALES
// REEMPLAZAR TODO EL ARCHIVO calendar_screen_v2.dart CON ESTE CÓDIGO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../../providers/auth_provider.dart';
import '../components/modern_design_system.dart';
import '../../../data/services/database_service.dart';
import '../daily_detail_screen.dart';

class CalendarScreenV2 extends StatefulWidget {
  const CalendarScreenV2({super.key});

  @override
  State<CalendarScreenV2> createState() => _CalendarScreenV2State();
}

class _CalendarScreenV2State extends State<CalendarScreenV2> with TickerProviderStateMixin {
  final Logger _logger = Logger();
  final DatabaseService _databaseService = DatabaseService();

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  // ✅ NUEVAS VARIABLES PARA DATOS REALES
  Map<int, Map<String, dynamic>> _daysData = {};
  bool _isLoading = false;

  // ✅ ANIMACIONES
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMonthData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ✅ CARGAR DATOS REALES DEL MES
  Future<void> _loadMonthData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser?.id == null) return;

    setState(() => _isLoading = true);

    try {
      _logger.i('📅 Cargando datos del mes: ${_focusedMonth.month}/${_focusedMonth.year}');

      final monthData = await _databaseService.getMonthSummary(
        authProvider.currentUser!.id!,
        _focusedMonth.year,
        _focusedMonth.month,
      );

      setState(() {
        _daysData = monthData;
        _isLoading = false;
      });

      _logger.i('✅ Datos cargados: ${_daysData.length} días con datos');
    } catch (e) {
      _logger.e('❌ Error cargando datos del mes: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarHeader(),
                    const SizedBox(height: 20),
                    _isLoading
                        ? _buildLoadingIndicator()
                        : _buildCalendarGrid(),
                    const SizedBox(height: 20),
                    _buildDayDetails(),
                    const SizedBox(height: 20),
                    _buildLegend(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: ModernColors.darkPrimary,
      elevation: 0,
      pinned: true,
      title: const Text(
        '📅 Tu Calendario Zen',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.today, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedDate = DateTime.now();
              _focusedMonth = DateTime.now();
            });
            _loadMonthData();
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadMonthData,
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    final monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
            _loadMonthData();
          },
        ),
        Column(
          children: [
            Text(
              '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_daysData.length} días con reflexiones',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white, size: 30),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
            _loadMonthData();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Cargando tu calendario...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Días de la semana
          Row(
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                .map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 16),
          // ✅ GRID DE DÍAS CON DATOS REALES
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday;

    List<Widget> dayWidgets = [];

    // Días vacíos al inicio
    for (int i = 1; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // ✅ DÍAS DEL MES CON DATOS REALES
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      dayWidgets.add(_buildDayCell(day, date));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  // ✅ NUEVA FUNCIÓN _buildDayCell CON DATOS REALES
  Widget _buildDayCell(int day, DateTime date) {
    final dayData = _daysData[day];
    final hasData = dayData != null && dayData['submitted'] == true;
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final isFuture = date.isAfter(DateTime.now());

    // ✅ COLORES Y EMOJIS SEGÚN DATOS REALES
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    String emoji = '';

    if (!hasData && !isFuture) {
      // Día sin datos
      backgroundColor = ModernColors.glassSecondary.withOpacity(0.3);
      borderColor = ModernColors.accentBlue;
      textColor = Colors.white60;
    } else if (hasData) {
      // Día con datos - analizar sentimiento
      final positive = (dayData!['positive'] as int?) ?? 0;
      final negative = (dayData['negative'] as int?) ?? 0;
      final worthIt = dayData['worth_it'] as bool?;

      if (positive > negative) {
        // Día positivo
        backgroundColor = ModernColors.success.withOpacity(0.4);
        borderColor = ModernColors.success;
        textColor = ModernColors.success;
        emoji = worthIt == true ? '✨' : '😊';
      } else if (negative > positive) {
        // Día negativo
        backgroundColor = ModernColors.warning.withOpacity(0.4);
        borderColor = ModernColors.warning;
        textColor = ModernColors.warning;
        emoji = '☁️';
      } else {
        // Día balanceado
        backgroundColor = ModernColors.info.withOpacity(0.4);
        borderColor = ModernColors.info;
        textColor = ModernColors.info;
        emoji = '⚖️';
      }
    } else if (isFuture) {
      // Día futuro
      backgroundColor = ModernColors.glassSecondary.withOpacity(0.1);
      borderColor = ModernColors.accentBlue.withOpacity(0.3);
      textColor = Colors.white30;
    } else {
      // Fallback
      backgroundColor = ModernColors.glassSecondary;
      borderColor = ModernColors.accentPurple;
      textColor = Colors.white60;
    }

    // ✅ DESTACAR DÍA SELECCIONADO Y ACTUAL
    if (isSelected) {
      borderColor = ModernColors.accentBlue;
      backgroundColor = ModernColors.accentBlue.withOpacity(0.3);
    }
    if (isToday) {
      borderColor = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        if (hasData || isToday) {
          _navigateToDay(date);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: (isToday || isSelected) ? 2 : 1,
          ),
          boxShadow: hasData ? [
            BoxShadow(
              color: borderColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji del estado
            if (emoji.isNotEmpty) ...[
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 2),
            ],

            // Número del día
            Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontWeight: (isSelected || isToday) ? FontWeight.bold :
                hasData ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),

            // Indicador de actividad
            if (hasData) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],

            // Indicador "HOY"
            if (isToday) ...[
              const SizedBox(height: 1),
              Text(
                'HOY',
                style: TextStyle(
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayDetails() {
    final dayData = _daysData[_selectedDate.day];
    final hasData = dayData != null && dayData['submitted'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Día ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (hasData) ...[
            // Mostrar datos del día
            Row(
              children: [
                Icon(Icons.sentiment_satisfied, color: ModernColors.success, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Momentos positivos: ${dayData!['positive'] ?? 0}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.sentiment_dissatisfied, color: ModernColors.warning, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Momentos negativos: ${dayData['negative'] ?? 0}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () => _navigateToDay(_selectedDate),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.accentBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ver detalles completos'),
            ),
          ] else ...[
            // Sin datos
            const Text(
              'No hay entradas registradas para este día.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),

            if (!_selectedDate.isAfter(DateTime.now()))
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/interactive_moments');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.accentBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Agregar reflexión'),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leyenda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendItem('✨', 'Día muy positivo', ModernColors.success),
          _buildLegendItem('😊', 'Día positivo', ModernColors.success),
          _buildLegendItem('⚖️', 'Día balanceado', ModernColors.info),
          _buildLegendItem('☁️', 'Día con retos', ModernColors.warning),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String emoji, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color.withOpacity(0.4),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _navigateToDay(DateTime selectedDate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyDetailScreen(selectedDate: selectedDate),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}