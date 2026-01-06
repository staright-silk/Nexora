import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated pressure ring that tightens as time progresses
class PressureRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final Animation<double> pulseAnimation;

  const PressureRing({
    super.key,
    required this.progress,
    required this.color,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(280, 280),
          painter: _PressureRingPainter(
            progress: progress,
            color: color,
            pulseValue: pulseAnimation.value,
          ),
        );
      },
    );
  }
}

class _PressureRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double pulseValue;

  _PressureRingPainter({
    required this.progress,
    required this.color,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background ring
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawCircle(center, radius - 10, backgroundPaint);

    // Progress ring with increasing saturation
    final progressPaint = Paint()
      ..color = color.withOpacity(0.3 + (progress * 0.7))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20 + (progress * 10) // Gets thicker as time passes
      ..strokeCap = StrokeCap.round;

    // Add pulse effect
    final pulsedRadius = radius - 10 + (pulseValue * 5);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: pulsedRadius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Inner glow effect
    if (progress > 0.5) {
      final glowPaint = Paint()
        ..color = color.withOpacity((progress - 0.5) * 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius - 40, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PressureRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.pulseValue != pulseValue;
  }
}

