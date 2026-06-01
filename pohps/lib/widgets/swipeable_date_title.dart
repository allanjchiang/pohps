import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Dashboard app bar title that swipes between days.
/// Swipe right → older day. Swipe left → newer day (up to today).
class SwipeableDateTitle extends StatefulWidget {
  final DateTime date;
  final bool canGoForward;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  const SwipeableDateTitle({
    super.key,
    required this.date,
    required this.canGoForward,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  @override
  State<SwipeableDateTitle> createState() => _SwipeableDateTitleState();
}

class _SwipeableDateTitleState extends State<SwipeableDateTitle> {
  double _dragOffset = 0;
  int _slideDirection = 0;

  static const _swipeThreshold = 48.0;

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final offset = _dragOffset;

    if (offset > _swipeThreshold || velocity > 350) {
      setState(() => _slideDirection = 1);
      widget.onPreviousDay();
    } else if (widget.canGoForward &&
        (offset < -_swipeThreshold || velocity < -350)) {
      setState(() => _slideDirection = -1);
      widget.onNextDay();
    }

    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hintColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
    final activeColor = theme.colorScheme.primary;

    return Semantics(
      label: l10n.swipeDateHint,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.delta.dx;
            if (!widget.canGoForward && _dragOffset < 0) {
              _dragOffset = 0;
            }
          });
        },
        onHorizontalDragEnd: _handleDragEnd,
        child: Transform.translate(
          offset: Offset(_dragOffset * 0.35, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left, size: 22, color: hintColor),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: Offset(_slideDirection * 0.35, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return ClipRect(
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    l10n.formatDashboardDate(widget.date),
                    key: ValueKey(
                      '${widget.date.year}-${widget.date.month}-${widget.date.day}',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22,
                color: widget.canGoForward ? hintColor : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
