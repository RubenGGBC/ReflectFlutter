// ============================================================================
// presentation/screens/v2/analytics_screen_optimized.dart
// PANTALLA DE ANÁLISIS OPTIMIZADA CON ALGORITMOS AVANZADOS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// Providers
import '../../providers/optimized_providers.dart';

// Modelos
import '../../../data/models/analytics_models.dart';

// ============================================================================
// PALETA DE COLORES MINIMALISTA (CONSISTENTE CON EL RESTO DE LA APP)
// ============================================================================
class AnalyticsColors {
  // Fondo principal - Negro profundo
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundCard = Color(0xFF0F0F0F);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);
  static const Color backgroundTertiary = Color(0xFF2A2A2A);

  // Gradientes Azul Oscuro a Morado
  static const List<Color> primaryGradient = [
    Color(0xFF1e3a8a), // Azul oscuro
    Color(0xFF581c87), // Morado oscuro
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3b82f6), // Azul
    Color(0xFF8b5cf6), // Morado
  ];

  static const List<Color> lightGradient = [
    Color(0xFF60a5fa), // Azul claro
    Color(0xFFa855f7), // Morado claro
  ];

  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3FFFFFF);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradientes específicos para métricas
  static const List<Color> positiveGradient = [Color(0xFF10b981), Color(0xFF34d399)];
  static const List<Color> neutralGradient = [Color(0xFFf59e0b), Color(0xFFfbbf24)];
  static const List<Color> negativeGradient = [Color(0xFFef4444), Color(0xFFf87171)];
  static const List<Color> warningGradient = [Color(0xFFf97316), Color(0xFFfb923c)];
}

class AnalyticsScreenOptimized extends StatefulWidget {
  const AnalyticsScreenOptimized({super.key});

  @override
  State<AnalyticsScreenOptimized> createState() => _AnalyticsScreenOptimizedState();
}

class _AnalyticsScreenOptimizedState extends State<AnalyticsScreenOptimized>
    with TickerProviderStateMixin {

  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAnalytics();
  }

  void _setupAnimations() {
    _tabController = TabController(length: 5, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  void _loadAnalytics() async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProviderOptimized>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      await analyticsProvider.generarAnalisisCompleto(user.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnalyticsColors.backgroundPrimary,
      body: SafeArea(
        child: Consumer<AnalyticsProviderOptimized>(
          builder: (context, analyticsProvider, child) {
            if (analyticsProvider.isLoading) {
              return _buildLoadingScreen();
            }

            if (analyticsProvider.error != null) {
              return _buildErrorScreen(analyticsProvider.error!);
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildModernHeader(),
                  const SizedBox(height: 20),
                  _buildTabBar(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildResumenTab(analyticsProvider),
                        _buildPrediccionTab(analyticsProvider),
                        _buildRutinasTab(analyticsProvider),
                        _buildAnsiedadTab(analyticsProvider),
                        _buildMomentosTab(analyticsProvider),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER MODERNO
  // ============================================================================

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AnalyticsColors.primaryGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.primaryGradient[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AnalyticsColors.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AnalyticsColors.textPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 28,
                  color: AnalyticsColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Análisis Inteligente',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AnalyticsColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Insights avanzados de tu bienestar mental',
                      style: TextStyle(
                        fontSize: 14,
                        color: AnalyticsColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AnalyticsColors.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _loadAnalytics,
                  icon: const Icon(
                    Icons.refresh,
                    color: AnalyticsColors.textPrimary,
                  ),
                  tooltip: 'Actualizar análisis',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB BAR
  // ============================================================================

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: AnalyticsColors.backgroundCard,
        border: Border.all(
          color: AnalyticsColors.textMuted.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: AnalyticsColors.accentGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: AnalyticsColors.accentGradient[0].withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: AnalyticsColors.textPrimary,
        unselectedLabelColor: AnalyticsColors.textTertiary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 12,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
        isScrollable: true,
        tabs: const [
          Tab(text: 'Resumen'),
          Tab(text: 'Predicción'),
          Tab(text: 'Rutinas'),
          Tab(text: 'Ansiedad'),
          Tab(text: 'Momentos'),
        ],
      ),
    );
  }

  // ============================================================================
  // PANTALLA DE CARGA
  // ============================================================================

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AnalyticsColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AnalyticsColors.textMuted.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: AnalyticsColors.accentGradient,
                    ),
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AnalyticsColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Analizando tus datos...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AnalyticsColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aplicando algoritmos avanzados de análisis mental',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AnalyticsColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PANTALLA DE ERROR
  // ============================================================================

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AnalyticsColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AnalyticsColors.negativeGradient[0].withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AnalyticsColors.negativeGradient,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: AnalyticsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Error en el análisis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AnalyticsColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadAnalytics,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnalyticsColors.accentGradient[0],
                  foregroundColor: AnalyticsColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER PARA CREAR CARDS MODERNOS
  // ============================================================================

  Widget _buildModernCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    List<Color>? gradientColors,
    Color? backgroundColor,
    bool addGlow = false,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AnalyticsColors.backgroundCard,
        gradient: gradientColors != null ? LinearGradient(colors: gradientColors) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.textMuted.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          if (addGlow && gradientColors != null)
            BoxShadow(
              color: gradientColors[0].withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================================
  // TAB RESUMEN
  // ============================================================================

  Widget _buildResumenTab(AnalyticsProviderOptimized provider) {
    final resumen = provider.resumenCompleto;
    if (resumen == null) return _buildNoDataWidget();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreBienestarCard(resumen.scoreBienestarGeneral),
          _buildMetricasGeneralesCard(resumen.metricasGenerales),
          if (resumen.alertas.isNotEmpty) _buildAlertasCard(resumen.alertas),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB PREDICCIÓN
  // ============================================================================

  Widget _buildPrediccionTab(AnalyticsProviderOptimized provider) {
    final prediccion = provider.prediccionSemana;
    if (prediccion == null) return _buildNoDataWidget();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrediccionCard(prediccion),
          _buildFactoresInfluenciaCard(prediccion.factoresInfluencia),
          _buildTendenciaCard(prediccion.tendencia, prediccion.estadoAnimoPredicto),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB RUTINAS
  // ============================================================================

  Widget _buildRutinasTab(AnalyticsProviderOptimized provider) {
    final rutinas = provider.analisisRutinas;
    if (rutinas == null) return _buildNoDataWidget();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConsistenciaCard(rutinas.consistenciaGeneral),
          _buildRutinasDetectadasCard(rutinas.rutinasDetectadas),
          _buildSugerenciasRutinaCard(rutinas.sugerencias),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB ANSIEDAD
  // ============================================================================

  Widget _buildAnsiedadTab(AnalyticsProviderOptimized provider) {
    final ansiedad = provider.analisisAnsiedad;
    if (ansiedad == null) return _buildNoDataWidget();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNivelAnsiedadCard(ansiedad.nivelAnsiedadPromedio),
          _buildTriggersCard(ansiedad.triggersDetectados),
          _buildEstrategiasCard(ansiedad.estrategiasRecomendadas),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB MOMENTOS
  // ============================================================================

  Widget _buildMomentosTab(AnalyticsProviderOptimized provider) {
    final momentos = provider.analisisMomentos;
    if (momentos == null) return _buildNoDataWidget();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDistribucionEmocionalCard(momentos.distribucionEmocional),
          _buildIntensidadPromedioCard(momentos.intensidadPromedio),
          _buildRecomendacionesMomentosCard(momentos.recomendaciones),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGETS DE CARDS
  // ============================================================================

  Widget _buildScoreBienestarCard(double score) {
    final scoreColor = _getScoreColor(score);
    final isHighScore = score >= 7.0;
    
    return _buildModernCard(
      gradientColors: isHighScore ? AnalyticsColors.positiveGradient : null,
      addGlow: isHighScore,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology,
                  color: scoreColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Score de Bienestar General',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: score / 10.0,
                    strokeWidth: 12,
                    backgroundColor: AnalyticsColors.backgroundTertiary,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(score * 10).toInt()}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AnalyticsColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'de 100',
                      style: TextStyle(
                        fontSize: 14,
                        color: AnalyticsColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AnalyticsColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scoreColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              _getScoreDescription(score),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricasGeneralesCard(Map<String, dynamic> metricas) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Métricas Generales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMetricaItem('Total de entradas', '${metricas['totalEntradas'] ?? 0}', Icons.edit),
          _buildMetricaItem('Total de momentos', '${metricas['totalMomentos'] ?? 0}', Icons.star),
          _buildMetricaItem('Total de metas', '${metricas['totalMetas'] ?? 0}', Icons.flag),
          _buildMetricaItem('Días consecutivos', '${metricas['diasConsecutivos'] ?? 0}', Icons.timeline),
          _buildMetricaItem('Mood promedio', '${(metricas['promedioMoodScore'] ?? 0.0).toStringAsFixed(1)}', Icons.mood),
        ],
      ),
    );
  }

  Widget _buildMetricaItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.textMuted.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AnalyticsColors.lightGradient,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AnalyticsColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertasCard(List<String> alertas) {
    return _buildModernCard(
      gradientColors: AnalyticsColors.negativeGradient,
      addGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AnalyticsColors.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Alertas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...alertas.map((alerta) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AnalyticsColors.textPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AnalyticsColors.textPrimary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AnalyticsColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alerta,
                    style: TextStyle(
                      fontSize: 14,
                      color: AnalyticsColors.textPrimary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPrediccionCard(PrediccionEstadoAnimo prediccion) {
    return _buildModernCard(
      gradientColors: AnalyticsColors.accentGradient,
      addGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AnalyticsColors.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Predicción para la Próxima Semana',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPrediccionMetric(
                'Estado de Ánimo',
                prediccion.estadoAnimoPredicto.toStringAsFixed(1),
                Icons.mood,
              ),
              _buildPrediccionMetric(
                'Confianza',
                '${(prediccion.confianza * 100).toInt()}%',
                Icons.analytics,
              ),
              _buildPrediccionMetric(
                'Tendencia',
                prediccion.tendencia,
                Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrediccionMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.textPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.textPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AnalyticsColors.textPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AnalyticsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AnalyticsColors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactoresInfluenciaCard(List<FactorInfluencia> factores) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.lightGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insights,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Factores de Influencia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...factores.take(5).map((factor) => _buildFactorItem(factor)),
        ],
      ),
    );
  }

  Widget _buildFactorItem(FactorInfluencia factor) {
    final impactColor = factor.impacto > 0 
        ? AnalyticsColors.positiveGradient[0]
        : factor.impacto < 0 
            ? AnalyticsColors.negativeGradient[0]
            : AnalyticsColors.textTertiary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: impactColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: impactColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              factor.nombre,
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: impactColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(factor.impacto * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: impactColor,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTendenciaCard(String tendencia, double estadoAnimo) {
    IconData icon;
    List<Color> gradientColors;
    
    switch (tendencia) {
      case 'ascendente':
        icon = Icons.trending_up;
        gradientColors = AnalyticsColors.positiveGradient;
        break;
      case 'descendente':
        icon = Icons.trending_down;
        gradientColors = AnalyticsColors.negativeGradient;
        break;
      default:
        icon = Icons.trending_flat;
        gradientColors = AnalyticsColors.neutralGradient;
    }

    return _buildModernCard(
      gradientColors: gradientColors,
      addGlow: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AnalyticsColors.textPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: AnalyticsColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tendencia ${tendencia.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estado de ánimo predicho: ${estadoAnimo.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    fontSize: 14,
                    color: AnalyticsColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistenciaCard(double consistencia) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Consistencia de Rutinas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AnalyticsColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: consistencia,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.positiveGradient,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(consistencia * 100).toInt()}% de consistencia',
            style: TextStyle(
              fontSize: 14,
              color: AnalyticsColors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRutinasDetectadasCard(List<RutinaDetectada> rutinas) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.lightGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.repeat_outlined,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Rutinas Detectadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (rutinas.isEmpty)
            Text(
              'No se detectaron rutinas consistentes',
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            )
          else
            ...rutinas.take(3).map((rutina) => _buildRutinaItem(rutina)),
        ],
      ),
    );
  }

  Widget _buildRutinaItem(RutinaDetectada rutina) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.textMuted.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rutina.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(rutina.frecuencia * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rutina.descripcion,
            style: TextStyle(
              fontSize: 12,
              color: AnalyticsColors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugerenciasRutinaCard(List<SugerenciaRutina> sugerencias) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.positiveGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sugerencias de Rutinas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (sugerencias.isEmpty)
            Text(
              'No hay sugerencias disponibles',
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            )
          else
            ...sugerencias.take(3).map((sugerencia) => _buildSugerenciaItem(sugerencia)),
        ],
      ),
    );
  }

  Widget _buildSugerenciaItem(SugerenciaRutina sugerencia) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.positiveGradient[0].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.positiveGradient,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sugerencia.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sugerencia.descripcion,
            style: TextStyle(
              fontSize: 12,
              color: AnalyticsColors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNivelAnsiedadCard(double nivel) {
    final ansiedadColor = _getAnsiedadColor(nivel);
    final gradientColors = nivel >= 8 ? AnalyticsColors.negativeGradient : nivel >= 6 ? AnalyticsColors.warningGradient : AnalyticsColors.positiveGradient;
    
    return _buildModernCard(
      gradientColors: nivel >= 6 ? gradientColors : null,
      addGlow: nivel >= 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ansiedadColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  color: ansiedadColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Nivel de Ansiedad Promedio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  nivel.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: ansiedadColor,
                    letterSpacing: -1.5,
                  ),
                ),
                Text(
                  'de 10',
                  style: TextStyle(
                    fontSize: 16,
                    color: AnalyticsColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggersCard(List<TriggerAnsiedad> triggers) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.warningGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Triggers de Ansiedad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (triggers.isEmpty)
            Text(
              'No se detectaron triggers específicos',
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            )
          else
            ...triggers.take(3).map((trigger) => _buildTriggerItem(trigger)),
        ],
      ),
    );
  }

  Widget _buildTriggerItem(TriggerAnsiedad trigger) {
    final triggerColor = _getAnsiedadColor(trigger.intensidadPromedio);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: triggerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: triggerColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trigger.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trigger.categoria,
                  style: TextStyle(
                    fontSize: 12,
                    color: AnalyticsColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: triggerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trigger.intensidadPromedio.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: triggerColor,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstrategiasCard(List<EstrategiaManejo> estrategias) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.positiveGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.healing_outlined,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Estrategias de Manejo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (estrategias.isEmpty)
            Text(
              'No hay estrategias disponibles',
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            )
          else
            ...estrategias.take(3).map((estrategia) => _buildEstrategiaItem(estrategia)),
        ],
      ),
    );
  }

  Widget _buildEstrategiaItem(EstrategiaManejo estrategia) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.positiveGradient[0].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AnalyticsColors.positiveGradient,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star_outline,
              size: 16,
              color: AnalyticsColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estrategia.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  estrategia.descripcion,
                  style: TextStyle(
                    fontSize: 12,
                    color: AnalyticsColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistribucionEmocionalCard(Map<String, double> distribucion) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart_outline,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Distribución Emocional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (distribucion.isEmpty)
            Text(
              'No hay datos de distribución emocional',
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            )
          else
            ...distribucion.entries.map((entry) => _buildDistribucionItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildDistribucionItem(String emocion, double valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.textMuted.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 60,
            decoration: BoxDecoration(
              color: AnalyticsColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: valor,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              emocion,
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Text(
            '${(valor * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensidadPromedioCard(double intensidad) {
    final intensidadColor = intensidad >= 7 ? AnalyticsColors.positiveGradient[0] : intensidad >= 5 ? AnalyticsColors.neutralGradient[0] : AnalyticsColors.negativeGradient[0];
    
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: intensidadColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flash_on_outlined,
                  color: intensidadColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Intensidad Promedio de Momentos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  intensidad.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: intensidadColor,
                    letterSpacing: -1.5,
                  ),
                ),
                Text(
                  'de 10',
                  style: TextStyle(
                    fontSize: 16,
                    color: AnalyticsColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendacionesMomentosCard(List<RecomendacionMomento> recomendaciones) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AnalyticsColors.lightGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tips_and_updates_outlined,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recomendaciones de Momentos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (recomendaciones.isEmpty)
            Text(
              'No hay recomendaciones disponibles',
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
              ),
            )
          else
            ...recomendaciones.take(3).map((recomendacion) => _buildRecomendacionItem(recomendacion)),
        ],
      ),
    );
  }

  Widget _buildRecomendacionItem(RecomendacionMomento recomendacion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.lightGradient[0].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AnalyticsColors.lightGradient,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: AnalyticsColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recomendacion.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recomendacion.descripcion,
                  style: TextStyle(
                    fontSize: 12,
                    color: AnalyticsColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AnalyticsColors.backgroundCard,
              AnalyticsColors.backgroundSecondary,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AnalyticsColors.accentGradient[0].withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AnalyticsColors.accentGradient[0].withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AnalyticsColors.accentGradient,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AnalyticsColors.accentGradient[0].withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.insights,
                size: 40,
                color: AnalyticsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Comienza tu análisis!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AnalyticsColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega entradas diarias y momentos para desbloquear insights poderosos sobre tu bienestar mental',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AnalyticsColors.textSecondary,
                letterSpacing: 0.1,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AnalyticsColors.accentGradient,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AnalyticsColors.accentGradient[0].withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate back to main screen or home to start adding entries
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AnalyticsColors.textPrimary,
                  size: 20,
                ),
                label: const Text(
                  'Agregar Primera Entrada',
                  style: TextStyle(
                    color: AnalyticsColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNoDataFeatureItem('Predicciones IA', Icons.psychology),
                const SizedBox(width: 24),
                _buildNoDataFeatureItem('Análisis Rutinas', Icons.repeat),
                const SizedBox(width: 24),
                _buildNoDataFeatureItem('Control Ansiedad', Icons.healing),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataFeatureItem(String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AnalyticsColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AnalyticsColors.accentGradient[0].withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AnalyticsColors.accentGradient[0],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AnalyticsColors.textTertiary,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  Color _getScoreColor(double score) {
    if (score >= 8) return AnalyticsColors.positiveGradient[0];
    if (score >= 6) return AnalyticsColors.neutralGradient[0];
    if (score >= 4) return AnalyticsColors.warningGradient[0];
    return AnalyticsColors.negativeGradient[0];
  }

  String _getScoreDescription(double score) {
    if (score >= 8) return 'Excelente bienestar mental 🌟';
    if (score >= 6) return 'Buen estado de bienestar 😊';
    if (score >= 4) return 'Bienestar moderado 😐';
    return 'Bienestar bajo - considera buscar apoyo 💜';
  }

  Color _getAnsiedadColor(double nivel) {
    if (nivel >= 8) return AnalyticsColors.negativeGradient[0];
    if (nivel >= 6) return AnalyticsColors.warningGradient[0];
    if (nivel >= 4) return AnalyticsColors.neutralGradient[0];
    return AnalyticsColors.positiveGradient[0];
  }
}