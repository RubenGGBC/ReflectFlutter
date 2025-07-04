// ============================================================================
// main_navigation_screen_v2.dart - ACTUALIZADO CON NUEVA PANTALLA DE MOMENTOS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../providers/image_moments_provider.dart';

// Screens optimizadas - ACTUALIZADO
import 'home_screen_v2.dart';
import 'quick_moments_screen.dart'; // ✅ NUEVA PANTALLA RÁPIDA
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

  // ============================================================================
  // VARIABLES DE ESTADO MEJORADAS
  // ============================================================================

  int _currentIndex = 0;
  PageController? _pageController;
  late AnimationController _navAnimationController;
  late Animation<double> _navAnimation;

  // Control de estados
  bool _isInitialized = false;
  bool _isDisposed = false;

  // Lista de pantallas con la nueva QuickMomentsScreen
  late final List<Widget> _screens;

  // ============================================================================
  // ACTUALIZADO: Configuración de navegación con nueva pantalla de momentos
  // ============================================================================

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
      color: const Color(0xFF3B82F6),
    ),
    NavigationItem(
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt,
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

    // Inicialización diferida y segura
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

  // ============================================================================
  // INICIALIZACIÓN Y CONFIGURACIÓN
  // ============================================================================

  void _setupAnimations() {
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _navAnimation = CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeInOut,
    );
  }

  void _initializeScreens() {
    _screens = [
      const _SafeScreenWrapper(child: HomeScreenV2()),
      const _SafeScreenWrapper(child: QuickMomentsScreen()), // ✅ NUEVA PANTALLA
      const _SafeScreenWrapper(child: DailyReviewScreenV2()),
      const _SafeScreenWrapper(child: AnalyticsScreenV2()),
      const _SafeScreenWrapper(child: GoalsScreen()),
      const _SafeScreenWrapper(child: AICoachScreen()),
      const _SafeScreenWrapper(child: ProfileScreenV2()),
    ];
  }

  Future<void> _initializeNavigation() async {
    if (_isDisposed) return;

    try {
      _pageController = PageController(initialPage: _currentIndex);

      // Precargar datos necesarios para la navegación
      await _preloadEssentialData();

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
        _navAnimationController.forward();
      }
    } catch (e) {
      debugPrint('Error inicializando navegación: $e');
    }
  }

  Future<void> _preloadEssentialData() async {
    try {
      final authProvider = context.read<OptimizedAuthProvider>();

      if (authProvider.currentUser != null) {
        final userId = authProvider.currentUser!.id;

        // Cargar datos en paralelo de forma segura
        final futures = <Future<void>>[];

        // Solo cargar si los providers están disponibles
        try {
          futures.add(context.read<OptimizedMomentsProvider>().loadMoments(userId));
        } catch (e) {
          debugPrint('MomentsProvider no disponible: $e');
        }

        try {
          futures.add(context.read<OptimizedDailyEntriesProvider>().loadEntries(userId));
        } catch (e) {
          debugPrint('DailyEntriesProvider no disponible: $e');
        }

        if (futures.isNotEmpty) {
          await Future.wait(futures, eagerError: false);
        }
      }
    } catch (e) {
      debugPrint('Error precargando datos: $e');
    }
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    return Consumer<OptimizedAuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.currentUser == null) {
          return _buildNoUserScreen();
        }

        return Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          body: SafeArea(
            child: _buildBody(),
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Preparando tu experiencia...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUserScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Usuario no disponible',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Por favor, reinicia la aplicación',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Reinicializar auth provider
                context.read<OptimizedAuthProvider>().loginAsDeveloper();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reiniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _screens.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _navAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _navAnimation,
              child: _screens[index],
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // BOTTOM NAVIGATION ACTUALIZADA
  // ============================================================================

  Widget _buildBottomNavigation() {
    return AnimatedBuilder(
      animation: _navAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_navAnimation),
          child: _buildBottomNavigationContent(),
        );
      },
    );
  }

  Widget _buildBottomNavigationContent() {
    return Container(
      height: MediaQuery.of(context).size.width > 600 ? 80 : 70,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
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
            final isSelected = _currentIndex == index;

            return Expanded(
              child: _buildNavigationItem(item, index, isSelected),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => _onNavigationTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.color.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: MediaQuery.of(context).size.width > 600 ? 22 : 18,
                color: isSelected ? item.color : Colors.white60,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 11 : 9,
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
    );
  }

  // ============================================================================
  // MÉTODOS DE NAVEGACIÓN MEJORADOS
  // ============================================================================

  void _onNavigationTap(int index) {
    if (_isDisposed || !_isInitialized || index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _provideFeedback();
  }

  void _onPageChanged(int index) {
    if (_isDisposed) return;

    setState(() {
      _currentIndex = index;
    });
  }

  void _provideFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // Ignorar errores de feedback háptico
    }
  }

  // ============================================================================
  // RESPONSIVE BREAKPOINTS
  // ============================================================================

  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }
}

// ============================================================================
// CLASES DE APOYO
// ============================================================================

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

// Wrapper seguro para las pantallas
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
          debugPrint('Error en pantalla: $e');
          return _buildErrorScreen(e.toString());
        }
      },
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error en la pantalla',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}