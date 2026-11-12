import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/design_system.dart';
import '../data/repositories/lumi_models.dart';
import '../data/repositories/providers.dart';
import '../features/reminders/foreground_alarm_coordinator.dart';
import '../features/reminders/notification_service.dart';
import '../features/settings/biometric_lock_gate.dart';
import 'lumi_router.dart';

class LumiApp extends ConsumerStatefulWidget {
  const LumiApp({super.key, this.useGoogleFonts = true});

  final bool useGoogleFonts;

  @override
  ConsumerState<LumiApp> createState() => _LumiAppState();
}

class _LumiAppState extends ConsumerState<LumiApp> {
  ThemeData? _cachedLightTheme;
  ThemeData? _cachedDarkTheme;
  Object? _themeCacheKey;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final router = ref.read(lumiRouterProvider);
      await ref
          .read(notificationServiceProvider)
          .initialize(
            onNotificationTap: (payload) async {
              if (payload == null || payload.isEmpty) return;
              final item = await ref
                  .read(itemsRepositoryProvider)
                  .getItem(payload);
              if (item?.type == LumiItemType.reminder.dbValue) {
                router.go('/reminders');
              } else if (item?.type == LumiItemType.calm.dbValue) {
                await router.push('/calm/$payload');
              } else {
                await router.push('/editor/$payload');
              }
            },
          );
      await ref.read(itemsRepositoryProvider).purgeExpiredTrash();
    });
  }

  void _ensureThemes({
    required Color accent,
    required bool reduceTransparency,
    required bool reduceMotion,
  }) {
    final key = (
      accent,
      reduceTransparency,
      reduceMotion,
      widget.useGoogleFonts,
    );
    if (_themeCacheKey == key &&
        _cachedLightTheme != null &&
        _cachedDarkTheme != null) {
      return;
    }
    _themeCacheKey = key;
    _cachedLightTheme = LumiThemes.build(
      brightness: Brightness.light,
      accentColor: accent,
      reduceTransparency: reduceTransparency,
      reduceMotion: reduceMotion,
      useGoogleFonts: widget.useGoogleFonts,
    );
    _cachedDarkTheme = LumiThemes.build(
      brightness: Brightness.dark,
      accentColor: accent,
      reduceTransparency: reduceTransparency,
      reduceMotion: reduceMotion,
      useGoogleFonts: widget.useGoogleFonts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(lumiRouterProvider);
    final accent = settings.accentPreset.color;

    _ensureThemes(
      accent: accent,
      reduceTransparency: settings.reduceTransparency,
      reduceMotion: settings.reduceMotion,
    );

    return LumiDesignScope(
      reduceTransparency: settings.reduceTransparency,
      reduceMotion: settings.reduceMotion,
      hapticsEnabled: settings.hapticsEnabled,
      backgroundTheme: settings.backgroundTheme,
      accentColor: accent,
      child: MaterialApp.router(
        title: 'Lumi',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        scrollBehavior: const _LumiScrollBehavior(),
        themeMode: settings.themeMode,
        theme: _cachedLightTheme,
        darkTheme: _cachedDarkTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: FlutterQuillLocalizations.supportedLocales,
        builder: (context, child) => BiometricLockGate(
          child: ForegroundAlarmCoordinator(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _LumiScrollBehavior extends MaterialScrollBehavior {
  const _LumiScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
