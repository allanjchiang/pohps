import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';

/// Pleasant blue water-intake ring (mirrors [ProgressRing] layout).
class WaterProgressRing extends StatelessWidget {
  final double progress;
  final double currentMl;
  final double goalMl;
  final MeasurementSystem measurementSystem;
  final double size;

  static const _waterBlue = Color(0xFF42A5F5);
  static const _waterBlueComplete = Color(0xFF1565C0);

  const WaterProgressRing({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    required this.measurementSystem,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completed = progress >= 1.0;
    final l10n = AppLocalizations.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _WaterRingPainter(
              progress: value,
              trackColor: colorScheme.surfaceContainerHighest,
              fillColor: completed ? _waterBlueComplete : _waterBlue,
              strokeWidth: 14,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (completed)
                    const Text('💧', style: TextStyle(fontSize: 28)),
                  Text(
                    l10n.formatWaterVolume(currentMl, measurementSystem,
                        compact: true),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: _waterBlueComplete,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.waterOfGoal(goalMl, measurementSystem),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WaterRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  _WaterRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaterRingPainter old) =>
      progress != old.progress || fillColor != old.fillColor;
}
