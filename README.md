# JARVIS (Android, Kotlin + Jetpack Compose)

A real Android app that locks the phone's screen on a voice command, using
Android's official `DevicePolicyManager.lockNow()` device-admin API.

**This is not a simulation.** There is no fake black-screen Activity. Locking
is performed by the real system `DevicePolicyManager`, the same mechanism
used by MDM / "Find My Device"-style apps.

## Voice commands supported (v1)
- "screen off"
- "screen lock"
- "lock my phone"
- "screen off chey"
- "phone lock chey"
- "screen ni off chey"

## How it works
1. `MainActivity` guides the user through granting Device Administrator,
   Microphone, and "Display over other apps" permissions.
2. Tapping **ACTIVATE JARVIS** starts `JarvisOverlayService`, a foreground
   service that draws a small floating "JARVIS" bubble using
   `WindowManager` + a `ComposeView` (a real system overlay window, visible
   above the home screen / any app).
3. The service immediately starts `android.speech.SpeechRecognizer` and
   listens for one of the phrases above.
4. On a match, it calls `ScreenLockManager.lockScreenNow()`, which calls
   `DevicePolicyManager.lockNow()` — the real Android screen lock API.
5. The overlay shows "Screen locked" briefly, then disappears and the
   service stops itself.

**LOCK SCREEN NOW** on the main screen calls the exact same
`ScreenLockManager.lockScreenNow()` function, without going through voice,
for testing.

## Project structure
```
app/src/main/java/com/jarvis/assistant/
  MainActivity.kt                     Setup screen + permission flow
  admin/JarvisDeviceAdminReceiver.kt  Required DeviceAdminReceiver
  manager/ScreenLockManager.kt        DevicePolicyManager.lockNow() wrapper
  voice/VoiceRecognitionManager.kt    SpeechRecognizer + command matching
  service/JarvisOverlayService.kt     Foreground service + overlay window
  ui/                                 Jetpack Compose screens & theme
app/src/main/res/xml/device_admin_receiver.xml   Device-admin policy (force-lock only)
app/src/main/AndroidManifest.xml
```

## Permissions requested (and only these)
| Permission | Why |
|---|---|
| Device Administrator (`force-lock` policy) | Required for `lockNow()` |
| `RECORD_AUDIO` | Voice command recognition |
| `SYSTEM_ALERT_WINDOW` | Floating JARVIS overlay |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MICROPHONE` | Keep the mic/overlay alive reliably while listening |
| `POST_NOTIFICATIONS` | Required by Android 13+ to show the foreground-service notification |

No storage, contacts, location, camera, or other unrelated permissions are requested.

## Build & run — exact steps
1. Download/export this project folder (or the zip you were given).
2. Open **Android Studio** → **Open** → select the `JARVIS` folder.
3. Wait for **Gradle sync** to finish (Android Studio will download the
   Gradle wrapper JAR automatically on first sync — an internet connection
   is required for this step).
4. Confirm there are no missing dependencies (File → Sync Project with
   Gradle Files if needed).
5. Connect a **physical Android device** (Android 8.0 / API 26 or higher)
   with USB debugging enabled, and select it as the run target.
   (An emulator technically launches, but `lockNow()` and overlay
   permissions are best verified on a real device.)
6. **Build → Build Bundle(s) / APK(s) → Build APK(s)**.
7. When the build finishes, click **locate** in the notification (or find
   it at `app/build/outputs/apk/debug/app-debug.apk`).
8. Copy/install the APK onto the phone (or just click ▶ Run in Android
   Studio to install + launch directly).
9. Open the **JARVIS** app.
10. Tap **ENABLE SCREEN LOCK** → accept the Device Administrator prompt.
11. Tap **GRANT MICROPHONE PERMISSION** → allow.
12. Tap **GRANT OVERLAY PERMISSION** → enable "Display over other apps" for JARVIS.
13. Tap **LOCK SCREEN NOW** to confirm the real lock works immediately.
14. Press Home, tap **ACTIVATE JARVIS** first (from inside the app) so the
    overlay/service starts, then say **"screen off chey"** (or any of the
    supported phrases) → the phone's screen locks for real, and the JARVIS
    bubble disappears.

## Notes on v1 scope
This build intentionally does only one thing end-to-end and does it for
real: voice-triggered, real `DevicePolicyManager` screen locking. It does
not include wake-word/always-on listening, additional assistant commands,
or cloud services — those are natural v2 additions once this core flow is
verified on your device.
