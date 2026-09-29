enum MeasurementSystem {
  metric,
  imperial,
}

enum DietType {
  lactoOvo,
  vegan,
  alliumVegetarian,
  alliumVegan,
}

/// How the user felt about a logged food. Order is left to right on the card.
enum FoodMood {
  sad,
  neutral,
  happy;

  String get assetPath => 'assets/moods/$name.png';

  static FoodMood? fromName(String? name) =>
      values.where((m) => m.name == name).firstOrNull;
}

enum TrendPeriod {
  week,
  month,
  year,
  yearToDate,
}

class CustomFoodComponent {
  final String sourceFoodId;
  final double fraction;

  const CustomFoodComponent({
    required this.sourceFoodId,
    required this.fraction,
  });

  Map<String, dynamic> toJson() => {
        'sourceFoodId': sourceFoodId,
        'fraction': fraction,
      };

  factory CustomFoodComponent.fromJson(Map<String, dynamic> json) =>
      CustomFoodComponent(
        sourceFoodId: json['sourceFoodId'] as String,
        fraction: (json['fraction'] as num).toDouble(),
      );

  CustomFoodComponent copyWith({double? fraction}) => CustomFoodComponent(
        sourceFoodId: sourceFoodId,
        fraction: fraction ?? this.fraction,
      );
}

class FoodItem {
  final String id;
  final String name;
  final String category;
  final double proteinGrams;
  final double waterMlPerServing;
  final double ironMg;
  final double calciumMg;
  final String servingSize;
  final String emoji;
  final bool isCustom;
  final List<CustomFoodComponent>? components;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.proteinGrams,
    required this.waterMlPerServing,
    this.ironMg = 0,
    this.calciumMg = 0,
    required this.servingSize,
    required this.emoji,
    this.isCustom = false,
    this.components,
  });

  bool get hasComponents => components != null && components!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'proteinGrams': proteinGrams,
        'waterMlPerServing': waterMlPerServing,
        'ironMg': ironMg,
        'calciumMg': calciumMg,
        'servingSize': servingSize,
        'emoji': emoji,
        'isCustom': isCustom,
        if (components != null)
          'components': components!.map((c) => c.toJson()).toList(),
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        proteinGrams: (json['proteinGrams'] as num).toDouble(),
        waterMlPerServing:
            (json['waterMlPerServing'] as num?)?.toDouble() ?? 0,
        ironMg: (json['ironMg'] as num?)?.toDouble() ?? 0,
        calciumMg: (json['calciumMg'] as num?)?.toDouble() ?? 0,
        servingSize: json['servingSize'] as String,
        emoji: json['emoji'] as String,
        isCustom: (json['isCustom'] as bool?) ?? false,
        components: (json['components'] as List<dynamic>?)
            ?.map((e) => CustomFoodComponent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class LogEntry {
  final String id;
  final FoodItem food;
  final DateTime timestamp;
  final double fraction;
  final FoodMood? mood;

  const LogEntry({
    required this.id,
    required this.food,
    required this.timestamp,
    this.fraction = 1.0,
    this.mood,
  });

  double get totalProtein => food.proteinGrams * fraction;

  double get totalWaterMl => food.waterMlPerServing * fraction;

  double get totalIronMg => food.ironMg * fraction;

  double get totalCalciumMg => food.calciumMg * fraction;

  LogEntry copyWith({double? fraction, DateTime? timestamp}) => LogEntry(
        id: id,
        food: food,
        timestamp: timestamp ?? this.timestamp,
        fraction: fraction ?? this.fraction,
        mood: mood,
      );

  /// Separate from [copyWith] so the mood can be cleared back to null.
  LogEntry withMood(FoodMood? mood) => LogEntry(
        id: id,
        food: food,
        timestamp: timestamp,
        fraction: fraction,
        mood: mood,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'food': food.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'fraction': fraction,
        if (mood != null) 'mood': mood!.name,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'] as String,
        food: FoodItem.fromJson(json['food'] as Map<String, dynamic>),
        timestamp: DateTime.parse(json['timestamp'] as String),
        fraction: (json['fraction'] as num?)?.toDouble() ??
            (json['quantity'] as num?)?.toDouble() ??
            1.0,
        mood: FoodMood.fromName(json['mood'] as String?),
      );
}

enum AchievementType {
  firstBite,
  halfwayThere,
  goalGetter,
  chefsSpecial,
  threeDayStreak,
  weekWarrior,
  monthStrong,
}

class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final String emoji;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

const List<Achievement> allAchievements = [
  Achievement(
    type: AchievementType.firstBite,
    title: 'First Bite',
    description: 'You logged your first protein source!',
    emoji: '🌱',
  ),
  Achievement(
    type: AchievementType.halfwayThere,
    title: 'Halfway There',
    description: 'You reached 50% of your daily protein goal!',
    emoji: '⭐',
  ),
  Achievement(
    type: AchievementType.goalGetter,
    title: 'Goal Getter',
    description: 'You met your daily protein goal!',
    emoji: '🏆',
  ),
  Achievement(
    type: AchievementType.chefsSpecial,
    title: "Chef's Special",
    description: 'You created your first custom food!',
    emoji: '👨‍🍳',
  ),
  Achievement(
    type: AchievementType.threeDayStreak,
    title: 'Three-Day Streak',
    description: 'You met your protein goal 3 days in a row!',
    emoji: '🔥',
  ),
  Achievement(
    type: AchievementType.weekWarrior,
    title: 'Week Warrior',
    description: 'You met your protein goal 7 days in a row!',
    emoji: '💪',
  ),
  Achievement(
    type: AchievementType.monthStrong,
    title: 'Month Strong',
    description: 'You met your protein goal 30 days in a row!',
    emoji: '🌟',
  ),
];
