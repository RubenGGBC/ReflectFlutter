// ============================================================================
// models/moment_category.dart - MODELO PARA CATEGORÍAS DE MOMENTOS
// ============================================================================

import 'package:flutter/material.dart';

class MomentCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final List<Color> gradient;

  const MomentCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

// ============================================================================
// DATOS DE CATEGORÍAS (Puede moverse a un servicio o constante)
// ============================================================================

class MomentCategories {
  static const List<MomentCategory> all = [
    MomentCategory(
      id: 'all',
      name: 'Todos',
      icon: '🌟',
      color: Color(0xFF667eea),
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
    ),
    MomentCategory(
      id: 'positive',
      name: 'Positivos',
      icon: '😊',
      color: Color(0xFF10B981),
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
    ),
    MomentCategory(
      id: 'creative',
      name: 'Creativos',
      icon: '🎨',
      color: Color(0xFFF59E0B),
      gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
    ),
    MomentCategory(
      id: 'work',
      name: 'Trabajo',
      icon: '💼',
      color: Color(0xFF3B82F6),
      gradient: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
    ),
    MomentCategory(
      id: 'health',
      name: 'Salud',
      icon: '🏃‍♀️',
      color: Color(0xFFEF4444),
      gradient: [Color(0xFFEF4444), Color(0xFFDC2626)],
    ),
  ];
}
