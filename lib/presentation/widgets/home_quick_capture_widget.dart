// ============================================================================
// home_quick_capture_widget.dart - WIDGET PARA CAPTURA RÁPIDA EN HOME
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Pantalla de momentos rápidos
import '../screens/v2/quick_moments_screen.dart';

class QuickCaptureWidget extends StatefulWidget {
  const QuickCaptureWidget({super.key});

  @override
  State<QuickCaptureWidget> createState() => _QuickCaptureWidgetState();
}

class _QuickCaptureWidgetState extends State<QuickCaptureWidget>
    with TickerProviderStateMixin {

  late AnimationController _pulseController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  Future<void> _openQuickCapture({bool withCamera = false}) async {
    HapticFeedback.mediumImpact();

    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuickMomentsScreen(startWithCamera: withCamera),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (result == true) {
      // Momento guardado exitosamente
      // El parent widget puede refrescar los datos si es necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Captura rápida',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Botones de captura rápida
          Row(
            children: [
              // Botón principal con cámara
              Expanded(
                flex: 2,
                child: _buildMainCaptureButton(),
              ),

              const SizedBox(width: 12),

              // Botón secundario sin cámara
              Expanded(
                child: _buildSecondaryButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCaptureButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            final scale = 1.0 - (_scaleController.value * 0.05);

            return Transform.scale(
              scale: scale,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: () => _openQuickCapture(withCamera: true),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade600,
                        Colors.purple.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Efecto de pulso
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.0 + (_pulseController.value * 0.3),
                              colors: [
                                Colors.white.withOpacity(0.1 * (1 - _pulseController.value)),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Contenido del botón
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Foto + Momento',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Captura instantánea',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      },
    );
  }

  Widget _buildSecondaryButton() {
    return GestureDetector(
      onTap: () => _openQuickCapture(withCamera: false),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade800.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              color: Colors.white.withOpacity(0.9),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Solo texto',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODIFICACIÓN AL HOME SCREEN V2 - AGREGAR EL WIDGET
// ============================================================================

class HomeScreenV2QuickCaptureAddition {
  // Este código muestra cómo integrar el widget en HomeScreenV2

  Widget buildQuickCaptureSection() {
    return const QuickCaptureWidget();
  }

  // Ejemplo de integración en el build method del HomeScreenV2:
  Widget buildHomeScreenWithQuickCapture() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ... otros widgets del home screen

              // Agregar la sección de captura rápida
              const QuickCaptureWidget(),

              const SizedBox(height: 20),

              // ... resto de widgets del home screen
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FLOATING ACTION BUTTON ALTERNATIVO PARA NAVEGACIÓN PRINCIPAL
// ============================================================================

class QuickCaptureFAB extends StatelessWidget {
  const QuickCaptureFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const QuickMomentsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 8,
      highlightElevation: 12,
      icon: const Icon(Icons.add_a_photo, size: 24),
      label: const Text(
        'Momento',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}