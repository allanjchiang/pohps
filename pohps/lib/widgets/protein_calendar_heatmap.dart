import 'package:flutter/material.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';

/// Month calendar highlighting each day the user met their protein goal in
/// green. Hand-built (not a calendar package) so touch targets, contrast,
/// and text size stay fully under our control for elderly-friendly use.
class ProteinCalendarHeatmap extends StatefulWidget {
  final AppState appState;

  const ProteinCalendarHeatmap({super.key, required this.appState});

  @override
  State<ProteinCalendarHeatmap> createState() =>
      _ProteinCalendarHeatmapState();
}

class _ProteinCalendarHeatmapState extends State<ProteinCalendarHeatmap> {
  late DateTime _month;

  /// Jan 4 1970 was a Sunday — used as a stable anchor to derive each
  /// weekday's short localized label for the calendar's column headers.
  static final _sundayAnchor = DateTime(1970, 1, 4);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return _month.isBefore(DateTime(now.year, now.month));
  }

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));

  void _nextMonth() {
    if (!_canGoNext) return;
    setState(() => _month = DateTime(_month.year, _month.month + 1));
  }

  void _showDayDetail(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final detail =
        widget.appState.statistics.dayDetail(date, widget.appState.dailyGoal);
    if (detail.totalProtein <= 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.dayDetailMessage(
            '${l10n.formatShortMonth(date)} ${date.day}',
            detail.totalProtein.round(),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final goalMetByDay = widget.appState.statistics
        .goalMetByDay(_month, widget.appState.dailyGoal);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;
    final leadingBlanks = firstWeekday % 7;
    final today = AppState.dateOnly(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.proteinCalendar, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _prevMonth,
              icon: const Icon(Icons.chevron_left),
              iconSize: 28,
              tooltip: l10n.previousMonth,
            ),
            Expanded(
              child: Text(
                l10n.formatMonthYear(_month),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: _canGoNext ? _nextMonth : null,
              icon: const Icon(Icons.chevron_right),
              iconSize: 28,
              tooltip: l10n.nextMonth,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(7, (i) {
            final label = l10n
                .formatShortWeekday(_sundayAnchor.add(Duration(days: i)));
            return Expanded(
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: leadingBlanks + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = index - leadingBlanks + 1;
            final date = DateTime(_month.year, _month.month, day);
            final goalMet = goalMetByDay[date];
            final isToday = AppState.isSameDay(date, today);
            final isFuture = date.isAfter(today);
            return _DayCell(
              day: day,
              goalMet: goalMet,
              isToday: isToday,
              isFuture: isFuture,
              onTap: isFuture ? null : () => _showDayDetail(context, date),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _LegendSwatch(
              color: theme.colorScheme.primary,
              label: l10n.goalMetLegend,
            ),
            const SizedBox(width: 20),
            _LegendSwatch(
              color: theme.colorScheme.surfaceContainerHighest,
              label: l10n.goalNotMetLegend,
            ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool? goalMet;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.goalMet,
    required this.isToday,
    required this.isFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color background;
    final Color textColor;
    if (isFuture) {
      background = Colors.transparent;
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    } else if (goalMet == true) {
      background = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (goalMet == false) {
      background = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
    } else {
      background = Colors.transparent;
      textColor = colorScheme.onSurfaceVariant;
    }

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isToday
            ? BorderSide(color: colorScheme.tertiary, width: 2)
            : BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 15,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
