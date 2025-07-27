// ============================================================================
// lib/presentation/providers/hopecore_quotes_provider.dart - HOPECORE QUOTES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:math';

class HopecoreQuotesProvider with ChangeNotifier {
  final Logger _logger = Logger();
  final Random _random = Random();

  bool _isInitialized = false;

  // Frases motivacionales más directas y alentadoras
  static const Map<String, List<Map<String, String>>> _quotes = {
    'series': [
      {'quote': 'Tienes el poder de cambiar tu historia hoy mismo.', 'source': 'This Is Us'},
      {'quote': 'Eres más resiliente de lo que imaginas.', 'source': 'Grey\'s Anatomy'},
      {'quote': 'Tu luz interior puede iluminar cualquier oscuridad.', 'source': 'Stranger Things'},
      {'quote': 'La verdadera familia siempre cree en ti.', 'source': 'The Good Place'},
      {'quote': 'Crecer duele, pero te hace increíblemente fuerte.', 'source': 'Bojack Horseman'},
      {'quote': 'Cada paso atrás te prepara para un salto gigante.', 'source': 'Breaking Bad'},
      {'quote': 'Elegir ser valiente es elegir vivir plenamente.', 'source': 'Friends'},
      {'quote': 'Tu determinación es tu superpoder.', 'source': 'House of Cards'},
      {'quote': 'El amor que das siempre regresa multiplicado.', 'source': 'The 100'},
      {'quote': 'Cada vez que te levantas, te vuelves más fuerte.', 'source': 'Arrow'},
    ],
    'peliculas': [
      {'quote': 'La fuerza ya está dentro de ti, solo despiértala.', 'source': 'Star Wars'},
      {'quote': 'Tu vida está llena de momentos dulces esperándote.', 'source': 'Forrest Gump'},
      {'quote': 'Vive cada día con alegría y sin preocupaciones.', 'source': 'El Rey León'},
      {'quote': 'Tus sueños no tienen límites, ve por ellos.', 'source': 'Toy Story'},
      {'quote': 'Cada experiencia te ha hecho quien eres hoy.', 'source': 'Mr. Nobody'},
      {'quote': 'Tu pasado te enseñó, tu presente te empodera.', 'source': 'El Rey León'},
      {'quote': 'Hacer lo correcto siempre vale la pena.', 'source': 'Spider-Man'},
      {'quote': 'Tienes el poder de crear tu realidad.', 'source': 'Matrix'},
      {'quote': 'La esperanza vive en tu corazón para siempre.', 'source': 'Sueño de Fuga'},
      {'quote': 'Usa tu poder para hacer el bien en el mundo.', 'source': 'Spider-Man'},
      {'quote': 'Mañana trae infinitas posibilidades para ti.', 'source': 'Lo que el Viento se Llevó'},
      {'quote': 'Disfruta cada momento, la vida es un regalo.', 'source': 'Un Día Libre en la Vida de Ferris Bueller'},
    ],
    'libros': [
      {'quote': 'Tu camino único te llevará a destinos increíbles.', 'source': 'El Señor de los Anillos'},
      {'quote': 'Tienes magia real dentro de ti esperando brillar.', 'source': 'Harry Potter'},
      {'quote': 'Tu valentía inspira a otros a ser mejores.', 'source': 'Harry Potter'},
      {'quote': 'Puedes encontrar luz incluso en tus días más difíciles.', 'source': 'Harry Potter'},
      {'quote': 'Tus decisiones demuestran tu fuerza interior.', 'source': 'Harry Potter'},
      {'quote': 'Aprovecha cada minuto que tienes para ser feliz.', 'source': 'El Señor de los Anillos'},
      {'quote': 'Tu impacto en el mundo es más grande de lo que crees.', 'source': 'El Señor de los Anillos'},
      {'quote': 'Tu sonrisa tiene el poder de cambiar vidas.', 'source': 'El Principito'},
      {'quote': 'Tu corazón ve la belleza que otros no pueden.', 'source': 'El Principito'},
      {'quote': 'Eres la estrella más brillante en tu propia historia.', 'source': 'El Principito'},
      {'quote': 'Celebra cada momento hermoso que vives.', 'source': 'Dr. Seuss'},
      {'quote': 'Ser auténtico es tu mayor fortaleza.', 'source': 'El Guardián entre el Centeno'},
    ],
    'juegos': [
      {'quote': 'Cada decisión que tomas te hace más libre.', 'source': 'BioShock'},
      {'quote': 'Tu determinación puede mover montañas.', 'source': 'Undertale'},
      {'quote': 'La esperanza vive eternamente en tu alma.', 'source': 'Final Fantasy'},
      {'quote': 'Cada caída te prepara para volar más alto.', 'source': 'Dark Souls'},
      {'quote': 'Tu coraje convierte el miedo en aventura.', 'source': 'The Legend of Zelda'},
      {'quote': 'Cada final te acerca a un nuevo comienzo hermoso.', 'source': 'Life is Strange'},
      {'quote': 'Tu vida es extraña, única y absolutamente hermosa.', 'source': 'Life is Strange'},
      {'quote': 'Eres el faro que guía tu propio destino.', 'source': 'BioShock Infinite'},
      {'quote': 'El héroe que vive en ti nunca se rinde.', 'source': 'Overwatch'},
      {'quote': 'Tu corazón fuerte es tu mejor guía.', 'source': 'Kingdom Hearts'},
      {'quote': 'Tu luz interior siempre vence a la oscuridad.', 'source': 'Kingdom Hearts'},
      {'quote': 'Eres esa pequeña llama que ilumina todo a su paso.', 'source': 'Dark Souls'},
      {'quote': 'El tiempo está de tu lado para sanar y crecer.', 'source': 'Chrono Trigger'},
      {'quote': 'Tu corazón tiene una fuerza imparable.', 'source': 'Final Fantasy VII'},
    ],
    'general': [
      {'quote': 'Hoy es tu día para brillar con luz propia.', 'source': 'Hopecore'},
      {'quote': 'Tu potencial es infinito y real.', 'source': 'Hopecore'},
      {'quote': 'Cada paso que das te acerca a tus sueños.', 'source': 'Hopecore'},
      {'quote': 'Eres increíblemente más fuerte de lo que crees.', 'source': 'Hopecore'},
      {'quote': 'Tu esperanza es el combustible de tu alma.', 'source': 'Hopecore'},
      {'quote': 'Tu sonrisa ilumina el mundo de alguien más.', 'source': 'Hopecore'},
      {'quote': 'Estás escribiendo una historia extraordinaria.', 'source': 'Hopecore'},
      {'quote': 'Mañana te trae oportunidades increíbles.', 'source': 'Hopecore'},
      {'quote': 'Tienes todo lo necesario para lograr cosas increíbles.', 'source': 'Hopecore'},
      {'quote': 'Tu bondad crea ondas de felicidad en el mundo.', 'source': 'Hopecore'},
    ],
  };

  bool get isInitialized => _isInitialized;

  /// Inicializar provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    _logger.i('🌟 Inicializando HopecoreQuotesProvider');
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Obtener una frase aleatoria de cualquier categoría
  Map<String, String> getRandomQuote() {
    final allQuotes = <Map<String, String>>[];
    _quotes.values.forEach((categoryQuotes) {
      allQuotes.addAll(categoryQuotes);
    });
    
    if (allQuotes.isEmpty) {
      return {'quote': 'Eres increíble tal como eres', 'source': 'Hopecore'};
    }
    
    return allQuotes[_random.nextInt(allQuotes.length)];
  }

  /// Obtener una frase aleatoria de una categoría específica
  Map<String, String> getRandomQuoteFromCategory(String category) {
    final categoryQuotes = _quotes[category];
    if (categoryQuotes == null || categoryQuotes.isEmpty) {
      return getRandomQuote();
    }
    
    return categoryQuotes[_random.nextInt(categoryQuotes.length)];
  }

  /// Obtener todas las frases de una categoría
  List<Map<String, String>> getQuotesFromCategory(String category) {
    return _quotes[category] ?? [];
  }

  /// Obtener todas las categorías disponibles
  List<String> getAvailableCategories() {
    return _quotes.keys.toList();
  }

  /// Obtener frase motivacional según el estado de ánimo
  Map<String, String> getQuoteForMood(double moodScore) {
    if (moodScore <= 3) {
      // Para estados de ánimo bajos, frases más reconfortantes y directas
      final comfortingQuotes = [
        {'quote': 'Eres más fuerte que cualquier tormenta que enfrentes.', 'source': 'Hopecore'},
        {'quote': 'Tu valor no depende de cómo te sientes hoy.', 'source': 'Hopecore'},
        {'quote': 'Mañana será un día completamente nuevo para ti.', 'source': 'Hopecore'},
        {'quote': 'Tu luz interior sigue brillando, aunque no la veas.', 'source': 'Hopecore'},
        {'quote': 'Tienes todo lo que necesitas para superar esto.', 'source': 'Hopecore'},
      ];
      return comfortingQuotes[_random.nextInt(comfortingQuotes.length)];
    } else if (moodScore <= 6) {
      // Para estados neutros, frases de motivación directa
      final encouragingQuotes = [
        {'quote': 'Cada pequeño paso te acerca a algo grandioso.', 'source': 'Hopecore'},
        {'quote': 'Hoy puedes hacer algo increíble.', 'source': 'Hopecore'},
        {'quote': 'Tu progreso es real, aunque sea pequeño.', 'source': 'Hopecore'},
        {'quote': 'Confía en ti mismo, tienes razones para hacerlo.', 'source': 'Hopecore'},
      ];
      return encouragingQuotes[_random.nextInt(encouragingQuotes.length)];
    } else {
      // Para estados positivos, frases inspiradoras y empoderadoras
      final inspiringQuotes = [
        {'quote': 'Tu energía positiva contagia a todos a tu alrededor.', 'source': 'Hopecore'},
        {'quote': 'Estás viviendo tu mejor versión ahora mismo.', 'source': 'Hopecore'},
        {'quote': 'Tu felicidad inspira a otros a ser felices.', 'source': 'Hopecore'},
        {'quote': 'Tienes el poder de hacer de hoy un día extraordinario.', 'source': 'Hopecore'},
        {'quote': 'Tu sonrisa es medicina para el alma de otros.', 'source': 'Hopecore'},
      ];
      return inspiringQuotes[_random.nextInt(inspiringQuotes.length)];
    }
  }

  /// Obtener frase para hora específica del día
  Map<String, String> getQuoteForTimeOfDay() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      // Mañana
      final morningQuotes = [
        {'quote': 'Este amanecer trae nuevas oportunidades solo para ti.', 'source': 'Hopecore'},
        {'quote': 'Hoy vas a lograr algo maravilloso.', 'source': 'Hopecore'},
        {'quote': 'Tu día está lleno de posibilidades esperándote.', 'source': 'Hopecore'},
      ];
      return morningQuotes[_random.nextInt(morningQuotes.length)];
    } else if (hour >= 12 && hour < 18) {
      // Tarde
      final afternoonQuotes = [
        {'quote': 'Tu energía positiva está transformando tu día.', 'source': 'Hopecore'},
        {'quote': 'Cada sonrisa tuya hace el mundo más hermoso.', 'source': 'Hopecore'},
        {'quote': 'Tu persistencia está dando frutos increíbles.', 'source': 'Hopecore'},
      ];
      return afternoonQuotes[_random.nextInt(afternoonQuotes.length)];
    } else {
      // Noche
      final eveningQuotes = [
        {'quote': 'Hoy hiciste cosas que te acercan a tus sueños.', 'source': 'Hopecore'},
        {'quote': 'Descansa sabiendo que eres increíblemente valioso.', 'source': 'Hopecore'},
        {'quote': 'Mañana despertarás con nuevas fuerzas y esperanzas.', 'source': 'Hopecore'},
      ];
      return eveningQuotes[_random.nextInt(eveningQuotes.length)];
    }
  }

  /// Obtener número total de frases
  int getTotalQuotesCount() {
    int total = 0;
    _quotes.values.forEach((quotes) {
      total += quotes.length;
    });
    return total;
  }

  /// Obtener frases por fuente específica
  List<Map<String, String>> getQuotesBySource(String source) {
    final List<Map<String, String>> result = [];
    _quotes.values.forEach((categoryQuotes) {
      result.addAll(categoryQuotes.where((quote) => 
        quote['source']?.toLowerCase() == source.toLowerCase()));
    });
    return result;
  }
}