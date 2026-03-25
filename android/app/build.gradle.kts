plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.med_app"

    compileSdk = 36   // 🔥 IMPORTANT FIX

    defaultConfig {
        applicationId = "com.example.med_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36   // 🔥 match compileSdk
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // 🔥 REQUIRED for notifications plugin
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // 🔥 REQUIRED (fixes previous error)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
