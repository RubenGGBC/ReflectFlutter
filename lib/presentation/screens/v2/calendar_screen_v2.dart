// ============================================================================
// screens/v2/calendar_screen_v2.dart - CALENDARIO CON DISEÑO MODERNO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../components/modern_design_system.dart';
import '../../../data/services/database_service.dart';

class CalendarScreenV2 extends StatefulWidget {
  const CalendarScreenV2({super.key});

  @override
  State<CalendarScreenV2> createState() => _CalendarScreenV2State();
}

class _CalendarScreenV2State extends State<CalendarScreenV2> with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();

  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  DateTime _focusedMonth = DateTime.now();
  Map<int, Map<String, dynamic>> _daysData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month);
    _pageController = PageController(initialPage: _focusedMonth.month - 1);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthData(_focusedMonth);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadMonthData(DateTime month) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser?.id == null) return;

    setState(() => _isLoading = true);
    final monthData = await _databaseService.getMonthSummary(
      authProvider.currentUser!.id!,
      month.year,
      month.month,
    );
    if (mounted) {
      setState(() {
        _daysData = monthData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              _buildWeekDays(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 12,
                  onPageChanged: (index) {
                    final newMonth = DateTime(_focusedMonth.year, index + 1);
                    setState(() {
                      _focusedMonth = newMonth;
                    });
                    _loadMonthData(newMonth);
                  },
                  itemBuilder: (context, index) {
                    final month = DateTime(_focusedMonth.year, index + 1);
                    return _buildDaysGrid(month);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return Padding(
      padding: const EdgeInsets.all(ModernSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              _pageController.previousPage(
                duration: ModernAnimations.fast,
                curve: Curves.easeInOut,
              );
            },
          ),
          Text(
            '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
            style: ModernTypography.heading2,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () {
              _pageController.nextPage(
                duration: ModernAnimations.fast,
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    final weekDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.lg, vertical: ModernSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) => Text(day, style: ModernTypography.bodySmall)).toList(),
      ),
    );
  }

  Widget _buildDaysGrid(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOffset = (DateUtils.firstDayOffset(month.year, month.month, MaterialLocalizations.of(context)) -1) % 7;

    return GridView.builder(
      padding: const EdgeInsets.all(ModernSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: ModernSpacing.sm,
        mainAxisSpacing: ModernSpacing.sm,
      ),
      itemCount: daysInMonth + firstDayOffset,
      itemBuilder: (context, index) {
        if (index < firstDayOffset) {
          return Container(); // Empty cell
        }
        final day = index - firstDayOffset + 1;
        final dayData = _daysData[day];
        return _buildDayCell(day, dayData);
      },
    );
  }

  Widget _buildDayCell(int day, Map<String, dynamic>? dayData) {
    final hasData = dayData != null && dayData['submitted'] == true;
    Color cellColor = ModernColors.glassSecondary;

    if (hasData) {
      final positive = (dayData['positive'] as int?) ?? 0;
      final negative = (dayData['negative'] as int?) ?? 0;
      if (positive > negative) {
        cellColor = ModernColors.success.withOpacity(0.3);
      } else if (negative > positive) {
        cellColor = ModernColors.warning.withOpacity(0.3);
      } else {
        cellColor = ModernColors.info.withOpacity(0.3);
      }
    }

    return GestureDetector(
      onTap: () {
        // No action on tap as requested
      },
      child: AnimatedContainer(
        duration: ModernAnimations.fast,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: ModernTypography.bodyMedium.copyWith(
              color: hasData ? Colors.white : ModernColors.textHint,
              fontWeight: hasData ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
