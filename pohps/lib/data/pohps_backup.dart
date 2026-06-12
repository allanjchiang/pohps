import 'dart:convert';

/// Versioned JSON backup format for POHPS local data.
class PohpsBackup {
  static const formatId = 'pohps_backup';
  static const currentVersion = 1;

  static String encode(Map<String, dynamic> data) {
    final envelope = {
      'format': formatId,
      'version': currentVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': data,
    };
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(envelope);
  }

  static Map<String, dynamic> decode(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup is not a JSON object');
    }

    final format = decoded['format'];
    if (format != formatId) {
      throw FormatException('Unknown backup format: $format');
    }

    final version = decoded['version'];
    if (version is! int || version > currentVersion) {
      throw FormatException('Unsupported backup version: $version');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Backup is missing a data object');
    }

    return data;
  }
}
