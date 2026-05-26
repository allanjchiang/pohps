import 'package:flutter/material.dart';
import 'models.dart';
import 'food_data.dart';
import 'storage.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool _disclaimerAccepted = false;
  int _dailyGoal = 0;
  ThemeMode _themeMode = ThemeMode.system;
  List<LogEntry> _todayLog = [];
  List<FoodItem> _customFoods = [];
  Set<String> _unlockedAchievements = {};
  final List<Achievement> _pendingAchievements = [];

  bool get disclaimerAccepted => _disclaimerAccepted;
  int get dailyGoal => _dailyGoal;
  ThemeMode get themeMode => _themeMode;
  List<LogEntry> get todayLog => List.unmodifiable(_todayLog);
  List<FoodItem> get customFoods => List.unmodifiable(_customFoods);
  Set<String> get unlockedAchievements =>
      Set.unmodifiable(_unlockedAchievements);
  List<FoodItem> get allFoods => [...defaultFoods, ..._customFoods];

  double get todayProtein =>
      _todayLog.fold(0.0, (sum, e) => sum + e.totalProtein);
  double get progressPercent =>
      _dailyGoal > 0 ? (todayProtein / _dailyGoal).clamp(0.0, 1.0) : 0.0;
  bool get goalReached => _dailyGoal > 0 && todayProtein >= _dailyGoal;

  Achievement? get pendingAchievement =>
      _pendingAchievements.isNotEmpty ? _pendingAchievements.first : null;

  Future<void> init() async {
    await _storage.init();
    _disclaimerAccepted = _storage.disclaimerAccepted;
    _dailyGoal = _storage.dailyGoal;
    _themeMode = _storage.themeMode;
    _customFoods = _storage.customFoods;
    _unlockedAchievements = _storage.unlockedAchievements;
    _todayLog = _storage.getDailyLog(DateTime.now());
    notifyListeners();
  }

  Future<void> acceptDisclaimer() async {
    _disclaimerAccepted = true;
    await _storage.setDisclaimerAccepted(true);
    notifyListeners();
  }

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    await _storage.setDailyGoal(goal);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> addFood(FoodItem food, {double fraction = 1.0}) async {
    final entry = LogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      food: food,
      timestamp: DateTime.now(),
      fraction: fraction,
    );
    _todayLog.add(entry);
    await _storage.saveDailyLog(DateTime.now(), _todayLog);
    _checkAchievements();
    notifyListeners();
  }

  Future<void> updateEntryFraction(String entryId, double fraction) async {
    final index = _todayLog.indexWhere((e) => e.id == entryId);
    if (index == -1) return;
    _todayLog[index] = _todayLog[index].copyWith(fraction: fraction);
    await _storage.saveDailyLog(DateTime.now(), _todayLog);
    _checkAchievements();
    notifyListeners();
  }

  Future<void> removeEntry(String entryId) async {
    _todayLog.removeWhere((e) => e.id == entryId);
    await _storage.saveDailyLog(DateTime.now(), _todayLog);
    notifyListeners();
  }

  Future<void> addCustomFood(FoodItem food) async {
    _customFoods.add(food);
    await _storage.saveCustomFoods(_customFoods);
    if (!_unlockedAchievements.contains('chefsSpecial')) {
      _unlock(AchievementType.chefsSpecial);
    }
    notifyListeners();
  }

  Future<void> removeCustomFood(String foodId) async {
    _customFoods.removeWhere((f) => f.id == foodId);
    await _storage.saveCustomFoods(_customFoods);
    notifyListeners();
  }

  void dismissAchievement() {
    if (_pendingAchievements.isNotEmpty) {
      _pendingAchievements.removeAt(0);
      notifyListeners();
    }
  }

  void _checkAchievements() {
    if (!_unlockedAchievements.contains('firstBite') &&
        _todayLog.isNotEmpty) {
      _unlock(AchievementType.firstBite);
    }
    if (!_unlockedAchievements.contains('halfwayThere') &&
        _dailyGoal > 0 &&
        todayProtein >= _dailyGoal * 0.5) {
      _unlock(AchievementType.halfwayThere);
    }
    if (!_unlockedAchievements.contains('goalGetter') &&
        _dailyGoal > 0 &&
        todayProtein >= _dailyGoal) {
      _unlock(AchievementType.goalGetter);
    }
    if (_dailyGoal > 0 && todayProtein >= _dailyGoal) {
      _checkStreaks();
    }
  }

  void _checkStreaks() {
    int streak = 1;
    final today = DateTime.now();
    for (int i = 1; i <= 30; i++) {
      final date = today.subtract(Duration(days: i));
      final log = _storage.getDailyLog(date);
      final total = log.fold(0.0, (sum, e) => sum + e.totalProtein);
      if (total >= _dailyGoal) {
        streak++;
      } else {
        break;
      }
    }
    if (streak >= 3 && !_unlockedAchievements.contains('threeDayStreak')) {
      _unlock(AchievementType.threeDayStreak);
    }
    if (streak >= 7 && !_unlockedAchievements.contains('weekWarrior')) {
      _unlock(AchievementType.weekWarrior);
    }
    if (streak >= 30 && !_unlockedAchievements.contains('monthStrong')) {
      _unlock(AchievementType.monthStrong);
    }
  }

  void _unlock(AchievementType type) {
    final name = type.name;
    if (_unlockedAchievements.contains(name)) return;
    _unlockedAchievements.add(name);
    _storage.saveUnlockedAchievements(_unlockedAchievements);
    final achievement = allAchievements.firstWhere((a) => a.type == type);
    _pendingAchievements.add(achievement);
  }
}
