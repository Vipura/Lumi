import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design_system.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Item> _results = const [];
  bool _searching = false;
  LumiItemType? _typeFilter;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(
      const Duration(milliseconds: 250),
      () => _runSearch(query),
    );
  }

  Future<void> _runSearch(String query, {bool saveRecent = false}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    if (saveRecent) {
      await ref
          .read(settingsControllerProvider.notifier)
          .addRecentSearch(trimmed);
    }
    final hits = await ref.read(itemsRepositoryProvider).search(trimmed);
    if (!mounted) return;
    setState(() {
      _results = hits;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final ext = context.lumiTheme;
    final filtered = _typeFilter == null
        ? _results
        : _results.where((i) => i.type == _typeFilter!.dbValue).toList();

    return LumiBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Search')),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            LumiSpacing.md,
            0,
            LumiSpacing.md,
            LumiSpacing.md,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LumiGlassSearchField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: _onChanged,
                    onSubmitted: (q) => _runSearch(q, saveRecent: true),
                  ),
                  const SizedBox(height: LumiSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        LumiGlassChip(
                          label: 'All',
                          selected: _typeFilter == null,
                          onTap: () => setState(() => _typeFilter = null),
                        ),
                        const SizedBox(width: LumiSpacing.xs),
                        ...[
                          (LumiItemType.note, 'Notes'),
                          (LumiItemType.checklist, 'Checklists'),
                          (LumiItemType.sticky, 'Stickies'),
                          (LumiItemType.card, 'Cards'),
                        ].map(
                          (pair) => Padding(
                            padding: const EdgeInsets.only(
                              right: LumiSpacing.xs,
                            ),
                            child: LumiGlassChip(
                              label: pair.$2,
                              selected: _typeFilter == pair.$1,
                              onTap: () => setState(
                                () => _typeFilter = _typeFilter == pair.$1
                                    ? null
                                    : pair.$1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: LumiSpacing.md),
                  Expanded(
                    child: _controller.text.trim().isEmpty
                        ? _RecentSearchesView(
                            recents: settings.recentSearches,
                            onSelect: (q) {
                              _controller.text = q;
                              _runSearch(q, saveRecent: true);
                            },
                            onClear: () => ref
                                .read(settingsControllerProvider.notifier)
                                .clearRecentSearches(),
                          )
                        : _searching
                        ? const Center(child: CircularProgressIndicator())
                        : filtered.isEmpty
                        ? const LumiEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No matching items',
                            subtitle: 'Try another keyword across titles, body, checklists, tags, or attachment names.',
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: LumiSpacing.xs),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final isSticky =
                                  item.type == LumiItemType.sticky.dbValue;
                              return LumiGlass.card(
                                onTap: () async {
                                  await ref
                                      .read(settingsControllerProvider.notifier)
                                      .addRecentSearch(_controller.text);
                                  if (!context.mounted) return;
                                  if (isSticky) {
                                    context.go('/wall');
                                  } else {
                                    unawaited(
                                      context.push('/editor/${item.id}'),
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isSticky
                                          ? Icons.sticky_note_2_outlined
                                          : item.type ==
                                                LumiItemType.checklist.dbValue
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.notes_rounded,
                                      color: ext.accentColor,
                                    ),
                                    const SizedBox(width: LumiSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title.isEmpty
                                                ? 'Untitled'
                                                : item.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          if (item.plainText.isNotEmpty)
                                            Text(
                                              item.plainText,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: ext.inkMuted,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

class _RecentSearchesView extends StatelessWidget {
  const _RecentSearchesView({
    required this.recents,
    required this.onSelect,
    required this.onClear,
  });

  final List<String> recents;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    if (recents.isEmpty) {
      return const LumiEmptyState(
        icon: Icons.manage_search_rounded,
        title: 'Search everything locally',
        subtitle: 'Matches titles, rich text, checklist steps, #tags, and attachment filenames instantaneously.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent searches',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: onClear,
              child: Text('Clear', style: TextStyle(color: ext.inkMuted)),
            ),
          ],
        ),
        const SizedBox(height: LumiSpacing.xs),
        Wrap(
          spacing: LumiSpacing.xs,
          runSpacing: LumiSpacing.xs,
          children: recents
              .map(
                (q) => LumiGlassChip(
                  label: q,
                  icon: Icons.history_rounded,
                  onTap: () => onSelect(q),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
