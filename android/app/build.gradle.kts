plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Apply google-services here at app level (no version or apply false here)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.reliq.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.reliq.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

dependencies {
    // Firebase BoM — manages all Firebase library versions automatically
    // so you never get version conflicts between Firebase packages
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))

    // Firebase Analytics — required base for most Firebase services
    implementation("com.google.firebase:firebase-analytics")

    // Firebase Auth — for when you switch to Firebase Authentication
    implementation("com.google.firebase:firebase-auth")

    // Firebase Cloud Messaging — for push notifications
    implementation("com.google.firebase:firebase-messaging")
}
