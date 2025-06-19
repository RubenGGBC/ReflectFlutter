// ============================================================================
// home_screen_v2.dart - PANTALLA DE INICIO CON DATOS REALES DEL USUARIO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/interactive_moments_provider.dart';
import '../components/modern_design_system.dart';
import '../../../data/services/database_service.dart';
// Agregar al inicio del archivo:
import '../../providers/analytics_provider.dart';
import '../components/analytics_widgets.dart';


class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // DATOS REALES DEL USUARIO
  Map<String, dynamic> _userStats = {};
  bool _isLoadingStats = true;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadRealUserData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  // CARGAR DATOS REALES DEL USUARIO
  Future<void> _loadRealUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final momentsProvider = Provider.of<InteractiveMomentsProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false); // ✅ NUEVO

    if (authProvider.currentUser?.id == null) return;

    setState(() => _isLoadingStats = true);

    try {
      final userId = authProvider.currentUser!.id!;

      // Cargar datos existentes
      await momentsProvider.loadTodayMoments(userId);
      final stats = await _databaseService.getUserComprehensiveStatistics(userId);

      // ✅ NUEVO: Cargar análisis avanzados
      await analyticsProvider.loadCompleteAnalytics(userId);

      setState(() {
        _userStats = stats;
        _isLoadingStats = false;
      });

    } catch (e) {
      print('Error cargando datos reales: $e');
      setState(() => _isLoadingStats = false);
    }
  }


  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final isLargeScreen = constraints.maxWidth > 900;

              return RefreshIndicator(
                onRefresh: _refreshRealData,
                color: ModernColors.primaryGradient.first,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? ModernSpacing.xl : ModernSpacing.lg),
                      child: _isLoadingStats
                          ? _buildLoadingState(isTablet)
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRealPersonalizedHeader(isTablet),
                          SizedBox(height: isTablet ? ModernSpacing.xxl : ModernSpacing.xl),

                          // ✅ NUEVO: Análisis del día actual
                          CurrentDayAnalysisWidget(isTablet: isTablet),
                          SizedBox(height: isTablet ? ModernSpacing.xl : ModernSpacing.lg),

                          _buildRealTodayInsights(isTablet, isLargeScreen),
                          SizedBox(height: isTablet ? ModernSpacing.xl : ModernSpacing.lg),

                          // ✅ NUEVO: Insights destacados
                          HighlightedInsightsWidget(isTablet: isTablet),
                          SizedBox(height: isTablet ? ModernSpacing.xl : ModernSpacing.lg),

                          // ✅ NUEVO: Progreso de logros y bienestar
                          AchievementProgressWidget(isTablet: isTablet),
                          SizedBox(height: isTablet ? ModernSpacing.xl : ModernSpacing.lg),

                          _buildRealLifetimeStats(isTablet, isLargeScreen),
                          SizedBox(height: isTablet ? ModernSpacing.xl : ModernSpacing.lg),

                          // ✅ NUEVO: Evolución del mood
                          MoodEvolutionWidget(isTablet: isTablet),
                          SizedBox(height: isTablet ? ModernSpacing.xl : ModernSpacing.lg),

                          _buildSmartActions(isTablet, isLargeScreen),
                          SizedBox(height: isTablet ? ModernSpacing.xl : ModernSpacing.lg),

                          _buildRealRecentMomentsTimeline(isTablet),
                          SizedBox(height: isTablet ? ModernSpacing.xl : ModernSpacing.lg),

                          // ✅ NUEVO: Temas dominantes
                          DominantThemesWidget(isTablet: isTablet),
                          SizedBox(height: isTablet ? ModernSpacing.xl : ModernSpacing.lg),

                          // ✅ NUEVO: Recomendaciones prioritarias
                          PriorityRecommendationsWidget(isTablet: isTablet),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildLoadingState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          CircularProgressIndicator(
            color: ModernColors.primaryGradient.first,
          ),
          const SizedBox(height: ModernSpacing.lg),
          Text(
            'Cargando tus datos reales...',
            style: TextStyle(
              color: ModernColors.textSecondary,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealPersonalizedHeader(bool isTablet) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final now = DateTime.now();
        final greeting = _getGreeting(now.hour);

        return Container(
          padding: EdgeInsets.all(isTablet ? ModernSpacing.xl : ModernSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ModernColors.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: ModernColors.primaryGradient.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isTablet ? 70 : 60,
                    height: isTablet ? 70 : 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user?.avatarEmoji ?? '🧘',
                        style: TextStyle(fontSize: isTablet ? 32 : 28),
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? ModernSpacing.lg : ModernSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.name ?? 'Usuario',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getMotivationalMessage(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRealStreakBadge(isTablet),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealStreakBadge(bool isTablet) {
    // Usar datos reales de racha
    final streakDays = _userStats['streak_days'] ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? ModernSpacing.md : ModernSpacing.sm,
        vertical: isTablet ? ModernSpacing.sm : ModernSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
      ),
      child: Column(
        children: [
          Text(
            '🔥',
            style: TextStyle(fontSize: isTablet ? 20 : 16),
          ),
          Text(
            '$streakDays días',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTodayInsights(bool isTablet, bool isLargeScreen) {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, provider, child) {
        final positiveToday = provider.positiveCount;
        final negativeToday = provider.negativeCount;
        final totalToday = provider.totalCount;

        final balancePercentage = totalToday > 0 ? (positiveToday / totalToday) : 0.0;
        final avgMood = _userStats['avg_mood_score'] ?? 5.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu día hasta ahora',
              style: TextStyle(
                color: ModernColors.textPrimary,
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),

            // Grid responsivo de insights REALES
            if (isLargeScreen)
              Row(
                children: [
                  Expanded(child: _buildBalanceCard(balancePercentage, positiveToday, negativeToday, isTablet)),
                  const SizedBox(width: ModernSpacing.lg),
                  Expanded(child: _buildMoodCard(avgMood, isTablet)),
                  const SizedBox(width: ModernSpacing.lg),
                  Expanded(child: _buildMomentsCard(totalToday, isTablet)),
                ],
              )
            else if (isTablet)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildBalanceCard(balancePercentage, positiveToday, negativeToday, isTablet)),
                      const SizedBox(width: ModernSpacing.lg),
                      Expanded(child: _buildMoodCard(avgMood, isTablet)),
                    ],
                  ),
                  const SizedBox(height: ModernSpacing.lg),
                  _buildMomentsCard(totalToday, isTablet),
                ],
              )
            else
              Column(
                children: [
                  _buildBalanceCard(balancePercentage, positiveToday, negativeToday, isTablet),
                  const SizedBox(height: ModernSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildMoodCard(avgMood, isTablet)),
                      const SizedBox(width: ModernSpacing.md),
                      Expanded(child: _buildMomentsCard(totalToday, isTablet)),
                    ],
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard(double balance, int positive, int negative, bool isTablet) {
    final balanceColor = balance >= 0.6 ? ModernColors.success :
    balance >= 0.4 ? ModernColors.warning : ModernColors.error;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.balance,
                color: balanceColor,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: ModernSpacing.sm),
              Text(
                'Balance Hoy',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? ModernSpacing.md : ModernSpacing.sm),
          Text(
            '${(balance * 100).toInt()}%',
            style: TextStyle(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: balanceColor,
            ),
          ),
          const SizedBox(height: ModernSpacing.xs),
          Text(
            '+$positive | -$negative',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: ModernColors.textSecondary,
            ),
          ),
          SizedBox(height: isTablet ? ModernSpacing.md : ModernSpacing.sm),
          LinearProgressIndicator(
            value: balance,
            backgroundColor: ModernColors.glassSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(balanceColor),
            minHeight: isTablet ? 6 : 4,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(double avgMood, bool isTablet) {
    final moodColor = avgMood >= 7 ? ModernColors.success :
    avgMood >= 5 ? ModernColors.warning : ModernColors.error;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sentiment_satisfied_alt,
                color: moodColor,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: ModernSpacing.sm),
              Text(
                'Mood Promedio',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? ModernSpacing.md : ModernSpacing.sm),
          Text(
            '${avgMood.toStringAsFixed(1)}/10',
            style: TextStyle(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: moodColor,
            ),
          ),
          const SizedBox(height: ModernSpacing.xs),
          Text(
            _getMoodDescription(avgMood),
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentsCard(int totalMoments, bool isTablet) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: ModernColors.categories['emocional']!,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: ModernSpacing.sm),
              Text(
                'Momentos Hoy',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? ModernSpacing.md : ModernSpacing.sm),
          Text(
            '$totalMoments',
            style: TextStyle(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: ModernColors.categories['emocional']!,
            ),
          ),
          const SizedBox(height: ModernSpacing.xs),
          Text(
            'registrados',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealLifetimeStats(bool isTablet, bool isLargeScreen) {
    final totalEntries = _userStats['total_entries'] ?? 0;
    final totalMoments = _userStats['total_moments'] ?? 0;
    final totalWords = _userStats['total_words'] ?? 0;
    final entriesThisMonth = _userStats['entries_this_month'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas Generales',
          style: TextStyle(
            color: ModernColors.textPrimary,
            fontSize: isTablet ? 22 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),

        if (isLargeScreen)
          Row(
            children: [
              Expanded(child: _buildStatCard('📝', 'Reflexiones', '$totalEntries', 'entradas totales', isTablet)),
              const SizedBox(width: ModernSpacing.md),
              Expanded(child: _buildStatCard('✨', 'Momentos', '$totalMoments', 'capturados', isTablet)),
              const SizedBox(width: ModernSpacing.md),
              Expanded(child: _buildStatCard('📖', 'Palabras', '$totalWords', 'escritas', isTablet)),
              const SizedBox(width: ModernSpacing.md),
              Expanded(child: _buildStatCard('📅', 'Este Mes', '$entriesThisMonth', 'reflexiones', isTablet)),
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard('📝', 'Reflexiones', '$totalEntries', 'totales', isTablet)),
                  const SizedBox(width: ModernSpacing.md),
                  Expanded(child: _buildStatCard('✨', 'Momentos', '$totalMoments', 'capturados', isTablet)),
                ],
              ),
              const SizedBox(height: ModernSpacing.md),
              Row(
                children: [
                  Expanded(child: _buildStatCard('📖', 'Palabras', '$totalWords', 'escritas', isTablet)),
                  const SizedBox(width: ModernSpacing.md),
                  Expanded(child: _buildStatCard('📅', 'Este Mes', '$entriesThisMonth', 'reflexiones', isTablet)),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String title, String value, String subtitle, bool isTablet) {
    return ModernCard(
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: isTablet ? 28 : 24)),
          SizedBox(height: isTablet ? ModernSpacing.sm : ModernSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartActions(bool isTablet, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: ModernColors.textPrimary,
          ),
        ),
        SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),

        if (isLargeScreen)
          Row(
            children: [
              Expanded(child: _buildActionCard(
                '🎯', 'Añadir Momento', 'Captura cómo te sientes ahora',
                ModernColors.positiveGradient, () => _navigateToMoments(), isTablet,
              )),
              const SizedBox(width: ModernSpacing.lg),
              Expanded(child: _buildActionCard(
                '📝', 'Reflexionar', 'Escribe sobre tu día',
                ModernColors.negativeGradient, () => _navigateToReview(), isTablet,
              )),
              const SizedBox(width: ModernSpacing.lg),
              Expanded(child: _buildActionCard(
                '📊', 'Ver Perfil', 'Revisa tus estadísticas',
                ModernColors.neutralGradient, () => _navigateToProfile(), isTablet,
              )),
            ],
          )
        else
          Column(
            children: [
              _buildActionCard(
                '🎯', 'Añadir Momento', 'Captura cómo te sientes ahora',
                ModernColors.positiveGradient, () => _navigateToMoments(), isTablet,
              ),
              const SizedBox(height: ModernSpacing.md),
              Row(
                children: [
                  Expanded(child: _buildActionCard(
                    '📝', 'Reflexionar', 'Tu día',
                    ModernColors.negativeGradient, () => _navigateToReview(), isTablet,
                  )),
                  const SizedBox(width: ModernSpacing.md),
                  Expanded(child: _buildActionCard(
                    '📊', 'Perfil', 'Estadísticas',
                    ModernColors.neutralGradient, () => _navigateToProfile(), isTablet,
                  )),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionCard(String emoji, String title, String subtitle, List<Color> gradient, VoidCallback onTap, bool isTablet) {
    return ModernCard(
      onTap: onTap,
      gradient: gradient,
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: isTablet ? 32 : 28)),
          SizedBox(height: isTablet ? ModernSpacing.sm : ModernSpacing.xs),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isTablet ? 12 : 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRealRecentMomentsTimeline(bool isTablet) {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, provider, child) {
        final recentMoments = provider.moments.take(5).toList();

        if (recentMoments.isEmpty) {
          return ModernCard(
            child: Center(
              child: Column(
                children: [
                  Text('📝', style: TextStyle(fontSize: isTablet ? 48 : 40)),
                  SizedBox(height: isTablet ? ModernSpacing.md : ModernSpacing.sm),
                  Text(
                    'Aún no hay momentos hoy',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: ModernSpacing.sm),
                  Text(
                    '¡Añade tu primer momento del día!',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Momentos Recientes',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: ModernColors.textPrimary,
              ),
            ),
            SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),
            ModernCard(
              child: Column(
                children: recentMoments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final moment = entry.value;
                  final isLast = index == recentMoments.length - 1;

                  return Column(
                    children: [
                      _buildRealMomentItem(moment, isTablet),
                      if (!isLast)
                        Divider(
                          color: ModernColors.glassSecondary,
                          height: isTablet ? ModernSpacing.lg : ModernSpacing.md,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRealMomentItem(dynamic moment, bool isTablet) {
    final isPositive = moment.type == 'positive';
    final momentEmoji = moment.emoji ?? '🤔';
    final momentText = moment.text ?? 'Momento sin descripción';
    final momentTime = moment.timeStr ?? 'Sin hora';
    final momentIntensity = moment.intensity ?? 5;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? ModernSpacing.sm : ModernSpacing.xs),
      child: Row(
        children: [
          Container(
            width: isTablet ? 50 : 40,
            height: isTablet ? 50 : 40,
            decoration: BoxDecoration(
              color: (isPositive ? ModernColors.success : ModernColors.warning).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPositive ? ModernColors.success : ModernColors.warning,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                momentEmoji,
                style: TextStyle(fontSize: isTablet ? 20 : 16),
              ),
            ),
          ),
          SizedBox(width: isTablet ? ModernSpacing.md : ModernSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  momentText,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$momentTime • Intensidad $momentIntensity/10',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? ModernColors.success : ModernColors.warning,
            size: isTablet ? 20 : 16,
          ),
        ],
      ),
    );
  }

  Widget _buildRealPersonalizedInsights(bool isTablet) {
    final insights = _generateRealPersonalizedInsights();

    return ModernCard(
      gradient: ModernColors.neutralGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.white, size: 24),
              const SizedBox(width: ModernSpacing.sm),
              Text(
                'Insights Personalizados',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: ModernSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight['emoji']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: ModernSpacing.sm),
                Expanded(
                  child: Text(
                    insight['text']!,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // HELPER METHODS CON DATOS REALES
  String _getGreeting(int hour) {
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _getMotivationalMessage() {
    final messages = [
      'Tu bienestar importa ✨',
      'Cada momento cuenta 🌟',
      'Construyendo hábitos positivos 💪',
      'El progreso es un proceso 🚀',
      'Tu mente merece atención 🧠',
    ];
    return messages[DateTime.now().day % messages.length];
  }

  String _getMoodDescription(double avgMood) {
    if (avgMood >= 8) return 'Excelente';
    if (avgMood >= 7) return 'Muy bueno';
    if (avgMood >= 6) return 'Bueno';
    if (avgMood >= 5) return 'Regular';
    if (avgMood >= 4) return 'Bajo';
    return 'Muy bajo';
  }

  List<Map<String, String>> _generateRealPersonalizedInsights() {
    final insights = <Map<String, String>>[];

    final totalEntries = _userStats['total_entries'] ?? 0;
    final streakDays = _userStats['streak_days'] ?? 0;
    final avgMood = _userStats['avg_mood_score'] ?? 5.0;
    final entriesThisMonth = _userStats['entries_this_month'] ?? 0;

    // Insights basados en datos REALES
    if (totalEntries == 0) {
      insights.add({
        'emoji': '🌱',
        'text': 'Bienvenido a ReflectApp. Comienza registrando tus primeros momentos para obtener insights personalizados.'
      });
    } else {
      if (streakDays >= 7) {
        insights.add({
          'emoji': '🔥',
          'text': '¡Increíble! Llevas $streakDays días consecutivos registrando. Tu constancia está construyendo mejores hábitos.'
        });
      } else if (streakDays >= 3) {
        insights.add({
          'emoji': '⭐',
          'text': 'Vas bien con $streakDays días de racha. ¡Sigue así para llegar a una semana completa!'
        });
      }

      if (avgMood >= 7) {
        insights.add({
          'emoji': '😊',
          'text': 'Tu mood promedio de ${avgMood.toStringAsFixed(1)}/10 indica que mantienes una actitud muy positiva.'
        });
      } else if (avgMood < 5) {
        insights.add({
          'emoji': '🤗',
          'text': 'Tu mood promedio está en ${avgMood.toStringAsFixed(1)}/10. Recuerda ser amable contigo mismo en los días difíciles.'
        });
      }

      if (entriesThisMonth >= 10) {
        insights.add({
          'emoji': '📈',
          'text': 'Has creado $entriesThisMonth reflexiones este mes. Tu práctica de autoconocimiento está creciendo.'
        });
      }
    }

    // Insight general siempre presente
    insights.add({
      'emoji': '🧠',
      'text': 'Cada reflexión que escribes fortalece tu inteligencia emocional y autoconciencia.'
    });

    return insights;
  }

  Future<void> _refreshRealData() async {
    await _loadRealUserData();
    // Pequeña pausa para mostrar el refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToMoments() {
    Navigator.pushNamed(context, '/interactive_moments');
  }

  void _navigateToReview() {
    Navigator.pushNamed(context, '/daily_review');
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }
}