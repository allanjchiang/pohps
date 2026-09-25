import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/statistics_export_service.dart';
import '../widgets/protein_calendar_heatmap.dart';
import '../widgets/protein_trend_chart.dart';

/// Statistics: trend chart, goal calendar, and Excel export. Free for everyone.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle)),
      body: _StatisticsBody(appState: appState),
    );
  }
}

class _StatisticsBody extends StatefulWidget {
  final AppState appState;
  const _StatisticsBody({required this.appState});

  @override
  State<_StatisticsBody> createState() => _StatisticsBodyState();
}

class _StatisticsBodyState extends State<_StatisticsBody> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appState = widget.appState;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 40 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ProteinTrendChart(appState: appState),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ProteinCalendarHeatmap(appState: appState),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed:
                _exporting ? null : () => _exportStatistics(context, appState, l10n),
            icon: _exporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.ios_share),
            label: Text(l10n.exportStatisticsButton),
          ),
        ],
      ),
    );
  }

  Future<void> _exportStatistics(
      BuildContext context, AppState appState, AppLocalizations l10n) async {
    setState(() => _exporting = true);
    try {
      final points = appState.statistics.fullHistory(appState.dailyGoal);
      if (points.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noStatisticsYet,
                style: const TextStyle(fontSize: 16)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await StatisticsExportService.exportDailySummaries(
        points,
        dateHeader: l10n.exportDateHeader,
        proteinHeader: l10n.exportProteinHeader,
        goalHeader: l10n.exportGoalHeader,
        goalMetHeader: l10n.exportGoalMetHeader,
        yes: l10n.exportYes,
        no: l10n.exportNo,
        dailyGoal: appState.dailyGoal,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.exportSuccessMessage,
              style: const TextStyle(fontSize: 16)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.exportFailedMessage,
              style: const TextStyle(fontSize: 16)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}
