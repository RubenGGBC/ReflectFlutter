// lib/presentation/screens/v2/main_navigation_screen_v2.dart
// ✅ COMPLETAMENTE ARREGLADA - UI OVERFLOW CORREGIDO

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Screens optimizadas
import 'home_screen_v2.dart';
import 'interactive_moments_screen_v2.dart';
import 'daily_review_screen_v2.dart';
import 'analytics_screen_v2.dart';
import 'profile_screen_v2.dart';
import 'ai_coach_screen.dart';
import 'goals_screen.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

class MainNavigationScreenV2 extends StatefulWidget {
  const MainNavigationScreenV2({super.key});

  @override
  State<MainNavigationScreenV2> createState() => _MainNavigationScreenV2State();
}

class _MainNavigationScreenV2State extends State<MainNavigationScreenV2>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  // ✅ VARIABLES DE ESTADO MEJORADAS
  int _currentIndex = 0;
  PageController? _pageController;
  late AnimationController _navAnimationController;
  late Animation<double> _navAnimation;

  // ✅ CONTROL DE ESTADOS
  bool _isInitialized = false;
  bool _isDisposed = false;

  // ✅ LISTA DE PANTALLAS CON GOALS
  late final List<Widget> _screens;

  // ✅ ACTUALIZADO: Configuración de navegación con Goals (RESPONSIVE)
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
      color: const Color(0xFF3B82F6),
    ),
    NavigationItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'Momentos',
      color: const Color(0xFF8B5CF6),
    ),
    NavigationItem(
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note,
      label: 'Reflexión',
      color: const Color(0xFF10B981),
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
      color: const Color(0xFFF59E0B),
    ),
    NavigationItem(
      icon: Icons.flag_outlined,
      activeIcon: Icons.flag,
      label: 'Goals',
      color: const Color(0xFF4ECDC4),
    ),
    NavigationItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
      label: 'Coach IA',
      color: const Color(0xFF9333EA),
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
      color: const Color(0xFFEF4444),
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeScreens();

    // ✅ INICIALIZACIÓN DIFERIDA Y SEGURA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _initializeNavigation();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pageController?.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navAnimation = CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeInOut,
    );
    _navAnimationController.forward();
  }

  void _initializeScreens() {
    _screens = [
      const HomeScreenV2(),
      const InteractiveMomentsScreenV2(),
      const DailyReviewScreenV2(),
      const AnalyticsScreenV2(),
      const GoalsScreen(),
      const AICoachScreen(),
      const ProfileScreenV2(),
    ];
    _isInitialized = true;
  }

  void _initializeNavigation() {
    if (_isDisposed) return;

    _pageController = PageController(initialPage: 0);

    // ✅ CARGAR DATOS INICIALES INCLUYENDO GOALS
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      context.read<GoalsProvider>().loadUserGoals(user.id);
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id);
      context.read<OptimizedMomentsProvider>().loadMoments(user.id);
      context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isInitialized || _isDisposed) {
      return const Scaffold(
        backgroundColor: ModernColors.darkPrimary,
        body: Center(
          child: CircularProgressIndicator(color: ModernColors.accentBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      extendBody: true,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  // ============================================================================
  // ✅ ARREGLADO: BOTTOM NAVIGATION CON UI RESPONSIVE
  // ============================================================================

  Widget _buildModernBottomNav() {
    return Container(
      height: 70, // ✅ ALTURA FIJA PARA EVITAR OVERFLOW
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ModernColors.borderPrimary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildNavigationItem(item, index);
          }).toList(),
        ),
      ),
    );
  }

  // ✅ ARREGLADO: Navigation Item con Flexible Layout
  Widget _buildNavigationItem(NavigationItem item, int index) {
    final isSelected = _currentIndex == index;

    return Expanded(  // ✅ CRÍTICO: Usar Expanded para distribución uniforme
      child: InkWell(
        onTap: () => _onNavigationTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 70, // ✅ ALTURA CONSISTENTE
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2), // ✅ Padding reducido
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ IMPORTANTE: Evitar expansion
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6), // ✅ Padding reducido de 12 a 6
                decoration: BoxDecoration(
                  color: isSelected ? item.color.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 18, // ✅ REDUCIDO: de 24 a 18
                  color: isSelected ? item.color : Colors.white60,
                ),
              ),
              const SizedBox(height: 2), // ✅ REDUCIDO: de 4 a 2
              Flexible( // ✅ CRÍTICO: Usar Flexible para texto
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 9, // ✅ REDUCIDO: de 12 a 9
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? item.color : Colors.white60,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // ✅ MÉTODOS DE NAVEGACIÓN MEJORADOS
  // ============================================================================

  void _onNavigationTap(int index) {
    if (_isDisposed || !_isInitialized) return;

    setState(() {
      _currentIndex = index;
    });

    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // ✅ FEEDBACK HÁPTICO MEJORADO
    _provideFeedback();
  }

  void _onPageChanged(int index) {
    if (_isDisposed) return;

    setState(() {
      _currentIndex = index;
    });
  }

  void _provideFeedback() {
    // Feedback háptico ligero
    try {
      // HapticFeedback.lightImpact(); // Descomentado si está disponible
    } catch (e) {
      // Ignorar errores de feedback háptico
    }
  }

  // ============================================================================
  // ✅ RESPONSIVE BREAKPOINTS PARA DIFERENTES TAMAÑOS DE PANTALLA
  // ============================================================================

  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }

  // ✅ VARIANTE PARA TABLETS (SI ES NECESARIO)
  Widget _buildTabletBottomNav() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: ModernColors.borderPrimary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          children: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildTabletNavigationItem(item, index);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabletNavigationItem(NavigationItem item, int index) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavigationTap(index),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? item.color.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 22,
                  color: isSelected ? item.color : Colors.white60,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? item.color : Colors.white60,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ CLASE DE DATOS PARA NAVIGATION ITEMS
// ============================================================================

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}