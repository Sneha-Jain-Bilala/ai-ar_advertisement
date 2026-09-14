# AR Camera & 3D Viewer — Setup / Fix Checklist (flutter_sceneview 4.35.0)

Fixes: *"3D product opens but is not interactive"* and *"AR has no camera, just a static image"*.

---

## 1. What was wrong in the Dart code (already fixed in the attached files)

| Symptom | Root cause | Fix |
|---|---|---|
| 3D model not interactive (no orbit / no zoom) | `SceneView` was wrapped in `GestureDetector(onScaleUpdate:)`. A scale recognizer claims **both** drags and pinches, wins the Flutter gesture arena, and the native platform view never receives a touch — the built-in **orbit camera** stayed dead. Also `rotateModel()/scaleModel()` only mutated Dart state that was never sent to the native model. | Removed the competing `GestureDetector`. Native orbit camera now owns gestures. A passive `Listener` (doesn't join the gesture arena) records `rotated3D`/`scaled3D` telemetry only. |
| Scale buttons / provider scale did nothing | `SceneViewController` (4.35.0) has **no** transform API. The only supported way to resize is `clearScene()` + `loadModel(ModelNode(scale: …))`. | Debounced clear+reload pipeline in `ArViewerScreen._applyScaleToScene()`. |
| AR mode = static image, no camera | `ARSceneView` **requires CAMERA permission on both Android and iOS** (plugin docs). The app never requested it → ARCore session can't start → frozen first frame. | Runtime permission flow (`permission_handler`), auto-enter AR after grant, dialog + Settings deep-link on denial, graceful 3D-studio fallback. |
| Model missing on iOS | RealityKit **cannot load `.glb`** — the failure is only logged natively. | `_resolveModelPath()` swaps `.glb` → `.usdz` on iOS. Ship `.usdz` siblings. |
| Double model load | `initialModels` **and** `onViewCreated → loadModel` were both used. | Load once, from `onViewCreated`. |

**Files:** `ar_viewer_screen.dart` (rewrite), `ar_view_provider.dart` (additive: `markRotated()`, `markScaled()`; existing API untouched).

---

## 2. `pubspec.yaml`

```yaml
dependencies:
  flutter_sceneview: ^4.35.0
  permission_handler: ^11.3.0   # runtime CAMERA permission for ARSceneView

flutter:
  assets:
    - assets/models/            # must contain shoe.glb ... AND shoe.usdz ... for iOS
```

---

## 3. Android — `android/app/src/main/AndroidManifest.xml`

ARCore will refuse to start the camera without these:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- CAMERA is mandatory for ARSceneView (ARCore session) -->
    <uses-permission android:name="android.permission.CAMERA" />

    <!-- App runs everywhere; AR degrades gracefully to 3D Studio -->
    <uses-feature android:name="android.hardware.camera.ar" android:required="false" />
    <uses-feature android:glEsVersion="0x00030000" android:required="true" />

    <application ...>
        <!-- Lets Play Services install/update "Google Play Services for AR" -->
        <meta-data android:name="com.google.ar.core" android:value="optional" />
        ...
    </application>
</manifest>
```

`android/app/build.gradle` (or `.kts`):

```gradle
android {
    defaultConfig {
        minSdkVersion 24      // hard requirement of the plugin
    }
}
```

> If `mobile_scanner` already merged a CAMERA permission into your manifest,
> keep it — both plugins share the same permission. The *runtime request* is
> what was missing (now handled in `ArViewerScreen._ensureCameraPermission`).

---

## 4. iOS

**`ios/Runner/Info.plist`** — without this string the camera never opens:

```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to display products in augmented reality.</string>
```

**`ios/Podfile`** — the plugin needs `SceneViewSwift` (RealityKit renderer),
which is not on CocoaPods trunk. Minimum iOS 18:

```ruby
platform :ios, '18.0'

target 'Runner' do
  use_frameworks!

  # flutter_sceneview bridge — SceneViewSwift is not published to trunk,
  # so point the Podfile at the repo's podspec (see plugin README).
  pod 'SceneViewSwift', :podspec => 'https://raw.githubusercontent.com/sceneview/sceneview/main/SceneViewSwift.podspec'

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

Then:

```bash
cd ios && pod install && cd ..
```

> Plugin README warning: pin flutter_sceneview **v4.27.0 or newer** (you are
> on 4.35.0 — fine). iOS 3D models must be `.usdz`/`.reality`; `.glb` is
> silently ignored on iOS.

---

## 5. Device requirements (why you may still see a static AR view)

| Requirement | Check |
|---|---|
| **Physical device** — ARCore does NOT run on emulators | Test on a real phone |
| **Google Play Services for AR** installed (Android) | Play Store → "Google Play Services for AR", or the app prompts on first AR launch |
| Device on the ARCore supported list | https://developers.google.com/ar/devices |
| Camera permission granted | Now requested automatically on entering AR |
| iOS 18+ with ARKit | iPhone SE/6s and older are out |

---

## 6. Verifying & debugging

`onModelLoaded` is **not bridged** in 4.35.0 — a failed model load is silent on
the Dart side. Grep the native logs:

```bash
# Android
adb logcat | grep -E "flutter_sceneview|ARCore|SceneView"
#   → "[flutter_sceneview] Cannot load AR model '<path>'" = RealityKit/format issue
#   → "[flutter_sceneview] Failed to load AR model '<path>'" = anything else

# iOS (Xcode console)
#   → "[SceneViewSwift] SceneViewerHostView failed to load model '<path>'"
```

Quick sanity matrix:

| Mode | Works on | Gestures |
|---|---|---|
| 3D Studio (`SceneView`, orbit) | Android + iOS | 1-finger drag = rotate, 2-finger pinch = zoom (native) |
| AR (`ARSceneView`) | Physical devices w/ ARCore / ARKit | Move phone to scan plane; model placed 0.85 m ahead |

---

## 7. Known plugin limitations to design around (4.35.0, from official README)

- **No programmatic model rotation** — orbit camera is the only rotation. `ModelNode` has only `x/y/z/scale`.
- `onPlaneDetected` events and AR taps: **Android only** (iOS bridge gap #909 / #2051).
- `autoCenterContent`: iOS-first; Android side tracked in issue #1051.
- `CameraControlMode.pan/.firstPerson`: iOS-only; Android falls back to orbit.
- Torch/flash for the AR view: **not bridged** (the HUD flash button stays cosmetic).
- No 3D→2D projection API — the floating hotspots remain screen-anchored overlays.
- Geometry/light nodes render on Android only.

If true model-anchored hotspots or torch become hard requirements, consider
`ar_flutter_plugin` (ARCore/ARKit via session APIs) as a complementary package.
