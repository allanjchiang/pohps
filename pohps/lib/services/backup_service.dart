import 'dart:convert';
import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/pohps_backup.dart';

/// Exports and imports POHPS backups via the system share sheet and file picker.
/// Data never leaves the device unless the user explicitly shares or saves a file.
class BackupService {
  static Future<void> shareBackup(String json) async {
    final name = _backupFileName();
    if (kIsWeb) {
      await Share.shareXFiles(
        [
          XFile.fromData(
            utf8.encode(json),
            mimeType: 'application/json',
            name: name,
          ),
        ],
        subject: 'POHPS data backup',
        text: 'POHPS backup — keep this file private.',
      );
      return;
    }

    final file = await _writeTempBackup(json, name);
    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'application/json',
          name: name,
        ),
      ],
      subject: 'POHPS data backup',
      text: 'POHPS backup — keep this file private.',
    );
  }

  static Future<String?> pickAndReadBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    if (file.bytes != null) {
      return utf8.decode(file.bytes!);
    }
    if (kIsWeb) return null;
    final path = file.path;
    if (path == null) return null;
    return File(path).readAsString();
  }

  static String encode(Map<String, dynamic> snapshot) =>
      PohpsBackup.encode(snapshot);

  static Map<String, dynamic> decode(String json) => PohpsBackup.decode(json);

  static String _backupFileName() {
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    return 'pohps_backup_$stamp.json';
  }

  static Future<File> _writeTempBackup(String json, String name) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(json);
    return file;
  }
}
