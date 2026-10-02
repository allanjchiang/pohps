import 'dart:math';
import 'package:flutter/material.dart';
import '../data/nutrient_limits.dart';
import '../l10n/app_localizations.dart';

/// Violet calcium-intake ring (mirrors [ProgressRing] layout).
class CalciumProgressRing extends StatelessWidget {
  final double progress;
  final double currentMg;
  final int goalMg;
  final double size;

  /// Intake is above the daily upper limit: warn instead of celebrating.
  final bool overLimit;

  static const calciumViolet = Color(0xFF9575CD);
  static const calciumVioletComplete = Color(0xFF6A4BA3);

  const CalciumProgressRing({
    super.key,
    required this.progress,
    required this.currentMg,
    required this.goalMg,
    this.size = 220,
    this.overLimit = false,
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
            painter: _CalciumRingPainter(
              progress: value,
              trackColor: colorScheme.surfaceContainerHighest,
              fillColor: overLimit
                  ? overLimitAmber
                  : completed
                      ? calciumVioletComplete
                      : calciumViolet,
              strokeWidth: 14,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (overLimit)
                    const Text('⚠️', style: TextStyle(fontSize: 28))
                  else if (completed)
                    const Text('🦴', style: TextStyle(fontSize: 28)),
                  Text(
                    l10n.formatCalciumMg(currentMg),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: overLimit ? overLimitAmberDark : calciumVioletComplete,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.calciumOfGoal(goalMg),
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

class _CalciumRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  _CalciumRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Inset so round stroke caps are not clipped by the canvas edge.
    final radius = (size.shortestSide - strokeWidth * 2) / 2;

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
  bool shouldRepaint(covariant _CalciumRingPainter old) =>
      progress != old.progress || fillColor != old.fillColor;
}
