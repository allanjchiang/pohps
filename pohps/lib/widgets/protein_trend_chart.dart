import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';

/// Protein trend graph with a Week/Month/Year/Year-to-date switcher.
/// Week and Month plot daily totals; Year and YTD plot monthly averages —
/// 365 raw daily points would be unreadable, especially for older users.
class ProteinTrendChart extends StatefulWidget {
  final AppState appState;

  const ProteinTrendChart({super.key, required this.appState});

  @override
  State<ProteinTrendChart> createState() => _ProteinTrendChartState();
}

class _ProteinTrendChartState extends State<ProteinTrendChart> {
  TrendPeriod _period = TrendPeriod.week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final points = _points(widget.appState, l10n);
    final goal = widget.appState.dailyGoal.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.proteinTrend, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PeriodChip(
              label: l10n.trendWeek,
              selected: _period == TrendPeriod.week,
              onSelected: () => setState(() => _period = TrendPeriod.week),
            ),
            _PeriodChip(
              label: l10n.trendMonth,
              selected: _period == TrendPeriod.month,
              onSelected: () => setState(() => _period = TrendPeriod.month),
            ),
            _PeriodChip(
              label: l10n.trendYear,
              selected: _period == TrendPeriod.year,
              onSelected: () => setState(() => _period = TrendPeriod.year),
            ),
            _PeriodChip(
              label: l10n.trendYearToDate,
              selected: _period == TrendPeriod.yearToDate,
              onSelected: () =>
                  setState(() => _period = TrendPeriod.yearToDate),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 260,
          child: points.isEmpty
              ? _EmptyChartState(text: l10n.noStatisticsYet)
              : _TrendLineChart(points: points, goal: goal, theme: theme),
        ),
      ],
    );
  }

  List<_ChartPoint> _points(AppState appState, AppLocalizations l10n) {
    final now = DateTime.now();
    final goal = appState.dailyGoal;
    switch (_period) {
      case TrendPeriod.week:
        final daily = appState.statistics.dailyTrend(
          endDate: now,
          days: 7,
          dailyGoal: goal,
        );
        return [
          for (final d in daily)
            _ChartPoint(
                l10n.formatShortWeekday(d.date), d.totalProtein, true),
        ];
      case TrendPeriod.month:
        final daily = appState.statistics.dailyTrend(
          endDate: now,
          days: 30,
          dailyGoal: goal,
        );
        return [
          for (var i = 0; i < daily.length; i++)
            _ChartPoint(
              '${daily[i].date.day}',
              daily[i].totalProtein,
              true,
              showLabel: i % 5 == 0 || i == daily.length - 1,
            ),
        ];
      case TrendPeriod.year:
        final monthly = appState.statistics.monthlyTrend(
          endDate: now,
          months: 12,
          dailyGoal: goal,
        );
        return [
          for (final m in monthly)
            _ChartPoint(l10n.formatShortMonth(m.month), m.averageProtein,
                m.anyDayLogged),
        ];
      case TrendPeriod.yearToDate:
        final monthly =
            appState.statistics.yearToDateTrend(endDate: now, dailyGoal: goal);
        return [
          for (final m in monthly)
            _ChartPoint(l10n.formatShortMonth(m.month), m.averageProtein,
                m.anyDayLogged),
        ];
    }
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ChartPoint {
  final String label;
  final double value;
  final bool hasData;
  final bool showLabel;

  const _ChartPoint(this.label, this.value, this.hasData,
      {this.showLabel = true});
}

class _EmptyChartState extends StatelessWidget {
  final String text;
  const _EmptyChartState({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        text,
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TrendLineChart extends StatelessWidget {
  final List<_ChartPoint> points;
  final double goal;
  final ThemeData theme;

  const _TrendLineChart({
    required this.points,
    required this.goal,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final values = points.map((p) => p.value).toList();
    final dataMax = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);
    final maxY = [dataMax, goal, 1.0].reduce((a, b) => a > b ? a : b) * 1.25;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(
          horizontalInterval: null,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: goal > 0
            ? ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y: goal,
                  color: theme.colorScheme.tertiary,
                  strokeWidth: 2,
                  dashArray: const [8, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: TextStyle(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    labelResolver: (line) => '${line.y.round()}g goal',
                  ),
                ),
              ])
            : const ExtraLinesData(),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: maxY <= 0 ? 1 : maxY / 4,
              getTitlesWidget: (value, meta) => Text(
                '${value.round()}',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= points.length || !points[i].showLabel) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[i].label,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final i = spot.x.round();
              final label = i >= 0 && i < points.length ? points[i].label : '';
              return LineTooltipItem(
                '$label\n${spot.y.round()}g',
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].value),
            ],
            isCurved: true,
            barWidth: 3,
            color: theme.colorScheme.primary,
            dotData: FlDotData(show: points.length <= 12),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
