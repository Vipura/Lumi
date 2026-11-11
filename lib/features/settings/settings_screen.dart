import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/design/design_system.dart';
import '../../data/repositories/providers.dart';
import 'backup_export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);
    final ext = context.lumiTheme;

    return LumiBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            LumiSpacing.md,
            LumiSpacing.xs,
            LumiSpacing.md,
            LumiSpacing.xl,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionTitle('Appearance'),
                    LumiGlass.card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme mode',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: LumiSpacing.xs),
                          Wrap(
                            spacing: LumiSpacing.xs,
                            children:
                                [
                                  (ThemeMode.system, 'System'),
                                  (ThemeMode.light, 'Light'),
                                  (ThemeMode.dark, 'Dark'),
                                ].map((pair) {
                                  return LumiGlassChip(
                                    label: pair.$2,
                                    selected: settings.themeMode == pair.$1,
                                    onTap: () => ctrl.update(
                                      (s) => s.copyWith(themeMode: pair.$1),
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: LumiSpacing.md),
                          Text(
                            'Ambient background',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: LumiSpacing.xs),
                          Wrap(
                            spacing: LumiSpacing.xs,
                            runSpacing: LumiSpacing.xs,
                            children: LumiBackgroundTheme.values
                                .map(
                                  (t) => LumiGlassChip(
                                    label: t.label,
                                    dotColor: t.previewColors.first,
                                    selected: settings.backgroundTheme == t,
                                    onTap: () => ctrl.update(
                                      (s) => s.copyWith(backgroundTheme: t),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: LumiSpacing.md),
                          Text(
                            'Accent glow',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: LumiSpacing.xs),
                          Wrap(
                            spacing: LumiSpacing.xs,
                            runSpacing: LumiSpacing.xs,
                            children: LumiAccentPreset.values
                                .map(
                                  (a) => LumiGlassChip(
                                    label: a.label,
                                    dotColor: a.color,
                                    selected: settings.accentPreset == a,
                                    onTap: () => ctrl.update(
                                      (s) => s.copyWith(accentPreset: a),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LumiSpacing.lg),
                    const _SectionTitle('Accessibility & Feel'),
                    LumiGlass.card(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          LumiGlassSwitchTile(
                            title: const Text('Reduce transparency'),
                            subtitle: const Text(
                              'Use solid tinted surfaces instead of live blur',
                            ),
                            value: settings.reduceTransparency,
                            onChanged: (v) => ctrl.update(
                              (s) => s.copyWith(reduceTransparency: v),
                            ),
                          ),
                          const Divider(height: 1),
                          LumiGlassSwitchTile(
                            title: const Text('Reduce motion'),
                            subtitle: const Text(
                              'Calm background drift and transitions',
                            ),
                            value: settings.reduceMotion,
                            onChanged: (v) =>
                                ctrl.update((s) => s.copyWith(reduceMotion: v)),
                          ),
                          const Divider(height: 1),
                          LumiGlassSwitchTile(
                            title: const Text('Haptic feedback'),
                            subtitle: const Text(
                              'Gentle taps on checklist and glass actions',
                            ),
                            value: settings.hapticsEnabled,
                            onChanged: (v) => ctrl.update(
                              (s) => s.copyWith(hapticsEnabled: v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LumiSpacing.lg),
                    const _SectionTitle('Privacy & Organization'),
                    LumiGlass.card(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          LumiGlassSwitchTile(
                            title: const Text('Biometric lock'),
                            subtitle: Text(
                              (kIsWeb ||
                                      defaultTargetPlatform ==
                                          TargetPlatform.linux)
                                  ? 'Available on Android, iOS, macOS, and Windows devices'
                                  : 'Require Face ID, Touch ID, Windows Hello, or device lock',
                            ),
                            value: settings.biometricLockEnabled,
                            onChanged: (v) async {
                              if (kIsWeb ||
                                  defaultTargetPlatform ==
                                      TargetPlatform.linux) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Device lock is supported on Android, iOS, macOS, and Windows.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (v) {
                                var supported = false;
                                try {
                                  supported = await LocalAuthentication()
                                      .isDeviceSupported();
                                } catch (_) {
                                  supported = false;
                                }
                                if (!supported && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Biometric/passcode hardware unavailable on this device.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                              }
                              await ctrl.update(
                                (s) => s.copyWith(biometricLockEnabled: v),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.archive_outlined),
                            title: const Text('Archived notes'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => context.push('/archive'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.delete_outline_rounded),
                            title: const Text('Trash (30-day restore)'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => context.push('/trash'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LumiSpacing.lg),
                    const _SectionTitle('Local Backup & Restore'),
                    LumiGlass.card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Everything stays offline on your device. Export a full .zip archive containing all notes, checklists, tags, reminders, and attachments.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: ext.inkMuted),
                          ),
                          const SizedBox(height: LumiSpacing.md),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final stackVert = constraints.maxWidth < 360;
                              final exportBtn = LumiGlassButton(
                                label: 'Export Backup (.zip)',
                                primary: true,
                                expanded: stackVert,
                                icon: Icons.download_rounded,
                                onPressed: () async {
                                  try {
                                    final count = await ref
                                        .read(backupExportServiceProvider)
                                        .exportFullBackupZip();
                                    if (context.mounted && count != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Exported $count items to backup archive.',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Export failed: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                              final restoreBtn = LumiGlassButton(
                                label: 'Restore (.zip)',
                                expanded: stackVert,
                                icon: Icons.upload_rounded,
                                onPressed: () async {
                                  try {
                                    final restored = await ref
                                        .read(backupExportServiceProvider)
                                        .restoreBackupFromPicker();
                                    if (context.mounted && restored > 0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Restored $restored items from backup.',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Restore failed: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                              if (stackVert) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    exportBtn,
                                    const SizedBox(height: LumiSpacing.xs),
                                    restoreBtn,
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: exportBtn),
                                  const SizedBox(width: LumiSpacing.xs),
                                  Expanded(child: restoreBtn),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LumiSpacing.lg),
                    const _SectionTitle('About & Preview'),
                    LumiGlass.card(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const LumiLogo(size: 28),
                            title: const Text('Lumi Design Gallery'),
                            subtitle: const Text(
                              'Inspect glass surfaces, themes, and tokens',
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => context.push('/design-gallery'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.explore_outlined),
                            title: const Text('Replay interactive tour'),
                            subtitle: const Text(
                              'Walk through Today, Notes, Checklists, Reminders & Plan',
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () async {
                              await ctrl.update(
                                (s) => s.copyWith(tourCompleted: false),
                              );
                              if (context.mounted) context.go('/today');
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.replay_rounded),
                            title: const Text('Replay onboarding'),
                            onTap: () => context.go('/onboarding'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LumiSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
