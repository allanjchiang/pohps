import 'package:flutter/material.dart';
import '../app_state.dart';
import '../food_data.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';

Future<void> showIngredientPickerSheet(
  BuildContext context,
  AppState appState, {
  required ValueChanged<FoodItem> onIngredientSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _IngredientPickerSheet(
      appState: appState,
      onIngredientSelected: onIngredientSelected,
    ),
  );
}

class _IngredientPickerSheet extends StatefulWidget {
  final AppState appState;
  final ValueChanged<FoodItem> onIngredientSelected;

  const _IngredientPickerSheet({
    required this.appState,
    required this.onIngredientSelected,
  });

  @override
  State<_IngredientPickerSheet> createState() => _IngredientPickerSheetState();
}

class _IngredientPickerSheetState extends State<_IngredientPickerSheet> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final appState = widget.appState;
    final foods = appState.baseFoods;

    final categories = [
      'All',
      ...categoriesForPicker(waterTrackerEnabled: appState.waterTrackerEnabled),
    ];

    final filtered = _selectedCategory == 'All'
        ? foods
        : foods.where((f) => f.category == _selectedCategory).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                l10n.pickIngredient,
                style: theme.textTheme.titleLarge,
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final selected = cat == _selectedCategory;
                  final label = cat == 'All'
                      ? l10n.allCategory
                      : l10n.categoryName(cat);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label, style: const TextStyle(fontSize: 14)),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noFoodsInCategory,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16 + MediaQuery.viewPaddingOf(context).bottom,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final food = filtered[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Text(
                              food.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                            title: Text(
                              l10n.foodDisplayName(food.id, food.name),
                            ),
                            subtitle: Text(
                              '${l10n.gProtein('${food.proteinGrams.round()}')} · ${l10n.servingDisplay(food.servingSize, foodId: food.id, system: appState.measurementSystem)}',
                            ),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () => widget.onIngredientSelected(food),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Preset chips + slider for adjusting an ingredient serving fraction.
class IngredientFractionEditor extends StatelessWidget {
  final double fraction;
  final ValueChanged<double> onChanged;

  const IngredientFractionEditor({
    super.key,
    required this.fraction,
    required this.onChanged,
  });

  static const _presets = [0.25, 0.5, 0.75, 1.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets.map((preset) {
            final selected = (fraction - preset).abs() < 0.01;
            return ChoiceChip(
              label: Text(
                preset == 1.0 ? l10n.full : '${(preset * 100).round()}%',
                style: const TextStyle(fontSize: 15),
              ),
              selected: selected,
              onSelected: (_) => onChanged(preset),
            );
          }).toList(),
        ),
        Row(
          children: [
            Text('0%', style: theme.textTheme.bodySmall),
            Expanded(
              child: Slider(
                value: fraction.clamp(0.0, 1.0),
                min: 0.0,
                max: 1.0,
                divisions: 20,
                label: '${(fraction * 100).round()}%',
                onChanged: onChanged,
              ),
            ),
            Text('100%', style: theme.textTheme.bodySmall),
          ],
        ),
        Text(
          l10n.ingredientAmountLabel(fraction),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class IngredientEntry {
  final FoodItem food;
  double fraction;

  IngredientEntry({required this.food, this.fraction = 1.0});

  CustomFoodComponent toComponent() => CustomFoodComponent(
        sourceFoodId: food.id,
        fraction: fraction,
      );
}

/// Mutable ingredient list used while creating a custom food.
class CustomIngredientList {
  final List<IngredientEntry> entries = [];

  bool get isEmpty => entries.isEmpty;

  void add(FoodItem food) {
    entries.add(IngredientEntry(food: food));
  }

  void removeAt(int index) => entries.removeAt(index);

  List<CustomFoodComponent> toComponents() =>
      entries.map((e) => e.toComponent()).toList();

  CustomFoodTotals totals({
    required DietType diet,
    required bool waterTrackerEnabled,
  }) {
    var protein = 0.0;
    var water = 0.0;
    for (final entry in entries) {
      protein += entry.food.proteinGrams * entry.fraction;
      water += entry.food.waterMlPerServing * entry.fraction;
    }
    return CustomFoodTotals(proteinGrams: protein, waterMl: water);
  }
}
