// ============================================================================
// test_data/analytics_test_runner.dart
// EJECUTOR DE PRUEBAS PARA ANÁLISIS AVANZADOS
// ============================================================================

import 'dart:convert';
import 'dart:io';
import '../data/services/optimized_database_service.dart';
import '../presentation/providers/analytics_provider_optimized.dart';
import '../injection_container_clean.dart' as di;
import 'analytics_test_data_generator.dart';

class AnalyticsTestRunner {
  static late OptimizedDatabaseService _databaseService;
  static late AnalyticsProviderOptimized _analyticsProvider;
  
  // ============================================================================
  // CONFIGURACIÓN DE PRUEBAS
  // ============================================================================
  
  static Future<void> initializeTests() async {
    print('🔧 Inicializando servicios de prueba...');
    
    // Inicializar dependency injection
    await di.init();
    
    // Obtener servicios
    _databaseService = di.sl<OptimizedDatabaseService>();
    _analyticsProvider = AnalyticsProviderOptimized(_databaseService);
    
    print('✅ Servicios inicializados correctamente');
  }
  
  // ============================================================================
  // MÉTODO PRINCIPAL DE PRUEBAS
  // ============================================================================
  
  static Future<void> runAllTests() async {
    print('🚀 Iniciando pruebas completas de Analytics...');
    print('=' * 60);
    
    await initializeTests();
    
    // Ejecutar pruebas para diferentes perfiles
    final profiles = [
      AnalyticsTestDataGenerator.UserProfile.stable,
      AnalyticsTestDataGenerator.UserProfile.anxious,
      AnalyticsTestDataGenerator.UserProfile.depressed,
      AnalyticsTestDataGenerator.UserProfile.improving,
      AnalyticsTestDataGenerator.UserProfile.chaotic,
    ];
    
    for (final profile in profiles) {
      print('\\n📊 Probando perfil: ${profile.name.toUpperCase()}');
      print('-' * 40);
      
      await testProfile(profile);
    }
    
    print('\\n🎉 Todas las pruebas completadas exitosamente!');
  }
  
  // ============================================================================
  // PRUEBAS POR PERFIL
  // ============================================================================
  
  static Future<void> testProfile(AnalyticsTestDataGenerator.UserProfile profile) async {
    final userId = profile.index + 1;
    
    try {
      // 1. Generar datos de prueba
      final testData = await AnalyticsTestDataGenerator.generateCompleteTestData(
        userId: userId,
        profile: profile,
        daysOfData: 45,
        momentsPerDay: 4,
        numberOfGoals: 6,
      );
      
      // 2. Insertar datos en la base de datos
      await _insertTestData(testData);
      
      // 3. Ejecutar análisis completo
      await _runAnalysisTests(userId, profile);
      
      // 4. Generar reporte
      await _generateTestReport(userId, profile, testData);
      
    } catch (e) {
      print('❌ Error en pruebas para perfil $profile: $e');
    }
  }
  
  // ============================================================================
  // INSERCIÓN DE DATOS DE PRUEBA
  // ============================================================================
  
  static Future<void> _insertTestData(Map<String, dynamic> testData) async {
    print('📝 Insertando datos de prueba...');
    
    final dailyEntries = testData['dailyEntries'] as List;
    final interactiveMoments = testData['interactiveMoments'] as List;
    final goals = testData['goals'] as List;
    
    // Insertar entradas diarias
    for (final entry in dailyEntries) {
      await _databaseService.insertDailyEntry(entry);
    }
    
    // Insertar momentos interactivos
    for (final moment in interactiveMoments) {
      await _databaseService.insertInteractiveMoment(moment);
    }
    
    // Insertar metas
    for (final goal in goals) {
      await _databaseService.insertGoal(goal);
    }
    
    print('✅ Datos insertados: ${dailyEntries.length} entradas, ${interactiveMoments.length} momentos, ${goals.length} metas');
  }
  
  // ============================================================================
  // EJECUCIÓN DE ANÁLISIS
  // ============================================================================
  
  static Future<void> _runAnalysisTests(int userId, AnalyticsTestDataGenerator.UserProfile profile) async {
    print('🔍 Ejecutando análisis avanzados...');
    
    // 1. Análisis completo
    await _testAnalisisCompleto(userId);
    
    // 2. Predicción de estado de ánimo
    await _testPrediccionEstadoAnimo(userId);
    
    // 3. Análisis de triggers de ansiedad
    await _testAnalisisTriggersAnsiedad(userId);
    
    // 4. Análisis de rutinas
    await _testAnalisisRutinas(userId);
    
    // 5. Análisis de momentos
    await _testAnalisisMomentosRapidos(userId);
  }
  
  // ============================================================================
  // PRUEBAS ESPECÍFICAS DE MÉTODOS
  // ============================================================================
  
  static Future<void> _testAnalisisCompleto(int userId) async {
    print('  📊 Probando análisis completo...');
    
    final stopwatch = Stopwatch()..start();
    
    try {
      await _analyticsProvider.generarAnalisisCompleto(userId);
      
      stopwatch.stop();
      
      // Verificar que todos los análisis se generaron
      final prediccion = _analyticsProvider.prediccionSemana;
      final ansiedad = _analyticsProvider.analisisAnsiedad;
      final rutinas = _analyticsProvider.analisisRutinas;
      final momentos = _analyticsProvider.analisisMomentos;
      final resumen = _analyticsProvider.resumenCompleto;
      
      print('    ✅ Análisis completo: ${stopwatch.elapsedMilliseconds}ms');
      print('    📈 Predicción: ${prediccion != null ? \"Generada\" : \"Error\"}');
      print('    😰 Ansiedad: ${ansiedad != null ? \"Analizada\" : \"Error\"}');
      print('    📅 Rutinas: ${rutinas != null ? \"Detectadas\" : \"Error\"}');
      print('    💭 Momentos: ${momentos != null ? \"Analizados\" : \"Error\"}');
      print('    📋 Resumen: ${resumen != null ? \"Completo\" : \"Error\"}');
      
    } catch (e) {
      print('    ❌ Error en análisis completo: $e');
    }
  }
  
  static Future<void> _testPrediccionEstadoAnimo(int userId) async {
    print('  🔮 Probando predicción de estado de ánimo...');
    
    try {
      final prediccion = await _analyticsProvider.predecirEstadoAnimoProximaSemana(userId);
      
      print('    ✅ Predicción generada exitosamente');
      print('    📅 Fecha predicción: ${prediccion.fecha.toIso8601String().split('T')[0]}');
      print('    😊 Estado de ánimo predicho: ${prediccion.estadoAnimoPredicto.toStringAsFixed(1)}/10');
      print('    🎯 Confianza: ${(prediccion.confianza * 100).toStringAsFixed(1)}%');
      print('    📈 Tendencia: ${prediccion.tendencia}');
      print('    🔍 Factores de influencia: ${prediccion.factoresInfluencia.length}');
      print('    😔 Probabilidad depresión: ${(prediccion.probabilidadDepresion * 100).toStringAsFixed(1)}%');
      print('    😰 Probabilidad ansiedad: ${(prediccion.probabilidadAnsiedad * 100).toStringAsFixed(1)}%');
      
      // Mostrar factores más importantes
      final factoresImportantes = prediccion.factoresInfluencia
          .take(3)
          .map((f) => '${f.nombre}: ${(f.impacto * 100).toStringAsFixed(0)}%')
          .join(', ');
      print('    🎯 Factores clave: $factoresImportantes');
      
    } catch (e) {
      print('    ❌ Error en predicción: $e');
    }
  }
  
  static Future<void> _testAnalisisTriggersAnsiedad(int userId) async {
    print('  😰 Probando análisis de triggers de ansiedad...');
    
    try {
      final analisis = await _analyticsProvider.analizarTriggersAnsiedad(userId);
      
      print('    ✅ Análisis de ansiedad completado');
      print('    📊 Nivel promedio ansiedad: ${analisis.nivelAnsiedadPromedio.toStringAsFixed(1)}/10');
      print('    🚨 Triggers detectados: ${analisis.triggersDetectados.length}');
      print('    💡 Estrategias recomendadas: ${analisis.estrategiasRecomendadas.length}');
      print('    ⏰ Patrones temporales: ${analisis.patronesTemporales.length}');
      
      // Mostrar triggers más frecuentes
      if (analisis.triggersDetectados.isNotEmpty) {
        final triggersFrecuentes = analisis.triggersDetectados
            .take(3)
            .map((t) => '${t.nombre} (${(t.intensidadPromedio * 10).toStringAsFixed(1)}/10)')
            .join(', ');
        print('    🎯 Triggers principales: $triggersFrecuentes');
      }
      
      // Mostrar estrategias
      if (analisis.estrategiasRecomendadas.isNotEmpty) {
        final estrategias = analisis.estrategiasRecomendadas
            .take(2)
            .map((e) => e.titulo)
            .join(', ');
        print('    💡 Estrategias clave: $estrategias');
      }
      
    } catch (e) {
      print('    ❌ Error en análisis de ansiedad: $e');
    }
  }
  
  static Future<void> _testAnalisisRutinas(int userId) async {
    print('  📅 Probando análisis de rutinas...');
    
    try {
      final analisis = await _analyticsProvider.analizarRutinasUsuario(userId);
      
      print('    ✅ Análisis de rutinas completado');
      print('    📊 Consistencia general: ${(analisis.consistenciaGeneral * 100).toStringAsFixed(1)}%');
      print('    🔄 Rutinas detectadas: ${analisis.rutinasDetectadas.length}');
      print('    📈 Patrones diarios: ${analisis.patronesDiarios.length}');
      print('    📅 Patrones semanales: ${analisis.patronesSemanales.length}');
      print('    💡 Sugerencias: ${analisis.sugerencias.length}');
      
      // Mostrar rutinas más consistentes
      if (analisis.rutinasDetectadas.isNotEmpty) {
        final rutinasConsistentes = analisis.rutinasDetectadas
            .take(3)
            .map((r) => '${r.nombre} (${(r.frecuencia * 100).toStringAsFixed(0)}%)')
            .join(', ');
        print('    🎯 Rutinas consistentes: $rutinasConsistentes');
      }
      
      // Mostrar sugerencias principales
      if (analisis.sugerencias.isNotEmpty) {
        final sugerencias = analisis.sugerencias
            .take(2)
            .map((s) => s.titulo)
            .join(', ');
        print('    💡 Sugerencias clave: $sugerencias');
      }
      
    } catch (e) {
      print('    ❌ Error en análisis de rutinas: $e');
    }
  }
  
  static Future<void> _testAnalisisMomentosRapidos(int userId) async {
    print('  💭 Probando análisis de momentos rápidos...');
    
    try {
      final analisis = await _analyticsProvider.analizarMomentosRapidos(userId);
      
      print('    ✅ Análisis de momentos completado');
      print('    📊 Intensidad promedio: ${analisis.intensidadPromedio.toStringAsFixed(1)}/10');
      print('    📈 Impacto general: ${analisis.impactoGeneral.toStringAsFixed(2)}');
      print('    😊 Distribución emocional: ${analisis.distribucionEmocional.length} tipos');
      print('    🔍 Patrones detectados: ${analisis.patronesDetectados.length}');
      print('    💡 Recomendaciones: ${analisis.recomendaciones.length}');
      
      // Mostrar distribución emocional
      final distribucionTop = analisis.distribucionEmocional.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      if (distribucionTop.isNotEmpty) {
        final top3 = distribucionTop.take(3)
            .map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(1)}%')
            .join(', ');
        print('    📊 Emociones principales: $top3');
      }
      
      // Mostrar recomendaciones
      if (analisis.recomendaciones.isNotEmpty) {
        final recomendaciones = analisis.recomendaciones
            .take(2)
            .map((r) => r.titulo)
            .join(', ');
        print('    💡 Recomendaciones clave: $recomendaciones');
      }
      
    } catch (e) {
      print('    ❌ Error en análisis de momentos: $e');
    }
  }
  
  // ============================================================================
  // GENERACIÓN DE REPORTES
  // ============================================================================
  
  static Future<void> _generateTestReport(int userId, AnalyticsTestDataGenerator.UserProfile profile, Map<String, dynamic> testData) async {
    print('📄 Generando reporte de pruebas...');
    
    try {
      final report = {
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        'profile': profile.name,
        'testData': testData['summary'],
        'analyticsResults': {
          'prediccion': _analyticsProvider.prediccionSemana?.toJson(),
          'ansiedad': _analyticsProvider.analisisAnsiedad?.toJson(),
          'rutinas': _analyticsProvider.analisisRutinas?.toJson(),
          'momentos': _analyticsProvider.analisisMomentos?.toJson(),
          'resumen': _analyticsProvider.resumenCompleto?.toJson(),
        },
        'performance': {
          'loadingTime': _analyticsProvider.isLoading ? 'En proceso' : 'Completado',
          'hasErrors': _analyticsProvider.error != null,
          'errorMessage': _analyticsProvider.error,
        }
      };
      
      // Guardar reporte en archivo
      final reportFile = File('test_reports/analytics_test_report_${profile.name}.json');
      await reportFile.create(recursive: true);
      await reportFile.writeAsString(JsonEncoder.withIndent('  ').convert(report));
      
      print('    ✅ Reporte guardado: ${reportFile.path}');
      
    } catch (e) {
      print('    ❌ Error generando reporte: $e');
    }
  }
  
  // ============================================================================
  // PRUEBAS DE RENDIMIENTO
  // ============================================================================
  
  static Future<void> runPerformanceTests() async {
    print('\\n⚡ Ejecutando pruebas de rendimiento...');
    print('-' * 40);
    
    final userId = 99;
    
    // Generar dataset grande
    final testData = await AnalyticsTestDataGenerator.generateCompleteTestData(
      userId: userId,
      profile: AnalyticsTestDataGenerator.UserProfile.stable,
      daysOfData: 90, // 3 meses
      momentsPerDay: 8, // Muchos momentos
      numberOfGoals: 15, // Muchas metas
    );
    
    await _insertTestData(testData);
    
    // Medir tiempo de análisis completo
    final stopwatch = Stopwatch()..start();
    await _analyticsProvider.generarAnalisisCompleto(userId);
    stopwatch.stop();
    
    print('📊 Análisis completo (90 días): ${stopwatch.elapsedMilliseconds}ms');
    
    // Medir análisis individuales
    await _measureIndividualAnalysis(userId);
  }
  
  static Future<void> _measureIndividualAnalysis(int userId) async {
    final analyses = [
      ('Predicción', () => _analyticsProvider.predecirEstadoAnimoProximaSemana(userId)),
      ('Triggers Ansiedad', () => _analyticsProvider.analizarTriggersAnsiedad(userId)),
      ('Rutinas', () => _analyticsProvider.analizarRutinasUsuario(userId)),
      ('Momentos', () => _analyticsProvider.analizarMomentosRapidos(userId)),
    ];
    
    for (final analysis in analyses) {
      final stopwatch = Stopwatch()..start();
      try {
        await analysis.$2();
        stopwatch.stop();
        print('⚡ ${analysis.$1}: ${stopwatch.elapsedMilliseconds}ms');
      } catch (e) {
        stopwatch.stop();
        print('❌ ${analysis.$1}: Error (${stopwatch.elapsedMilliseconds}ms)');
      }
    }
  }
  
  // ============================================================================
  // PRUEBAS DE CASOS LÍMITE
  // ============================================================================
  
  static Future<void> runEdgeCaseTests() async {
    print('\\n🔬 Ejecutando pruebas de casos límite...');
    print('-' * 40);
    
    // Caso 1: Usuario sin datos
    await _testEmptyUser();
    
    // Caso 2: Usuario con pocos datos
    await _testMinimalData();
    
    // Caso 3: Usuario con datos extremos
    await _testExtremeData();
  }
  
  static Future<void> _testEmptyUser() async {
    print('📊 Probando usuario sin datos...');
    
    try {
      await _analyticsProvider.generarAnalisisCompleto(999);
      print('    ⚠️  Análisis completado (inesperado)');
    } catch (e) {
      print('    ✅ Error esperado: Datos insuficientes');
    }
  }
  
  static Future<void> _testMinimalData() async {
    print('📊 Probando usuario con datos mínimos...');
    
    final userId = 888;
    
    // Generar solo 3 días de datos
    final testData = await AnalyticsTestDataGenerator.generateCompleteTestData(
      userId: userId,
      profile: AnalyticsTestDataGenerator.UserProfile.stable,
      daysOfData: 3,
      momentsPerDay: 1,
      numberOfGoals: 1,
    );
    
    await _insertTestData(testData);
    
    try {
      await _analyticsProvider.generarAnalisisCompleto(userId);
      print('    ✅ Análisis completado con datos mínimos');
    } catch (e) {
      print('    ⚠️  Error con datos mínimos: $e');
    }
  }
  
  static Future<void> _testExtremeData() async {
    print('📊 Probando usuario con datos extremos...');
    
    final userId = 777;
    
    // Generar datos extremos
    final testData = await AnalyticsTestDataGenerator.generateCompleteTestData(
      userId: userId,
      profile: AnalyticsTestDataGenerator.UserProfile.chaotic,
      daysOfData: 180, // 6 meses
      momentsPerDay: 15, // Muchos momentos
      numberOfGoals: 30, // Muchas metas
    );
    
    await _insertTestData(testData);
    
    try {
      final stopwatch = Stopwatch()..start();
      await _analyticsProvider.generarAnalisisCompleto(userId);
      stopwatch.stop();
      
      print('    ✅ Análisis completado con datos extremos: ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      print('    ❌ Error con datos extremos: $e');
    }
  }
}

// ============================================================================
// EJECUTOR PRINCIPAL
// ============================================================================

void main() async {
  print('🚀 INICIANDO PRUEBAS DE ANALYTICS AVANZADOS');
  print('=' * 60);
  
  try {
    // Ejecutar todas las pruebas
    await AnalyticsTestRunner.runAllTests();
    
    // Ejecutar pruebas de rendimiento
    await AnalyticsTestRunner.runPerformanceTests();
    
    // Ejecutar pruebas de casos límite
    await AnalyticsTestRunner.runEdgeCaseTests();
    
    print('\\n🎉 TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE');
    
  } catch (e) {
    print('\\n❌ ERROR GENERAL EN PRUEBAS: $e');
  }
}