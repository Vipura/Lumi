import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/design/design_system.dart';

@immutable
class LumiUserSettings {
  const LumiUserSettings({
    this.themeMode = ThemeMode.system,
    this.backgroundTheme = LumiBackgroundTheme.aurora,
    this.accentPreset = LumiAccentPreset.warmAmber,
    this.reduceTransparency = false,
    this.reduceMotion = false,
    this.hapticsEnabled = true,
    this.biometricLockEnabled = false,
    this.onboardingCompleted = false,
    this.notesGridView = true,
    this.recentSearches = const [],
  });

  final ThemeMode themeMode;
  final LumiBackgroundTheme backgroundTheme;
  final LumiAccentPreset accentPreset;
  final bool reduceTransparency;
  final bool reduceMotion;
  final bool hapticsEnabled;
  final bool biometricLockEnabled;
  final bool onboardingCompleted;
  final bool notesGridView;
  final List<String> recentSearches;

  LumiUserSettings copyWith({
    ThemeMode? themeMode,
    LumiBackgroundTheme? backgroundTheme,
    LumiAccentPreset? accentPreset,
    bool? reduceTransparency,
    bool? reduceMotion,
    bool? hapticsEnabled,
    bool? biometricLockEnabled,
    bool? onboardingCompleted,
    bool? notesGridView,
    List<String>? recentSearches,
  }) {
    return LumiUserSettings(
      themeMode: themeMode ?? this.themeMode,
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      accentPreset: accentPreset ?? this.accentPreset,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      notesGridView: notesGridView ?? this.notesGridView,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'lumi.themeMode';
  static const _kBgTheme = 'lumi.backgroundTheme';
  static const _kAccent = 'lumi.accentPreset';
  static const _kReduceTransparency = 'lumi.reduceTransparency';
  static const _kReduceMotion = 'lumi.reduceMotion';
  static const _kHaptics = 'lumi.hapticsEnabled';
  static const _kBiometric = 'lumi.biometricLockEnabled';
  static const _kOnboarding = 'lumi.onboardingCompleted';
  static const _kNotesGrid = 'lumi.notesGridView';
  static const _kRecentSearches = 'lumi.recentSearches';

  LumiUserSettings load() {
    final themeIndex = _prefs.getInt(_kThemeMode) ?? ThemeMode.system.index;
    final bgName = _prefs.getString(_kBgTheme);
    final accentName = _prefs.getString(_kAccent);

    return LumiUserSettings(
      themeMode:
          ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1)],
      backgroundTheme: LumiBackgroundTheme.values.firstWhere(
        (e) => e.name == bgName,
        orElse: () => LumiBackgroundTheme.aurora,
      ),
      accentPreset: LumiAccentPreset.values.firstWhere(
        (e) => e.name == accentName,
        orElse: () => LumiAccentPreset.warmAmber,
      ),
      reduceTransparency: _prefs.getBool(_kReduceTransparency) ?? false,
      reduceMotion: _prefs.getBool(_kReduceMotion) ?? false,
      hapticsEnabled: _prefs.getBool(_kHaptics) ?? true,
      biometricLockEnabled: _prefs.getBool(_kBiometric) ?? false,
      onboardingCompleted: _prefs.getBool(_kOnboarding) ?? false,
      notesGridView: _prefs.getBool(_kNotesGrid) ?? true,
      recentSearches: _prefs.getStringList(_kRecentSearches) ?? const [],
    );
  }

  Future<void> save(LumiUserSettings settings) async {
    await _prefs.setInt(_kThemeMode, settings.themeMode.index);
    await _prefs.setString(_kBgTheme, settings.backgroundTheme.name);
    await _prefs.setString(_kAccent, settings.accentPreset.name);
    await _prefs.setBool(_kReduceTransparency, settings.reduceTransparency);
    await _prefs.setBool(_kReduceMotion, settings.reduceMotion);
    await _prefs.setBool(_kHaptics, settings.hapticsEnabled);
    await _prefs.setBool(_kBiometric, settings.biometricLockEnabled);
    await _prefs.setBool(_kOnboarding, settings.onboardingCompleted);
    await _prefs.setBool(_kNotesGrid, settings.notesGridView);
    await _prefs.setStringList(_kRecentSearches, settings.recentSearches);
  }
}
