# Add project specific ProGuard rules here.
# JARVIS v1 ships with minifyEnabled false, so these rules are not applied
# by default. They are kept here in case you enable minification later.

-keep class com.jarvis.assistant.admin.JarvisDeviceAdminReceiver { *; }
-keep class com.jarvis.assistant.service.JarvisOverlayService { *; }
