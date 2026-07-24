import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/statistics_export_service.dart';
import '../widgets/protein_calendar_heatmap.dart';
import '../widgets/protein_trend_chart.dart';
import 'paywall_screen.dart';

/// Entry point for POHPS Pro Statistics. Shows the trend chart, calendar,
/// and Excel export when the user has access (trial or subscribed);
/// otherwise embeds the paywall offer directly, so there's no extra
/// navigation hop between "locked" and "here's how to unlock it."
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle)),
      body: appState.hasStatisticsAccess
          ? _StatisticsBody(appState: appState)
          : PaywallScreen(appState: appState, embedded: true),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final appState = widget.appState;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 40 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (appState.isTrialActive) ...[
            _buildTrialBanner(context, theme, l10n, appState),
            const SizedBox(height: 16),
          ],
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

  Widget _buildTrialBanner(BuildContext context, ThemeData theme,
      AppLocalizations l10n, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top,
              color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.trialDaysRemainingMessage(appState.trialDaysRemaining),
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaywallScreen(appState: appState),
              ),
            ),
            child: Text(l10n.upgradeNow),
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
