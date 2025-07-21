// lib/presentation/screens/v2/welcome_onboarding_screen.dart
// WELCOME ONBOARDING SCREEN FOR FIRST-TIME USERS
// ============================================================================
// STYLED WITH HOME SCREEN DESIGN SYSTEM - MINIMAL DARK THEME WITH GRADIENTS
// ============================================================================

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';

// Models
import '../../../data/models/goal_model.dart';

// Services
import '../../../data/services/image_picker_service.dart';
import '../../../injection_container_clean.dart' as clean_di;

// Navigation
import 'main_navigation_screen_v2.dart';

// Componentes
import 'components/minimal_colors.dart';

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  State<WelcomeOnboardingScreen> createState() => _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen>
    with TickerProviderStateMixin {
  
  // Page Controller
  final PageController _pageController = PageController();
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  
  // State Variables
  int _currentPage = 0;
  String? _selectedProfilePicture;
  bool _isDarkTheme = false;
  List<GoalModel> _selectedGoals = [];
  
  // Animation Controllers (siguiendo el patrón del home screen)
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shimmerController, curve: Curves.linear));
    
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _floatingController, curve: Curves.linear));
    
    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final themeProvider = context.read<ThemeProvider>();
      
      // Set theme preference
      themeProvider.setTheme(_isDarkTheme);
      
      // Create default profile for single device user
      final success = await authProvider.createDefaultProfile(
        name: _nameController.text.trim().isEmpty ? 'Usuario' : _nameController.text.trim(),
        avatarEmoji: '🧘‍♀️',
        profilePicturePath: _selectedProfilePicture,
        age: int.tryParse(_ageController.text),
        bio: "Usuario de Reflect",
        goals: _selectedGoals,
      );
      
      if (success) {
        // Navigate to main app
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreenV2(),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error creando el perfil')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completando configuración: $e')),
        );
      }
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final imageService = clean_di.sl<ImagePickerService>();
      final imagePath = await imageService.pickFromGallery();
      if (imagePath != null) {
        setState(() {
          _selectedProfilePicture = imagePath;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _toggleGoal(GoalModel goal) {
    setState(() {
      if (_selectedGoals.any((g) => g.title == goal.title)) {
        _selectedGoals.removeWhere((g) => g.title == goal.title);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedTheme(
          duration: const Duration(milliseconds: 300),
          data: themeProvider.currentThemeData,
          child: Scaffold(
            backgroundColor: MinimalColors.backgroundPrimary(context),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MinimalColors.backgroundPrimary(context),
                    MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
                    MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Animated background particles (siguiendo el patrón del home screen)
                  ...List.generate(3, (index) =>
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 100 + (index * 200) + (math.sin(_floatingAnimation.value * math.pi * 2 + index) * 20),
                          right: 50 + (index * 100) + (math.cos(_floatingAnimation.value * math.pi * 2 + index) * 30),
                          child: Container(
                            width: 20 + (index * 10),
                            height: 20 + (index * 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  MinimalColors.accentGradient(context)[index % 2].withValues(alpha: 0.1),
                                  MinimalColors.lightGradient(context)[index % 2].withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Progress Indicator
                        _buildProgressIndicator(),
                        
                        // Page Content
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            children: [
                              _buildWelcomePage(),
                              _buildProfileSetupPage(),
                              _buildGoalsSelectionPage(),
                              _buildThemeSelectionPage(),
                            ],
                          ),
                        ),
                        
                        // Navigation Buttons
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: index <= _currentPage ? 1.0 + (_pulseAnimation.value * 0.1) : 1.0,
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    decoration: BoxDecoration(
                      gradient: index <= _currentPage
                          ? LinearGradient(
                              colors: MinimalColors.primaryGradient(context),
                            )
                          : null,
                      color: index > _currentPage 
                          ? MinimalColors.textMuted(context).withValues(alpha: 0.3)
                          : null,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: index <= _currentPage
                          ? [
                              BoxShadow(
                                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo/Icon con el estilo del home screen
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: MinimalColors.primaryGradient(context),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Welcome Text con animación shimmer
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, math.sin(_shimmerAnimation.value * math.pi * 2) * 1),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: MinimalColors.accentGradientStatic,
                      ).createShader(bounds),
                      child: Text(
                        'Bienvenido a Reflect',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Tu viaje personal hacia el bienestar mental comienza aquí. Conozcámonos mejor.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: MinimalColors.textSecondary(context),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Features Preview con estilo mejorado
              Row(
                children: [
                  _buildFeatureItem('🧘‍♀️', 'Reflexión Mindful'),
                  _buildFeatureItem('📊', 'Seguimiento'),
                  _buildFeatureItem('🎯', 'Objetivos'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, math.sin(_floatingAnimation.value * math.pi * 2) * 3),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSetupPage() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cuéntanos sobre ti',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Profile Picture con estilo del home screen
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _selectedProfilePicture != null
                              ? null
                              : LinearGradient(
                                  colors: MinimalColors.primaryGradient(context),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          color: _selectedProfilePicture != null
                              ? MinimalColors.backgroundCard(context)
                              : null,
                          border: Border.all(
                            color: MinimalColors.primaryGradient(context)[0],
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _selectedProfilePicture != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(57),
                                child: Image.file(
                                  File(_selectedProfilePicture!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Name Field con estilo mejorado
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _nameController,
                style: TextStyle(color: MinimalColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Tu Nombre',
                  labelStyle: TextStyle(color: MinimalColors.textSecondary(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: MinimalColors.primaryGradient(context)[0],
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: MinimalColors.backgroundCard(context),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Age Field con estilo mejorado
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: MinimalColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Edad (Opcional)',
                  labelStyle: TextStyle(color: MinimalColors.textSecondary(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: MinimalColors.primaryGradient(context)[0],
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: MinimalColors.backgroundCard(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSelectionPage() {
    final goals = [
      GoalModel(
        id: 0,
        userId: 0,
        title: 'Reflexión Diaria',
        description: 'Escribir una reflexión cada día',
        category: GoalCategory.habits,
        targetValue: 7,
        currentValue: 0,
        createdAt: DateTime.now(),
      ),
      GoalModel(
        id: 0,
        userId: 0,
        title: 'Mejorar Estado de Ánimo',
        description: 'Mantener un puntaje promedio de 7+',
        category: GoalCategory.emotional,
        targetValue: 7,
        currentValue: 0,
        createdAt: DateTime.now(),
      ),
      GoalModel(
        id: 0,
        userId: 0,
        title: 'Momentos Positivos',
        description: 'Capturar 10 momentos positivos esta semana',
        category: GoalCategory.emotional,
        targetValue: 10,
        currentValue: 0,
        createdAt: DateTime.now(),
      ),
      GoalModel(
        id: 0,
        userId: 0,
        title: 'Reducción de Estrés',
        description: 'Mantener el nivel de estrés por debajo de 5',
        category: GoalCategory.stress,
        targetValue: 5,
        currentValue: 0,
        createdAt: DateTime.now(),
      ),
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige tus objetivos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Selecciona los objetivos en los que te gustaría trabajar. Puedes cambiarlos después.',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final isSelected = _selectedGoals.any((g) => g.title == goal.title);
                  
                  return AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? 1.0 + (_pulseAnimation.value * 0.02) : 1.0,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: MinimalColors.backgroundCard(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? MinimalColors.primaryGradient(context)[0]
                                  : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3)
                                    : MinimalColors.backgroundCard(context).withValues(alpha: 0.1),
                                blurRadius: isSelected ? 15 : 5,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () => _toggleGoal(goal),
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: isSelected 
                                    ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                                    : null,
                                color: !isSelected ? MinimalColors.textMuted(context).withValues(alpha: 0.3) : null,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: isSelected ? Colors.white : MinimalColors.textSecondary(context),
                                size: 24,
                              ),
                            ),
                            title: Text(
                              goal.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                            subtitle: Text(
                              goal.description,
                              style: TextStyle(
                                color: MinimalColors.textSecondary(context),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelectionPage() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige tu tema',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Selecciona el tema que se sienta más cómodo para ti.',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Theme Options con estilo del home screen
            Row(
              children: [
                // Light Theme
                Expanded(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: !_isDarkTheme ? 1.0 + (_pulseAnimation.value * 0.02) : 1.0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDarkTheme = false;
                            });
                          },
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: !_isDarkTheme 
                                    ? MinimalColors.primaryGradient(context)[0]
                                    : Colors.grey.shade300,
                                width: !_isDarkTheme ? 3 : 1,
                              ),
                              boxShadow: !_isDarkTheme
                                  ? [
                                      BoxShadow(
                                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [const Color(0xFFfbbf24), const Color(0xFFf59e0b)],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.wb_sunny,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Claro',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (!_isDarkTheme)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Seleccionado',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Dark Theme
                Expanded(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isDarkTheme ? 1.0 + (_pulseAnimation.value * 0.02) : 1.0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDarkTheme = true;
                            });
                          },
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0E1A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isDarkTheme 
                                    ? MinimalColors.primaryGradient(context)[0]
                                    : Colors.grey.shade600,
                                width: _isDarkTheme ? 3 : 1,
                              ),
                              boxShadow: _isDarkTheme
                                  ? [
                                      BoxShadow(
                                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [const Color(0xFF1e3a8a), const Color(0xFF581c87)],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.nightlight_round,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Oscuro',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_isDarkTheme)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Seleccionado',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Final Step Message con estilo del home screen
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, math.sin(_shimmerAnimation.value * math.pi * 2) * 2),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: MinimalColors.backgroundCard(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                        width: 1,
                      ),
                      gradient: LinearGradient(
                        colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: MinimalColors.accentGradientStatic,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '¡Estás listo! Toca "Comenzar" para iniciar tu viaje de bienestar.',
                            style: TextStyle(
                              color: MinimalColors.textPrimary(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseAnimation.value * 0.01),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: MinimalColors.primaryGradient(context)[0],
                            width: 2,
                          ),
                          backgroundColor: MinimalColors.backgroundCard(context),
                        ),
                        child: Text(
                          'Anterior',
                          style: TextStyle(
                            color: MinimalColors.primaryGradient(context)[0],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          if (_currentPage > 0) const SizedBox(width: 16),
          
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseAnimation.value * 0.02),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: MinimalColors.primaryGradient(context),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (_currentPage == 1 && _nameController.text.trim().isEmpty) 
                          ? null
                          : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == 3 ? 'Comenzar' : 'Siguiente',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}