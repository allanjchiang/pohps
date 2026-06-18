import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services/backup_service.dart';

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

          // Water tracker
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.waterTracker, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    l10n.waterTrackerHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.waterTracker),
                    value: appState.waterTrackerEnabled,
                    activeThumbColor: const Color(0xFF42A5F5),
                    onChanged: appState.setWaterTrackerEnabled,
                  ),
                  if (appState.waterTrackerEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          l10n.formatWaterVolume(
                            appState.dailyWaterGoalMl.toDouble(),
                            appState.measurementSystem,
                          ),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF1565C0),
                          ),
                        ),
                        const Spacer(),
                        FilledButton.tonal(
                          onPressed: () => _editWaterGoal(context, appState),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            foregroundColor: const Color(0xFF1565C0),
                          ),
                          child: Text(l10n.change),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Diet
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.diet, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dietHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<DietType>(
                    groupValue: appState.dietType,
                    onChanged: (diet) {
                      if (diet != null) appState.setDietType(diet);
                    },
                    child: Column(
                      children: [
                        RadioListTile<DietType>(
                          title: Text(l10n.dietLactoOvo),
                          value: DietType.lactoOvo,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<DietType>(
                          title: Text(l10n.dietVegan),
                          value: DietType.vegan,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<DietType>(
                          title: Text(l10n.dietAlliumVegetarian),
                          value: DietType.alliumVegetarian,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<DietType>(
                          title: Text(l10n.dietAlliumVegan),
                          value: DietType.alliumVegan,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
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

          // Measurements
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.measurements, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    l10n.measurementImperialHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<MeasurementSystem>(
                    segments: [
                      ButtonSegment(
                        value: MeasurementSystem.metric,
                        label: Text(l10n.measurementMetric),
                      ),
                      ButtonSegment(
                        value: MeasurementSystem.imperial,
                        label: Text(l10n.measurementImperial),
                      ),
                    ],
                    selected: {appState.measurementSystem},
                    onSelectionChanged: (systems) {
                      appState.setMeasurementSystem(systems.first);
                    },
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
                          title: Text(
                            l10n.foodDisplayName(food.id, food.name),
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            '${food.proteinGrams.toStringAsFixed(food.proteinGrams == food.proteinGrams.roundToDouble() ? 0 : 1)}g · ${l10n.servingDisplay(food.servingSize, foodId: food.id, system: appState.measurementSystem)}',
                          ),
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

          // Backup
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.yourData, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    l10n.backupPrivacyHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.backupIncludesHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.upload_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    title: Text(
                      l10n.exportData,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(l10n.exportDataHint),
                    onTap: () => _exportData(context, appState),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.download_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    title: Text(
                      l10n.importData,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(l10n.importDataHint),
                    onTap: () => _importData(context, appState),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

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

  void _editWaterGoal(BuildContext context, AppState appState) {
    final l10n = AppLocalizations.of(context);
    final controller =
        TextEditingController(text: appState.dailyWaterGoalMl.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.changeWaterGoal),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: l10n.mlPerDay,
            suffixText: 'ml',
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
                appState.setDailyWaterGoalMl(value);
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, AppState appState) async {
    final l10n = AppLocalizations.of(context);
    try {
      final json = appState.exportBackupJson();
      await BackupService.shareBackup(json);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupExported,
              style: const TextStyle(fontSize: 16)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupExportFailed,
              style: const TextStyle(fontSize: 16)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _importData(BuildContext context, AppState appState) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importBackupTitle),
        content: Text(l10n.importBackupMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.importBackupConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final json = await BackupService.pickAndReadBackup();
      if (json == null) return;
      await appState.importBackupJson(json);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupImported,
              style: const TextStyle(fontSize: 16)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupImportFailed,
              style: const TextStyle(fontSize: 16)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
