import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart';
import 'food_data.dart';
import 'storage.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  final StorageService _storage = StorageService();
  Timer? _resetTimer;
  late DateTime _currentEffectiveDate;

  bool _disclaimerAccepted = false;
  int _dailyGoal = 0;
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  MeasurementSystem _measurementSystem = MeasurementSystem.metric;
  DietType _dietType = DietType.lactoOvo;
  bool _waterTrackerEnabled = false;
  int _dailyWaterGoalMl = 2000;
  DateTime _viewDate = effectiveDate();
  List<LogEntry> _viewLog = [];
  List<FoodItem> _customFoods = [];
  Set<String> _unlockedAchievements = {};
  final List<Achievement> _pendingAchievements = [];

  /// The "logical" date for tracking purposes.
  /// Before 3 AM local time, entries still belong to the previous day.
  static DateTime effectiveDate() {
    final now = DateTime.now();
    if (now.hour < 3) {
      return DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
    }
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get disclaimerAccepted => _disclaimerAccepted;
  int get dailyGoal => _dailyGoal;
  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  MeasurementSystem get measurementSystem => _measurementSystem;
  DietType get dietType => _dietType;
  bool get waterTrackerEnabled => _waterTrackerEnabled;
  int get dailyWaterGoalMl => _dailyWaterGoalMl;
  DateTime get viewDate => _viewDate;
  bool get isViewingToday => isSameDay(_viewDate, _currentEffectiveDate);
  bool get canViewNextDay => !isViewingToday;
  List<LogEntry> get viewLog => List.unmodifiable(_viewLog);
  List<FoodItem> get customFoods => List.unmodifiable(_customFoods);
  Set<String> get unlockedAchievements =>
      Set.unmodifiable(_unlockedAchievements);
  List<FoodItem> get allFoods => [
        ...foodsForDiet(_dietType, includeBeverages: _waterTrackerEnabled),
        ..._customFoods,
      ];

  double get viewProtein =>
      _viewLog.fold(0.0, (sum, e) => sum + e.totalProtein);
  double get viewWaterMl =>
      _viewLog.fold(0.0, (sum, e) => sum + e.totalWaterMl);
  double get viewProgressPercent =>
      _dailyGoal > 0 ? (viewProtein / _dailyGoal).clamp(0.0, 1.0) : 0.0;
  double get viewWaterProgressPercent => _dailyWaterGoalMl > 0
      ? (viewWaterMl / _dailyWaterGoalMl).clamp(0.0, 1.0)
      : 0.0;
  bool get viewGoalReached => _dailyGoal > 0 && viewProtein >= _dailyGoal;
  bool get viewWaterGoalReached =>
      _dailyWaterGoalMl > 0 && viewWaterMl >= _dailyWaterGoalMl;

  Achievement? get pendingAchievement =>
      _pendingAchievements.isNotEmpty ? _pendingAchievements.first : null;

  Future<void> init() async {
    await _storage.init();
    _disclaimerAccepted = _storage.disclaimerAccepted;
    _dailyGoal = _storage.dailyGoal;
    _themeMode = _storage.themeMode;
    _locale = _parseLocale(_storage.localeCode);
    _measurementSystem = _storage.measurementSystem;
    _dietType = _storage.dietType;
    _waterTrackerEnabled = _storage.waterTrackerEnabled;
    _dailyWaterGoalMl = _storage.dailyWaterGoalMl;
    _customFoods = _storage.customFoods;
    _unlockedAchievements = _storage.unlockedAchievements;
    _currentEffectiveDate = effectiveDate();
    _viewDate = _currentEffectiveDate;
    _loadViewLog();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextReset();
    notifyListeners();
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLogIfDateChanged();
      _scheduleNextReset();
    }
  }

  void _loadViewLog() {
    _viewLog = _storage.getDailyLog(_viewDate);
  }

  void _refreshLogIfDateChanged() {
    final newDate = effectiveDate();
    if (!isSameDay(newDate, _currentEffectiveDate)) {
      final wasViewingToday = isSameDay(_viewDate, _currentEffectiveDate);
      _currentEffectiveDate = newDate;
      if (wasViewingToday) {
        _viewDate = newDate;
        _loadViewLog();
      }
      notifyListeners();
    }
  }

  void goToPreviousDay() {
    _viewDate = dateOnly(_viewDate).subtract(const Duration(days: 1));
    _loadViewLog();
    notifyListeners();
  }

  void goToNextDay() {
    if (!canViewNextDay) return;
    final next = dateOnly(_viewDate).add(const Duration(days: 1));
    _viewDate = next.isAfter(_currentEffectiveDate) ? _currentEffectiveDate : next;
    _loadViewLog();
    notifyListeners();
  }

  List<LogEntry> _todayLogFromStorage() =>
      List<LogEntry>.from(_storage.getDailyLog(_currentEffectiveDate));

  Future<void> _saveTodayLog(List<LogEntry> log) async {
    await _storage.saveDailyLog(_currentEffectiveDate, log);
    if (isViewingToday) {
      _viewLog = log;
    }
  }

  void _scheduleNextReset() {
    _resetTimer?.cancel();
    final now = DateTime.now();
    var next3am = DateTime(now.year, now.month, now.day, 3);
    if (!now.isBefore(next3am)) {
      next3am = next3am.add(const Duration(days: 1));
    }
    _resetTimer = Timer(next3am.difference(now), () {
      _refreshLogIfDateChanged();
      _scheduleNextReset();
    });
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

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final code = locale == null
        ? null
        : locale.countryCode != null
            ? '${locale.languageCode}_${locale.countryCode}'
            : locale.languageCode;
    await _storage.setLocaleCode(code);
    notifyListeners();
  }

  Future<void> setMeasurementSystem(MeasurementSystem system) async {
    _measurementSystem = system;
    await _storage.setMeasurementSystem(system);
    notifyListeners();
  }

  Future<void> setDietType(DietType diet) async {
    _dietType = diet;
    await _storage.setDietType(diet);
    notifyListeners();
  }

  Future<void> setWaterTrackerEnabled(bool enabled) async {
    _waterTrackerEnabled = enabled;
    await _storage.setWaterTrackerEnabled(enabled);
    notifyListeners();
  }

  Future<void> setDailyWaterGoalMl(int goalMl) async {
    _dailyWaterGoalMl = goalMl;
    await _storage.setDailyWaterGoalMl(goalMl);
    notifyListeners();
  }

  static Locale? _parseLocale(String? code) {
    if (code == null) return null;
    final parts = code.split('_');
    if (parts.length == 2) return Locale(parts[0], parts[1]);
    return Locale(parts[0]);
  }

  Future<void> addFood(FoodItem food, {double fraction = 1.0}) async {
    _refreshLogIfDateChanged();
    final entry = LogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      food: food,
      timestamp: DateTime.now(),
      fraction: fraction,
    );
    final log = _todayLogFromStorage()..add(entry);
    await _saveTodayLog(log);
    _checkAchievements();
    notifyListeners();
  }

  Future<void> updateEntryFraction(String entryId, double fraction) async {
    if (!isViewingToday) return;
    _refreshLogIfDateChanged();
    final log = _todayLogFromStorage();
    final index = log.indexWhere((e) => e.id == entryId);
    if (index == -1) return;
    log[index] = log[index].copyWith(fraction: fraction);
    await _saveTodayLog(log);
    _checkAchievements();
    notifyListeners();
  }

  Future<void> removeEntry(String entryId) async {
    if (!isViewingToday) return;
    _refreshLogIfDateChanged();
    final log = _todayLogFromStorage()..removeWhere((e) => e.id == entryId);
    await _saveTodayLog(log);
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
    final todayLog = _todayLogFromStorage();
    final todayProtein =
        todayLog.fold(0.0, (sum, e) => sum + e.totalProtein);
    if (!_unlockedAchievements.contains('firstBite') && todayLog.isNotEmpty) {
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
    final today = _currentEffectiveDate;
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
