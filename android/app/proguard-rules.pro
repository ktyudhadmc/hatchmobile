# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ML Kit (mobile_scanner)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Riverpod / Dart AOT
-keep class * extends java.lang.annotation.Annotation { *; }

# Jangan obfuscate class yang pakai reflection
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Flutter deferred components (Play Core) - tidak dipakai di app ini
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