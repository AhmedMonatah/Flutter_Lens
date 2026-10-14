/// Represents aggregated typography statistics for a single style variation on a screen.
class StyleStat {
  StyleStat({
    required this.key,
    required this.displayFamily,
    this.fontSize,
    this.fontWeight,
    this.italic = false,
    this.count = 0,
    this.fontFile,
    List<String>? samples,
    Set<String>? warnings,
  }) : samples = samples ?? [],
       warnings = warnings ?? {};

  /// Unique style key formatted as "family|size|weight|italic".
  final String key;

  /// Resolved display font family.
  final String displayFamily;

  /// Font size in logical pixels, if specified.
  final double? fontSize;

  /// Font weight integer value (e.g. 400, 700), if specified.
  final int? fontWeight;

  /// Whether the style is italic.
  final bool italic;

  /// Associated asset font file path, if resolved.
  final String? fontFile;

  /// Number of texts using this style on the screen in the latest scan.
  int count;

  /// At most 3 distinct sample strings, each at most 40 characters (or placeholders).
  final List<String> samples;

  /// Set of warning codes associated with texts in this style.
  final Set<String> warnings;

  /// Generates the canonical style key.
  static String makeKey({
    required String displayFamily,
    double? fontSize,
    int? fontWeight,
    bool italic = false,
  }) {
    final sizeStr = fontSize != null ? fontSize.toStringAsFixed(0) : '—';
    final weightVal = fontWeight ?? 400;
    return '$displayFamily|$sizeStr|$weightVal|$italic';
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'displayFamily': displayFamily,
    if (fontSize != null) 'fontSize': fontSize,
    if (fontWeight != null) 'fontWeight': fontWeight,
    'italic': italic,
    if (fontFile != null) 'fontFile': fontFile,
    'count': count,
    'samples': samples,
    'warnings': warnings.toList()..sort(),
  };

  factory StyleStat.fromJson(Map<String, dynamic> json) {
    return StyleStat(
      key: json['key'] as String? ?? '',
      displayFamily: json['displayFamily'] as String? ?? 'System',
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      fontWeight: json['fontWeight'] as int?,
      italic: json['italic'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      fontFile: json['fontFile'] as String?,
      samples:
          (json['samples'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
    );
  }
}
