plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin (WAJIB di posisi terakhir)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.uas_capstone"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // Enable Core Library Desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.uas_capstone"

        // Minimum SDK wajib 21 untuk sqflite & notifications
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Enable multidex
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Pakai debug signing dulu agar bisa build release
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Dependency untuk Core Library Desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
