import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/fishing_score.dart';

class ScoreGauge extends StatelessWidget {
  final FishingScore score;
  final bool dark;

  const ScoreGauge({super.key, required this.score, this.dark = false});

  Color get _arcColor {
    if (score.score >= 80) return const Color(0xFF4CAF50);
    if (score.score >= 60) return const Color(0xFF8BC34A);
    if (score.score >= 40) return const Color(0xFFFFC107);
    if (score.score >= 20) return const Color(0xFFFF5722);
    return const Color(0xFFF44336);
  }

  String get _emoji {
    switch (score.rating) {
      case FishingRating.excellent:
        return '🎣';
      case FishingRating.good:
        return '🐟';
      case FishingRating.fair:
        return '😐';
      case FishingRating.poor:
        return '☁️';
      case FishingRating.terrible:
        return '⛈️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = dark ? Colors.white : _arcColor;
    final subtextColor = dark ? Colors.white70 : _arcColor.withValues(alpha: 0.75);

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _ArcPainter(
              value: score.score / 100,
              arcColor: _arcColor,
              trackColor: dark ? Colors.white24 : Colors.grey.shade200,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 4),
              Text(
                '${score.score}',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                score.ratingLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double value;
  final Color arcColor;
  final Color trackColor;

  _ArcPainter({required this.value, required this.arcColor, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;
    const startAngle = math.pi * 0.75;
    const maxSweep = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      maxSweep,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );

    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        maxSweep * value,
        false,
        Paint()
          ..color = arcColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.value != value || old.arcColor != arcColor;
}
