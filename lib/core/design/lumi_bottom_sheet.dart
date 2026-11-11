import 'package:flutter/material.dart';

import 'lumi_glass.dart';
import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Displays a Liquid Glass modal bottom sheet with drag handle and safe insets.
Future<T?> showLumiGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  Color? tintColor,
  String? title,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.36),
    builder: (sheetContext) {
      final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          LumiSpacing.sm,
          LumiSpacing.md,
          LumiSpacing.sm,
          LumiSpacing.sm + bottomInset,
        ),
        child: LumiGlassSheetContainer(
          tintColor: tintColor,
          title: title,
          child: builder(sheetContext),
        ),
      );
    },
  );
}

class LumiGlassSheetContainer extends StatelessWidget {
  const LumiGlassSheetContainer({
    super.key,
    required this.child,
    this.title,
    this.tintColor,
    this.padding = const EdgeInsets.fromLTRB(
      LumiSpacing.lg,
      LumiSpacing.sm,
      LumiSpacing.lg,
      LumiSpacing.lg,
    ),
  });

  final Widget child;
  final String? title;
  final Color? tintColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    return LumiGlass(
      borderRadius: LumiRadius.xl,
      blur: 28,
      elevated: true,
      tintColor: tintColor,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: LumiSpacing.md),
              decoration: BoxDecoration(
                color: ext.inkMuted.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(LumiRadius.pill),
              ),
            ),
          ),
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: LumiSpacing.md),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }
}
