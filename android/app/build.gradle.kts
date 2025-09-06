plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.iconaapp.live"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.iconaapp.live"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        create("release") {
            storeFile = rootProject.file(project.properties["KEYSTORE_PATH"].toString())
            storePassword = project.properties["KEYSTORE_PASSWORD"].toString()
            keyAlias = project.properties["KEY_ALIAS"].toString()
            keyPassword = project.properties["KEY_PASSWORD"].toString()
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true // code shrinking
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
dependencies {
    // Required for desugaring (Java 8+ APIs on lower Android versions)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Other Flutter/Firebase deps are auto-added
}
flutter {
    source = "../.."
}
