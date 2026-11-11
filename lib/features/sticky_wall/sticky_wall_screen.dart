import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design_system.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';

class StickyWallScreen extends ConsumerStatefulWidget {
  const StickyWallScreen({super.key});

  @override
  ConsumerState<StickyWallScreen> createState() => _StickyWallScreenState();
}

class _StickyWallScreenState extends ConsumerState<StickyWallScreen> {
  final _transformController = TransformationController();
  static const double _canvasSize = 1800;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _addSticky() async {
    final stickies = ref.read(stickyItemsStreamProvider).value ?? const [];
    final maxZ = stickies.fold<int>(
      0,
      (acc, e) => (e.stickyZ ?? 0) > acc ? (e.stickyZ ?? 0) : acc,
    );
    final offset = (stickies.length % 6) * 34.0;
    final swatch =
        LumiStickyColor.values[stickies.length % LumiStickyColor.values.length];

    final created = await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.sticky,
          title: 'Sticky Note',
          initialPlainText: 'Tap to edit...',
          colorValue: swatch.colorValue,
          stickyX: 48 + offset,
          stickyY: 56 + offset,
          stickyW: 184,
          stickyH: 184,
          stickyZ: maxZ + 1,
        );

    if (mounted) {
      await _editStickyDialog(created);
    }
  }

  Future<void> _editStickyDialog(Item sticky) async {
    final result = await showDialog<_StickyDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.40),
      builder: (_) => _EditStickyDialog(sticky: sticky),
    );

    if (result != null) {
      final repo = ref.read(itemsRepositoryProvider);
      await repo.saveContent(
        id: sticky.id,
        title: result.title,
        bodyDeltaJson: _plainToDelta(result.body),
        autoDeriveTitle: true,
      );
      await repo.updateMetadata(
        id: sticky.id,
        colorValue: Value(result.color.colorValue),
      );
    }
  }

  String _plainToDelta(String text) {
    final normalized = text.endsWith('\n') ? text : '$text\n';
    return '[{"insert":${_jsonEscape(normalized)}}]';
  }

  String _jsonEscape(String s) {
    return '"${s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n')}"';
  }

  @override
  Widget build(BuildContext context) {
    final stickies = ref.watch(stickyItemsStreamProvider).value ?? const [];
    final ext = context.lumiTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LumiSpacing.md,
                LumiSpacing.sm,
                LumiSpacing.md,
                LumiSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sticky Wall',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(width: LumiSpacing.xs),
                  LumiGlassIconButton(
                    icon: Icons.center_focus_weak_rounded,
                    size: 40,
                    tooltip: 'Reset zoom',
                    onTap: () =>
                        _transformController.value = Matrix4.identity(),
                  ),
                  const SizedBox(width: LumiSpacing.xs),
                  LumiGlassChip(
                    label: 'Add Sticky',
                    icon: Icons.add_rounded,
                    selected: true,
                    onTap: _addSticky,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  InteractiveViewer(
                    transformationController: _transformController,
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(200),
                    minScale: 0.55,
                    maxScale: 2.0,
                    child: SizedBox(
                      width: _canvasSize,
                      height: _canvasSize,
                      child: CustomPaint(
                        painter: _DotGridPainter(
                          dotColor: ext.inkMuted.withValues(alpha: 0.16),
                        ),
                        child: Stack(
                          children: stickies.map((sticky) {
                            final maxZ = stickies.fold<int>(
                              1,
                              (acc, e) => (e.stickyZ ?? 0) > acc
                                  ? (e.stickyZ ?? 0)
                                  : acc,
                            );
                            return _StickyCardWidget(
                              key: ValueKey(sticky.id),
                              sticky: sticky,
                              onBringToFront: () => ref
                                  .read(itemsRepositoryProvider)
                                  .updateMetadata(
                                    id: sticky.id,
                                    stickyZ: maxZ + 1,
                                  ),
                              onMoveEnd: (x, y) => ref
                                  .read(itemsRepositoryProvider)
                                  .updateMetadata(
                                    id: sticky.id,
                                    stickyX: x.clamp(8.0, _canvasSize - 160),
                                    stickyY: y.clamp(8.0, _canvasSize - 160),
                                    stickyZ: maxZ + 1,
                                  ),
                              onResizeEnd: (w, h) => ref
                                  .read(itemsRepositoryProvider)
                                  .updateMetadata(
                                    id: sticky.id,
                                    stickyW: w.clamp(140.0, 360.0),
                                    stickyH: h.clamp(130.0, 360.0),
                                  ),
                              onEdit: () => _editStickyDialog(sticky),
                              onTogglePin: () => ref
                                  .read(itemsRepositoryProvider)
                                  .updateMetadata(
                                    id: sticky.id,
                                    pinned: !sticky.pinned,
                                  ),
                              onCycleColor: () {
                                final current = LumiStickyColor.fromColorValue(
                                  sticky.colorValue,
                                );
                                final next =
                                    LumiStickyColor.values[(current.index + 1) %
                                        LumiStickyColor.values.length];
                                ref
                                    .read(itemsRepositoryProvider)
                                    .updateMetadata(
                                      id: sticky.id,
                                      colorValue: Value(next.colorValue),
                                    );
                              },
                              onDelete: () => ref
                                  .read(itemsRepositoryProvider)
                                  .softDelete(sticky.id),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  if (stickies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: LumiEmptyState(
                        icon: Icons.sticky_note_2_outlined,
                        title: 'Your Sticky Wall is clear',
                        subtitle: 'Pin colorful thoughts, drag them anywhere, resize, and organize visually.',
                        actionLabel: 'Add Sticky',
                        onAction: _addSticky,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyCardWidget extends StatefulWidget {
  const _StickyCardWidget({
    super.key,
    required this.sticky,
    required this.onBringToFront,
    required this.onMoveEnd,
    required this.onResizeEnd,
    required this.onEdit,
    required this.onTogglePin,
    required this.onCycleColor,
    required this.onDelete,
  });

  final Item sticky;
  final VoidCallback onBringToFront;
  final void Function(double x, double y) onMoveEnd;
  final void Function(double w, double h) onResizeEnd;
  final VoidCallback onEdit;
  final VoidCallback onTogglePin;
  final VoidCallback onCycleColor;
  final VoidCallback onDelete;

  @override
  State<_StickyCardWidget> createState() => _StickyCardWidgetState();
}

class _StickyCardWidgetState extends State<_StickyCardWidget> {
  late double _x;
  late double _y;
  late double _w;
  late double _h;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant _StickyCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging) {
      _syncFromWidget();
    }
  }

  void _syncFromWidget() {
    _x = widget.sticky.stickyX ?? 32;
    _y = widget.sticky.stickyY ?? 48;
    _w = widget.sticky.stickyW ?? 180;
    _h = widget.sticky.stickyH ?? 180;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final swatch = LumiStickyColor.fromColorValue(widget.sticky.colorValue);
    final fill = swatch.fillFor(brightness);
    final ext = context.lumiTheme;
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: ext.reduceMotion,
    );

    return Positioned(
      left: _x,
      top: _y,
      width: _w,
      height: _h,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() => _dragging = true);
          widget.onBringToFront();
        },
        onPanUpdate: (details) {
          setState(() {
            _x += details.delta.dx;
            _y += details.delta.dy;
          });
        },
        onPanEnd: (_) {
          setState(() => _dragging = false);
          if (LumiDesignScope.maybeOf(context)?.hapticsEnabled ?? true) {
            HapticFeedback.lightImpact();
          }
          widget.onMoveEnd(_x, _y);
        },
        onTap: widget.onEdit,
        child: AnimatedScale(
          scale: _dragging && !reduceMotion ? 1.045 : 1.0,
          duration: reduceMotion ? Duration.zero : LumiMotion.medium,
          curve: LumiMotion.pop,
          child: Container(
            padding: const EdgeInsets.all(LumiSpacing.sm),
            decoration: BoxDecoration(
              color: fill.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(LumiRadius.md),
              border: Border.all(
                color: swatch.accent.withValues(alpha: 0.48),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _dragging ? 0.28 : 0.14,
                  ),
                  blurRadius: _dragging ? 24 : 12,
                  offset: Offset(0, _dragging ? 12 : 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.sticky.title.isEmpty
                                ? 'Sticky'
                                : widget.sticky.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: ext.ink),
                          ),
                        ),
                        Semantics(
                          label: widget.sticky.pinned
                              ? 'Unpin sticky'
                              : 'Pin sticky',
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onTogglePin,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                widget.sticky.pinned
                                    ? Icons.push_pin_rounded
                                    : Icons.push_pin_outlined,
                                size: 16,
                                color: widget.sticky.pinned
                                    ? swatch.accent
                                    : ext.inkMuted,
                              ),
                            ),
                          ),
                        ),
                        Semantics(
                          label: 'Change sticky color',
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onCycleColor,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.palette_outlined,
                                size: 16,
                                color: ext.inkMuted,
                              ),
                            ),
                          ),
                        ),
                        Semantics(
                          label: 'Delete sticky',
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onDelete,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: ext.inkMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        widget.sticky.plainText,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: ext.ink.withValues(alpha: 0.88)),
                      ),
                    ),
                  ],
                ),
                // Bottom-right resize handle
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setState(() {
                        _w = (_w + details.delta.dx).clamp(140.0, 360.0);
                        _h = (_h + details.delta.dy).clamp(130.0, 360.0);
                      });
                    },
                    onPanEnd: (_) => widget.onResizeEnd(_w, _h),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.south_east_rounded,
                        size: 14,
                        color: swatch.accent,
                      ),
                    ),
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

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.dotColor});

  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    const step = 32.0;
    for (double y = step; y < size.height; y += step) {
      for (double x = step; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor;
}

class _StickyDialogResult {
  const _StickyDialogResult({
    required this.title,
    required this.body,
    required this.color,
  });

  final String title;
  final String body;
  final LumiStickyColor color;
}

class _EditStickyDialog extends StatefulWidget {
  const _EditStickyDialog({required this.sticky});

  final Item sticky;

  @override
  State<_EditStickyDialog> createState() => _EditStickyDialogState();
}

class _EditStickyDialogState extends State<_EditStickyDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late LumiStickyColor _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.sticky.title);
    _bodyCtrl = TextEditingController(
      text: widget.sticky.plainText == 'Tap to edit...'
          ? ''
          : widget.sticky.plainText,
    );
    _selectedColor = LumiStickyColor.fromColorValue(widget.sticky.colorValue);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(LumiSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: LumiGlass(
          borderRadius: LumiRadius.lg,
          blur: 28,
          elevated: true,
          padding: const EdgeInsets.all(LumiSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Sticky',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: LumiSpacing.sm),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Heading (optional)',
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: LumiSpacing.xs),
                      TextField(
                        controller: _bodyCtrl,
                        autofocus: true,
                        maxLines: 4,
                        minLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Write a quick thought...',
                        ),
                      ),
                      const SizedBox(height: LumiSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: LumiStickyColor.values.map((swatch) {
                          final active = _selectedColor == swatch;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColor = swatch),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: swatch.fillFor(
                                  Theme.of(context).brightness,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: active
                                      ? swatch.accent
                                      : Colors.white54,
                                  width: active ? 2.5 : 1,
                                ),
                              ),
                              child: active
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: swatch.accent,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: LumiSpacing.lg),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: LumiSpacing.xs,
                runSpacing: LumiSpacing.xs,
                children: [
                  LumiGlassButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  LumiGlassButton(
                    label: 'Save',
                    primary: true,
                    onPressed: () => Navigator.of(context).pop(
                      _StickyDialogResult(
                        title: _titleCtrl.text.trim(),
                        body: _bodyCtrl.text,
                        color: _selectedColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
