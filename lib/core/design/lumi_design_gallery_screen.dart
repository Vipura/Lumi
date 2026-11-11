import 'package:flutter/material.dart';

import 'design_system.dart';

/// Hidden developer gallery screen to inspect all Lumi Glass components,
/// background themes, light/dark modes, and accessibility fallbacks.
class LumiDesignGalleryScreen extends StatefulWidget {
  const LumiDesignGalleryScreen({
    super.key,
    this.initialBrightness,
    this.onThemeModeToggle,
  });

  final Brightness? initialBrightness;
  final ValueChanged<Brightness>? onThemeModeToggle;

  @override
  State<LumiDesignGalleryScreen> createState() =>
      _LumiDesignGalleryScreenState();
}

class _LumiDesignGalleryScreenState extends State<LumiDesignGalleryScreen> {
  final _searchController = TextEditingController();
  LumiBackgroundTheme _bgTheme = LumiBackgroundTheme.aurora;
  LumiAccentPreset _accent = LumiAccentPreset.warmAmber;
  bool _dark = true;
  bool _timeShift = false;
  bool _reduceTransparency = false;
  bool _reduceMotion = false;
  double _progress = 0.68;
  bool _lensToggleA = true;
  bool _lensToggleB = false;
  final Set<String> _selectedTags = {'Focus', 'Design'};

  @override
  void initState() {
    super.initState();
    if (widget.initialBrightness != null) {
      _dark = widget.initialBrightness == Brightness.dark;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _dark ? Brightness.dark : Brightness.light;
    final theme = LumiThemes.build(
      brightness: brightness,
      accentColor: _accent.color,
      reduceTransparency: _reduceTransparency,
      reduceMotion: _reduceMotion,
    );

    return Theme(
      data: theme,
      child: LumiDesignScope(
        reduceTransparency: _reduceTransparency,
        reduceMotion: _reduceMotion,
        hapticsEnabled: true,
        backgroundTheme: _bgTheme,
        accentColor: _accent.color,
        child: Builder(
          builder: (scopedContext) {
            final ext = scopedContext.lumiTheme;
            return LumiBackground(
              theme: _bgTheme,
              timeOfDayShift: _timeShift,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Row(
                    children: [
                      LumiLogo(size: 30),
                      SizedBox(width: LumiSpacing.sm),
                      Text('Lumi Design Gallery'),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: LumiSpacing.md),
                      child: LumiGlassIconButton(
                        icon: _dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        tooltip: 'Toggle Light / Dark',
                        onTap: () {
                          setState(() => _dark = !_dark);
                          widget.onThemeModeToggle?.call(
                            _dark ? Brightness.dark : Brightness.light,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                body: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    LumiSpacing.md,
                    LumiSpacing.sm,
                    LumiSpacing.md,
                    120,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _SectionHeader(
                              'Ambient Backgrounds & Accents',
                            ),
                            LumiGlass(
                              padding: const EdgeInsets.all(LumiSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: LumiSpacing.xs,
                                    runSpacing: LumiSpacing.xs,
                                    children: LumiBackgroundTheme.values
                                        .map(
                                          (t) => LumiGlassChip(
                                            label: t.label,
                                            dotColor: t.previewColors.first,
                                            selected: _bgTheme == t,
                                            onTap: () =>
                                                setState(() => _bgTheme = t),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: LumiSpacing.sm),
                                  Wrap(
                                    spacing: LumiSpacing.xs,
                                    runSpacing: LumiSpacing.xs,
                                    children: LumiAccentPreset.values
                                        .map(
                                          (a) => LumiGlassChip(
                                            label: a.label,
                                            dotColor: a.color,
                                            selected: _accent == a,
                                            onTap: () =>
                                                setState(() => _accent = a),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: LumiSpacing.sm),
                                  Wrap(
                                    spacing: LumiSpacing.md,
                                    children: [
                                      _TogglePill(
                                        label: 'Time-of-day shift',
                                        value: _timeShift,
                                        onChanged: (v) =>
                                            setState(() => _timeShift = v),
                                      ),
                                      _TogglePill(
                                        label: 'Reduce transparency',
                                        value: _reduceTransparency,
                                        onChanged: (v) => setState(
                                          () => _reduceTransparency = v,
                                        ),
                                      ),
                                      _TogglePill(
                                        label: 'Reduce motion',
                                        value: _reduceMotion,
                                        onChanged: (v) =>
                                            setState(() => _reduceMotion = v),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: LumiSpacing.lg),
                            const _SectionHeader('Search & Chips'),
                            LumiGlassSearchField(
                              controller: _searchController,
                              trailing: LumiGlassIconButton(
                                icon: Icons.tune_rounded,
                                size: 36,
                                iconSize: 18,
                                useBlur: false,
                                tooltip: 'Filter options',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(height: LumiSpacing.sm),
                            Wrap(
                              spacing: LumiSpacing.xs,
                              runSpacing: LumiSpacing.xs,
                              children: ['Focus', 'Design', 'Morning', 'Ideas']
                                  .map(
                                    (tag) => LumiGlassChip(
                                      label: tag,
                                      icon: Icons.tag_rounded,
                                      selected: _selectedTags.contains(tag),
                                      onTap: () {
                                        setState(() {
                                          if (_selectedTags.contains(tag)) {
                                            _selectedTags.remove(tag);
                                          } else {
                                            _selectedTags.add(tag);
                                          }
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: LumiSpacing.lg),
                            const _SectionHeader(
                              'LumiGlass Surfaces & Progress',
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: LumiGlass(
                                    padding: const EdgeInsets.all(
                                      LumiSpacing.md,
                                    ),
                                    onTap: () => setState(() {
                                      _progress = _progress >= 1.0
                                          ? 0.25
                                          : _progress + 0.15;
                                    }),
                                    child: Row(
                                      children: [
                                        LumiProgressRing(
                                          progress: _progress,
                                          size: 52,
                                          child: Text(
                                            '${(_progress * 100).round()}%',
                                            style: Theme.of(scopedContext)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                        ),
                                        const SizedBox(width: LumiSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Interactive Glass',
                                                style: Theme.of(scopedContext)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              Text(
                                                'Tap for press-scale & progress',
                                                style: Theme.of(scopedContext)
                                                    .textTheme
                                                    .bodySmall,
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
                            const SizedBox(height: LumiSpacing.sm),
                            LumiGlass(
                              elevated: true,
                              tintColor: ext.accentColor,
                              padding: const EdgeInsets.all(LumiSpacing.md),
                              child: Row(
                                children: [
                                  const LumiLogo(size: 48),
                                  const SizedBox(width: LumiSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Elevated Tinted Surface',
                                          style: Theme.of(scopedContext)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          'Optical lens caustics • inner bevel halo • crisp contrast',
                                          style: Theme.of(scopedContext)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: LumiSpacing.sm),
                            LumiGlass.card(
                              child: Text(
                                'Lightweight list card (LumiGlass.card) skips BackdropFilter so long lists stay crisp at 60/120 fps.',
                                style: Theme.of(scopedContext)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ),
                            const SizedBox(height: LumiSpacing.lg),
                            const _SectionHeader(
                              'Liquid Glass Switches & Lens Controls',
                            ),
                            LumiGlass.card(
                              padding: const EdgeInsets.all(LumiSpacing.md),
                              child: Wrap(
                                spacing: LumiSpacing.lg,
                                runSpacing: LumiSpacing.sm,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LumiGlassSwitch(
                                        value: _lensToggleA,
                                        onChanged: (v) =>
                                            setState(() => _lensToggleA = v),
                                      ),
                                      const SizedBox(width: LumiSpacing.xs),
                                      Text(
                                        _lensToggleA ? 'Glass Active' : 'Muted',
                                        style: Theme.of(scopedContext)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LumiGlassSwitch(
                                        value: _lensToggleB,
                                        activeColor: LumiColors.success,
                                        onChanged: (v) =>
                                            setState(() => _lensToggleB = v),
                                      ),
                                      const SizedBox(width: LumiSpacing.xs),
                                      Text(
                                        'Optic Green',
                                        style: Theme.of(scopedContext)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  LumiGlassLensButton(
                                    label: 'Get started',
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: LumiSpacing.lg),
                            const _SectionHeader('Buttons, Sheets & Dialogs'),
                            Wrap(
                              spacing: LumiSpacing.sm,
                              runSpacing: LumiSpacing.sm,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                LumiGlassButton(
                                  label: 'Open Sheet',
                                  primary: true,
                                  icon: Icons.layers_rounded,
                                  onPressed: () {
                                    showLumiGlassBottomSheet<void>(
                                      context: scopedContext,
                                      title: 'Quick Capture Sheet',
                                      builder: (ctx) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Translucent glass sheet with safe area and drag pill.',
                                            style: Theme.of(ctx)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          const SizedBox(
                                            height: LumiSpacing.md,
                                          ),
                                          LumiGlassButton(
                                            label: 'Got it',
                                            primary: true,
                                            expanded: true,
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                LumiGlassButton(
                                  label: 'Open Dialog',
                                  icon: Icons.auto_awesome_rounded,
                                  onPressed: () {
                                    showLumiConfirmDialog(
                                      context: scopedContext,
                                      title: 'Liquid Glass Dialog',
                                      message: 'High-contrast typography floating smoothly over the ambient canvas.',
                                      confirmLabel: 'Nice',
                                    );
                                  },
                                ),
                                LumiCaptureFab(onTap: () {}),
                              ],
                            ),
                            const SizedBox(height: LumiSpacing.lg),
                            const _SectionHeader('8 Sticky Note Swatches'),
                            Wrap(
                              spacing: LumiSpacing.xs,
                              runSpacing: LumiSpacing.xs,
                              children: LumiStickyColor.values
                                  .map(
                                    (swatch) => Container(
                                      width: 78,
                                      padding: const EdgeInsets.all(
                                        LumiSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: swatch.fillFor(brightness),
                                        borderRadius: BorderRadius.circular(
                                          LumiRadius.sm,
                                        ),
                                        border: Border.all(
                                          color: swatch.accent.withValues(
                                            alpha: 0.45,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        swatch.label,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(scopedContext)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: ext.ink,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LumiSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return LumiGlassChip(
      label: label,
      icon: value ? Icons.check_circle_rounded : Icons.circle_outlined,
      selected: value,
      onTap: () => onChanged(!value),
    );
  }
}
