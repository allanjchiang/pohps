import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                'Set Your Daily Goal',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'How many grams of protein did\nyour dietitian prescribe per day?',
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
                  hintText: 'e.g. 60',
                  suffixText: 'grams',
                  suffixStyle: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You can change this later in Settings.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 36),
              FilledButton(
                onPressed: _submit,
                child: const Text('Start Tracking'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid protein goal in grams.'),
        ),
      );
      return;
    }
    context.read<AppState>().setDailyGoal(value);
  }
}
