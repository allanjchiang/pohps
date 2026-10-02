import 'package:flutter/material.dart';

/// Daily Tolerable Upper Intake Levels (US National Academies), from food
/// and supplements combined. The app doesn't know the user's age, so these
/// are the lowest adult limits: iron is 45 mg from age 14, and calcium is
/// 2,000 mg from age 51 (2,500 mg for ages 19–50).
const int ironUpperLimitMg = 45;
const int calciumUpperLimitMg = 2000;

/// Warning colours for a ring whose intake is above the upper limit.
const Color overLimitAmber = Color(0xFFE69500);
const Color overLimitAmberDark = Color(0xFF9A5B00);
