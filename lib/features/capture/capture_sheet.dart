import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design/design_system.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import '../attachments/attachment_service.dart';
import '../attachments/voice_recorder_sheet.dart';
import '../reminders/reminder_picker_sheet.dart';
import '../templates/templates_sheet.dart';

/// Opens the signature Liquid Glass Capture bottom sheet from the center "+" button.
Future<void> showLumiCaptureSheet(BuildContext context, WidgetRef ref) {
  return showLumiGlassBottomSheet<void>(
    context: context,
    title: 'Quick Capture',
    builder: (sheetCtx) => _CaptureSheetBody(parentContext: context),
  );
}

class _CaptureSheetBody extends ConsumerStatefulWidget {
  const _CaptureSheetBody({required this.parentContext});

  final BuildContext parentContext;

  @override
  ConsumerState<_CaptureSheetBody> createState() => _CaptureSheetBodyState();
}

class _CaptureSheetBodyState extends ConsumerState<_CaptureSheetBody> {
  final _quickController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _quickController.dispose();
    super.dispose();
  }

  Future<void> _submitQuickNote() async {
    final text = _quickController.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(type: LumiItemType.note, initialPlainText: text);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text('Saved "${item.title}"'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              if (widget.parentContext.mounted) {
                widget.parentContext.push('/editor/${item.id}');
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _captureNote() async {
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(type: LumiItemType.note);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      unawaited(widget.parentContext.push('/editor/${item.id}'));
    }
  }

  Future<void> _captureChecklist() async {
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.checklist,
          title: 'New Checklist',
          dueDate: DateTime.now(),
        );
    await ref
        .read(checklistRepositoryProvider)
        .addEntry(itemId: item.id, text: '');
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      unawaited(widget.parentContext.push('/editor/${item.id}'));
    }
  }

  Future<void> _captureSticky() async {
    final existing = ref.read(stickyItemsStreamProvider).value ?? const [];
    final offset = (existing.length % 5) * 28.0;
    final swatch =
        LumiStickyColor.values[existing.length % LumiStickyColor.values.length];
    await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.sticky,
          title: 'Quick Sticky',
          initialPlainText: _quickController.text.trim().isNotEmpty
              ? _quickController.text.trim()
              : 'Tap to jot a bright note',
          colorValue: swatch.colorValue,
          stickyX: 32 + offset,
          stickyY: 48 + offset,
          stickyW: 180,
          stickyH: 180,
          stickyZ: existing.length + 1,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      widget.parentContext.go('/wall');
    }
  }

  Future<void> _captureVoice() async {
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(type: LumiItemType.note, title: 'Voice Note');
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      await showVoiceRecorderSheet(
        context: widget.parentContext,
        ref: ref,
        itemId: item.id,
      );
      if (widget.parentContext.mounted) {
        unawaited(widget.parentContext.push('/editor/${item.id}'));
      }
    }
  }

  Future<void> _capturePhoto() async {
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(type: LumiItemType.note, title: 'Photo Note');
    final attachment = await ref
        .read(attachmentServiceProvider)
        .pickAndAttachImage(itemId: item.id, source: ImageSource.gallery);
    if (attachment == null) {
      await ref.read(itemsRepositoryProvider).permanentlyDelete(item.id);
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      unawaited(widget.parentContext.push('/editor/${item.id}'));
    }
  }

  Future<void> _captureReminder() async {
    final noteTitle = _quickController.text.trim().isNotEmpty
        ? _quickController.text.trim()
        : 'Reminder';
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.note,
          title: noteTitle,
          dueDate: DateTime.now(),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      await showReminderPickerSheet(
        context: widget.parentContext,
        ref: ref,
        itemId: item.id,
        itemTitle: noteTitle,
      );
    }
  }

  Future<void> _openTemplates() async {
    Navigator.of(context).pop();
    if (!widget.parentContext.mounted) return;
    final createdId = await showTemplatesSheet(widget.parentContext, ref);
    if (createdId != null && widget.parentContext.mounted) {
      unawaited(widget.parentContext.push('/editor/$createdId'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final actions = [
      _CaptureTileData(
        label: 'Note',
        icon: Icons.edit_note_rounded,
        color: ext.accentColor,
        onTap: _captureNote,
      ),
      _CaptureTileData(
        label: 'Checklist',
        icon: Icons.check_circle_outline_rounded,
        color: LumiColors.success,
        onTap: _captureChecklist,
      ),
      _CaptureTileData(
        label: 'Sticky',
        icon: Icons.sticky_note_2_rounded,
        color: LumiStickyColor.butter.accent,
        onTap: _captureSticky,
      ),
      _CaptureTileData(
        label: 'Voice',
        icon: Icons.mic_rounded,
        color: LumiStickyColor.lavender.accent,
        onTap: _captureVoice,
      ),
      _CaptureTileData(
        label: 'Photo',
        icon: Icons.photo_camera_back_rounded,
        color: LumiColors.info,
        onTap: _capturePhoto,
      ),
      _CaptureTileData(
        label: 'Reminder',
        icon: Icons.notifications_active_rounded,
        color: LumiStickyColor.rose.accent,
        onTap: _captureReminder,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instant 2-second quick note bar
          LumiGlass.card(
            padding: const EdgeInsets.symmetric(
              horizontal: LumiSpacing.sm,
              vertical: LumiSpacing.xxs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quickController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitQuickNote(),
                    decoration: const InputDecoration(
                      hintText: 'Instant thought... press Enter to save',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                    color: ext.accentColor,
                  ),
                  tooltip: 'Save quick note',
                  onPressed: _submitQuickNote,
                ),
              ],
            ),
          ),
          const SizedBox(height: LumiSpacing.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: LumiSpacing.sm,
            crossAxisSpacing: LumiSpacing.sm,
            childAspectRatio: 1.04,
            children: actions.map((action) {
              return LumiGlass.card(
                onTap: action.onTap,
                semanticLabel: 'Capture ${action.label}',
                padding: const EdgeInsets.all(LumiSpacing.sm),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: action.color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(action.icon, color: action.color, size: 22),
                    ),
                    const SizedBox(height: LumiSpacing.xs),
                    Flexible(
                      child: Text(
                        action.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: LumiSpacing.sm),
          LumiGlassButton(
            label: 'Use a template',
            icon: Icons.auto_awesome_outlined,
            expanded: true,
            onPressed: _openTemplates,
          ),
        ],
      ),
    );
  }
}

class _CaptureTileData {
  const _CaptureTileData({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
