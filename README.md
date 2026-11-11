# Lumi

**Lumi** ("light shining through glass") is an offline-first all-in-one notes, nested checklists, reminders, attachments, sticky notes, and daily planning app built with **Flutter** and an Apple-inspired **Liquid Glass** design system.

---

## Features (v1)

- **Lumi Glass Design System (`lib/core/design/`)**:
  - Reusable `LumiGlass` surface (`ClipRRect` + `BackdropFilter` + translucent directional gradient + 1px rim border + inner highlight + press-scale/haptic feedback) plus lightweight `LumiGlass.card` for 60/120 fps scrolling lists.
  - `LumiBackground` animated multi-orb ambient canvas with **5 themes** (*Aurora*, *Sunset*, *Ocean*, *Forest*, *Mono*), automatic Light/Dark modes, time-of-day shift on the Today view, and full *Reduce transparency* / *Reduce motion* accessibility fallbacks.
  - Custom drawn `LumiLogo` glowing glass droplet mark.
- **Instant Capture (< 2s)**: Quick-capture bar on Today plus a glowing center `+` glass capture sheet for **Notes**, **Checklists**, **Sticky Notes**, **Voice Notes**, **Photos**, **Reminders**, and **Templates**.
- **Rich Text Notes & Editor**: Powered by `flutter_quill` storing Quill Delta JSON, auto-saving continuously, auto-deriving titles from the first line, showing live word counts, and keeping the reading/writing surface clean and distraction-free.
- **Checklists**: Nested parent/child items, drag-and-drop reordering, live progress rings (`LumiProgressRing`), per-item reminders, and one-tap **rollover unfinished tasks to tomorrow**.
- **Reminders & Local Notifications**: One-time and repeating rules (daily/weekly/monthly), snooze actions (15m / 1h / tomorrow), iOS & Android 13+ notification/exact-alarm permission handling via `flutter_local_notifications` + `timezone`.
- **Attachments**: Camera & gallery photos (with isolate-generated thumbnails), files/PDFs, voice recordings (`record` + `just_audio` inline player), and offline-safe web link preview cards.
- **Sticky Wall**: Infinite zoom/pan `InteractiveViewer` dot-grid canvas with draggable, resizable, recolorable, pinnable sticky notes in 8 soft pastel swatches with persisted X/Y/W/H/Z state.
- **Daily Planning**:
  - **Today view**: Time-aware greeting, quick capture bar, completed-today progress ring, evening unfinished-task rollover prompt, reminders, due tasks, and pinned notes.
  - **Planner**: Month/Week **Calendar** view + **Boards** (To do / Doing / Done) with drag-and-drop and quick-move controls.
- **Organization, Search & Templates**: Collections (*Personal*, *Work*, *Study* + custom), `#tags`, color labels, pin, archive, 30-day recoverable Trash, instant search (FTS5 + indexed LIKE across titles, body, checklists, tags, attachments), and 5 built-in templates (*Daily plan*, *Weekly review*, *Meeting notes*, *Shopping list*, *Study notes*).
- **Export, Biometric Lock & Local Backup**: Note export as **Markdown (`.md`)** and **PDF (`.pdf`)**, optional biometric/device lock (`local_auth`), and full offline **`.zip` backup & restore** (JSON payload + attachment files).

---

## Project Structure

```text
lib/
├── main.dart
├── app/                   # App bootstrap, GoRouter routes, floating glass shell
├── core/
│   ├── design/            # Tokens, themes, LumiGlass, LumiBackground, gallery
│   └── utils/             # Delta JSON utilities & platform-safe file/image helpers
├── data/
│   ├── db/                # Drift schema, tables, DAOs, SQLite/WASM connection
│   └── repositories/      # Repository interfaces, Riverpod providers, sample seed
└── features/
    ├── attachments/
    ├── capture/
    ├── checklist/
    ├── editor/
    ├── notes/
    ├── onboarding/
    ├── planner/
    ├── reminders/
    ├── search/
    ├── settings/
    ├── sticky_wall/
    ├── templates/
    └── today/
```

---

## Tech Stack

- **Flutter** `3.47+` / **Dart** `3.13+` (null safety, Material 3)
- **State management**: `flutter_riverpod`
- **Navigation**: `go_router`
- **Local database**: `drift` + `drift_flutter` + FTS5 (`sqlite3.wasm` + `drift_worker.js` bundled in `web/`)
- **Rich text**: `flutter_quill`
- **Reminders**: `flutter_local_notifications`, `timezone`, `flutter_timezone`
- **Media & files**: `image_picker`, `file_picker`, `path_provider`, `record`, `just_audio`, `url_launcher`, `image`, `pdf`, `archive`, `share_plus`
- **UX & Auth**: `flutter_animate`, `google_fonts`, `local_auth`, `shared_preferences`, `uuid`, `intl`

---

## Setup & Running

### 1. Prerequisites
- **Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)** (`>= 3.47.0`, Dart `>= 3.13.0`).
- **Android**: Android SDK (`compileSdk 37`, `minSdk 24`) & JDK 17+.
- **iOS / macOS**: Xcode + CocoaPods on macOS (`ios/` and `macos/` include privacy descriptions, sandbox entitlements, and notification setup).
- **Windows**: Visual Studio 2022 with *Desktop development with C++* (plus optional [Inno Setup](https://jrsoftware.org/isinfo.php) for `.exe` installer packaging).
- **Ubuntu / Linux**: `build-essential clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev`.

### 2. Install dependencies & run codegen
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run the app
```bash
# Android / iOS emulator or connected device
flutter run

# Web preview (Chrome)
flutter run -d chrome

# Desktop (enable desired desktop target via flutter config if needed)
flutter run -d macos
flutter run -d windows
flutter run -d linux
```

### 4. Format, Analyze & Test
```bash
dart format lib test
flutter analyze
flutter test
```

---

## Releases & CI/CD

Lumi uses GitHub Actions on `main` + version tags (`v*`):

- **Continuous Integration ([`.github/workflows/ci.yml`](./.github/workflows/ci.yml))**: Runs formatting, `flutter analyze`, and `flutter test` on every push or PR targeting `main`.
- **Cross-Platform Releases ([`.github/workflows/release.yml`](./.github/workflows/release.yml))**: Pushing a semantic version tag (`v1.0.0`, etc.) verifies checks and builds downloadable installers/bundles in parallel for all supported platforms, attaching them plus `SHA256SUMS.txt` to a GitHub Release:
  - **Android**: `Lumi-<version>-android-arm64-v8a.apk`, `armeabi-v7a`, `x86_64`, and `universal.apk`
  - **Windows (x64)**: `Lumi-<version>-windows-x64-setup.exe` (via [Inno Setup](./.github/packaging/windows_installer.iss)) & portable `.zip`
  - **macOS (Universal)**: `Lumi-<version>-macos-universal.dmg`
  - **Ubuntu / Linux (x64)**: `Lumi-<version>-linux-x64.tar.gz`

### Cutting a Release
```bash
git tag v1.0.0
git push origin v1.0.0
```

See [DECISIONS.md](./DECISIONS.md) for architecture notes and environment/toolchain details.
