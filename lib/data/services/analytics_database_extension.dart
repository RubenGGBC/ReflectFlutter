// ============================================================================
// data/services/analytics_database_extension.dart
// EXTENSIÓN DE BASE DE DATOS PARA ANÁLISIS AVANZADOS
// ============================================================================

import 'dart:math';
import 'package:logger/logger.dart';
import 'optimized_database_service.dart';

extension AnalyticsDatabaseExtension on OptimizedDatabaseService {
  static final Logger _logger = Logger();

  // ============================================================================
  // ANÁLISIS DE TENDENCIAS TEMPORALES
  // ============================================================================
  
  Future<List<Map<String, dynamic>>> obtenerTendenciasEstadoAnimo(
    int userId, {
    int diasAtras = 30,
  }) async {
    final db = await database;
    
    final results = await db.rawQuery('''
      SELECT 
        DATE(entry_date) as fecha,
        mood_score,
        energy_level,
        stress_level,
        sleep_quality,
        anxiety_level,
        motivation_level,
        social_interaction,
        physical_activity,
        work_productivity,
        sleep_hours,
        water_intake,
        meditation_minutes,
        exercise_minutes,
        screen_time_hours,
        emotional_stability,
        focus_level,
        life_satisfaction
      FROM daily_entries 
      WHERE user_id = ? 
        AND entry_date >= DATE('now', '-$diasAtras days')
      ORDER BY entry_date DESC
    ''', [userId]);
    
    return results;
  }

  Future<Map<String, double>> calcularCorrelacionesAvanzadas(int userId) async {
    final datos = await obtenerTendenciasEstadoAnimo(userId);
    
    if (datos.length < 5) {
      return {};
    }
    
    final correlaciones = <String, double>{};
    final moodScores = datos.map((d) => (d['mood_score'] as int? ?? 5).toDouble()).toList();
    
    // Correlaciones con diferentes métricas
    final metricas = [
      'energy_level', 'stress_level', 'sleep_quality', 'anxiety_level',
      'motivation_level', 'social_interaction', 'physical_activity',
      'work_productivity', 'sleep_hours', 'water_intake', 'meditation_minutes',
      'exercise_minutes', 'screen_time_hours', 'emotional_stability',
      'focus_level', 'life_satisfaction'
    ];
    
    for (final metrica in metricas) {
      final valores = datos.map((d) => (d[metrica] as num? ?? 5).toDouble()).toList();
      correlaciones[metrica] = _calcularCorrelacionPearson(moodScores, valores);
    }
    
    return correlaciones;
  }

  // ============================================================================
  // ANÁLISIS DE PATRONES TEMPORALES
  // ============================================================================
  
  Future<Map<String, dynamic>> analizarPatronesHorarios(int userId) async {
    final db = await database;
    
    // Analizar momentos por hora del día
    final momentosPorHora = await db.rawQuery('''
      SELECT 
        SUBSTR(time_str, 1, 2) as hora,
        COUNT(*) as frecuencia,
        AVG(intensity) as intensidad_promedio,
        SUM(CASE WHEN type = 'positive' THEN 1 ELSE 0 END) as positivos,
        SUM(CASE WHEN type = 'negative' THEN 1 ELSE 0 END) as negativos
      FROM interactive_moments 
      WHERE user_id = ?
        AND created_at >= DATE('now', '-30 days')
      GROUP BY hora
      ORDER BY hora
    ''', [userId]);
    
    // Analizar entradas por día de la semana
    final entradasPorDia = await db.rawQuery('''
      SELECT 
        CAST(strftime('%w', entry_date) AS INTEGER) as dia_semana,
        AVG(mood_score) as mood_promedio,
        AVG(energy_level) as energia_promedio,
        AVG(stress_level) as estres_promedio,
        COUNT(*) as total_entradas
      FROM daily_entries 
      WHERE user_id = ?
        AND entry_date >= DATE('now', '-60 days')
      GROUP BY dia_semana
      ORDER BY dia_semana
    ''', [userId]);
    
    return {
      'momentosPorHora': momentosPorHora,
      'entradasPorDia': entradasPorDia,
    };
  }

  // ============================================================================
  // DETECCIÓN DE TRIGGERS DE ANSIEDAD
  // ============================================================================
  
  Future<List<Map<String, dynamic>>> detectarTriggersAnsiedad(int userId) async {
    final db = await database;
    
    // Buscar días con alta ansiedad y sus características
    final diasAltaAnsiedad = await db.rawQuery('''
      SELECT 
        entry_date,
        anxiety_level,
        stress_level,
        sleep_quality,
        work_productivity,
        social_interaction,
        screen_time_hours,
        exercise_minutes,
        free_reflection
      FROM daily_entries 
      WHERE user_id = ? 
        AND anxiety_level >= 7
        AND entry_date >= DATE('now', '-45 days')
      ORDER BY entry_date DESC
    ''', [userId]);
    
    // Buscar momentos negativos con alta intensidad
    final momentosNegativos = await db.rawQuery('''
      SELECT 
        entry_date,
        time_str,
        text,
        intensity,
        category
      FROM interactive_moments 
      WHERE user_id = ? 
        AND type = 'negative'
        AND intensity >= 7
        AND entry_date >= DATE('now', '-30 days')
      ORDER BY entry_date DESC, time_str DESC
    ''', [userId]);
    
    return [
      ...diasAltaAnsiedad.map((d) => {...d, 'tipo': 'dia_ansiedad'}),
      ...momentosNegativos.map((m) => {...m, 'tipo': 'momento_negativo'}),
    ];
  }

  // ============================================================================
  // ANÁLISIS DE RUTINAS
  // ============================================================================
  
  Future<Map<String, dynamic>> analizarRutinasDetectadas(int userId) async {
    final db = await database;
    
    // Analizar consistencia en horarios de sueño
    final patronesSueno = await db.rawQuery('''
      SELECT 
        sleep_hours,
        sleep_quality,
        COUNT(*) as frecuencia,
        AVG(mood_score) as mood_correlacionado
      FROM daily_entries 
      WHERE user_id = ? 
        AND sleep_hours IS NOT NULL
        AND entry_date >= DATE('now', '-30 days')
      GROUP BY ROUND(sleep_hours, 1), sleep_quality
      HAVING frecuencia >= 3
      ORDER BY frecuencia DESC
    ''', [userId]);
    
    // Analizar rutinas de ejercicio
    final patronesEjercicio = await db.rawQuery('''
      SELECT 
        exercise_minutes,
        physical_activity,
        COUNT(*) as frecuencia,
        AVG(energy_level) as energia_correlacionada,
        AVG(mood_score) as mood_correlacionado
      FROM daily_entries 
      WHERE user_id = ? 
        AND exercise_minutes > 0
        AND entry_date >= DATE('now', '-30 days')
      GROUP BY ROUND(exercise_minutes, -1), physical_activity
      HAVING frecuencia >= 3
      ORDER BY frecuencia DESC
    ''', [userId]);
    
    // Analizar rutinas de meditación
    final patronesMeditacion = await db.rawQuery('''
      SELECT 
        meditation_minutes,
        COUNT(*) as frecuencia,
        AVG(emotional_stability) as estabilidad_correlacionada,
        AVG(anxiety_level) as ansiedad_correlacionada
      FROM daily_entries 
      WHERE user_id = ? 
        AND meditation_minutes > 0
        AND entry_date >= DATE('now', '-30 days')
      GROUP BY ROUND(meditation_minutes, -1)
      HAVING frecuencia >= 3
      ORDER BY frecuencia DESC
    ''', [userId]);
    
    return {
      'patronesSueno': patronesSueno,
      'patronesEjercicio': patronesEjercicio,
      'patronesMeditacion': patronesMeditacion,
    };
  }

  // ============================================================================
  // ANÁLISIS DE MOMENTOS RÁPIDOS
  // ============================================================================
  
  Future<Map<String, dynamic>> analizarMomentosRapidos(int userId) async {
    final db = await database;
    
    // Distribución emocional
    final distribucionEmocional = await db.rawQuery('''
      SELECT 
        type,
        COUNT(*) as total,
        AVG(intensity) as intensidad_promedio,
        category,
        COUNT(DISTINCT entry_date) as dias_activos
      FROM interactive_moments 
      WHERE user_id = ?
        AND entry_date >= DATE('now', '-30 days')
      GROUP BY type, category
      ORDER BY total DESC
    ''', [userId]);
    
    // Momentos por hora del día
    final momentosPorHora = await db.rawQuery('''
      SELECT 
        SUBSTR(time_str, 1, 2) as hora,
        type,
        COUNT(*) as frecuencia,
        AVG(intensity) as intensidad_promedio
      FROM interactive_moments 
      WHERE user_id = ?
        AND entry_date >= DATE('now', '-30 days')
      GROUP BY hora, type
      ORDER BY hora
    ''', [userId]);
    
    // Evolución temporal de momentos
    final evolucionTemporal = await db.rawQuery('''
      SELECT 
        DATE(entry_date) as fecha,
        type,
        COUNT(*) as total,
        AVG(intensity) as intensidad_promedio
      FROM interactive_moments 
      WHERE user_id = ?
        AND entry_date >= DATE('now', '-14 days')
      GROUP BY DATE(entry_date), type
      ORDER BY fecha DESC
    ''', [userId]);
    
    return {
      'distribucionEmocional': distribucionEmocional,
      'momentosPorHora': momentosPorHora,
      'evolucionTemporal': evolucionTemporal,
    };
  }

  // ============================================================================
  // MÉTRICAS AVANZADAS DE BIENESTAR
  // ============================================================================
  
  Future<Map<String, dynamic>> calcularMetricasBienestar(int userId) async {
    final db = await database;
    
    // Métricas generales
    final metricas = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_entradas,
        AVG(mood_score) as mood_promedio,
        AVG(energy_level) as energia_promedio,
        AVG(stress_level) as estres_promedio,
        AVG(sleep_quality) as sueño_promedio,
        AVG(anxiety_level) as ansiedad_promedio,
        AVG(motivation_level) as motivacion_promedio,
        AVG(social_interaction) as social_promedio,
        AVG(physical_activity) as actividad_promedio,
        AVG(work_productivity) as productividad_promedio,
        AVG(sleep_hours) as horas_sueño_promedio,
        AVG(water_intake) as agua_promedio,
        AVG(meditation_minutes) as meditacion_promedio,
        AVG(exercise_minutes) as ejercicio_promedio,
        AVG(screen_time_hours) as pantalla_promedio,
        AVG(emotional_stability) as estabilidad_promedio,
        AVG(focus_level) as foco_promedio,
        AVG(life_satisfaction) as satisfaccion_promedio,
        MIN(entry_date) as primera_entrada,
        MAX(entry_date) as ultima_entrada
      FROM daily_entries 
      WHERE user_id = ?
        AND entry_date >= DATE('now', '-30 days')
    ''', [userId]);
    
    // Tendencias (comparar últimos 7 días vs 7 días anteriores)
    final tendencias = await db.rawQuery('''
      SELECT 
        'ultimos_7' as periodo,
        AVG(mood_score) as mood_promedio,
        AVG(energy_level) as energia_promedio,
        AVG(stress_level) as estres_promedio,
        AVG(anxiety_level) as ansiedad_promedio
      FROM daily_entries 
      WHERE user_id = ?
        AND entry_date >= DATE('now', '-7 days')
      
      UNION ALL
      
      SELECT 
        'anteriores_7' as periodo,
        AVG(mood_score) as mood_promedio,
        AVG(energy_level) as energia_promedio,
        AVG(stress_level) as estres_promedio,
        AVG(anxiety_level) as ansiedad_promedio
      FROM daily_entries 
      WHERE user_id = ?
        AND entry_date >= DATE('now', '-14 days')
        AND entry_date < DATE('now', '-7 days')
    ''', [userId, userId]);
    
    return {
      'metricas': metricas.isNotEmpty ? metricas.first : {},
      'tendencias': tendencias,
    };
  }

  // ============================================================================
  // PREDICCIONES Y RECOMENDACIONES
  // ============================================================================
  
  Future<Map<String, dynamic>> generarRecomendacionesPersonalizadas(int userId) async {
    final correlaciones = await calcularCorrelacionesAvanzadas(userId);
    final patrones = await analizarPatronesHorarios(userId);
    final rutinas = await analizarRutinasDetectadas(userId);
    
    final recomendaciones = <String>[];
    
    // Recomendaciones basadas en correlaciones
    if (correlaciones['sleep_quality'] != null && correlaciones['sleep_quality']! > 0.3) {
      recomendaciones.add('Mantener rutina de sueño consistente mejora significativamente tu estado de ánimo');
    }
    
    if (correlaciones['exercise_minutes'] != null && correlaciones['exercise_minutes']! > 0.2) {
      recomendaciones.add('El ejercicio regular tiene un impacto positivo en tu bienestar');
    }
    
    if (correlaciones['meditation_minutes'] != null && correlaciones['meditation_minutes']! > 0.2) {
      recomendaciones.add('La meditación ayuda a mantener tu estabilidad emocional');
    }
    
    if (correlaciones['stress_level'] != null && correlaciones['stress_level']! < -0.3) {
      recomendaciones.add('Enfocarte en reducir el estrés puede mejorar tu estado de ánimo general');
    }
    
    // Recomendaciones basadas en patrones temporales
    final momentosPorHora = patrones['momentosPorHora'] as List<Map<String, dynamic>>;
    final horasMasPositivas = momentosPorHora
        .where((m) => (m['positivos'] as int? ?? 0) > (m['negativos'] as int? ?? 0))
        .map((m) => m['hora'] as String)
        .toList();
    
    if (horasMasPositivas.isNotEmpty) {
      recomendaciones.add('Tus mejores momentos tienden a ser entre las ${horasMasPositivas.join(', ')} horas');
    }
    
    return {
      'recomendaciones': recomendaciones,
      'correlaciones': correlaciones,
      'patrones': patrones,
      'rutinas': rutinas,
    };
  }

  // ============================================================================
  // ANÁLISIS DE PROGRESO DE METAS
  // ============================================================================
  
  Future<Map<String, dynamic>> analizarProgresoMetas(int userId) async {
    final db = await database;
    
    // Obtener todas las metas del usuario
    final metas = await db.rawQuery('''
      SELECT 
        id,
        title,
        description,
        type,
        status,
        target_value,
        current_value,
        created_at,
        completed_at
      FROM user_goals 
      WHERE user_id = ?
      ORDER BY created_at DESC
    ''', [userId]);
    
    // Calcular métricas de progreso
    final metasActivas = metas.where((m) => m['status'] == 'active').length;
    final metasCompletadas = metas.where((m) => m['status'] == 'completed').length;
    final metasArchivadas = metas.where((m) => m['status'] == 'archived').length;
    
    // Calcular progreso promedio
    double progresoPromedio = 0.0;
    if (metasActivas > 0) {
      final progresoTotal = metas
          .where((m) => m['status'] == 'active')
          .map((m) => (m['current_value'] as double) / (m['target_value'] as double))
          .fold<double>(0.0, (a, b) => a + b);
      progresoPromedio = progresoTotal / metasActivas;
    }
    
    return {
      'totalMetas': metas.length,
      'metasActivas': metasActivas,
      'metasCompletadas': metasCompletadas,
      'metasArchivadas': metasArchivadas,
      'progresoPromedio': progresoPromedio,
      'metas': metas,
    };
  }

  // ============================================================================
  // EXPORTACIÓN DE DATOS PARA ANÁLISIS
  // ============================================================================
  
  Future<Map<String, dynamic>> exportarDatosCompletos(int userId) async {
    final entradas = await obtenerTendenciasEstadoAnimo(userId, diasAtras: 90);
    final momentos = await analizarMomentosRapidos(userId);
    final rutinas = await analizarRutinasDetectadas(userId);
    final metas = await analizarProgresoMetas(userId);
    final metricas = await calcularMetricasBienestar(userId);
    
    return {
      'userId': userId,
      'fechaExportacion': DateTime.now().toIso8601String(),
      'entradas': entradas,
      'momentos': momentos,
      'rutinas': rutinas,
      'metas': metas,
      'metricas': metricas,
    };
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================
  
  double _calcularCorrelacionPearson(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return 0.0;
    
    final n = x.length;
    final sumaX = x.fold<double>(0.0, (a, b) => a + b);
    final sumaY = y.fold<double>(0.0, (a, b) => a + b);
    final sumaXY = List.generate(n, (i) => x[i] * y[i]).fold<double>(0.0, (a, b) => a + b);
    final sumaX2 = x.map((v) => v * v).fold<double>(0.0, (a, b) => a + b);
    final sumaY2 = y.map((v) => v * v).fold<double>(0.0, (a, b) => a + b);
    
    final numerador = n * sumaXY - sumaX * sumaY;
    final denominador = sqrt((n * sumaX2 - sumaX * sumaX) * (n * sumaY2 - sumaY * sumaY));
    
    return denominador == 0 ? 0.0 : numerador / denominador;
  }

  // ============================================================================
  // LIMPIEZA Y MANTENIMIENTO
  // ============================================================================
  
  Future<void> limpiarDatosAntiguos(int userId, {int diasAMantener = 365}) async {
    final db = await database;
    
    try {
      // Limpiar entradas antiguas
      await db.delete(
        'daily_entries',
        where: 'user_id = ? AND entry_date < DATE("now", "-$diasAMantener days")',
        whereArgs: [userId],
      );
      
      // Limpiar momentos antiguos
      await db.delete(
        'interactive_moments',
        where: 'user_id = ? AND entry_date < DATE("now", "-$diasAMantener days")',
        whereArgs: [userId],
      );
      
      _logger.i('✅ Limpieza de datos antiguos completada para usuario $userId');
    } catch (e) {
      _logger.e('❌ Error en limpieza de datos: $e');
    }
  }

  Future<void> optimizarBaseDatos() async {
    final db = await database;
    
    try {
      // Ejecutar VACUUM para optimizar el archivo de base de datos
      await db.execute('VACUUM');
      
      // Actualizar estadísticas
      await db.execute('ANALYZE');
      
      _logger.i('✅ Optimización de base de datos completada');
    } catch (e) {
      _logger.e('❌ Error en optimización de base de datos: $e');
    }
  }
}