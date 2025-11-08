# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Flutter Engine
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Google Maps
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# JSON / Serialization (Gson, Moshi, etc.)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepattributes Signature
-keepattributes *Annotation*

# Reflexión (si usas)
-keepattributes InnerClasses, EnclosingMethod

# Tu código (opcional: si usas reflexión)
# -keep class com.example.app_properties.** { *; }

# Evita warnings de bibliotecas
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.**
-dontwarn com.google.errorprone.annotations.**

# R8 full mode (si usas)
-keepattributes SourceFile,LineNumberTable