import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design_system.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';

class LumiTemplate {
  const LumiTemplate({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.type,
    required this.deltaOps,
    this.checklistItems = const [],
    this.collectionId,
    this.tagName,
  });

  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final LumiItemType type;
  final List<Map<String, dynamic>> deltaOps;
  final List<String> checklistItems;
  final String? collectionId;
  final String? tagName;
}

const lumiBuiltInTemplates = <LumiTemplate>[
  LumiTemplate(
    id: 'daily_plan',
    name: 'Daily plan',
    subtitle: 'Top priorities, schedule blocks, and gratitude',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFF8A5B),
    type: LumiItemType.checklist,
    collectionId: 'col_personal',
    tagName: 'daily',
    deltaOps: [
      {
        'insert': 'Daily Plan\n',
        'attributes': {'header': 1},
      },
      {
        'insert': 'Intent for today:\n',
        'attributes': {'bold': true},
      },
      {'insert': 'Keep momentum calm and deliberate.\n\n'},
      {
        'insert': 'Evening reflection:\n',
        'attributes': {'bold': true},
      },
      {'insert': 'What felt most meaningful today?\n'},
    ],
    checklistItems: [
      'Define the #1 non-negotiable outcome',
      'Deep focus block (60 min)',
      'Clear inbox & quick replies',
      'Evening wind-down & tomorrow prep',
    ],
  ),
  LumiTemplate(
    id: 'weekly_review',
    name: 'Weekly review',
    subtitle: 'Wins, lessons learned, and next week focus',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFF8B5CF6),
    type: LumiItemType.note,
    collectionId: 'col_personal',
    tagName: 'review',
    deltaOps: [
      {
        'insert': 'Weekly Review\n',
        'attributes': {'header': 1},
      },
      {
        'insert': 'Biggest wins\n',
        'attributes': {'header': 2},
      },
      {'insert': '• \n\n'},
      {
        'insert': 'What slowed me down\n',
        'attributes': {'header': 2},
      },
      {'insert': '• \n\n'},
      {
        'insert': 'Next week focus\n',
        'attributes': {'header': 2},
      },
      {'insert': '• \n'},
    ],
  ),
  LumiTemplate(
    id: 'meeting_notes',
    name: 'Meeting notes',
    subtitle: 'Attendees, agenda, decisions, and action items',
    icon: Icons.groups_rounded,
    color: Color(0xFF38BDF8),
    type: LumiItemType.checklist,
    collectionId: 'col_work',
    tagName: 'meeting',
    deltaOps: [
      {
        'insert': 'Meeting Notes\n',
        'attributes': {'header': 1},
      },
      {
        'insert': 'Attendees: ',
        'attributes': {'bold': true},
      },
      {'insert': '\n'},
      {
        'insert': 'Summary & Decisions\n',
        'attributes': {'header': 2},
      },
      {'insert': 'Key takeaways from the discussion.\n'},
    ],
    checklistItems: [
      'Send follow-up summary to team',
      'Confirm owner & timeline for next milestone',
    ],
  ),
  LumiTemplate(
    id: 'shopping_list',
    name: 'Shopping list',
    subtitle: 'Groceries and household essentials',
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFF10B981),
    type: LumiItemType.checklist,
    collectionId: 'col_personal',
    tagName: 'errands',
    deltaOps: [
      {
        'insert': 'Shopping List\n',
        'attributes': {'header': 1},
      },
      {'insert': 'Fresh produce & pantry restock.\n'},
    ],
    checklistItems: [
      'Fresh fruit & greens',
      'Coffee beans / oat milk',
      'Sourdough bread',
      'Sparkling water',
    ],
  ),
  LumiTemplate(
    id: 'study_notes',
    name: 'Study notes',
    subtitle: 'Core concepts, questions, and recall cues',
    icon: Icons.menu_book_rounded,
    color: Color(0xFFF59E0B),
    type: LumiItemType.note,
    collectionId: 'col_study',
    tagName: 'study',
    deltaOps: [
      {
        'insert': 'Study Notes\n',
        'attributes': {'header': 1},
      },
      {
        'insert': 'Core Concepts\n',
        'attributes': {'header': 2},
      },
      {'insert': 'Summarize the main mental model in your own words.\n\n'},
      {
        'insert': 'Open Questions\n',
        'attributes': {'header': 2},
      },
      {'insert': '• \n\n'},
      {
        'insert': 'Quick Recall Summary\n',
        'attributes': {'header': 2},
      },
      {'insert': 'Three key points to remember without looking.\n'},
    ],
  ),
];

/// Instantiates a template into Drift and returns the created item ID.
Future<String> createItemFromTemplate(
  WidgetRef ref,
  LumiTemplate template, {
  DateTime? dueDate,
}) async {
  final itemsRepo = ref.read(itemsRepositoryProvider);
  final checklistRepo = ref.read(checklistRepositoryProvider);
  final orgRepo = ref.read(organizationRepositoryProvider);

  String? resolvedCollectionId = template.collectionId;
  if (resolvedCollectionId != null) {
    final existingCols = await ref
        .read(databaseProvider)
        .organizationDao
        .getCollections();
    if (!existingCols.any((c) => c.id == resolvedCollectionId)) {
      resolvedCollectionId = null;
    }
  }

  final item = await itemsRepo.createItem(
    type: template.type,
    title: template.name,
    bodyDeltaJson: jsonEncode(template.deltaOps),
    collectionId: resolvedCollectionId,
    dueDate: dueDate ?? (template.id == 'daily_plan' ? DateTime.now() : null),
  );

  for (final text in template.checklistItems) {
    await checklistRepo.addEntry(itemId: item.id, text: text);
  }
  if (template.tagName != null) {
    await orgRepo.addTagToItem(itemId: item.id, tagName: template.tagName!);
  }
  return item.id;
}

/// Opens a template picker sheet using its own live [Consumer] `WidgetRef`,
/// preventing disposed-caller `ref` errors when opened after closing another sheet.
Future<String?> showTemplatesSheet(
  BuildContext context, [
  WidgetRef? _,
  LumiItemType? filterType,
]) {
  return showLumiGlassBottomSheet<String>(
    context: context,
    title: 'Start from a template',
    builder: (sheetCtx) => _TemplatesSheetBody(filterType: filterType),
  );
}

class _TemplatesSheetBody extends ConsumerStatefulWidget {
  const _TemplatesSheetBody({this.filterType});

  final LumiItemType? filterType;

  @override
  ConsumerState<_TemplatesSheetBody> createState() =>
      _TemplatesSheetBodyState();
}

class _TemplatesSheetBodyState extends ConsumerState<_TemplatesSheetBody> {
  String? _creatingId;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final templates = widget.filterType == null
        ? lumiBuiltInTemplates
        : lumiBuiltInTemplates
              .where((t) => t.type == widget.filterType)
              .toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: templates.map((tpl) {
          final isBusy = _creatingId == tpl.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: LumiSpacing.xs),
            child: LumiGlass.card(
              onTap: _creatingId != null
                  ? null
                  : () async {
                      setState(() => _creatingId = tpl.id);
                      try {
                        final id = await createItemFromTemplate(ref, tpl);
                        if (context.mounted) Navigator.of(context).pop(id);
                      } catch (_) {
                        if (mounted) setState(() => _creatingId = null);
                      }
                    },
              padding: const EdgeInsets.all(LumiSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: tpl.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(LumiRadius.sm),
                    ),
                    child: isBusy
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: tpl.color,
                            ),
                          )
                        : Icon(tpl.icon, color: tpl.color, size: 22),
                  ),
                  const SizedBox(width: LumiSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tpl.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tpl.color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(
                                  LumiRadius.pill,
                                ),
                              ),
                              child: Text(
                                tpl.type == LumiItemType.checklist
                                    ? 'Checklist'
                                    : 'Note',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tpl.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tpl.subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ext.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: LumiSpacing.xs),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: ext.inkMuted,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
