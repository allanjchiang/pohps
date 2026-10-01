import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pohps/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('importing an older backup keeps settings it does not include',
      () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'light',
      'mood_tracker_enabled': true,
      'iron_tracker_enabled': true,
      'calcium_tracker_enabled': true,
      'b12_reminder_enabled': true,
      'custom_foods': '[]',
    });
    final storage = StorageService();
    await storage.init();

    // Shape of a backup exported before mood, iron, calcium and B12 existed.
    await storage.importSnapshot({
      'disclaimerAccepted': true,
      'dailyGoal': 65,
      'locale': null,
      'waterTrackerEnabled': true,
      'dailyWaterGoalMl': 2000,
    });

    expect(storage.moodTrackerEnabled, isTrue);
    expect(storage.ironTrackerEnabled, isTrue);
    expect(storage.calciumTrackerEnabled, isTrue);
    expect(storage.b12ReminderEnabled, isTrue);
    expect(storage.themeMode, ThemeMode.light);
    expect(storage.waterTrackerEnabled, isTrue);
    expect(storage.dailyGoal, 65);
  });

  test('importing a backup applies the settings it includes', () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'light',
      'iron_tracker_enabled': true,
    });
    final storage = StorageService();
    await storage.init();

    await storage.importSnapshot({
      'themeMode': 'dark',
      'ironTrackerEnabled': false,
    });

    expect(storage.themeMode, ThemeMode.dark);
    expect(storage.ironTrackerEnabled, isFalse);
  });
}
