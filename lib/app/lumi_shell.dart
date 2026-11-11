import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/design_system.dart';
import '../data/repositories/providers.dart';
import '../features/capture/capture_sheet.dart';
import '../features/onboarding/lumi_tour_overlay.dart';

class _ShellTabSpec {
  const _ShellTabSpec({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _shellTabs = <_ShellTabSpec>[
  _ShellTabSpec(
    index: 0,
    icon: Icons.wb_sunny_outlined,
    activeIcon: Icons.wb_sunny_rounded,
    label: 'Today',
  ),
  _ShellTabSpec(
    index: 1,
    icon: Icons.notes_outlined,
    activeIcon: Icons.notes_rounded,
    label: 'Notes',
  ),
  _ShellTabSpec(
    index: 2,
    icon: Icons.checklist_outlined,
    activeIcon: Icons.checklist_rounded,
    label: 'Checklists',
  ),
  _ShellTabSpec(
    index: 3,
    icon: Icons.alarm_outlined,
    activeIcon: Icons.alarm_rounded,
    label: 'Reminders',
  ),
  _ShellTabSpec(
    index: 4,
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today_rounded,
    label: 'Plan',
  ),
  _ShellTabSpec(
    index: 5,
    icon: Icons.sticky_note_2_outlined,
    activeIcon: Icons.sticky_note_2_rounded,
    label: 'Wall',
  ),
];

class LumiShell extends ConsumerWidget {
  const LumiShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelectTab(int index, {bool resetIfSame = true}) {
    navigationShell.goBranch(
      index,
      initialLocation: resetIfSame && index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final isWide = MediaQuery.sizeOf(context).width >= 840;
    final tourDone = ref.watch(
      settingsControllerProvider.select((s) => s.tourCompleted),
    );

    final mainContent = isWide
        ? Row(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LumiSpacing.md,
                    LumiSpacing.md,
                    0,
                    LumiSpacing.md,
                  ),
                  child: _DesktopGlassRail(
                    currentIndex: currentIndex,
                    onSelect: _onSelectTab,
                    onCapture: () => showLumiCaptureSheet(context, ref),
                  ),
                ),
              ),
              Expanded(child: navigationShell),
            ],
          )
        : navigationShell;

    return LumiBackground(
      timeOfDayShift: currentIndex == 0,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            body: mainContent,
            bottomNavigationBar: isWide
                ? null
                : SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        LumiSpacing.sm,
                        0,
                        LumiSpacing.sm,
                        LumiSpacing.sm,
                      ),
                      child: _MobileFloatingGlassBar(
                        currentIndex: currentIndex,
                        onSelect: _onSelectTab,
                        onCapture: () => showLumiCaptureSheet(context, ref),
                      ),
                    ),
                  ),
          ),
          if (!tourDone)
            LumiTourOverlay(
              onSelectBranch: (idx) => _onSelectTab(idx, resetIfSame: false),
              onFinish: () => ref
                  .read(settingsControllerProvider.notifier)
                  .update((s) => s.copyWith(tourCompleted: true)),
            ),
        ],
      ),
    );
  }
}

class _MobileFloatingGlassBar extends StatelessWidget {
  const _MobileFloatingGlassBar({
    required this.currentIndex,
    required this.onSelect,
    required this.onCapture,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Row(
          children: [
            Expanded(
              child: LumiGlass(
                borderRadius: LumiRadius.pill,
                blur: 8,
                elevated: true,
                grouped: false,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: _shellTabs
                      .map(
                        (tab) => Expanded(
                          child: _TabItem(
                            icon: tab.icon,
                            activeIcon: tab.activeIcon,
                            label: tab.label,
                            compact: true,
                            selected: currentIndex == tab.index,
                            onTap: () => onSelect(tab.index),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: LumiSpacing.xs),
            LumiCaptureFab(size: 50, onTap: onCapture),
          ],
        ),
      ),
    );
  }
}

class _DesktopGlassRail extends StatelessWidget {
  const _DesktopGlassRail({
    required this.currentIndex,
    required this.onSelect,
    required this.onCapture,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return LumiGlass(
      width: 96,
      borderRadius: LumiRadius.xl,
      blur: 8,
      elevated: true,
      grouped: false,
      padding: const EdgeInsets.symmetric(
        vertical: LumiSpacing.md,
        horizontal: LumiSpacing.xs,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LumiLogo(size: 36),
            const SizedBox(height: LumiSpacing.md),
            LumiCaptureFab(size: 50, onTap: onCapture),
            const SizedBox(height: LumiSpacing.lg),
            for (var i = 0; i < _shellTabs.length; i++) ...[
              _TabItem(
                icon: _shellTabs[i].icon,
                activeIcon: _shellTabs[i].activeIcon,
                label: _shellTabs[i].label,
                selected: currentIndex == _shellTabs[i].index,
                onTap: () => onSelect(_shellTabs[i].index),
              ),
              if (i < _shellTabs.length - 1)
                const SizedBox(height: LumiSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scope = LumiDesignScope.maybeOf(context);
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? ext.reduceMotion,
    );
    final color = selected ? ext.accentColor : ext.inkMuted;
    final lensFill = selected
        ? Color.lerp(
            ext.accentColor,
            Colors.white,
            isDark ? 0.12 : 0.28,
          )!.withValues(alpha: isDark ? 0.20 : 0.28)
        : Colors.transparent;
    final lensBorder = selected
        ? Colors.white.withValues(alpha: isDark ? 0.26 : 0.72)
        : Colors.transparent;

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : LumiMotion.fast,
          curve: LumiMotion.spring,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 4 : 10,
            vertical: compact ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: lensFill,
            borderRadius: BorderRadius.circular(LumiRadius.pill),
            border: selected ? Border.all(color: lensBorder, width: 0.9) : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  color: color,
                  size: compact ? 20 : 22,
                ),
                SizedBox(height: compact ? 1 : 2),
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: compact ? 10 : 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
