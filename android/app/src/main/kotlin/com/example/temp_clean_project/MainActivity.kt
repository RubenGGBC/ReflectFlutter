// android/app/src/main/kotlin/com/example/temp_clean_project/MainActivity.kt
// VERIFY THIS MATCHES YOUR EXISTING FILE

package com.example.temp_clean_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the GenAI plugin
        flutterEngine.plugins.add(GenAIPlugin())
    }
}