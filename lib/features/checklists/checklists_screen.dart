import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design_system.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import '../notes/widgets/note_summary_card.dart';
import '../templates/templates_sheet.dart';

class ChecklistsScreen extends ConsumerStatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  ConsumerState<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends ConsumerState<ChecklistsScreen> {
  final _searchDummyController = TextEditingController();
  String? _selectedCollectionId;

  @override
  void dispose() {
    _searchDummyController.dispose();
    super.dispose();
  }

  Future<void> _createChecklist() async {
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.checklist,
          title: 'New Checklist',
          collectionId: _selectedCollectionId,
          dueDate: DateTime.now(),
        );
    await ref
        .read(checklistRepositoryProvider)
        .addEntry(itemId: item.id, text: '');
    if (mounted) {
      unawaited(context.push('/editor/${item.id}'));
    }
  }

  Future<void> _showCardActions(LumiItemSummary summary) async {
    final item = summary.item;
    await showLumiGlassBottomSheet<void>(
      context: context,
      title: item.title.isEmpty ? 'Checklist' : item.title,
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
                Text(item.pinned ? 'Unpin checklist' : 'Pin to top'),
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
    final summaries = ref.watch(checklistsSummariesProvider);
    final collections = ref.watch(collectionsStreamProvider).value ?? const [];
    final ext = context.lumiTheme;

    final filtered = summaries.where((s) {
      if (_selectedCollectionId != null &&
          s.item.collectionId != _selectedCollectionId) {
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Checklists',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ),
                        ),
                        const SizedBox(width: LumiSpacing.xs),
                        LumiGlassLensButton(
                          label: 'New',
                          compact: true,
                          icon: Icons.add_rounded,
                          onPressed: _createChecklist,
                        ),
                        const SizedBox(width: LumiSpacing.xs),
                        LumiGlass(
                          borderRadius: LumiRadius.pill,
                          useBlur: false,
                          blur: 0,
                          elevated: true,
                          hasShadow: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LumiGlassIconButton(
                                icon: Icons.auto_awesome_outlined,
                                size: 36,
                                iconSize: 19,
                                useBlur: false,
                                chrome: false,
                                tooltip: 'Checklist templates',
                                onTap: () async {
                                  final id = await showTemplatesSheet(
                                    context,
                                    ref,
                                    LumiItemType.checklist,
                                  );
                                  if (id != null && context.mounted) {
                                    unawaited(context.push('/editor/$id'));
                                  }
                                },
                              ),
                              Container(
                                width: 1,
                                height: 18,
                                color: ext.inkMuted.withValues(alpha: 0.18),
                              ),
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  tooltip: 'More options',
                                  icon: Icon(
                                    Icons.more_horiz_rounded,
                                    size: 20,
                                    color: ext.ink,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'archive') {
                                      context.push('/archive');
                                    }
                                    if (value == 'trash') {
                                      context.push('/trash');
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'archive',
                                      child: Text('Archived'),
                                    ),
                                    PopupMenuItem(
                                      value: 'trash',
                                      child: Text('Trash (30-day restore)'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: LumiSpacing.sm),
                    LumiGlassSearchField(
                      controller: _searchDummyController,
                      hintText: 'Search checklists...',
                      readOnly: true,
                      onTap: () => context.push('/search'),
                    ),
                    const SizedBox(height: LumiSpacing.sm),
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
                        ],
                      ),
                    ),
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
                    icon: Icons.checklist_rounded,
                    title: 'No checklists yet',
                    subtitle: 'Track groceries, routines, and multi-step goals with nested subtasks.',
                    actionLabel: 'Create Checklist',
                    onAction: _createChecklist,
                  ),
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
                    return NoteSummaryCard(
                      summary: s,
                      heroPrefix: 'checklists',
                      onTap: () =>
                          context.push('/editor/${s.item.id}?hero=checklists'),
                      onLongPress: () => _showCardActions(s),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
