import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design_system.dart';
import '../../data/repositories/providers.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(archivedItemsStreamProvider).value ?? const [];

    return LumiBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Archive')),
        body: items.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(LumiSpacing.md),
                child: LumiEmptyState(
                  icon: Icons.archive_outlined,
                  title: 'Nothing archived',
                  subtitle: 'Archived notes stay neatly tucked out of sight.',
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(LumiSpacing.md),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: LumiSpacing.sm),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return LumiGlass.card(
                    onTap: () => context.push('/editor/${item.id}'),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title.isEmpty
                                    ? 'Untitled note'
                                    : item.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (item.plainText.isNotEmpty)
                                Text(
                                  item.plainText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        LumiGlassIconButton(
                          icon: Icons.unarchive_rounded,
                          size: 34,
                          iconSize: 18,
                          tooltip: 'Unarchive',
                          onTap: () => ref
                              .read(itemsRepositoryProvider)
                              .updateMetadata(id: item.id, archived: false),
                        ),
                        const SizedBox(width: 4),
                        LumiGlassIconButton(
                          icon: Icons.delete_outline_rounded,
                          iconColor: LumiColors.danger,
                          size: 34,
                          iconSize: 18,
                          tooltip: 'Move to Trash',
                          onTap: () => ref
                              .read(itemsRepositoryProvider)
                              .softDelete(item.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(trashItemsStreamProvider).value ?? const [];

    return LumiBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Trash'),
          actions: [
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: LumiGlassButton(
                  label: 'Empty',
                  tintColor: LumiColors.danger,
                  onPressed: () async {
                    final ok = await showLumiConfirmDialog(
                      context: context,
                      title: 'Empty Trash?',
                      message:
                          'Permanently delete ${items.length} trashed item(s)? This cannot be undone.',
                      confirmLabel: 'Delete All',
                      destructive: true,
                    );
                    if (!ok) return;
                    final repo = ref.read(itemsRepositoryProvider);
                    for (final item in items) {
                      await repo.permanentlyDelete(item.id);
                    }
                  },
                ),
              ),
          ],
        ),
        body: items.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(LumiSpacing.md),
                child: LumiEmptyState(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Trash is empty',
                  subtitle: 'Deleted items stay recoverable here for 30 days.',
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(LumiSpacing.md),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: LumiSpacing.sm),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final elapsed = item.deletedAt == null
                      ? 0
                      : DateTime.now().difference(item.deletedAt!).inDays;
                  final daysLeft = (30 - elapsed).clamp(0, 30);

                  return LumiGlass.card(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title.isEmpty
                                    ? 'Untitled item'
                                    : item.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '$daysLeft day${daysLeft == 1 ? '' : 's'} left to restore',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        LumiGlassIconButton(
                          icon: Icons.restore_from_trash_rounded,
                          size: 34,
                          iconSize: 18,
                          tooltip: 'Restore',
                          onTap: () => ref
                              .read(itemsRepositoryProvider)
                              .restore(item.id),
                        ),
                        const SizedBox(width: 4),
                        LumiGlassIconButton(
                          icon: Icons.delete_forever_rounded,
                          iconColor: LumiColors.danger,
                          size: 34,
                          iconSize: 18,
                          tooltip: 'Delete forever',
                          onTap: () => ref
                              .read(itemsRepositoryProvider)
                              .permanentlyDelete(item.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
