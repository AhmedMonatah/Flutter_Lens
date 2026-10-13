import 'found_text.dart';
import 'platform_helper.dart';

/// The resolved display information for a single [FoundText].
class ResolvedText {
  /// Creates a [ResolvedText].
  const ResolvedText({
    required this.source,
    required this.displayFamily,
    required this.warnings,
    this.fontFile,
  });

  /// The original scanned text item.
  final FoundText source;

  /// Human-readable font family name after resolution rules are applied.
  final String displayFamily;

  /// Any warnings produced by the resolver for this item.
  final List<String> warnings;

  /// Inferred or resolved font asset/file name (e.g. "assets/fonts/Cairo-Regular.ttf").
  final String? fontFile;

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    ...source.toJson(),
    'displayFamily': displayFamily,
    'warnings': warnings,
    if (fontFile != null) 'fontFile': fontFile,
  };
}

/// The output of a single scan: all text found on screen, metadata, and any
/// cross-screen warnings.
class ScanResult {
  /// Creates a [ScanResult].
  const ScanResult({
    required this.texts,
    required this.timestamp,
    required this.platform,
    required this.route,
    required this.screenWidth,
    required this.screenHeight,
    this.screenWarnings = const [],
  });

  /// All resolved text items found during this scan.
  final List<ResolvedText> texts;

  /// When the scan was taken (UTC).
  final DateTime timestamp;

  /// Platform string, e.g. `"android"`, `"ios"`, `"windows"`.
  final String platform;

  /// The current named route at scan time.
  final String? route;

  /// Logical screen width in pixels.
  final double screenWidth;

  /// Logical screen height in pixels.
  final double screenHeight;

  /// Warnings that apply to the whole screen (e.g. too many fonts).
  final List<String> screenWarnings;

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'platform': platform,
    'route': route,
    'screenSize': {'width': screenWidth, 'height': screenHeight},
    'screenWarnings': screenWarnings,
    'texts': texts.map((t) => t.toJson()).toList(),
  };

  /// Deserialises from a JSON map.
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final size = json['screenSize'] as Map<String, dynamic>;
    return ScanResult(
      texts: (json['texts'] as List<dynamic>)
          .map((e) => _resolvedFromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      platform: json['platform'] as String,
      route: json['route'] as String?,
      screenWidth: (size['width'] as num).toDouble(),
      screenHeight: (size['height'] as num).toDouble(),
      screenWarnings: (json['screenWarnings'] as List<dynamic>? ?? [])
          .cast<String>(),
    );
  }

  static ResolvedText _resolvedFromJson(Map<String, dynamic> json) =>
      ResolvedText(
        source: FoundText.fromJson(json),
        displayFamily: json['displayFamily'] as String? ?? '',
        warnings: (json['warnings'] as List<dynamic>? ?? []).cast<String>(),
        fontFile: json['fontFile'] as String?,
      );

  /// Returns the current platform as a lowercase string.
  /// Uses [currentPlatformName] from [platform_helper.dart] which is
  /// resolved via conditional imports (dart:io on VM, web fallback on web).
  static String currentPlatform() => currentPlatformName();
}
