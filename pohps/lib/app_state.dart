import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'models.dart';
import 'food_data.dart';
import 'services/backup_service.dart';
import 'services/statistics_service.dart';
import 'services/subscription_service.dart';
import 'storage.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  final StorageService _storage = StorageService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  late final StatisticsService statistics = StatisticsService(_storage);
  Timer? _resetTimer;
  late DateTime _currentEffectiveDate;

  static const int trialDurationDays = 30;

  DateTime? _trialStartDate;
  SubscriptionPlan? _activePlan;
  bool _entitlementRestoring = true;
  bool _purchasePending = false;
  String? _lastPurchaseError;
  List<ProductDetails> _products = [];

  bool _disclaimerAccepted = false;
  int _dailyGoal = 0;
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  MeasurementSystem _measurementSystem = MeasurementSystem.metric;
  DietType _dietType = DietType.lactoOvo;
  bool _waterTrackerEnabled = false;
  int _dailyWaterGoalMl = 2000;
  Map<String, double> _proteinOverrides = {};
  DateTime _viewDate = effectiveDate();
  List<LogEntry> _viewLog = [];
  List<FoodItem> _customFoods = [];
  List<String> _favoriteFoodIds = [];
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
  Map<String, double> get proteinOverrides =>
      Map.unmodifiable(_proteinOverrides);
  DateTime get viewDate => _viewDate;
  bool get isViewingToday => isSameDay(_viewDate, _currentEffectiveDate);
  bool get canViewNextDay => !isViewingToday;
  List<LogEntry> get viewLog => List.unmodifiable(_viewLog);
  List<FoodItem> get customFoods => List.unmodifiable(_customFoods);
  List<String> get favoriteFoodIds => List.unmodifiable(_favoriteFoodIds);
  Set<String> get unlockedAchievements =>
      Set.unmodifiable(_unlockedAchievements);

  bool isFavorite(String foodId) => _favoriteFoodIds.contains(foodId);

  List<FoodItem> get favoriteFoods {
    final byId = {for (final f in allFoods) f.id: f};
    return _favoriteFoodIds
        .where(byId.containsKey)
        .map((id) => byId[id]!)
        .toList();
  }

  bool isProteinEditableFood(FoodItem food) =>
      food.category != categoryFruits && food.category != categoryVegetables;

  double proteinForFood(FoodItem food) =>
      _proteinOverrides[food.id] ?? food.proteinGrams;

  List<FoodItem> get baseFoods =>
      _applyProteinOverrides(foodsForDiet(_dietType, includeBeverages: _waterTrackerEnabled));

  List<FoodItem> get allFoods => [
        ...baseFoods,
        ..._customFoods,
      ];

  FoodItem? baseFoodById(String id) {
    for (final f in baseFoods) {
      if (f.id == id) return f;
    }
    return null;
  }

  List<FoodItem> _applyProteinOverrides(List<FoodItem> foods) {
    if (_proteinOverrides.isEmpty) return foods;
    return foods.map((food) {
      final override = _proteinOverrides[food.id];
      if (override == null) return food;
      return FoodItem(
        id: food.id,
        name: food.name,
        category: food.category,
        proteinGrams: override,
        waterMlPerServing: food.waterMlPerServing,
        servingSize: food.servingSize,
        emoji: food.emoji,
        isCustom: food.isCustom,
        components: food.components,
      );
    }).toList();
  }

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

  // ── POHPS Pro trial / entitlement ─────────────────────────────────────

  DateTime? get trialStartDate => _trialStartDate;
  bool get hasEverStartedTrial => _trialStartDate != null;
  DateTime? get trialEndDate =>
      _trialStartDate?.add(const Duration(days: trialDurationDays));

  bool get isTrialActive {
    final end = trialEndDate;
    return end != null && DateTime.now().isBefore(end);
  }

  int get trialDaysRemaining {
    final end = trialEndDate;
    if (end == null) return 0;
    final remainingHours = end.difference(DateTime.now()).inHours;
    if (remainingHours <= 0) return 0;
    return (remainingHours / 24).ceil().clamp(0, trialDurationDays);
  }

  SubscriptionPlan? get activePlan => _activePlan;
  bool get isSubscribed => _activePlan != null;

  /// Debug builds always have access so Statistics can be developed and
  /// tested without burning through the local trial or a real purchase.
  bool get hasStatisticsAccess =>
      kDebugMode || isTrialActive || isSubscribed;

  /// True until the first store query/restore on launch resolves. Lets the
  /// UI avoid flashing a paywall before we know the real entitlement.
  bool get entitlementRestoring => _entitlementRestoring;
  bool get purchasePending => _purchasePending;
  String? get lastPurchaseError => _lastPurchaseError;
  List<ProductDetails> get availableProducts => List.unmodifiable(_products);

  ProductDetails? productFor(SubscriptionPlan plan) {
    final id = switch (plan) {
      SubscriptionPlan.monthly => SubscriptionService.monthlyProductId,
      SubscriptionPlan.annual => SubscriptionService.annualProductId,
    };
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  static SubscriptionPlan? _planForProductId(String? id) => switch (id) {
        SubscriptionService.monthlyProductId => SubscriptionPlan.monthly,
        SubscriptionService.annualProductId => SubscriptionPlan.annual,
        _ => null,
      };

  Future<void> init() async {
    await _storage.init();
    _loadFromStorage();
    await _seedPresetCustomFoods();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextReset();
    _initSubscriptions();
    notifyListeners();
  }

  void _initSubscriptions() {
    _subscriptionService.listen(
      onUpdate: _onPurchaseUpdate,
      onError: _onPurchaseError,
    );
    unawaited(_refreshEntitlement());
  }

  Future<void> _refreshEntitlement() async {
    try {
      if (await _subscriptionService.isAvailable()) {
        _products = await _subscriptionService.queryProducts();
        await _subscriptionService.restorePurchases();
      }
    } catch (_) {
      // Offline or store unreachable — keep the cached optimistic
      // entitlement rather than revoking it. Only a successful, contradicting
      // restore result (handled in _onPurchaseUpdate) changes _activePlan.
    } finally {
      _entitlementRestoring = false;
      notifyListeners();
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final plan = _planForProductId(purchase.productID);
          if (plan != null) {
            _activePlan = plan;
            await _storage.setCachedActiveProductId(purchase.productID);
          }
          _purchasePending = false;
          _lastPurchaseError = null;
          await _subscriptionService.completePurchase(purchase);
          break;
        case PurchaseStatus.error:
          _purchasePending = false;
          _lastPurchaseError = purchase.error?.message;
          break;
        case PurchaseStatus.canceled:
          _purchasePending = false;
          break;
      }
    }
    notifyListeners();
  }

  void _onPurchaseError(Object error) {
    _purchasePending = false;
    _entitlementRestoring = false;
    notifyListeners();
  }

  /// Starts the local 30-day trial. No credit card, no store interaction —
  /// idempotent so it can't be repeatedly reset by re-tapping the CTA.
  Future<void> startFreeTrial() async {
    if (_trialStartDate != null) return;
    final now = DateTime.now();
    _trialStartDate = now;
    await _storage.setTrialStartDate(now);
    notifyListeners();
  }

  Future<void> purchase(ProductDetails product) async {
    _lastPurchaseError = null;
    _purchasePending = true;
    notifyListeners();
    final started = await _subscriptionService.buy(product);
    if (!started) {
      _purchasePending = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchasesManually() async {
    _purchasePending = true;
    notifyListeners();
    try {
      await _subscriptionService.restorePurchases();
    } finally {
      _purchasePending = false;
      notifyListeners();
    }
  }

  Future<void> _seedPresetCustomFoods() async {
    final existingIds = _customFoods.map((food) => food.id).toSet();
    final missing = defaultPresetCustomFoods
        .where((food) => !existingIds.contains(food.id))
        .toList();
    if (missing.isEmpty) return;
    _customFoods = [..._customFoods, ...missing];
    await _storage.saveCustomFoods(_customFoods);
  }

  void _loadFromStorage() {
    _disclaimerAccepted = _storage.disclaimerAccepted;
    _dailyGoal = _storage.dailyGoal;
    _themeMode = _storage.themeMode;
    _locale = _parseLocale(_storage.localeCode);
    _measurementSystem = _storage.measurementSystem;
    _dietType = _storage.dietType;
    _waterTrackerEnabled = _storage.waterTrackerEnabled;
    _dailyWaterGoalMl = _storage.dailyWaterGoalMl;
    _proteinOverrides = _storage.proteinOverrides;
    _customFoods = _storage.customFoods;
    _favoriteFoodIds = _storage.favoriteFoodIds;
    _unlockedAchievements = _storage.unlockedAchievements;
    _trialStartDate = _storage.trialStartDate;
    _activePlan = _planForProductId(_storage.cachedActiveProductId);
    _currentEffectiveDate = effectiveDate();
    _viewDate = _currentEffectiveDate;
    _loadViewLog();
  }

  String exportBackupJson() =>
      BackupService.encode(_storage.exportSnapshot());

  Future<void> importBackupJson(String json) async {
    final snapshot = BackupService.decode(json);
    await _storage.importSnapshot(snapshot);
    _pendingAchievements.clear();
    _loadFromStorage();
    notifyListeners();
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _subscriptionService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLogIfDateChanged();
      _scheduleNextReset();
      // No backend/push notifications, so re-check entitlement on every
      // resume in case a subscription lapsed or renewed while backgrounded.
      unawaited(_subscriptionService.restorePurchases());
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

  List<LogEntry> _viewLogFromStorage() =>
      List<LogEntry>.from(_storage.getDailyLog(_viewDate));

  Future<void> _saveViewLog(List<LogEntry> log) async {
    await _storage.saveDailyLog(_viewDate, log);
    _viewLog = log;
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

  Future<void> setProteinOverride(String foodId, double gramsPerServing) async {
    _proteinOverrides = {..._proteinOverrides, foodId: gramsPerServing};
    await _storage.setProteinOverride(foodId, gramsPerServing);
    notifyListeners();
  }

  Future<void> clearProteinOverride(String foodId) async {
    final next = {..._proteinOverrides};
    next.remove(foodId);
    _proteinOverrides = next;
    await _storage.clearProteinOverride(foodId);
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
    final log = _viewLogFromStorage()..add(entry);
    await _saveViewLog(log);
    if (isViewingToday) _checkAchievements();
    notifyListeners();
  }

  Future<void> updateEntryFraction(String entryId, double fraction) async {
    _refreshLogIfDateChanged();
    final log = _viewLogFromStorage();
    final index = log.indexWhere((e) => e.id == entryId);
    if (index == -1) return;
    log[index] = log[index].copyWith(fraction: fraction);
    await _saveViewLog(log);
    if (isViewingToday) _checkAchievements();
    notifyListeners();
  }

  Future<void> removeEntry(String entryId) async {
    _refreshLogIfDateChanged();
    final log = _viewLogFromStorage()..removeWhere((e) => e.id == entryId);
    await _saveViewLog(log);
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

  Future<void> updateCustomFood(FoodItem food) async {
    final index = _customFoods.indexWhere((f) => f.id == food.id);
    if (index == -1) return;
    _customFoods[index] = food;
    await _storage.saveCustomFoods(_customFoods);
    notifyListeners();
  }

  Future<void> removeCustomFood(String foodId) async {
    _customFoods.removeWhere((f) => f.id == foodId);
    await _storage.saveCustomFoods(_customFoods);
    if (_favoriteFoodIds.remove(foodId)) {
      await _storage.saveFavoriteFoodIds(_favoriteFoodIds);
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String foodId) async {
    if (_favoriteFoodIds.contains(foodId)) {
      _favoriteFoodIds.remove(foodId);
    } else {
      _favoriteFoodIds.add(foodId);
    }
    await _storage.saveFavoriteFoodIds(_favoriteFoodIds);
    notifyListeners();
  }

  Future<void> reorderFavorites(int from, int to) async {
    if (from == to || _favoriteFoodIds.isEmpty) return;
    final ids = List<String>.from(_favoriteFoodIds);
    if (from < 0 || from >= ids.length) return;
    to = to.clamp(0, ids.length - 1);
    final id = ids.removeAt(from);
    ids.insert(to, id);
    _favoriteFoodIds = ids;
    await _storage.saveFavoriteFoodIds(_favoriteFoodIds);
    notifyListeners();
  }

  Future<void> reorderCustomFoods(int from, int to) async {
    if (from == to || _customFoods.isEmpty) return;
    final foods = List<FoodItem>.from(_customFoods);
    if (from < 0 || from >= foods.length) return;
    to = to.clamp(0, foods.length - 1);
    final food = foods.removeAt(from);
    foods.insert(to, food);
    _customFoods = foods;
    await _storage.saveCustomFoods(_customFoods);
    notifyListeners();
  }

  Future<void> reorderViewLog(int from, int to) async {
    if (from == to) return;
    _refreshLogIfDateChanged();
    final log = _viewLogFromStorage();
    if (from < 0 || from >= log.length) return;
    to = to.clamp(0, log.length - 1);
    final entry = log.removeAt(from);
    log.insert(to, entry);
    await _saveViewLog(log);
    notifyListeners();
  }

  void dismissAchievement() {
    if (_pendingAchievements.isNotEmpty) {
      _pendingAchievements.removeAt(0);
      notifyListeners();
    }
  }

  void _checkAchievements() {
    final todayLog = _storage.getDailyLog(_currentEffectiveDate);
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
