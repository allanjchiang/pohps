import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../food_data.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';

class CustomFoodScreen extends StatefulWidget {
  const CustomFoodScreen({super.key});

  @override
  State<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends State<CustomFoodScreen> {
  final _nameController = TextEditingController();
  final _proteinController = TextEditingController();
  final _servingController = TextEditingController();
  String _selectedCategory = categoryOther;
  String _selectedEmoji = '🍽️';

  static const _emojiOptions = [
    '🍽️', '🥘', '🍲', '🥗', '🍛', '🥧', '🧆', '🥙',
    '🌮', '🌯', '🥪', '🫕', '🍝', '🍜', '🍱', '🥡',
    '🧁', '🥮', '🍰', '🫓', '🥞', '🧇', '🥣', '🍵',
  ];

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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createCustomFood)),
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
            Text(l10n.proteinPerServing, style: theme.textTheme.titleMedium),
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
            const SizedBox(height: 28),
            Text(l10n.servingSizeLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _servingController,
              decoration: InputDecoration(
                hintText: imperial ? l10n.egServingSizeImperial : l10n.egServingSize,
              ),
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyLarge,
            ),
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

  void _save() {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final protein = double.tryParse(_proteinController.text);
    final serving = _servingController.text.trim();

    if (name.isEmpty) {
      _showError(l10n.enterFoodName);
      return;
    }
    if (protein == null || protein < 0) {
      _showError(l10n.enterProteinAmount);
      return;
    }
    if (serving.isEmpty) {
      _showError(l10n.enterServingSize);
      return;
    }

    final food = FoodItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _selectedCategory,
      proteinGrams: protein,
      servingSize: serving,
      emoji: _selectedEmoji,
      isCustom: true,
    );
    context.read<AppState>().addCustomFood(food);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.foodCreated(name),
            style: const TextStyle(fontSize: 16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(fontSize: 16))),
    );
  }
}
