# Flutter & Flutter Engine
-keep class com.sumireach.app.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google Play Core (Split Install / Deferred Components)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Google Play Services & Firebase
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# Google Sign-in & Auth
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.auth.api.credentials.** { *; }
-keep class com.google.android.gms.common.api.** { *; }

# OkHttp, Coroutines & AndroidX
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn kotlinx.coroutines.**
-dontwarn androidx.**