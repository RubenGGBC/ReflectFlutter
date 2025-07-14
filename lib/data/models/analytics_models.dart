// ============================================================================
// data/models/analytics_models.dart - MODELOS AVANZADOS DE ANÁLISIS
// ============================================================================

import 'dart:math';

// ============================================================================
// MODELO DE PREDICCIÓN DE ESTADO DE ÁNIMO
// ============================================================================
class PrediccionEstadoAnimo {
  final DateTime fecha;
  final double estadoAnimoPredicto;
  final double confianza;
  final List<FactorInfluencia> factoresInfluencia;
  final String tendencia; // 'ascendente', 'descendente', 'estable'
  final double probabilidadDepresion;
  final double probabilidadAnsiedad;

  const PrediccionEstadoAnimo({
    required this.fecha,
    required this.estadoAnimoPredicto,
    required this.confianza,
    required this.factoresInfluencia,
    required this.tendencia,
    required this.probabilidadDepresion,
    required this.probabilidadAnsiedad,
  });

  Map<String, dynamic> toJson() => {
    'fecha': fecha.toIso8601String(),
    'estadoAnimoPredicto': estadoAnimoPredicto,
    'confianza': confianza,
    'factoresInfluencia': factoresInfluencia.map((f) => f.toJson()).toList(),
    'tendencia': tendencia,
    'probabilidadDepresion': probabilidadDepresion,
    'probabilidadAnsiedad': probabilidadAnsiedad,
  };

  factory PrediccionEstadoAnimo.fromJson(Map<String, dynamic> json) =>
      PrediccionEstadoAnimo(
        fecha: DateTime.parse(json['fecha']),
        estadoAnimoPredicto: json['estadoAnimoPredicto'].toDouble(),
        confianza: json['confianza'].toDouble(),
        factoresInfluencia: (json['factoresInfluencia'] as List)
            .map((f) => FactorInfluencia.fromJson(f))
            .toList(),
        tendencia: json['tendencia'],
        probabilidadDepresion: json['probabilidadDepresion'].toDouble(),
        probabilidadAnsiedad: json['probabilidadAnsiedad'].toDouble(),
      );

  get recomendaciones => recomendaciones;
}

// ============================================================================
// MODELO DE FACTOR DE INFLUENCIA
// ============================================================================
class FactorInfluencia {
  final String nombre;
  final double impacto; // -1.0 a 1.0
  final double importancia; // 0.0 a 1.0
  final String categoria;
  final Map<String, dynamic> detalles;

  const FactorInfluencia({
    required this.nombre,
    required this.impacto,
    required this.importancia,
    required this.categoria,
    required this.detalles,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'impacto': impacto,
    'importancia': importancia,
    'categoria': categoria,
    'detalles': detalles,
  };

  factory FactorInfluencia.fromJson(Map<String, dynamic> json) =>
      FactorInfluencia(
        nombre: json['nombre'],
        impacto: json['impacto'].toDouble(),
        importancia: json['importancia'].toDouble(),
        categoria: json['categoria'],
        detalles: json['detalles'],
      );
}

// ============================================================================
// MODELO DE ANÁLISIS DE RUTINAS
// ============================================================================
class AnalisisRutinas {
  final Map<String, PatronTemporal> patronesDiarios;
  final Map<String, PatronTemporal> patronesSemanales;
  final List<RutinaDetectada> rutinasDetectadas;
  final double consistenciaGeneral; // 0.0 a 1.0
  final List<SugerenciaRutina> sugerencias;

  const AnalisisRutinas({
    required this.patronesDiarios,
    required this.patronesSemanales,
    required this.rutinasDetectadas,
    required this.consistenciaGeneral,
    required this.sugerencias,
  });

  Map<String, dynamic> toJson() => {
    'patronesDiarios': patronesDiarios.map((k, v) => MapEntry(k, v.toJson())),
    'patronesSemanales': patronesSemanales.map((k, v) => MapEntry(k, v.toJson())),
    'rutinasDetectadas': rutinasDetectadas.map((r) => r.toJson()).toList(),
    'consistenciaGeneral': consistenciaGeneral,
    'sugerencias': sugerencias.map((s) => s.toJson()).toList(),
  };

  factory AnalisisRutinas.fromJson(Map<String, dynamic> json) =>
      AnalisisRutinas(
        patronesDiarios: (json['patronesDiarios'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, PatronTemporal.fromJson(v))),
        patronesSemanales: (json['patronesSemanales'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, PatronTemporal.fromJson(v))),
        rutinasDetectadas: (json['rutinasDetectadas'] as List)
            .map((r) => RutinaDetectada.fromJson(r))
            .toList(),
        consistenciaGeneral: json['consistenciaGeneral'].toDouble(),
        sugerencias: (json['sugerencias'] as List)
            .map((s) => SugerenciaRutina.fromJson(s))
            .toList(),
      );
}

// ============================================================================
// MODELO DE PATRÓN TEMPORAL
// ============================================================================
class PatronTemporal {
  final String nombre;
  final Map<String, double> valores; // hora/día -> valor
  final double intensidadPromedio;
  final String tipoPatron; // 'matutino', 'vespertino', 'nocturno', 'consistente'
  final double regularidad; // 0.0 a 1.0
  final List<String> horasOptimas;

  const PatronTemporal({
    required this.nombre,
    required this.valores,
    required this.intensidadPromedio,
    required this.tipoPatron,
    required this.regularidad,
    required this.horasOptimas,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'valores': valores,
    'intensidadPromedio': intensidadPromedio,
    'tipoPatron': tipoPatron,
    'regularidad': regularidad,
    'horasOptimas': horasOptimas,
  };

  factory PatronTemporal.fromJson(Map<String, dynamic> json) =>
      PatronTemporal(
        nombre: json['nombre'],
        valores: Map<String, double>.from(json['valores']),
        intensidadPromedio: json['intensidadPromedio'].toDouble(),
        tipoPatron: json['tipoPatron'],
        regularidad: json['regularidad'].toDouble(),
        horasOptimas: List<String>.from(json['horasOptimas']),
      );
}

// ============================================================================
// MODELO DE RUTINA DETECTADA
// ============================================================================
class RutinaDetectada {
  final String nombre;
  final String descripcion;
  final double frecuencia; // 0.0 a 1.0
  final List<String> actividades;
  final String horario; // 'mañana', 'tarde', 'noche'
  final double impactoEstadoAnimo;
  final Map<String, dynamic> estadisticas;

  const RutinaDetectada({
    required this.nombre,
    required this.descripcion,
    required this.frecuencia,
    required this.actividades,
    required this.horario,
    required this.impactoEstadoAnimo,
    required this.estadisticas,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'frecuencia': frecuencia,
    'actividades': actividades,
    'horario': horario,
    'impactoEstadoAnimo': impactoEstadoAnimo,
    'estadisticas': estadisticas,
  };

  factory RutinaDetectada.fromJson(Map<String, dynamic> json) =>
      RutinaDetectada(
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        frecuencia: json['frecuencia'].toDouble(),
        actividades: List<String>.from(json['actividades']),
        horario: json['horario'],
        impactoEstadoAnimo: json['impactoEstadoAnimo'].toDouble(),
        estadisticas: json['estadisticas'],
      );
}

// ============================================================================
// MODELO DE SUGERENCIA DE RUTINA
// ============================================================================
class SugerenciaRutina {
  final String titulo;
  final String descripcion;
  final String categoria;
  final double impactoEstimado;
  final String dificultad; // 'baja', 'media', 'alta'
  final List<String> pasos;
  final String horarioRecomendado;

  const SugerenciaRutina({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.impactoEstimado,
    required this.dificultad,
    required this.pasos,
    required this.horarioRecomendado,
  });

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'descripcion': descripcion,
    'categoria': categoria,
    'impactoEstimado': impactoEstimado,
    'dificultad': dificultad,
    'pasos': pasos,
    'horarioRecomendado': horarioRecomendado,
  };

  factory SugerenciaRutina.fromJson(Map<String, dynamic> json) =>
      SugerenciaRutina(
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        categoria: json['categoria'],
        impactoEstimado: json['impactoEstimado'].toDouble(),
        dificultad: json['dificultad'],
        pasos: List<String>.from(json['pasos']),
        horarioRecomendado: json['horarioRecomendado'],
      );
}

// ============================================================================
// MODELO DE ANÁLISIS DE TRIGGERS DE ANSIEDAD
// ============================================================================
class AnalisisTriggersAnsiedad {
  final List<TriggerAnsiedad> triggersDetectados;
  final Map<String, double> patronesTemporales;
  final double nivelAnsiedadPromedio;
  final List<EstrategiaManejo> estrategiasRecomendadas;
  final Map<String, int> frecuenciaTriggers;

  const AnalisisTriggersAnsiedad({
    required this.triggersDetectados,
    required this.patronesTemporales,
    required this.nivelAnsiedadPromedio,
    required this.estrategiasRecomendadas,
    required this.frecuenciaTriggers,
  });

  Map<String, dynamic> toJson() => {
    'triggersDetectados': triggersDetectados.map((t) => t.toJson()).toList(),
    'patronesTemporales': patronesTemporales,
    'nivelAnsiedadPromedio': nivelAnsiedadPromedio,
    'estrategiasRecomendadas': estrategiasRecomendadas.map((e) => e.toJson()).toList(),
    'frecuenciaTriggers': frecuenciaTriggers,
  };

  factory AnalisisTriggersAnsiedad.fromJson(Map<String, dynamic> json) =>
      AnalisisTriggersAnsiedad(
        triggersDetectados: (json['triggersDetectados'] as List)
            .map((t) => TriggerAnsiedad.fromJson(t))
            .toList(),
        patronesTemporales: Map<String, double>.from(json['patronesTemporales']),
        nivelAnsiedadPromedio: json['nivelAnsiedadPromedio'].toDouble(),
        estrategiasRecomendadas: (json['estrategiasRecomendadas'] as List)
            .map((e) => EstrategiaManejo.fromJson(e))
            .toList(),
        frecuenciaTriggers: Map<String, int>.from(json['frecuenciaTriggers']),
      );
}

// ============================================================================
// MODELO DE TRIGGER DE ANSIEDAD
// ============================================================================
class TriggerAnsiedad {
  final String nombre;
  final String categoria;
  final double intensidadPromedio;
  final List<DateTime> ocurrencias;
  final Map<String, dynamic> contexto;
  final double correlacionEstadoAnimo;

  const TriggerAnsiedad({
    required this.nombre,
    required this.categoria,
    required this.intensidadPromedio,
    required this.ocurrencias,
    required this.contexto,
    required this.correlacionEstadoAnimo,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'categoria': categoria,
    'intensidadPromedio': intensidadPromedio,
    'ocurrencias': ocurrencias.map((o) => o.toIso8601String()).toList(),
    'contexto': contexto,
    'correlacionEstadoAnimo': correlacionEstadoAnimo,
  };

  factory TriggerAnsiedad.fromJson(Map<String, dynamic> json) =>
      TriggerAnsiedad(
        nombre: json['nombre'],
        categoria: json['categoria'],
        intensidadPromedio: json['intensidadPromedio'].toDouble(),
        ocurrencias: (json['ocurrencias'] as List)
            .map((o) => DateTime.parse(o))
            .toList(),
        contexto: json['contexto'],
        correlacionEstadoAnimo: json['correlacionEstadoAnimo'].toDouble(),
      );
}

// ============================================================================
// MODELO DE ESTRATEGIA DE MANEJO
// ============================================================================
class EstrategiaManejo {
  final String nombre;
  final String descripcion;
  final String tipo; // 'respiracion', 'cognitiva', 'conductual'
  final double efectividadEstimada;
  final List<String> pasos;
  final String duracionEstimada;

  const EstrategiaManejo({
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.efectividadEstimada,
    required this.pasos,
    required this.duracionEstimada,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'tipo': tipo,
    'efectividadEstimada': efectividadEstimada,
    'pasos': pasos,
    'duracionEstimada': duracionEstimada,
  };

  factory EstrategiaManejo.fromJson(Map<String, dynamic> json) =>
      EstrategiaManejo(
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        tipo: json['tipo'],
        efectividadEstimada: json['efectividadEstimada'].toDouble(),
        pasos: List<String>.from(json['pasos']),
        duracionEstimada: json['duracionEstimada'],
      );
}

// ============================================================================
// MODELO DE ANÁLISIS DE MOMENTOS RÁPIDOS
// ============================================================================
class AnalisisMomentosRapidos {
  final Map<String, double> distribucionEmocional;
  final List<PatronMomento> patronesDetectados;
  final double intensidadPromedio;
  final Map<String, int> frecuenciaCategorias;
  final List<RecomendacionMomento> recomendaciones;
  final double impactoEstadoAnimoGeneral;

  const AnalisisMomentosRapidos({
    required this.distribucionEmocional,
    required this.patronesDetectados,
    required this.intensidadPromedio,
    required this.frecuenciaCategorias,
    required this.recomendaciones,
    required this.impactoEstadoAnimoGeneral,
  });

  Map<String, dynamic> toJson() => {
    'distribucionEmocional': distribucionEmocional,
    'patronesDetectados': patronesDetectados.map((p) => p.toJson()).toList(),
    'intensidadPromedio': intensidadPromedio,
    'frecuenciaCategorias': frecuenciaCategorias,
    'recomendaciones': recomendaciones.map((r) => r.toJson()).toList(),
    'impactoEstadoAnimoGeneral': impactoEstadoAnimoGeneral,
  };

  factory AnalisisMomentosRapidos.fromJson(Map<String, dynamic> json) =>
      AnalisisMomentosRapidos(
        distribucionEmocional: Map<String, double>.from(json['distribucionEmocional']),
        patronesDetectados: (json['patronesDetectados'] as List)
            .map((p) => PatronMomento.fromJson(p))
            .toList(),
        intensidadPromedio: json['intensidadPromedio'].toDouble(),
        frecuenciaCategorias: Map<String, int>.from(json['frecuenciaCategorias']),
        recomendaciones: (json['recomendaciones'] as List)
            .map((r) => RecomendacionMomento.fromJson(r))
            .toList(),
        impactoEstadoAnimoGeneral: json['impactoEstadoAnimoGeneral'].toDouble(),
      );
}

// ============================================================================
// MODELO DE PATRÓN DE MOMENTO
// ============================================================================
class PatronMomento {
  final String nombre;
  final String categoria;
  final List<String> horasComunes;
  final double intensidadPromedio;
  final double frecuencia;
  final String contextoComun;

  const PatronMomento({
    required this.nombre,
    required this.categoria,
    required this.horasComunes,
    required this.intensidadPromedio,
    required this.frecuencia,
    required this.contextoComun,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'categoria': categoria,
    'horasComunes': horasComunes,
    'intensidadPromedio': intensidadPromedio,
    'frecuencia': frecuencia,
    'contextoComun': contextoComun,
  };

  factory PatronMomento.fromJson(Map<String, dynamic> json) =>
      PatronMomento(
        nombre: json['nombre'],
        categoria: json['categoria'],
        horasComunes: List<String>.from(json['horasComunes']),
        intensidadPromedio: json['intensidadPromedio'].toDouble(),
        frecuencia: json['frecuencia'].toDouble(),
        contextoComun: json['contextoComun'],
      );
}

// ============================================================================
// MODELO DE RECOMENDACIÓN DE MOMENTO
// ============================================================================
class RecomendacionMomento {
  final String titulo;
  final String descripcion;
  final String categoria;
  final String horarioOptimo;
  final double impactoEstimado;
  final String dificultad;

  const RecomendacionMomento({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.horarioOptimo,
    required this.impactoEstimado,
    required this.dificultad,
  });

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'descripcion': descripcion,
    'categoria': categoria,
    'horarioOptimo': horarioOptimo,
    'impactoEstimado': impactoEstimado,
    'dificultad': dificultad,
  };

  factory RecomendacionMomento.fromJson(Map<String, dynamic> json) =>
      RecomendacionMomento(
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        categoria: json['categoria'],
        horarioOptimo: json['horarioOptimo'],
        impactoEstimado: json['impactoEstimado'].toDouble(),
        dificultad: json['dificultad'],
      );
}

// ============================================================================
// MODELO DE RESUMEN ANALÍTICO COMPLETO
// ============================================================================
class ResumenAnaliticoCompleto {
  final DateTime fechaGeneracion;
  final PrediccionEstadoAnimo prediccionSemana;
  final AnalisisRutinas analisisRutinas;
  final AnalisisTriggersAnsiedad analisisAnsiedad;
  final AnalisisMomentosRapidos analisisMomentos;
  final Map<String, dynamic> metricasGenerales;
  final List<String> alertas;
  final double scoreBienestarGeneral;

  const ResumenAnaliticoCompleto({
    required this.fechaGeneracion,
    required this.prediccionSemana,
    required this.analisisRutinas,
    required this.analisisAnsiedad,
    required this.analisisMomentos,
    required this.metricasGenerales,
    required this.alertas,
    required this.scoreBienestarGeneral,
  });

  Map<String, dynamic> toJson() => {
    'fechaGeneracion': fechaGeneracion.toIso8601String(),
    'prediccionSemana': prediccionSemana.toJson(),
    'analisisRutinas': analisisRutinas.toJson(),
    'analisisAnsiedad': analisisAnsiedad.toJson(),
    'analisisMomentos': analisisMomentos.toJson(),
    'metricasGenerales': metricasGenerales,
    'alertas': alertas,
    'scoreBienestarGeneral': scoreBienestarGeneral,
  };

  factory ResumenAnaliticoCompleto.fromJson(Map<String, dynamic> json) =>
      ResumenAnaliticoCompleto(
        fechaGeneracion: DateTime.parse(json['fechaGeneracion']),
        prediccionSemana: PrediccionEstadoAnimo.fromJson(json['prediccionSemana']),
        analisisRutinas: AnalisisRutinas.fromJson(json['analisisRutinas']),
        analisisAnsiedad: AnalisisTriggersAnsiedad.fromJson(json['analisisAnsiedad']),
        analisisMomentos: AnalisisMomentosRapidos.fromJson(json['analisisMomentos']),
        metricasGenerales: json['metricasGenerales'],
        alertas: List<String>.from(json['alertas']),
        scoreBienestarGeneral: json['scoreBienestarGeneral'].toDouble(),
      );
}