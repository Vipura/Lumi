import 'package:flutter/material.dart';

import 'lumi_buttons.dart';
import 'lumi_glass.dart';
import 'lumi_tokens.dart';

/// Displays a frosted Liquid Glass dialog with high-contrast content.
///
/// Prefer [contentBuilder] and [actionsBuilder] so `Navigator.of(dialogContext)`
/// pops the dialog overlay route rather than an ancestor shell navigator.
Future<T?> showLumiGlassDialog<T>({
  required BuildContext context,
  required String title,
  Widget? content,
  WidgetBuilder? contentBuilder,
  List<Widget>? actions,
  List<Widget> Function(BuildContext dialogContext)? actionsBuilder,
  Color? tintColor,
}) {
  assert(
    content != null || contentBuilder != null,
    'Provide either content or contentBuilder.',
  );
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.40),
    builder: (dialogContext) {
      final resolvedContent = contentBuilder?.call(dialogContext) ?? content!;
      final resolvedActions =
          actionsBuilder?.call(dialogContext) ?? actions ?? const <Widget>[];
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(LumiSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LumiGlass(
            borderRadius: LumiRadius.lg,
            blur: 20,
            elevated: true,
            grouped: false,
            tintColor: tintColor,
            padding: const EdgeInsets.all(LumiSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                ),
                const SizedBox(height: LumiSpacing.sm),
                Flexible(child: SingleChildScrollView(child: resolvedContent)),
                if (resolvedActions.isNotEmpty) ...[
                  const SizedBox(height: LumiSpacing.lg),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: LumiSpacing.xs,
                    runSpacing: LumiSpacing.xs,
                    children: resolvedActions,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Convenience confirmation dialog using Lumi Glass styling.
Future<bool> showLumiConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showLumiGlassDialog<bool>(
    context: context,
    title: title,
    contentBuilder: (dialogCtx) =>
        Text(message, style: Theme.of(dialogCtx).textTheme.bodyMedium),
    actionsBuilder: (dialogCtx) => [
      LumiGlassButton(
        label: cancelLabel,
        onPressed: () => Navigator.of(dialogCtx).pop(false),
      ),
      LumiGlassButton(
        label: confirmLabel,
        primary: true,
        tintColor: destructive ? LumiColors.danger : null,
        onPressed: () => Navigator.of(dialogCtx).pop(true),
      ),
    ],
  );
  return result ?? false;
}

/// Convenience single-field prompt dialog whose [TextEditingController] lifecycle
/// is scoped to the dialog state so exit transitions never hit a disposed controller.
Future<String?> showLumiTextPromptDialog({
  required BuildContext context,
  required String title,
  required String hintText,
  String confirmLabel = 'Add',
  String cancelLabel = 'Cancel',
  String initialValue = '',
  TextInputType? keyboardType,
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.40),
    builder: (dialogCtx) => _LumiTextPromptDialog(
      title: title,
      hintText: hintText,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialValue: initialValue,
      keyboardType: keyboardType,
    ),
  );
}

class _LumiTextPromptDialog extends StatefulWidget {
  const _LumiTextPromptDialog({
    required this.title,
    required this.hintText,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.initialValue,
    this.keyboardType,
  });

  final String title;
  final String hintText;
  final String confirmLabel;
  final String cancelLabel;
  final String initialValue;
  final TextInputType? keyboardType;

  @override
  State<_LumiTextPromptDialog> createState() => _LumiTextPromptDialogState();
}

class _LumiTextPromptDialogState extends State<_LumiTextPromptDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(LumiSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: LumiGlass(
          borderRadius: LumiRadius.lg,
          blur: 20,
          elevated: true,
          grouped: false,
          padding: const EdgeInsets.all(LumiSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: LumiSpacing.sm),
              Flexible(
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: widget.keyboardType,
                    decoration: InputDecoration(hintText: widget.hintText),
                    onSubmitted: (v) => Navigator.of(context).pop(v),
                  ),
                ),
              ),
              const SizedBox(height: LumiSpacing.lg),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: LumiSpacing.xs,
                runSpacing: LumiSpacing.xs,
                children: [
                  LumiGlassButton(
                    label: widget.cancelLabel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  LumiGlassButton(
                    label: widget.confirmLabel,
                    primary: true,
                    onPressed: () =>
                        Navigator.of(context).pop(_controller.text),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
