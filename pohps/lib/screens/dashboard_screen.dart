import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets/progress_ring.dart';
import '../widgets/achievement_dialog.dart';
import 'add_food_screen.dart';
import 'custom_food_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingAchievements();
    });
  }

  void _showPendingAchievements() {
    if (!mounted) return;
    final appState = context.read<AppState>();
    final achievement = appState.pendingAchievement;
    if (achievement == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AchievementDialog(
        achievement: achievement,
        onDismiss: () {
          Navigator.pop(ctx);
          appState.dismissAchievement();
          Future.microtask(() => _showPendingAchievements());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'POHPS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Achievements',
            iconSize: 26,
            onPressed: () => _showAchievementsSheet(context, appState),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            iconSize: 26,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ProgressRing(
            progress: appState.progressPercent,
            current: appState.todayProtein,
            goal: appState.dailyGoal.toDouble(),
          ),
          if (appState.goalReached)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Goal reached! Well done!',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text("Today's Foods", style: theme.textTheme.titleLarge),
                const Spacer(),
                if (appState.todayLog.isNotEmpty)
                  Text(
                    '${appState.todayLog.length} item${appState.todayLog.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: appState.todayLog.isEmpty
                ? _buildEmptyState(theme)
                : _buildFoodList(theme, appState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddFood(context),
        icon: const Icon(Icons.add, size: 28),
        label: Text('Add Food', style: theme.textTheme.labelLarge),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🥗', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'No foods logged yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + Add Food to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(ThemeData theme, AppState appState) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: appState.todayLog.length,
      itemBuilder: (context, index) {
        final entry = appState.todayLog[index];
        return Dismissible(
          key: Key(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.delete_outline,
                color: theme.colorScheme.onErrorContainer, size: 28),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Remove Food?'),
                content:
                    Text('Remove ${entry.food.name} from today\'s log?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) => appState.removeEntry(entry.id),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onTap: () => _showFractionPicker(context, appState, entry),
              leading:
                  Text(entry.food.emoji, style: const TextStyle(fontSize: 32)),
              title: Text(entry.food.name, style: theme.textTheme.titleMedium),
              subtitle: Text(
                entry.fraction == 1.0
                    ? entry.food.servingSize
                    : '${entry.fraction}× ${entry.food.servingSize}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Text(
                '+${entry.totalProtein.round()}g',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFractionPicker(
      BuildContext context, AppState appState, LogEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => _FractionPickerDialog(
        foodName: entry.food.name,
        fullProtein: entry.food.proteinGrams,
        initialFraction: entry.fraction,
        onChanged: (fraction) {
          appState.updateEntryFraction(entry.id, fraction);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _openAddFood(BuildContext context) async {
    final appState = context.read<AppState>();
    final nav = Navigator.of(context);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: appState,
        child: const AddFoodSheet(),
      ),
    );
    if (!mounted) return;

    if (result == 'create_custom') {
      await nav.push(
        MaterialPageRoute(builder: (_) => const CustomFoodScreen()),
      );
    }

    if (mounted) _showPendingAchievements();
  }

  void _showAchievementsSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Achievements',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...allAchievements.map((a) {
                final unlocked =
                    appState.unlockedAchievements.contains(a.type.name);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(
                    unlocked ? a.emoji : '🔒',
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    a.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    a.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  ThemeData get theme => Theme.of(context);
}

class _FractionPickerDialog extends StatefulWidget {
  final String foodName;
  final double fullProtein;
  final double initialFraction;
  final ValueChanged<double> onChanged;

  const _FractionPickerDialog({
    required this.foodName,
    required this.fullProtein,
    required this.initialFraction,
    required this.onChanged,
  });

  @override
  State<_FractionPickerDialog> createState() => _FractionPickerDialogState();
}

class _FractionPickerDialogState extends State<_FractionPickerDialog> {
  late double _fraction;

  static const _presets = [0.25, 0.5, 0.75, 1.0];

  @override
  void initState() {
    super.initState();
    _fraction = widget.initialFraction;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final protein = (widget.fullProtein * _fraction);

    return AlertDialog(
      title: Text('How much ${widget.foodName}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${protein.toStringAsFixed(1)}g protein',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(_fraction * 100).round()}% of a full serving',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _presets.map((p) {
              final selected = (_fraction - p).abs() < 0.01;
              return ChoiceChip(
                label: Text(
                  p == 1.0 ? 'Full' : '${(p * 100).round()}%',
                  style: const TextStyle(fontSize: 16),
                ),
                selected: selected,
                onSelected: (_) => setState(() => _fraction = p),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('0%'),
              Expanded(
                child: Slider(
                  value: _fraction,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  label: '${(_fraction * 100).round()}%',
                  onChanged: (v) => setState(() => _fraction = v),
                ),
              ),
              const Text('100%'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => widget.onChanged(_fraction),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
