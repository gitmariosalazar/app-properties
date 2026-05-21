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
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    // 1. AGREGA ESTO: Configuración de firmas antes de los Build Types
    signingConfigs {
        val keystoreProperties = Properties()
        val keystorePropertiesFile = rootProject.file("key.properties")
        
        if (keystorePropertiesFile.exists()) {
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        }

        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            // Asegúrate de que la ruta en key.properties sea correcta (ej: ./upload-keystore.jks)
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        applicationId = "com.example.app_properties"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "app"
    productFlavors {
        create("dev") {
            dimension = "app"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Property App DEV")
            resValue("string", "google_maps_key", googleMapsApiKey("dev"))
        }
        create("prod") {
            dimension = "app"
            resValue("string", "app_name", "Property App")
            resValue("string", "google_maps_key", googleMapsApiKey("prod"))
        }
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            isDebuggable = true
            // Usar firma de debug por defecto
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            // 2. CORRECCIÓN: Referencia correcta en Kotlin DSL
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

fun googleMapsApiKey(flavor: String): String {
    val fileName = if (flavor == "dev") ".env.dev" else ".env"
    // 3. MEJORA: Ruta más robusta para encontrar el .env en la raíz de Flutter
    val envFile = project.rootProject.file("../$fileName")

    if (!envFile.exists()) {
        println("❌ Warning: Archivo $fileName no encontrado en ${envFile.absolutePath}")
        return "MISSING_KEY"
    }

    return try {
        val props = Properties()
        envFile.inputStream().use { props.load(it) }
        val key = props.getProperty("GOOGLE_MAPS_API_KEY")
        if (key.isNullOrBlank()) "MISSING_KEY" else key.trim()
    } catch (e: Exception) {
        "MISSING_KEY"
    }
}

flutter {
    source = "../.."
}