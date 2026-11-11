import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/design_system.dart';
import '../data/repositories/providers.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final router = ref.read(lumiRouterProvider);
      await ref
          .read(notificationServiceProvider)
          .initialize(
            onNotificationTap: (payload) {
              if (payload != null && payload.isNotEmpty) {
                router.push('/editor/$payload');
              }
            },
          );
      await ref.read(itemsRepositoryProvider).purgeExpiredTrash();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(lumiRouterProvider);
    final accent = settings.accentPreset.color;

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
        themeMode: settings.themeMode,
        theme: LumiThemes.build(
          brightness: Brightness.light,
          accentColor: accent,
          reduceTransparency: settings.reduceTransparency,
          reduceMotion: settings.reduceMotion,
          useGoogleFonts: widget.useGoogleFonts,
        ),
        darkTheme: LumiThemes.build(
          brightness: Brightness.dark,
          accentColor: accent,
          reduceTransparency: settings.reduceTransparency,
          reduceMotion: settings.reduceMotion,
          useGoogleFonts: widget.useGoogleFonts,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: FlutterQuillLocalizations.supportedLocales,
        builder: (context, child) =>
            BiometricLockGate(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
