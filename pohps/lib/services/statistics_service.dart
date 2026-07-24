import '../storage.dart';

/// One day's total logged protein — used by the trend chart's Week/Month
/// views and by the calendar heatmap.
class DailyProteinPoint {
  final DateTime date;
  final double totalProtein;
  final bool goalMet;

  const DailyProteinPoint({
    required this.date,
    required this.totalProtein,
    required this.goalMet,
  });
}

/// One calendar month's average daily protein — used by the trend chart's
/// Year/YTD views. 365 raw daily points is unreadable, especially for
/// elderly users, so those views aggregate to monthly.
class MonthlyProteinPoint {
  final DateTime month;
  final double averageProtein;
  final bool anyDayLogged;

  const MonthlyProteinPoint({
    required this.month,
    required this.averageProtein,
    required this.anyDayLogged,
  });
}

/// Aggregates the existing per-day logs (`StorageService.getDailyLog`) into
/// trend-chart, calendar, and export data. "Goal met" is always evaluated
/// against the CURRENT daily goal, matching how
/// `AppState._checkStreaks()` already treats historical days — this app has
/// never tracked historical goal changes, so statistics stay consistent
/// with the existing achievements/streak behavior.
class StatisticsService {
  final StorageService _storage;

  const StatisticsService(this._storage);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  double _totalProteinFor(DateTime date) {
    final log = _storage.getDailyLog(date);
    return log.fold(0.0, (sum, e) => sum + e.totalProtein);
  }

  DailyProteinPoint _dailyPoint(DateTime date, int dailyGoal) {
    final total = _totalProteinFor(date);
    return DailyProteinPoint(
      date: date,
      totalProtein: total,
      goalMet: dailyGoal > 0 && total >= dailyGoal,
    );
  }

  /// Daily points for the trailing [days] days, ending on [endDate] inclusive.
  List<DailyProteinPoint> dailyTrend({
    required DateTime endDate,
    required int days,
    required int dailyGoal,
  }) {
    final end = _dateOnly(endDate);
    return List.generate(days, (i) {
      final date = end.subtract(Duration(days: days - 1 - i));
      return _dailyPoint(date, dailyGoal);
    });
  }

  /// Monthly-averaged points for the trailing [months] calendar months,
  /// ending in the month containing [endDate].
  List<MonthlyProteinPoint> monthlyTrend({
    required DateTime endDate,
    required int months,
    required int dailyGoal,
  }) {
    final endMonth = DateTime(endDate.year, endDate.month);
    return List.generate(months, (i) {
      final month =
          DateTime(endMonth.year, endMonth.month - (months - 1 - i));
      return _monthlyAverage(month, endDate, dailyGoal);
    });
  }

  /// Monthly-averaged points from January through [endDate]'s month
  /// (year-to-date).
  List<MonthlyProteinPoint> yearToDateTrend({
    required DateTime endDate,
    required int dailyGoal,
  }) {
    return List.generate(endDate.month, (i) {
      final month = DateTime(endDate.year, i + 1);
      return _monthlyAverage(month, endDate, dailyGoal);
    });
  }

  MonthlyProteinPoint _monthlyAverage(
    DateTime month,
    DateTime notAfter,
    int dailyGoal,
  ) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final today = _dateOnly(notAfter);
    double sum = 0;
    int loggedDays = 0;
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      if (date.isAfter(today)) break;
      final total = _totalProteinFor(date);
      if (total > 0) {
        sum += total;
        loggedDays++;
      }
    }
    return MonthlyProteinPoint(
      month: DateTime(month.year, month.month),
      averageProtein: loggedDays == 0 ? 0 : sum / loggedDays,
      anyDayLogged: loggedDays > 0,
    );
  }

  /// Full detail (total protein + goal-met) for a single day — used when the
  /// calendar heatmap's day cell is tapped.
  DailyProteinPoint dayDetail(DateTime date, int dailyGoal) =>
      _dailyPoint(_dateOnly(date), dailyGoal);

  /// Goal-met status for every logged day of [month], for the calendar
  /// heatmap. Days with no logged entries are omitted from the map.
  Map<DateTime, bool> goalMetByDay(DateTime month, int dailyGoal) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final result = <DateTime, bool>{};
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final log = _storage.getDailyLog(date);
      if (log.isEmpty) continue;
      final total = log.fold(0.0, (sum, e) => sum + e.totalProtein);
      result[date] = dailyGoal > 0 && total >= dailyGoal;
    }
    return result;
  }

  /// Every logged day across the app's full history, oldest first — for the
  /// Excel export.
  List<DailyProteinPoint> fullHistory(int dailyGoal) {
    return _storage.loggedDates
        .map((date) => _dailyPoint(date, dailyGoal))
        .toList();
  }
}
