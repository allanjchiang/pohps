import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../food_data.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../widgets/ingredient_picker_sheet.dart';

class CustomFoodScreen extends StatefulWidget {
  final FoodItem? existingFood;

  const CustomFoodScreen({super.key, this.existingFood});

  @override
  State<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends State<CustomFoodScreen> {
  final _nameController = TextEditingController();
  final _proteinController = TextEditingController();
  final _servingController = TextEditingController();
  final _ingredients = CustomIngredientList();
  String _selectedCategory = categoryOther;
  String _selectedEmoji = '🍓';

  bool get _isEditing => widget.existingFood != null;

  static const _emojiOptions = [
    '🍓', '🍹', '🥤', '🧋', '🍽️', '🥘', '🍲', '🥗', '🍛', '🥧',
    '🧆', '🥙', '🌮', '🌯', '🥪', '🫕', '🍝', '🍜', '🍱', '🥡',
    '🧁', '🥮', '🍰', '🫓', '🥞', '🧇', '🥣', '🍵',
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingFood;
    if (existing == null) return;

    _nameController.text = existing.name;
    _servingController.text = existing.servingSize;
    _selectedCategory = existing.category;
    _selectedEmoji = existing.emoji;

    if (existing.hasComponents) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final appState = context.read<AppState>();
        setState(() {
          _ingredients.loadFromComponents(existing.components!, appState);
        });
      });
    } else {
      final protein = existing.proteinGrams;
      _proteinController.text = protein == protein.roundToDouble()
          ? '${protein.round()}'
          : protein.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _proteinController.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCustomFood : l10n.createCustomFood),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                hintText:
                    imperial ? l10n.egServingSizeImperial : l10n.egServingSize,
              ),
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyLarge,
            ),
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
            const SizedBox(height: 36),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.saveFood),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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

  void _save() {
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
    List<CustomFoodComponent>? components;

    if (_ingredients.isEmpty) {
      final manualProtein = double.tryParse(_proteinController.text);
      if (manualProtein == null || manualProtein < 0) {
        _showError(l10n.addAtLeastOneIngredient);
        return;
      }
      protein = manualProtein;
      water = 0;
      components = null;
    } else {
      final totals = _ingredients.totals(
        diet: appState.dietType,
        waterTrackerEnabled: appState.waterTrackerEnabled,
      );
      protein = totals.proteinGrams;
      water = totals.waterMl;
      components = _ingredients.toComponents();
    }

    final food = FoodItem(
      id: widget.existingFood?.id ??
          'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _selectedCategory,
      proteinGrams: protein,
      waterMlPerServing: water,
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
