# Lumi — Engineering & Architecture Decisions

## 1. Local Build & Verification Target (Platform Toolchain Availability)
- **Observation**: The development machine runs macOS 26.7.2 (x86_64) with Xcode Command Line Tools only (no full `Xcode.app` / CocoaPods), OpenJDK 21 (`Temurin-21`), and headless Android SDK (`~/Library/Android/sdk` with `cmdline-tools/latest`, `platform-tools`, platforms 35/36/37, build-tools 35/36/37, NDK `28.2.13676358`, CMake `3.22.1`), alongside Google Chrome (`157.x`) and Flutter `3.47.9` (at `~/development/flutter`).
- **Decision**:
  - Full Android (`android/` Gradle, `AndroidManifest.xml`, `FlutterFragmentActivity`, desugaring, exact-alarm/notification/media/biometric permissions) and iOS (`ios/` `Info.plist`, `AppDelegate.swift` notification delegate, app icon assets) configurations are authored cleanly.
  - Because native iOS/macOS compilers (`Xcode.app` / CocoaPods) are unavailable on this host, UI/runtime verification uses `flutter analyze`, `dart format`, `flutter test`, `flutter build apk --release`, and live previews in **Chrome** (`build/web`), with platform-safe `kIsWeb` guards around native-only APIs (`dart:io` file storage, `local_auth`, `flutter_local_notifications` native permissions).
  - Desktop targets (`macos`, `windows`) remain enabled with responsive layouts and zero mobile-only assumptions in core logic.

## 2. State Management (Riverpod 3.x without codegen)
- **Observation**: `flutter_riverpod 3.5.0` resolved cleanly alongside `drift 2.35.4`, `drift_dev 2.35.3`, and `flutter_quill 11.6.0`.
- **Decision**: Use `drift_dev` code generation for Drift tables/DAOs and explicit typed Riverpod `NotifierProvider`, `StreamProvider`, and `Provider` definitions (rather than mixing `riverpod_generator` with `drift_dev`) to keep `build_runner` fast, deterministic, and conflict-free.

## 3. Offline Persistence on Native + Web Preview Asset Setup
- **Decision**:
  - Use Drift (`drift` + `drift_flutter`) as the offline-first SQLite source of truth on Android, iOS, macOS, and Windows (with FTS5 virtual table + trigger sync on native SQLite, falling back cleanly to indexed `LIKE` queries if FTS5 is unavailable in an environment).
  - For full persistent SQLite support in Chrome/Web previews (`database_connection.dart` via `DriftWebOptions`), the matching Drift `2.35.x` web binaries (`web/sqlite3.wasm` and `web/drift_worker.js`) are bundled locally in `web/`.

## 4. Rich Text, File Picking, Thumbnails, PDF Export & Backups
- **Decision**:
  - Store note bodies as `flutter_quill` Delta JSON (`dart_quill_delta`), with plain-text extraction helpers for search indexing, card previews, auto-titling, word count, and Markdown/PDF export.
  - Use `file_picker 13.3.3` static `FilePicker.pickFile()` and `PlatformFile.readAsBytes()` API so file attachments and `.zip` backup restores work cleanly across both Web and native platforms.
  - Use pure-Dart `image`, `pdf`, and `archive` packages so thumbnail generation, PDF note export, and JSON+attachments `.zip` backup/restore work consistently offline across Android, iOS, macOS, and Windows.
  - Link preview metadata uses a real short-timeout HTTP OpenGraph fetch with immediate offline URL parsing fallback so offline capture stays instant (< 2 s).
  - Scope list-to-editor `Hero` tags by source (`notes` vs `today`) so cards inside `StatefulShellRoute.indexedStack` never conflict across active tabs while still animating smoothly into `NoteEditorScreen`.

