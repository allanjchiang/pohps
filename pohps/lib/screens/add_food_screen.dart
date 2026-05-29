import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../food_data.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

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

    return FractionallySizedBox(
      heightFactor: 0.85,
      alignment: Alignment.bottomCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DragToCloseZone(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                  child: Row(
                    children: [
                      Text(l10n.addFood,
                          style: theme.textTheme.headlineSmall),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, 'create_custom'),
                        icon: const Icon(Icons.add_circle_outline, size: 22),
                        label: Text(l10n.custom),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allCategories.length,
                    itemBuilder: (context, index) {
                      final cat = allCategories[index];
                      final selected = cat == _selectedCategory;
                      final label = switch (cat) {
                        'All' => l10n.allCategory,
                        'My Foods' => l10n.myFoods,
                        _ => l10n.categoryName(cat),
                      };
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label:
                              Text(label, style: const TextStyle(fontSize: 14)),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: filteredFoods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🍽️', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noFoodsInCategory,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
      ),
    );
  }
}

/// Large touch target at the top of the sheet — swipe down anywhere here to close.
class _DragToCloseZone extends StatefulWidget {
  final Widget child;

  const _DragToCloseZone({required this.child});

  @override
  State<_DragToCloseZone> createState() => _DragToCloseZoneState();
}

class _DragToCloseZoneState extends State<_DragToCloseZone> {
  double _dragDistance = 0;

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_dragDistance > 48 || velocity > 400) {
      Navigator.of(context).pop();
    }
    _dragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (_) => _dragDistance = 0,
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          _dragDistance += details.delta.dy;
        }
      },
      onVerticalDragEnd: _onDragEnd,
      onVerticalDragCancel: () => _dragDistance = 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 128),
        child: widget.child,
      ),
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
    final l10n = AppLocalizations.of(context);
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
                  l10n.foodDisplayName(widget.food.id, widget.food.name),
                  style: theme.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.gProtein('${widget.food.proteinGrams.round()}'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _justAdded
                      ? l10n.added
                      : l10n.servingDisplay(widget.food.servingSize),
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
