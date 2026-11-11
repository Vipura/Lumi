import 'package:flutter/material.dart';

import 'lumi_glass.dart';
import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Frosted Liquid Glass pill search input with zero-rebuild typing clear button.
class LumiGlassSearchField extends StatelessWidget {
  const LumiGlassSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search notes, checklists, tags...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.trailing,
    this.focusNode,
    this.grouped = true,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final Widget? trailing;
  final FocusNode? focusNode;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;

    return LumiGlass(
      borderRadius: LumiRadius.pill,
      blur: 0,
      useBlur: false,
      elevated: true,
      hasShadow: false,
      grouped: grouped,
      padding: const EdgeInsets.symmetric(
        horizontal: LumiSpacing.md,
        vertical: LumiSpacing.xxs,
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: ext.inkMuted),
          const SizedBox(width: LumiSpacing.xs),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              autofocus: autofocus,
              onTap: onTap,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ext.ink),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: ext.inkMuted),
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (!readOnly)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: ext.inkMuted,
                  ),
                  tooltip: 'Clear search',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                );
              },
            ),
          ?trailing,
        ],
      ),
    );
  }
}
