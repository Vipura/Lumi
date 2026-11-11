import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design_system.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/providers.dart';
import '../reminders/reminder_picker_sheet.dart';

/// Nested, reorderable checklist widget with satisfying check-off motion,
/// progress ring, per-item reminder attachment, and rollover to tomorrow.
class ChecklistSection extends ConsumerStatefulWidget {
  const ChecklistSection({
    super.key,
    required this.itemId,
    required this.itemTitle,
    this.compact = false,
  });

  final String itemId;
  final String itemTitle;
  final bool compact;

  @override
  ConsumerState<ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends ConsumerState<ChecklistSection> {
  final _newItemController = TextEditingController();
  final _newItemFocus = FocusNode();

  @override
  void dispose() {
    _newItemController.dispose();
    _newItemFocus.dispose();
    super.dispose();
  }

  Future<void> _addEntry({String? parentId}) async {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;
    _newItemController.clear();
    await ref
        .read(checklistRepositoryProvider)
        .addEntry(itemId: widget.itemId, text: text, parentId: parentId);
    _newItemFocus.requestFocus();
  }

  Future<void> _moveUnfinishedToTomorrow(List<ChecklistEntry> entries) async {
    final unfinished = entries.where((e) => !e.done).toList();
    if (unfinished.isEmpty) return;
    final itemsRepo = ref.read(itemsRepositoryProvider);
    final checklistRepo = ref.read(checklistRepositoryProvider);

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9, 0);

    await itemsRepo.updateMetadata(id: widget.itemId, dueDate: Value(tomorrow));
    await checklistRepo.rolloverUnfinishedTasks(
      fromDate: now,
      toDate: tomorrow,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Moved ${unfinished.length} unfinished item${unfinished.length == 1 ? '' : 's'} to tomorrow',
          ),
        ),
      );
    }
  }

  List<ChecklistEntry> _flattenOrdered(List<ChecklistEntry> raw) {
    final parents = raw.where((e) => e.parentId == null).toList();
    final childrenByParent = <String, List<ChecklistEntry>>{};
    for (final e in raw) {
      if (e.parentId != null) {
        childrenByParent.putIfAbsent(e.parentId!, () => []).add(e);
      }
    }
    final result = <ChecklistEntry>[];
    for (final parent in parents) {
      result.add(parent);
      result.addAll(childrenByParent[parent.id] ?? const []);
    }
    // Include any orphaned children gracefully.
    final addedIds = result.map((e) => e.id).toSet();
    for (final e in raw) {
      if (!addedIds.contains(e.id)) result.add(e);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final entriesAsync = ref.watch(itemChecklistStreamProvider(widget.itemId));
    final entries = entriesAsync.value ?? const <ChecklistEntry>[];
    final ordered = _flattenOrdered(entries);
    final doneCount = entries.where((e) => e.done).length;
    final progress = entries.isEmpty ? 0.0 : doneCount / entries.length;
    final hasUnfinished = entries.any((e) => !e.done);

    return LumiGlass.card(
      padding: const EdgeInsets.all(LumiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LumiProgressRing(
                progress: progress,
                size: 36,
                strokeWidth: 3.5,
                child: Text(
                  entries.isEmpty ? '0' : '$doneCount',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(width: LumiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Checklist',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$doneCount of ${entries.length} completed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (hasUnfinished)
                TextButton.icon(
                  onPressed: () => _moveUnfinishedToTomorrow(entries),
                  icon: const Icon(Icons.redo_rounded, size: 16),
                  label: const Text('Tomorrow'),
                ),
            ],
          ),
          const SizedBox(height: LumiSpacing.sm),
          if (ordered.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: ordered.length,
              onReorderItem: (oldIndex, newIndex) {
                final list = List<ChecklistEntry>.from(ordered);
                final moved = list.removeAt(oldIndex);
                list.insert(newIndex, moved);
                if (LumiDesignScope.maybeOf(context)?.hapticsEnabled ?? true) {
                  unawaited(HapticFeedback.selectionClick());
                }
                unawaited(
                  ref
                      .read(checklistRepositoryProvider)
                      .reorderEntries(list.map((e) => e.id).toList()),
                );
              },
              itemBuilder: (context, index) {
                final entry = ordered[index];
                final isChild = entry.parentId != null;
                final previousParent =
                    index > 0 && ordered[index - 1].parentId == null
                    ? ordered[index - 1].id
                    : (index > 0 ? ordered[index - 1].parentId : null);

                return _ChecklistRow(
                  key: ValueKey(entry.id),
                  index: index,
                  entry: entry,
                  isChild: isChild,
                  canIndent: !isChild && previousParent != null,
                  onToggle: (done) async {
                    if (LumiDesignScope.maybeOf(context)?.hapticsEnabled ??
                        true) {
                      if (done) {
                        unawaited(HapticFeedback.mediumImpact());
                      } else {
                        unawaited(HapticFeedback.lightImpact());
                      }
                    }
                    await ref
                        .read(checklistRepositoryProvider)
                        .toggleEntry(entry.id, done);
                  },
                  onChanged: (text) => ref
                      .read(checklistRepositoryProvider)
                      .updateEntryText(entry.id, text),
                  onToggleIndent: () async {
                    final targetParent = isChild ? null : previousParent;
                    await ref
                        .read(databaseProvider)
                        .checklistDao
                        .upsertEntry(
                          entry
                              .toCompanion(true)
                              .copyWith(parentId: Value(targetParent)),
                        );
                  },
                  onRemind: () => showReminderPickerSheet(
                    context: context,
                    ref: ref,
                    itemId: widget.itemId,
                    itemTitle: widget.itemTitle,
                    entryId: entry.id,
                    entryLabel: entry.entryText.isEmpty
                        ? 'Checklist item'
                        : entry.entryText,
                  ),
                  onDelete: () => ref
                      .read(checklistRepositoryProvider)
                      .deleteEntry(entry.id),
                );
              },
            ),
          const SizedBox(height: LumiSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 20,
                color: ext.accentColor,
              ),
              const SizedBox(width: LumiSpacing.xs),
              Expanded(
                child: TextField(
                  controller: _newItemController,
                  focusNode: _newItemFocus,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addEntry(),
                  decoration: const InputDecoration(
                    hintText: 'Add task item...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  size: 18,
                  color: ext.accentColor,
                ),
                tooltip: 'Add step',
                onPressed: _addEntry,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatefulWidget {
  const _ChecklistRow({
    super.key,
    required this.index,
    required this.entry,
    required this.isChild,
    required this.canIndent,
    required this.onToggle,
    required this.onChanged,
    required this.onToggleIndent,
    required this.onRemind,
    required this.onDelete,
  });

  final int index;
  final ChecklistEntry entry;
  final bool isChild;
  final bool canIndent;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleIndent;
  final VoidCallback onRemind;
  final VoidCallback onDelete;

  @override
  State<_ChecklistRow> createState() => _ChecklistRowState();
}

class _ChecklistRowState extends State<_ChecklistRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.entryText);
  }

  @override
  void didUpdateWidget(covariant _ChecklistRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.entryText != widget.entry.entryText &&
        _controller.text != widget.entry.entryText) {
      _controller.text = widget.entry.entryText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final done = widget.entry.done;

    return Padding(
      padding: EdgeInsets.only(
        left: widget.isChild ? LumiSpacing.lg : 0,
        top: 2,
        bottom: 2,
      ),
      child: Row(
        children: [
          if (widget.isChild)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: 16,
                color: ext.inkMuted,
              ),
            ),
          GestureDetector(
            onTap: () => widget.onToggle(!done),
            child: AnimatedScale(
              scale: done ? 1.06 : 1.0,
              duration: LumiMotion.fast,
              curve: LumiMotion.pop,
              child: AnimatedContainer(
                duration: LumiMotion.fast,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? ext.accentColor : Colors.transparent,
                  border: Border.all(
                    color: done
                        ? ext.accentColor
                        : ext.inkMuted.withValues(alpha: 0.48),
                    width: 1.8,
                  ),
                ),
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: LumiSpacing.sm),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              maxLines: null,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: done ? TextDecoration.lineThrough : null,
                color: done ? ext.inkMuted : ext.ink,
              ),
              decoration: const InputDecoration(
                hintText: 'Checklist item',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
          if (widget.isChild || widget.canIndent)
            IconButton(
              icon: Icon(
                widget.isChild
                    ? Icons.format_indent_decrease_rounded
                    : Icons.format_indent_increase_rounded,
                size: 16,
                color: ext.inkMuted,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: widget.isChild ? 'Outdent' : 'Nest under previous',
              onPressed: widget.onToggleIndent,
            ),
          IconButton(
            icon: Icon(Icons.alarm_add_rounded, size: 16, color: ext.inkMuted),
            visualDensity: VisualDensity.compact,
            tooltip: 'Remind for this step',
            onPressed: widget.onRemind,
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 16, color: ext.inkMuted),
            visualDensity: VisualDensity.compact,
            tooltip: 'Remove item',
            onPressed: widget.onDelete,
          ),
          ReorderableDragStartListener(
            index: widget.index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 18,
                color: ext.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
