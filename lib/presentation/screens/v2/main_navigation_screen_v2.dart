// ============================================================================
// presentation/screens/v2/main_navigation_screen_v2.dart - NAVEGACIÓN CORREGIDA
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
  PageController? _pageController; // ✅ ARREGLADO: Nullable para inicialización segura
  late AnimationController _navAnimationController;
  late Animation<double> _navAnimation;

  // ✅ ARREGLADO: Estado de inicialización
  bool _isInitialized = false;
  bool _isInitializing = false;

  // Lista de pantallas con lazy loading
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
    _setupAnimations();

    // ✅ ARREGLADO: Inicialización diferida y segura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNavigation();
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeNavigation() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      // ✅ ARREGLADO: Verificar autenticación primero
      final authProvider = context.read<OptimizedAuthProvider>();
      if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
        return;
      }

      // ✅ ARREGLADO: Configurar navegación después de verificar auth
      _setupNavigation();
      _setupAnimations();

      // ✅ ARREGLADO: Precargar datos esenciales con timeout
      await _initializeUserData();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        _navAnimationController.forward();
      }

    } catch (e) {
      debugPrint('❌ Error inicializando navegación: $e');
      if (mounted) {
        // En caso de error, redirigir a login
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  void _setupNavigation() {
    // ✅ ARREGLADO: Crear PageController solo una vez
    if (_pageController == null) {
      _pageController = PageController(initialPage: _currentIndex);
    }

    // ✅ ARREGLADO: Instancias frescas de las pantallas
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
  }

  Future<void> _initializeUserData() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) return;

    try {
      // ✅ ARREGLADO: Precargar datos con timeout y manejo de errores
      await Future.wait([
        context.read<OptimizedDailyEntriesProvider>()
            .loadEntries(user.id, limitDays: 7),
        context.read<OptimizedMomentsProvider>()
            .loadTodayMoments(user.id),
        context.read<OptimizedAnalyticsProvider>()
            .loadCompleteAnalytics(user.id, days: 30),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw 'Timeout cargando datos iniciales',
      );
    } catch (e) {
      debugPrint('⚠️ Error precargando datos (continuando): $e');
      // No lanzar excepción, solo log - la app puede funcionar sin datos precargados
    }
  }

  // ✅ ARREGLADO: Navegación segura y sincronizada
  void _onNavItemTapped(int index) {
    if (!_isInitialized || _pageController == null) return;

    if (index == _currentIndex) return; // Ya estamos en esa pantalla

    setState(() {
      _currentIndex = index;
    });

    // ✅ ARREGLADO: Animación suave entre páginas
    _pageController!.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ✅ ARREGLADO: Sincronización bidireccional
  void _onPageChanged(int index) {
    if (!mounted) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OptimizedAuthProvider>(
        builder: (context, authProvider, child) {
          // ✅ ARREGLADO: Verificación de autenticación mejorada
          if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            });
            return const _AuthRedirectScreen();
          }

          // ✅ ARREGLADO: Estados de carga y error
          if (!_isInitialized) {
            return _buildInitializingScreen();
          }

          return _buildMainContent();
        },
      ),
    );
  }

  Widget _buildInitializingScreen() {
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              'Preparando tu espacio...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
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
          // ✅ ARREGLADO: Contenido principal con verificación
          Expanded(
            child: _pageController != null
                ? PageView(
              controller: _pageController!,
              onPageChanged: _onPageChanged,
              physics: const ClampingScrollPhysics(), // ✅ ARREGLADO: Física de scroll mejorada
              children: _screens,
            )
                : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

          // Barra de navegación
          _buildModernBottomNav(),
        ],
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NUEVO: Métodos de conveniencia públicos
  void navigateToScreen(int index) {
    if (index >= 0 && index < _screens.length && _isInitialized) {
      _onNavItemTapped(index);
    }
  }

  Widget get currentScreen => _isInitialized && _currentIndex < _screens.length
      ? _screens[_currentIndex]
      : const SizedBox.shrink();

  bool isScreenActive(int index) => _currentIndex == index && _isInitialized;

  // ✅ NUEVO: Método para refrescar datos
  Future<void> refreshData() async {
    if (!_isInitialized) return;

    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      await _initializeUserData();
    }
  }
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

// ✅ NUEVO: Screen de redirección a auth
class _AuthRedirectScreen extends StatelessWidget {
  const _AuthRedirectScreen();

  @override
  Widget build(BuildContext context) {
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.white54,
              size: 64,
            ),
            SizedBox(height: 24),
            Text(
              'Redirigiendo al login...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
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