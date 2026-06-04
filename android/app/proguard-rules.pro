
Set-Content -Path "android\app\proguard-rules.pro" -Value @"
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.**
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**
"@