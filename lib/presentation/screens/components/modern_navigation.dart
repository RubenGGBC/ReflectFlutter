// ============================================================================
// modern_navigation.dart - NAVEGACIÓN COMPLETAMENTE ARREGLADA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports corregidos
import '../../providers/auth_provider.dart';
import '../v2/home_screen_v2.dart';
import '../v2/interactive_moments_screen_v2.dart';
import '../v2/calendar_screen_v2.dart';
import '../v2/profile_screen_v2.dart';
import 'modern_design_system.dart';

class ModernNavigationWrapper extends StatefulWidget {
  const ModernNavigationWrapper({super.key});

  @override
  State<ModernNavigationWrapper> createState() => _ModernNavigationWrapperState();
}

class _ModernNavigationWrapperState extends State<ModernNavigationWrapper> {
  int _currentIndex = 0;

  // Pantallas principales con manejo de errores
  final List<Widget> _screens = [
    const HomeScreenV2(),
    const CalendarScreenV2(),
    const ProfileScreenV2(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToInteractiveMoments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InteractiveMomentsScreenV2(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToInteractiveMoments,
        backgroundColor: ModernColors.accentBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_reaction_outlined),
        label: const Text(
          'Momentos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        tooltip: 'Gestionar Momentos',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: const Color(0xFF1a1a2e).withOpacity(0.95), // ✅ CORREGIDO: withOpacity en lugar de withValues
      elevation: 8,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Home'),
            _buildNavItem(1, Icons.calendar_month_outlined, 'Calendario'),
            const SizedBox(width: 80), // Espacio para FAB
            _buildNavItem(2, Icons.person_outline, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    final color = isActive ? ModernColors.accentBlue : Colors.white54;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: isActive ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}