# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/laina/Library/Android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

#ARouter
-keep public class com.alibaba.android.arouter.routes.**{*;}
-keep public class com.alibaba.android.arouter.facade.**{*;}
-keep class * implements com.alibaba.android.arouter.facade.template.ISyringe{*;}

-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontnote
-verbose

-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.app.IntentService
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class com.android.vending.licensing.ILicensingService

-dontoptimize
-dontpreverify

-dontwarn cn.jpush.**
-keep class cn.jpush.** { *; }
-keep class * extends cn.jpush.android.helpers.JPushMessageReceiver { *; }
-keep class * extends com.mk.autosecure.jpush.PushMessageReceiver { *; }

-dontwarn com.google.**
-keep class com.google.gson.** {*;}
-keep class com.google.protobuf.** {*;}

-dontwarn cn.jiguang.**
-keep class cn.jiguang.** { *; }

-dontwarn cn.jpush.**
-keep class cn.jpush.** { *; }

-keep class com.nt.moc_lib.icao.CardInfo
-keepnames class com.nt.moc_lib.icao.CardInfo
-keepclassmembers class com.nt.moc_lib.icao.CardInfo {
   public *;
}


-keep class com.nt.moc_lib.icao.ReadIcaoClass
-keepnames class com.nt.moc_lib.icao.ReadIcaoClass
-keepclassmembers class com.nt.moc_lib.icao.ReadIcaoClass {
   public *;
}


-keep class com.nt.moc_lib.icao.ReadCard
-keepnames class com.nt.moc_lib.icao.ReadCard
-keepclassmembers class com.nt.moc_lib.icao.ReadCard {
   public *;
}

-keep class com.nt.moc_lib.org**{ *; }
-keep class com.nt.sdk**{ *; }
-keep class com.nt.callback**{ *; }
-keep class com.nt.config**{ *; }
-keep class com.nt.fingerprint**{ *; }
-keep class com.nt.keystoremanager**{ *; }
-keep class com.nt.libotpprivate**{ *; }
-keep class com.nt.otp**{ *; }
-keep class com.nt.result**{ *; }
-keep class com.nt.token**{ *; }
-keep class com.nt.util**{ *; }
-keep class com.nt.SdkExceptions**{ *; }
-keep class com.neurotec.face**{ *; }
-keep class com.neurotec.face.verification.client**{ *; }
-keep class com.neurotec.face.verification.server**{ *; }
-keep class com.sun.jna**{ *; }
-keep class com.squareup.okhttp**{ *; }


# 如果使用了 byType 的方式获取 Service，需添加下面规则，保护接口
# -keep interface * implements com.alibaba.android.arouter.facade.template.IProvider

# 如果使用了 单类注入，即不定义接口实现 IProvider，需添加下面规则，保护实现
# -keep class * implements com.alibaba.android.arouter.facade.template.IProvider
