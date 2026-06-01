import 'models.dart';

const String categoryBeverages = 'Beverages';
const String categoryDairyEggs = 'Dairy & Eggs';
const String categoryProteinBoosters = 'Protein Boosters';
const String categoryLegumes = 'Legumes';
const String categoryGrains = 'Grains';
const String categoryVegetables = 'Vegetables';
const String categoryOther = 'Other';

const List<String> categories = [
  categoryDairyEggs,
  categoryProteinBoosters,
  categoryLegumes,
  categoryGrains,
  categoryVegetables,
  categoryOther,
];

/// Category chips shown in Add Food (includes Beverages when water tracker is on).
List<String> categoriesForPicker({required bool waterTrackerEnabled}) {
  if (!waterTrackerEnabled) return categories;
  return [categoryBeverages, ...categories];
}

/// Shown after milk in the All list when the water tracker is on.
const List<FoodItem> dairyBeverageFoods = [
  FoodItem(
    id: 'water',
    name: 'Water',
    category: categoryBeverages,
    proteinGrams: 0,
    waterMlPerServing: 250,
    servingSize: '1 glass (250ml)',
    emoji: '💧',
  ),
  FoodItem(
    id: 'coffee',
    name: 'Coffee',
    category: categoryBeverages,
    proteinGrams: 0,
    waterMlPerServing: 240,
    servingSize: '1 cup (240ml)',
    emoji: '☕',
  ),
  FoodItem(
    id: 'tea',
    name: 'Tea',
    category: categoryBeverages,
    proteinGrams: 0,
    waterMlPerServing: 240,
    servingSize: '1 cup (240ml)',
    emoji: '🍵',
  ),
];

/// Shown after mushroom in the All list when the water tracker is on.
const List<FoodItem> vegetableBeverageFoods = [
  FoodItem(
    id: 'sugar_free_soda',
    name: 'Sugar-Free Soda',
    category: categoryBeverages,
    proteinGrams: 0,
    waterMlPerServing: 355,
    servingSize: '1 can (355ml)',
    emoji: '🥤',
  ),
  FoodItem(
    id: 'milk_tea',
    name: 'Milk Tea',
    category: categoryBeverages,
    proteinGrams: 2,
    waterMlPerServing: 350,
    servingSize: '1 cup (350ml)',
    emoji: '🧋',
  ),
  FoodItem(
    id: 'juice',
    name: 'Juice',
    category: categoryBeverages,
    proteinGrams: 1,
    waterMlPerServing: 250,
    servingSize: '1 glass (250ml)',
    emoji: '🧃',
  ),
  FoodItem(
    id: 'fruit_smoothie',
    name: 'Fruit Smoothie',
    category: categoryBeverages,
    proteinGrams: 2,
    waterMlPerServing: 350,
    servingSize: '1 glass (350ml)',
    emoji: '🍓',
  ),
];

const List<FoodItem> defaultFoods = [
  // Dairy & Eggs
  FoodItem(
    id: 'egg',
    name: 'Egg',
    category: categoryDairyEggs,
    proteinGrams: 6,
    waterMlPerServing: 38,
    servingSize: '1 large',
    emoji: '🥚',
  ),
  FoodItem(
    id: 'greek_yoghurt',
    name: 'Greek Yoghurt',
    category: categoryDairyEggs,
    proteinGrams: 14,
    waterMlPerServing: 130,
    servingSize: '1 pot (160g)',
    emoji: '🫙',
  ),
  FoodItem(
    id: 'milk',
    name: 'Milk',
    category: categoryDairyEggs,
    proteinGrams: 8,
    waterMlPerServing: 218,
    servingSize: '1 glass (250ml)',
    emoji: '🥛',
  ),
  FoodItem(
    id: 'paneer',
    name: 'Paneer',
    category: categoryDairyEggs,
    proteinGrams: 18,
    waterMlPerServing: 50,
    servingSize: '100g',
    emoji: '🧀',
  ),
  FoodItem(
    id: 'cottage_cheese',
    name: 'Cottage Cheese',
    category: categoryDairyEggs,
    proteinGrams: 14,
    waterMlPerServing: 90,
    servingSize: '1/2 cup',
    emoji: '🥣',
  ),

  // Protein Boosters
  FoodItem(
    id: 'whey_smoothie',
    name: 'Whey Protein Isolate Powder',
    category: categoryProteinBoosters,
    proteinGrams: 24,
    waterMlPerServing: 0,
    servingSize: '1 scoop',
    emoji: '🥄',
  ),
  FoodItem(
    id: 'pea_protein_powder',
    name: 'Pea Protein Powder',
    category: categoryProteinBoosters,
    proteinGrams: 24,
    waterMlPerServing: 0,
    servingSize: '1 scoop',
    emoji: '🥄',
  ),
  FoodItem(
    id: 'soy_milk',
    name: 'Soy Milk',
    category: categoryProteinBoosters,
    proteinGrams: 8,
    waterMlPerServing: 218,
    servingSize: '1 glass (250ml)',
    emoji: '🧃',
  ),
  FoodItem(
    id: 'tofu',
    name: 'Tofu',
    category: categoryProteinBoosters,
    proteinGrams: 10,
    waterMlPerServing: 85,
    servingSize: '100g (firm)',
    emoji: '🧈',
  ),
  FoodItem(
    id: 'soy_meat',
    name: 'Soy Meat',
    category: categoryProteinBoosters,
    proteinGrams: 11,
    waterMlPerServing: 50,
    servingSize: '1 serving (85g)',
    emoji: '🥩',
  ),

  // Legumes
  FoodItem(
    id: 'lentils',
    name: 'Lentils',
    category: categoryLegumes,
    proteinGrams: 18,
    waterMlPerServing: 140,
    servingSize: '1 cup cooked',
    emoji: '🫘',
  ),
  FoodItem(
    id: 'chickpeas',
    name: 'Chickpeas',
    category: categoryLegumes,
    proteinGrams: 15,
    waterMlPerServing: 130,
    servingSize: '1 cup cooked',
    emoji: '🫛',
  ),
  FoodItem(
    id: 'black_beans',
    name: 'Black Beans',
    category: categoryLegumes,
    proteinGrams: 15,
    waterMlPerServing: 130,
    servingSize: '1 cup cooked',
    emoji: '🫘',
  ),
  FoodItem(
    id: 'kidney_beans',
    name: 'Kidney Beans',
    category: categoryLegumes,
    proteinGrams: 15,
    waterMlPerServing: 130,
    servingSize: '1 cup cooked',
    emoji: '🫘',
  ),

  // Grains
  FoodItem(
    id: 'white_rice',
    name: 'White Rice',
    category: categoryGrains,
    proteinGrams: 4,
    waterMlPerServing: 130,
    servingSize: '1 cup cooked',
    emoji: '🍚',
  ),
  FoodItem(
    id: 'brown_rice',
    name: 'Brown Rice',
    category: categoryGrains,
    proteinGrams: 5,
    waterMlPerServing: 130,
    servingSize: '1 cup cooked',
    emoji: '🍘',
  ),
  FoodItem(
    id: 'quinoa',
    name: 'Quinoa',
    category: categoryGrains,
    proteinGrams: 8,
    waterMlPerServing: 140,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'millet',
    name: 'Millet',
    category: categoryGrains,
    proteinGrams: 6,
    waterMlPerServing: 130,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'buckwheat',
    name: 'Buckwheat',
    category: categoryGrains,
    proteinGrams: 6,
    waterMlPerServing: 130,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'noodles',
    name: 'Noodles',
    category: categoryGrains,
    proteinGrams: 8,
    waterMlPerServing: 120,
    servingSize: '1 cup cooked',
    emoji: '🍜',
  ),

  // Vegetables
  FoodItem(
    id: 'potato',
    name: 'Potato',
    category: categoryVegetables,
    proteinGrams: 3,
    waterMlPerServing: 130,
    servingSize: '1 medium',
    emoji: '🥔',
  ),
  FoodItem(
    id: 'mushroom',
    name: 'Mushroom',
    category: categoryVegetables,
    proteinGrams: 3,
    waterMlPerServing: 85,
    servingSize: '1 cup',
    emoji: '🍄',
  ),
  FoodItem(
    id: 'cauliflower',
    name: 'Cauliflower',
    category: categoryVegetables,
    proteinGrams: 2,
    waterMlPerServing: 85,
    servingSize: '1 cup',
    emoji: '🥦',
  ),
  FoodItem(
    id: 'broccoli',
    name: 'Broccoli',
    category: categoryVegetables,
    proteinGrams: 3,
    waterMlPerServing: 85,
    servingSize: '1 cup',
    emoji: '🥦',
  ),
  FoodItem(
    id: 'cabbage',
    name: 'Cabbage',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 70,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'bok_choy',
    name: 'Bok Choy',
    category: categoryVegetables,
    proteinGrams: 2,
    waterMlPerServing: 75,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'wombok',
    name: 'Wombok',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 75,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'capsicum',
    name: 'Capsicum',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 90,
    servingSize: '1 medium',
    emoji: '🫑',
  ),
  FoodItem(
    id: 'kale',
    name: 'Kale',
    category: categoryVegetables,
    proteinGrams: 3,
    waterMlPerServing: 75,
    servingSize: '1 cup',
    emoji: '🥬',
  ),

  // Other
  FoodItem(
    id: 'fruits',
    name: 'Fruits',
    category: categoryOther,
    proteinGrams: 1,
    waterMlPerServing: 85,
    servingSize: '1 medium',
    emoji: '🍎',
  ),
  FoodItem(
    id: 'nuts_seeds',
    name: 'Nuts & Seeds',
    category: categoryOther,
    proteinGrams: 6,
    waterMlPerServing: 2,
    servingSize: '30g (1 oz)',
    emoji: '🥜',
  ),
  FoodItem(
    id: 'oils',
    name: 'Oils',
    category: categoryOther,
    proteinGrams: 0,
    waterMlPerServing: 0,
    servingSize: '1 tbsp',
    emoji: '🫒',
  ),
];

/// Foods excluded when the user selects a vegan diet.
const Set<String> lactoOvoOnlyFoodIds = {
  'egg',
  'greek_yoghurt',
  'milk',
  'paneer',
  'cottage_cheese',
  'whey_smoothie',
};

const List<FoodItem> veganOnlyFoods = [
  FoodItem(
    id: 'pea_protein_smoothie',
    name: 'Pea Protein Smoothie',
    category: categoryProteinBoosters,
    proteinGrams: 22,
    waterMlPerServing: 200,
    servingSize: '1 scoop + soy milk',
    emoji: '🥤',
  ),
];

List<FoodItem> _insertAfterId(
  List<FoodItem> foods,
  String afterId,
  List<FoodItem> items,
) {
  final index = foods.indexWhere((f) => f.id == afterId);
  if (index == -1) return foods;
  return [
    ...foods.sublist(0, index + 1),
    ...items,
    ...foods.sublist(index + 1),
  ];
}

List<FoodItem> _insertAfterFirstFound(
  List<FoodItem> foods,
  List<String> anchorIds,
  List<FoodItem> items,
) {
  for (final id in anchorIds) {
    final index = foods.indexWhere((f) => f.id == id);
    if (index != -1) {
      return [
        ...foods.sublist(0, index + 1),
        ...items,
        ...foods.sublist(index + 1),
      ];
    }
  }
  final fallback =
      foods.indexWhere((f) => f.category == categoryProteinBoosters);
  if (fallback == -1) return [...foods, ...items];
  return [
    ...foods.sublist(0, fallback),
    ...items,
    ...foods.sublist(fallback),
  ];
}

List<FoodItem> foodsForDiet(DietType diet, {bool includeBeverages = false}) {
  final List<FoodItem> base;
  if (diet == DietType.lactoOvo) {
    base = defaultFoods;
  } else {
    base = [
      ...defaultFoods.where((f) => !lactoOvoOnlyFoodIds.contains(f.id)),
      ...veganOnlyFoods,
    ];
  }
  if (!includeBeverages) return base;

  final withDairyDrinks = _insertAfterFirstFound(
    base,
    ['milk', 'greek_yoghurt', 'egg'],
    dairyBeverageFoods,
  );
  return _insertAfterId(withDairyDrinks, 'mushroom', vegetableBeverageFoods);
}

/// Base database foods available when building a custom recipe.
List<FoodItem> baseFoodsForIngredients({
  required DietType diet,
  required bool waterTrackerEnabled,
}) =>
    foodsForDiet(diet, includeBeverages: waterTrackerEnabled);

FoodItem? findBaseFood(
  String id, {
  required DietType diet,
  required bool waterTrackerEnabled,
}) {
  for (final food in baseFoodsForIngredients(
    diet: diet,
    waterTrackerEnabled: waterTrackerEnabled,
  )) {
    if (food.id == id) return food;
  }
  return null;
}

class CustomFoodTotals {
  final double proteinGrams;
  final double waterMl;

  const CustomFoodTotals({
    required this.proteinGrams,
    required this.waterMl,
  });
}

CustomFoodTotals computeCustomFoodTotals(
  List<CustomFoodComponent> components, {
  required DietType diet,
  required bool waterTrackerEnabled,
}) {
  var protein = 0.0;
  var water = 0.0;
  for (final component in components) {
    final food = findBaseFood(
      component.sourceFoodId,
      diet: diet,
      waterTrackerEnabled: waterTrackerEnabled,
    );
    if (food == null) continue;
    protein += food.proteinGrams * component.fraction;
    water += food.waterMlPerServing * component.fraction;
  }
  return CustomFoodTotals(proteinGrams: protein, waterMl: water);
}
