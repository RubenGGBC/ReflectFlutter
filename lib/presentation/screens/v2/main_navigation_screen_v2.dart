// ============================================================================
// presentation/screens/v2/main_navigation_screen_v2.dart - NAVEGACIÓN PRINCIPAL
// ============================================================================

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

// Componentes modernos
import '../components/modern_design_system.dart';

class MainNavigationScreenV2 extends StatefulWidget {
  const MainNavigationScreenV2({super.key});

  @override
  State<MainNavigationScreenV2> createState() => _MainNavigationScreenV2State();
}

class _MainNavigationScreenV2State extends State<MainNavigationScreenV2>
    with TickerProviderStateMixin {

  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _navAnimationController;
  late Animation<double> _navAnimation;

  // Lista de pantallas
  late final List<Widget> _screens;

  // Configuración de navegación
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
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
      color: const Color(0xFFEF4444),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupNavigation();
    _setupAnimations();
    _initializeUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  void _setupNavigation() {
    _pageController = PageController(initialPage: _currentIndex);

    _screens = [
      const HomeScreenV2(),
      const InteractiveMomentsScreenV2(),
      const DailyReviewScreenV2(),
      const AnalyticsScreenV2(),
      const ProfileScreenV2(),
    ];
  }

  void _setupAnimations() {
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _navAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeOutBack,
    ));

    _navAnimationController.forward();
  }

  Future<void> _initializeUserData() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      // Precargar datos esenciales en paralelo
      try {
        await Future.wait([
          context.read<OptimizedDailyEntriesProvider>()
              .loadEntries(user.id, limitDays: 7),
          context.read<OptimizedMomentsProvider>()
              .loadTodayMoments(user.id),
          context.read<OptimizedAnalyticsProvider>()
              .loadCompleteAnalytics(user.id, days: 30),
        ]);
      } catch (e) {
        debugPrint('Error precargando datos: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OptimizedAuthProvider>(
        builder: (context, authProvider, child) {
          // Verificar autenticación
          if (!authProvider.isLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/auth');
            });
            return const SizedBox.shrink();
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF334155),
                ],
              ),
            ),
            child: Column(
              children: [
                // Contenido principal
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: _screens,
                  ),
                ),

                // Barra de navegación
                _buildModernBottomNav(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_navAnimation),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navigationItems.length, (index) {
                return _buildNavItem(index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? item.color.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono con animación
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.color.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? item.color : Colors.white54,
                size: isSelected ? 26 : 22,
              ),
            ),

            const SizedBox(height: 4),

            // Label con animación
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? item.color : Colors.white38,
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // LÓGICA DE NAVEGACIÓN
  // ============================================================================

  void _onNavItemTapped(int index) {
    if (_currentIndex == index) {
      // Si ya estamos en la pantalla, scroll al top o refresh
      _handleSameScreenTap(index);
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Haptic feedback
    _provideFeedback();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleSameScreenTap(int index) {
    // Implementar scroll to top o refresh según la pantalla
    switch (index) {
      case 0: // Home
        _refreshHomeData();
        break;
      case 1: // Momentos
      // Scroll to top o mostrar quick add
        break;
      case 2: // Reflexión
      // No action needed
        break;
      case 3: // Analytics
        _refreshAnalytics();
        break;
      case 4: // Perfil
      // No action needed
        break;
    }
  }

  Future<void> _refreshHomeData() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      try {
        await Future.wait([
          context.read<OptimizedDailyEntriesProvider>()
              .loadEntries(user.id, limitDays: 7),
          context.read<OptimizedMomentsProvider>()
              .loadTodayMoments(user.id),
        ]);

        _showSnackBar('Datos actualizados');
      } catch (e) {
        _showSnackBar('Error actualizando datos', isError: true);
      }
    }
  }

  Future<void> _refreshAnalytics() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      try {
        await context.read<OptimizedAnalyticsProvider>()
            .loadCompleteAnalytics(user.id, days: 30);

        _showSnackBar('Analytics actualizados');
      } catch (e) {
        _showSnackBar('Error actualizando analytics', isError: true);
      }
    }
  }

  void _provideFeedback() {
    // Implementar haptic feedback si está disponible
    try {
      // HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback no disponible
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(
          bottom: 100, // Espacio para la bottom nav
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE CONVENIENCIA
  // ============================================================================

  // Método público para navegar programáticamente
  void navigateToScreen(int index) {
    if (index >= 0 && index < _screens.length) {
      _onNavItemTapped(index);
    }
  }

  // Método para obtener la pantalla actual
  Widget get currentScreen => _screens[_currentIndex];

  // Método para verificar si una pantalla específica está activa
  bool isScreenActive(int index) => _currentIndex == index;
}

// ============================================================================
// CLASES AUXILIARES
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

// ============================================================================
// WIDGET WRAPPER PARA FACILITAR IMPORTACIÓN
// ============================================================================

class ModernNavigationWrapper extends StatelessWidget {
  const ModernNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreenV2();
  }
}