import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
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
                  Text(l10n.dailyProteinGoal,
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
                        child: Text(l10n.change),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Language
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.language, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _languageChip(
                        context,
                        label: l10n.languageSystem,
                        locale: null,
                        current: appState.locale,
                        appState: appState,
                      ),
                      _languageChip(
                        context,
                        label: 'English',
                        locale: const Locale('en'),
                        current: appState.locale,
                        appState: appState,
                      ),
                      _languageChip(
                        context,
                        label: '繁體中文',
                        locale: const Locale('zh', 'TW'),
                        current: appState.locale,
                        appState: appState,
                      ),
                      _languageChip(
                        context,
                        label: '简体中文',
                        locale: const Locale('zh', 'CN'),
                        current: appState.locale,
                        appState: appState,
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
                  Text(l10n.appearance, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l10n.themeAuto),
                        icon: const Icon(Icons.brightness_auto),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l10n.themeLight),
                        icon: const Icon(Icons.light_mode),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l10n.themeDark),
                        icon: const Icon(Icons.dark_mode),
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
                    Text(l10n.myCustomFoods,
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
                  Text(l10n.aboutPohps, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    l10n.aboutDescription,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.aboutBullets,
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

  Widget _languageChip(
    BuildContext context, {
    required String label,
    required Locale? locale,
    required Locale? current,
    required AppState appState,
  }) {
    final selected = locale == current;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => appState.setLocale(locale),
    );
  }

  void _editGoal(BuildContext context, AppState appState) {
    final l10n = AppLocalizations.of(context);
    final controller =
        TextEditingController(text: appState.dailyGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.changeProteinGoal),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: l10n.gramsPerDay,
            suffixText: 'g',
          ),
          autofocus: true,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                appState.setDailyGoal(value);
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppState appState, FoodItem food) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCustomFoodTitle),
        content: Text(l10n.deleteConfirm(food.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              appState.removeCustomFood(food.id);
              Navigator.pop(ctx);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
