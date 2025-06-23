// android/app/src/main/kotlin/com/example/temp_clean_project/GenAIPlugin.java
package io.flutter.kotlin.com.example.temp_clean_project

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class GenAIPlugin : FlutterPlugin, MethodCallHandler {
    private var channel: MethodChannel? = null
    private var context: Context? = null
    private var executor: ExecutorService? = null
    private var isModelLoaded: Boolean = false

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.yourapp.genai")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.getApplicationContext()
        executor = Executors.newSingleThreadExecutor()
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isGenAIAvailable" -> result.success(true) // Siempre disponible para modo simulado
            "initializeModel" -> {
                val modelPath: String = call.argument("modelPath")
                initializeModelAsync(modelPath, result)
            }

            "generateText" -> {
                if (!isModelLoaded) {
                    result.error("MODEL_NOT_LOADED", "Model not initialized", null)
                    return
                }

                val prompt: String = call.argument("prompt")
                val maxTokens: Int = call.argument("maxTokens")
                val temperature: Double = call.argument("temperature")
                val topP: Double = call.argument("topP")

                generateTextAsync(prompt, maxTokens, temperature, topP, result)
            }

            "disposeModel" -> disposeModelAsync(result)
            else -> result.notImplemented()
        }
    }

    private fun initializeModelAsync(modelPath: String, result: Result) {
        executor.execute(java.lang.Runnable {
            try {
                // Simular carga del modelo
                java.lang.Thread.sleep(2000)
                isModelLoaded = true
                result.success(true)
            } catch (e: java.lang.Exception) {
                result.error("INIT_ERROR", "Failed to initialize model: " + e.message, null)
            }
        })
    }

    private fun generateTextAsync(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double,
        result: Result
    ) {
        executor.execute(java.lang.Runnable {
            try {
                // Simular tiempo de procesamiento
                java.lang.Thread.sleep(3000)
                val response: String = generateIntelligentResponse(prompt)
                result.success(response)
            } catch (e: java.lang.Exception) {
                result.error("GENERATION_ERROR", "Failed to generate text: " + e.message, null)
            }
        })
    }

    private fun generateIntelligentResponse(prompt: String): String {
        try {
            // Extraer datos del prompt para análisis real
            val data: UserWeekData = parseUserDataFromPrompt(prompt)

            if (data.hasData()) {
                return generatePersonalizedAnalysis(data)
            } else {
                return generateEmptyWeekResponse(data.userName)
            }
        } catch (e: java.lang.Exception) {
            // Fallback en caso de error
            return generateFallbackResponse()
        }
    }

    private fun parseUserDataFromPrompt(prompt: String): UserWeekData {
        val data: UserWeekData = UserWeekData()


        // Extraer nombre de usuario
        if (prompt.contains("de ") && prompt.contains(" de esta semana")) {
            val start: Int = prompt.indexOf("de ") + 3
            val end: Int = prompt.indexOf(" de esta semana")
            if (start < end && start >= 0 && end >= 0) {
                data.userName = prompt.substring(start, end).trim { it <= ' ' }
            }
        }


        // Extraer número de reflexiones
        if (prompt.contains("Total de días con reflexiones: ")) {
            try {
                val start: Int = prompt.indexOf("Total de días con reflexiones: ") + 32
                var end: Int = prompt.indexOf("\n", start)
                if (end == -1) end = start + 2
                val countStr: String = prompt.substring(start, end).trim { it <= ' ' }
                data.totalReflections = countStr.toInt()
            } catch (ignored: java.lang.Exception) {
            }
        }


        // Extraer estado de ánimo promedio
        if (prompt.contains("Estado de ánimo promedio: ")) {
            try {
                val start: Int = prompt.indexOf("Estado de ánimo promedio: ") + 26
                val end: Int = prompt.indexOf("/10", start)
                val moodStr: String = prompt.substring(start, end).trim { it <= ' ' }
                data.avgMood = moodStr.toDouble()
            } catch (ignored: java.lang.Exception) {
            }
        }


        // Extraer nivel de energía
        if (prompt.contains("Nivel de energía promedio: ")) {
            try {
                val start: Int = prompt.indexOf("Nivel de energía promedio: ") + 28
                val end: Int = prompt.indexOf("/10", start)
                val energyStr: String = prompt.substring(start, end).trim { it <= ' ' }
                data.avgEnergy = energyStr.toDouble()
            } catch (ignored: java.lang.Exception) {
            }
        }


        // Extraer nivel de estrés
        if (prompt.contains("Nivel de estrés promedio: ")) {
            try {
                val start: Int = prompt.indexOf("Nivel de estrés promedio: ") + 26
                val end: Int = prompt.indexOf("/10", start)
                val stressStr: String = prompt.substring(start, end).trim { it <= ' ' }
                data.avgStress = stressStr.toDouble()
            } catch (ignored: java.lang.Exception) {
            }
        }


        // Extraer reflexiones destacadas
        if (prompt.contains("REFLEXIONES DESTACADAS:")) {
            val start: Int = prompt.indexOf("REFLEXIONES DESTACADAS:") + 24
            var end: Int = prompt.indexOf("\n\nMOMENTOS", start)
            if (end == -1) end = prompt.length

            val reflectionsSection: String = prompt.substring(start, end)
            val lines: Array<String> =
                reflectionsSection.split("\n".toRegex()).dropLastWhile { it.isEmpty() }
                    .toTypedArray()

            for (line: String in lines) {
                if (line.trim { it <= ' ' }.matches("\\d+\\..*".toRegex())) {
                    data.keyReflections.add(
                        line.trim { it <= ' ' }.substring(3)
                            .replace("\"".toRegex(), "")
                    )
                }
            }
        }


        // Extraer momentos especiales
        if (prompt.contains("Total de momentos registrados: ")) {
            try {
                val start: Int = prompt.indexOf("Total de momentos registrados: ") + 31
                val end: Int = prompt.indexOf("\n", start)
                val momentsStr: String = prompt.substring(start, end).trim { it <= ' ' }
                data.totalMoments = momentsStr.toInt()
            } catch (ignored: java.lang.Exception) {
            }
        }

        return data
    }

    private fun generatePersonalizedAnalysis(data: UserWeekData): String {
        val analysis: java.lang.StringBuilder = java.lang.StringBuilder()

        analysis.append("**¡Hola ").append(if (data.userName != null) data.userName else "")
            .append("!**\n\n")


        // RESUMEN SEMANAL personalizado
        analysis.append("**RESUMEN SEMANAL:**\n")
        analysis.append("Esta semana registraste ").append(data.totalReflections)
            .append(" reflexiones, mostrando ")

        if (data.avgMood >= 7) {
            analysis.append("un excelente estado de ánimo promedio de ")
                .append(String.format("%.1f", data.avgMood)).append("/10. ")
        } else if (data.avgMood >= 5) {
            analysis.append("un estado de ánimo equilibrado de ")
                .append(String.format("%.1f", data.avgMood)).append("/10. ")
        } else {
            analysis.append("un estado de ánimo de ")
                .append(String.format("%.1f", data.avgMood))
                .append("/10, sugiriendo algunos desafíos importantes. ")
        }

        if (data.avgEnergy > 0) {
            analysis.append("Tu nivel de energía (").append(String.format("%.1f", data.avgEnergy))
                .append("/10) ")
            if (data.avgEnergy >= 7) {
                analysis.append("muestra vitalidad constante.")
            } else if (data.avgEnergy >= 5) {
                analysis.append("indica un equilibrio energético razonable.")
            } else {
                analysis.append("sugiere la necesidad de recargar energías.")
            }
        }

        analysis.append("\n\n")


        // INSIGHTS PROFUNDOS personalizados
        analysis.append("**INSIGHTS PROFUNDOS:**\n")


        // Análisis de consistencia
        if (data.totalReflections >= 5) {
            analysis.append("• Tu consistencia en la reflexión (")
                .append(data.totalReflections)
                .append(" días) demuestra un compromiso excepcional\n")
        } else if (data.totalReflections >= 3) {
            analysis.append("• Tu práctica regular de reflexión muestra disciplina personal valiosa\n")
        } else {
            analysis.append("• Hay oportunidad para mayor consistencia en tu práctica reflexiva\n")
        }


        // Análisis emocional
        if (data.avgMood >= 7 && data.avgStress <= 4) {
            analysis.append("• Logras mantener un equilibrio emocional admirable con bajo estrés\n")
        } else if (data.avgMood >= 6) {
            analysis.append("• Tu capacidad de mantener una perspectiva positiva es una fortaleza clave\n")
        } else {
            analysis.append("• Tu honestidad sobre los desafíos emocionales muestra gran autoconocimiento\n")
        }


        // Análisis energético
        if (data.avgEnergy > 0) {
            if (data.avgEnergy >= 7) {
                analysis.append("• Tu alta energía sugiere hábitos de vida que te favorecen\n")
            } else if (data.avgEnergy <= 4) {
                analysis.append("• Los niveles bajos de energía podrían indicar necesidad de cambios en rutinas\n")
            }
        }


        // Análisis de reflexiones
        if (!data.keyReflections.isEmpty()) {
            analysis.append("• Tus reflexiones muestran profundidad y sinceridad en el autoexamen\n")
        }

        analysis.append("\n")


        // RECOMENDACIONES PERSONALIZADAS
        analysis.append("**RECOMENDACIONES PERSONALIZADAS:**\n")

        if (data.totalReflections < 4) {
            analysis.append("• Intenta reflexionar más frecuentemente - incluso 2 minutos diarios marcan diferencia\n")
        }

        if (data.avgMood < 5) {
            analysis.append("• Considera incorporar una pequeña actividad que disfrutes cada día\n")
            analysis.append("• Explora técnicas de manejo emocional como respiración o caminatas\n")
        } else if (data.avgMood >= 7) {
            analysis.append("• Mantén las prácticas que están funcionando tan bien para ti\n")
            analysis.append("• Considera compartir tu enfoque positivo con otros\n")
        }

        if (data.avgEnergy > 0 && data.avgEnergy <= 4) {
            analysis.append("• Revisa tus patrones de sueño y nutrición para optimizar energía\n")
            analysis.append("• Pequeños descansos durante el día pueden ser muy efectivos\n")
        }

        if (data.avgStress > 6) {
            analysis.append("• Identifica las principales fuentes de estrés y abórdalas gradualmente\n")
            analysis.append("• Técnicas de relajación específicas podrían ser muy beneficiosas\n")
        }

        analysis.append("\n")


        // REFLEXIÓN FINAL personalizada
        analysis.append("**REFLEXIÓN FINAL:**\n")
        if (data.avgMood >= 6 && data.totalReflections >= 4) {
            analysis.append("Tu dedicación constante y tu actitud positiva crean una base sólida para el crecimiento continuo. ¡Excelente trabajo!")
        } else if (data.avgMood < 5) {
            analysis.append("Atravesar momentos difíciles con la voluntad de reflexionar demuestra una fortaleza admirable. Cada día es una nueva oportunidad.")
        } else {
            analysis.append("Tu compromiso con el autoconocimiento te está llevando por un camino valioso de desarrollo personal. ¡Continúa adelante!")
        }

        return analysis.toString()
    }

    private fun generateEmptyWeekResponse(userName: String?): String {
        return "**¡Hola " + (if (userName != null) userName else "") + "!**\n\n" +
                "**OBSERVACIÓN CLAVE:**\n" +
                "Esta semana no registraste reflexiones en tu diario, y eso también nos dice algo valioso.\n\n" +
                "**INSIGHT PROFUNDO:**\n" +
                "Los períodos sin registro suelen coincidir con semanas muy ocupadas o momentos de transición. Esto es completamente normal y parte del ritmo natural de la vida.\n\n" +
                "**RECOMENDACIÓN PERSONALIZADA:**\n" +
                "Prueba la \"reflexión de 30 segundos\": antes de dormir, pregúntate simplemente \"¿Cómo me sentí hoy?\" No necesitas escribir un párrafo; incluso una palabra o emoji cuenta.\n\n" +
                "Recuerda: la constancia importa más que la perfección. ¡Nos vemos la próxima semana! 🌟"
    }

    private fun generateFallbackResponse(): String {
        return "**¡Hola!**\n\n" +
                "He analizado tus datos de esta semana y puedo ver tu compromiso con el bienestar personal.\n\n" +
                "**INSIGHT CLAVE:**\n" +
                "Tu práctica de reflexión muestra una dedicación valiosa al autoconocimiento.\n\n" +
                "**RECOMENDACIÓN:**\n" +
                "Continúa con esta práctica tan beneficiosa para tu desarrollo personal.\n\n" +
                "¡Sigue adelante en tu camino de crecimiento!"
    }

    // Clase auxiliar para datos del usuario
    private class UserWeekData {
        var userName: String? = null
        var totalReflections: Int = 0
        var avgMood: Double = 0.0
        var avgEnergy: Double = 0.0
        var avgStress: Double = 0.0
        var totalMoments: Int = 0
        var keyReflections: MutableList<String> = ArrayList<String>()

        fun hasData(): Boolean {
            return totalReflections > 0 || totalMoments > 0 || !keyReflections.isEmpty()
        }
    }

    private fun disposeModelAsync(result: Result) {
        executor.execute(java.lang.Runnable {
            try {
                isModelLoaded = false
                result.success(null)
            } catch (e: java.lang.Exception) {
                result.error("DISPOSE_ERROR", "Failed to dispose model: " + e.message, null)
            }
        })
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding?) {
        channel.setMethodCallHandler(null)
        if (executor != null) {
            executor.shutdown()
        }
    }
}