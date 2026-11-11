import 'package:flutter/material.dart';

import 'lumi_glass.dart';
import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Frosted pill search input with clear action and optional trailing widget.
class LumiGlassSearchField extends StatefulWidget {
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

  @override
  State<LumiGlassSearchField> createState() => _LumiGlassSearchFieldState();
}

class _LumiGlassSearchFieldState extends State<LumiGlassSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant LumiGlassSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final hasText = widget.controller.text.isNotEmpty;

    return LumiGlass(
      borderRadius: LumiRadius.pill,
      blur: 22,
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
              controller: widget.controller,
              focusNode: widget.focusNode,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ext.ink),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: ext.inkMuted),
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (hasText && !widget.readOnly)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 18, color: ext.inkMuted),
              tooltip: 'Clear search',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                widget.controller.clear();
                widget.onChanged?.call('');
              },
            ),
          if (widget.trailing != null) widget.trailing!,
        ],
      ),
    );
  }
}
