import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Smooth animated circular progress ring with soft luminous gradient stroke.
class LumiProgressRing extends StatelessWidget {
  const LumiProgressRing({
    super.key,
    required this.progress,
    this.size = 44,
    this.strokeWidth = 4.5,
    this.color,
    this.trackColor,
    this.child,
  });

  /// Clamped between 0.0 and 1.0.
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final scope = LumiDesignScope.maybeOf(context);
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? ext.reduceMotion,
    );
    final target = progress.clamp(0.0, 1.0);
    final ringColor = color ?? ext.accentColor;
    final track = trackColor ?? ext.inkMuted.withValues(alpha: 0.18);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: target, end: target),
      duration: reduceMotion ? Duration.zero : LumiMotion.slow,
      curve: LumiMotion.spring,
      builder: (context, value, _) {
        return Semantics(
          label: '${(value * 100).round()} percent complete',
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(size),
                  painter: _RingPainter(
                    progress: value,
                    strokeWidth: strokeWidth,
                    color: ringColor,
                    trackColor: track,
                  ),
                ),
                ?child,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweep = progress * math.pi * 2;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.pi * 2,
        colors: [Color.lerp(color, Colors.white, 0.28)!, color],
      ).createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
