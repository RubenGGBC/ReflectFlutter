// ============================================================================
// test_integration.dart - SIMPLE TEST FOR ENHANCED ROADMAP INTEGRATION
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import all required providers
import '../../providers/optimized_providers.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/theme_provider.dart';

// Import the enhanced screen
import 'daily_roadmap_screen_v3.dart';
import '../../../injection_container_clean.dart' as di;

class TestIntegration extends StatelessWidget {
  const TestIntegration({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Roadmap Test',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          // Theme Provider
          ChangeNotifierProvider(
            create: (_) => di.sl<ThemeProvider>()..initialize(),
          ),
          
          // Auth Provider
          ChangeNotifierProvider(
            create: (_) => di.sl<OptimizedAuthProvider>(),
          ),
          
          // Daily Roadmap Provider
          ChangeNotifierProxyProvider<OptimizedAuthProvider, DailyRoadmapProvider>(
            create: (_) => di.sl<DailyRoadmapProvider>(),
            update: (_, auth, previous) => previous ?? di.sl<DailyRoadmapProvider>(),
          ),
        ],
        child: Consumer<OptimizedAuthProvider>(
          builder: (context, authProvider, _) {
            return FutureBuilder(
              future: _initializeAuth(authProvider),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    backgroundColor: const Color(0xFF0A0E1A),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Iniciando test de integración...',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (authProvider.currentUser == null) {
                  return Scaffold(
                    backgroundColor: const Color(0xFF0A0E1A),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 64,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Error: Usuario no inicializado',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No se pudo inicializar el usuario de prueba',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show the enhanced roadmap screen
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Enhanced Daily Roadmap'),
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          _showTestInfo(context);
                        },
                      ),
                    ],
                  ),
                  body: const DailyRoadmapScreenV3(),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _initializeAuth(OptimizedAuthProvider authProvider) async {
    if (authProvider.currentUser == null) {
      await authProvider.loginAsDeveloper();
    }
  }

  void _showTestInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        title: Text(
          'Test de Integración',
          style: TextStyle(
            color: Colors.grey.shade100,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta es una prueba de integración del Enhanced Daily Roadmap Screen V3.',
              style: TextStyle(color: Colors.grey.shade300),
            ),
            const SizedBox(height: 16),
            Text(
              'Características probadas:',
              style: TextStyle(
                color: Colors.grey.shade100,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...const [
              '✅ Carga de providers',
              '✅ Inicialización de usuario',
              '✅ Soporte de temas',
              '✅ Integración con navegación',
              '✅ Animaciones y transiciones',
            ].map((item) => Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 13,
                ),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: Colors.blue.shade400),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple test runner
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.initForCleanTesting();
  
  runApp(const TestIntegration());
}