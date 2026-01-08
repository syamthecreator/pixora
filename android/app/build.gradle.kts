plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin (MUST be last)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.pixora"
    compileSdk = flutter.compileSdkVersion 

    // CameraX works best with NDK 27+
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.pixora"

        // CameraX requires minSdk 21+
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Using debug key for now (OK for testing)
            signingConfig = signingConfigs.getByName("debug")

            // Optional optimizations
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // -------- CameraX --------
    implementation("androidx.camera:camera-core:1.3.4")
    implementation("androidx.camera:camera-camera2:1.3.4")
    implementation("androidx.camera:camera-lifecycle:1.3.4")
    implementation("androidx.camera:camera-view:1.3.4")

    // -------- Guava (REQUIRED for ListenableFuture) --------
    implementation("com.google.guava:guava:31.1-android")

    // -------- Lifecycle --------
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.4")
}


flutter {
    source = "../.."
}
