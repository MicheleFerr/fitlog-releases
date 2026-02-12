import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// 🔐 Load keystore properties for release signing
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.micheleferrero93.GymProgressAppNew"
    compileSdk = 36  // Android 16 (SDK 36) required by plugins
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.micheleferrero93.GymProgressAppNew"
        minSdk = 26  // Required by health plugin (Android 8.0+)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🔐 Signing configurations for release builds
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // ✅ SECURITY: Enable ProGuard/R8 for code obfuscation and shrinking
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // ✅ Use release keystore for production builds
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Play Feature Delivery for deferred components (required by Flutter)
    // Using split modules instead of deprecated monolithic core library
    implementation("com.google.android.play:feature-delivery:2.1.0")
}

// 🧪 Remove test plugins from release builds
// These plugins (integration_test, patrol) are dev_dependencies but Flutter still
// registers them in GeneratedPluginRegistrant.java. This task removes them for release.
tasks.whenTaskAdded {
    if (name.contains("compileReleaseJavaWithJavac")) {
        doFirst {
            val registrantFile = file("src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java")
            if (registrantFile.exists()) {
                var content = registrantFile.readText()
                // Remove integration_test plugin registration
                content = content.replace(
                    Regex("""try \{\s*flutterEngine\.getPlugins\(\)\.add\(new dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin\(\)\);\s*\} catch \(Exception e\) \{\s*Log\.e\(TAG, "Error registering plugin integration_test, dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin", e\);\s*\}"""),
                    "// integration_test excluded from release"
                )
                // Remove patrol plugin registration
                content = content.replace(
                    Regex("""try \{\s*flutterEngine\.getPlugins\(\)\.add\(new pl\.leancode\.patrol\.PatrolPlugin\(\)\);\s*\} catch \(Exception e\) \{\s*Log\.e\(TAG, "Error registering plugin patrol, pl\.leancode\.patrol\.PatrolPlugin", e\);\s*\}"""),
                    "// patrol excluded from release"
                )
                registrantFile.writeText(content)
            }
        }
    }
}

flutter {
    source = "../.."
}
