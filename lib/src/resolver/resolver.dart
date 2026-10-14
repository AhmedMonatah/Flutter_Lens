import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

import '../models/found_text.dart';
import '../models/scan_result.dart';

// ---------------------------------------------------------------------------
// Arabic Unicode ranges used to detect Arabic text.
// ---------------------------------------------------------------------------
final _arabicRe = RegExp(
  r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
);

// google_fonts encodes family names like "Poppins_regular" or "Poppins_700italic".
final _googleFontsRe = RegExp(r'^([A-Z][a-zA-Z0-9 ]*)_\d*\w*$');

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Resolves a list of [FoundText] items into [ResolvedText] items and
/// produces screen-level warnings.
///
/// All rules are applied in pure Dart without touching the widget tree, so
/// each rule is independently unit-testable.
ScanResult resolveAll(
  List<FoundText> items, {
  required String? route,
  required DateTime timestamp,
  required String platform,
}) {
  final resolved = items.map(resolveOne).toList();
  final screenWarnings = _screenWarnings(resolved);

  return ScanResult(
    texts: resolved,
    timestamp: timestamp,
    platform: platform,
    route: route,
    screenWidth: _currentScreenWidth(),
    screenHeight: _currentScreenHeight(),
    screenWarnings: screenWarnings,
  );
}

/// Resolves a single [FoundText] into a [ResolvedText].
ResolvedText resolveOne(FoundText ft) {
  final display = _displayFamily(ft.fontFamily);
  final warnings = <String>[];

  if (_isArabic(ft.text)) {
    final hasNoFallback =
        ft.fontFamily == null || ft.fontFamilyFallback.isEmpty;
    if (hasNoFallback) {
      warnings.add(
        'Arabic text relies on the system fallback font. '
        'Appearance will differ across devices. '
        'Set an Arabic-capable font such as Cairo or Tajawal.',
      );
    }
  }

  final file = resolveFontFile(
    ft.fontFamily,
    weight: ft.fontWeight,
    italic: ft.italic,
  );

  return ResolvedText(
    source: ft,
    displayFamily: display,
    warnings: warnings,
    fontFile: file,
  );
}

/// Resolves or infers the font file or asset source name for a given font family.
String resolveFontFile(String? rawFamily, {int? weight, bool italic = false}) {
  if (rawFamily == null || rawFamily.isEmpty) {
    return _systemFontFileName();
  }

  // System-internal fonts starting with a dot
  if (rawFamily.startsWith('.')) {
    return _systemFontFileName();
  }

  final suffix = _weightSuffix(weight, italic: italic);

  // Packages prefix: "packages/<pkg>/<family>"
  if (rawFamily.startsWith('packages/')) {
    final parts = rawFamily.split('/');
    if (parts.length >= 3) {
      final pkg = parts[1];
      final fontName = parts.sublist(2).join('/');
      return 'packages/$pkg/fonts/$fontName-$suffix.ttf';
    }
    return '$rawFamily.ttf';
  }

  // Google fonts: e.g. "Cairo_regular", "Poppins_700italic"
  final gfMatch = _googleFontsRe.firstMatch(rawFamily);
  if (gfMatch != null) {
    final family = gfMatch.group(1)!;
    return 'google_fonts/$family-$suffix.ttf';
  }

  // If already ends with an extension (.ttf, .otf, .woff2, .woff)
  final lower = rawFamily.toLowerCase();
  if (lower.endsWith('.ttf') ||
      lower.endsWith('.otf') ||
      lower.endsWith('.woff2') ||
      lower.endsWith('.woff')) {
    return rawFamily;
  }

  // Custom asset family declared in pubspec.yaml
  return 'assets/fonts/$rawFamily-$suffix.ttf';
}

String _weightSuffix(int? weight, {bool italic = false}) {
  final name = switch (weight) {
    100 => 'Thin',
    200 => 'ExtraLight',
    300 => 'Light',
    500 => 'Medium',
    600 => 'SemiBold',
    700 => 'Bold',
    800 => 'ExtraBold',
    900 => 'Black',
    _ => 'Regular',
  };
  if (italic) {
    return name == 'Regular' ? 'Italic' : '${name}Italic';
  }
  return name;
}

String _systemFontFileName() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'System (Roboto / Noto)';
    case TargetPlatform.iOS:
      return 'System (SF Pro / Apple)';
    case TargetPlatform.macOS:
      return 'System (SF Pro)';
    case TargetPlatform.windows:
      return 'System (Segoe UI)';
    case TargetPlatform.linux:
      return 'System (Distro default)';
    case TargetPlatform.fuchsia:
      return 'System (Roboto)';
  }
}

// ---------------------------------------------------------------------------
// Family resolution rules (applied in order)
// ---------------------------------------------------------------------------

/// Converts a raw [fontFamily] value to a human-readable display string.
String displayFamily(String? fontFamily) => _displayFamily(fontFamily);

String _displayFamily(String? raw) {
  if (raw == null) return _systemDefault();

  // Packages prefix: "packages/<pkg>/<Family>" -> "Family (from <pkg>)"
  if (raw.startsWith('packages/')) {
    final parts = raw.split('/');
    if (parts.length >= 3) {
      final pkg = parts[1];
      final name = parts.sublist(2).join('/');
      return '$name (from $pkg)';
    }
  }

  // google_fonts style e.g. "Poppins_regular", "Poppins_700italic"
  final gfMatch = _googleFontsRe.firstMatch(raw);
  if (gfMatch != null) return gfMatch.group(1)!;

  // System-internal font that starts with a dot, e.g. ".SF UI Text"
  if (raw.startsWith('.')) return 'System (SF)';

  return raw;
}

String _systemDefault() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'System default (Roboto on Android)';
    case TargetPlatform.iOS:
      return 'System default (SF Pro on iOS)';
    case TargetPlatform.macOS:
      return 'System default (SF Pro on macOS)';
    case TargetPlatform.windows:
      return 'System default (Segoe UI on Windows)';
    case TargetPlatform.linux:
      return 'System default (varies by distro)';
    case TargetPlatform.fuchsia:
      return 'System default (Fuchsia)';
  }
}

// ---------------------------------------------------------------------------
// Per-text checks
// ---------------------------------------------------------------------------

/// Returns `true` if [text] contains any Arabic character.
bool containsArabic(String text) => _arabicRe.hasMatch(text);

bool _isArabic(String text) => containsArabic(text);

// ---------------------------------------------------------------------------
// Screen-level warnings
// ---------------------------------------------------------------------------

List<String> _screenWarnings(List<ResolvedText> resolved) {
  final warnings = <String>[];

  final families = resolved.map((r) => r.displayFamily).toSet();
  if (families.length > 3) {
    warnings.add(
      'Too many font families on one screen (${families.length}). '
      'Consider consolidating to 3 or fewer for visual consistency.',
    );
  }

  final sizes = resolved
      .map((r) => r.source.fontSize)
      .whereType<double>()
      .toSet();
  if (sizes.length > 8) {
    warnings.add(
      'Too many distinct font sizes on one screen (${sizes.length}). '
      'A consistent type scale improves readability.',
    );
  }

  // Faux-bold detection: weight >= 600 requested, but only one weight variant
  // of that family appears on screen. Flutter may synthesise bold instead of
  // loading a bold asset.
  final allFamilyWeights = <String, Set<int>>{};
  for (final r in resolved) {
    final w = r.source.fontWeight;
    if (w != null) {
      allFamilyWeights.putIfAbsent(r.displayFamily, () => {}).add(w);
    }
  }
  for (final entry in allFamilyWeights.entries) {
    final weights = entry.value;
    final hasBold = weights.any((w) => w >= 600);
    if (hasBold && weights.length == 1) {
      warnings.add(
        'Possible faux-bold: "${entry.key}" uses weight ${weights.first} '
        'but only one weight variant was seen. '
        'Ensure the bold font asset is declared in pubspec.yaml.',
      );
    }
  }

  return warnings;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

double _currentScreenWidth() {
  final view = PlatformDispatcher.instance.views.first;
  return view.physicalSize.width / view.devicePixelRatio;
}

double _currentScreenHeight() {
  final view = PlatformDispatcher.instance.views.first;
  return view.physicalSize.height / view.devicePixelRatio;
}
