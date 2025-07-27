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

  // Frases inspiradoras de videojuegos, libros, series, películas y celebridades
  static const Map<String, List<Map<String, String>>> _quotes = {
    'libros': [
      {'quote': 'La felicidad se puede encontrar incluso en los momentos más oscuros, si uno solo recuerda encender la luz.', 'source': 'Harry Potter'},
      {'quote': 'No importa lo mal que se pongan las cosas, siempre puedes empeorarlas. O mejorarlas.', 'source': 'El nombre del viento'},
      {'quote': 'Incluso la persona más pequeña puede cambiar el curso del futuro.', 'source': 'El Señor de los Anillos'},
      {'quote': 'Es nuestra elección, no nuestras habilidades, lo que realmente muestra quiénes somos.', 'source': 'Harry Potter'},
      {'quote': 'Solo existe un camino hacia la felicidad y es dejar de preocuparse por cosas que están más allá del poder de nuestra voluntad.', 'source': 'Epicteto'},
      {'quote': 'Aunque el camino sea largo, cada paso te acerca a tu destino.', 'source': 'Paulo Coelho'},
      {'quote': 'La vida no trata de esperar a que pase la tormenta, trata de aprender a bailar bajo la lluvia.', 'source': 'Vivian Greene'},
      {'quote': 'No podemos elegir cómo empezamos en la vida. Pero podemos elegir cómo terminamos.', 'source': 'Octavia E. Butler'},
      {'quote': 'No hay nada como un sueño para crear el futuro.', 'source': 'Victor Hugo'},
      {'quote': 'La esperanza es una cosa buena, quizás la mejor de las cosas buenas, y las cosas buenas nunca mueren.', 'source': 'Stephen King'},
      {'quote': 'Con cada error, aprendes algo nuevo.', 'source': 'El Alquimista'},
      {'quote': 'El verdadero valor no es la ausencia de miedo, sino la conquista de él.', 'source': 'Mark Twain'},
      {'quote': 'No es lo que te sucede, sino cómo reaccionas lo que importa.', 'source': 'Epicteto'},
      {'quote': 'Las palabras son, en mi humilde opinión, nuestra más inagotable fuente de magia.', 'source': 'Harry Potter'},
      {'quote': 'Cuando no puedes cambiar la dirección del viento, ajusta tus velas.', 'source': 'H. Jackson Brown Jr.'},
      {'quote': 'El sol saldrá de nuevo.', 'source': 'Anna Karenina'},
      {'quote': 'Eres más valiente de lo que crees, más fuerte de lo que pareces y más inteligente de lo que piensas.', 'source': 'Winnie the Pooh'},
    ],
    'series': [
      {'quote': 'Nunca te rindas, nunca te rindas.', 'source': 'Hora de Aventura'},
      {'quote': 'Las cosas no tienen que ser perfectas para ser maravillosas.', 'source': 'The Big Bang Theory'},
      {'quote': 'Cuando crees que no tienes nada más, tienes tu amor.', 'source': 'This Is Us'},
      {'quote': 'La adversidad es una oportunidad, no un castigo.', 'source': 'Sense8'},
      {'quote': 'No podemos cambiar el pasado, pero podemos elegir nuestro futuro.', 'source': 'Dark'},
      {'quote': 'La verdad es que la vida es dura, pero tú eres más duro.', 'source': 'Unbreakable Kimmy Schmidt'},
      {'quote': 'Cada día es una nueva oportunidad para ser mejor.', 'source': 'BoJack Horseman'},
      {'quote': 'La gente no está hecha para rendirse.', 'source': 'One Punch Man'},
      {'quote': 'Las heridas sanan, pero las cicatrices te recuerdan lo lejos que has llegado.', 'source': 'Game of Thrones'},
      {'quote': 'La familia es lo primero.', 'source': 'The Simpsons'},
      {'quote': 'Sigue nadando.', 'source': 'Buscando a Nemo'},
      {'quote': 'No estás solo.', 'source': '13 Reasons Why'},
      {'quote': 'La esperanza es lo que nos mantiene en marcha.', 'source': 'The Walking Dead'},
      {'quote': 'Si tienes miedo, hazlo con miedo.', 'source': 'Grey\'s Anatomy'},
      {'quote': 'Lo que no te mata, te hace más fuerte.', 'source': 'The Boys'},
      {'quote': 'El futuro es brillante.', 'source': 'Futurama'},
      {'quote': 'Un paso a la vez.', 'source': 'The Good Place'},
      {'quote': 'Eres capaz de cosas asombrosas.', 'source': 'Stranger Things'},
      {'quote': 'Hay magia en el mundo, si solo la miras.', 'source': 'Once Upon a Time'},
      {'quote': 'Siempre hay una razón para sonreír.', 'source': 'Friends'},
    ],
    'peliculas': [
      {'quote': 'Sigue adelante.', 'source': 'Meet the Robinsons'},
      {'quote': 'No dejes que nadie te diga que no puedes hacer algo.', 'source': 'En busca de la felicidad'},
      {'quote': 'El pasado puede doler, pero puedes huir de él o aprender de él.', 'source': 'El Rey León'},
      {'quote': 'La vida es como una caja de bombones... nunca sabes lo que te va a tocar.', 'source': 'Forrest Gump'},
      {'quote': 'Nadie puede hacerte sentir inferior sin tu consentimiento.', 'source': 'Eleanor Roosevelt'},
      {'quote': 'Con un gran poder viene una gran responsabilidad.', 'source': 'Spider-Man'},
      {'quote': 'Solo los sueños son el combustible de la vida.', 'source': 'El Secreto de Walter Mitty'},
      {'quote': 'Siempre hay esperanza. Siempre hay una forma.', 'source': 'Star Wars'},
      {'quote': 'Si lo construyes, ellos vendrán.', 'source': 'Campo de sueños'},
      {'quote': 'A veces el miedo es una señal de que estás a punto de hacer algo realmente valiente.', 'source': 'El Increíble Hulk'},
      {'quote': 'No somos perfectos, pero nuestras imperfecciones nos hacen únicos.', 'source': 'El club de los poetas muertos'},
      {'quote': 'Sé el cambio que quieres ver en el mundo.', 'source': 'Mahatma Gandhi'},
      {'quote': 'Lo importante no es lo que tienes, sino lo que haces con lo que tienes.', 'source': 'El Gato con Botas'},
      {'quote': 'Nuestros destinos están ligados.', 'source': 'Moana'},
      {'quote': 'Incluso la noche más oscura terminará y el sol saldrá.', 'source': 'Los Miserables'},
      {'quote': 'El amor lo conquista todo.', 'source': 'Love Actually'},
      {'quote': 'Para infinity... y más allá!', 'source': 'Toy Story'},
      {'quote': 'Nunca dejes de creer en ti mismo.', 'source': 'Rocky'},
      {'quote': 'Cada persona es una estrella, brillando a su manera.', 'source': 'Estrellas en la Tierra'},
      {'quote': 'El futuro es lo que hacemos de él.', 'source': 'Volver al Futuro'},
    ],
    'celebridades': [
      {'quote': 'Soy una gran creyente en la suerte, y encuentro que cuanto más duro trabajo, más suerte tengo.', 'source': 'Thomas Jefferson'},
      {'quote': 'Si puedes soñarlo, puedes lograrlo.', 'source': 'Walt Disney'},
      {'quote': 'La única manera de hacer un gran trabajo es amar lo que haces.', 'source': 'Steve Jobs'},
      {'quote': 'No puedes controlar todo. A veces, solo necesitas relajarte y tener fe en que las cosas saldrán bien.', 'source': 'Kourtney Kardashian'},
      {'quote': 'El optimismo es la fe que conduce al logro. Nada puede hacerse sin esperanza y confianza.', 'source': 'Helen Keller'},
      {'quote': 'El éxito no es la clave de la felicidad. La felicidad es la clave del éxito.', 'source': 'Albert Schweitzer'},
      {'quote': 'Cree que puedes y ya estás a medio camino.', 'source': 'Theodore Roosevelt'},
      {'quote': 'El verdadero éxito es superar el miedo al fracaso.', 'source': 'Will Smith'},
      {'quote': 'No es lo que haces, sino cómo lo haces.', 'source': 'Oprah Winfrey'},
      {'quote': 'La diferencia entre lo ordinario y lo extraordinario es ese pequeño extra.', 'source': 'Jimmy Johnson'},
      {'quote': 'La vida es 10% lo que te sucede y 90% cómo reaccionas a ello.', 'source': 'Charles R. Swindoll'},
      {'quote': 'Nunca es demasiado tarde para ser lo que podrías haber sido.', 'source': 'George Eliot'},
      {'quote': 'El futuro pertenece a aquellos que creen en la belleza de sus sueños.', 'source': 'Eleanor Roosevelt'},
      {'quote': 'Conviértete en el cambio que quieres ver en el mundo.', 'source': 'Mahatma Gandhi'},
      {'quote': 'Si el plan A no funciona, el abecedario tiene 26 letras más.', 'source': 'Desconocido'},
      {'quote': 'La adversidad te prepara para un destino extraordinario.', 'source': 'Roma Downey'},
      {'quote': 'Cada strike me acerca al siguiente home run.', 'source': 'Babe Ruth'},
      {'quote': 'La vida es una oportunidad, aprovéchala.', 'source': 'Madre Teresa'},
      {'quote': 'Tus talentos y habilidades mejorarán con el tiempo, pero para eso tienes que empezar.', 'source': 'Martin Luther King Jr.'},
      {'quote': 'La gratitud es el principio de la felicidad.', 'source': 'Tony Robbins'},
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