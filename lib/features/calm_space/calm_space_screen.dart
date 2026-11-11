import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/design/design_system.dart';
import '../../core/utils/delta_utils.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import '../settings/backup_export_service.dart';

/// A peaceful, unhurried writing sanctuary for freeform thoughts, journal
/// entries, and stories, with instant one-tap PDF export.
class CalmSpaceScreen extends ConsumerStatefulWidget {
  const CalmSpaceScreen({super.key, this.entryId});

  final String? entryId;

  @override
  ConsumerState<CalmSpaceScreen> createState() => _CalmSpaceScreenState();
}

class _CalmSpaceScreenState extends ConsumerState<CalmSpaceScreen> {
  Future<void> _createEntry({String? initialTitle, String? promptBody}) async {
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.calm,
          title: initialTitle ?? '',
          initialPlainText: promptBody,
        );
    if (mounted) {
      unawaited(context.push('/calm/${item.id}'));
    }
  }

  Future<void> _exportPdf(Item item) async {
    try {
      final exported = await ref
          .read(backupExportServiceProvider)
          .exportNotePdf(item);
      if (exported && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported Calm Space entry as PDF.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entryId != null) {
      return _CalmComposerView(entryId: widget.entryId!);
    }

    final ext = context.lumiTheme;
    final entries = ref.watch(calmFeedStreamProvider).value ?? const [];

    return LumiBackground(
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
                onTap: () => context.pop(),
              ),
            ),
          ),
          title: const Text('Calm Space'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: LumiSpacing.sm),
              child: LumiGlassLensButton(
                label: 'Write',
                icon: Icons.edit_rounded,
                onPressed: () => _createEntry(),
              ),
            ),
          ],
        ),
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
                constraints: const BoxConstraints(maxWidth: 780),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LumiGlass.card(
                      tintColor: ext.accentColor,
                      padding: const EdgeInsets.all(LumiSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.spa_rounded,
                                color: ext.accentColor,
                                size: 24,
                              ),
                              const SizedBox(width: LumiSpacing.xs),
                              Expanded(
                                child: Text(
                                  'A quiet place for your mind',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: LumiSpacing.xs),
                          Text(
                            'Write freeform thoughts, late-night stories, or reflections without checklists or clutter. Export any piece as a clean PDF.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: ext.inkMuted),
                          ),
                          const SizedBox(height: LumiSpacing.md),
                          Wrap(
                            spacing: LumiSpacing.xs,
                            runSpacing: LumiSpacing.xs,
                            children: [
                              LumiGlassChip(
                                label: 'Blank page',
                                icon: Icons.auto_awesome_outlined,
                                selected: true,
                                onTap: () => _createEntry(),
                              ),
                              LumiGlassChip(
                                label: 'Freeform thought',
                                icon: Icons.bubble_chart_outlined,
                                onTap: () => _createEntry(
                                  initialTitle:
                                      'Thought • ${DateFormat('MMM d').format(DateTime.now())}',
                                ),
                              ),
                              LumiGlassChip(
                                label: 'Short story',
                                icon: Icons.menu_book_rounded,
                                onTap: () => _createEntry(
                                  initialTitle: 'Untitled Story',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LumiSpacing.lg),
                    Text(
                      'Your entries (${entries.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: LumiSpacing.sm),
                    if (entries.isEmpty)
                      LumiGlass.card(
                        padding: const EdgeInsets.all(LumiSpacing.lg),
                        child: Text(
                          'Your Calm Space is open and quiet. Tap Write or pick a starter above whenever inspiration arrives.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: ext.inkMuted),
                        ),
                      )
                    else
                      ...entries.map((item) {
                        final words = DeltaUtils.wordCount(item.plainText);
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: LumiSpacing.sm,
                          ),
                          child: LumiGlass.card(
                            onTap: () => context.push('/calm/${item.id}'),
                            padding: const EdgeInsets.all(LumiSpacing.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title.trim().isEmpty
                                            ? 'Calm Space Entry'
                                            : item.title.trim(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      if (item.plainText.trim().isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item.plainText.trim(),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: ext.inkMuted),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        '${DateFormat('MMM d, h:mm a').format(item.updatedAt)} • $words word${words == 1 ? '' : 's'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: ext.inkMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: ext.accentColor,
                                    size: 20,
                                  ),
                                  tooltip: 'Export PDF',
                                  onPressed: () => unawaited(_exportPdf(item)),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: ext.inkMuted,
                                    size: 20,
                                  ),
                                  tooltip: 'Delete entry',
                                  onPressed: () => ref
                                      .read(itemsRepositoryProvider)
                                      .softDelete(item.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
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

class _CalmComposerView extends ConsumerStatefulWidget {
  const _CalmComposerView({required this.entryId});

  final String entryId;

  @override
  ConsumerState<_CalmComposerView> createState() => _CalmComposerViewState();
}

class _CalmComposerViewState extends ConsumerState<_CalmComposerView> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _wordCountNotifier = ValueNotifier<int>(0);
  final _statusNotifier = ValueNotifier<String>('Saved');

  Timer? _autosaveTimer;
  Timer? _wordTimer;
  bool _loaded = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final item = await ref
        .read(itemsRepositoryProvider)
        .getItem(widget.entryId);
    if (!mounted) return;
    if (item != null) {
      _titleController.text = item.title;
      final plain = item.plainText.isNotEmpty
          ? item.plainText
          : DeltaUtils.plainTextFromDeltaJson(item.body);
      _bodyController.text = plain;
      _wordCountNotifier.value = DeltaUtils.wordCount(plain);
    }
    _titleController.addListener(_onEdited);
    _bodyController.addListener(_onEdited);
    setState(() => _loaded = true);
  }

  void _onEdited() {
    if (!_loaded) return;
    _dirty = true;
    if (_statusNotifier.value != 'Saving...') {
      _statusNotifier.value = 'Saving...';
    }
    _wordTimer?.cancel();
    _wordTimer = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      _wordCountNotifier.value = DeltaUtils.wordCount(_bodyController.text);
    });
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 420), _flush);
  }

  Future<void> _flush() async {
    if (!_dirty) return;
    _dirty = false;
    await ref
        .read(itemsRepositoryProvider)
        .saveContent(
          id: widget.entryId,
          title: _titleController.text,
          bodyDeltaJson: DeltaUtils.deltaJsonFromPlainText(
            _bodyController.text,
          ),
          autoDeriveTitle: true,
        );
    if (mounted) {
      _statusNotifier.value = 'Saved';
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _wordTimer?.cancel();
    if (_dirty) {
      unawaited(
        ref
            .read(itemsRepositoryProvider)
            .saveContent(
              id: widget.entryId,
              title: _titleController.text,
              bodyDeltaJson: DeltaUtils.deltaJsonFromPlainText(
                _bodyController.text,
              ),
              autoDeriveTitle: true,
            ),
      );
    }
    _titleController.dispose();
    _bodyController.dispose();
    _wordCountNotifier.dispose();
    _statusNotifier.dispose();
    super.dispose();
  }

  Future<void> _exportPdf() async {
    await _flush();
    final item = await ref
        .read(itemsRepositoryProvider)
        .getItem(widget.entryId);
    if (item == null) return;
    try {
      final ok = await ref
          .read(backupExportServiceProvider)
          .exportNotePdf(item);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported story/thought as PDF.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return LumiBackground(
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
                  await _flush();
                  if (context.mounted) context.pop();
                },
              ),
            ),
          ),
          title: ValueListenableBuilder<int>(
            valueListenable: _wordCountNotifier,
            builder: (context, words, _) => ValueListenableBuilder<String>(
              valueListenable: _statusNotifier,
              builder: (context, status, _) => Text(
                '$words word${words == 1 ? '' : 's'} • $status',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: LumiSpacing.sm),
              child: LumiGlassButton(
                label: 'Export PDF',
                icon: Icons.picture_as_pdf_outlined,
                primary: true,
                onPressed: _exportPdf,
              ),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Container(
              margin: const EdgeInsets.fromLTRB(
                LumiSpacing.md,
                LumiSpacing.xs,
                LumiSpacing.md,
                LumiSpacing.lg,
              ),
              padding: const EdgeInsets.all(LumiSpacing.lg),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF0C1222) : Colors.white)
                    .withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(LumiRadius.lg),
                border: Border.all(
                  color: ext.glassBorderTopLeft.withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.headlineLarge,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Title your thought or story...',
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(height: LumiSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _bodyController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(height: 1.65),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Let it flow onto the page. Everything stays offline on your device...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
