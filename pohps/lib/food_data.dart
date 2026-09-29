import 'models.dart';

const String categoryBeverages = 'Beverages';
const String categoryDairyEggs = 'Dairy & Eggs';
const String categoryProteinBoosters = 'Protein Boosters';
const String categoryLegumes = 'Legumes';
const String categoryGrains = 'Grains';
const String categoryVegetables = 'Vegetables';
const String categoryFungi = 'Fungi';
const String categoryFruits = 'Fruits';
const String categoryNutsSeeds = 'Nuts & Seeds';
const String categoryOther = 'Other';

const List<String> categories = [
  categoryDairyEggs,
  categoryProteinBoosters,
  categoryLegumes,
  categoryGrains,
  categoryVegetables,
  categoryFungi,
  categoryFruits,
  categoryNutsSeeds,
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
    ironMg: 0.1,
    calciumMg: 5,
    servingSize: '1 cup (240ml)',
    emoji: '☕',
  ),
  FoodItem(
    id: 'espresso',
    name: 'Espresso',
    category: categoryBeverages,
    proteinGrams: 0,
    waterMlPerServing: 30,
    servingSize: '1 shot (30ml)',
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
  FoodItem(
    id: 'oat_milk',
    name: 'Oat Milk',
    category: categoryBeverages,
    proteinGrams: 3,
    waterMlPerServing: 218,
    ironMg: 0.3,
    calciumMg: 300,
    servingSize: '1 glass (250ml)',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'oat_milk_latte',
    name: 'Oat Milk Latte',
    category: categoryBeverages,
    proteinGrams: 2.25,
    waterMlPerServing: 223.5,
    ironMg: 0.2,
    calciumMg: 225,
    servingSize: '2 shots + 6 oz oat milk',
    emoji: '☕',
    components: [
      CustomFoodComponent(sourceFoodId: 'espresso', fraction: 2.0),
      CustomFoodComponent(sourceFoodId: 'oat_milk', fraction: 0.75),
    ],
  ),
  FoodItem(
    id: 'almond_milk',
    name: 'Almond Milk',
    category: categoryBeverages,
    proteinGrams: 1,
    waterMlPerServing: 218,
    ironMg: 0.7,
    calciumMg: 300,
    servingSize: '1 glass (250ml)',
    emoji: '🥛',
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
    ironMg: 0.2,
    calciumMg: 100,
    servingSize: '1 cup (350ml)',
    emoji: '🧋',
  ),
  FoodItem(
    id: 'juice',
    name: 'Juice',
    category: categoryBeverages,
    proteinGrams: 1,
    waterMlPerServing: 250,
    ironMg: 0.5,
    calciumMg: 25,
    servingSize: '1 glass (250ml)',
    emoji: '🧃',
  ),
  FoodItem(
    id: 'fruit_smoothie',
    name: 'Fruit Smoothie',
    category: categoryBeverages,
    proteinGrams: 2,
    waterMlPerServing: 350,
    ironMg: 0.8,
    calciumMg: 50,
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
    ironMg: 0.9,
    calciumMg: 25,
    servingSize: '1 large',
    emoji: '🥚',
  ),
  FoodItem(
    id: 'greek_yoghurt',
    name: 'Greek Yoghurt',
    category: categoryDairyEggs,
    proteinGrams: 14,
    waterMlPerServing: 130,
    ironMg: 0.1,
    calciumMg: 175,
    servingSize: '1 pot (160g)',
    emoji: '🫙',
  ),
  FoodItem(
    id: 'milk',
    name: 'Milk',
    category: categoryDairyEggs,
    proteinGrams: 8,
    waterMlPerServing: 218,
    ironMg: 0.1,
    calciumMg: 300,
    servingSize: '1 glass (250ml)',
    emoji: '🥛',
  ),
  FoodItem(
    id: 'paneer',
    name: 'Paneer',
    category: categoryDairyEggs,
    proteinGrams: 18,
    waterMlPerServing: 50,
    ironMg: 0.2,
    calciumMg: 400,
    servingSize: '100g',
    emoji: '🧀',
  ),
  FoodItem(
    id: 'cottage_cheese',
    name: 'Cottage Cheese',
    category: categoryDairyEggs,
    proteinGrams: 14,
    waterMlPerServing: 90,
    ironMg: 0.1,
    calciumMg: 95,
    servingSize: '1/2 cup',
    emoji: '🥣',
  ),
  FoodItem(
    id: 'cheese',
    name: 'Cheese',
    category: categoryDairyEggs,
    proteinGrams: 7,
    waterMlPerServing: 5,
    ironMg: 0.2,
    calciumMg: 200,
    servingSize: '1 slice (28g)',
    emoji: '🧀',
  ),

  // Protein Boosters
  FoodItem(
    id: 'whey_smoothie',
    name: 'Whey Protein Isolate Powder',
    category: categoryProteinBoosters,
    proteinGrams: 24,
    waterMlPerServing: 0,
    ironMg: 0.3,
    calciumMg: 100,
    servingSize: '1 scoop',
    emoji: '🥄',
  ),
  FoodItem(
    id: 'pea_protein_powder',
    name: 'Pea Protein Powder',
    category: categoryProteinBoosters,
    proteinGrams: 24,
    waterMlPerServing: 0,
    ironMg: 5,
    calciumMg: 80,
    servingSize: '1 scoop',
    emoji: '🥄',
  ),
  FoodItem(
    id: 'soy_milk',
    name: 'Soy Milk',
    category: categoryProteinBoosters,
    proteinGrams: 8,
    waterMlPerServing: 218,
    ironMg: 1.1,
    calciumMg: 300,
    servingSize: '1 glass (250ml)',
    emoji: '🧃',
  ),
  FoodItem(
    id: 'tofu',
    name: 'Tofu',
    category: categoryProteinBoosters,
    proteinGrams: 10,
    waterMlPerServing: 85,
    ironMg: 2.7,
    calciumMg: 350,
    servingSize: '100g (firm)',
    emoji: '🧈',
  ),
  FoodItem(
    id: 'beancurd_skin',
    name: 'Beancurd Skin',
    category: categoryProteinBoosters,
    proteinGrams: 25,
    waterMlPerServing: 20,
    ironMg: 4.5,
    calciumMg: 100,
    servingSize: '50g',
    emoji: '🥡',
  ),
  FoodItem(
    id: 'soy_meat',
    name: 'Soy Meat',
    category: categoryProteinBoosters,
    proteinGrams: 11,
    waterMlPerServing: 50,
    ironMg: 2.2,
    calciumMg: 80,
    servingSize: '1 serving (85g)',
    emoji: '🥩',
  ),
  FoodItem(
    id: 'plant_based_meat',
    name: 'Plant-Based Meat (Pea Protein)',
    category: categoryProteinBoosters,
    proteinGrams: 17,
    waterMlPerServing: 55,
    ironMg: 3,
    calciumMg: 70,
    servingSize: '1 serving (85g)',
    emoji: '🥩',
  ),
  FoodItem(
    id: 'quorn_chicken_pieces',
    name: 'Quorn Chicken Pieces',
    category: categoryProteinBoosters,
    proteinGrams: 10,
    waterMlPerServing: 65,
    ironMg: 0.4,
    calciumMg: 40,
    servingSize: '100g',
    emoji: '🍗',
  ),

  // Legumes
  FoodItem(
    id: 'lentils',
    name: 'Lentils',
    category: categoryLegumes,
    proteinGrams: 18,
    waterMlPerServing: 140,
    ironMg: 6.6,
    calciumMg: 40,
    servingSize: '1 cup cooked',
    emoji: '🫘',
  ),
  FoodItem(
    id: 'chickpeas',
    name: 'Chickpeas',
    category: categoryLegumes,
    proteinGrams: 15,
    waterMlPerServing: 130,
    ironMg: 4.7,
    calciumMg: 80,
    servingSize: '1 cup cooked',
    emoji: '🫛',
  ),
  FoodItem(
    id: 'black_beans',
    name: 'Black Beans',
    category: categoryLegumes,
    proteinGrams: 15,
    waterMlPerServing: 130,
    ironMg: 3.6,
    calciumMg: 45,
    servingSize: '1 cup cooked',
    emoji: '🫘',
  ),
  FoodItem(
    id: 'kidney_beans',
    name: 'Kidney Beans',
    category: categoryLegumes,
    proteinGrams: 15,
    waterMlPerServing: 130,
    ironMg: 3.9,
    calciumMg: 60,
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
    ironMg: 0.4,
    calciumMg: 15,
    servingSize: '1 cup cooked',
    emoji: '🍚',
  ),
  FoodItem(
    id: 'brown_rice',
    name: 'Brown Rice',
    category: categoryGrains,
    proteinGrams: 5,
    waterMlPerServing: 130,
    ironMg: 0.8,
    calciumMg: 20,
    servingSize: '1 cup cooked',
    emoji: '🍘',
  ),
  FoodItem(
    id: 'quinoa',
    name: 'Quinoa',
    category: categoryGrains,
    proteinGrams: 8,
    waterMlPerServing: 140,
    ironMg: 2.8,
    calciumMg: 30,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'millet',
    name: 'Millet',
    category: categoryGrains,
    proteinGrams: 6,
    waterMlPerServing: 130,
    ironMg: 1.1,
    calciumMg: 5,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'buckwheat',
    name: 'Buckwheat',
    category: categoryGrains,
    proteinGrams: 6,
    waterMlPerServing: 130,
    ironMg: 1.3,
    calciumMg: 12,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'couscous',
    name: 'Couscous',
    category: categoryGrains,
    proteinGrams: 6,
    waterMlPerServing: 130,
    ironMg: 0.6,
    calciumMg: 15,
    servingSize: '1 cup cooked',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'noodles',
    name: 'Noodles',
    category: categoryGrains,
    proteinGrams: 8,
    waterMlPerServing: 120,
    ironMg: 0.8,
    calciumMg: 20,
    servingSize: '1 cup cooked',
    emoji: '🍜',
  ),
  FoodItem(
    id: 'pasta',
    name: 'Pasta',
    category: categoryGrains,
    proteinGrams: 8,
    waterMlPerServing: 90,
    ironMg: 0.8,
    calciumMg: 10,
    servingSize: '1 cup cooked',
    emoji: '🍝',
  ),
  FoodItem(
    id: 'bread',
    name: 'Bread',
    category: categoryGrains,
    proteinGrams: 3,
    waterMlPerServing: 15,
    ironMg: 0.7,
    calciumMg: 35,
    servingSize: '1 slice',
    emoji: '🍞',
  ),
  FoodItem(
    id: 'roti',
    name: 'Roti',
    category: categoryGrains,
    proteinGrams: 3,
    waterMlPerServing: 12,
    ironMg: 1.1,
    calciumMg: 15,
    servingSize: '1 piece (40g)',
    emoji: '🫓',
  ),
  FoodItem(
    id: 'oats',
    name: 'Oats',
    category: categoryGrains,
    proteinGrams: 6,
    waterMlPerServing: 140,
    ironMg: 1.7,
    calciumMg: 20,
    servingSize: '1 cup cooked',
    emoji: '🥣',
  ),
  FoodItem(
    id: 'flour',
    name: 'Flour',
    category: categoryGrains,
    proteinGrams: 10,
    waterMlPerServing: 12,
    ironMg: 1.2,
    calciumMg: 15,
    servingSize: '100g',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'glass_noodles',
    name: 'Glass Noodles',
    category: categoryGrains,
    proteinGrams: 0,
    waterMlPerServing: 10,
    ironMg: 2.2,
    calciumMg: 25,
    servingSize: '100g',
    emoji: '🍜',
  ),

  // Vegetables
  FoodItem(
    id: 'potato',
    name: 'Potato',
    category: categoryVegetables,
    proteinGrams: 3,
    waterMlPerServing: 130,
    ironMg: 1.2,
    calciumMg: 20,
    servingSize: '1 medium',
    emoji: '🥔',
  ),
  FoodItem(
    id: 'cauliflower',
    name: 'Cauliflower',
    category: categoryVegetables,
    proteinGrams: 2,
    waterMlPerServing: 85,
    ironMg: 0.4,
    calciumMg: 25,
    servingSize: '1 cup',
    emoji: '🥦',
  ),
  FoodItem(
    id: 'broccoli',
    name: 'Broccoli',
    category: categoryVegetables,
    proteinGrams: 3,
    waterMlPerServing: 85,
    ironMg: 0.7,
    calciumMg: 45,
    servingSize: '1 cup',
    emoji: '🥦',
  ),
  FoodItem(
    id: 'cabbage',
    name: 'Cabbage',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 70,
    ironMg: 0.4,
    calciumMg: 30,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'carrots',
    name: 'Carrots',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 88,
    ironMg: 0.3,
    calciumMg: 35,
    servingSize: '100g',
    emoji: '🥕',
  ),
  FoodItem(
    id: 'radish',
    name: 'Radish',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 110,
    ironMg: 0.4,
    calciumMg: 30,
    servingSize: '1 cup sliced',
    emoji: '🌱',
  ),
  FoodItem(
    id: 'bok_choy',
    name: 'Bok Choy',
    category: categoryVegetables,
    proteinGrams: 2,
    waterMlPerServing: 75,
    ironMg: 0.6,
    calciumMg: 75,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'wombok',
    name: 'Wombok',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 75,
    ironMg: 0.2,
    calciumMg: 60,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'capsicum',
    name: 'Capsicum',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 90,
    ironMg: 0.4,
    calciumMg: 10,
    servingSize: '1 medium',
    emoji: '🫑',
  ),
  FoodItem(
    id: 'kale',
    name: 'Kale',
    category: categoryVegetables,
    proteinGrams: 3,
    waterMlPerServing: 75,
    ironMg: 1.1,
    calciumMg: 50,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'eggplant',
    name: 'Eggplant',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 85,
    ironMg: 0.2,
    calciumMg: 10,
    servingSize: '1 cup',
    emoji: '🍆',
  ),
  FoodItem(
    id: 'brussel_sprouts',
    name: 'Brussel Sprouts',
    category: categoryVegetables,
    proteinGrams: 3,
    waterMlPerServing: 80,
    ironMg: 1.2,
    calciumMg: 35,
    servingSize: '1 cup',
    emoji: '🥦',
  ),
  FoodItem(
    id: 'cucumber',
    name: 'Cucumber',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 115,
    ironMg: 0.8,
    calciumMg: 30,
    servingSize: '1 medium',
    emoji: '🥒',
  ),
  FoodItem(
    id: 'zucchini',
    name: 'Zucchini',
    category: categoryVegetables,
    proteinGrams: 2,
    waterMlPerServing: 90,
    ironMg: 0.7,
    calciumMg: 30,
    servingSize: '1 medium',
    emoji: '🥒',
  ),
  FoodItem(
    id: 'olives',
    name: 'Olives',
    category: categoryVegetables,
    proteinGrams: 0,
    waterMlPerServing: 15,
    ironMg: 1.4,
    calciumMg: 35,
    servingSize: '10 olives',
    emoji: '🫒',
  ),
  FoodItem(
    id: 'tomatoes',
    name: 'Tomatoes',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 120,
    ironMg: 0.3,
    calciumMg: 10,
    servingSize: '1 medium',
    emoji: '🍅',
  ),
  FoodItem(
    id: 'cherry_tomatoes',
    name: 'Cherry Tomatoes',
    category: categoryVegetables,
    proteinGrams: 2,
    waterMlPerServing: 130,
    ironMg: 0.4,
    calciumMg: 15,
    servingSize: '1 cup',
    emoji: '🍅',
  ),
  FoodItem(
    id: 'lettuce',
    name: 'Lettuce',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 70,
    ironMg: 0.4,
    calciumMg: 15,
    servingSize: '1 cup',
    emoji: '🥬',
  ),
  FoodItem(
    id: 'pickles',
    name: 'Pickles',
    category: categoryVegetables,
    proteinGrams: 0,
    waterMlPerServing: 25,
    ironMg: 0.4,
    calciumMg: 60,
    servingSize: '4 spears',
    emoji: '🥒',
  ),
  FoodItem(
    id: 'spinach',
    name: 'Spinach',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 27,
    ironMg: 0.8,
    calciumMg: 30,
    servingSize: '1 cup',
    emoji: '🥬',
  ),

  // Fungi
  FoodItem(
    id: 'mushroom',
    name: 'Mushroom',
    category: categoryFungi,
    proteinGrams: 3,
    waterMlPerServing: 85,
    ironMg: 0.4,
    calciumMg: 3,
    servingSize: '1 cup',
    emoji: '🍄',
  ),
  FoodItem(
    id: 'lions_mane_mushroom',
    name: "Lion's Mane Mushroom",
    category: categoryFungi,
    proteinGrams: 2.5,
    waterMlPerServing: 90,
    ironMg: 0.5,
    calciumMg: 5,
    servingSize: '100g',
    emoji: '🍄',
  ),

  // Fruits
  FoodItem(
    id: 'apple',
    name: 'Apple',
    category: categoryFruits,
    proteinGrams: 0,
    waterMlPerServing: 130,
    ironMg: 0.2,
    calciumMg: 10,
    servingSize: '1 medium',
    emoji: '🍎',
  ),
  FoodItem(
    id: 'banana',
    name: 'Banana',
    category: categoryFruits,
    proteinGrams: 1,
    waterMlPerServing: 75,
    ironMg: 0.3,
    calciumMg: 5,
    servingSize: '1 medium',
    emoji: '🍌',
  ),
  FoodItem(
    id: 'strawberries',
    name: 'Strawberries',
    category: categoryFruits,
    proteinGrams: 1,
    waterMlPerServing: 140,
    ironMg: 0.6,
    calciumMg: 25,
    servingSize: '1 cup',
    emoji: '🍓',
  ),
  FoodItem(
    id: 'blueberries',
    name: 'Blueberries',
    category: categoryFruits,
    proteinGrams: 1,
    waterMlPerServing: 120,
    ironMg: 0.4,
    calciumMg: 10,
    servingSize: '1 cup',
    emoji: '🫐',
  ),
  FoodItem(
    id: 'blackberries',
    name: 'Blackberries',
    category: categoryFruits,
    proteinGrams: 2,
    waterMlPerServing: 130,
    ironMg: 0.9,
    calciumMg: 40,
    servingSize: '1 cup',
    emoji: '🫐',
  ),
  FoodItem(
    id: 'boysenberries',
    name: 'Boysenberries',
    category: categoryFruits,
    proteinGrams: 2,
    waterMlPerServing: 130,
    ironMg: 1.1,
    calciumMg: 35,
    servingSize: '1 cup',
    emoji: '🫐',
  ),
  FoodItem(
    id: 'mixed_berries',
    name: 'Mixed Berries',
    category: categoryFruits,
    proteinGrams: 1,
    waterMlPerServing: 130,
    ironMg: 0.6,
    calciumMg: 25,
    servingSize: '1 cup',
    emoji: '🫐',
  ),
  FoodItem(
    id: 'kiwifruit',
    name: 'Kiwifruit',
    category: categoryFruits,
    proteinGrams: 1,
    waterMlPerServing: 75,
    ironMg: 0.2,
    calciumMg: 25,
    servingSize: '1 medium',
    emoji: '🥝',
  ),
  FoodItem(
    id: 'dragonfruit',
    name: 'Dragonfruit',
    category: categoryFruits,
    proteinGrams: 1,
    waterMlPerServing: 200,
    ironMg: 1,
    calciumMg: 20,
    servingSize: '1 medium',
    emoji: '🍈',
  ),
  FoodItem(
    id: 'pineapple',
    name: 'Pineapple',
    category: categoryFruits,
    proteinGrams: 1,
    waterMlPerServing: 140,
    ironMg: 0.5,
    calciumMg: 20,
    servingSize: '1 cup',
    emoji: '🍍',
  ),
  FoodItem(
    id: 'fruits',
    name: 'Fruits',
    category: categoryFruits,
    proteinGrams: 1,
    waterMlPerServing: 85,
    ironMg: 0.3,
    calciumMg: 10,
    servingSize: '1 medium',
    emoji: '🍎',
  ),
  FoodItem(
    id: 'avocado',
    name: 'Avocado',
    category: categoryFruits,
    proteinGrams: 4,
    waterMlPerServing: 146,
    ironMg: 1.1,
    calciumMg: 25,
    servingSize: '1 medium',
    emoji: '🥑',
  ),

  // Nuts & Seeds
  FoodItem(
    id: 'nuts_seeds',
    name: 'Nuts & Seeds',
    category: categoryNutsSeeds,
    proteinGrams: 6,
    waterMlPerServing: 2,
    ironMg: 1.5,
    calciumMg: 50,
    servingSize: '30g (1 oz)',
    emoji: '🥜',
  ),
  FoodItem(
    id: 'almonds',
    name: 'Almonds',
    category: categoryNutsSeeds,
    proteinGrams: 6,
    waterMlPerServing: 2,
    ironMg: 1.1,
    calciumMg: 75,
    servingSize: '30g (1 oz)',
    emoji: '🌰',
  ),
  FoodItem(
    id: 'peanuts',
    name: 'Peanuts',
    category: categoryNutsSeeds,
    proteinGrams: 7,
    waterMlPerServing: 2,
    ironMg: 1.4,
    calciumMg: 30,
    servingSize: '30g (1 oz)',
    emoji: '🥜',
  ),
  FoodItem(
    id: 'peanut_butter',
    name: 'Peanut Butter',
    category: categoryNutsSeeds,
    proteinGrams: 8,
    waterMlPerServing: 2,
    ironMg: 0.6,
    calciumMg: 15,
    servingSize: '2 tbsp',
    emoji: '🥜',
  ),
  FoodItem(
    id: 'cashews',
    name: 'Cashews',
    category: categoryNutsSeeds,
    proteinGrams: 5,
    waterMlPerServing: 2,
    ironMg: 1.9,
    calciumMg: 10,
    servingSize: '30g (1 oz)',
    emoji: '🌰',
  ),
  FoodItem(
    id: 'pistachios',
    name: 'Pistachios',
    category: categoryNutsSeeds,
    proteinGrams: 6,
    waterMlPerServing: 2,
    ironMg: 1.1,
    calciumMg: 30,
    servingSize: '30g (1 oz)',
    emoji: '🌰',
  ),
  FoodItem(
    id: 'macadamias',
    name: 'Macadamias',
    category: categoryNutsSeeds,
    proteinGrams: 2,
    waterMlPerServing: 2,
    ironMg: 1.1,
    calciumMg: 25,
    servingSize: '30g (1 oz)',
    emoji: '🌰',
  ),
  FoodItem(
    id: 'brazil_nuts',
    name: 'Brazil Nuts',
    category: categoryNutsSeeds,
    proteinGrams: 4,
    waterMlPerServing: 2,
    ironMg: 0.7,
    calciumMg: 50,
    servingSize: '30g (1 oz)',
    emoji: '🌰',
  ),
  FoodItem(
    id: 'pecans',
    name: 'Pecans',
    category: categoryNutsSeeds,
    proteinGrams: 3,
    waterMlPerServing: 2,
    ironMg: 0.8,
    calciumMg: 20,
    servingSize: '30g (1 oz)',
    emoji: '🌰',
  ),
  FoodItem(
    id: 'walnuts',
    name: 'Walnuts',
    category: categoryNutsSeeds,
    proteinGrams: 4.5,
    waterMlPerServing: 1,
    ironMg: 0.9,
    calciumMg: 30,
    servingSize: '30g (1 oz)',
    emoji: '🌰',
  ),
  FoodItem(
    id: 'flaxseeds',
    name: 'Flaxseeds',
    category: categoryNutsSeeds,
    proteinGrams: 5,
    waterMlPerServing: 2,
    ironMg: 1.7,
    calciumMg: 75,
    servingSize: '30g (1 oz)',
    emoji: '🌾',
  ),
  FoodItem(
    id: 'chia_seeds',
    name: 'Chia Seeds',
    category: categoryNutsSeeds,
    proteinGrams: 5,
    waterMlPerServing: 2,
    ironMg: 2.3,
    calciumMg: 190,
    servingSize: '30g (1 oz)',
    emoji: '🌱',
  ),
  FoodItem(
    id: 'sunflower_seeds',
    name: 'Sunflower Seeds',
    category: categoryNutsSeeds,
    proteinGrams: 6,
    waterMlPerServing: 2,
    ironMg: 1.6,
    calciumMg: 25,
    servingSize: '30g (1 oz)',
    emoji: '🌻',
  ),
  FoodItem(
    id: 'pumpkin_seeds',
    name: 'Pumpkin Seeds',
    category: categoryNutsSeeds,
    proteinGrams: 9,
    waterMlPerServing: 2,
    ironMg: 2.5,
    calciumMg: 15,
    servingSize: '30g (1 oz)',
    emoji: '🎃',
  ),

  // Other
  FoodItem(
    id: 'nutritional_yeast',
    name: 'Nutritional Yeast',
    category: categoryOther,
    proteinGrams: 3,
    waterMlPerServing: 0,
    ironMg: 0.5,
    calciumMg: 5,
    servingSize: '1 tbsp',
    emoji: '🧀',
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

/// Drinks whose tannins and polyphenols reduce iron absorption from a meal.
const Set<String> ironInhibitingDrinkIds = {
  'coffee',
  'espresso',
  'tea',
  'oat_milk_latte',
  'milk_tea',
};

/// Foods excluded when the user selects a vegan or allium vegan diet.
const Set<String> lactoOvoOnlyFoodIds = {
  'egg',
  'greek_yoghurt',
  'milk',
  'paneer',
  'cottage_cheese',
  'cheese',
  'whey_smoothie',
  'quorn_chicken_pieces',
};

const List<FoodItem> veganOnlyFoods = [
  FoodItem(
    id: 'pea_protein_smoothie',
    name: 'Pea Protein Smoothie',
    category: categoryProteinBoosters,
    proteinGrams: 22,
    waterMlPerServing: 200,
    ironMg: 5.9,
    calciumMg: 320,
    servingSize: '1 scoop + soy milk',
    emoji: '🥤',
  ),
];

/// Alliums shown only for allium vegetarian and allium vegan diets.
const List<FoodItem> alliumOnlyFoods = [
  FoodItem(
    id: 'onions',
    name: 'Onions',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 130,
    ironMg: 0.3,
    calciumMg: 25,
    servingSize: '1 medium',
    emoji: '🧅',
  ),
  FoodItem(
    id: 'garlic',
    name: 'Garlic',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 5,
    ironMg: 0.2,
    calciumMg: 15,
    servingSize: '3 cloves',
    emoji: '🧄',
  ),
  FoodItem(
    id: 'leeks',
    name: 'Leeks',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 75,
    ironMg: 1.9,
    calciumMg: 55,
    servingSize: '1 cup',
    emoji: '🧅',
  ),
  FoodItem(
    id: 'shallots',
    name: 'Shallots',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 20,
    ironMg: 0.6,
    calciumMg: 20,
    servingSize: '2 shallots',
    emoji: '🧅',
  ),
  FoodItem(
    id: 'chives',
    name: 'Chives',
    category: categoryVegetables,
    proteinGrams: 0,
    waterMlPerServing: 5,
    calciumMg: 3,
    servingSize: '1 tbsp',
    emoji: '🌿',
  ),
  FoodItem(
    id: 'spring_onions',
    name: 'Spring Onions',
    category: categoryVegetables,
    proteinGrams: 1,
    waterMlPerServing: 25,
    ironMg: 0.4,
    calciumMg: 20,
    servingSize: '2 stalks',
    emoji: '🧅',
  ),
];

bool includesDairyAndEggs(DietType diet) =>
    diet == DietType.lactoOvo || diet == DietType.alliumVegetarian;

bool includesAlliums(DietType diet) =>
    diet == DietType.alliumVegetarian || diet == DietType.alliumVegan;

/// Preset custom foods merged into My Foods on first launch.
const List<FoodItem> defaultPresetCustomFoods = [
  FoodItem(
    id: 'chonghua_dumplings',
    name: 'Chonghua Dumplings',
    category: categoryOther,
    proteinGrams: 5.2,
    waterMlPerServing: 51,
    ironMg: 1.7,
    calciumMg: 46,
    servingSize: '5 dumplings (100g)',
    emoji: '🥟',
    isCustom: true,
    components: [
      CustomFoodComponent(sourceFoodId: 'flour', fraction: 0.35),
      CustomFoodComponent(sourceFoodId: 'cabbage', fraction: 0.36),
      CustomFoodComponent(sourceFoodId: 'carrots', fraction: 0.15),
      CustomFoodComponent(sourceFoodId: 'glass_noodles', fraction: 0.10),
      CustomFoodComponent(sourceFoodId: 'beancurd_skin', fraction: 0.16),
      CustomFoodComponent(sourceFoodId: 'soy_meat', fraction: 0.08),
    ],
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
  if (includesDairyAndEggs(diet)) {
    base = List<FoodItem>.from(defaultFoods);
  } else {
    base = [
      ...defaultFoods.where((f) => !lactoOvoOnlyFoodIds.contains(f.id)),
      ...veganOnlyFoods,
    ];
  }

  final withAlliums = includesAlliums(diet)
      ? _insertAfterId(base, 'pickles', alliumOnlyFoods)
      : base;

  if (!includeBeverages) return withAlliums;

  final withDairyDrinks = _insertAfterFirstFound(
    withAlliums,
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
  final double ironMg;
  final double calciumMg;

  const CustomFoodTotals({
    required this.proteinGrams,
    required this.waterMl,
    this.ironMg = 0,
    this.calciumMg = 0,
  });
}

CustomFoodTotals computeCustomFoodTotals(
  List<CustomFoodComponent> components, {
  required DietType diet,
  required bool waterTrackerEnabled,
}) {
  var protein = 0.0;
  var water = 0.0;
  var iron = 0.0;
  var calcium = 0.0;
  for (final component in components) {
    final food = findBaseFood(
      component.sourceFoodId,
      diet: diet,
      waterTrackerEnabled: waterTrackerEnabled,
    );
    if (food == null) continue;
    protein += food.proteinGrams * component.fraction;
    water += food.waterMlPerServing * component.fraction;
    iron += food.ironMg * component.fraction;
    calcium += food.calciumMg * component.fraction;
  }
  return CustomFoodTotals(
    proteinGrams: protein,
    waterMl: water,
    ironMg: iron,
    calciumMg: calcium,
  );
}
