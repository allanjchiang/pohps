import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final _controller = TextEditingController();
  bool _water = true;
  bool _iron = true;
  bool _calcium = true;
  bool _b12 = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('🎯', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                l10n.setYourDailyGoal,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.howManyGramsOfProtein,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
                decoration: InputDecoration(
                  hintText: l10n.egGoal,
                  suffixText: l10n.grams,
                  suffixStyle: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.canChangeLater,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.alsoTrack, style: theme.textTheme.titleMedium),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.waterTracker),
                value: _water,
                onChanged: (v) => setState(() => _water = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.ironTracker),
                value: _iron,
                onChanged: (v) => setState(() => _iron = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.calciumTracker),
                value: _calcium,
                onChanged: (v) => setState(() => _calcium = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.b12Reminder),
                value: _b12,
                onChanged: (v) => setState(() => _b12 = v ?? false),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _submit, child: Text(l10n.startTracking)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final value = int.tryParse(_controller.text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidGoalMessage),
        ),
      );
      return;
    }
    final appState = context.read<AppState>();
    // Save trackers before the goal: setting the goal swaps this screen for
    // the dashboard.
    await appState.setWaterTrackerEnabled(_water);
    await appState.setIronTrackerEnabled(_iron);
    await appState.setCalciumTrackerEnabled(_calcium);
    await appState.setB12ReminderEnabled(_b12);
    await appState.setDailyGoal(value);
  }
}
