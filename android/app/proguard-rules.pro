#######################
# FIREBASE MESSAGING (FCM)
#######################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

#######################
# APPSFLYER
#######################
-keep class com.appsflyer.** { *; }
-dontwarn com.appsflyer.**

#######################
# RAZORPAY REQUIRED
#######################
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

#######################
# OKHTTP / GSON (sometimes needed)
#######################
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

#######################
# WOOCOMMERCE (used in Razorpay plugin)
#######################
-keep class org.woocommerce.** { *; }
-dontwarn org.woocommerce.**

#######################
# GOOGLE SIGN-IN / GMS AUTH
#######################
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**

#######################
# KOTLIN REFLECTION FIX
#######################
-keepclassmembers class kotlin.** { *; }
-dontwarn kotlin.**
