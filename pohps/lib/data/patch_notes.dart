/// One line of a patch note, in each supported language.
class PatchNoteItem {
  final String emoji;
  final String en;
  final String zhTW;
  final String zhCN;

  const PatchNoteItem({
    required this.emoji,
    required this.en,
    required this.zhTW,
    required this.zhCN,
  });
}

class PatchNote {
  /// Matches the `version` name in pubspec.yaml (without the build number).
  final String version;

  /// Important updates also offer the optional donation button. Routine
  /// updates leave [important] false and show plain notes only.
  final bool important;
  final List<PatchNoteItem> items;

  const PatchNote({
    required this.version,
    required this.items,
    this.important = false,
  });
}

/// Add an entry here whenever a release should show a "What's New" popup.
/// A version without an entry updates silently.
const List<PatchNote> patchNotes = [
  PatchNote(
    version: '1.2.0',
    important: true,
    items: [
      PatchNoteItem(
        emoji: '📊',
        en: 'Statistics is now free for everyone — protein trends, the goal calendar and Excel export. No trial, no subscription.',
        zhTW: '統計功能現已人人免費 — 蛋白質趨勢圖、目標日曆與 Excel 匯出。沒有試用期，也不需訂閱。',
        zhCN: '统计功能现已人人免费 — 蛋白质趋势图、目标日历与 Excel 导出。没有试用期，也无需订阅。',
      ),
      PatchNoteItem(
        emoji: '🌿',
        en: 'POHPS stays ad-free, and your data stays on your device.',
        zhTW: 'POHPS 仍然沒有廣告，您的資料也依然只儲存在您的裝置上。',
        zhCN: 'POHPS 仍然没有广告，您的数据也依然只存储在您的设备上。',
      ),
    ],
  ),
];

PatchNote? patchNoteFor(String version) {
  for (final note in patchNotes) {
    if (note.version == version) return note;
  }
  return null;
}

/// Decides whether launching [currentVersion] should show patch notes.
///
/// [lastSeenVersion] is null on the very first launch after an install. A
/// first launch by someone who hasn't finished onboarding is a fresh install
/// and never sees notes; a null value from someone who already has, is an
/// existing user updating from a release that predates this feature.
PatchNote? patchNoteToShow({
  required String? lastSeenVersion,
  required String currentVersion,
  required bool hasCompletedOnboarding,
}) {
  if (lastSeenVersion == currentVersion) return null;
  if (lastSeenVersion == null && !hasCompletedOnboarding) return null;
  return patchNoteFor(currentVersion);
}
