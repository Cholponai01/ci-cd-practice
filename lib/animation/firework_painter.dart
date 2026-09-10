import 'package:flutter/material.dart';

class Shard {
  const Shard({
    required this.origin,
    required this.velocity,
    required this.color,
    required this.hueShift,
  });

  final Offset origin;
  final Offset velocity;
  final Color color;
  final double hueShift;
}

class FireworksPainter extends CustomPainter {
  FireworksPainter({required this.progress, required this.shards});

  final double progress;
  final List<Shard> shards;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || shards.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    const g = 420.0;

    for (final s in shards) {
      final t = progress;
      final dx = s.velocity.dx * t;
      final dy = s.velocity.dy * t + 0.5 * g * t * t;
      final p = s.origin + Offset(dx, dy);
      final fade = (1 - t).clamp(0.0, 1.0);
      paint.color = HSVColor.fromAHSV(
        fade,
        (HSVColor.fromColor(s.color).hue + s.hueShift * t) % 360,
        0.85,
        1,
      ).toColor();
      canvas.drawCircle(p, 3.2 * fade + 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FireworksPainter old) =>
      old.progress != progress || !identical(old.shards, shards);
}
