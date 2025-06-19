// ============================================================================
// modern_navigation.dart - NAVEGACIÓN CON HOMESCREEN V2 Y BOTÓN HACIA INTERACTIVE MOMENTS V2
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// FIX: Corrected import paths based on project structure
import '../../providers/auth_provider.dart';
import '../v2/home_screen_v2.dart';  // ✅ USANDO HomeScreenV2
import '../v2/interactive_moments_screen_v2.dart';  // Using InteractiveMomentsScreenV2
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

  // ✅ USANDO HomeScreenV2 en lugar de DashboardScreen
  final List<Widget> _screens = [
    const HomeScreenV2(),        // ← PANTALLA PRINCIPAL CON ANALYTICS
    const CalendarScreenV2(),
    const ProfileScreenV2(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // ✅ NAVEGACIÓN HACIA InteractiveMomentsScreenV2 MEJORADO
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToInteractiveMoments,
        backgroundColor: ModernColors.primaryGradient.first,
        icon: const Icon(Icons.add_reaction_outlined, color: Colors.white),
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
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: const Color(0xFF1a1a2e).withValues(alpha: 0.95),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Home'),  // ✅ ACTUALIZADO
            _buildNavItem(1, Icons.calendar_month_outlined, 'Calendario'),
            const SizedBox(width: 80), // Space for the extended FAB
            _buildNavItem(2, Icons.person_outline, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    final color = isActive ? ModernColors.primaryGradient.first : ModernColors.textHint;

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}