// lib/presentation/screens/v2/activities_screen.dart
// ============================================================================
// ACTIVITIES SCREEN FOR MANAGING DAILY ACTIVITIES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_activities_provider.dart';
import '../../../data/models/daily_activity_model.dart';
import 'components/minimal_colors.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: MinimalColors.textPrimary(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Actividades Diarias',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: MinimalColors.primaryGradient(context)[0],
          labelColor: MinimalColors.textPrimary(context),
          unselectedLabelColor: MinimalColors.textSecondary(context),
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Pendientes'),
            Tab(text: 'Completadas'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<DailyActivitiesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${provider.error}',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.clearError(),
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildCustomScrollView(provider, provider.activities),
                _buildCustomScrollView(provider, provider.pendingActivities),
                _buildCustomScrollView(provider, provider.completedActivities),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressStats(DailyActivitiesProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            blurRadius: 8,
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
                'Progreso del Día',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${provider.completedCount}/${provider.totalActivities}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: provider.completionPercentage / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.completionPercentage.toStringAsFixed(0)}% completado',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomScrollView(DailyActivitiesProvider provider, List<DailyActivity> activities) {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: MinimalColors.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay actividades',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        // Progress Stats - Now scrollable
        _buildProgressStats(provider),
        // Activity List
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: activities.map((activity) => _buildActivityCard(activity)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(DailyActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activity.isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: activity.isCompleted
                ? Colors.green.withValues(alpha: 0.2)
                : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              activity.emoji,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          activity.title,
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: activity.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              activity.description,
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activity.category,
                    style: TextStyle(
                      color: MinimalColors.primaryGradient(context)[0],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  activity.durationText,
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (activity.isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
            if (activity.isCompleted && activity.completionNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activity.completionNotes!,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: activity.isCompleted
            ? IconButton(
                icon: Icon(
                  Icons.undo,
                  color: Colors.orange,
                ),
                onPressed: () => _showUndoDialog(activity),
              )
            : IconButton(
                icon: Icon(
                  Icons.check_circle_outline,
                  color: MinimalColors.primaryGradient(context)[0],
                ),
                onPressed: () => _showCompleteDialog(activity),
              ),
      ),
    );
  }

  void _showCompleteDialog(DailyActivity activity) {
    final notesController = TextEditingController();
    int rating = 3;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalColors.backgroundCard(context),
        title: Text(
          'Completar Actividad',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Completaste "${activity.title}"?',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Calificación (1-5):',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  children: List.generate(5, (index) {
                    final isSelected = index < rating;
                    return GestureDetector(
                      onTap: () => setState(() => rating = index + 1),
                      child: Icon(
                        Icons.star,
                        color: isSelected ? Colors.amber : Colors.grey,
                        size: 28,
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
              ),
              decoration: InputDecoration(
                hintText: 'Agregar notas (opcional)...',
                hintStyle: TextStyle(
                  color: MinimalColors.textSecondary(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: MinimalColors.primaryGradient(context)[0],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Provider.of<DailyActivitiesProvider>(context, listen: false)
                  .completeActivity(
                activity.id,
                notes: notesController.text.trim().isNotEmpty
                    ? notesController.text.trim()
                    : null,
                rating: rating,
              );
              Navigator.pop(context);
              _showSuccessSnackBar('¡Actividad completada!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MinimalColors.primaryGradient(context)[0],
              foregroundColor: Colors.white,
            ),
            child: Text('Completar'),
          ),
        ],
      ),
    );
  }

  void _showUndoDialog(DailyActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalColors.backgroundCard(context),
        title: Text(
          'Deshacer Completado',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Quieres marcar "${activity.title}" como no completada?',
          style: TextStyle(
            color: MinimalColors.textSecondary(context),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Provider.of<DailyActivitiesProvider>(context, listen: false)
                  .undoActivityCompletion(activity.id);
              Navigator.pop(context);
              _showSuccessSnackBar('Actividad marcada como pendiente');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Deshacer'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}