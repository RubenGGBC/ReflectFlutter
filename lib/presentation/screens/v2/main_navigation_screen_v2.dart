// lib/presentation/screens/v2/main_navigation_screen_v2.dart
// ✅ ACTUALIZADO CON INTEGRACIÓN COMPLETA DE GOALS

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
import 'goals_screen.dart'; // ✅ NUEVA IMPORTACIÓN

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

  // ✅ ACTUALIZADO: Configuración de navegación con Goals
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
    NavigationItem( // ✅ NUEVA PESTAÑA DE GOALS
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
      const GoalsScreen(), // ✅ NUEVA PANTALLA
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
      // Cargar datos de goals al inicializar
      context.read<GoalsProvider>().loadUserGoals(user.id);

      // Cargar otros datos existentes
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
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  void _onPageChanged(int index) {
    if (!mounted || _isDisposed) return;
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavItemTapped(int index) {
    if (!mounted || _isDisposed || _pageController == null) return;

    _pageController!.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: ModernColors.darkSecondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ModernColors.darkSecondary,
                ModernColors.darkSecondary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = _currentIndex == index;

                  return _buildNavItem(item, index, isActive);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavigationItem item, int index, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con animación
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? item.color.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive ? item.color : Colors.white.withOpacity(0.6),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isActive ? item.color : Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Indicador activo
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 6 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(1),
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
// ✅ MODELO DE NAVEGACIÓN ACTUALIZADO
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
// ✅ WIDGET FLOATING ACTION BUTTON PARA GOALS
// ============================================================================

class GoalsFloatingActionButton extends StatefulWidget {
  const GoalsFloatingActionButton({super.key});

  @override
  State<GoalsFloatingActionButton> createState() => _GoalsFloatingActionButtonState();
}

class _GoalsFloatingActionButtonState extends State<GoalsFloatingActionButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        final hasActiveGoals = goalsProvider.activeGoals.isNotEmpty;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _animationController.forward().then((_) {
                      _animationController.reverse();
                    });
                    _showGoalQuickActions(context);
                  },
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  icon: const Icon(Icons.flag),
                  label: Text(
                    hasActiveGoals ? 'Goals' : 'New Goal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showGoalQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const GoalQuickActionsSheet(),
    );
  }
}

// ============================================================================
// ✅ SHEET DE ACCIONES RÁPIDAS PARA GOALS
// ============================================================================

class GoalQuickActionsSheet extends StatelessWidget {
  const GoalQuickActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ModernColors.darkSecondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                '🎯 Goal Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Acciones rápidas
              _buildQuickAction(
                context,
                'Create New Goal',
                'Start tracking a new objective',
                Icons.add_circle,
                const Color(0xFF4ECDC4),
                    () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/goals');
                },
              ),
              const SizedBox(height: 16),

              _buildQuickAction(
                context,
                'View Progress',
                'Check your current goals',
                Icons.trending_up,
                const Color(0xFFFFD700),
                    () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/goals');
                },
              ),
              const SizedBox(height: 16),

              _buildQuickAction(
                context,
                'Goal Analytics',
                'Deep dive into your progress',
                Icons.analytics,
                const Color(0xFF45B7D1),
                    () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/analytics');
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ PROVIDER WATCHER PARA GOALS
// ============================================================================

class GoalsProviderWatcher extends StatefulWidget {
  final Widget child;

  const GoalsProviderWatcher({
    super.key,
    required this.child,
  });

  @override
  State<GoalsProviderWatcher> createState() => _GoalsProviderWatcherState();
}

class _GoalsProviderWatcherState extends State<GoalsProviderWatcher> {
  @override
  void initState() {
    super.initState();
    _initializeGoals();
  }

  void _initializeGoals() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<OptimizedAuthProvider>();
      final user = authProvider.currentUser;

      if (user != null) {
        context.read<GoalsProvider>().loadUserGoals(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// ============================================================================
// ✅ EXTENSIÓN PARA NAVEGACIÓN A GOALS
// ============================================================================

extension GoalsNavigation on BuildContext {
  void navigateToGoals() {
    Navigator.pushNamed(this, '/goals');
  }

  void navigateToGoalDetail(int goalId) {
    Navigator.pushNamed(this, '/goal-detail', arguments: goalId);
  }

  void navigateToCreateGoal() {
    Navigator.pushNamed(this, '/create-goal');
  }
}

// ============================================================================
// ✅ CONFIGURACIÓN DE RUTAS PARA GOALS
// ============================================================================

class GoalsRoutes {
  static const String goals = '/goals';
  static const String goalDetail = '/goal-detail';
  static const String createGoal = '/create-goal';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case goals:
        return MaterialPageRoute(
          builder: (_) => const GoalsScreen(),
          settings: settings,
        );

      case goalDetail:
        final goalId = settings.arguments as int?;
        if (goalId == null) {
          return _errorRoute('Goal ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => GoalDetailScreen(goalId: goalId),
          settings: settings,
        );

      case createGoal:
        return MaterialPageRoute(
          builder: (_) => const CreateGoalScreen(),
          settings: settings,
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: ModernColors.darkPrimary,
        body: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Placeholders para pantallas que faltan
class GoalDetailScreen extends StatelessWidget {
  final int goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        backgroundColor: ModernColors.darkPrimary,
        title: const Text('Goal Detail'),
      ),
      body: Center(
        child: Text(
          'Goal Detail Screen for ID: $goalId',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class CreateGoalScreen extends StatelessWidget {
  const CreateGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        backgroundColor: ModernColors.darkPrimary,
        title: const Text('Create Goal'),
      ),
      body: const Center(
        child: Text(
          'Create Goal Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}