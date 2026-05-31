import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import 'progress_ring.dart';
import 'water_progress_ring.dart';

/// Swipe horizontally between protein and water progress rings.
class ProgressTrackerCarousel extends StatefulWidget {
  final double proteinProgress;
  final double proteinCurrent;
  final double proteinGoal;
  final bool proteinGoalReached;
  final String proteinGoalReachedText;

  final bool waterTrackerEnabled;
  final double waterProgress;
  final double waterCurrentMl;
  final double waterGoalMl;
  final MeasurementSystem measurementSystem;
  final bool waterGoalReached;
  final String waterGoalReachedText;

  const ProgressTrackerCarousel({
    super.key,
    required this.proteinProgress,
    required this.proteinCurrent,
    required this.proteinGoal,
    required this.proteinGoalReached,
    required this.proteinGoalReachedText,
    required this.waterTrackerEnabled,
    required this.waterProgress,
    required this.waterCurrentMl,
    required this.waterGoalMl,
    required this.measurementSystem,
    required this.waterGoalReached,
    required this.waterGoalReachedText,
  });

  @override
  State<ProgressTrackerCarousel> createState() =>
      _ProgressTrackerCarouselState();
}

class _ProgressTrackerCarouselState extends State<ProgressTrackerCarousel> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final pageCount = widget.waterTrackerEnabled ? 2 : 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 220,
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              ProgressRing(
                progress: widget.proteinProgress,
                current: widget.proteinCurrent,
                goal: widget.proteinGoal,
              ),
              if (widget.waterTrackerEnabled)
                WaterProgressRing(
                  progress: widget.waterProgress,
                  currentMl: widget.waterCurrentMl,
                  goalMl: widget.waterGoalMl,
                  measurementSystem: widget.measurementSystem,
                ),
            ],
          ),
        ),
        if (_page == 0 && widget.proteinGoalReached)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.proteinGoalReachedText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (_page == 1 && widget.waterGoalReached)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.waterGoalReachedText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (pageCount > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (i) {
              final selected = i == _page;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 10 : 8,
                  height: selected ? 10 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? (i == 0
                            ? theme.colorScheme.primary
                            : const Color(0xFF42A5F5))
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            _page == 0 ? l10n.swipeForWater : l10n.swipeForProtein,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
