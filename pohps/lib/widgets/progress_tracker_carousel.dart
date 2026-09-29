import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import 'iron_progress_ring.dart';
import 'progress_ring.dart';
import 'water_progress_ring.dart';

enum _TrackerPage { protein, water, iron }

/// Swipe horizontally between protein, water and iron progress rings.
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

  final bool ironTrackerEnabled;
  final double ironProgress;
  final double ironCurrentMg;
  final int ironGoalMg;
  final bool ironGoalReached;
  final String ironGoalReachedText;

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
    required this.ironTrackerEnabled,
    required this.ironProgress,
    required this.ironCurrentMg,
    required this.ironGoalMg,
    required this.ironGoalReached,
    required this.ironGoalReachedText,
  });

  @override
  State<ProgressTrackerCarousel> createState() =>
      _ProgressTrackerCarouselState();
}

class _ProgressTrackerCarouselState extends State<ProgressTrackerCarousel> {
  static const _ringSize = 220.0;

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
    final pages = [
      _TrackerPage.protein,
      if (widget.waterTrackerEnabled) _TrackerPage.water,
      if (widget.ironTrackerEnabled) _TrackerPage.iron,
    ];
    // A tracker switched off in Settings can leave the index past the end.
    final pageIndex = _page.clamp(0, pages.length - 1);
    final page = pages[pageIndex];

    final (goalReached, goalReachedText, goalColor) = switch (page) {
      _TrackerPage.protein => (
          widget.proteinGoalReached,
          widget.proteinGoalReachedText,
          theme.colorScheme.primary,
        ),
      _TrackerPage.water => (
          widget.waterGoalReached,
          widget.waterGoalReachedText,
          const Color(0xFF1565C0),
        ),
      _TrackerPage.iron => (
          widget.ironGoalReached,
          widget.ironGoalReachedText,
          IronProgressRing.ironRedComplete,
        ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _ringSize,
          child: PageView(
            clipBehavior: Clip.none,
            controller: _pageController,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              for (final p in pages) Center(child: _buildRing(p)),
            ],
          ),
        ),
        if (goalReached)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              goalReachedText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: goalColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (pages.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (i) {
              final selected = i == pageIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 10 : 8,
                  height: selected ? 10 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? _dotColor(pages[i], theme)
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            _swipeHint(pages, pageIndex, l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRing(_TrackerPage page) => switch (page) {
        _TrackerPage.protein => ProgressRing(
            progress: widget.proteinProgress,
            current: widget.proteinCurrent,
            goal: widget.proteinGoal,
            size: _ringSize,
          ),
        _TrackerPage.water => WaterProgressRing(
            progress: widget.waterProgress,
            currentMl: widget.waterCurrentMl,
            goalMl: widget.waterGoalMl,
            measurementSystem: widget.measurementSystem,
            size: _ringSize,
          ),
        _TrackerPage.iron => IronProgressRing(
            progress: widget.ironProgress,
            currentMg: widget.ironCurrentMg,
            goalMg: widget.ironGoalMg,
            size: _ringSize,
          ),
      };

  Color _dotColor(_TrackerPage page, ThemeData theme) => switch (page) {
        _TrackerPage.protein => theme.colorScheme.primary,
        _TrackerPage.water => const Color(0xFF42A5F5),
        _TrackerPage.iron => IronProgressRing.ironRed,
      };

  /// Points to the next ring, or back to protein from the last one.
  String _swipeHint(
    List<_TrackerPage> pages,
    int index,
    AppLocalizations l10n,
  ) {
    if (index == pages.length - 1) return l10n.swipeForProtein;
    return switch (pages[index + 1]) {
      _TrackerPage.water => l10n.swipeForWater,
      _TrackerPage.iron => l10n.swipeForIron,
      _TrackerPage.protein => l10n.swipeForProtein,
    };
  }
}
