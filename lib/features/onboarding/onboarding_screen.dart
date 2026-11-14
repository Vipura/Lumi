import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design_system.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';

/// 3-screen luminous onboarding flow ending in creating the first note.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _firstNoteController = TextEditingController();
  int _page = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNoteController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final settingsCtrl = ref.read(settingsControllerProvider.notifier);
    await settingsCtrl.update(
      (s) => s.copyWith(onboardingCompleted: true, tourCompleted: false),
    );

    final initialText = _firstNoteController.text.trim();
    String? createdId;
    if (initialText.isNotEmpty) {
      final item = await ref
          .read(itemsRepositoryProvider)
          .createItem(
            type: LumiItemType.note,
            initialPlainText: initialText,
            pinned: true,
          );
      createdId = item.id;
    }

    if (!mounted) return;
    if (createdId != null) {
      context.go('/today');
      unawaited(context.push('/editor/$createdId'));
    } else {
      context.go('/today');
    }
  }

  void _next() {
    if (_page < 2) {
      _pageController.animateToPage(
        _page + 1,
        duration: LumiMotion.slow,
        curve: LumiMotion.spring,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final settings = ref.watch(settingsControllerProvider);

    return LumiBackground(
      timeOfDayShift: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(LumiSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            LumiLogo(size: 30),
                            SizedBox(width: LumiSpacing.xs),
                            Text(
                              'Lumi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        LumiGlassButton(
                          label: 'Skip',
                          onPressed: _finishOnboarding,
                        ),
                      ],
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) => setState(() => _page = index),
                        children: [
                          _StepOne(ext: ext),
                          _StepTwo(
                            selectedBg: settings.backgroundTheme,
                            onSelectBg: (bg) {
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .update(
                                    (s) => s.copyWith(backgroundTheme: bg),
                                  );
                            },
                          ),
                          _StepThree(
                            controller: _firstNoteController,
                            onSubmitted: _finishOnboarding,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LumiSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final active = index == _page;
                        return AnimatedContainer(
                          duration: LumiMotion.fast,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? ext.accentColor
                                : ext.inkMuted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(
                              LumiRadius.pill,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: LumiSpacing.lg),
                    LumiGlassButton(
                      label: _page < 2 ? 'Continue' : 'Start with Lumi',
                      primary: true,
                      expanded: true,
                      isLoading: _submitting,
                      icon: _page < 2
                          ? Icons.arrow_forward_rounded
                          : Icons.auto_awesome_rounded,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepOne extends StatelessWidget {
  const _StepOne({required this.ext});

  final LumiThemeExtension ext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const LumiLogo(size: 108)
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.88, 0.88)),
        const SizedBox(height: LumiSpacing.xl),
        Text(
          'Light through glass,\ncalm for your day.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: LumiSpacing.sm),
        Text(
          'Notes, nested checklists, reminders, voice captures, and sticky boards — offline-first and instant.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: ext.inkMuted),
        ),
      ],
    );
  }
}

class _StepTwo extends StatelessWidget {
  const _StepTwo({required this.selectedBg, required this.onSelectBg});

  final LumiBackgroundTheme selectedBg;
  final ValueChanged<LumiBackgroundTheme> onSelectBg;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LumiGlass(
          useBlur: false,
          blur: 0,
          elevated: true,
          padding: const EdgeInsets.all(LumiSpacing.lg),
          child: Column(
            children: [
              Text(
                'Choose your ambient glow',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: LumiSpacing.xs),
              Text(
                'Today shifts gently from sunrise to twilight.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: ext.inkMuted),
              ),
              const SizedBox(height: LumiSpacing.lg),
              Wrap(
                spacing: LumiSpacing.xs,
                runSpacing: LumiSpacing.xs,
                alignment: WrapAlignment.center,
                children: LumiBackgroundTheme.values
                    .map(
                      (theme) => LumiGlassChip(
                        label: theme.label,
                        dotColor: theme.previewColors.first,
                        selected: selectedBg == theme,
                        onTap: () => onSelectBg(theme),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepThree extends StatelessWidget {
  const _StepThree({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Jot your first thought',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: LumiSpacing.xs),
        Text(
          'Capture in under 2 seconds — or skip right to Today.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: ext.inkMuted),
        ),
        const SizedBox(height: LumiSpacing.lg),
        LumiGlass(
          useBlur: false,
          blur: 0,
          elevated: true,
          padding: const EdgeInsets.all(LumiSpacing.md),
          child: TextField(
            controller: controller,
            maxLines: 4,
            minLines: 3,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmitted(),
            decoration: const InputDecoration(
              hintText: 'e.g. Plan weekend trip, pick up fresh coffee, call Maya at 4 PM...',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
