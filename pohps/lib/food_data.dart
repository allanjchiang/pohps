import 'models.dart';

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

const List<FoodItem> defaultFoods = [
  // Dairy & Eggs
  FoodItem(
    id: 'egg',
    name: 'Egg',
    category: categoryDairyEggs,
    proteinGrams: 6,
    servingSize: '1 large',
    emoji: '🥚',
  ),
  FoodItem(
    id: 'greek_yoghurt',
    name: 'Greek Yoghurt',
    category: categoryDairyEggs,
    proteinGrams: 14,
    servingSize: '1 pot (160g)',
    emoji: '🫙',
  ),
  FoodItem(
    id: 'milk',
    name: 'Milk',
    category: categoryDairyEggs,
    proteinGrams: 8,
    servingSize: '1 glass (250ml)',
    emoji: '🥛',
  ),

  // Protein Boosters
  FoodItem(
    id: 'whey_smoothie',
    name: 'Whey Smoothie',
    category: categoryProteinBoosters,
    proteinGrams: 22,
    servingSize: '1 scoop + milk',
    emoji: '🥤',
  ),
  FoodItem(
    id: 'soy_milk',
    name: 'Soy Milk',
    category: categoryProteinBoosters,
    proteinGrams: 8,
    servingSize: '1 glass (250ml)',
    emoji: '🧃',
  ),
  FoodItem(
    id: 'tofu',
    name: 'Tofu',
    category: categoryProteinBoosters,
    proteinGrams: 10,
    servingSize: '100g (firm)',
    emoji: '🧈',
  ),
  FoodItem(
    id: 'soy_meat',
    name: 'Soy Meat',
    category: categoryProteinBoosters,
    proteinGrams: 11,
    servingSize: '1 serving (85g)',
    emoji: '🥩',
  ),

  // Legumes
  FoodItem(
    id: 'lentils',
    name: 'Lentils',
    category: categoryLegumes,
    proteinGrams: 18,
    servingSize: '1 cup cooked',
    emoji: '🫘',
  ),
  FoodItem(
    id: 'chickpeas',
    name: 'Chickpeas',
    category: categoryLegumes,
    proteinGrams: 15,
    servingSize: '1 cup cooked',
    emoji: '🫛',
  ),

  // Grains
  FoodItem(
    id: 'white_rice',
    name: 'White Rice',
    category: categoryGrains,
    proteinGrams: 4,
    servingSize: '1 cup cooked',
    emoji: '🍚',
  ),
  FoodItem(
    id: 'brown_rice',
    name: 'Brown Rice',
    category: categoryGrains,
    proteinGrams: 5,
    servingSize: '1 cup cooked',
    emoji: '🍘',
  ),
  FoodItem(
    id: 'quinoa',
    name: 'Quinoa',
    category: categoryGrains,
    proteinGrams: 8,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'millet',
    name: 'Millet',
    category: categoryGrains,
    proteinGrams: 6,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'buckwheat',
    name: 'Buckwheat',
    category: categoryGrains,
    proteinGrams: 6,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'noodles',
    name: 'Noodles',
    category: categoryGrains,
    proteinGrams: 8,
    servingSize: '1 cup cooked',
    emoji: '🍜',
  ),

  // Vegetables
  FoodItem(
    id: 'potato',
    name: 'Potato',
    category: categoryVegetables,
    proteinGrams: 3,
    servingSize: '1 medium',
    emoji: '🥔',
  ),
  FoodItem(
    id: 'mushroom',
    name: 'Mushroom',
    category: categoryVegetables,
    proteinGrams: 3,
    servingSize: '1 cup',
    emoji: '🍄',
  ),
  FoodItem(
    id: 'cauliflower',
    name: 'Cauliflower',
    category: categoryVegetables,
    proteinGrams: 2,
    servingSize: '1 cup',
    emoji: '🥦',
  ),
  FoodItem(
    id: 'cabbage',
    name: 'Cabbage',
    category: categoryVegetables,
    proteinGrams: 1,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'bok_choy',
    name: 'Bok Choy',
    category: categoryVegetables,
    proteinGrams: 2,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'wombok',
    name: 'Wombok',
    category: categoryVegetables,
    proteinGrams: 1,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'capsicum',
    name: 'Capsicum',
    category: categoryVegetables,
    proteinGrams: 1,
    servingSize: '1 medium',
    emoji: '🫑',
  ),

  // Other
  FoodItem(
    id: 'fruits',
    name: 'Fruits',
    category: categoryOther,
    proteinGrams: 1,
    servingSize: '1 medium',
    emoji: '🍎',
  ),
  FoodItem(
    id: 'nuts_seeds',
    name: 'Nuts & Seeds',
    category: categoryOther,
    proteinGrams: 6,
    servingSize: '30g (1 oz)',
    emoji: '🥜',
  ),
  FoodItem(
    id: 'oils',
    name: 'Oils',
    category: categoryOther,
    proteinGrams: 0,
    servingSize: '1 tbsp',
    emoji: '🫒',
  ),
];

/// Foods excluded when the user selects a vegan diet.
const Set<String> lactoOvoOnlyFoodIds = {
  'egg',
  'greek_yoghurt',
  'milk',
  'whey_smoothie',
};

const List<FoodItem> veganOnlyFoods = [
  FoodItem(
    id: 'pea_protein_smoothie',
    name: 'Pea Protein Smoothie',
    category: categoryProteinBoosters,
    proteinGrams: 22,
    servingSize: '1 scoop + soy milk',
    emoji: '🥤',
  ),
];

List<FoodItem> foodsForDiet(DietType diet) {
  if (diet == DietType.lactoOvo) return defaultFoods;
  return [
    ...defaultFoods.where((f) => !lactoOvoOnlyFoodIds.contains(f.id)),
    ...veganOnlyFoods,
  ];
}
