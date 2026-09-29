import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../widgets/iron_progress_ring.dart';
import '../widgets/progress_tracker_carousel.dart';
import '../widgets/swipeable_date_title.dart';
import '../widgets/food_reorder_list.dart';
import '../widgets/achievement_dialog.dart';
import '../widgets/patch_notes_dialog.dart';
import 'add_food_screen.dart';
import 'custom_food_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Pixels of scroll before the progress ring fully hides (higher = slower fade).
  static const _progressFadeDistance = 400.0;

  final _scrollController = ScrollController();
  final _progressCollapse = ValueNotifier<double>(0);
  bool _isReorderMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onFoodListScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPatchNotes();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onFoodListScroll);
    _scrollController.dispose();
    _progressCollapse.dispose();
    super.dispose();
  }

  void _onFoodListScroll() {
    final linear = (_scrollController.offset / _progressFadeDistance)
        .clamp(0.0, 1.0);
    // Ease-in keeps the ring visible longer at the start of the scroll.
    final collapse = Curves.easeInCubic.transform(linear);
    if (collapse != _progressCollapse.value) {
      _progressCollapse.value = collapse;
    }
  }

  /// Shown once after an app update, before any achievement popups.
  void _showPatchNotes() {
    if (!mounted) return;
    final appState = context.read<AppState>();
    final note = appState.pendingPatchNote;
    if (note == null) {
      _showPendingAchievements();
      return;
    }

    showDialog(
      context: context,
      builder: (_) => PatchNotesDialog(note: note),
    ).then((_) {
      appState.dismissPatchNotes();
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

  void _resetScrollForDateChange() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _progressCollapse.value = 0;
  }

  void _goToPreviousDay(AppState appState) {
    appState.goToPreviousDay();
    setState(() => _isReorderMode = false);
    _resetScrollForDateChange();
  }

  void _goToNextDay(AppState appState) {
    appState.goToNextDay();
    setState(() => _isReorderMode = false);
    _resetScrollForDateChange();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: SwipeableDateTitle(
          date: appState.viewDate,
          canGoForward: appState.canViewNextDay,
          onPreviousDay: () => _goToPreviousDay(appState),
          onNextDay: () => _goToNextDay(appState),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: l10n.statisticsTitle,
            iconSize: 26,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: l10n.achievementsTitle,
            iconSize: 26,
            onPressed: () => _showAchievementsSheet(context, appState),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            iconSize: 26,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const _PreciseScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ValueListenableBuilder<double>(
              valueListenable: _progressCollapse,
              builder: (context, collapse, _) => _CollapsibleProgressSection(
                collapse: collapse,
                appState: appState,
                l10n: l10n,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.foodsSectionTitle(
                        isToday: appState.isViewingToday,
                      ),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (appState.viewLog.isNotEmpty)
                    Text(
                      l10n.itemCount(appState.viewLog.length),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (appState.viewLog.length > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () =>
                        setState(() => _isReorderMode = !_isReorderMode),
                    icon: Icon(
                      _isReorderMode ? Icons.check : Icons.swap_vert,
                      size: 24,
                    ),
                    label: Text(
                      _isReorderMode
                          ? l10n.doneReordering
                          : l10n.reorderFoods,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (appState.viewLog.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(theme, l10n, appState.isViewingToday),
            )
          else if (_isReorderMode)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
              sliver: SliverToBoxAdapter(
                child: FoodReorderList(
                  entries: appState.viewLog
                      .map(
                        (entry) => FoodReorderEntry(
                          id: entry.id,
                          emoji: entry.food.emoji,
                          title: l10n.foodDisplayName(
                            entry.food.id,
                            entry.food.name,
                          ),
                          subtitle: entry.fraction == 1.0
                              ? l10n.servingDisplay(
                                  entry.food.servingSize,
                                  foodId: entry.food.isCustom
                                      ? null
                                      : entry.food.id,
                                  system: appState.measurementSystem,
                                )
                              : '${entry.fraction}× ${l10n.servingDisplay(
                                  entry.food.servingSize,
                                  foodId: entry.food.isCustom
                                      ? null
                                      : entry.food.id,
                                  system: appState.measurementSystem,
                                )}',
                        ),
                      )
                      .toList(),
                  onReorder: appState.reorderViewLog,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildFoodListItem(
                    theme,
                    appState,
                    l10n,
                    appState.viewLog[index],
                  ),
                  childCount: appState.viewLog.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_isReorderMode
          ? FloatingActionButton.extended(
              onPressed: () => _openAddFood(context),
              icon: const Icon(Icons.add, size: 28),
              label: Text(l10n.addFood, style: theme.textTheme.labelLarge),
            )
          : null,
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    AppLocalizations l10n,
    bool isViewingToday,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🥗', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            isViewingToday ? l10n.noFoodsLoggedYet : l10n.noFoodsLoggedOnDay,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tapAddFoodToStart,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodListItem(
    ThemeData theme,
    AppState appState,
    AppLocalizations l10n,
    LogEntry entry,
  ) {
    final displayName = l10n.foodDisplayName(entry.food.id, entry.food.name);
    final displayServing = l10n.servingDisplay(
      entry.food.servingSize,
      foodId: entry.food.isCustom ? null : entry.food.id,
      system: appState.measurementSystem,
    );
    final tile = Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        onTap: () => _showFractionPicker(context, appState, entry),
        leading: Text(entry.food.emoji, style: const TextStyle(fontSize: 32)),
        title: Text(displayName, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entry.fraction == 1.0
                  ? displayServing
                  : '${entry.fraction}× $displayServing',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            _LogTimeChip(
              time: entry.timestamp,
              onTap: () => _showTimePicker(context, appState, entry),
            ),
            if (appState.moodTrackerEnabled) ...[
              const SizedBox(height: 4),
              _MoodPicker(
                selected: entry.mood,
                // Tapping the selected face again clears the rating.
                onSelected: (mood) => appState.updateEntryMood(
                  entry.id,
                  mood == entry.mood ? null : mood,
                ),
              ),
            ],
          ],
        ),
        trailing: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '+${entry.totalProtein.round()}g',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (appState.waterTrackerEnabled && entry.totalWaterMl > 0)
                TextSpan(
                  text:
                      '\n${l10n.waterAmountLabel(entry.totalWaterMl, appState.measurementSystem)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1565C0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (appState.ironTrackerEnabled && entry.totalIronMg > 0)
                TextSpan(
                  text: '\n${l10n.ironAmountLabel(entry.totalIronMg)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: IronProgressRing.ironRedComplete,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          textAlign: TextAlign.end,
        ),
      ),
    );

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
                title: Text(l10n.removeFoodTitle),
                content: Text(l10n.removeFoodConfirm(displayName)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(l10n.remove),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) => appState.removeEntry(entry.id),
          child: tile,
        );
  }

  void _showFractionPicker(
      BuildContext context, AppState appState, LogEntry entry) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => _FractionPickerDialog(
        foodName: l10n.foodDisplayName(entry.food.id, entry.food.name),
        fullProtein: entry.food.proteinGrams,
        initialFraction: entry.fraction,
        onChanged: (fraction) {
          appState.updateEntryFraction(entry.id, fraction);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showTimePicker(
      BuildContext context, AppState appState, LogEntry entry) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _TimePickerSheet(
        foodName: l10n.foodDisplayName(entry.food.id, entry.food.name),
        initialTime: entry.timestamp,
        showRelativePresets: appState.isViewingToday,
        onChanged: (time) {
          appState.updateEntryTime(entry.id, time);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _openAddFood(BuildContext context) async {
    final appState = context.read<AppState>();
    final nav = Navigator.of(context);
    final result = await showAddFoodSheet(context, appState);
    if (!mounted) return;

    if (result == 'create_custom') {
      await nav.push(
        MaterialPageRoute(builder: (_) => const CustomFoodScreen()),
      );
    }

    if (mounted) _showPendingAchievements();
  }

  void _showAchievementsSheet(BuildContext context, AppState appState) {
    final l10n = AppLocalizations.of(context);
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
              Text(l10n.achievementsTitle,
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
                    l10n.achievementTitle(a.type.name, a.title),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    l10n.achievementDesc(a.type.name, a.description),
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

/// Requires a bit more finger movement per pixel scrolled for easier control.
class _PreciseScrollPhysics extends ClampingScrollPhysics {
  const _PreciseScrollPhysics({super.parent});

  static const _dragFactor = 0.72;

  @override
  _PreciseScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _PreciseScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset) * _dragFactor;
  }
}

/// Fades and collapses while the user scrolls Today's Foods.
class _CollapsibleProgressSection extends StatelessWidget {
  final double collapse;
  final AppState appState;
  final AppLocalizations l10n;

  const _CollapsibleProgressSection({
    required this.collapse,
    required this.appState,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final visibility = (1 - collapse).clamp(0.0, 1.0);

    return ClipRect(
      clipBehavior: visibility >= 1 ? Clip.none : Clip.hardEdge,
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: visibility,
        child: Opacity(
          opacity: visibility,
          child: IgnorePointer(
            ignoring: collapse > 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                ProgressTrackerCarousel(
                  proteinProgress: appState.viewProgressPercent,
                  proteinCurrent: appState.viewProtein,
                  proteinGoal: appState.dailyGoal.toDouble(),
                  proteinGoalReached: appState.viewGoalReached,
                  proteinGoalReachedText: l10n.goalReachedWellDone,
                  waterTrackerEnabled: appState.waterTrackerEnabled,
                  waterProgress: appState.viewWaterProgressPercent,
                  waterCurrentMl: appState.viewWaterMl,
                  waterGoalMl: appState.dailyWaterGoalMl.toDouble(),
                  measurementSystem: appState.measurementSystem,
                  waterGoalReached: appState.viewWaterGoalReached,
                  waterGoalReachedText: l10n.waterGoalReachedWellDone,
                  ironTrackerEnabled: appState.ironTrackerEnabled,
                  ironProgress: appState.viewIronProgressPercent,
                  ironCurrentMg: appState.viewIronMg,
                  ironGoalMg: appState.dailyIronGoalMg,
                  ironGoalReached: appState.viewIronGoalReached,
                  ironGoalReachedText: l10n.ironGoalReachedWellDone,
                ),
                if (appState.b12ReminderEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: CheckboxListTile(
                        value: appState.viewB12Taken,
                        onChanged: (taken) =>
                            appState.setViewB12Taken(taken ?? false),
                        secondary: const Text(
                          '💊',
                          style: TextStyle(fontSize: 26),
                        ),
                        title: Text(
                          l10n.b12Taken(isToday: appState.isViewingToday),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                if (appState.ironTrackerEnabled &&
                    appState.viewHasIronInhibitingDrink)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.ironTeaCoffeeTip,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    final l10n = AppLocalizations.of(context);
    final protein = (widget.fullProtein * _fraction);

    return AlertDialog(
      title: Text(l10n.howMuchFood(widget.foodName)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.gProtein(protein.toStringAsFixed(1)),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.percentOfServing((_fraction * 100).round()),
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
                  p == 1.0 ? l10n.full : '${(p * 100).round()}%',
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => widget.onChanged(_fraction),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Tappable time shown under the serving size; opens the time picker.
class _LogTimeChip extends StatelessWidget {
  final DateTime time;
  final VoidCallback onTap;

  const _LogTimeChip({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final use24Hour = MediaQuery.alwaysUse24HourFormatOf(context);
    final color = theme.colorScheme.onSecondaryContainer;

    return Tooltip(
      message: l10n.changeTimeTooltip,
      child: Material(
        color: theme.colorScheme.secondaryContainer,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  l10n.formatLogTime(time, use24Hour: use24Hour),
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
                const SizedBox(width: 4),
                Icon(Icons.edit, size: 14, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Optional one-tap food rating that sits on the card; never prompts.
class _MoodPicker extends StatelessWidget {
  final FoodMood? selected;
  final ValueChanged<FoodMood> onSelected;

  const _MoodPicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final mood in FoodMood.values)
          _moodButton(mood, l10n.moodLabel(mood)),
      ],
    );
  }

  Widget _moodButton(FoodMood mood, String label) {
    final isSelected = mood == selected;
    // Unrated faces stay visible enough to invite a tap; once rated, the
    // choice stands out and the others fade back.
    final opacity = isSelected ? 1.0 : (selected == null ? 0.55 : 0.3);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkResponse(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelected(mood);
        },
        radius: 22,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 180),
                child: Image.asset(mood.assetPath, width: 28, height: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One tap on a preset saves immediately; the wheel covers any other time.
class _TimePickerSheet extends StatefulWidget {
  final String foodName;
  final DateTime initialTime;
  final bool showRelativePresets;
  final ValueChanged<DateTime> onChanged;

  const _TimePickerSheet({
    required this.foodName,
    required this.initialTime,
    required this.showRelativePresets,
    required this.onChanged,
  });

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  static const _minutesAgoPresets = [15, 30, 60, 120];

  late DateTime _time = widget.initialTime;

  /// Keeps the entry's date and only swaps the time of day.
  DateTime _atTimeOfDay(int hour, int minute) {
    final t = widget.initialTime;
    return DateTime(t.year, t.month, t.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final use24Hour = MediaQuery.alwaysUse24HourFormatOf(context);

    Widget preset(String label, DateTime Function() time) => ActionChip(
          label: Text(label, style: const TextStyle(fontSize: 16)),
          onPressed: () => widget.onChanged(time()),
        );

    // Shrink the wheel on short screens (small phones, landscape) so the
    // whole sheet fits without scrolling where possible.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final wheelHeight = (screenHeight * 0.22).clamp(120.0, 200.0);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.whenDidYouEat(widget.foodName),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (widget.showRelativePresets) ...[
                  preset(l10n.justNow, DateTime.now),
                  for (final m in _minutesAgoPresets)
                    preset(
                      l10n.minutesAgo(m),
                      () => DateTime.now().subtract(Duration(minutes: m)),
                    ),
                ],
                preset(l10n.breakfast, () => _atTimeOfDay(8, 0)),
                preset(l10n.lunch, () => _atTimeOfDay(12, 0)),
                preset(l10n.dinner, () => _atTimeOfDay(18, 0)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: wheelHeight,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: theme.brightness,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: theme.textTheme.headlineSmall,
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: widget.initialTime,
                  use24hFormat: use24Hour,
                  onDateTimeChanged: (t) => _time = t,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () =>
                  widget.onChanged(_atTimeOfDay(_time.hour, _time.minute)),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              child: Text(l10n.save, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
