// ============================================================================
// daily_detail_screen_v2.dart - VERSIÓN CORREGIDA SIN ERRORES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;

import '../../providers/auth_provider.dart';
import '../components/modern_design_system.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/daily_entry_model.dart';

class DailyDetailScreenV2 extends StatefulWidget {
  final DateTime selectedDate;

  const DailyDetailScreenV2({
    super.key,
    required this.selectedDate,
  });

  @override
  State<DailyDetailScreenV2> createState() => _DailyDetailScreenV2State();
}

class _DailyDetailScreenV2State extends State<DailyDetailScreenV2>
    with TickerProviderStateMixin {
  final Logger _logger = Logger();
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  // 🎭 CONTROLADORES DE ANIMACIÓN
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _fabController;
  late AnimationController _parallaxController;

  // 🎨 ANIMACIONES
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _parallaxAnimation;

  // 📊 DATOS
  bool _isLoading = true;
  DailyEntryModel? _dayEntry;
  List<Map<String, dynamic>> _timeline = [];
  Map<String, dynamic>? _dayData;

  // 🎯 ESTADO UI
  bool _isHeaderExpanded = true;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _loadDayData();
  }

  void _initializeAnimations() {
    // 🎬 Header animations
    _headerController = AnimationController(
      duration: ModernAnimations.ultraSlow,
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: ModernAnimations.elasticOut),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: ModernAnimations.bounceOut));

    // 🎬 Content animations
    _contentController = AnimationController(
      duration: ModernAnimations.slow,
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: ModernAnimations.smoothOut),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: ModernAnimations.smoothOut));

    // 🎬 FAB animations
    _fabController = AnimationController(
      duration: ModernAnimations.medium,
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: ModernAnimations.elasticOut),
    );

    // 🎬 Parallax
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _parallaxAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_parallaxController);

    // 🚀 Secuencia de inicio
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _fabController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final progress = (_scrollController.offset / 200).clamp(0.0, 1.0);
      setState(() {
        _scrollProgress = progress;
        _isHeaderExpanded = progress < 0.5;
      });

      _parallaxController.animateTo(progress);
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _fabController.dispose();
    _parallaxController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: Stack(
        children: [
          // 🌌 FONDO ANIMATED
          _buildAnimatedBackground(),

          // 📜 CONTENIDO PRINCIPAL
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAnimatedHeader(),
              _buildContent(),
            ],
          ),

          // 🎯 FAB ANIMADO
          _buildAnimatedFAB(),

          // ⏳ LOADING OVERLAY
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _parallaxAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ModernColors.darkPrimary,
                ModernColors.darkSecondary.withOpacity(0.8),
                ModernColors.darkPrimary,
              ],
              stops: [
                0.0,
                0.5 + (_parallaxAnimation.value * 0.3),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeader() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: _buildBackButton(),
      flexibleSpace: FlexibleSpaceBar(
        background: SlideTransition(
          position: _headerSlideAnimation,
          child: FadeTransition(
            opacity: _headerFadeAnimation,
            child: _buildHeaderContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ModernColors.borderPrimary),
        boxShadow: ModernShadows.glass,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildHeaderContent() {
    final dayName = _getDayName(widget.selectedDate.weekday);
    final monthName = _getMonthName(widget.selectedDate.month);
    final dayStatus = _getDayStatus();
    final statusColor = _getStatusColor();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            statusColor.withOpacity(0.3),
            statusColor.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📅 FECHA HERO
              Hero(
                tag: 'date_${widget.selectedDate.toIso8601String()}',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ModernColors.glassPrimary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ModernColors.borderPrimary),
                  ),
                  child: Text(
                    '$dayName ${widget.selectedDate.day}',
                    style: ModernTypography.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🗓️ MES Y AÑO
              Text(
                '$monthName ${widget.selectedDate.year}',
                style: ModernTypography.bodyLarge.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // 🎭 STATUS DEL DÍA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ModernColors.glassPrimary,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: ModernColors.borderPrimary),
                  boxShadow: ModernShadows.glass,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statusColor, statusColor.withOpacity(0.7)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getStatusEmoji(),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayStatus,
                            style: ModernTypography.heading4.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusDescription(),
                            style: ModernTypography.bodyMedium.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _contentSlideAnimation,
        child: FadeTransition(
          opacity: _contentFadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_dayEntry != null) ...[
                  _buildStatsCard(),
                  const SizedBox(height: 20),
                  _buildReflectionCard(),
                  const SizedBox(height: 20),
                  _buildTagsSection(),
                  if (_timeline.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildTimelineSection(),
                  ],
                ] else ...[
                  _buildEmptyStateCard(),
                ],

                const SizedBox(height: 100), // Espacio para FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    // ✅ CORREGIDO: Usar moodScore que sí existe en el modelo
    final moodScore = _dayEntry?.moodScore ?? 5;

    // ✅ CORREGIDO: Usar datos de la base de datos si están disponibles
    final energyLevel = _dayData?['energy_level'] as int? ?? 5;
    final stressLevel = _dayData?['stress_level'] as int? ?? 5;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ModernColors.borderPrimary),
        boxShadow: ModernShadows.glass,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: ModernColors.accentBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Métricas del día',
                style: ModernTypography.heading4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _buildStatItem('😊', 'Estado', moodScore, 10, ModernColors.success)),
              Expanded(child: _buildStatItem('⚡', 'Energía', energyLevel, 10, ModernColors.warning)),
              Expanded(child: _buildStatItem('😰', 'Estrés', 10 - stressLevel, 10, ModernColors.info)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, int value, int maxValue, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: ModernTypography.bodySmall.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '$value/$maxValue',
          style: ModernTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / maxValue,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ModernColors.borderPrimary),
        boxShadow: ModernShadows.glass,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_outlined, color: ModernColors.accentPurple, size: 24),
              const SizedBox(width: 12),
              Text(
                'Reflexión del día',
                style: ModernTypography.heading4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              _dayEntry?.freeReflection ?? 'Sin reflexión registrada',
              style: ModernTypography.bodyMedium.copyWith(
                // ✅ CORREGIDO: Usar Colors.white con opacity en vez de white90
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    final positiveTags = _dayEntry?.positiveTags ?? [];
    final negativeTags = _dayEntry?.negativeTags ?? [];

    if (positiveTags.isEmpty && negativeTags.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ModernColors.borderPrimary),
        boxShadow: ModernShadows.glass,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, color: ModernColors.accentGreen, size: 24),
              const SizedBox(width: 12),
              Text(
                'Etiquetas del día',
                style: ModernTypography.heading4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (positiveTags.isNotEmpty) ...[
            Text(
              '✨ Aspectos positivos',
              style: ModernTypography.bodyMedium.copyWith(
                color: ModernColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: positiveTags.map((tag) => _buildTag(tag.name, ModernColors.success)).toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (negativeTags.isNotEmpty) ...[
            Text(
              '☁️ Aspectos a mejorar',
              style: ModernTypography.bodyMedium.copyWith(
                color: ModernColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: negativeTags.map((tag) => _buildTag(tag.name, ModernColors.warning)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: ModernTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ModernColors.borderPrimary),
        boxShadow: ModernShadows.glass,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_outlined, color: ModernColors.accentOrange, size: 24),
              const SizedBox(width: 12),
              Text(
                'Timeline del día',
                style: ModernTypography.heading4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ..._timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final moment = entry.value;
            return _buildTimelineItem(moment, index == _timeline.length - 1);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> moment, bool isLast) {
    final text = moment['text'] as String? ?? '';
    final emoji = moment['emoji'] as String? ?? '💭';
    final type = moment['type'] as String? ?? 'neutral';
    final timestamp = moment['timestamp'] as String? ?? '';

    final color = type == 'positive' ? ModernColors.success :
    type == 'negative' ? ModernColors.warning : ModernColors.info;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withOpacity(0.5), Colors.transparent],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (timestamp.isNotEmpty)
                  Text(
                    _formatTimestamp(timestamp),
                    style: ModernTypography.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: ModernTypography.bodyMedium.copyWith(
                    // ✅ CORREGIDO: Usar Colors.white con opacity
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ModernColors.borderPrimary),
        boxShadow: ModernShadows.glass,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ModernColors.accentBlue.withOpacity(0.3), Colors.transparent],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📝', style: TextStyle(fontSize: 32)),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Sin registros',
            style: ModernTypography.heading4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'No hay reflexiones registradas para este día',
            style: ModernTypography.bodyMedium.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/interactive_moments');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernColors.accentBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Agregar reflexión',
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushNamed('/interactive_moments');
          },
          backgroundColor: ModernColors.accentBlue,
          elevation: 8,
          label: Text(
            'Editar día',
            style: ModernTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.darkPrimary.withOpacity(0.9),
            ModernColors.darkSecondary.withOpacity(0.9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ModernColors.glassPrimary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ModernColors.borderPrimary),
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
              'Cargando tu día...',
              style: ModernTypography.bodyLarge.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE DATOS
  // ============================================================================

  Future<void> _loadDayData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    try {
      final userId = authProvider.currentUser!.id!;

      // ✅ CORREGIDO: Cargar datos completos del día
      final dayData = await _databaseService.getDayEntryWithTimeline(userId, widget.selectedDate);

      if (mounted) {
        setState(() {
          if (dayData != null) {
            _dayEntry = dayData['entry'];
            _timeline = List<Map<String, dynamic>>.from(dayData['timeline'] ?? []);
            _dayData = dayData; // ✅ CORREGIDO: Guardar todos los datos
          }
          _isLoading = false;
        });
      }

      _logger.d('📊 Datos cargados para ${widget.selectedDate}: entrada=${_dayEntry != null}');

    } catch (e) {
      _logger.e('❌ Error cargando datos del día: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  String _getDayName(int weekday) {
    const days = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday];
  }

  String _getMonthName(int month) {
    const months = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month];
  }

  String _getDayStatus() {
    if (_dayEntry == null) return 'Sin registro';

    final moodScore = _dayEntry!.moodScore ?? 5;
    if (moodScore >= 8) return 'Día excelente';
    if (moodScore >= 6) return 'Buen día';
    if (moodScore >= 4) return 'Día regular';
    return 'Día difícil';
  }

  Color _getStatusColor() {
    if (_dayEntry == null) return ModernColors.borderPrimary;

    final moodScore = _dayEntry!.moodScore ?? 5;
    if (moodScore >= 8) return ModernColors.success;
    if (moodScore >= 6) return ModernColors.accentGreen;
    if (moodScore >= 4) return ModernColors.warning;
    return ModernColors.error;
  }

  String _getStatusEmoji() {
    if (_dayEntry == null) return '📝';

    final moodScore = _dayEntry!.moodScore ?? 5;
    if (moodScore >= 8) return '✨';
    if (moodScore >= 6) return '😊';
    if (moodScore >= 4) return '😐';
    return '😔';
  }

  String _getStatusDescription() {
    if (_dayEntry == null) return 'No hay datos registrados para este día';

    final positiveTags = _dayEntry!.positiveTags.length;
    final negativeTags = _dayEntry!.negativeTags.length;

    if (positiveTags > negativeTags) {
      return 'Día con más aspectos positivos';
    } else if (negativeTags > positiveTags) {
      return 'Día con algunos retos';
    } else {
      return 'Día balanceado';
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return timestamp;
    }
  }
}