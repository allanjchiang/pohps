import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Protein goal
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Protein Goal',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${appState.dailyGoal}g',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.tonal(
                        onPressed: () => _editGoal(context, appState),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Appearance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Auto'),
                        icon: Icon(Icons.brightness_auto),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                    selected: {appState.themeMode},
                    onSelectionChanged: (modes) {
                      appState.setThemeMode(modes.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Custom foods
          if (appState.customFoods.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Custom Foods',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...appState.customFoods.map((food) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(food.emoji,
                              style: const TextStyle(fontSize: 28)),
                          title: Text(food.name,
                              style: theme.textTheme.titleMedium),
                          subtitle: Text(
                              '${food.proteinGrams.round()}g · ${food.servingSize}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: theme.colorScheme.error),
                            iconSize: 26,
                            onPressed: () =>
                                _confirmDelete(context, appState, food),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // About
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About POHPS', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    'A free, open-source protein tracking app designed for elderly lacto-ovo vegetarians.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• No ads, no paywalls, no data collection\n'
                    '• All data stored locally on your device\n'
                    '• Protein values are estimates — always consult your dietitian',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _editGoal(BuildContext context, AppState appState) {
    final controller =
        TextEditingController(text: appState.dailyGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Protein Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Grams per day',
            suffixText: 'g',
          ),
          autofocus: true,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                appState.setDailyGoal(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppState appState, FoodItem food) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Custom Food?'),
        content: Text('Are you sure you want to delete "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              appState.removeCustomFood(food.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
