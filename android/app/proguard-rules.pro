# 🔒 ProGuard/R8 Configuration per GymBro TrackLog
# Abilita code obfuscation, rimozione codice debug, shrinking risorse

# ============================================================================
# FLUTTER CORE RULES
# ============================================================================

# Mantieni classi native Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mantieni GeneratedPluginRegistrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Mantieni metodi nativi
-keepclassmembers class * {
    native <methods>;
}

# ============================================================================
# FIREBASE RULES
# ============================================================================

# Firebase Core
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.protobuf.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.auth.** { *; }

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.android.gms.measurement.** { *; }

# Firebase Messaging (FCM)
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }

# Firebase Performance
-keep class com.google.firebase.perf.** { *; }

# ============================================================================
# GOOGLE SIGN IN
# ============================================================================

-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# ============================================================================
# KOTLIN RULES
# ============================================================================

# Kotlin Metadata
-keep class kotlin.Metadata { *; }
-keepattributes RuntimeVisibleAnnotations

# Kotlin Coroutines
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# ============================================================================
# GSON / JSON SERIALIZATION
# ============================================================================

-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Mantieni classi modello dati (aggiungi qui le tue data class)
-keep class com.micheleferrero93.GymProgressAppNew.**.models.** { *; }
-keep class com.micheleferrero93.GymProgressAppNew.**.entities.** { *; }

# ============================================================================
# HIVE DATABASE
# ============================================================================

-keep class * extends io.flutter.plugins.** { *; }
-keepclassmembers class * extends io.flutter.plugins.** { *; }

# ============================================================================
# CRASHLYTICS (se usato)
# ============================================================================

-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.crashlytics.** { *; }
-dontwarn com.crashlytics.**

# ============================================================================
# ADMOB (se usato)
# ============================================================================

-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# ============================================================================
# GENERAL ANDROID RULES
# ============================================================================

# Mantieni attributi necessari per reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Mantieni Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Mantieni Serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============================================================================
# OPTIMIZATION FLAGS
# ============================================================================

# Abilita ottimizzazioni aggressive (può aumentare tempo build ma migliora performance)
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Rimuovi log in produzione (IMPORTANTE per sicurezza!)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# ============================================================================
# DEBUGGING (commentare in produzione)
# ============================================================================

# Se hai problemi di build, decommentare temporaneamente:
# -dontobfuscate
# -printmapping mapping.txt
# -printseeds seeds.txt
# -printusage usage.txt

# ============================================================================
# GOOGLE PLAY CORE (Dynamic Feature Delivery)
# ============================================================================

# Flutter references these classes but we don't use dynamic feature delivery
# Suppress warnings about missing Play Core classes (generated from missing_rules.txt)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# ============================================================================
# CUSTOM RULES - Aggiungi qui regole specifiche per la tua app
# ============================================================================

# Esempio: Se usi reflection per accedere a classi/metodi specifici
# -keep class com.tuaapp.MiaClasse { *; }
