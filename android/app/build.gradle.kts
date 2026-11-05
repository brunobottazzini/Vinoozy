plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing material comes only from environment variables that
// release.yml fills from GitHub Actions secrets. Nothing is read from files in
// the repository (NFR4.7); without the variables a release build stays unsigned
// and cannot be uploaded to Google Play.
val uploadKeystorePath: String? = System.getenv("ANDROID_UPLOAD_KEYSTORE_PATH")
val uploadKeystorePassword: String? = System.getenv("ANDROID_UPLOAD_KEYSTORE_PASSWORD")
val uploadKeyAlias: String? = System.getenv("ANDROID_UPLOAD_KEY_ALIAS")
val uploadKeyPassword: String? = System.getenv("ANDROID_UPLOAD_KEY_PASSWORD")
val hasUploadKey: Boolean =
    listOf(uploadKeystorePath, uploadKeystorePassword, uploadKeyAlias, uploadKeyPassword)
        .all { !it.isNullOrBlank() }

android {
    namespace = "com.vinoozy.vinoozy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Final Google Play package name (infrastructure-specification.md).
        applicationId = "com.vinoozy.app"
        // FlutterFire on Firebase Android BoM 35 requires minSdk 24.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKey) {
            create("upload") {
                storeFile = file(uploadKeystorePath!!)
                storePassword = uploadKeystorePassword
                keyAlias = uploadKeyAlias
                keyPassword = uploadKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // Never fall back to the debug key: an unsigned bundle is rejected
            // by Google Play instead of shipping with the wrong key.
            signingConfig = if (hasUploadKey) signingConfigs.getByName("upload") else null
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
