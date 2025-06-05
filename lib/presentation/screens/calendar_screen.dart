// ============================================================================
// presentation/screens/calendar_screen.dart - VERSIÓN MEJORADA VISUALMENTE
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;

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

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _glowController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

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

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Trigger animations
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _glowController.dispose();
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
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildEnhancedHeader(context, themeProvider),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState(themeProvider)
                      : SlideTransition(
                    position: _slideAnimation,
                    child: _currentView == CalendarView.months
                        ? _buildMonthsView(themeProvider)
                        : _buildDaysView(themeProvider),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.currentColors.accentPrimary,
            themeProvider.currentColors.accentSecondary,
            themeProvider.currentColors.positiveMain.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.currentColors.accentPrimary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  // Botón volver mejorado
                  _buildGlassButton(
                    '← Momentos',
                        () => Navigator.of(context).pushReplacementNamed('/interactive_moments'),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        // Título con gradiente
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [Colors.white, Colors.white70],
                            ).createShader(bounds);
                          },
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

                        // Subtítulo dinámico
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2 * _glowAnimation.value),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3 * _glowAnimation.value),
                                ),
                              ),
                              child: Text(
                                _getHeaderSubtitle(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Botón de perfil
                  _buildGlassButton(
                    '👤 Perfil',
                        () => Navigator.of(context).pushNamed('/profile'),
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

  Widget _buildGlassButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
              gradient: RadialGradient(
                colors: [
                  themeProvider.currentColors.accentPrimary,
                  themeProvider.currentColors.accentSecondary,
                ],
              ),
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
          // Selector de año mejorado
          _buildEnhancedYearSelector(themeProvider),
          const SizedBox(height: 30),

          // Grid de meses con animaciones
          _buildAnimatedMonthsGrid(themeProvider),
          const SizedBox(height: 30),

          // Leyenda mejorada
          _buildEnhancedLegend(themeProvider),
        ],
      ),
    );
  }

  Widget _buildEnhancedYearSelector(ThemeProvider themeProvider) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.currentColors.surface.withOpacity(0.8),
              themeProvider.currentColors.surfaceVariant.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: themeProvider.currentColors.borderColor.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: themeProvider.currentColors.shadowColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildYearButton(
              '‹',
                  () => _changeYear(-1),
              themeProvider,
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            themeProvider.currentColors.accentPrimary,
                            themeProvider.currentColors.accentSecondary,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        _selectedYear.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
            ),

            _buildYearButton(
              '›',
                  () => _changeYear(1),
              themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearButton(String icon, VoidCallback onTap, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              themeProvider.currentColors.accentPrimary.withOpacity(0.8),
              themeProvider.currentColors.accentSecondary.withOpacity(0.6),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: themeProvider.currentColors.accentPrimary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMonthsGrid(ThemeProvider themeProvider) {
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
              final delay = (rowIndex * 3 + colIndex) * 100;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 600 + delay),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: _buildEnhancedMonthCard(
                            monthIndex,
                            monthNames[monthIndex - 1],
                            themeProvider,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildEnhancedMonthCard(int monthNum, String monthName, ThemeProvider themeProvider) {
    final monthData = _monthsData[monthNum] ?? {'positive': 0, 'negative': 0, 'total': 0};
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final isCurrent = monthNum == currentMonth && _selectedYear == currentYear;

    final positive = monthData['positive'] ?? 0;
    final negative = monthData['negative'] ?? 0;
    final total = monthData['total'] ?? 0;

    Color primaryColor;
    Color secondaryColor;
    String statusEmoji;

    if (total == 0) {
      primaryColor = themeProvider.currentColors.surfaceVariant;
      secondaryColor = themeProvider.currentColors.borderColor;
      statusEmoji = '○';
    } else if (positive > negative) {
      primaryColor = themeProvider.currentColors.positiveMain;
      secondaryColor = themeProvider.currentColors.positiveMain.withOpacity(0.3);
      statusEmoji = '✨';
    } else if (negative > positive) {
      primaryColor = themeProvider.currentColors.negativeMain;
      secondaryColor = themeProvider.currentColors.negativeMain.withOpacity(0.3);
      statusEmoji = '☁️';
    } else {
      primaryColor = themeProvider.currentColors.accentPrimary;
      secondaryColor = themeProvider.currentColors.accentPrimary.withOpacity(0.3);
      statusEmoji = '⚖️';
    }

    return GestureDetector(
      onTap: () => _selectMonth(monthNum),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.9),
              secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: isCurrent
              ? Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 3,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: isCurrent ? 20 : 12,
              offset: const Offset(0, 6),
            ),
            if (isCurrent)
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Efecto de brillo
            if (isCurrent)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.3 * _glowAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header del mes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        statusEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HOY',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Nombre del mes
                  Text(
                    monthName.substring(0, 3).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Estadísticas
                  Column(
                    children: [
                      Text(
                        total.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (total > 0)
                        Text(
                          '+$positive  -$negative',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
          // Header del mes mejorado
          _buildEnhancedMonthHeader(monthNames[_selectedMonth!], themeProvider),
          const SizedBox(height: 20),

          // Calendario de días
          _buildEnhancedDaysCalendar(themeProvider),
          const SizedBox(height: 30),

          // Leyenda
          _buildEnhancedLegend(themeProvider),
        ],
      ),
    );
  }

  Widget _buildEnhancedMonthHeader(String monthName, ThemeProvider themeProvider) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.currentColors.surface.withOpacity(0.8),
              themeProvider.currentColors.surfaceVariant.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: themeProvider.currentColors.borderColor.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: themeProvider.currentColors.shadowColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Botón volver
            GestureDetector(
              onTap: _goToMonthsView,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.currentColors.accentPrimary,
                      themeProvider.currentColors.accentSecondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.currentColors.accentPrimary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  '← Meses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Título central
            Expanded(
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          themeProvider.currentColors.accentPrimary,
                          themeProvider.currentColors.accentSecondary,
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      '$monthName $_selectedYear',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
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

            // Espacio para simetría
            const SizedBox(width: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDaysCalendar(ThemeProvider themeProvider) {
    if (_selectedMonth == null) return const SizedBox();

    // Días de la semana con estilo
    final weekdaysRow = Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: themeProvider.currentColors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.currentColors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((day) {
          return Text(
            day,
            style: TextStyle(
              fontSize: 14,
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
        ...weeks.asMap().entries.map((weekEntry) {
          final weekIndex = weekEntry.key;
          final week = weekEntry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: week.asMap().entries.map((dayEntry) {
                final dayIndex = dayEntry.key;
                final day = dayEntry.value;

                if (day == null) {
                  return Expanded(child: Container(height: 60));
                }

                return Expanded(
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (weekIndex * 7 + dayIndex) * 50),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: _buildEnhancedDayCell(day, themeProvider),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEnhancedDayCell(int day, ThemeProvider themeProvider) {
    final dayData = _daysData[day] ?? {'positive': 0, 'negative': 0, 'submitted': false};
    final isToday = _isCurrentDay(day);
    final isFuture = _isFutureDay(day);
    final hasData = dayData['submitted'] == true;

    final positive = dayData['positive'] as int? ?? 0;
    final negative = dayData['negative'] as int? ?? 0;
    final total = positive + negative;

    Color primaryColor;
    Color secondaryColor;
    String statusEmoji = '';

    if (isFuture) {
      primaryColor = themeProvider.currentColors.surface;
      secondaryColor = themeProvider.currentColors.borderColor;
      statusEmoji = '○';
    } else if (isToday && !hasData) {
      primaryColor = themeProvider.currentColors.accentSecondary;
      secondaryColor = themeProvider.currentColors.accentPrimary;
      statusEmoji = '⭐';
    } else if (hasData && total > 0) {
      if (positive > negative) {
        primaryColor = themeProvider.currentColors.positiveMain;
        secondaryColor = themeProvider.currentColors.positiveMain.withOpacity(0.3);
        statusEmoji = '✨';
      } else if (negative > positive) {
        primaryColor = themeProvider.currentColors.negativeMain;
        secondaryColor = themeProvider.currentColors.negativeMain.withOpacity(0.3);
        statusEmoji = '☁️';
      } else {
        primaryColor = themeProvider.currentColors.accentPrimary;
        secondaryColor = themeProvider.currentColors.accentPrimary.withOpacity(0.3);
        statusEmoji = '⚖️';
      }
    } else {
      primaryColor = themeProvider.currentColors.surfaceVariant;
      secondaryColor = themeProvider.currentColors.borderColor;
      statusEmoji = '○';
    }

    return GestureDetector(
      onTap: isFuture ? null : () => _onDayTap(day),
      child: Container(
        width: 50,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: isToday
              ? Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 2,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: isToday ? 15 : 8,
              offset: const Offset(0, 4),
            ),
            if (isToday)
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (statusEmoji.isNotEmpty)
              Text(
                statusEmoji,
                style: const TextStyle(fontSize: 12),
              ),
            Text(
              day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isFuture || (primaryColor == themeProvider.currentColors.surfaceVariant)
                    ? themeProvider.currentColors.textHint
                    : Colors.white,
              ),
            ),
            if (total > 0)
              Text(
                '$total',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedLegend(ThemeProvider themeProvider) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.currentColors.surface.withOpacity(0.8),
              themeProvider.currentColors.surfaceVariant.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: themeProvider.currentColors.borderColor.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: themeProvider.currentColors.shadowColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('⭐', 'Día actual', themeProvider.currentColors.accentSecondary),
                _buildLegendItem('○', 'Sin actividad', themeProvider.currentColors.surfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String emoji, String label, Color color) {
    final themeProvider = context.read<ThemeProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 10)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: themeProvider.currentColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // MÉTODOS DE NEGOCIO (sin cambios)
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver día $_selectedYear-$_selectedMonth-$day'),
        backgroundColor: context.read<ThemeProvider>().currentColors.accentPrimary,
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

  String _getHeaderSubtitle() {
    if (_currentView == CalendarView.months) {
      final totalEntries = _monthsData.values.fold<int>(
        0, (sum, month) => sum + (month['total'] ?? 0),
      );
      return totalEntries > 0
          ? '$totalEntries momentos registrados'
          : 'Tu viaje de reflexión te espera';
    } else {
      final totalDays = _daysData.length;
      return totalDays > 0
          ? '$totalDays días con actividad'
          : 'Mes por explorar';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month];
  }
}