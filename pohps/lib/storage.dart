import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get disclaimerAccepted => _prefs.getBool('disclaimer_accepted') ?? false;
  Future<void> setDisclaimerAccepted(bool value) =>
      _prefs.setBool('disclaimer_accepted', value);

  int get dailyGoal => _prefs.getInt('daily_goal') ?? 0;
  Future<void> setDailyGoal(int value) => _prefs.setInt('daily_goal', value);

  String? get localeCode => _prefs.getString('locale');
  Future<void> setLocaleCode(String? code) {
    if (code == null) {
      return _prefs.remove('locale');
    }
    return _prefs.setString('locale', code);
  }

  ThemeMode get themeMode {
    final mode = _prefs.getString('theme_mode');
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    return _prefs.setString('theme_mode', value);
  }

  MeasurementSystem get measurementSystem {
    final value = _prefs.getString('measurement_system');
    return switch (value) {
      'imperial' => MeasurementSystem.imperial,
      _ => MeasurementSystem.metric,
    };
  }

  Future<void> setMeasurementSystem(MeasurementSystem system) {
    final value = switch (system) {
      MeasurementSystem.imperial => 'imperial',
      MeasurementSystem.metric => 'metric',
    };
    return _prefs.setString('measurement_system', value);
  }

  DietType get dietType {
    final value = _prefs.getString('diet_type');
    return switch (value) {
      'vegan' => DietType.vegan,
      'allium_vegetarian' => DietType.alliumVegetarian,
      'allium_vegan' => DietType.alliumVegan,
      _ => DietType.lactoOvo,
    };
  }

  Future<void> setDietType(DietType diet) {
    final value = switch (diet) {
      DietType.vegan => 'vegan',
      DietType.alliumVegetarian => 'allium_vegetarian',
      DietType.alliumVegan => 'allium_vegan',
      DietType.lactoOvo => 'lacto_ovo',
    };
    return _prefs.setString('diet_type', value);
  }

  bool get waterTrackerEnabled =>
      _prefs.getBool('water_tracker_enabled') ?? false;
  Future<void> setWaterTrackerEnabled(bool value) =>
      _prefs.setBool('water_tracker_enabled', value);

  bool get moodTrackerEnabled =>
      _prefs.getBool('mood_tracker_enabled') ?? false;
  Future<void> setMoodTrackerEnabled(bool value) =>
      _prefs.setBool('mood_tracker_enabled', value);

  int get dailyWaterGoalMl => _prefs.getInt('daily_water_goal_ml') ?? 2000;
  Future<void> setDailyWaterGoalMl(int value) =>
      _prefs.setInt('daily_water_goal_ml', value);

  bool get ironTrackerEnabled =>
      _prefs.getBool('iron_tracker_enabled') ?? false;
  Future<void> setIronTrackerEnabled(bool value) =>
      _prefs.setBool('iron_tracker_enabled', value);

  int get dailyIronGoalMg => _prefs.getInt('daily_iron_goal_mg') ?? 18;
  Future<void> setDailyIronGoalMg(int value) =>
      _prefs.setInt('daily_iron_goal_mg', value);

  bool get calciumTrackerEnabled =>
      _prefs.getBool('calcium_tracker_enabled') ?? false;
  Future<void> setCalciumTrackerEnabled(bool value) =>
      _prefs.setBool('calcium_tracker_enabled', value);

  int get dailyCalciumGoalMg =>
      _prefs.getInt('daily_calcium_goal_mg') ?? 1000;
  Future<void> setDailyCalciumGoalMg(int value) =>
      _prefs.setInt('daily_calcium_goal_mg', value);

  bool get b12ReminderEnabled =>
      _prefs.getBool('b12_reminder_enabled') ?? false;
  Future<void> setB12ReminderEnabled(bool value) =>
      _prefs.setBool('b12_reminder_enabled', value);

  /// Days the B12 supplement was checked off, as `yyyy-MM-dd` strings.
  Set<String> get b12TakenDates {
    final json = _prefs.getString('b12_taken_dates');
    if (json == null) return {};
    final decoded = jsonDecode(json);
    if (decoded is! List) return {};
    return decoded.whereType<String>().toSet();
  }

  Future<void> saveB12TakenDates(Set<String> dates) {
    final sorted = dates.toList()..sort();
    return _prefs.setString('b12_taken_dates', jsonEncode(sorted));
  }

  Map<String, double> get proteinOverrides {
    final json = _prefs.getString('protein_overrides');
    if (json == null) return {};
    final decoded = jsonDecode(json);
    if (decoded is! Map) return {};
    final map = <String, double>{};
    decoded.forEach((key, value) {
      if (key is String && value is num) {
        map[key] = value.toDouble();
      }
    });
    return map;
  }

  Future<void> setProteinOverride(String foodId, double gramsPerServing) {
    final current = proteinOverrides;
    current[foodId] = gramsPerServing;
    return _prefs.setString('protein_overrides', jsonEncode(current));
  }

  Future<void> clearProteinOverride(String foodId) {
    final current = proteinOverrides;
    current.remove(foodId);
    return _prefs.setString('protein_overrides', jsonEncode(current));
  }

  String _dateKey(DateTime date) =>
      'log_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<LogEntry> getDailyLog(DateTime date) {
    final json = _prefs.getString(_dateKey(date));
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDailyLog(DateTime date, List<LogEntry> entries) {
    final json = jsonEncode(entries.map((e) => e.toJson()).toList());
    return _prefs.setString(_dateKey(date), json);
  }

  /// All dates that have at least one logged entry, oldest first. Used to
  /// bound a full-history statistics export.
  List<DateTime> get loggedDates {
    final dates = <DateTime>[];
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith('log_')) continue;
      final raw = _prefs.getString(key);
      if (raw == null || raw == '[]') continue;
      dates.add(_parseDateKey(key.substring(4)));
    }
    dates.sort();
    return dates;
  }

  List<FoodItem> get customFoods {
    final json = _prefs.getString('custom_foods');
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomFoods(List<FoodItem> foods) {
    final json = jsonEncode(foods.map((e) => e.toJson()).toList());
    return _prefs.setString('custom_foods', json);
  }

  Set<String> get unlockedAchievements {
    final json = _prefs.getString('unlocked_achievements');
    if (json == null) return {};
    final list = jsonDecode(json) as List;
    return list.cast<String>().toSet();
  }

  Future<void> saveUnlockedAchievements(Set<String> achievements) {
    final json = jsonEncode(achievements.toList());
    return _prefs.setString('unlocked_achievements', json);
  }

  /// Statistics used to sit behind a subscription/trial. Drop the leftover
  /// local state from those installs now that everything is free.
  Future<void> clearLegacyProState() async {
    await _prefs.remove('trial_start_date');
    await _prefs.remove('cached_active_product_id');
  }

  // ── Patch notes ───────────────────────────────────────────────────────
  // Deliberately NOT in exportSnapshot/_managedKeys: this records which app
  // version this install last showed notes for, so a restored backup must not
  // change it.

  String? get lastSeenVersion => _prefs.getString('last_seen_version');

  Future<void> setLastSeenVersion(String version) =>
      _prefs.setString('last_seen_version', version);

  List<String> get favoriteFoodIds {
    final json = _prefs.getString('favorite_food_ids');
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.cast<String>();
  }

  Future<void> saveFavoriteFoodIds(List<String> ids) {
    return _prefs.setString('favorite_food_ids', jsonEncode(ids));
  }

  static const _managedKeys = {
    'disclaimer_accepted',
    'daily_goal',
    'locale',
    'theme_mode',
    'measurement_system',
    'diet_type',
    'water_tracker_enabled',
    'daily_water_goal_ml',
    'mood_tracker_enabled',
    'iron_tracker_enabled',
    'daily_iron_goal_mg',
    'calcium_tracker_enabled',
    'daily_calcium_goal_mg',
    'b12_reminder_enabled',
    'b12_taken_dates',
    'protein_overrides',
    'custom_foods',
    'unlocked_achievements',
    'favorite_food_ids',
  };

  /// Snapshot keys for preferences (not user data) that an import should
  /// leave unchanged when the backup predates them.
  static const _settingKeys = [
    'locale',
    'themeMode',
    'measurementSystem',
    'dietType',
    'waterTrackerEnabled',
    'dailyWaterGoalMl',
    'moodTrackerEnabled',
    'ironTrackerEnabled',
    'dailyIronGoalMg',
    'calciumTrackerEnabled',
    'dailyCalciumGoalMg',
    'b12ReminderEnabled',
  ];

  Map<String, dynamic> exportSnapshot() {
    final dailyLogs = <String, dynamic>{};
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith('log_')) continue;
      final raw = _prefs.getString(key);
      if (raw == null) continue;
      final date = key.substring(4);
      dailyLogs[date] = jsonDecode(raw);
    }

    return {
      'disclaimerAccepted': disclaimerAccepted,
      'dailyGoal': dailyGoal,
      'locale': localeCode,
      'themeMode': _prefs.getString('theme_mode') ?? 'system',
      'measurementSystem': _prefs.getString('measurement_system') ?? 'metric',
      'dietType': _prefs.getString('diet_type') ?? 'lacto_ovo',
      'waterTrackerEnabled': waterTrackerEnabled,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'moodTrackerEnabled': moodTrackerEnabled,
      'ironTrackerEnabled': ironTrackerEnabled,
      'dailyIronGoalMg': dailyIronGoalMg,
      'calciumTrackerEnabled': calciumTrackerEnabled,
      'dailyCalciumGoalMg': dailyCalciumGoalMg,
      'b12ReminderEnabled': b12ReminderEnabled,
      'b12TakenDates': b12TakenDates.toList()..sort(),
      'proteinOverrides': proteinOverrides,
      'customFoods': customFoods.map((f) => f.toJson()).toList(),
      'favoriteFoodIds': favoriteFoodIds,
      'unlockedAchievements': unlockedAchievements.toList(),
      'dailyLogs': dailyLogs,
    };
  }

  Future<void> importSnapshot(Map<String, dynamic> data) async {
    // Settings missing from older backups keep their current values instead
    // of being reset to defaults.
    final current = exportSnapshot();
    data = {
      for (final key in _settingKeys)
        if (current.containsKey(key)) key: current[key],
      ...data,
    };

    for (final key in List<String>.from(_prefs.getKeys())) {
      if (key.startsWith('log_') || _managedKeys.contains(key)) {
        await _prefs.remove(key);
      }
    }

    await setDisclaimerAccepted(data['disclaimerAccepted'] as bool? ?? false);
    await setDailyGoal((data['dailyGoal'] as num?)?.toInt() ?? 0);

    final locale = data['locale'];
    if (locale is String) {
      await setLocaleCode(locale);
    } else {
      await setLocaleCode(null);
    }

    final themeMode = data['themeMode'] as String? ?? 'system';
    await setThemeMode(switch (themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    });

    final measurement = data['measurementSystem'] as String? ?? 'metric';
    await setMeasurementSystem(
      measurement == 'imperial'
          ? MeasurementSystem.imperial
          : MeasurementSystem.metric,
    );

    final diet = data['dietType'] as String? ?? 'lacto_ovo';
    await setDietType(switch (diet) {
      'vegan' => DietType.vegan,
      'allium_vegetarian' => DietType.alliumVegetarian,
      'allium_vegan' => DietType.alliumVegan,
      _ => DietType.lactoOvo,
    });

    await setWaterTrackerEnabled(data['waterTrackerEnabled'] as bool? ?? false);
    await setMoodTrackerEnabled(data['moodTrackerEnabled'] as bool? ?? false);
    await setDailyWaterGoalMl(
      (data['dailyWaterGoalMl'] as num?)?.toInt() ?? 2000,
    );

    await setIronTrackerEnabled(data['ironTrackerEnabled'] as bool? ?? false);
    await setDailyIronGoalMg((data['dailyIronGoalMg'] as num?)?.toInt() ?? 18);
    await setCalciumTrackerEnabled(
      data['calciumTrackerEnabled'] as bool? ?? false,
    );
    await setDailyCalciumGoalMg(
      (data['dailyCalciumGoalMg'] as num?)?.toInt() ?? 1000,
    );
    await setB12ReminderEnabled(data['b12ReminderEnabled'] as bool? ?? false);
    final b12Dates = data['b12TakenDates'];
    if (b12Dates is List) {
      await saveB12TakenDates(b12Dates.whereType<String>().toSet());
    }

    final overrides = data['proteinOverrides'];
    if (overrides is Map) {
      final map = <String, double>{};
      overrides.forEach((key, value) {
        if (key is String && value is num) {
          map[key] = value.toDouble();
        }
      });
      await _prefs.setString('protein_overrides', jsonEncode(map));
    } else {
      await _prefs.remove('protein_overrides');
    }

    final customFoods = data['customFoods'];
    if (customFoods is List) {
      final foods = customFoods
          .whereType<Map<String, dynamic>>()
          .map(FoodItem.fromJson)
          .toList();
      await saveCustomFoods(foods);
    } else {
      await _prefs.remove('custom_foods');
    }

    final favorites = data['favoriteFoodIds'];
    if (favorites is List) {
      await saveFavoriteFoodIds(favorites.cast<String>());
    } else {
      await _prefs.remove('favorite_food_ids');
    }

    final achievements = data['unlockedAchievements'];
    if (achievements is List) {
      await saveUnlockedAchievements(achievements.cast<String>().toSet());
    } else {
      await _prefs.remove('unlocked_achievements');
    }

    final dailyLogs = data['dailyLogs'];
    if (dailyLogs is Map) {
      for (final entry in dailyLogs.entries) {
        final dateKey = entry.key;
        if (dateKey is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateKey)) {
          continue;
        }
        final log = entry.value;
        if (log is! List) continue;
        final entries = log
            .whereType<Map<String, dynamic>>()
            .map(LogEntry.fromJson)
            .toList();
        await saveDailyLog(_parseDateKey(dateKey), entries);
      }
    }
  }

  DateTime _parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

