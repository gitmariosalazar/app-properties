import java.util.Properties
import java.io.FileInputStream
import java.io.IOException

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_properties"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.app_properties"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // === FLAVORS ===
    flavorDimensions += "app"
    productFlavors {
        create("dev") {
            dimension = "app"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Scan App DEV")
            resValue("string", "google_maps_api_key", googleMapsApiKey("dev"))
        }
        create("prod") {
            dimension = "app"
            resValue("string", "app_name", "Scan App")
            resValue("string", "google_maps_api_key", googleMapsApiKey("prod"))
        }
    }

    // === BUILD TYPES ===
    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            isDebuggable = true
        }
        release {
            isMinifyEnabled = false
            isShrinkResources = false  // ← AÑADIDO: DESACTIVADO
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// === LEE .env DESDE LA RAÍZ DEL PROYECTO FLUTTER (NO DESDE android/) ===
fun googleMapsApiKey(flavor: String): String {
    val fileName = if (flavor == "dev") ".env.dev" else ".env"
    // Usa projectDir del proyecto raíz (app_properties), NO de android
    val rootProjectDir = project.rootProject.projectDir.parentFile
    val envFile = rootProjectDir.resolve(fileName)

    if (!envFile.exists()) {
        println("Warning: Archivo $fileName no encontrado en $rootProjectDir. Usando clave por defecto.")
        return "MISSING_KEY"
    }

    return try {
        val props = Properties()
        FileInputStream(envFile).use { input ->
            props.load(input)
        }
        val key = props.getProperty("API_KEY_GOOGLE_MAPS")
        if (key.isNullOrBlank()) "MISSING_KEY" else key.trim()
    } catch (e: IOException) {
        println("Error al leer $fileName: ${e.message}")
        "MISSING_KEY"
    } catch (e: Exception) {
        println("Error inesperado: ${e.message}")
        "MISSING_KEY"
    }
}

flutter {
    source = "../.."
}