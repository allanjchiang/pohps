import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String get todaysFoods => _t("Today's Foods", '今日食物', '今日食物');

  String itemCount(int count) => _t(
        '$count item${count == 1 ? '' : 's'}',
        '$count 項',
        '$count 项',
      );

  String get noFoodsLoggedYet =>
      _t('No foods logged yet', '尚未記錄任何食物', '尚未记录任何食物');

  String get tapAddFoodToStart => _t(
        'Tap + Add Food to get started',
        '點擊 + 新增食物 開始記錄',
        '点击 + 添加食物 开始记录',
      );

  String get addFood => _t('Add Food', '新增食物', '添加食物');

  String get removeFoodTitle => _t('Remove Food?', '移除食物？', '移除食物？');

  String removeFoodConfirm(String name) => _t(
        'Remove $name from today\'s log?',
        '確定從今日記錄中移除$name？',
        '确定从今日记录中移除$name？',
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

  String get change => _t('Change', '更改', '更改');

  String get appearance => _t('Appearance', '外觀', '外观');
  String get themeAuto => _t('Auto', '自動', '自动');
  String get themeLight => _t('Light', '淺色', '浅色');
  String get themeDark => _t('Dark', '深色', '深色');

  String get language => _t('Language', '語言', '语言');
  String get languageSystem => _t('System', '系統', '系统');

  String get myCustomFoods =>
      _t('My Custom Foods', '我的自訂食物', '我的自定义食物');

  String get aboutPohps => _t('About POHPS', '關於 POHPS', '关于 POHPS');

  String get aboutDescription => _t(
        'A free, open-source protein tracking app designed for elderly lacto-ovo vegetarians.',
        '一款免費的開源蛋白質追蹤應用程式，專為蛋奶素食長者設計。',
        '一款免费的开源蛋白质追踪应用，专为蛋奶素食老年人设计。',
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
  String get allCategory => _t('All', '全部', '全部');
  String get myFoods => _t('My Foods', '我的食物', '我的食物');
  String get noFoodsInCategory =>
      _t('No foods in this category', '此分類沒有食物', '此分类没有食物');
  String get added => _t('✓ Added!', '✓ 已新增！', '✓ 已添加！');

  // ── Custom Food Screen ─────────────────────────────────────────────────

  String get createCustomFood =>
      _t('Create Custom Food', '建立自訂食物', '创建自定义食物');

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
      'Dairy & Eggs' => _t('Dairy & Eggs', '乳蛋類', '乳蛋类'),
      'Protein Boosters' => _t('Protein Boosters', '蛋白質補充', '蛋白质补充'),
      'Legumes' => _t('Legumes', '豆類', '豆类'),
      'Grains' => _t('Grains', '穀物', '谷物'),
      'Vegetables' => _t('Vegetables', '蔬菜', '蔬菜'),
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
      'whey_smoothie' => _t('Whey Smoothie', '乳清蛋白奶昔', '乳清蛋白奶昔'),
      'soy_milk' => _t('Soy Milk', '豆漿', '豆浆'),
      'tofu' => _t('Tofu', '豆腐', '豆腐'),
      'soy_meat' => _t('Soy Meat', '素肉', '素肉'),
      'lentils' => _t('Lentils', '扁豆', '扁豆'),
      'chickpeas' => _t('Chickpeas', '鷹嘴豆', '鹰嘴豆'),
      'white_rice' => _t('White Rice', '白飯', '白米饭'),
      'brown_rice' => _t('Brown Rice', '糙米飯', '糙米饭'),
      'quinoa' => _t('Quinoa', '藜麥', '藜麦'),
      'millet' => _t('Millet', '小米', '小米'),
      'buckwheat' => _t('Buckwheat', '蕎麥', '荞麦'),
      'noodles' => _t('Noodles', '麵條', '面条'),
      'potato' => _t('Potato', '馬鈴薯', '土豆'),
      'mushroom' => _t('Mushroom', '蘑菇', '蘑菇'),
      'cauliflower' => _t('Cauliflower', '花椰菜', '花椰菜'),
      'cabbage' => _t('Cabbage', '高麗菜', '卷心菜'),
      'bok_choy' => _t('Bok Choy', '青江菜', '青菜'),
      'wombok' => _t('Wombok', '大白菜', '大白菜'),
      'capsicum' => _t('Capsicum', '甜椒', '甜椒'),
      'fruits' => _t('Fruits', '水果', '水果'),
      'nuts_seeds' => _t('Nuts & Seeds', '堅果與種子', '坚果与种子'),
      'oils' => _t('Oils', '油脂', '油脂'),
      _ => fallback,
    };
  }

  // ── Default Serving Sizes ──────────────────────────────────────────────

  String servingDisplay(String original) {
    return switch (original) {
      '1 large' => _t('1 large', '1 顆（大）', '1 个（大）'),
      '1 pot (160g)' => _t('1 pot (160g)', '1 杯（160g）', '1 杯（160g）'),
      '1 glass (250ml)' =>
        _t('1 glass (250ml)', '1 杯（250ml）', '1 杯（250ml）'),
      '1 scoop + milk' =>
        _t('1 scoop + milk', '1 勺 + 牛奶', '1 勺 + 牛奶'),
      '100g (firm)' => _t('100g (firm)', '100g（板豆腐）', '100g（老豆腐）'),
      '1 serving (85g)' =>
        _t('1 serving (85g)', '1 份（85g）', '1 份（85g）'),
      '1 cup cooked' => _t('1 cup cooked', '1 杯（煮熟）', '1 杯（煮熟）'),
      '1 medium' => _t('1 medium', '1 個（中）', '1 个（中）'),
      '1 cup' => _t('1 cup', '1 杯', '1 杯'),
      '30g (1 oz)' => _t('30g (1 oz)', '30g（1 盎司）', '30g（1 盎司）'),
      '1 tbsp' => _t('1 tbsp', '1 湯匙', '1 汤匙'),
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
