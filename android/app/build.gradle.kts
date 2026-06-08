import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}
val hasReleaseSigningConfig =
    (keystoreProperties["storeFile"] as String?)?.isNotBlank() == true &&
        (keystoreProperties["storePassword"] as String?)?.isNotBlank() == true &&
        (keystoreProperties["keyAlias"] as String?)?.isNotBlank() == true &&
        (keystoreProperties["keyPassword"] as String?)?.isNotBlank() == true

fun missingReleaseSigningConfigMessage(): String {
    return "Missing Android release signing config. Copy android/key.properties.example " +
        "to android/key.properties and fill in the production keystore values."
}

android {
    namespace = "com.ezackly.golfkakis"
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
        applicationId = "com.ezackly.golfkakis"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "GolfKakis Staging")
        }

        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "GolfKakis")
        }
    }

    signingConfigs {
        if (hasReleaseSigningConfig) {
            create("release") {
                val storeFilePath = keystoreProperties["storeFile"] as String?
                val storePasswordValue =
                    keystoreProperties["storePassword"] as String?
                val keyAliasValue = keystoreProperties["keyAlias"] as String?
                val keyPasswordValue = keystoreProperties["keyPassword"] as String?

                storeFile = rootProject.file(storeFilePath!!)
                storePassword = storePasswordValue
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigningConfig) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

gradle.taskGraph.whenReady {
    if (
        !hasReleaseSigningConfig &&
            allTasks.any {
                (it.name.startsWith("assemble") || it.name.startsWith("bundle")) &&
                    it.name.endsWith("Release")
            }
    ) {
        throw GradleException(missingReleaseSigningConfigMessage())
    }
}

flutter {
    source = "../.."
}
