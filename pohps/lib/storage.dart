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
}
