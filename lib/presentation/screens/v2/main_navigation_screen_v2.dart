// lib/presentation/screens/v2/main_navigation_screen_v2.dart
// ✅ ACTUALIZADO CON COACH DE IA

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
import 'ai_coach_screen.dart'; // ✅ NUEVA PANTALLA

// Componentes modernos
import '../components/modern_design_system.dart';

class MainNavigationScreenV2 extends StatefulWidget {
  const MainNavigationScreenV2({super.key});

  @override
  State<MainNavigationScreenV2> createState() => _MainNavigationScreenV2State();
}

class _MainNavigationScreenV2State extends State<MainNavigationScreenV2>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  // ✅ ARREGLADO: Variables de estado mejoradas
  int _currentIndex = 0;
  PageController? _pageController;
  late AnimationController _navAnimationController;
  late Animation<double> _navAnimation;

  // ✅ ARREGLADO: Control de estados
  bool _isInitialized = false;
  bool _isDisposed = false;

  // ✅ ARREGLADO: Lista de pantallas con verificación de estado
  late final List<Widget> _screens;

  // ✅ ACTUALIZADO: Configuración de navegación con Coach de IA
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
      icon: Icons.psychology_outlined, // ✅ NUEVO: Coach IA
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

    // ✅ ARREGLADO: Inicialización diferida y segura
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

  // ✅ ACTUALIZADO: Inicialización de pantallas con Coach IA
  void _initializeScreens() {
    _screens = [
      _SafeScreenWrapper(child: const HomeScreenV2()),
      _SafeScreenWrapper(child: const InteractiveMomentsScreenV2()),
      _SafeScreenWrapper(child: const DailyReviewScreenV2()),
      _SafeScreenWrapper(child: const AnalyticsScreenV2()),
      _SafeScreenWrapper(child: const AICoachScreenV2()), // ✅ NUEVA PANTALLA
      _SafeScreenWrapper(child: const ProfileScreenV2()),
    ];
  }

  // ✅ ARREGLADO: Inicialización de navegación segura
  Future<void> _initializeNavigation() async {
    if (_isDisposed) return;

    try {
      // Verificar autenticación
      final authProvider = context.read<OptimizedAuthProvider>();
      if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
        if (mounted && !_isDisposed) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
        return;
      }

      // ✅ ARREGLADO: Crear PageController de forma segura
      _pageController = PageController(
        initialPage: _currentIndex,
        keepPage: true,
      );

      // Precargar datos con timeout
      await _initializeUserData().timeout(
        const Duration(seconds: 8),
        onTimeout: () => debugPrint('⚠️ Timeout en carga de datos (continuando)'),
      );

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
        _navAnimationController.forward();
      }

    } catch (e) {
      debugPrint('❌ Error inicializando navegación: $e');
      if (mounted && !_isDisposed) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    }
  }

  Future<void> _initializeUserData() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

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
      debugPrint('⚠️ Error precargando datos: $e');
    }
  }

  // ✅ ARREGLADO: Navegación completamente segura
  void _onNavItemTapped(int index) {
    if (_isDisposed || !_isInitialized || _pageController == null) return;
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // ✅ ARREGLADO: Verificar que el PageController esté disponible
    if (_pageController!.hasClients) {
      _pageController!.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Para AutomaticKeepAliveClientMixin

    return Scaffold(
      body: Consumer<OptimizedAuthProvider>(
        builder: (context, authProvider, child) {
          // Verificación de autenticación
          if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isDisposed) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            });
            return _buildAuthRedirectScreen();
          }

          // Estado de inicialización
          if (!_isInitialized) {
            return _buildInitializingScreen();
          }

          return _buildMainContent();
        },
      ),
    );
  }

  Widget _buildAuthRedirectScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
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
            CircularProgressIndicator(color: Colors.white),
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
          // ✅ ARREGLADO: Contenido principal con verificaciones
          Expanded(
            child: _pageController != null && _pageController!.hasClients
                ? PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemCount: _screens.length,
              itemBuilder: (context, index) {
                return _screens[index];
              },
            )
                : _screens[_currentIndex], // Fallback seguro
          ),

          // ✅ ACTUALIZADO: Navegación inferior con 6 elementos
          AnimatedBuilder(
            animation: _navAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 100 * (1 - _navAnimation.value)),
                child: Container(
                  margin: const EdgeInsets.all(12), // Reducido para 6 elementos
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: _buildBottomNavigation(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), // Ajustado para 6 elementos
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _navigationItems.length,
              (index) => _buildNavItem(index),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isActive = index == _currentIndex;

    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Reducido para 6 elementos
        decoration: BoxDecoration(
          color: isActive ? item.color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? item.color : Colors.white60,
              size: 22, // Ligeramente más pequeño para 6 elementos
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? item.color : Colors.white60,
                fontSize: 10, // Texto más pequeño para 6 elementos
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ ARREGLADO: Wrapper para pantallas que previene errores
class _SafeScreenWrapper extends StatelessWidget {
  final Widget child;

  const _SafeScreenWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          debugPrint('❌ Error en pantalla: $e');
          return _buildErrorScreen();
        }
      },
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white60,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Error cargando pantalla',
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

// Clase para items de navegación
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}