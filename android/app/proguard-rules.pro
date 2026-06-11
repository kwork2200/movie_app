## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Ignore missing Play Core classes (not using dynamic features)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

## Gson rules (for JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## Keep all model classes (prevent obfuscation of JSON models)
-keep class com.example.new_movie_app.**.models.** { *; }
-keep class com.example.new_movie_app.**.entities.** { *; }

## Keep all data classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

## Dio (HTTP client)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

## Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items)
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

## With R8 full mode generic signatures are stripped for classes that are not kept
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

## Equatable
-keep class * extends org.equatable.Equatable { *; }
-keepclassmembers class * extends org.equatable.Equatable {
    <fields>;
    <methods>;
}

## Keep all fromJson and toJson methods
-keepclassmembers class * {
    public static ** fromJson(...);
    public ** toJson();
}

## Keep all constructors
-keepclassmembers class * {
    public <init>(...);
}

## Prevent obfuscation of enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
