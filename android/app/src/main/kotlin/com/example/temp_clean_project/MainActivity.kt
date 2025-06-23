// android/app/src/main/java/io/flutter/kotlin/com/example/temp_clean_project/MainActivity.java
// UPDATE YOUR EXISTING MAINACTIVITY.JAVA
package io.flutter.kotlin.com.example.temp_clean_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        // Register the GenAI plugin
        flutterEngine.getPlugins().add(GenAIPlugin())
    }
}