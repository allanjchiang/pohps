enum MeasurementSystem {
  metric,
  imperial,
}

enum DietType {
  lactoOvo,
  vegan,
}

class FoodItem {
  final String id;
  final String name;
  final String category;
  final double proteinGrams;
  final double waterMlPerServing;
  final String servingSize;
  final String emoji;
  final bool isCustom;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.proteinGrams,
    required this.waterMlPerServing,
    required this.servingSize,
    required this.emoji,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'proteinGrams': proteinGrams,
        'waterMlPerServing': waterMlPerServing,
        'servingSize': servingSize,
        'emoji': emoji,
        'isCustom': isCustom,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        proteinGrams: (json['proteinGrams'] as num).toDouble(),
        waterMlPerServing:
            (json['waterMlPerServing'] as num?)?.toDouble() ?? 0,
        servingSize: json['servingSize'] as String,
        emoji: json['emoji'] as String,
        isCustom: (json['isCustom'] as bool?) ?? false,
      );
}

class LogEntry {
  final String id;
  final FoodItem food;
  final DateTime timestamp;
  final double fraction;

  const LogEntry({
    required this.id,
    required this.food,
    required this.timestamp,
    this.fraction = 1.0,
  });

  double get totalProtein => food.proteinGrams * fraction;

  double get totalWaterMl => food.waterMlPerServing * fraction;

  LogEntry copyWith({double? fraction}) => LogEntry(
        id: id,
        food: food,
        timestamp: timestamp,
        fraction: fraction ?? this.fraction,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'food': food.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'fraction': fraction,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'] as String,
        food: FoodItem.fromJson(json['food'] as Map<String, dynamic>),
        timestamp: DateTime.parse(json['timestamp'] as String),
        fraction: (json['fraction'] as num?)?.toDouble() ??
            (json['quantity'] as num?)?.toDouble() ??
            1.0,
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
