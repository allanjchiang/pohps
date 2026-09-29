import 'package:flutter_test/flutter_test.dart';
import 'package:pohps/food_data.dart';
import 'package:pohps/models.dart';

void main() {
  test('foods saved before calcium tracking load with zero calcium', () {
    final food = FoodItem.fromJson({
      'id': 'custom_1',
      'name': 'Old Food',
      'category': categoryOther,
      'proteinGrams': 5,
      'ironMg': 1.2,
      'servingSize': '1 bowl',
      'emoji': '🍲',
    });
    expect(food.calciumMg, 0);
    expect(food.ironMg, 1.2);
  });

  test('calcium survives a JSON round trip and scales with fraction', () {
    final tofu = defaultFoods.firstWhere((f) => f.id == 'tofu');
    final entry = LogEntry(
      id: '1',
      food: FoodItem.fromJson(tofu.toJson()),
      timestamp: DateTime(2026, 9, 29),
      fraction: 0.5,
    );
    expect(entry.food.calciumMg, tofu.calciumMg);
    expect(entry.totalCalciumMg, closeTo(tofu.calciumMg / 2, 1e-9));
  });

  test('custom food totals include calcium from ingredients', () {
    final dumplings = defaultPresetCustomFoods.first;
    final totals = computeCustomFoodTotals(
      dumplings.components!,
      diet: DietType.lactoOvo,
      waterTrackerEnabled: true,
    );
    expect(totals.calciumMg, closeTo(dumplings.calciumMg, 1));
  });

  test('beverage recipes match their ingredients', () {
    final foods = foodsForDiet(DietType.lactoOvo, includeBeverages: true);
    final latte = foods.firstWhere((f) => f.id == 'oat_milk_latte');
    final totals = computeCustomFoodTotals(
      latte.components!,
      diet: DietType.lactoOvo,
      waterTrackerEnabled: true,
    );
    expect(totals.calciumMg, closeTo(latte.calciumMg, 1));
  });

  test('vegan foods still offer good calcium sources', () {
    final vegan = foodsForDiet(DietType.vegan, includeBeverages: true);
    expect(vegan.where((f) => f.calciumMg >= 200).length, greaterThan(2));
  });
}
