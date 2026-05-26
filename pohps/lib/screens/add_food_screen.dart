import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../food_data.dart';

class AddFoodSheet extends StatefulWidget {
  const AddFoodSheet({super.key});

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    final allCategories = [
      'All',
      ...categories,
      if (appState.customFoods.isNotEmpty) 'My Foods',
    ];

    List<FoodItem> filteredFoods;
    if (_selectedCategory == 'All') {
      filteredFoods = appState.allFoods;
    } else if (_selectedCategory == 'My Foods') {
      filteredFoods = appState.customFoods;
    } else {
      filteredFoods = appState.allFoods
          .where((f) => f.category == _selectedCategory)
          .toList();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
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
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  Text('Add Food', style: theme.textTheme.headlineSmall),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context, 'create_custom'),
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    label: const Text('Custom'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  final cat = allCategories[index];
                  final selected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat, style: const TextStyle(fontSize: 14)),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: filteredFoods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🍽️',
                              style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            'No foods in this category',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.25,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: filteredFoods.length,
                      itemBuilder: (context, index) {
                        final food = filteredFoods[index];
                        return _FoodCard(
                          food: food,
                          onTap: () => appState.addFood(food),
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

class _FoodCard extends StatefulWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const _FoodCard({required this.food, required this.onTap});

  @override
  State<_FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<_FoodCard> {
  bool _justAdded = false;

  void _handleTap() {
    widget.onTap();
    setState(() => _justAdded = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _justAdded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _justAdded
              ? theme.colorScheme.primary
              : Colors.transparent,
          width: 2.5,
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.food.emoji,
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 2),
                Text(
                  widget.food.name,
                  style: theme.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.food.proteinGrams.round()}g protein',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _justAdded ? '✓ Added!' : widget.food.servingSize,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _justAdded
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        _justAdded ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
