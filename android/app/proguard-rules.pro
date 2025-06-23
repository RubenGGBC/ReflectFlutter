# android/app/proguard-rules.pro
# UPDATE TO USE CORRECT PACKAGE NAME

# Keep all classes in our package
-keep class com.example.temp_clean_project.** { *; }

# Keep AI Plugin classes
-keep class com.example.temp_clean_project.GenAIPlugin { *; }

# Keep ONNX Runtime classes
-keep class com.microsoft.onnxruntime.** { *; }
-keep class ai.onnxruntime.** { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# Keep method channel classes
-keepclassmembers class * {
    @io.flutter.plugin.common.MethodChannel.* *;
}

# Keep plugin registration methods
-keepclassmembers class * {
    public void configureFlutterEngine(io.flutter.embedding.engine.FlutterEngine);
    public void cleanUpFlutterEngine(io.flutter.embedding.engine.FlutterEngine);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep AI-related annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep coroutines
-keep class kotlinx.coroutines.** { *; }

# Prevent obfuscation of AI model loading
-keep class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}