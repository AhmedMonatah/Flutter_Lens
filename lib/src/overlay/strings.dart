/// Small, standalone string dictionary for font_lens panel (en & ar).
/// Independent of the host app's localization delegates.
class FontLensStrings {
  const FontLensStrings({
    required this.title,
    required this.pick,
    required this.pickMode,
    required this.tapAnyText,
    required this.noTextHere,
    required this.rescan,
    required this.settings,
    required this.close,
    required this.all,
    required this.warnings,
    required this.show,
    required this.hide,
    required this.selectedText,
    required this.showInList,
    required this.emptyState,
    required this.theme,
    required this.language,
    required this.themeDevice,
    required this.themeLight,
    required this.themeDark,
    required this.themeApp,
    required this.langDevice,
    required this.langEn,
    required this.langAr,
    required this.copyJson,
    required this.copied,
    required this.ok,
    required this.clearSavedScreens,
    this.isArabic = false,
  });

  final String title;
  final String pick;
  final String pickMode;
  final String tapAnyText;
  final String noTextHere;
  final String rescan;
  final String settings;
  final String close;
  final String all;
  final String warnings;
  final String show;
  final String hide;
  final String selectedText;
  final String showInList;
  final String emptyState;
  final String theme;
  final String language;
  final String themeDevice;
  final String themeLight;
  final String themeDark;
  final String themeApp;
  final String langDevice;
  final String langEn;
  final String langAr;
  final String copyJson;
  final String copied;
  final String ok;
  final String clearSavedScreens;
  final bool isArabic;

  String fontsCount(int n) {
    if (isArabic) {
      if (n == 1) return 'خط واحد';
      if (n == 2) return 'خطان';
      if (n >= 3 && n <= 10) return '$n خطوط';
      return '$n خطاً';
    }
    return n == 1 ? '1 font' : '$n fonts';
  }

  String sizesCount(int n) {
    if (isArabic) {
      if (n == 1) return 'حجم واحد';
      if (n == 2) return 'حجمان';
      if (n >= 3 && n <= 10) return '$n أحجام';
      return '$n حجماً';
    }
    return n == 1 ? '1 size' : '$n sizes';
  }

  String warningsCount(int n) {
    if (isArabic) {
      if (n == 1) return 'تحذير واحد';
      if (n == 2) return 'تحذيران';
      if (n >= 3 && n <= 10) return '$n تحذيرات';
      return '$n تحذيراً';
    }
    return n == 1 ? '1 warning' : '$n warnings';
  }

  String usedInCount(int n) {
    if (isArabic) {
      if (n == 1) return 'مستخدم في نص واحد';
      if (n == 2) return 'مستخدم في نصين';
      if (n >= 3 && n <= 10) return 'مستخدم في $n نصوص';
      return 'مستخدم في $n نصاً';
    }
    return n == 1 ? 'Used in 1 text' : 'Used in $n texts';
  }

  String screensSavedCount(int n) {
    if (isArabic) {
      if (n == 1) return 'شاشة واحدة محفوظة';
      if (n == 2) return 'شاشتان محفوظتان';
      if (n >= 3 && n <= 10) return '$n شاشات محفوظة';
      return '$n شاشة محفوظة';
    }
    return n == 1 ? '1 screen saved' : '$n screens saved';
  }

  String translateWarning(String w) {
    if (!isArabic) return w;

    final familiesMatch =
        RegExp(r'Too many font families on one screen \((\d+)\)').firstMatch(w);
    if (familiesMatch != null) {
      final count = familiesMatch.group(1);
      return 'عدد عائلات الخطوط كبير على شاشة واحدة ($count). يُنصح بحصرها في 3 أو أقل للتناسق البصري.';
    }

    final sizesMatch =
        RegExp(r'Too many distinct font sizes on one screen \((\d+)\)')
            .firstMatch(w);
    if (sizesMatch != null) {
      final count = sizesMatch.group(1);
      return 'عدد أحجام الخطوط كبير على شاشة واحدة ($count). استخدام مقياس أحجام موحد يسهل القراءة.';
    }

    if (w.contains('Arabic text relies on the system fallback font')) {
      return 'النص العربي يعتمد على خط النظام الاحتياطي وقد يختلف مظهره بين الأجهزة. يُفضّل استخدام خط عربي مثل Cairo أو Tajawal.';
    }

    final fauxBoldMatch =
        RegExp(r'Possible faux-bold: "([^"]+)" uses weight (\d+)').firstMatch(w);
    if (fauxBoldMatch != null) {
      final family = fauxBoldMatch.group(1);
      final weight = fauxBoldMatch.group(2);
      return 'احتمال وجود خط عريض مصطنع (faux-bold): يستخدم خط "$family" الوزن $weight دون وجود ملف خط عريض في pubspec.yaml.';
    }

    return w;
  }

  static const en = FontLensStrings(
    title: 'font_lens',
    pick: 'Pick',
    pickMode: 'Pick mode',
    tapAnyText: 'Tap any text on screen',
    noTextHere: 'No text here',
    rescan: 'Rescan',
    settings: 'Settings',
    close: 'Close',
    all: 'All',
    warnings: 'Warnings',
    show: 'Show',
    hide: 'Hide',
    selectedText: 'Selected text',
    showInList: 'Show in list',
    emptyState:
        'No text on this screen. Scroll or open a screen with text, then rescan.',
    theme: 'Theme',
    language: 'Language',
    themeDevice: 'Device',
    themeLight: 'Light',
    themeDark: 'Dark',
    themeApp: 'App',
    langDevice: 'Device',
    langEn: 'English',
    langAr: 'العربية',
    copyJson: 'Copy report JSON',
    copied: 'Copied to clipboard',
    ok: 'OK',
    clearSavedScreens: 'Clear saved screens',
    isArabic: false,
  );

  static const ar = FontLensStrings(
    title: 'font_lens',
    pick: 'تحديد',
    pickMode: 'وضع التحديد',
    tapAnyText: 'اضغط على أي نص على الشاشة',
    noTextHere: 'لا يوجد نص هنا',
    rescan: 'إعادة الفحص',
    settings: 'الإعدادات',
    close: 'إغلاق',
    all: 'الكل',
    warnings: 'التحذيرات',
    show: 'عرض',
    hide: 'إخفاء',
    selectedText: 'النص المحدد',
    showInList: 'عرض في القائمة',
    emptyState:
        'لا يوجد نص على هذه الشاشة. مرر أو افتح شاشة بها نصوص ثم أعد الفحص.',
    theme: 'المظهر',
    language: 'اللغة',
    themeDevice: 'الجهاز',
    themeLight: 'فاتح',
    themeDark: 'داكن',
    themeApp: 'التطبيق',
    langDevice: 'الجهاز',
    langEn: 'English',
    langAr: 'العربية',
    copyJson: 'نسخ التقرير بتنسيق JSON',
    copied: 'تم النسخ إلى الحافظة',
    ok: 'حسناً',
    clearSavedScreens: 'مسح الشاشات المحفوظة',
    isArabic: true,
  );

  static FontLensStrings of(String? languageCode) {
    if (languageCode == 'ar') return ar;
    return en;
  }
}
