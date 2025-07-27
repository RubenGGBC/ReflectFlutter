// ============================================================================
// lib/presentation/widgets/hopecore_quotes_carousel.dart - CAROUSEL DE FRASES MOTIVACIONALES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers
import '../providers/hopecore_quotes_provider.dart';
import '../providers/theme_provider.dart';

// Componentes
import '../screens/v2/components/minimal_colors.dart';

class HopecoreQuotesCarousel extends StatefulWidget {
  final AnimationController? animationController;
  
  const HopecoreQuotesCarousel({
    super.key,
    this.animationController,
  });

  @override
  State<HopecoreQuotesCarousel> createState() => _HopecoreQuotesCarouselState();
}

class _HopecoreQuotesCarouselState extends State<HopecoreQuotesCarousel>
    with TickerProviderStateMixin {
  
  PageController? _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _glowController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  
  Map<String, String> _currentQuote = {'quote': '', 'source': ''};
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadNewQuote();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
    _glowController.repeat(reverse: true);
  }

  Future<void> _loadNewQuote() async {
    final quotesProvider = Provider.of<HopecoreQuotesProvider>(context, listen: false);
    
    if (!quotesProvider.isInitialized) {
      await quotesProvider.initialize();
    }

    setState(() {
      _currentQuote = quotesProvider.getRandomQuote();
      _isInitialized = true;
    });

    // Animar entrada de nueva frase
    _fadeController.reset();
    _slideController.reset();
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (!_isInitialized) {
          return _buildLoadingState();
        }

        return GestureDetector(
          onTap: _loadNewQuote,
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _slideAnimation, _glowAnimation]),
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.8),
                          MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.9),
                          MinimalColors.accentGradient(context)[0].withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4 * _glowAnimation.value),
                          blurRadius: 25 * _glowAnimation.value,
                          offset: const Offset(-5, 10),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3 * _glowAnimation.value),
                          blurRadius: 30 * _glowAnimation.value,
                          offset: const Offset(5, 15),
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con icono y título
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.format_quote,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Frase del Momento',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Toca para nueva frase',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Indicador de categoría
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getCategoryEmoji(_currentQuote['source'] ?? ''),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Frase principal
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.3),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            '"${_currentQuote['quote']}"',
                            key: ValueKey(_currentQuote['quote']),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 1.4,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Fuente y acción
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: Text(
                                  '— ${_currentQuote['source']}',
                                  key: ValueKey(_currentQuote['source']),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                            // Botón de refresh con animación
                            AnimatedBuilder(
                              animation: widget.animationController ?? _glowController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: (_glowAnimation.value * math.pi * 2) * 0.1,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.3 * _glowAnimation.value),
                                          blurRadius: 10 * _glowAnimation.value,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      size: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.format_quote,
                  color: MinimalColors.textSecondary(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cargando inspiración...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MinimalColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      'Preparando frases motivacionales',
                      style: TextStyle(
                        fontSize: 12,
                        color: MinimalColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Shimmer loading animation
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MinimalColors.textMuted(context).withValues(alpha: 0.1),
                      MinimalColors.textMuted(context).withValues(alpha: 0.3 * _glowAnimation.value),
                      MinimalColors.textMuted(context).withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getCategoryEmoji(String source) {
    if (source.contains('Star Wars') || source.contains('Matrix') || source.contains('Spider-Man')) {
      return '🎬'; // Películas
    } else if (source.contains('This Is Us') || source.contains('Friends') || source.contains('Grey\'s Anatomy')) {
      return '📺'; // Series
    } else if (source.contains('Harry Potter') || source.contains('El Señor de los Anillos') || source.contains('El Principito')) {
      return '📚'; // Libros
    } else if (source.contains('BioShock') || source.contains('Undertale') || source.contains('Final Fantasy')) {
      return '🎮'; // Juegos
    } else {
      return '✨'; // General/Hopecore
    }
  }
}