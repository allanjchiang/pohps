import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pohps/app_state.dart';
import 'package:pohps/l10n/app_localizations.dart';
import 'package:pohps/screens/custom_food_screen.dart';
import 'package:provider/provider.dart';

/// Opens the custom food screen on top of a placeholder home page.
Future<void> _openScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CustomFoodScreen()),
            ),
            child: const Text('home'),
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
  testWidgets('back with nothing entered leaves without asking',
      (tester) async {
    await _openScreen(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('back with unsaved changes asks first, discard leaves',
      (tester) async {
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
}
