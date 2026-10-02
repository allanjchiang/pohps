import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pohps/app_state.dart';
import 'package:pohps/food_data.dart';
import 'package:pohps/l10n/app_localizations.dart';
import 'package:pohps/screens/custom_food_screen.dart';
import 'package:pohps/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _testFood = FoodItem(
  id: 'custom_test',
  name: 'Test Food',
  category: categoryFruits,
  proteinGrams: 1,
  waterMlPerServing: 0,
  servingSize: '1 bowl',
  emoji: '🍓',
  isCustom: true,
);

/// Opens the custom food screen on top of a placeholder home page.
Future<void> _openScreen(
  WidgetTester tester, {
  AppState? appState,
  FoodItem? existingFood,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => appState ?? AppState(),
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CustomFoodScreen(existingFood: existingFood),
                ),
              ),
              child: const Text('home'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('home'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('back with nothing entered leaves without asking', (
    tester,
  ) async {
    await _openScreen(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('back with unsaved changes asks first, discard leaves', (
    tester,
  ) async {
    await _openScreen(tester);
    await tester.enterText(find.byType(TextField).first, 'Tofu stir fry');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Save this food?'), findsOneWidget);

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Tofu stir fry'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('save is reachable from the app bar', (tester) async {
    await _openScreen(tester);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Save')),
      findsOneWidget,
    );
  });

  testWidgets('deleting a custom food can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({
      'custom_foods': '[]',
      'favorite_food_ids': '[]',
    });
    final appState = AppState();
    // No store on desktop, so init() skips connecting to Play Billing.
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    await tester.runAsync(appState.init);
    debugDefaultTargetPlatformOverride = null;
    await tester.runAsync(() => appState.addCustomFood(_testFood));
    expect(appState.customFoods.map((f) => f.id), contains('custom_test'));

    await _openScreen(tester, appState: appState, existingFood: _testFood);
    await tester.tap(find.byTooltip('Delete food'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Custom Food?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(
      appState.customFoods.map((f) => f.id),
      isNot(contains('custom_test')),
    );
    expect(find.text('Test Food deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(appState.customFoods.map((f) => f.id), contains('custom_test'));
  });
}
