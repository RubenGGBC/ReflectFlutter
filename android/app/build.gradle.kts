// android/app/build.gradle.kts
// FIXED VERSION WITH PROPER CORE LIBRARY DESUGARING

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.temp_clean_project"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        // CRITICAL: Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.temp_clean_project"
        minSdk = 23  // Required by record plugin
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }

        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // CRITICAL: Core library desugaring dependency MUST be first
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("androidx.work:work-runtime:2.8.1")
    implementation("androidx.concurrent:concurrent-futures:1.1.0")
    // Keep any other dependencies you need
     implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
     
    // All AI dependencies removed
     
    // ✅ NOTIFICATION DEPENDENCIES
    implementation("androidx.core:core:1.10.1")
    implementation("androidx.annotation:annotation:1.7.0")
}