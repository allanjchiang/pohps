import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pohps/data/nutrient_limits.dart';
import 'package:pohps/food_data.dart';
import 'package:pohps/l10n/app_localizations.dart';
import 'package:pohps/models.dart';

FoodItem _supplement({double ironMg = 0, double calciumMg = 0}) => FoodItem(
      id: 'custom_1',
      name: 'Iron Chew',
      category: categorySupplements,
      proteinGrams: 0,
      waterMlPerServing: 0,
      ironMg: ironMg,
      calciumMg: calciumMg,
      servingSize: '1 tablet',
      emoji: '💊',
      isCustom: true,
    );

void main() {
  test('supplements are kept out of food categories and ingredients', () {
    expect(categories, isNot(contains(categorySupplements)));
    expect(defaultFoods.where(isSupplement), isEmpty);
    expect(isSupplement(_supplement(ironMg: 20)), isTrue);
  });

  test('supplement category survives a JSON round trip', () {
    final food = FoodItem.fromJson(_supplement(ironMg: 7).toJson());
    expect(isSupplement(food), isTrue);
    expect(food.ironMg, 7);
    expect(food.proteinGrams, 0);
  });

  test('supplement summary lists only the minerals it contains', () {
    final l10n = AppLocalizations(const Locale('en'));
    expect(l10n.supplementSummary(_supplement(ironMg: 20)), '20.0 mg iron');
    expect(
      l10n.supplementSummary(_supplement(ironMg: 7, calciumMg: 500)),
      '7.0 mg iron · 500 mg calcium',
    );
  });

  test('label amounts pass the compound-weight check, compounds do not', () {
    // "Ferrous fumarate 61 mg (equiv. iron 20 mg)" and Floradix's 7 mg.
    expect(20 <= maxPlausibleIronPerTabletMg, isTrue);
    expect(7 <= maxPlausibleIronPerTabletMg, isTrue);
    // Ferrous sulfate 325 mg tablets hold 65 mg iron; the compound is 325.
    expect(325 > maxPlausibleIronPerTabletMg, isTrue);
    // "Calcium carbonate 1,250 mg (500 mg calcium)".
    expect(500 <= maxPlausibleCalciumPerTabletMg, isTrue);
    expect(1250 > maxPlausibleCalciumPerTabletMg, isTrue);
  });
}
