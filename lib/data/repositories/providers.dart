import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/lumi_database.dart';
import 'attachments_repository.dart';
import 'checklist_repository.dart';
import 'items_repository.dart';
import 'lumi_models.dart';
import 'organization_repository.dart';
import 'reminders_repository.dart';
import 'settings_repository.dart';

/// Initialized in `main.dart` and overridden in `ProviderScope`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden'),
);

final databaseProvider = Provider<LumiDatabase>((ref) {
  final db = LumiDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

class SettingsController extends Notifier<LumiUserSettings> {
  @override
  LumiUserSettings build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  Future<void> update(
    LumiUserSettings Function(LumiUserSettings) transform,
  ) async {
    final next = transform(state);
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final updated = [
      trimmed,
      ...state.recentSearches.where(
        (q) => q.toLowerCase() != trimmed.toLowerCase(),
      ),
    ].take(8).toList();
    await update((s) => s.copyWith(recentSearches: updated));
  }

  Future<void> clearRecentSearches() async {
    await update((s) => s.copyWith(recentSearches: const []));
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, LumiUserSettings>(
      SettingsController.new,
    );

// Repository providers
final itemsRepositoryProvider = Provider<ItemsRepository>(
  (ref) => DriftItemsRepository(ref.watch(databaseProvider)),
);

final checklistRepositoryProvider = Provider<ChecklistRepository>(
  (ref) => DriftChecklistRepository(ref.watch(databaseProvider)),
);

final remindersRepositoryProvider = Provider<RemindersRepository>(
  (ref) => DriftRemindersRepository(ref.watch(databaseProvider)),
);

final attachmentsRepositoryProvider = Provider<AttachmentsRepository>(
  (ref) => DriftAttachmentsRepository(ref.watch(databaseProvider)),
);

final organizationRepositoryProvider = Provider<OrganizationRepository>(
  (ref) => DriftOrganizationRepository(ref.watch(databaseProvider)),
);

// Live streams
final collectionsStreamProvider = StreamProvider<List<Collection>>(
  (ref) => ref.watch(organizationRepositoryProvider).watchCollections(),
);

final tagsStreamProvider = StreamProvider<List<Tag>>(
  (ref) => ref.watch(organizationRepositoryProvider).watchTags(),
);

final allItemTagsStreamProvider = StreamProvider<List<ItemTag>>(
  (ref) => ref.watch(organizationRepositoryProvider).watchAllItemTags(),
);

final allChecklistEntriesStreamProvider = StreamProvider<List<ChecklistEntry>>(
  (ref) => ref.watch(checklistRepositoryProvider).watchAllActiveEntries(),
);

final allAttachmentsStreamProvider = StreamProvider<List<Attachment>>(
  (ref) => ref.watch(attachmentsRepositoryProvider).watchAll(),
);

final scheduledRemindersStreamProvider = StreamProvider<List<Reminder>>(
  (ref) => ref.watch(remindersRepositoryProvider).watchScheduledReminders(),
);

final allRemindersStreamProvider = StreamProvider<List<Reminder>>(
  (ref) =>
      ref.watch(remindersRepositoryProvider).watchAllNonCancelledReminders(),
);

final pinnedItemsStreamProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemsRepositoryProvider).watchPinnedItems(),
);

final stickyItemsStreamProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemsRepositoryProvider).watchStickyItems(),
);

final boardItemsStreamProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemsRepositoryProvider).watchBoardItems(),
);

final archivedItemsStreamProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemsRepositoryProvider).watchArchivedItems(),
);

final trashItemsStreamProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemsRepositoryProvider).watchTrashItems(),
);

final notesFeedStreamProvider = StreamProvider<List<Item>>((ref) {
  return ref
      .watch(itemsRepositoryProvider)
      .watchActiveItems(type: LumiItemType.note);
});

final checklistsFeedStreamProvider = StreamProvider<List<Item>>((ref) {
  return ref
      .watch(itemsRepositoryProvider)
      .watchActiveItems(type: LumiItemType.checklist);
});

final plansFeedStreamProvider = StreamProvider<List<Item>>((ref) {
  return ref
      .watch(itemsRepositoryProvider)
      .watchActiveItems(type: LumiItemType.card);
});

final calmFeedStreamProvider = StreamProvider<List<Item>>((ref) {
  return ref
      .watch(itemsRepositoryProvider)
      .watchActiveItems(type: LumiItemType.calm);
});

final allActiveItemsStreamProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemsRepositoryProvider).watchActiveItems();
});

final itemStreamProvider = StreamProvider.family<Item?, String>(
  (ref, id) => ref.watch(itemsRepositoryProvider).watchItem(id),
);

final itemChecklistStreamProvider =
    StreamProvider.family<List<ChecklistEntry>, String>(
      (ref, itemId) =>
          ref.watch(checklistRepositoryProvider).watchEntries(itemId),
    );

final itemAttachmentsStreamProvider =
    StreamProvider.family<List<Attachment>, String>(
      (ref, itemId) =>
          ref.watch(attachmentsRepositoryProvider).watchForItem(itemId),
    );

final itemRemindersStreamProvider =
    StreamProvider.family<List<Reminder>, String>(
      (ref, itemId) =>
          ref.watch(remindersRepositoryProvider).watchRemindersForItem(itemId),
    );

final itemTagsStreamProvider = StreamProvider.family<List<Tag>, String>(
  (ref, itemId) =>
      ref.watch(organizationRepositoryProvider).watchTagsForItem(itemId),
);

/// Strict summary list containing ONLY Notes (`LumiItemType.note`).
final notesSummariesProvider = Provider<List<LumiItemSummary>>((ref) {
  final items = ref.watch(notesFeedStreamProvider).value ?? const [];
  final collections = ref.watch(collectionsStreamProvider).value ?? const [];
  final tags = ref.watch(tagsStreamProvider).value ?? const [];
  final itemTags = ref.watch(allItemTagsStreamProvider).value ?? const [];
  final attachments = ref.watch(allAttachmentsStreamProvider).value ?? const [];
  final reminders =
      ref.watch(scheduledRemindersStreamProvider).value ?? const [];

  return buildItemSummaries(
    items: items,
    collections: collections,
    tags: tags,
    itemTags: itemTags,
    entries: const [],
    attachments: attachments,
    reminders: reminders,
  );
});

/// Strict summary list containing ONLY Checklists (`LumiItemType.checklist`).
final checklistsSummariesProvider = Provider<List<LumiItemSummary>>((ref) {
  final items = ref.watch(checklistsFeedStreamProvider).value ?? const [];
  final collections = ref.watch(collectionsStreamProvider).value ?? const [];
  final tags = ref.watch(tagsStreamProvider).value ?? const [];
  final itemTags = ref.watch(allItemTagsStreamProvider).value ?? const [];
  final entries =
      ref.watch(allChecklistEntriesStreamProvider).value ?? const [];
  final reminders =
      ref.watch(scheduledRemindersStreamProvider).value ?? const [];

  return buildItemSummaries(
    items: items,
    collections: collections,
    tags: tags,
    itemTags: itemTags,
    entries: entries,
    attachments: const [],
    reminders: reminders,
  );
});

/// Strict summary list containing ONLY Plans (`LumiItemType.card`).
final plansSummariesProvider = Provider<List<LumiItemSummary>>((ref) {
  final items = ref.watch(plansFeedStreamProvider).value ?? const [];
  final collections = ref.watch(collectionsStreamProvider).value ?? const [];
  final tags = ref.watch(tagsStreamProvider).value ?? const [];
  final itemTags = ref.watch(allItemTagsStreamProvider).value ?? const [];
  final entries =
      ref.watch(allChecklistEntriesStreamProvider).value ?? const [];
  final reminders =
      ref.watch(scheduledRemindersStreamProvider).value ?? const [];

  return buildItemSummaries(
    items: items,
    collections: collections,
    tags: tags,
    itemTags: itemTags,
    entries: entries,
    attachments: const [],
    reminders: reminders,
  );
});

/// Cross-type active summary list used by Today overview & item lookups.
final itemSummariesProvider = Provider<List<LumiItemSummary>>((ref) {
  final items = ref.watch(allActiveItemsStreamProvider).value ?? const [];
  final collections = ref.watch(collectionsStreamProvider).value ?? const [];
  final tags = ref.watch(tagsStreamProvider).value ?? const [];
  final itemTags = ref.watch(allItemTagsStreamProvider).value ?? const [];
  final entries =
      ref.watch(allChecklistEntriesStreamProvider).value ?? const [];
  final attachments = ref.watch(allAttachmentsStreamProvider).value ?? const [];
  final reminders =
      ref.watch(scheduledRemindersStreamProvider).value ?? const [];

  return buildItemSummaries(
    items: items,
    collections: collections,
    tags: tags,
    itemTags: itemTags,
    entries: entries,
    attachments: attachments,
    reminders: reminders,
  );
});

List<LumiItemSummary> buildItemSummaries({
  required List<Item> items,
  required List<Collection> collections,
  required List<Tag> tags,
  required List<ItemTag> itemTags,
  required List<ChecklistEntry> entries,
  required List<Attachment> attachments,
  required List<Reminder> reminders,
}) {
  final colById = {for (final c in collections) c.id: c};
  final tagById = {for (final t in tags) t.id: t};

  final tagsByItem = <String, List<Tag>>{};
  for (final link in itemTags) {
    final tag = tagById[link.tagId];
    if (tag != null) {
      tagsByItem.putIfAbsent(link.itemId, () => []).add(tag);
    }
  }

  final entriesByItem = <String, List<ChecklistEntry>>{};
  for (final e in entries) {
    entriesByItem.putIfAbsent(e.itemId, () => []).add(e);
  }

  final attachmentCountByItem = <String, int>{};
  for (final a in attachments) {
    attachmentCountByItem[a.itemId] =
        (attachmentCountByItem[a.itemId] ?? 0) + 1;
  }

  final nextReminderByItem = <String, Reminder>{};
  for (final r in reminders) {
    final prev = nextReminderByItem[r.itemId];
    if (prev == null || r.fireAt.isBefore(prev.fireAt)) {
      nextReminderByItem[r.itemId] = r;
    }
  }

  return items.map((item) {
    final itemEntries = entriesByItem[item.id] ?? const [];
    final doneCount = itemEntries.where((e) => e.done).length;
    return LumiItemSummary(
      item: item,
      tags: tagsByItem[item.id] ?? const [],
      checklistTotal: itemEntries.length,
      checklistDone: doneCount,
      attachmentCount: attachmentCountByItem[item.id] ?? 0,
      nextReminder: nextReminderByItem[item.id],
      collection: item.collectionId != null ? colById[item.collectionId] : null,
    );
  }).toList();
}

/// Today's completed-vs-total progress for the Today progress ring.
final todayProgressProvider = Provider<LumiTodayProgress>((ref) {
  final entries =
      ref.watch(allChecklistEntriesStreamProvider).value ?? const [];
  final items = ref.watch(allActiveItemsStreamProvider).value ?? const [];
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  final dueTodayIds = items
      .where(
        (i) =>
            i.dueDate != null &&
            !i.dueDate!.isBefore(todayStart) &&
            i.dueDate!.isBefore(todayEnd),
      )
      .map((i) => i.id)
      .toSet();

  final relevantEntries = entries.where((e) {
    if (dueTodayIds.contains(e.itemId)) return true;
    final completedToday =
        e.completedAt != null &&
        !e.completedAt!.isBefore(todayStart) &&
        e.completedAt!.isBefore(todayEnd);
    return completedToday;
  }).toList();

  final completed = relevantEntries.where((e) => e.done).length;
  return LumiTodayProgress(
    completedCount: completed,
    totalCount: relevantEntries.length,
  );
});
