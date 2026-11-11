# Lumi — Engineering & Architecture Decisions

## 1. Local Build & Verification Target (Platform Toolchain Availability)
- **Observation**: The development machine runs macOS 26.7.2 (x86_64) with Xcode Command Line Tools only (no full `Xcode.app` / CocoaPods), OpenJDK 21 (`Temurin-21`), and headless Android SDK (`~/Library/Android/sdk` with `cmdline-tools/latest`, `platform-tools`, platforms 35/36/37, build-tools 35/36/37, NDK `28.2.13676358`, CMake `3.22.1`), alongside Google Chrome (`157.x`) and Flutter `3.47.9` (at `~/development/flutter`).
- **Decision**:
  - Full Android (`android/` Gradle `9.4.1` + AGP `9.2.1` with `compileSdk = 37` for `flutter_local_notifications` + `androidx.core:1.19.0`, `AndroidManifest.xml`, `FlutterFragmentActivity`, desugaring, `-Xmx3G` JVM heap sizing, exact-alarm/notification/media/biometric permissions) and iOS (`ios/` `Info.plist`, `AppDelegate.swift` notification delegate, app icon assets) configurations are authored and kept up to date.
  - Android release APKs build directly via `flutter build apk --release` (`build/app/outputs/flutter-apk/app-release.apk`) and `flutter build apk --release --split-per-abi`. Using AGP `9.2.1` + Gradle `9.4.1` (`sdklib 32.2.1`) natively supports Android API 37 and SDK XML schema v4 emitted by Android CLI 23.0, while a local symlink (`platforms/android-37 -> android-37.0`) maps the `platforms;android-37.0` directory name.
  - Because native iOS/macOS compilers (`Xcode.app` / CocoaPods) are unavailable on this host, UI/runtime verification uses `flutter analyze`, `dart format`, `flutter test`, `flutter build apk --release`, and live previews in **Chrome** (`build/web`), with platform-safe `kIsWeb` guards around native-only APIs (`dart:io` file storage, `local_auth`, `flutter_local_notifications` native permissions).
  - Desktop targets (`macos`, `windows`) remain enabled with responsive layouts and zero mobile-only assumptions in core logic.

## 2. State Management (Riverpod 3.x without codegen)
- **Observation**: `flutter_riverpod 3.5.0` resolved cleanly alongside `drift 2.35.4`, `drift_dev 2.35.3`, and `flutter_quill 11.6.0`.
- **Decision**: Use `drift_dev` code generation for Drift tables/DAOs and explicit typed Riverpod `NotifierProvider`, `StreamProvider`, and `Provider` definitions (rather than mixing `riverpod_generator` with `drift_dev`) to keep `build_runner` fast, deterministic, and conflict-free.
