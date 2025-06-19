// ============================================================================
// modern_navigation.dart - NAVEGACIÓN CON DASHBOARD Y BOTÓN DE ACCIÓN CENTRAL
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// FIX: Corrected import paths based on project structure
import '../../providers/auth_provider.dart';
import '../v2/dashboard_screen.dart'; // Using the new Dashboard
import '../v2/add_moment_screen.dart';   // Using the new Add Moment screen
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

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CalendarScreenV2(),
    const ProfileScreenV2(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToAddMoment() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMomentScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMoment,
        backgroundColor: ModernColors.primaryGradient.first,
        child: const Icon(Icons.add),
        tooltip: 'Añadir Momento',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: const Color(0xFF1a1a2e).withOpacity(0.95),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
            _buildNavItem(1, Icons.calendar_month_outlined, 'Calendario'),
            const SizedBox(width: 48), // Placeholder for the FAB
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
