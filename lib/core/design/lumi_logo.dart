import 'package:flutter/material.dart';

import 'lumi_themes.dart';

/// Custom-painted Lumi brand mark: a glowing translucent glass droplet/orb.
class LumiLogo extends StatelessWidget {
  const LumiLogo({
    super.key,
    this.size = 44,
    this.accentColor,
    this.showHalo = true,
  });

  final double size;
  final Color? accentColor;
  final bool showHalo;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? context.lumiTheme.accentColor;
    final brightness = Theme.of(context).brightness;
    return Semantics(
      label: 'Lumi logo',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _LumiLogoPainter(
            accent: accent,
            brightness: brightness,
            showHalo: showHalo,
          ),
        ),
      ),
    );
  }
}

class _LumiLogoPainter extends CustomPainter {
  const _LumiLogoPainter({
    required this.accent,
    required this.brightness,
    required this.showHalo,
  });

  final Color accent;
  final Brightness brightness;
  final bool showHalo;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.56);

    if (showHalo) {
      final haloPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(
              alpha: brightness == Brightness.dark ? 0.52 : 0.36,
            ),
            accent.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: w * 0.54));
      canvas.drawCircle(center, w * 0.54, haloPaint);
    }

    // Teardrop / glass droplet silhouette.
    final path = Path()
      ..moveTo(w * 0.5, h * 0.09)
      ..cubicTo(w * 0.72, h * 0.32, w * 0.86, h * 0.50, w * 0.86, h * 0.64)
      ..cubicTo(w * 0.86, h * 0.84, w * 0.70, h * 0.93, w * 0.50, h * 0.93)
      ..cubicTo(w * 0.30, h * 0.93, w * 0.14, h * 0.84, w * 0.14, h * 0.64)
      ..cubicTo(w * 0.14, h * 0.50, w * 0.28, h * 0.32, w * 0.50, h * 0.09)
      ..close();

    // Translucent glass body gradient.
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(
            alpha: brightness == Brightness.dark ? 0.42 : 0.86,
          ),
          Color.lerp(accent, Colors.white, 0.32)!.withValues(alpha: 0.55),
          accent.withValues(alpha: 0.78),
        ],
        stops: const [0.0, 0.52, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, bodyPaint);

    // Warm inner radiant core inside the droplet.
    final coreCenter = Offset(w * 0.46, h * 0.62);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.85),
          Color.lerp(accent, Colors.amberAccent, 0.4)!.withValues(alpha: 0.55),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: coreCenter, radius: w * 0.28));
    canvas.save();
    canvas.clipPath(path);
    canvas.drawCircle(coreCenter, w * 0.28, corePaint);
    canvas.restore();

    // Specular rim border.
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.045).clamp(1.0, 2.5)
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.92),
          Colors.white.withValues(alpha: 0.22),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, rimPaint);

    // Subtle specular highlight arc on the upper-left curve.
    final gleamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (w * 0.055).clamp(1.2, 3.0)
      ..color = Colors.white.withValues(alpha: 0.72);
    final gleam = Path()
      ..moveTo(w * 0.34, h * 0.44)
      ..quadraticBezierTo(w * 0.25, h * 0.55, w * 0.27, h * 0.67);
    canvas.drawPath(gleam, gleamPaint);
  }

  @override
  bool shouldRepaint(covariant _LumiLogoPainter oldDelegate) {
    return oldDelegate.accent != accent ||
        oldDelegate.brightness != brightness ||
        oldDelegate.showHalo != showHalo;
  }
}
