// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/found_text.dart';
import '../models/scan_result.dart';
import '../resolver/resolver.dart';
import '../scanner/scanner.dart';

/// Supported theme modes for the font_lens panel.
enum FontLensThemeMode { device, app, light, dark }

/// The three vertical snap heights of the inspector panel.
enum PanelSnap {
  collapsed(0.10, 72.0),
  half(0.38, 300.0),
  full(0.90, 700.0);

  const PanelSnap(this.fraction, this.approxDp);
  final double fraction;
  final double approxDp;
}

/// A collection of [ResolvedText] items that share the exact same typography style.
class StyleGroup {
  StyleGroup({
    required this.key,
    required this.displayFamily,
    required this.rawFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.italic,
    required this.items,
  });

  final String key;
  final String displayFamily;
  final String? rawFamily;
  final double? fontSize;
  final int? fontWeight;
  final bool italic;
  final List<ResolvedText> items;

  int get count => items.length;
  bool get hasWarnings => items.any((t) => t.warnings.isNotEmpty);
  String get specimenText => items.first.source.text;
  ResolvedText get firstItem => items.first;

  static String makeKey({
    required String displayFamily,
    required double? fontSize,
    required int? fontWeight,
    required bool italic,
  }) =>
      '$displayFamily|${fontSize?.toStringAsFixed(1)}|$fontWeight|$italic';
}

/// Controller managing font_lens panel state, selection, scans, and pick mode.
class FontLensController extends ChangeNotifier {
  FontLensController({
    FontLensThemeMode themeMode = FontLensThemeMode.device,
    Locale? locale,
  })  : _themeMode = themeMode,
        _locale = locale;

  bool _isVisible = false;
  PanelSnap _snap = PanelSnap.half;
  bool _isPickMode = false;
  ScanResult? _scanResult;
  List<StyleGroup> _groups = const [];

  String? _activeFilterFamily;
  String? _selectedGroupKey;
  FoundText? _pickedText;
  bool _warningsExpanded = false;
  bool _isSettingsOpen = false;

  FontLensThemeMode _themeMode;
  Locale? _locale;
  Offset _launcherPosition = const Offset(16, 200);

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isVisible => _isVisible;
  PanelSnap get snap => _snap;
  bool get isPickMode => _isPickMode;
  ScanResult? get scanResult => _scanResult;
  List<StyleGroup> get groups => _groups;

  String? get activeFilterFamily => _activeFilterFamily;
  String? get selectedGroupKey => _selectedGroupKey;
  FoundText? get pickedText => _pickedText;
  bool get warningsExpanded => _warningsExpanded;
  bool get isSettingsOpen => _isSettingsOpen;

  FontLensThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  Offset get launcherPosition => _launcherPosition;

  List<ResolvedText> get selectedTexts {
    if (_selectedGroupKey == null) return const [];
    final match = _groups.where((g) => g.key == _selectedGroupKey).firstOrNull;
    return match?.items ?? const [];
  }

  int get distinctFontsCount {
    if (_scanResult == null) return 0;
    return _scanResult!.texts.map((t) => t.displayFamily).toSet().length;
  }

  int get distinctSizesCount {
    if (_scanResult == null) return 0;
    return _scanResult!.texts
        .map((t) => t.source.fontSize)
        .whereType<double>()
        .toSet()
        .length;
  }

  int get totalWarningsCount {
    if (_scanResult == null) return 0;
    return _scanResult!.texts.expand((t) => t.warnings).length +
        _scanResult!.screenWarnings.length;
  }

  List<String> get distinctFamilies {
    if (_scanResult == null) return const [];
    return _scanResult!.texts.map((t) => t.displayFamily).toSet().toList()
      ..sort();
  }

  // ---------------------------------------------------------------------------
  // Global root element provider
  // ---------------------------------------------------------------------------

  /// Global provider for the active host app root element to scan.
  static Element? Function()? activeRootElementProvider;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Shows the inspector. By default, opens in collapsed pick mode.
  void show({bool startInPick = true, Element? rootElement}) {
    _isVisible = true;
    if (startInPick) {
      _snap = PanelSnap.collapsed;
      _isPickMode = true;
    } else {
      _snap = PanelSnap.half;
      _isPickMode = false;
    }
    _selectedGroupKey = null;
    _pickedText = null;
    scan(rootElement: rootElement);
    notifyListeners();
  }

  /// Hides the inspector panel and leaves the launcher button.
  void hide() {
    _isVisible = false;
    _isPickMode = false;
    _selectedGroupKey = null;
    _pickedText = null;
    notifyListeners();
  }

  /// Executes a scan on the provided [rootElement] (or the active host app subtree).
  void scan({Element? rootElement}) {
    final target = rootElement ?? activeRootElementProvider?.call();
    final raw = scanScreen(rootElement: target);
    final result = resolveAll(
      raw,
      route: null,
      timestamp: DateTime.now().toUtc(),
      platform: ScanResult.currentPlatform(),
    );
    _scanResult = result;
    _computeGroups(result.texts);

    notifyListeners();
  }

  /// Sets scan result directly (useful for tests or service extensions).
  void setScanResult(ScanResult result) {
    _scanResult = result;
    _computeGroups(result.texts);
    notifyListeners();
  }

  /// Starts tap-to-inspect mode: collapses panel, activates pick layer, and scans live screen.
  void startPick({Element? rootElement}) {
    _isPickMode = true;
    _snap = PanelSnap.collapsed;
    _pickedText = null;
    scan(rootElement: rootElement);
    notifyListeners();
  }

  /// Exits tap-to-inspect mode.
  void stopPick({bool expand = false}) {
    _isPickMode = false;
    _pickedText = null;
    if (expand) {
      _snap = PanelSnap.half;
      scan();
    }
    notifyListeners();
  }

  /// Sets the currently inspected text from a tap.
  void setPickedText(FoundText? text) {
    _pickedText = text;
    if (text != null) {
      final disp = displayFamily(text.fontFamily);
      final key = StyleGroup.makeKey(
        displayFamily: disp,
        fontSize: text.fontSize,
        fontWeight: text.fontWeight,
        italic: text.italic,
      );
      _selectedGroupKey = key;
    }
    notifyListeners();
  }

  /// Toggles or sets selected group by key.
  void selectGroup(String? key) {
    if (_selectedGroupKey == key) {
      _selectedGroupKey = null;
    } else {
      _selectedGroupKey = key;
    }
    notifyListeners();
  }

  /// Sets the panel height snap.
  void setSnap(PanelSnap snap) {
    _snap = snap;
    if (snap != PanelSnap.collapsed) {
      _isPickMode = false;
      scan();
    }
    notifyListeners();
  }

  /// Sets active filter family chip (null = All, or family name, or '__warnings__').
  void setFilterFamily(String? family) {
    _activeFilterFamily = family;
    notifyListeners();
  }

  /// Toggles warnings expansion.
  void toggleWarnings() {
    _warningsExpanded = !_warningsExpanded;
    notifyListeners();
  }

  /// Toggles settings view inside the panel.
  void toggleSettings() {
    _isSettingsOpen = !_isSettingsOpen;
    notifyListeners();
  }

  /// Closes the settings view.
  void closeSettings() {
    if (_isSettingsOpen) {
      _isSettingsOpen = false;
      notifyListeners();
    }
  }

  /// Updates theme mode.
  void setThemeMode(FontLensThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Updates language override.
  void setLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  /// Updates floating launcher button position.
  void setLauncherPosition(Offset offset) {
    _launcherPosition = offset;
    notifyListeners();
  }

  void _computeGroups(List<ResolvedText> texts) {
    final map = <String, List<ResolvedText>>{};
    for (final t in texts) {
      final key = StyleGroup.makeKey(
        displayFamily: t.displayFamily,
        fontSize: t.source.fontSize,
        fontWeight: t.source.fontWeight,
        italic: t.source.italic,
      );
      map.putIfAbsent(key, () => []).add(t);
    }

    _groups = map.entries.map((e) {
      final first = e.value.first;
      return StyleGroup(
        key: e.key,
        displayFamily: first.displayFamily,
        rawFamily: first.source.fontFamily,
        fontSize: first.source.fontSize,
        fontWeight: first.source.fontWeight,
        italic: first.source.italic,
        items: e.value,
      );
    }).toList();
  }

  /// Resolves current brightness based on [themeMode] and [appBrightness].
  Brightness resolveBrightness(BuildContext context, Brightness appBrightness) {
    switch (_themeMode) {
      case FontLensThemeMode.device:
        return PlatformDispatcher.instance.platformBrightness;
      case FontLensThemeMode.app:
        return appBrightness;
      case FontLensThemeMode.light:
        return Brightness.light;
      case FontLensThemeMode.dark:
        return Brightness.dark;
    }
  }

  /// Resolves language code based on [locale] or device platform locale.
  String resolveLanguageCode() {
    if (_locale != null) return _locale!.languageCode;
    final dev = PlatformDispatcher.instance.locale.languageCode;
    return (dev == 'ar') ? 'ar' : 'en';
  }
}
