package com.example.temp_clean_project // Correct package name

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class GenAIPlugin : FlutterPlugin, MethodCallHandler {
    private var channel: MethodChannel? = null
    private var context: Context? = null
    private var executor: ExecutorService? = null
    private var isModelLoaded: Boolean = false

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.yourapp.genai")
        channel?.setMethodCallHandler(this)
        context = binding.applicationContext
        executor = Executors.newSingleThreadExecutor()
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isGenAIAvailable" -> result.success(true) // Always available for simulated mode
            "initializeModel" -> {
                val modelPath: String? = call.argument("modelPath")
                if (modelPath != null) {
                    initializeModelAsync(modelPath, result)
                } else {
                    result.error("INVALID_ARGS", "modelPath is null", null)
                }
            }

            "generateText" -> {
                if (!isModelLoaded) {
                    result.error("MODEL_NOT_LOADED", "Model not initialized", null)
                    return
                }

                val prompt: String? = call.argument("prompt")
                val maxTokens: Int? = call.argument("maxTokens")
                val temperature: Double? = call.argument("temperature")
                val topP: Double? = call.argument("topP")

                if (prompt != null && maxTokens != null && temperature != null && topP != null) {
                    generateTextAsync(prompt, maxTokens, temperature, topP, result)
                } else {
                    result.error("INVALID_ARGS", "One or more arguments are null", null)
                }
            }

            "disposeModel" -> disposeModelAsync(result)
            else -> result.notImplemented()
        }
    }

    private fun initializeModelAsync(modelPath: String, result: Result) {
        executor?.execute {
            try {
                // Simulate model loading
                Thread.sleep(2000)
                isModelLoaded = true
                result.success(true)
            } catch (e: Exception) {
                result.error("INIT_ERROR", "Failed to initialize model: " + e.message, null)
            }
        }
    }

    private fun generateTextAsync(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double,
        result: Result
    ) {
        executor?.execute {
            try {
                // Simulate processing time
                Thread.sleep(3000)
                val response: String = generateIntelligentResponse(prompt)
                result.success(response)
            } catch (e: Exception) {
                result.error("GENERATION_ERROR", "Failed to generate text: " + e.message, null)
            }
        }
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
        } catch (e: Exception) {
            // Fallback en caso de error
            return generateFallbackResponse()
        }
    }

    private fun parseUserDataFromPrompt(prompt: String): UserWeekData {
        val data = UserWeekData()

        // Extraer nombre de usuario
        val nameRegex = "de (.*?) de esta semana".toRegex()
        nameRegex.find(prompt)?.let {
            data.userName = it.groupValues[1].trim()
        }

        // Extraer número de reflexiones
        val reflectionsRegex = "Total de días con reflexiones: (\\d+)".toRegex()
        reflectionsRegex.find(prompt)?.let {
            data.totalReflections = it.groupValues[1].toIntOrNull() ?: 0
        }

        // Extraer estado de ánimo promedio
        val moodRegex = "Estado de ánimo promedio: (\\d+\\.\\d+)/10".toRegex()
        moodRegex.find(prompt)?.let {
            data.avgMood = it.groupValues[1].toDoubleOrNull() ?: 0.0
        }

        // Extraer nivel de energía
        val energyRegex = "Nivel de energía promedio: (\\d+\\.\\d+)/10".toRegex()
        energyRegex.find(prompt)?.let {
            data.avgEnergy = it.groupValues[1].toDoubleOrNull() ?: 0.0
        }

        // Extraer nivel de estrés
        val stressRegex = "Nivel de estrés promedio: (\\d+\\.\\d+)/10".toRegex()
        stressRegex.find(prompt)?.let {
            data.avgStress = it.groupValues[1].toDoubleOrNull() ?: 0.0
        }

        // Extraer reflexiones destacadas
        val reflectionsSectionRegex = "REFLEXIONES DESTACADAS:(.*?)(?=\\n\\nMOMENTOS|$)".toRegex(RegexOption.DOT_MATCHES_ALL)
        reflectionsSectionRegex.find(prompt)?.let {
            val section = it.groupValues[1]
            val reflectionLineRegex = "\\d+\\.\\s*\"(.*?)\"".toRegex()
            reflectionLineRegex.findAll(section).forEach { match ->
                data.keyReflections.add(match.groupValues[1])
            }
        }

        // Extraer momentos especiales
        val momentsRegex = "Total de momentos registrados: (\\d+)".toRegex()
        momentsRegex.find(prompt)?.let {
            data.totalMoments = it.groupValues[1].toIntOrNull() ?: 0
        }

        return data
    }

    private fun generatePersonalizedAnalysis(data: UserWeekData): String {
        val analysis = StringBuilder()

        analysis.append("**¡Hola ${data.userName ?: ""}!**\n\n")

        // RESUMEN SEMANAL personalizado
        analysis.append("**RESUMEN SEMANAL:**\n")
        val moodText = when {
            data.avgMood >= 7 -> "un excelente estado de ánimo promedio de ${"%.1f".format(data.avgMood)}/10. "
            data.avgMood >= 5 -> "un estado de ánimo equilibrado de ${"%.1f".format(data.avgMood)}/10. "
            else -> "un estado de ánimo de ${"%.1f".format(data.avgMood)}/10, sugiriendo algunos desafíos importantes. "
        }
        analysis.append("Esta semana registraste ${data.totalReflections} reflexiones, mostrando $moodText")

        if (data.avgEnergy > 0) {
            val energyText = when {
                data.avgEnergy >= 7 -> "muestra vitalidad constante."
                data.avgEnergy >= 5 -> "indica un equilibrio energético razonable."
                else -> "sugiere la necesidad de recargar energías."
            }
            analysis.append("Tu nivel de energía (${"%.1f".format(data.avgEnergy)}/10) $energyText")
        }
        analysis.append("\n\n")

        // INSIGHTS PROFUNDOS personalizados
        analysis.append("**INSIGHTS PROFUNDOS:**\n")
        if (data.totalReflections >= 5) {
            analysis.append("• Tu consistencia en la reflexión (${data.totalReflections} días) demuestra un compromiso excepcional\n")
        } else if (data.totalReflections >= 3) {
            analysis.append("• Tu práctica regular de reflexión muestra disciplina personal valiosa\n")
        } else {
            analysis.append("• Hay oportunidad para mayor consistencia en tu práctica reflexiva\n")
        }
        if (data.avgMood >= 7 && data.avgStress <= 4) {
            analysis.append("• Logras mantener un equilibrio emocional admirable con bajo estrés\n")
        } else if (data.avgMood >= 6) {
            analysis.append("• Tu capacidad de mantener una perspectiva positiva es una fortaleza clave\n")
        }
        if (data.avgEnergy > 0 && data.avgEnergy <= 4) {
            analysis.append("• Los niveles bajos de energía podrían indicar necesidad de cambios en rutinas\n")
        }
        if (data.keyReflections.isNotEmpty()) {
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
        }
        if (data.avgStress > 6) {
            analysis.append("• Identifica las principales fuentes de estrés y abórdalas gradualmente\n")
        }
        analysis.append("\n")

        // REFLEXIÓN FINAL personalizada
        analysis.append("**REFLEXIÓN FINAL:**\n")
        if (data.avgMood >= 6 && data.totalReflections >= 4) {
            analysis.append("Tu dedicación constante y tu actitud positiva crean una base sólida para el crecimiento continuo. ¡Excelente trabajo!")
        } else {
            analysis.append("Tu compromiso con el autoconocimiento te está llevando por un camino valioso de desarrollo personal. ¡Continúa adelante!")
        }

        return analysis.toString()
    }

    private fun generateEmptyWeekResponse(userName: String?): String {
        return """
            **¡Hola ${userName ?: ""}!**

            **OBSERVACIÓN CLAVE:**
            Esta semana no registraste reflexiones en tu diario, y eso también nos dice algo valioso.

            **INSIGHT PROFUNDO:**
            Los períodos sin registro suelen coincidir con semanas muy ocupadas o momentos de transición. Esto es completamente normal y parte del ritmo natural de la vida.

            **RECOMENDACIÓN PERSONALIZADA:**
            Prueba la "reflexión de 30 segundos": antes de dormir, pregúntate simplemente "¿Cómo me sentí hoy?" No necesitas escribir un párrafo; incluso una palabra o emoji cuenta.

            Recuerda: la constancia importa más que la perfección. ¡Nos vemos la próxima semana! 🌟
            """.trimIndent()
    }

    private fun generateFallbackResponse(): String {
        return """
            **¡Hola!**

            He analizado tus datos de esta semana y puedo ver tu compromiso con el bienestar personal.

            **INSIGHT CLAVE:**
            Tu práctica de reflexión muestra una dedicación valiosa al autoconocimiento.

            **RECOMENDACIÓN:**
            Continúa con esta práctica tan beneficiosa para tu desarrollo personal.

            ¡Sigue adelante en tu camino de crecimiento!
            """.trimIndent()
    }

    // Clase auxiliar para datos del usuario
    private class UserWeekData {
        var userName: String? = null
        var totalReflections: Int = 0
        var avgMood: Double = 0.0
        var avgEnergy: Double = 0.0
        var avgStress: Double = 0.0
        var totalMoments: Int = 0
        var keyReflections: MutableList<String> = mutableListOf()

        fun hasData(): Boolean {
            return totalReflections > 0 || totalMoments > 0 || keyReflections.isNotEmpty()
        }
    }


    private fun disposeModelAsync(result: Result) {
        executor?.execute {
            try {
                isModelLoaded = false
                result.success(null)
            } catch (e: Exception) {
                result.error("DISPOSE_ERROR", "Failed to dispose model: " + e.message, null)
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        executor?.shutdown()
        executor = null
        context = null
        channel = null
    }
}