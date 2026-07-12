import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('zh', 'TW'),
    Locale('zh', 'CN'),
  ];

  String get _langKey {
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'CN' || locale.countryCode == 'SG') {
        return 'zh_CN';
      }
      return 'zh_TW';
    }
    return 'en';
  }

  String _t(String en, String zhTW, String zhCN) {
    return switch (_langKey) {
      'zh_TW' => zhTW,
      'zh_CN' => zhCN,
      _ => en,
    };
  }

  // ── Common ──────────────────────────────────────────────────────────────

  String get cancel => _t('Cancel', '取消', '取消');
  String get save => _t('Save', '儲存', '保存');
  String get delete => _t('Delete', '刪除', '删除');
  String get goBack => _t('Go Back', '返回', '返回');
  String get reset => _t('Reset', '重設', '重置');
  String get grams => _t('grams', '公克', '克');

  String get _dateLocaleTag => switch (_langKey) {
        'zh_TW' => 'zh_TW',
        'zh_CN' => 'zh_CN',
        _ => 'en_US',
      };

  /// Localized calendar date for the dashboard header.
  String formatDashboardDate(DateTime date) =>
      DateFormat.yMMMEd(_dateLocaleTag).format(date);

  // ── Disclaimer Screen ──────────────────────────────────────────────────

  String get appSubtitle => _t(
        'Protein Tracker for\nLacto-Ovo Vegetarians',
        '蛋奶素食者的\n蛋白質追蹤工具',
        '蛋奶素食者的\n蛋白质追踪工具',
      );

  String get importantDisclaimer =>
      _t('Important Disclaimer', '重要聲明', '重要声明');

  String get disclaimerReadCarefully => _t(
        'Please read carefully before using this app:',
        '使用本應用程式前請仔細閱讀：',
        '使用本应用前请仔细阅读：',
      );

  List<String> get disclaimerBullets => [
        _t(
          'This app is NOT a substitute for professional medical or dietary advice. Always consult your doctor or registered dietitian before making changes to your diet.',
          '本應用程式不能替代專業醫療或飲食建議。在改變飲食前，請務必諮詢您的醫師或營養師。',
          '本应用不能替代专业医疗或饮食建议。在改变饮食前，请务必咨询您的医生或营养师。',
        ),
        _t(
          'The protein values provided are approximate estimates and may vary depending on brands, preparation methods, and serving sizes.',
          '所提供的蛋白質數值為近似估計值，可能因品牌、烹調方式和份量而異。',
          '所提供的蛋白质数值为近似估计值，可能因品牌、烹调方式和份量而异。',
        ),
        _t(
          'This app is provided "AS-IS" without any warranties of any kind, either express or implied, including but not limited to fitness for a particular purpose.',
          '本應用程式按「現狀」提供，不附帶任何明示或暗示的保證，包括但不限於特定用途的適用性。',
          '本应用按「现状」提供，不附带任何明示或暗示的保证，包括但不限于特定用途的适用性。',
        ),
        _t(
          'You use this app entirely at your own risk. The developers accept no liability for any health outcomes resulting from use of this app.',
          '使用本應用程式的風險完全由您自行承擔。開發者不對因使用本應用程式而產生的任何健康後果承擔責任。',
          '使用本应用的风险完全由您自行承担。开发者不对因使用本应用而产生的任何健康后果承担责任。',
        ),
        _t(
          'No personal data is collected. All information is stored locally on your device only.',
          '我們不會收集任何個人資料。所有資訊僅儲存在您的裝置上。',
          '我们不会收集任何个人数据。所有信息仅存储在您的设备上。',
        ),
        _t(
          'This is free, open-source software. There are no ads, no paywalls, and no in-app purchases.',
          '這是免費的開源軟體。沒有廣告、沒有付費牆、也沒有應用程式內購買。',
          '这是免费的开源软件。没有广告、没有付费墙、也没有应用内购买。',
        ),
      ];

  String get disclaimerAcceptNote => _t(
        'By tapping "I Understand & Accept" below, you acknowledge that you have read, understood, and agree to these terms.',
        '點擊下方「我已了解並接受」，即表示您已閱讀、理解並同意上述條款。',
        '点击下方「我已了解并接受」，即表示您已阅读、理解并同意上述条款。',
      );

  String get iUnderstandAndAccept =>
      _t('I Understand & Accept', '我已了解並接受', '我已了解并接受');

  String get iDoNotAgree => _t('I Do Not Agree', '我不同意', '我不同意');

  String get cannotContinue => _t('Cannot Continue', '無法繼續', '无法继续');

  String get mustAcceptDisclaimer => _t(
        'You must accept the disclaimer to use this app. Please close the app if you do not agree with the terms.',
        '您必須接受聲明才能使用本應用程式。如果您不同意上述條款，請關閉應用程式。',
        '您必须接受声明才能使用本应用。如果您不同意上述条款，请关闭应用。',
      );

  // ── Goal Setup Screen ──────────────────────────────────────────────────

  String get setYourDailyGoal =>
      _t('Set Your Daily Goal', '設定每日目標', '设定每日目标');

  String get howManyGramsOfProtein => _t(
        'How many grams of protein did\nyour dietitian prescribe per day?',
        '您的營養師建議\n每日攝取多少公克蛋白質？',
        '您的营养师建议\n每日摄入多少克蛋白质？',
      );

  String get egGoal => _t('e.g. 60', '例如 60', '例如 60');

  String get canChangeLater => _t(
        'You can change this later in Settings.',
        '您可以稍後在設定中更改。',
        '您可以稍后在设置中更改。',
      );

  String get startTracking => _t('Start Tracking', '開始追蹤', '开始追踪');

  String get invalidGoalMessage => _t(
        'Please enter a valid protein goal in grams.',
        '請輸入有效的蛋白質目標（公克）。',
        '请输入有效的蛋白质目标（克）。',
      );

  // ── Dashboard Screen ───────────────────────────────────────────────────

  String get achievementsTitle => _t('Achievements', '成就', '成就');
  String get settings => _t('Settings', '設定', '设置');

  String get goalReachedWellDone =>
      _t('Goal reached! Well done!', '目標達成！做得好！', '目标达成！做得好！');

  String get waterGoalReachedWellDone => _t(
        'Water goal reached! Stay hydrated!',
        '水分目標達成！記得保持補水！',
        '水分目标达成！记得保持补水！',
      );

  String get swipeForWater =>
      _t('Swipe for water →', '滑動查看水分 →', '滑动查看水分 →');

  String get swipeForProtein =>
      _t('← Swipe for protein', '← 滑動查看蛋白質', '← 滑动查看蛋白质');

  String get swipeDateHint => _t(
        'Swipe the date to view previous days',
        '滑動日期以查看先前紀錄',
        '滑动日期以查看先前记录',
      );

  String foodsSectionTitle({required bool isToday}) {
    if (isToday) return todaysFoods;
    return _t('Foods & Drinks', '食物與飲品', '食物与饮品');
  }

  String get todaysFoods => _t("Today's Foods", '今日食物', '今日食物');

  String itemCount(int count) => _t(
        '$count item${count == 1 ? '' : 's'}',
        '$count 項',
        '$count 项',
      );

  String get noFoodsLoggedYet =>
      _t('No foods logged yet', '尚未記錄任何食物', '尚未记录任何食物');

  String get noFoodsLoggedOnDay =>
      _t('No foods logged on this day', '這天尚未記錄任何食物', '这天尚未记录任何食物');

  String get tapAddFoodToStart => _t(
        'Tap + Add Food to get started',
        '點擊 + 新增食物 開始記錄',
        '点击 + 添加食物 开始记录',
      );

  String get addFood => _t('Add Food', '新增食物', '添加食物');

  String get removeFoodTitle => _t('Remove Food?', '移除食物？', '移除食物？');

  String removeFoodConfirm(String name) => _t(
        'Remove $name from this log?',
        '確定從記錄中移除$name？',
        '确定从记录中移除$name？',
      );

  String get remove => _t('Remove', '移除', '移除');

  String howMuchFood(String name) =>
      _t('How much $name?', '吃了多少$name？', '吃了多少$name？');

  String gProtein(String g) =>
      _t('${g}g protein', '${g}g 蛋白質', '${g}g 蛋白质');

  String percentOfServing(int pct) => _t(
        '$pct% of a full serving',
        '一份的 $pct%',
        '一份的 $pct%',
      );

  String get full => _t('Full', '全部', '全部');

  // ── Settings Screen ────────────────────────────────────────────────────

  String get dailyProteinGoal =>
      _t('Daily Protein Goal', '每日蛋白質目標', '每日蛋白质目标');

  String get dailyWaterGoal =>
      _t('Daily Water Goal', '每日水分目標', '每日水分目标');

  String get waterTracker => _t('Water Tracker', '水分追蹤', '水分追踪');

  String get waterTrackerHint => _t(
        'Track hydration from drinks and water in foods. Swipe the progress ring for water.',
        '追蹤飲品與食物中的水分。滑動進度環可查看水分。',
        '追踪饮品与食物中的水分。滑动进度环可查看水分。',
      );

  String get mlPerDay => _t('Millilitres per day', '每日毫升', '每日毫升');

  String get changeWaterGoal =>
      _t('Change Water Goal', '更改水分目標', '更改水分目标');

  String get invalidWaterGoalMessage => _t(
        'Please enter a valid water goal in millilitres.',
        '請輸入有效的每日水分目標（毫升）。',
        '请输入有效的每日水分目标（毫升）。',
      );

  String formatWaterVolume(
    double ml,
    MeasurementSystem system, {
    bool compact = false,
  }) {
    if (system == MeasurementSystem.metric) {
      if (compact && ml >= 1000) {
        return '${(ml / 1000).toStringAsFixed(1)} L';
      }
      return '${ml.round()} ml';
    }
    final flOz = ml / 29.5735;
    if (flOz >= 16) {
      final pints = flOz / 16;
      if (pints >= 1.05) {
        return '${pints.toStringAsFixed(1)} pt';
      }
    }
    return '${flOz.round()} fl oz';
  }

  String waterOfGoal(double goalMl, MeasurementSystem system) => _t(
        'of ${formatWaterVolume(goalMl, system, compact: true)}',
        '目標 ${formatWaterVolume(goalMl, system, compact: true)}',
        '目标 ${formatWaterVolume(goalMl, system, compact: true)}',
      );

  String waterAmountLabel(double ml, MeasurementSystem system) =>
      formatWaterVolume(ml, system);

  String get change => _t('Change', '更改', '更改');

  String get appearance => _t('Appearance', '外觀', '外观');
  String get themeAuto => _t('Auto', '自動', '自动');
  String get themeLight => _t('Light', '淺色', '浅色');
  String get themeDark => _t('Dark', '深色', '深色');

  String get measurements => _t('Measurements', '計量單位', '计量单位');
  String get measurementMetric => _t('Metric', '公制', '公制');
  String get measurementImperial => _t('Imperial', '英制', '英制');
  String get measurementImperialHint => _t(
        'Uses cups, fl oz, and oz for serving sizes.',
        '份量以杯、液量盎司和盎司顯示。',
        '份量以杯、液量盎司和盎司显示。',
      );

  String get egServingSizeImperial =>
      _t('e.g. 4 oz', '例如：4 oz', '例如：4 oz');

  String get diet => _t('Diet', '飲食類型', '饮食类型');
  String get dietLactoOvo =>
      _t('Lacto-Ovo', '蛋奶素', '蛋奶素');
  String get dietVegan => _t('Vegan', '全素', '全素');
  String get dietAlliumVegetarian =>
      _t('Allium Vegetarian', '五辛素', '五辛素');
  String get dietAlliumVegan => _t('Allium Vegan', '五辛全素', '五辛全素');
  String get dietHint => _t(
        'Vegan and Allium Vegan hide eggs and dairy. Lacto-Ovo and Allium Vegetarian include them. Allium diets add onions, garlic, leeks, shallots, chives, and spring onions.',
        '全素與五辛全素會隱藏蛋類和乳製品；蛋奶素與五辛素則包含。五辛飲食會新增洋蔥、大蒜、韭蔥、紅蔥頭、細香蔥與青蔥。',
        '全素与五辛全素会隐藏蛋类和乳制品；蛋奶素与五辛素则包含。五辛饮食会新增洋葱、大蒜、韭葱、红葱头、细香葱与青葱。',
      );

  String get language => _t('Language', '語言', '语言');
  String get languageSystem => _t('System', '系統', '系统');

  String get myCustomFoods =>
      _t('My Custom Foods', '我的自訂食物', '我的自定义食物');

  String get yourData => _t('Your Data', '您的資料', '您的数据');

  String get backupPrivacyHint => _t(
        'Your logs and settings stay on this device. Export creates a file you can save or share anywhere you choose — POHPS never uploads your data.',
        '您的記錄和設定僅保存在此裝置上。匯出會建立一個檔案，由您自行選擇儲存或分享的位置——POHPS 不會上傳您的資料。',
        '您的记录和设置仅保存在此设备上。导出会创建一个文件，由您自行选择保存或分享的位置——POHPS 不会上传您的数据。',
      );

  String get backupIncludesHint => _t(
        'Includes protein and water history, custom foods, favorites, achievements, and app settings.',
        '包含蛋白質與水分記錄、自訂食物、最愛、成就及應用程式設定。',
        '包含蛋白质与水分记录、自定义食物、收藏、成就及应用设置。',
      );

  String get exportData => _t('Export data', '匯出資料', '导出数据');

  String get importData => _t('Import data', '匯入資料', '导入数据');

  String get exportDataHint =>
      _t('Save or share a backup file', '儲存或分享備份檔案', '保存或分享备份文件');

  String get importDataHint => _t(
        'Replace all data from a backup file',
        '從備份檔案取代所有資料',
        '从备份文件替换所有数据',
      );

  String get importBackupTitle =>
      _t('Import backup?', '匯入備份？', '导入备份？');

  String get importBackupMessage => _t(
        'This will replace all protein and water logs, custom foods, favorites, achievements, and settings on this device with the backup file. This cannot be undone.',
        '這將以備份檔案取代此裝置上的所有蛋白質與水分記錄、自訂食物、最愛、成就及設定。此操作無法復原。',
        '这将用备份文件替换此设备上的所有蛋白质与水分记录、自定义食物、收藏、成就及设置。此操作无法撤销。',
      );

  String get importBackupConfirm =>
      _t('Import backup', '匯入備份', '导入备份');

  String get backupExported =>
      _t('Backup ready to save or share', '備份已準備好供您儲存或分享', '备份已准备好供您保存或分享');

  String get backupImported =>
      _t('Backup imported successfully', '備份已成功匯入', '备份已成功导入');

  String get backupExportFailed =>
      _t('Could not export backup', '無法匯出備份', '无法导出备份');

  String get backupImportFailed =>
      _t('Could not import backup', '無法匯入備份', '无法导入备份');

  String get aboutPohps => _t('About POHPS', '關於 POHPS', '关于 POHPS');

  String get aboutDescription => _t(
        'A free, open-source protein tracking app designed for lacto-ovo vegetarians.',
        '一款免費的開源蛋白質追蹤應用程式，專為蛋奶素食者設計。',
        '一款免费的开源蛋白质追踪应用，专为蛋奶素食者设计。',
      );

  String get aboutBullets => _t(
        '• No ads, no paywalls, no data collection\n'
            '• All data stored locally on your device\n'
            '• Protein values are estimates — always consult your dietitian',
        '• 無廣告、無付費牆、不收集資料\n'
            '• 所有資料僅儲存在您的裝置上\n'
            '• 蛋白質數值為估計值——請務必諮詢您的營養師',
        '• 无广告、无付费墙、不收集数据\n'
            '• 所有数据仅存储在您的设备上\n'
            '• 蛋白质数值为估计值——请务必咨询您的营养师',
      );

  String get changeProteinGoal =>
      _t('Change Protein Goal', '更改蛋白質目標', '更改蛋白质目标');

  String get gramsPerDay => _t('Grams per day', '每日公克數', '每日克数');

  String get deleteCustomFoodTitle =>
      _t('Delete Custom Food?', '刪除自訂食物？', '删除自定义食物？');

  String deleteConfirm(String name) => _t(
        'Are you sure you want to delete "$name"?',
        '確定要刪除「$name」嗎？',
        '确定要删除「$name」吗？',
      );

  // ── Add Food Screen ────────────────────────────────────────────────────

  String get custom => _t('Custom', '自訂', '自定义');
  String get favoritesCategory => _t('Favorites', '我的最愛', '收藏');
  String get allCategory => _t('All', '全部', '全部');
  String get myFoods => _t('My Foods', '我的食物', '我的食物');
  String get noFoodsInCategory =>
      _t('No foods in this category', '此分類沒有食物', '此分类没有食物');
  String get noFavoritesYet => _t(
        'No favorites yet. Tap the star on any food to add it here.',
        '尚無最愛。點擊任何食物上的星號即可加入。',
        '暂无收藏。点击任意食物上的星标即可添加。',
      );
  String get addToFavorites => _t('Add to favorites', '加入最愛', '加入收藏');
  String get removeFromFavorites =>
      _t('Remove from favorites', '從最愛移除', '从收藏移除');
  String get reorderFoods => _t('Reorder', '調整順序', '调整顺序');
  String get doneReordering => _t('Done', '完成', '完成');
  String get reorderHint => _t(
        'Use the up and down arrows to move foods. You can also press and drag the handle on the left.',
        '使用上下箭頭移動食物，也可以按住左側把手拖曳。',
        '使用上下箭头移动食物，也可以按住左侧把手拖曳。',
      );
  String get moveUp => _t('Move up', '上移', '上移');
  String get moveDown => _t('Move down', '下移', '下移');
  String get dragToReorder => _t('Drag to reorder', '拖曳以調整順序', '拖曳以调整顺序');
  String get added => _t('✓ Added!', '✓ 已新增！', '✓ 已添加！');

  // ── Custom Food Screen ─────────────────────────────────────────────────

  String get createCustomFood =>
      _t('Create Custom Food', '建立自訂食物', '创建自定义食物');

  String get editCustomFood =>
      _t('Edit Custom Food', '編輯自訂食物', '编辑自定义食物');

  String get editCustomFoodHint =>
      _t('Edit custom food', '編輯自訂食物', '编辑自定义食物');

  String get chooseAnIcon => _t('Choose an Icon', '選擇圖示', '选择图标');
  String get foodName => _t('Food Name', '食物名稱', '食物名称');

  String get egFoodName =>
      _t('e.g. My Special Smoothie', '例如：我的特調果昔', '例如：我的特调果昔');

  String get proteinPerServing =>
      _t('Protein per Serving', '每份蛋白質含量', '每份蛋白质含量');

  String get egProtein => _t('e.g. 15', '例如 15', '例如 15');
  String get servingSizeLabel => _t('Serving Size', '份量大小', '份量大小');

  String get egServingSize =>
      _t('e.g. 1 bowl', '例如：1 碗', '例如：1 碗');

  String get categoryLabel => _t('Category', '分類', '分类');
  String get saveFood => _t('Save Food', '儲存食物', '保存食物');
  String get enterFoodName =>
      _t('Please enter a food name.', '請輸入食物名稱。', '请输入食物名称。');

  String get enterProteinAmount => _t(
        'Please enter a valid protein amount.',
        '請輸入有效的蛋白質含量。',
        '请输入有效的蛋白质含量。',
      );

  String get enterServingSize =>
      _t('Please enter a serving size.', '請輸入份量大小。', '请输入份量大小。');

  String foodCreated(String name) =>
      _t('$name has been created!', '$name 已建立！', '$name 已创建！');

  String foodUpdated(String name) =>
      _t('$name has been updated!', '$name 已更新！', '$name 已更新！');

  String get buildFromIngredients =>
      _t('Build from Ingredients', '以食材組成', '以食材组成');

  String get addIngredient =>
      _t('Add Ingredient', '新增食材', '添加食材');

  String get ingredientsLabel => _t('Ingredients', '食材', '食材');

  String get noIngredientsYet => _t(
        'Add foods from the database to combine protein and water.',
        '從資料庫加入食物，以加總蛋白質與水分。',
        '从数据库加入食物，以加总蛋白质与水分。',
      );

  String get combinedTotals => _t('Combined Totals', '加總', '加总');

  String get orEnterProteinManually => _t(
        'Or enter protein manually',
        '或手動輸入蛋白質',
        '或手动输入蛋白质',
      );

  String get addAtLeastOneIngredient => _t(
        'Add at least one ingredient, or enter protein manually.',
        '請至少新增一項食材，或手動輸入蛋白質。',
        '请至少添加一项食材，或手动输入蛋白质。',
      );

  String get pickIngredient =>
      _t('Pick an Ingredient', '選擇食材', '选择食材');

  String get removeIngredient =>
      _t('Remove ingredient', '移除食材', '移除食材');

  String ingredientAmountLabel(double fraction) =>
      _t('${(fraction * 100).round()}% serving', '一份的 ${(fraction * 100).round()}%', '一份的 ${(fraction * 100).round()}%');

  String editProteinTitle(String foodName) => _t(
        'Edit protein for $foodName',
        '編輯$foodName的蛋白質',
        '编辑$foodName的蛋白质',
      );

  // ── Achievement Dialog ─────────────────────────────────────────────────

  String get achievementUnlocked =>
      _t('Achievement Unlocked!', '成就解鎖！', '成就解锁！');

  String get wonderful => _t('Wonderful!', '太棒了！', '太棒了！');

  // ── Progress Ring ──────────────────────────────────────────────────────

  String ofGoal(int goal) =>
      _t('of ${goal}g', '目標 ${goal}g', '目标 ${goal}g');

  // ── Category Names ─────────────────────────────────────────────────────

  String categoryName(String category) {
    return switch (category) {
      'Beverages' => _t('Beverages', '飲品', '饮品'),
      'Dairy & Eggs' => _t('Dairy & Eggs', '乳蛋類', '乳蛋类'),
      'Protein Boosters' => _t('Protein Boosters', '蛋白質補充', '蛋白质补充'),
      'Legumes' => _t('Legumes', '豆類', '豆类'),
      'Grains' => _t('Grains', '穀物', '谷物'),
      'Vegetables' => _t('Vegetables', '蔬菜', '蔬菜'),
      'Fruits' => _t('Fruits', '水果', '水果'),
      'Nuts & Seeds' => _t('Nuts & Seeds', '堅果與種子', '坚果与种子'),
      'Other' => _t('Other', '其他', '其他'),
      _ => category,
    };
  }

  // ── Achievement Titles & Descriptions ──────────────────────────────────

  String achievementTitle(String typeName, String fallback) {
    return switch (typeName) {
      'firstBite' => _t('First Bite', '第一口', '第一口'),
      'halfwayThere' => _t('Halfway There', '達成一半', '达成一半'),
      'goalGetter' => _t('Goal Getter', '目標達成', '目标达成'),
      'chefsSpecial' => _t("Chef's Special", '主廚特餐', '大厨特制'),
      'threeDayStreak' => _t('Three-Day Streak', '三日連續', '三日连续'),
      'weekWarrior' => _t('Week Warrior', '一週勇士', '一周勇士'),
      'monthStrong' => _t('Month Strong', '月度達人', '月度达人'),
      _ => fallback,
    };
  }

  String achievementDesc(String typeName, String fallback) {
    return switch (typeName) {
      'firstBite' => _t(
          'You logged your first protein source!',
          '您記錄了第一個蛋白質來源！',
          '您记录了第一个蛋白质来源！',
        ),
      'halfwayThere' => _t(
          'You reached 50% of your daily protein goal!',
          '您達到了每日蛋白質目標的 50%！',
          '您达到了每日蛋白质目标的 50%！',
        ),
      'goalGetter' => _t(
          'You met your daily protein goal!',
          '您達成了每日蛋白質目標！',
          '您达成了每日蛋白质目标！',
        ),
      'chefsSpecial' => _t(
          'You created your first custom food!',
          '您建立了第一個自訂食物！',
          '您创建了第一个自定义食物！',
        ),
      'threeDayStreak' => _t(
          'You met your protein goal 3 days in a row!',
          '您連續 3 天達成蛋白質目標！',
          '您连续 3 天达成蛋白质目标！',
        ),
      'weekWarrior' => _t(
          'You met your protein goal 7 days in a row!',
          '您連續 7 天達成蛋白質目標！',
          '您连续 7 天达成蛋白质目标！',
        ),
      'monthStrong' => _t(
          'You met your protein goal 30 days in a row!',
          '您連續 30 天達成蛋白質目標！',
          '您连续 30 天达成蛋白质目标！',
        ),
      _ => fallback,
    };
  }

  // ── Default Food Names ─────────────────────────────────────────────────

  String foodDisplayName(String id, String fallback) {
    return switch (id) {
      'egg' => _t('Egg', '雞蛋', '鸡蛋'),
      'greek_yoghurt' => _t('Greek Yoghurt', '希臘優格', '希腊酸奶'),
      'milk' => _t('Milk', '牛奶', '牛奶'),
      'paneer' => _t('Paneer', '印度起司', '印度奶酪'),
      'cottage_cheese' => _t('Cottage Cheese', '茅屋起司', '茅屋奶酪'),
      'cheese' => _t('Cheese', '起司', '奶酪'),
      'whey_smoothie' =>
        _t('Whey Protein Isolate Powder', '乳清分離蛋白粉', '乳清分离蛋白粉'),
      'pea_protein_powder' =>
        _t('Pea Protein Powder', '豌豆蛋白粉', '豌豆蛋白粉'),
      'plant_based_meat' => _t(
        'Plant-Based Meat (Pea Protein)',
        '植物肉（豌豆蛋白）',
        '植物肉（豌豆蛋白）',
      ),
      'quorn_chicken_pieces' => _t(
        'Quorn Chicken Pieces',
        'Quorn 素雞肉塊',
        'Quorn 素鸡肉块',
      ),
      'pea_protein_smoothie' =>
        _t('Pea Protein Smoothie', '豌豆蛋白奶昔', '豌豆蛋白奶昔'),
      'water' => _t('Water', '水', '水'),
      'coffee' => _t('Coffee', '咖啡', '咖啡'),
      'espresso' => _t('Espresso', '濃縮咖啡', '浓缩咖啡'),
      'tea' => _t('Tea', '茶', '茶'),
      'sugar_free_soda' =>
        _t('Sugar-Free Soda', '無糖汽水', '无糖汽水'),
      'milk_tea' => _t('Milk Tea', '奶茶', '奶茶'),
      'juice' => _t('Juice', '果汁', '果汁'),
      'fruit_smoothie' => _t('Fruit Smoothie', '水果果昔', '水果果昔'),
      'oat_milk' => _t('Oat Milk', '燕麥奶', '燕麦奶'),
      'oat_milk_latte' => _t('Oat Milk Latte', '燕麥奶拿鐵', '燕麦奶拿铁'),
      'almond_milk' => _t('Almond Milk', '杏仁奶', '杏仁奶'),
      'soy_milk' => _t('Soy Milk', '豆漿', '豆浆'),
      'tofu' => _t('Tofu', '豆腐', '豆腐'),
      'beancurd_skin' => _t('Beancurd Skin', '豆皮', '豆皮'),
      'soy_meat' => _t('Soy Meat', '素肉', '素肉'),
      'lentils' => _t('Lentils', '扁豆', '扁豆'),
      'chickpeas' => _t('Chickpeas', '鷹嘴豆', '鹰嘴豆'),
      'black_beans' => _t('Black Beans', '黑豆', '黑豆'),
      'kidney_beans' => _t('Kidney Beans', '腰豆', '腰豆'),
      'white_rice' => _t('White Rice', '白飯', '白米饭'),
      'brown_rice' => _t('Brown Rice', '糙米飯', '糙米饭'),
      'quinoa' => _t('Quinoa', '藜麥', '藜麦'),
      'millet' => _t('Millet', '小米', '小米'),
      'buckwheat' => _t('Buckwheat', '蕎麥', '荞麦'),
      'couscous' => _t('Couscous', '北非小米', '北非小米'),
      'noodles' => _t('Noodles', '麵條', '面条'),
      'bread' => _t('Bread', '麵包', '面包'),
      'oats' => _t('Oats', '燕麥', '燕麦'),
      'flour' => _t('Flour', '麵粉', '面粉'),
      'glass_noodles' => _t('Glass Noodles', '冬粉', '冬粉'),
      'potato' => _t('Potato', '馬鈴薯', '土豆'),
      'mushroom' => _t('Mushroom', '蘑菇', '蘑菇'),
      'cauliflower' => _t('Cauliflower', '花椰菜', '花椰菜'),
      'broccoli' => _t('Broccoli', '青花菜', '西兰花'),
      'cabbage' => _t('Cabbage', '高麗菜', '卷心菜'),
      'carrots' => _t('Carrots', '紅蘿蔔', '胡萝卜'),
      'bok_choy' => _t('Bok Choy', '青江菜', '青菜'),
      'wombok' => _t('Wombok', '大白菜', '大白菜'),
      'capsicum' => _t('Capsicum', '甜椒', '甜椒'),
      'kale' => _t('Kale', '羽衣甘藍', '羽衣甘蓝'),
      'eggplant' => _t('Eggplant', '茄子', '茄子'),
      'brussel_sprouts' => _t('Brussel Sprouts', '球芽甘藍', '球芽甘蓝'),
      'cucumber' => _t('Cucumber', '小黃瓜', '黄瓜'),
      'zucchini' => _t('Zucchini', '櫛瓜', '西葫芦'),
      'olives' => _t('Olives', '橄欖', '橄榄'),
      'tomatoes' => _t('Tomatoes', '番茄', '番茄'),
      'cherry_tomatoes' => _t('Cherry Tomatoes', '小番茄', '小番茄'),
      'lettuce' => _t('Lettuce', '生菜', '生菜'),
      'pickles' => _t('Pickles', '醃黃瓜', '腌黄瓜'),
      'onions' => _t('Onions', '洋蔥', '洋葱'),
      'garlic' => _t('Garlic', '大蒜', '大蒜'),
      'leeks' => _t('Leeks', '韭蔥', '韭葱'),
      'shallots' => _t('Shallots', '紅蔥頭', '红葱头'),
      'chives' => _t('Chives', '細香蔥', '细香葱'),
      'spring_onions' => _t('Spring Onions', '青蔥', '青葱'),
      'apple' => _t('Apple', '蘋果', '苹果'),
      'banana' => _t('Banana', '香蕉', '香蕉'),
      'strawberries' => _t('Strawberries', '草莓', '草莓'),
      'blueberries' => _t('Blueberries', '藍莓', '蓝莓'),
      'blackberries' => _t('Blackberries', '黑莓', '黑莓'),
      'boysenberries' => _t('Boysenberries', '波森莓', '波森莓'),
      'mixed_berries' => _t('Mixed Berries', '綜合莓果', '综合莓果'),
      'kiwifruit' => _t('Kiwifruit', '奇異果', '猕猴桃'),
      'dragonfruit' => _t('Dragonfruit', '火龍果', '火龙果'),
      'pineapple' => _t('Pineapple', '鳳梨', '菠萝'),
      'fruits' => _t('Fruits', '水果', '水果'),
      'nuts_seeds' => _t('Nuts & Seeds', '堅果與種子', '坚果与种子'),
      'almonds' => _t('Almonds', '杏仁', '杏仁'),
      'peanuts' => _t('Peanuts', '花生', '花生'),
      'peanut_butter' => _t('Peanut Butter', '花生醬', '花生酱'),
      'cashews' => _t('Cashews', '腰果', '腰果'),
      'pistachios' => _t('Pistachios', '開心果', '开心果'),
      'macadamias' => _t('Macadamias', '夏威夷果', '夏威夷果'),
      'brazil_nuts' => _t('Brazil Nuts', '巴西堅果', '巴西坚果'),
      'pecans' => _t('Pecans', '碧根果', '碧根果'),
      'flaxseeds' => _t('Flaxseeds', '亞麻籽', '亚麻籽'),
      'chia_seeds' => _t('Chia Seeds', '奇亞籽', '奇亚籽'),
      'sunflower_seeds' => _t('Sunflower Seeds', '葵花籽', '葵花籽'),
      'pumpkin_seeds' => _t('Pumpkin Seeds', '南瓜籽', '南瓜籽'),
      'nutritional_yeast' => _t('Nutritional Yeast', '營養酵母', '营养酵母'),
      'oils' => _t('Oils', '油脂', '油脂'),
      'chonghua_dumplings' =>
        _t('Chonghua Dumplings', '崇華水餃', '崇华水饺'),
      _ => fallback,
    };
  }

  // ── Default Serving Sizes ──────────────────────────────────────────────

  String servingDisplay(
    String original, {
    String? foodId,
    MeasurementSystem system = MeasurementSystem.metric,
  }) {
    if (system == MeasurementSystem.imperial) {
      return _imperialServing(foodId, original);
    }
    return _metricServing(original);
  }

  String _metricServing(String original) {
    return switch (original) {
      '1 large' => _t('1 large', '1 顆（大）', '1 个（大）'),
      '1 pot (160g)' => _t('1 pot (160g)', '1 杯（160g）', '1 杯（160g）'),
      '1 glass (250ml)' =>
        _t('1 glass (250ml)', '1 杯（250ml）', '1 杯（250ml）'),
      '1 scoop + milk' =>
        _t('1 scoop + milk', '1 勺 + 牛奶', '1 勺 + 牛奶'),
      '1 scoop + soy milk' =>
        _t('1 scoop + soy milk', '1 勺 + 豆漿', '1 勺 + 豆浆'),
      '1 scoop' => _t('1 scoop', '1 勺', '1 勺'),
      '1 cup (240ml)' => _t('1 cup (240ml)', '1 杯（240ml）', '1 杯（240ml）'),
      '1 shot (30ml)' => _t('1 shot (30ml)', '1 份（30ml）', '1 份（30ml）'),
      '2 shots + 6 oz oat milk' => _t(
        '2 shots + 6 oz oat milk',
        '2 份濃縮 + 6 盎司燕麥奶',
        '2 份浓缩 + 6 盎司燕麦奶',
      ),
      '1 can (355ml)' => _t('1 can (355ml)', '1 罐（355ml）', '1 罐（355ml）'),
      '1 cup (350ml)' => _t('1 cup (350ml)', '1 杯（350ml）', '1 杯（350ml）'),
      '1 glass (350ml)' =>
        _t('1 glass (350ml)', '1 杯（350ml）', '1 杯（350ml）'),
      '100g (firm)' => _t('100g (firm)', '100g（板豆腐）', '100g（老豆腐）'),
      '100g' => _t('100g', '100g', '100g'),
      '50g' => _t('50g', '50g', '50g'),
      '5 dumplings (100g)' => _t(
        '5 dumplings (100g)',
        '5 顆水餃（100g）',
        '5 颗水饺（100g）',
      ),
      '1/2 cup' => _t('1/2 cup', '½ 杯', '½ 杯'),
      '1 serving (85g)' =>
        _t('1 serving (85g)', '1 份（85g）', '1 份（85g）'),
      '1 cup cooked' => _t('1 cup cooked', '1 杯（煮熟）', '1 杯（煮熟）'),
      '1 medium' => _t('1 medium', '1 個（中）', '1 个（中）'),
      '1 cup' => _t('1 cup', '1 杯', '1 杯'),
      '1 slice' => _t('1 slice', '1 片', '1 片'),
      '1 slice (28g)' => _t('1 slice (28g)', '1 片（28g）', '1 片（28g）'),
      '10 olives' => _t('10 olives', '10 顆橄欖', '10 颗橄榄'),
      '4 spears' => _t('4 spears', '4 根', '4 根'),
      '3 cloves' => _t('3 cloves', '3 瓣', '3 瓣'),
      '2 shallots' => _t('2 shallots', '2 顆紅蔥頭', '2 颗红葱头'),
      '2 stalks' => _t('2 stalks', '2 根', '2 根'),
      '30g (1 oz)' => _t('30g (1 oz)', '30g（1 盎司）', '30g（1 盎司）'),
      '1 tbsp' => _t('1 tbsp', '1 湯匙', '1 汤匙'),
      '2 tbsp' => _t('2 tbsp', '2 湯匙', '2 汤匙'),
      _ => original,
    };
  }

  String _imperialServing(String? foodId, String original) {
    if (foodId != null) {
      final byId = switch (foodId) {
        'egg' => '1 large',
        'greek_yoghurt' => '5.6 oz container',
        'milk' => '½ pint (8 fl oz)',
        'paneer' => '3.5 oz',
        'cottage_cheese' => '4 oz',
        'cheese' => '1 slice (1 oz)',
        'whey_smoothie' => '1 scoop',
        'pea_protein_powder' => '1 scoop',
        'plant_based_meat' => '3 oz',
        'quorn_chicken_pieces' => '3.5 oz',
        'pea_protein_smoothie' => '1 scoop + ½ pint soy milk',
        'water' => '½ pint (8 fl oz)',
        'coffee' => '1 cup (8 fl oz)',
        'espresso' => '1 shot (1 fl oz)',
        'tea' => '1 cup (8 fl oz)',
        'oat_milk' => '½ pint (8 fl oz)',
        'oat_milk_latte' => '2 shots + 6 oz oat milk',
        'almond_milk' => '½ pint (8 fl oz)',
        'sugar_free_soda' => '12 fl oz can',
        'milk_tea' => '1 cup (12 fl oz)',
        'juice' => '½ pint (8 fl oz)',
        'fruit_smoothie' => '12 fl oz',
        'soy_milk' => '½ pint (8 fl oz)',
        'broccoli' => '3 oz',
        'tofu' => '3.5 oz (firm)',
        'beancurd_skin' => '1.75 oz',
        'soy_meat' => '3 oz',
        'lentils' => '7 oz cooked',
        'chickpeas' => '7 oz cooked',
        'black_beans' => '7 oz cooked',
        'kidney_beans' => '7 oz cooked',
        'white_rice' => '5 oz cooked',
        'brown_rice' => '5 oz cooked',
        'quinoa' => '6 oz cooked',
        'millet' => '6 oz cooked',
        'buckwheat' => '6 oz cooked',
        'couscous' => '6 oz cooked',
        'noodles' => '5 oz cooked',
        'bread' => '1 slice',
        'oats' => '6 oz cooked',
        'flour' => '3.5 oz',
        'glass_noodles' => '3.5 oz',
        'potato' => '1 medium (5 oz)',
        'mushroom' => '3 oz',
        'cauliflower' => '3 oz',
        'cabbage' => '2 oz',
        'carrots' => '3.5 oz',
        'bok_choy' => '2 oz',
        'wombok' => '2 oz',
        'kale' => '2 oz',
        'eggplant' => '3 oz',
        'brussel_sprouts' => '3 oz',
        'cucumber' => '1 medium (7 oz)',
        'zucchini' => '1 medium (7 oz)',
        'olives' => '10 olives',
        'tomatoes' => '1 medium (5 oz)',
        'cherry_tomatoes' => '5 oz',
        'lettuce' => '2 oz',
        'pickles' => '4 spears',
        'onions' => '1 medium (5 oz)',
        'garlic' => '3 cloves',
        'leeks' => '3 oz',
        'shallots' => '2 shallots',
        'chives' => '1 tbsp',
        'spring_onions' => '2 stalks',
        'capsicum' => '1 medium (5 oz)',
        'apple' => '1 medium (5 oz)',
        'banana' => '1 medium (5 oz)',
        'strawberries' => '5 oz',
        'blueberries' => '5 oz',
        'blackberries' => '5 oz',
        'boysenberries' => '5 oz',
        'mixed_berries' => '5 oz',
        'kiwifruit' => '1 medium (3 oz)',
        'dragonfruit' => '1 medium (10 oz)',
        'pineapple' => '5 oz',
        'fruits' => '1 medium',
        'nuts_seeds' => '1 oz',
        'almonds' => '1 oz',
        'peanuts' => '1 oz',
        'peanut_butter' => '2 tbsp',
        'cashews' => '1 oz',
        'pistachios' => '1 oz',
        'macadamias' => '1 oz',
        'brazil_nuts' => '1 oz',
        'pecans' => '1 oz',
        'flaxseeds' => '1 oz',
        'chia_seeds' => '1 oz',
        'sunflower_seeds' => '1 oz',
        'pumpkin_seeds' => '1 oz',
        'nutritional_yeast' => '1 tbsp',
        'oils' => '1 tbsp',
        'chonghua_dumplings' => '5 dumplings (3.5 oz)',
        _ => null,
      };
      if (byId != null) return byId;
    }

    return switch (original) {
      '1 glass (250ml)' => '½ pint (8 fl oz)',
      '1 scoop + milk' => '1 scoop + ½ pint milk',
      '1 scoop + soy milk' => '1 scoop + ½ pint soy milk',
      '1 scoop' => '1 scoop',
      '100g (firm)' => '3.5 oz (firm)',
      '100g' => '3.5 oz',
      '1/2 cup' => '4 oz',
      '1 serving (85g)' => '3 oz',
      '1 pot (160g)' => '5.6 oz container',
      '1 cup cooked' => '6 oz cooked',
      '1 cup' => '3 oz',
      '30g (1 oz)' => '1 oz',
      _ => original,
    };
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
