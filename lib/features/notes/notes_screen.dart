import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design_system.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import '../templates/templates_sheet.dart';
import 'widgets/note_summary_card.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchDummyController = TextEditingController();
  String? _selectedCollectionId;
  String? _selectedTagId;

  @override
  void dispose() {
    _searchDummyController.dispose();
    super.dispose();
  }

  Future<void> _createNote() async {
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.note,
          collectionId: _selectedCollectionId,
        );
    if (mounted) {
      unawaited(context.push('/editor/${item.id}'));
    }
  }

  Future<void> _createCollectionDialog() async {
    final name = await showLumiTextPromptDialog(
      context: context,
      title: 'New Collection',
      hintText: 'e.g. Travel, Reading, Projects',
      confirmLabel: 'Create',
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref
          .read(organizationRepositoryProvider)
          .createCollection(name: name.trim());
    }
  }

  Future<void> _showCardActions(LumiItemSummary summary) async {
    final item = summary.item;
    await showLumiGlassBottomSheet<void>(
      context: context,
      title: item.title.isEmpty ? 'Note' : item.title,
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LumiGlass.card(
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await ref
                  .read(itemsRepositoryProvider)
                  .updateMetadata(id: item.id, pinned: !item.pinned);
            },
            child: Row(
              children: [
                Icon(
                  item.pinned
                      ? Icons.push_pin_outlined
                      : Icons.push_pin_rounded,
                ),
                const SizedBox(width: LumiSpacing.sm),
                Text(item.pinned ? 'Unpin note' : 'Pin to top'),
              ],
            ),
          ),
          const SizedBox(height: LumiSpacing.xs),
          LumiGlass.card(
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await ref
                  .read(itemsRepositoryProvider)
                  .updateMetadata(id: item.id, archived: true);
            },
            child: const Row(
              children: [
                Icon(Icons.archive_outlined),
                SizedBox(width: LumiSpacing.sm),
                Text('Archive'),
              ],
            ),
          ),
          const SizedBox(height: LumiSpacing.xs),
          LumiGlass.card(
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await ref.read(itemsRepositoryProvider).softDelete(item.id);
            },
            child: const Row(
              children: [
                Icon(Icons.delete_outline_rounded, color: LumiColors.danger),
                SizedBox(width: LumiSpacing.sm),
                Text(
                  'Move to Trash',
                  style: TextStyle(color: LumiColors.danger),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final summaries = ref.watch(itemSummariesProvider);
    final collections = ref.watch(collectionsStreamProvider).value ?? const [];
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final ext = context.lumiTheme;
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: settings.reduceMotion,
    );

    final filtered = summaries.where((s) {
      if (_selectedCollectionId != null &&
          s.item.collectionId != _selectedCollectionId) {
        return false;
      }
      if (_selectedTagId != null &&
          !s.tags.any((t) => t.id == _selectedTagId)) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LumiSpacing.md,
                  LumiSpacing.sm,
                  LumiSpacing.md,
                  LumiSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Notes',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                        const SizedBox(width: LumiSpacing.xs),
                        LumiGlassIconButton(
                          icon: settings.notesGridView
                              ? Icons.view_agenda_outlined
                              : Icons.grid_view_rounded,
                          size: 40,
                          tooltip: settings.notesGridView
                              ? 'Switch to list'
                              : 'Switch to grid',
                          onTap: () => ref
                              .read(settingsControllerProvider.notifier)
                              .update(
                                (s) =>
                                    s.copyWith(notesGridView: !s.notesGridView),
                              ),
                        ),
                        const SizedBox(width: LumiSpacing.xs),
                        LumiGlassIconButton(
                          icon: Icons.auto_awesome_outlined,
                          size: 40,
                          tooltip: 'Templates',
                          onTap: () async {
                            final id = await showTemplatesSheet(context, ref);
                            if (id != null && context.mounted) {
                              unawaited(context.push('/editor/$id'));
                            }
                          },
                        ),
                        const SizedBox(width: LumiSpacing.xs),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert_rounded, color: ext.ink),
                          onSelected: (value) {
                            if (value == 'archive') context.push('/archive');
                            if (value == 'trash') context.push('/trash');
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'archive',
                              child: Text('Archived notes'),
                            ),
                            PopupMenuItem(
                              value: 'trash',
                              child: Text('Trash (30-day restore)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: LumiSpacing.sm),
                    LumiGlassSearchField(
                      controller: _searchDummyController,
                      readOnly: true,
                      onTap: () => context.push('/search'),
                    ),
                    const SizedBox(height: LumiSpacing.sm),
                    // Collections bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          LumiGlassChip(
                            label: 'All',
                            selected: _selectedCollectionId == null,
                            onTap: () =>
                                setState(() => _selectedCollectionId = null),
                          ),
                          const SizedBox(width: LumiSpacing.xs),
                          ...collections.map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(
                                right: LumiSpacing.xs,
                              ),
                              child: LumiGlassChip(
                                label: c.name,
                                dotColor: Color(c.colorValue),
                                selected: _selectedCollectionId == c.id,
                                onTap: () => setState(
                                  () => _selectedCollectionId =
                                      _selectedCollectionId == c.id
                                      ? null
                                      : c.id,
                                ),
                              ),
                            ),
                          ),
                          LumiGlassChip(
                            label: 'Collection',
                            icon: Icons.add_rounded,
                            onTap: _createCollectionDialog,
                          ),
                        ],
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: LumiSpacing.xs),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tags
                              .map(
                                (t) => Padding(
                                  padding: const EdgeInsets.only(
                                    right: LumiSpacing.xs,
                                  ),
                                  child: LumiGlassChip(
                                    label: '#${t.name}',
                                    selected: _selectedTagId == t.id,
                                    onTap: () => setState(
                                      () => _selectedTagId =
                                          _selectedTagId == t.id ? null : t.id,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LumiSpacing.md,
                    LumiSpacing.md,
                    LumiSpacing.md,
                    120,
                  ),
                  child: LumiEmptyState(
                    icon: Icons.notes_rounded,
                    title: 'No notes here yet',
                    subtitle: 'Capture a thought, checklist, or start from a template.',
                    actionLabel: 'New Note',
                    onAction: _createNote,
                  ),
                ),
              )
            else if (settings.notesGridView)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  LumiSpacing.md,
                  LumiSpacing.xs,
                  LumiSpacing.md,
                  120,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.crossAxisExtent >= 960
                        ? 4
                        : constraints.crossAxisExtent >= 620
                        ? 3
                        : 2;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: LumiSpacing.sm,
                        crossAxisSpacing: LumiSpacing.sm,
                        childAspectRatio: 0.98,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final s = filtered[index];
                        final card = NoteSummaryCard(
                          summary: s,
                          compact: true,
                          heroPrefix: 'item',
                          onTap: () =>
                              context.push('/editor/${s.item.id}?hero=notes'),
                          onLongPress: () => _showCardActions(s),
                        );
                        return reduceMotion
                            ? card
                            : card
                                  .animate()
                                  .fadeIn(
                                    duration: 220.ms,
                                    delay: (index.clamp(0, 8) * 25).ms,
                                  )
                                  .slideY(begin: 0.04, end: 0);
                      }, childCount: filtered.length),
                    );
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  LumiSpacing.md,
                  LumiSpacing.xs,
                  LumiSpacing.md,
                  120,
                ),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: LumiSpacing.sm),
                  itemBuilder: (context, index) {
                    final s = filtered[index];
                    final card = NoteSummaryCard(
                      summary: s,
                      heroPrefix: 'item',
                      onTap: () =>
                          context.push('/editor/${s.item.id}?hero=notes'),
                      onLongPress: () => _showCardActions(s),
                    );
                    return reduceMotion
                        ? card
                        : card
                              .animate()
                              .fadeIn(
                                duration: 220.ms,
                                delay: (index.clamp(0, 8) * 25).ms,
                              )
                              .slideY(begin: 0.03, end: 0);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
