import 'dart:io' show File;

import 'package:excel/excel.dart' as xls;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'statistics_service.dart';

/// Builds and shares a POHPS Pro statistics export as a readable .xlsx —
/// mirrors the temp-file + share_plus flow BackupService already uses for
/// JSON backups.
class StatisticsExportService {
  static const _xlsxMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  static final _headerStyle = xls.CellStyle(bold: true);

  static Future<void> exportDailySummaries(
    List<DailyProteinPoint> points, {
    required String proteinHeader,
    required String goalHeader,
    required String goalMetHeader,
    required String dateHeader,
    required String yes,
    required String no,
    required int dailyGoal,
  }) async {
    final workbook = xls.Excel.createExcel();
    final defaultSheetName = workbook.getDefaultSheet()!;
    workbook.rename(defaultSheetName, 'Daily Summary');
    final sheet = workbook['Daily Summary'];

    sheet.appendRow([
      xls.TextCellValue(dateHeader),
      xls.TextCellValue(proteinHeader),
      xls.TextCellValue(goalHeader),
      xls.TextCellValue(goalMetHeader),
    ]);
    for (var col = 0; col < 4; col++) {
      sheet
          .cell(xls.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .cellStyle = _headerStyle;
    }

    for (final point in points) {
      sheet.appendRow([
        xls.DateCellValue.fromDateTime(point.date),
        xls.DoubleCellValue(
            double.parse(point.totalProtein.toStringAsFixed(1))),
        xls.IntCellValue(dailyGoal),
        xls.TextCellValue(point.goalMet ? yes : no),
      ]);
    }

    for (var col = 0; col < 4; col++) {
      sheet.setColumnWidth(col, 18);
    }

    final raw = workbook.save();
    if (raw == null) {
      throw StateError('Failed to generate statistics workbook');
    }
    final bytes = Uint8List.fromList(raw);

    final name = _fileName();
    if (kIsWeb) {
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: _xlsxMimeType, name: name)],
        subject: 'POHPS statistics export',
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: _xlsxMimeType, name: name)],
      subject: 'POHPS statistics export',
    );
  }

  static String _fileName() {
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    return 'pohps_statistics_$stamp.xlsx';
  }
}
