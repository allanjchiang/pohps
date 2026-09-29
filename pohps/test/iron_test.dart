import 'package:flutter_test/flutter_test.dart';
import 'package:pohps/food_data.dart';
import 'package:pohps/models.dart';

void main() {
  test('foods saved before iron tracking load with zero iron', () {
    final food = FoodItem.fromJson({
      'id': 'custom_1',
      'name': 'Old Food',
      'category': categoryOther,
      'proteinGrams': 5,
      'servingSize': '1 bowl',
      'emoji': '🍲',
    });
    expect(food.ironMg, 0);
  });

  test('iron survives a JSON round trip and scales with fraction', () {
    final lentils = defaultFoods.firstWhere((f) => f.id == 'lentils');
    final entry = LogEntry(
      id: '1',
      food: FoodItem.fromJson(lentils.toJson()),
      timestamp: DateTime(2026, 9, 29),
      fraction: 0.5,
    );
    expect(entry.food.ironMg, lentils.ironMg);
    expect(entry.totalIronMg, closeTo(lentils.ironMg / 2, 1e-9));
  });

  test('custom food totals include iron from ingredients', () {
    final dumplings = defaultPresetCustomFoods.first;
    final totals = computeCustomFoodTotals(
      dumplings.components!,
      diet: DietType.lactoOvo,
      waterTrackerEnabled: true,
    );
    expect(totals.ironMg, closeTo(dumplings.ironMg, 0.1));
  });

  test('tea and coffee inhibitor IDs are real foods', () {
    final ids = foodsForDiet(DietType.lactoOvo, includeBeverages: true)
        .map((f) => f.id)
        .toSet();
    expect(ids.containsAll(ironInhibitingDrinkIds), isTrue);
  });
}
