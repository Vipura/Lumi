import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/design_system.dart';
import '../features/capture/capture_sheet.dart';

class LumiShell extends ConsumerWidget {
  const LumiShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelectTab(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    return LumiBackground(
      timeOfDayShift: currentIndex == 0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: isWide
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
            : navigationShell,
        bottomNavigationBar: isWide
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LumiSpacing.md,
                    0,
                    LumiSpacing.md,
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
        constraints: const BoxConstraints(maxWidth: 480),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LumiGlass(
                borderRadius: LumiRadius.pill,
                blur: 18,
                elevated: true,
                grouped: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: LumiSpacing.xs,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: _TabItem(
                        icon: Icons.wb_sunny_outlined,
                        activeIcon: Icons.wb_sunny_rounded,
                        label: 'Today',
                        selected: currentIndex == 0,
                        onTap: () => onSelect(0),
                      ),
                    ),
                    Flexible(
                      child: _TabItem(
                        icon: Icons.notes_outlined,
                        activeIcon: Icons.notes_rounded,
                        label: 'Notes',
                        selected: currentIndex == 1,
                        onTap: () => onSelect(1),
                      ),
                    ),
                    const SizedBox(width: 60),
                    Flexible(
                      child: _TabItem(
                        icon: Icons.calendar_today_outlined,
                        activeIcon: Icons.calendar_today_rounded,
                        label: 'Plan',
                        selected: currentIndex == 2,
                        onTap: () => onSelect(2),
                      ),
                    ),
                    Flexible(
                      child: _TabItem(
                        icon: Icons.sticky_note_2_outlined,
                        activeIcon: Icons.sticky_note_2_rounded,
                        label: 'Wall',
                        selected: currentIndex == 3,
                        onTap: () => onSelect(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(top: 0, child: LumiCaptureFab(onTap: onCapture)),
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
      width: 92,
      borderRadius: LumiRadius.xl,
      blur: 18,
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
            LumiCaptureFab(size: 52, onTap: onCapture),
            const SizedBox(height: LumiSpacing.lg),
            _TabItem(
              icon: Icons.wb_sunny_outlined,
              activeIcon: Icons.wb_sunny_rounded,
              label: 'Today',
              selected: currentIndex == 0,
              onTap: () => onSelect(0),
            ),
            const SizedBox(height: LumiSpacing.sm),
            _TabItem(
              icon: Icons.notes_outlined,
              activeIcon: Icons.notes_rounded,
              label: 'Notes',
              selected: currentIndex == 1,
              onTap: () => onSelect(1),
            ),
            const SizedBox(height: LumiSpacing.sm),
            _TabItem(
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today_rounded,
              label: 'Plan',
              selected: currentIndex == 2,
              onTap: () => onSelect(2),
            ),
            const SizedBox(height: LumiSpacing.sm),
            _TabItem(
              icon: Icons.sticky_note_2_outlined,
              activeIcon: Icons.sticky_note_2_rounded,
              label: 'Wall',
              selected: currentIndex == 3,
              onTap: () => onSelect(3),
            ),
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
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: lensFill,
            borderRadius: BorderRadius.circular(LumiRadius.pill),
            border: selected ? Border.all(color: lensBorder, width: 0.9) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? activeIcon : icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
