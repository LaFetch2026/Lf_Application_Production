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
# KOTLIN REFLECTION FIX
#######################
-keepclassmembers class kotlin.** { *; }
-dontwarn kotlin.**
