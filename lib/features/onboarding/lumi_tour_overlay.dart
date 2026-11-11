import 'package:flutter/material.dart';

import '../../core/design/design_system.dart';

class _TourStepData {
  const _TourStepData({
    required this.branchIndex,
    required this.title,
    required this.description,
    required this.icon,
  });

  final int branchIndex;
  final String title;
  final String description;
  final IconData icon;
}

const _tourSteps = <_TourStepData>[
  _TourStepData(
    branchIndex: 0,
    title: 'Welcome to Today',
    description: 'See your daily momentum ring, capture an instant thought or task in seconds, and stay grounded without clutter.',
    icon: Icons.wb_sunny_rounded,
  ),
  _TourStepData(
    branchIndex: 0,
    title: 'Calm Space Sanctuary',
    description: 'Find Calm Space right on Today whenever you want to pour out freeform thoughts, journal reflections, or stories — and export as PDF.',
    icon: Icons.spa_rounded,
  ),
  _TourStepData(
    branchIndex: 1,
    title: 'Notes, Voice & Photos',
    description: 'Your rich notes live cleanly in Notes along with voice recordings, photo attachments, templates, and photo-included PDF exports.',
    icon: Icons.notes_rounded,
  ),
  _TourStepData(
    branchIndex: 2,
    title: 'Dedicated Checklists',
    description: 'Checklists now have their own focused tab with nested subtasks, completion rings, and one-tap rollover to tomorrow.',
    icon: Icons.checklist_rounded,
  ),
  _TourStepData(
    branchIndex: 3,
    title: 'Smart Reminders & Alarms',
    description: 'Give reminders custom titles, pick exact dates & times, add early alerts (5 minutes to 1 month before), repeat schedules, and fire alarms.',
    icon: Icons.alarm_on_rounded,
  ),
  _TourStepData(
    branchIndex: 4,
    title: 'Plan & Status Boards',
    description: 'Use the compact Calendar and To Do / Doing / Done boards exclusively for your Plans — notes and reminders never clutter your board.',
    icon: Icons.view_kanban_rounded,
  ),
  _TourStepData(
    branchIndex: 5,
    title: 'Sticky Wall & Quick Capture (+)',
    description: 'Arrange color-tinted stickies freely here, and tap the floating + lens button anywhere to create items or start from a template.',
    icon: Icons.sticky_note_2_rounded,
  ),
];

/// Interactive multi-step walkthrough rendered inside [LumiShell] so new users
/// explore each live workspace tab directly.
class LumiTourOverlay extends StatefulWidget {
  const LumiTourOverlay({
    super.key,
    required this.onSelectBranch,
    required this.onFinish,
  });

  final ValueChanged<int> onSelectBranch;
  final VoidCallback onFinish;

  @override
  State<LumiTourOverlay> createState() => _LumiTourOverlayState();
}

class _LumiTourOverlayState extends State<LumiTourOverlay> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onSelectBranch(_tourSteps[_step].branchIndex);
      }
    });
  }

  void _goToStep(int index) {
    setState(() => _step = index);
    widget.onSelectBranch(_tourSteps[index].branchIndex);
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final current = _tourSteps[_step];
    final isLast = _step == _tourSteps.length - 1;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.36),
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                LumiSpacing.md,
                LumiSpacing.md,
                LumiSpacing.md,
                84,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 460,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.72,
                ),
                child: LumiGlass(
                  borderRadius: LumiRadius.xl,
                  blur: 8,
                  elevated: true,
                  tintColor: ext.accentColor,
                  padding: const EdgeInsets.all(LumiSpacing.lg),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ext.accentColor.withValues(alpha: 0.18),
                              ),
                              child: Icon(
                                current.icon,
                                color: ext.accentColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: LumiSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quick Tour • ${_step + 1} of ${_tourSteps.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: ext.accentColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  Text(
                                    current.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: widget.onFinish,
                              child: Text(
                                'Skip',
                                style: TextStyle(color: ext.inkMuted),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: LumiSpacing.sm),
                        Text(
                          current.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: LumiSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: List.generate(_tourSteps.length, (i) {
                                  final active = i == _step;
                                  return Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    width: active ? 18 : 6,
                                    height: 6,
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
                            ),
                            if (_step > 0) ...[
                              TextButton(
                                onPressed: () => _goToStep(_step - 1),
                                child: const Text('Back'),
                              ),
                              const SizedBox(width: LumiSpacing.xs),
                            ],
                            LumiGlassButton(
                              label: isLast ? 'Finish Tour' : 'Next',
                              primary: true,
                              icon: isLast
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              onPressed: isLast
                                  ? widget.onFinish
                                  : () => _goToStep(_step + 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
