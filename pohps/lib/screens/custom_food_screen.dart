import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../data/nutrient_limits.dart';
import '../food_data.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../widgets/ingredient_picker_sheet.dart';
import '../widgets/calcium_progress_ring.dart';
import '../widgets/iron_progress_ring.dart';

/// Asks before deleting a custom food, then offers undo in a snackbar.
/// Returns whether it was deleted. Logged entries keep their own copy of the
/// food, so past days are unaffected.
Future<bool> confirmDeleteCustomFood(BuildContext context, FoodItem food) async {
  final l10n = AppLocalizations.of(context);
  final appState = context.read<AppState>();
  final messenger = ScaffoldMessenger.of(context);
  final name = l10n.foodDisplayName(food.id, food.name);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteCustomFoodTitle),
      content: Text(l10n.deleteConfirm(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  final index = appState.customFoods.indexWhere((f) => f.id == food.id);
  final favoriteIndex = appState.favoriteFoodIds.indexOf(food.id);
  final saved = index >= 0 ? appState.customFoods[index] : food;
  await appState.removeCustomFood(food.id);
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.foodDeleted(name),
          style: const TextStyle(fontSize: 16)),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () => appState.restoreCustomFood(
          saved,
          index: index,
          favoriteIndex: favoriteIndex,
        ),
      ),
    ),
  );
  return true;
}

class CustomFoodScreen extends StatefulWidget {
  final FoodItem? existingFood;

  const CustomFoodScreen({super.key, this.existingFood});

  @override
  State<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends State<CustomFoodScreen> {
  final _nameController = TextEditingController();
  final _proteinController = TextEditingController();
  final _ironController = TextEditingController();
  final _calciumController = TextEditingController();
  final _servingController = TextEditingController();
  final _ingredients = CustomIngredientList();
  String _selectedCategory = categoryOther;
  String _selectedEmoji = '🍓';
  bool _isSupplement = false;

  bool get _isEditing => widget.existingFood != null;

  /// The form as last saved (or as opened), to tell whether leaving would
  /// lose anything. Null while an existing food's ingredients are loading.
  String? _savedSnapshot;
  bool _showedUnsaved = false;

  String _snapshot() => [
        _selectedEmoji,
        _isSupplement,
        _selectedCategory,
        _nameController.text.trim(),
        _servingController.text.trim(),
        _proteinController.text,
        _ironController.text,
        _calciumController.text,
        for (final c in _ingredients.toComponents())
          '${c.sourceFoodId}:${c.fraction}',
      ].join('|');

  bool get _hasUnsavedChanges =>
      _savedSnapshot != null && _snapshot() != _savedSnapshot;

  /// Text edits don't rebuild on their own; rebuild when typing flips the
  /// unsaved state so the back-button guard stays current.
  void _onFieldChanged() {
    if (_hasUnsavedChanges != _showedUnsaved) setState(() {});
  }

  static const _emojiOptions = [
    '🍓', '🍹', '🥘', '🍲', '🥗', '🍛', '🥧',
    '🧆', '🥙', '🌮', '🌯', '🥪', '🫕', '🍝', '🍜', '🍱', '🥡',
    '🥮', '🫓',
    '🍫', '🍕', '🥟', '🍗', '🐟', '🥩', '☕', '💊',
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController,
      _servingController,
      _proteinController,
      _ironController,
      _calciumController,
    ]) {
      controller.addListener(_onFieldChanged);
    }
    final existing = widget.existingFood;
    if (existing == null) {
      _savedSnapshot = _snapshot();
      return;
    }

    _nameController.text = existing.name;
    _servingController.text = existing.servingSize;
    _isSupplement = isSupplement(existing);
    if (!_isSupplement) _selectedCategory = existing.category;
    _selectedEmoji = existing.emoji;

    if (existing.hasComponents) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final appState = context.read<AppState>();
        setState(() {
          _ingredients.loadFromComponents(existing.components!, appState);
          _savedSnapshot = _snapshot();
        });
      });
    } else {
      final protein = existing.proteinGrams;
      _proteinController.text = protein == protein.roundToDouble()
          ? '${protein.round()}'
          : protein.toStringAsFixed(1);
      if (existing.ironMg > 0) {
        _ironController.text = existing.ironMg.toStringAsFixed(1);
      }
      if (existing.calciumMg > 0) {
        _calciumController.text = '${existing.calciumMg.round()}';
      }
      _savedSnapshot = _snapshot();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _proteinController.dispose();
    _ironController.dispose();
    _calciumController.dispose();
    _servingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final imperial = appState.measurementSystem == MeasurementSystem.imperial;
    final totals = _ingredients.isEmpty
        ? null
        : _ingredients.totals(
            diet: appState.dietType,
            waterTrackerEnabled: appState.waterTrackerEnabled,
          );

    _showedUnsaved = _hasUnsavedChanges;

    return PopScope(
      canPop: !_showedUnsaved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? l10n.editCustomFood : l10n.createCustomFood),
          actions: [
            if (_isEditing)
              IconButton(
                tooltip: l10n.deleteFood,
                icon: const Icon(Icons.delete_outline),
                onPressed: _delete,
              ),
            TextButton(onPressed: _save, child: Text(l10n.save)),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(l10n.foodKind)),
                  ButtonSegment(value: true, label: Text(l10n.supplementKind)),
                ],
                selected: {_isSupplement},
                onSelectionChanged: (selection) =>
                    _setSupplement(selection.first),
                showSelectedIcon: false,
              ),
              const SizedBox(height: 28),
              Text(l10n.chooseAnIcon, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _emojiOptions.map((emoji) {
                  final selected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                            ? Border.all(
                                color: theme.colorScheme.primary, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              Text(l10n.foodName, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: l10n.egFoodName),
                textCapitalization: TextCapitalization.words,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Text(l10n.servingSizeLabel, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _servingController,
                decoration: InputDecoration(
                  hintText: _isSupplement
                      ? l10n.egSupplementServing
                      : imperial
                          ? l10n.egServingSizeImperial
                          : l10n.egServingSize,
                ),
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.bodyLarge,
              ),
              if (_isSupplement) ...[
                const SizedBox(height: 28),
                Text(
                  l10n.supplementLabelHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _mgField(_ironController, l10n.ironPerServing, l10n.egIron),
                const SizedBox(height: 12),
                _mgField(
                    _calciumController, l10n.calciumPerServing, l10n.egCalcium),
              ] else ...[
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.ingredientsLabel,
                          style: theme.textTheme.titleMedium),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _addIngredient(appState),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addIngredient),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.buildFromIngredients,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (_ingredients.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.noIngredientsYet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(_ingredients.entries.length, (index) {
                    final entry = _ingredients.entries[index];
                    return _IngredientCard(
                      entry: entry,
                      appState: appState,
                      onFractionChanged: (value) {
                        setState(() => entry.fraction = value);
                      },
                      onRemove: () {
                        setState(() => _ingredients.removeAt(index));
                      },
                    );
                  }),
                if (totals != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.combinedTotals,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.gProtein(totals.proteinGrams.toStringAsFixed(1)),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (appState.waterTrackerEnabled &&
                              totals.waterMl > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.waterAmountLabel(
                                totals.waterMl,
                                appState.measurementSystem,
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF1565C0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (appState.ironTrackerEnabled &&
                              totals.ironMg > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.ironAmountLabel(totals.ironMg),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: IronProgressRing.ironRedComplete,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (appState.calciumTrackerEnabled &&
                              totals.calciumMg > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.calciumAmountLabel(totals.calciumMg),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: CalciumProgressRing.calciumVioletComplete,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                if (_ingredients.isEmpty) ...[
                  const SizedBox(height: 28),
                  Text(
                    l10n.orEnterProteinManually,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _proteinController,
                    decoration: InputDecoration(
                      hintText: l10n.egProtein,
                      suffixText: l10n.grams,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (appState.ironTrackerEnabled) ...[
                    const SizedBox(height: 12),
                    _mgField(_ironController, l10n.ironOptional, l10n.egIron),
                  ],
                  if (appState.calciumTrackerEnabled) ...[
                    const SizedBox(height: 12),
                    _mgField(
                        _calciumController, l10n.calciumOptional, l10n.egCalcium),
                  ],
                ],
                const SizedBox(height: 28),
                Text(l10n.categoryLabel, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final selected = cat == _selectedCategory;
                    return ChoiceChip(
                      label: Text(l10n.categoryName(cat)),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 36),
              FilledButton(
                onPressed: _save,
                child: Text(l10n.saveFood),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _delete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.deleteFood),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final deleted =
        await confirmDeleteCustomFood(context, widget.existingFood!);
    if (deleted && mounted) Navigator.pop(context, true);
  }

  /// Back was pressed with unsaved changes: save, discard, or stay.
  Future<void> _confirmLeave() async {
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.unsavedFoodTitle),
        content: Text(l10n.unsavedFoodBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.discard),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (!mounted || choice == null) return;
    if (choice) {
      await _save();
    } else {
      Navigator.pop(context);
    }
  }

  void _setSupplement(bool value) {
    setState(() {
      _isSupplement = value;
      if (value && _selectedEmoji == '🍓') _selectedEmoji = '💊';
      if (!value && _selectedEmoji == '💊') _selectedEmoji = '🍓';
    });
  }

  Widget _mgField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: 'mg',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  /// Asks whether an unusually high per-serving amount is really the weight
  /// of the whole compound. Returns true to keep the value as entered.
  Future<bool> _confirmPlausible(String message) async {
    final l10n = AppLocalizations.of(context);
    final keep = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.compoundWeightTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.itsCorrect),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.changeIt),
          ),
        ],
      ),
    );
    return keep ?? false;
  }

  Future<void> _addIngredient(AppState appState) async {
    await showIngredientPickerSheet(
      context,
      appState,
      onIngredientSelected: (food) {
        if (!mounted) return;
        setState(() => _ingredients.add(food));
      },
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final appState = context.read<AppState>();
    final name = _nameController.text.trim();
    final serving = _servingController.text.trim();

    if (name.isEmpty) {
      _showError(l10n.enterFoodName);
      return;
    }
    if (serving.isEmpty) {
      _showError(l10n.enterServingSize);
      return;
    }

    double protein;
    double water;
    double iron;
    double calcium;
    List<CustomFoodComponent>? components;

    if (_isSupplement) {
      protein = 0;
      water = 0;
      iron = double.tryParse(_ironController.text) ?? 0;
      calcium = double.tryParse(_calciumController.text) ?? 0;
      components = null;
      if (iron <= 0 && calcium <= 0) {
        _showError(l10n.enterSupplementAmount);
        return;
      }
    } else if (_ingredients.isEmpty) {
      final manualProtein = double.tryParse(_proteinController.text);
      if (manualProtein == null || manualProtein < 0) {
        _showError(l10n.addAtLeastOneIngredient);
        return;
      }
      protein = manualProtein;
      water = 0;
      // Keep the saved value when iron fields are hidden (tracker off).
      iron = appState.ironTrackerEnabled
          ? double.tryParse(_ironController.text) ?? 0
          : widget.existingFood?.ironMg ?? 0;
      calcium = appState.calciumTrackerEnabled
          ? double.tryParse(_calciumController.text) ?? 0
          : widget.existingFood?.calciumMg ?? 0;
      components = null;
    } else {
      final totals = _ingredients.totals(
        diet: appState.dietType,
        waterTrackerEnabled: appState.waterTrackerEnabled,
      );
      protein = totals.proteinGrams;
      water = totals.waterMl;
      iron = totals.ironMg;
      calcium = totals.calciumMg;
      components = _ingredients.toComponents();
    }

    // Typed-in amounts only: totals from ingredients come from food data.
    if (components == null) {
      if (iron > maxPlausibleIronPerTabletMg &&
          !await _confirmPlausible(l10n.ironCompoundWeightCheck(iron))) {
        return;
      }
      if (calcium > maxPlausibleCalciumPerTabletMg &&
          !await _confirmPlausible(l10n.calciumCompoundWeightCheck(calcium))) {
        return;
      }
      if (!mounted) return;
    }

    final food = FoodItem(
      id: widget.existingFood?.id ??
          'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _isSupplement ? categorySupplements : _selectedCategory,
      proteinGrams: protein,
      waterMlPerServing: water,
      ironMg: iron,
      calciumMg: calcium,
      servingSize: serving,
      emoji: _selectedEmoji,
      isCustom: true,
      components: components,
    );

    if (_isEditing) {
      appState.updateCustomFood(food);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.foodUpdated(name),
              style: const TextStyle(fontSize: 16)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      appState.addCustomFood(food);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.foodCreated(name),
              style: const TextStyle(fontSize: 16)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    Navigator.pop(context, true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(fontSize: 16))),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final IngredientEntry entry;
  final AppState appState;
  final ValueChanged<double> onFractionChanged;
  final VoidCallback onRemove;

  const _IngredientCard({
    required this.entry,
    required this.appState,
    required this.onFractionChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final food = entry.food;
    final protein = food.proteinGrams * entry.fraction;
    final water = food.waterMlPerServing * entry.fraction;
    final iron = food.ironMg * entry.fraction;
    final calcium = food.calciumMg * entry.fraction;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.foodDisplayName(food.id, food.name),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        l10n.servingDisplay(
                          food.servingSize,
                          foodId: food.id,
                          system: appState.measurementSystem,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.gProtein(protein.toStringAsFixed(1)),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (appState.waterTrackerEnabled && water > 0)
                        Text(
                          l10n.waterAmountLabel(
                            water,
                            appState.measurementSystem,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF1565C0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (appState.ironTrackerEnabled && iron > 0)
                        Text(
                          l10n.ironAmountLabel(iron),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: IronProgressRing.ironRedComplete,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (appState.calciumTrackerEnabled && calcium > 0)
                        Text(
                          l10n.calciumAmountLabel(calcium),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: CalciumProgressRing.calciumVioletComplete,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.removeIngredient,
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            IngredientFractionEditor(
              fraction: entry.fraction,
              onChanged: onFractionChanged,
            ),
          ],
        ),
      ),
    );
  }
}
