plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Line coverage of the label photo classes (u6-label-recognition
    // cicd-pipeline.md §1): jacocoLabelReport below.
    jacoco
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
        // freemium-plus D6: google_mobile_ads stops the app at start-up
        // without an AdMob App ID in the manifest. Debug, CI and any build
        // without ADMOB_APP_ID use Google's public test App ID; the real one
        // comes only from a Gradle property or the ADMOB_APP_ID environment
        // variable (a GitHub Actions secret), never from the repository.
        manifestPlaceholders["admobAppId"] =
            (project.findProperty("ADMOB_APP_ID") as String?)?.takeIf { it.isNotBlank() }
                ?: System.getenv("ADMOB_APP_ID")?.takeIf { it.isNotBlank() }
                ?: "ca-app-pub-3940256099942544~3347511713"
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
            // u6-label-recognition: the unused ML Kit scripts (see the file).
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    // JVM tests of the native label code with Robolectric (u6 cicd-pipeline.md
    // §1): `./gradlew :app:testDebugUnitTest :app:jacocoLabelReport`.
    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all { test ->
                test.extensions.configure(JacocoTaskExtension::class) {
                    // Robolectric loads the classes with its own class loader.
                    isIncludeNoLocationClasses = true
                    excludes = listOf("jdk.internal.*")
                }
            }
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

dependencies {
    // EXIF orientation of the label photos (u6 security-design.md §3).
    implementation("androidx.exifinterface:exifinterface:1.4.2")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.robolectric:robolectric:4.17")
    testImplementation("androidx.test:core:1.7.0")
}

// With isIncludeAndroidResources the unit-test package reads the merged
// assets, which the Flutter plugin also writes: order the two tasks.
tasks.matching { it.name == "packageDebugUnitTestForUnitTest" }.configureEach {
    dependsOn(tasks.matching { it.name == "copyFlutterAssetsDebug" })
}

jacoco {
    toolVersion = "0.8.14"
}

// The two native classes of the label photo (u6 cicd-pipeline.md §1). The
// threshold is an input (team.md, Copertura): never lower it to pass a build.
val labelCoverageClasses = listOf(
    "com/vinoozy/vinoozy/LabelImagePreparer*.class",
    "com/vinoozy/vinoozy/SharedImageReceiver*.class",
)
val labelCoverageMinimum = "0.80".toBigDecimal()

fun JacocoReportBase.labelCoverageInputs() {
    dependsOn("testDebugUnitTest")
    classDirectories.setFrom(
        fileTree(layout.buildDirectory.dir("tmp/kotlin-classes/debug")) {
            include(labelCoverageClasses)
        },
    )
    sourceDirectories.setFrom(files("src/main/kotlin"))
    executionData.setFrom(
        fileTree(layout.buildDirectory) { include("jacoco/testDebugUnitTest.exec") },
    )
}

val jacocoLabelVerification by tasks.registering(JacocoCoverageVerification::class) {
    group = "verification"
    description = "Fails below 80% line coverage of LabelImagePreparer and SharedImageReceiver."
    labelCoverageInputs()
    violationRules {
        rule {
            limit {
                counter = "LINE"
                value = "COVEREDRATIO"
                minimum = labelCoverageMinimum
            }
        }
    }
}

tasks.register<JacocoReport>("jacocoLabelReport") {
    group = "verification"
    description = "Coverage report of the label photo classes, then the 80% check."
    labelCoverageInputs()
    reports {
        xml.required = true
        html.required = true
    }
    finalizedBy(jacocoLabelVerification)
}
