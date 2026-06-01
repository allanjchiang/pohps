import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../food_data.dart';
import '../l10n/app_localizations.dart';
import 'custom_food_screen.dart';

/// Full-height modal with interactive drag (panel follows the finger).
Future<String?> showAddFoodSheet(BuildContext context, AppState appState) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    builder: (ctx) => _AddFoodModal(appState: appState),
  );
}

class _AddFoodModal extends StatefulWidget {
  final AppState appState;

  const _AddFoodModal({required this.appState});

  @override
  State<_AddFoodModal> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends State<_AddFoodModal>
    with SingleTickerProviderStateMixin {
  static const _sheetHeightFactor = 0.85;

  final _dragOffset = ValueNotifier<double>(0);
  late AnimationController _snapController;
  Animation<double>? _snapAnimation;
  late double _sheetHeightPx;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sheetHeightPx = MediaQuery.sizeOf(context).height * _sheetHeightFactor;
  }

  @override
  void dispose() {
    _dragOffset.dispose();
    _snapController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_snapController.isAnimating) return;
    _dragOffset.value = (_dragOffset.value + details.delta.dy)
        .clamp(0.0, _sheetHeightPx);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_snapController.isAnimating) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_dragOffset.value > _sheetHeightPx * 0.18 || velocity > 600) {
      _animateTo(_sheetHeightPx).then((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }
    _animateTo(0);
  }

  void _onDragCancel() {
    if (_dragOffset.value > 0) _animateTo(0);
  }

  Future<void> _animateTo(double target) async {
    _snapAnimation = Tween<double>(begin: _dragOffset.value, end: target)
        .animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    void listener() {
      if (_snapAnimation != null) {
        _dragOffset.value = _snapAnimation!.value;
      }
    }

    _snapAnimation!.addListener(listener);
    await _snapController.forward(from: 0);
    _snapAnimation!.removeListener(listener);
    _snapController.reset();
    _snapAnimation = null;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    final sheetPanel = RepaintBoundary(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
            height: _sheetHeightPx,
            child: SafeArea(
              top: false,
              child: _AddFoodPanel(
                onDragUpdate: _onDragUpdate,
                onDragEnd: _onDragEnd,
                onDragCancel: _onDragCancel,
                onCreateCustom: () => Navigator.pop(context, 'create_custom'),
              ),
            ),
          ),
        ),
      ),
    );

    return ChangeNotifierProvider.value(
      value: widget.appState,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Expanded(
              child: _SheetDragListener(
                onDragUpdate: _onDragUpdate,
                onDragEnd: _onDragEnd,
                onDragCancel: _onDragCancel,
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox.expand(),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _dragOffset,
              builder: (context, offset, child) => Transform.translate(
                offset: Offset(0, offset),
                child: child,
              ),
              child: sheetPanel,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetDragListener extends StatelessWidget {
  final void Function(DragUpdateDetails) onDragUpdate;
  final void Function(DragEndDetails) onDragEnd;
  final VoidCallback? onDragCancel;
  final VoidCallback? onTap;
  final Widget child;

  const _SheetDragListener({
    required this.onDragUpdate,
    required this.onDragEnd,
    this.onDragCancel,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      onVerticalDragCancel: onDragCancel,
      child: child,
    );
  }
}

class _AddFoodPanel extends StatefulWidget {
  final void Function(DragUpdateDetails) onDragUpdate;
  final void Function(DragEndDetails) onDragEnd;
  final VoidCallback? onDragCancel;
  final VoidCallback onCreateCustom;

  const _AddFoodPanel({
    required this.onDragUpdate,
    required this.onDragEnd,
    this.onDragCancel,
    required this.onCreateCustom,
  });

  @override
  State<_AddFoodPanel> createState() => _AddFoodPanelState();
}

class _AddFoodPanelState extends State<_AddFoodPanel> {
  String _selectedCategory = 'All';

  Future<void> _editCustomFood(FoodItem food) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CustomFoodScreen(existingFood: food),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);

    final allCategories = [
      'All',
      ...categoriesForPicker(waterTrackerEnabled: appState.waterTrackerEnabled),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetDragListener(
          onDragUpdate: widget.onDragUpdate,
          onDragEnd: widget.onDragEnd,
          onDragCancel: widget.onDragCancel,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 128),
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
                        onPressed: widget.onCreateCustom,
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
                          label: Text(label,
                              style: const TextStyle(fontSize: 14)),
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
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    24 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        appState.waterTrackerEnabled ? 1.12 : 1.25,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: filteredFoods.length,
                  itemBuilder: (context, index) {
                    final food = filteredFoods[index];
                    return _FoodCard(
                      food: food,
                      onTap: () => appState.addFood(food),
                      onEdit: food.isCustom
                          ? () => _editCustomFood(food)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FoodCard extends StatefulWidget {
  final FoodItem food;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _FoodCard({
    required this.food,
    required this.onTap,
    this.onEdit,
  });

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

  Future<void> _maybeEditProtein(AppState appState) async {
    if (!appState.isProteinEditableFood(widget.food.id)) return;
    final l10n = AppLocalizations.of(context);
    final displayName = l10n.foodDisplayName(widget.food.id, widget.food.name);

    final current = appState.proteinForFood(widget.food);
    final controller =
        TextEditingController(text: current.toStringAsFixed(0));

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editProteinTitle(displayName)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: InputDecoration(
            hintText: l10n.egProtein,
            suffixText: l10n.grams,
          ),
          autofocus: true,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              appState.clearProteinOverride(widget.food.id);
              Navigator.pop(ctx);
            },
            child: Text(l10n.reset),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                appState.setProteinOverride(widget.food.id, value);
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final proteinEditable = appState.isProteinEditableFood(widget.food.id);
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
          onLongPress: () {
            if (widget.onEdit != null) {
              widget.onEdit!();
            } else if (proteinEditable) {
              _maybeEditProtein(appState);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.food.emoji,
                            style: const TextStyle(fontSize: 28)),
                        Text(
                          l10n.foodDisplayName(widget.food.id, widget.food.name),
                          style: theme.textTheme.titleSmall,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (appState.waterTrackerEnabled &&
                            widget.food.waterMlPerServing > 0)
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: l10n.gProtein(
                                      '${appState.proteinForFood(widget.food).round()}'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' · ${l10n.waterAmountLabel(widget.food.waterMlPerServing, appState.measurementSystem)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF1565C0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            l10n.gProtein(
                                '${appState.proteinForFood(widget.food).round()}'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Text(
                          _justAdded
                              ? l10n.added
                              : l10n.servingDisplay(
                                  widget.food.servingSize,
                                  foodId: widget.food.isCustom
                                      ? null
                                      : widget.food.id,
                                  system: appState.measurementSystem,
                                ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _justAdded
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: _justAdded
                                ? FontWeight.w600
                                : FontWeight.normal,
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
              if (widget.onEdit != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton(
                      tooltip: l10n.editCustomFoodHint,
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.8),
                      ),
                      onPressed: widget.onEdit,
                    ),
                  ),
                )
              else if (proteinEditable)
                Positioned(
                  top: 0,
                  right: 0,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton(
                      tooltip: l10n.editProteinTitle(
                        l10n.foodDisplayName(widget.food.id, widget.food.name),
                      ),
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.8),
                      ),
                      onPressed: () => _maybeEditProtein(appState),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
