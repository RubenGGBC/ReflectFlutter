// ============================================================================
// screens/v2/dashboard_screen.dart - NUEVO DASHBOARD CON MÉTRICAS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // You might need to add `fl_chart` to your pubspec.yaml
import '../../providers/auth_provider.dart';
import '../../providers/interactive_moments_provider.dart';
import '../components/modern_design_system.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      context.read<InteractiveMomentsProvider>().loadTodayMoments(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ModernSpacing.md),
          children: [
            _buildHeader(),
            const SizedBox(height: ModernSpacing.lg),
            _buildWeeklyMoodChart(),
            const SizedBox(height: ModernSpacing.lg),
            _buildKeyMetrics(),
            const SizedBox(height: ModernSpacing.lg),
            _buildCategoryBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<AuthProvider>().currentUser;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: ModernColors.primaryGradient.first,
          child: Text(user?.avatarEmoji ?? '🧘', style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: ModernSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido, ${user?.name ?? 'Viajero'}', style: ModernTypography.heading3),
            const Text('Aquí tienes tu resumen emocional', style: ModernTypography.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyMoodChart() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu Semana', style: ModernTypography.heading3),
          const SizedBox(height: ModernSpacing.xl),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(enabled: true),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _getWeekDayTitles,
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _getWeeklyBars(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _getWeekDayTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: ModernColors.textHint, fontWeight: FontWeight.bold, fontSize: 12);
    String text;
    switch (value.toInt()) {
      case 0: text = 'L'; break;
      case 1: text = 'M'; break;
      case 2: text = 'X'; break;
      case 3: text = 'J'; break;
      case 4: text = 'V'; break;
      case 5: text = 'S'; break;
      case 6: text = 'D'; break;
      default: return Container();
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
  }

  List<BarChartGroupData> _getWeeklyBars() {
    // Dummy data - replace with real data from provider
    final weeklyMoods = [5.0, 7.0, 6.0, 8.0, 9.0, 5.0, 7.0];
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyMoods[index],
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(ModernSpacing.radiusSmall),
              topRight: Radius.circular(ModernSpacing.radiusSmall),
            ),
            gradient: LinearGradient(
              colors: [
                ModernColors.primaryGradient.first,
                ModernColors.primaryGradient.last.withOpacity(0.7)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildKeyMetrics() {
    // Dummy data
    const streak = 12;
    const totalMoments = 512;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: ModernSpacing.md,
      crossAxisSpacing: ModernSpacing.md,
      childAspectRatio: 2.0,
      children: [
        _buildMetricCard('Racha Actual', '$streak días', Icons.local_fire_department_outlined, ModernColors.warning),
        _buildMetricCard('Momentos Totales', '$totalMoments', Icons.timeline, ModernColors.info),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return ModernCard(
      padding: const EdgeInsets.all(ModernSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: ModernSpacing.md),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ModernTypography.bodySmall),
              Text(value, style: ModernTypography.heading3),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Desglose de Momentos', style: ModernTypography.heading3),
          const SizedBox(height: ModernSpacing.xl),
          // Dummy data
          _buildCategoryRow("Trabajo", 0.4, ModernColors.info),
          _buildCategoryRow("Personal", 0.3, ModernColors.success),
          _buildCategoryRow("Social", 0.2, ModernColors.warning),
          _buildCategoryRow("Salud", 0.1, ModernColors.error),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String category, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ModernSpacing.md),
      child: Row(
        children: [
          Text(category, style: ModernTypography.bodyLarge),
          const Spacer(),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: ModernColors.glassSurface,
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
            ),
          ),
          const SizedBox(width: ModernSpacing.sm),
          SizedBox(width: 40, child: Text('${(percentage * 100).toInt()}%', style: ModernTypography.bodySmall)),
        ],
      ),
    );
  }
}
