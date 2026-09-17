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