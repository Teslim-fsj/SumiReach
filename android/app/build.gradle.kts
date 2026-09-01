import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin (Firebase)
    id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { stream ->
        keystoreProperties.load(stream)
    }
}

val resolvedKeyAlias = keystoreProperties.getProperty("keyAlias") ?: "upload"
val resolvedKeyPassword = keystoreProperties.getProperty("keyPassword") ?: "sumireach_keystore_pass123"
val resolvedStorePassword = keystoreProperties.getProperty("storePassword") ?: "sumireach_keystore_pass123"
val resolvedStorePath = keystoreProperties.getProperty("storeFile") ?: "../upload-keystore.jks"
val resolvedStoreFile = rootProject.file("upload-keystore.jks")
val isReleaseSigningAvailable = resolvedStoreFile.exists() || (keystorePropertiesFile.exists() && file(resolvedStorePath).exists())

android {
    namespace = "com.sumireach.app"
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
        applicationId = "com.sumireach.app"
        // Firebase requires minSdk 23+
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (isReleaseSigningAvailable) {
                keyAlias = resolvedKeyAlias
                keyPassword = resolvedKeyPassword
                storeFile = if (resolvedStoreFile.exists()) resolvedStoreFile else file(resolvedStorePath)
                storePassword = resolvedStorePassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (isReleaseSigningAvailable) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}