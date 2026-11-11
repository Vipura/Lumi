import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/design/design_system.dart';
import '../../core/utils/delta_utils.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/items_repository.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import '../attachments/attachments_panel.dart';
import '../checklist/checklist_section.dart';
import '../reminders/notification_service.dart';
import '../reminders/reminder_picker_sheet.dart';
import '../settings/backup_export_service.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.itemId, this.heroPrefix});

  final String itemId;
  final String? heroPrefix;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _editorFocusNode = FocusNode();
  final _editorScrollController = ScrollController();
  final _wordCountNotifier = ValueNotifier<int>(0);
  final _savedLabelNotifier = ValueNotifier<String>('Saved');

  late final ItemsRepository _itemsRepo;
  QuillController? _quillController;
  StreamSubscription<DocChange>? _docSub;
  Timer? _autosaveTimer;

  bool _loaded = false;
  bool _dirty = false;
  bool _showChecklist = false;
  bool _titleEditedManually = false;

  @override
  void initState() {
    super.initState();
    _itemsRepo = ref.read(itemsRepositoryProvider);
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final item = await ref.read(itemsRepositoryProvider).getItem(widget.itemId);
    final entries = await ref
        .read(checklistRepositoryProvider)
        .getEntries(widget.itemId);
    if (!mounted) return;
    if (item == null) {
      setState(() => _loaded = true);
      return;
    }

    _titleController.text = item.title;
    _titleEditedManually =
        item.title.trim().isNotEmpty &&
        item.title.trim() != 'Untitled note' &&
        item.title.trim() != 'New Checklist';

    final doc = _parseDocument(item.body);
    final controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _wordCountNotifier.value = DeltaUtils.wordCount(doc.toPlainText());
    _showChecklist =
        item.type == LumiItemType.checklist.dbValue || entries.isNotEmpty;

    _docSub = controller.document.changes.listen((_) {
      _onContentChanged();
    });
    _titleController.addListener(_onTitleChanged);

    setState(() {
      _quillController = controller;
      _loaded = true;
    });
  }

  Document _parseDocument(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List && decoded.isNotEmpty) {
        return Document.fromJson(decoded);
      }
    } catch (_) {}
    return Document();
  }

  void _onTitleChanged() {
    if (!_loaded) return;
    _titleEditedManually = _titleController.text.trim().isNotEmpty;
    _scheduleAutosave();
  }

  void _onContentChanged() {
    if (!_loaded || _quillController == null) return;
    final plain = _quillController!.document.toPlainText();
    final nextCount = DeltaUtils.wordCount(plain);
    if (nextCount != _wordCountNotifier.value) {
      _wordCountNotifier.value = nextCount;
    }
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _dirty = true;
    if (_savedLabelNotifier.value != 'Saving...') {
      _savedLabelNotifier.value = 'Saving...';
    }
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 450), _flushSave);
  }

  Future<void> _flushSave() async {
    if (!_dirty || _quillController == null) return;
    _dirty = false;
    final bodyJson = jsonEncode(_quillController!.document.toDelta().toJson());
    await _itemsRepo.saveContent(
      id: widget.itemId,
      title: _titleEditedManually ? _titleController.text : '',
      bodyDeltaJson: bodyJson,
      autoDeriveTitle: true,
    );
    if (mounted) {
      _savedLabelNotifier.value = 'Saved';
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    if (_dirty && _quillController != null) {
      final bodyJson = jsonEncode(
        _quillController!.document.toDelta().toJson(),
      );
      // Fire-and-forget flush via cached repository so edits right before pop never vanish.
      unawaited(
        _itemsRepo.saveContent(
          id: widget.itemId,
          title: _titleEditedManually ? _titleController.text : '',
          bodyDeltaJson: bodyJson,
          autoDeriveTitle: true,
        ),
      );
    }
    _docSub?.cancel();
    _titleController.dispose();
    _quillController?.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _wordCountNotifier.dispose();
    _savedLabelNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickTag(Item item) async {
    final name = await showLumiTextPromptDialog(
      context: context,
      title: 'Add Tag',
      hintText: 'e.g. design, urgent, ideas',
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref
          .read(organizationRepositoryProvider)
          .addTagToItem(itemId: item.id, tagName: name);
    }
  }

  Future<void> _pickColorAndCollection(
    Item item,
    List<Collection> collections,
  ) async {
    await showLumiGlassBottomSheet<void>(
      context: context,
      title: 'Organize & Tint',
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Collection', style: Theme.of(sheetCtx).textTheme.labelLarge),
          const SizedBox(height: LumiSpacing.xs),
          Wrap(
            spacing: LumiSpacing.xs,
            runSpacing: LumiSpacing.xs,
            children: [
              LumiGlassChip(
                label: 'None',
                selected: item.collectionId == null,
                onTap: () async {
                  await ref
                      .read(itemsRepositoryProvider)
                      .updateMetadata(
                        id: item.id,
                        collectionId: const Value(null),
                      );
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                },
              ),
              ...collections.map(
                (col) => LumiGlassChip(
                  label: col.name,
                  dotColor: Color(col.colorValue),
                  selected: item.collectionId == col.id,
                  onTap: () async {
                    await ref
                        .read(itemsRepositoryProvider)
                        .updateMetadata(
                          id: item.id,
                          collectionId: Value(col.id),
                        );
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: LumiSpacing.md),
          Text('Color Label', style: Theme.of(sheetCtx).textTheme.labelLarge),
          const SizedBox(height: LumiSpacing.xs),
          Wrap(
            spacing: LumiSpacing.xs,
            runSpacing: LumiSpacing.xs,
            children: [
              LumiGlassChip(
                label: 'Default',
                selected: item.colorValue == null,
                onTap: () async {
                  await ref
                      .read(itemsRepositoryProvider)
                      .updateMetadata(
                        id: item.id,
                        colorValue: const Value(null),
                      );
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                },
              ),
              ...LumiStickyColor.values.map(
                (swatch) => LumiGlassChip(
                  label: swatch.label,
                  dotColor: swatch.accent,
                  selected: item.colorValue == swatch.colorValue,
                  onTap: () async {
                    await ref
                        .read(itemsRepositoryProvider)
                        .updateMetadata(
                          id: item.id,
                          colorValue: Value(swatch.colorValue),
                        );
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: LumiSpacing.md),
          Text('Board Status', style: Theme.of(sheetCtx).textTheme.labelLarge),
          const SizedBox(height: LumiSpacing.xs),
          Wrap(
            spacing: LumiSpacing.xs,
            children: LumiBoardStatus.values
                .map(
                  (status) => LumiGlassChip(
                    label: status.label,
                    selected: item.boardStatus == status.dbValue,
                    onTap: () async {
                      await ref
                          .read(itemsRepositoryProvider)
                          .updateMetadata(id: item.id, boardStatus: status);
                      if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDueDate(Item item) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: item.dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;
    await ref
        .read(itemsRepositoryProvider)
        .updateMetadata(id: item.id, dueDate: Value(picked));
  }

  Future<void> _showMoreMenu(Item item) async {
    await showLumiGlassBottomSheet<void>(
      context: context,
      title: 'Note Actions',
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionRow(
            icon: _showChecklist
                ? Icons.checklist_rtl_rounded
                : Icons.add_task_rounded,
            label: _showChecklist
                ? 'Hide checklist block'
                : 'Add checklist block',
            onTap: () {
              Navigator.of(sheetCtx).pop();
              setState(() => _showChecklist = !_showChecklist);
            },
          ),
          _ActionRow(
            icon: Icons.description_outlined,
            label: 'Export as Markdown (.md)',
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await _flushSave();
              final latest = await ref
                  .read(itemsRepositoryProvider)
                  .getItem(widget.itemId);
              if (latest != null) {
                try {
                  final exported = await ref
                      .read(backupExportServiceProvider)
                      .exportNoteMarkdown(latest);
                  if (exported && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exported note as Markdown.'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Markdown export failed: $e')),
                    );
                  }
                }
              }
            },
          ),
          _ActionRow(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Export as PDF (.pdf)',
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await _flushSave();
              final latest = await ref
                  .read(itemsRepositoryProvider)
                  .getItem(widget.itemId);
              if (latest != null) {
                try {
                  final exported = await ref
                      .read(backupExportServiceProvider)
                      .exportNotePdf(latest);
                  if (exported && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exported note as PDF.')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF export failed: $e')),
                    );
                  }
                }
              }
            },
          ),
          _ActionRow(
            icon: item.archived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined,
            label: item.archived ? 'Unarchive' : 'Archive note',
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await ref
                  .read(itemsRepositoryProvider)
                  .updateMetadata(id: item.id, archived: !item.archived);
              if (mounted) context.pop();
            },
          ),
          _ActionRow(
            icon: Icons.delete_outline_rounded,
            label: 'Move to Trash',
            destructive: true,
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await ref.read(itemsRepositoryProvider).softDelete(item.id);
              if (mounted) context.pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(itemStreamProvider(widget.itemId)).value;
    final tags =
        ref.watch(itemTagsStreamProvider(widget.itemId)).value ?? const [];
    final reminders =
        ref.watch(itemRemindersStreamProvider(widget.itemId)).value ?? const [];
    final collections = ref.watch(collectionsStreamProvider).value ?? const [];
    final ext = context.lumiTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_loaded) {
      return const LumiBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (item == null || _quillController == null) {
      return LumiBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(),
          body: const LumiEmptyState(
            icon: Icons.note_outlined,
            title: 'Note not found',
            subtitle: 'This note may have been deleted.',
          ),
        ),
      );
    }

    final activeReminders = reminders
        .where((r) => r.status == 'scheduled' || r.status == 'snoozed')
        .toList();
    final tintColor = item.colorValue != null ? Color(item.colorValue!) : null;
    // Clean, calm, distraction-free surface for reading/writing body text.
    final canvasSurface = isDark
        ? Color.alphaBlend(
            (tintColor ?? Colors.transparent).withValues(alpha: 0.08),
            const Color(0xFF0C1222).withValues(alpha: 0.88),
          )
        : Color.alphaBlend(
            (tintColor ?? Colors.transparent).withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.88),
          );

    final canvasBox = Container(
      margin: const EdgeInsets.fromLTRB(
        LumiSpacing.md,
        LumiSpacing.xs,
        LumiSpacing.md,
        0,
      ),
      decoration: BoxDecoration(
        color: canvasSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(LumiRadius.lg),
        ),
        border: Border.all(
          color: ext.glassBorderTopLeft.withValues(alpha: 0.4),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(LumiSpacing.lg),
        children: [
          // Metadata & Tag strip
          Wrap(
            spacing: LumiSpacing.xs,
            runSpacing: LumiSpacing.xs,
            children: [
              if (item.collectionId != null)
                ...collections
                    .where((c) => c.id == item.collectionId)
                    .map(
                      (c) => LumiGlassChip(
                        label: c.name,
                        dotColor: Color(c.colorValue),
                        onTap: () => _pickColorAndCollection(item, collections),
                      ),
                    ),
              LumiGlassChip(
                label: item.dueDate != null
                    ? DateFormat('MMM d').format(item.dueDate!)
                    : 'Add date',
                icon: Icons.event_outlined,
                selected: item.dueDate != null,
                onTap: () => _pickDueDate(item),
                onDelete: item.dueDate != null
                    ? () => ref
                          .read(itemsRepositoryProvider)
                          .updateMetadata(
                            id: item.id,
                            dueDate: const Value(null),
                          )
                    : null,
              ),
              LumiGlassChip(
                label: activeReminders.isEmpty
                    ? 'Remind me'
                    : DateFormat('MMM d, h:mm a')
                          .format(activeReminders.first.fireAt),
                icon: Icons.notifications_none_rounded,
                selected: activeReminders.isNotEmpty,
                onTap: () => showReminderPickerSheet(
                  context: context,
                  ref: ref,
                  itemId: item.id,
                  itemTitle: _titleController.text.isNotEmpty
                      ? _titleController.text
                      : item.title,
                ),
                onDelete: activeReminders.isNotEmpty
                    ? () async {
                        final rem = activeReminders.first;
                        await ref
                            .read(remindersRepositoryProvider)
                            .cancelReminder(rem.id);
                        await ref
                            .read(notificationServiceProvider)
                            .cancelReminder(rem.notificationId);
                      }
                    : null,
              ),
              ...tags.map(
                (tag) => LumiGlassChip(
                  label: '#${tag.name}',
                  onDelete: () => ref
                      .read(organizationRepositoryProvider)
                      .removeTagFromItem(item.id, tag.id),
                ),
              ),
              LumiGlassChip(
                label: 'Tag',
                icon: Icons.add_rounded,
                onTap: () => _pickTag(item),
              ),
            ],
          ),
          const SizedBox(height: LumiSpacing.md),
          // Title field with clean display typography
          TextField(
            controller: _titleController,
            style: Theme.of(context).textTheme.headlineLarge,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: LumiSpacing.xs),
          // Clean rich-text Quill editor (no blur behind text)
          QuillEditor(
            controller: _quillController!,
            focusNode: _editorFocusNode,
            scrollController: _editorScrollController,
            config: const QuillEditorConfig(
              placeholder: 'Start writing...',
              scrollable: false,
              expands: false,
              padding: EdgeInsets.symmetric(vertical: 8),
              minHeight: 140,
            ),
          ),
          if (_showChecklist) ...[
            const SizedBox(height: LumiSpacing.md),
            ChecklistSection(
              itemId: item.id,
              itemTitle: _titleController.text.isNotEmpty
                  ? _titleController.text
                  : item.title,
            ),
          ],
          const SizedBox(height: LumiSpacing.lg),
          AttachmentsPanel(itemId: item.id),
          const SizedBox(height: LumiSpacing.xl),
        ],
      ),
    );

    return LumiBackground(
      child: BackdropGroup(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: LumiSpacing.xs),
              child: Center(
                child: LumiGlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  size: 40,
                  iconSize: 18,
                  tooltip: 'Back',
                  onTap: () async {
                    await _flushSave();
                    if (context.mounted) context.pop();
                  },
                ),
              ),
            ),
            title: ValueListenableBuilder<int>(
              valueListenable: _wordCountNotifier,
              builder: (context, words, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: _savedLabelNotifier,
                  builder: (context, savedLabel, _) {
                    return Text(
                      '$words word${words == 1 ? '' : 's'} • $savedLabel',
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                );
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: LumiSpacing.sm),
                child: LumiGlass(
                  borderRadius: LumiRadius.pill,
                  blur: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LumiGlassIconButton(
                        icon: item.pinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        size: 36,
                        iconSize: 19,
                        useBlur: false,
                        chrome: false,
                        tintColor: item.pinned ? ext.accentColor : null,
                        iconColor: item.pinned ? ext.accentColor : null,
                        tooltip: item.pinned ? 'Unpin' : 'Pin note',
                        onTap: () => ref
                            .read(itemsRepositoryProvider)
                            .updateMetadata(id: item.id, pinned: !item.pinned),
                      ),
                      Container(
                        width: 1,
                        height: 18,
                        color: ext.inkMuted.withValues(alpha: 0.18),
                      ),
                      LumiGlassIconButton(
                        icon: Icons.palette_outlined,
                        size: 36,
                        iconSize: 19,
                        useBlur: false,
                        chrome: false,
                        tooltip: 'Organize & color',
                        onTap: () => _pickColorAndCollection(item, collections),
                      ),
                      Container(
                        width: 1,
                        height: 18,
                        color: ext.inkMuted.withValues(alpha: 0.18),
                      ),
                      LumiGlassIconButton(
                        icon: Icons.more_horiz_rounded,
                        size: 36,
                        iconSize: 20,
                        useBlur: false,
                        chrome: false,
                        tooltip: 'More options',
                        onTap: () => _showMoreMenu(item),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: widget.heroPrefix != null
                        ? Hero(
                            tag: 'lumi_${widget.heroPrefix}_${item.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: canvasBox,
                            ),
                          )
                        : canvasBox,
                  ),
                ),
              ),
              // Floating / keyboard-docked Liquid Glass Quill toolbar
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LumiSpacing.md,
                    LumiSpacing.xs,
                    LumiSpacing.md,
                    LumiSpacing.xs,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: LumiGlass(
                      borderRadius: LumiRadius.pill,
                      blur: 16,
                      elevated: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: LumiSpacing.xs,
                        vertical: 2,
                      ),
                      child: QuillSimpleToolbar(
                        controller: _quillController!,
                        config: const QuillSimpleToolbarConfig(
                          multiRowsDisplay: false,
                          decoration: BoxDecoration(color: Colors.transparent),
                          showFontFamily: false,
                          showFontSize: false,
                          showColorButton: false,
                          showBackgroundColorButton: false,
                          showSearchButton: false,
                          showSubscript: false,
                          showSuperscript: false,
                          showDirection: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? LumiColors.danger : context.lumiTheme.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: LumiSpacing.xs),
      child: LumiGlass.card(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: LumiSpacing.md,
          vertical: LumiSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: LumiSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
