plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.projekakhir_praktpm"
    // ===============================================
    // PERUBAHAN UTAMA DI SINI: UBAH 34 MENJADI 35
    // ===============================================
    compileSdk = 35
    // ===============================================

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.projekakhir_praktpm"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21 // Mengatur minSdk secara eksplisit lebih baik
        targetSdk = 34 // targetSdk bisa tetap 34, tidak masalah
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Blok dependencies ini sudah benar, pertahankan saja.
dependencies {
    // Dependensi lain yang mungkin sudah ada...

    // Tambahkan baris ini untuk core library desugaring
    add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:2.0.4")
}