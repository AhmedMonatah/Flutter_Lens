/// A single piece of text found on screen during a scan, with its raw style.
class FoundText {
  /// Creates a [FoundText] instance.
  const FoundText({
    required this.text,
    required this.fontFamily,
    required this.fontFamilyFallback,
    required this.fontSize,
    required this.fontWeight,
    required this.italic,
    required this.color,
    required this.height,
    required this.rectLTWH,
    required this.route,
    this.element,
  });

  /// The visible text content.
  final String text;

  /// Raw `fontFamily` from the [TextStyle]; may be null (meaning system default).
  final String? fontFamily;

  /// Raw `fontFamilyFallback` from the [TextStyle].
  final List<String> fontFamilyFallback;

  /// Font size in logical pixels.
  final double? fontSize;

  /// Font weight as an integer 100–900, or null.
  final int? fontWeight;

  /// Whether the text is italic.
  final bool italic;

  /// Color as an ARGB integer, or null.
  final int? color;

  /// Line height multiplier.
  final double? height;

  /// Bounding box in global screen coordinates as [left, top, width, height].
  final List<double> rectLTWH;

  /// Left coordinate.
  double get left => rectLTWH.isNotEmpty ? rectLTWH[0] : 0.0;

  /// Top coordinate.
  double get top => rectLTWH.length > 1 ? rectLTWH[1] : 0.0;

  /// Width.
  double get width => rectLTWH.length > 2 ? rectLTWH[2] : 0.0;

  /// Height in pixels.
  double get heightPx => rectLTWH.length > 3 ? rectLTWH[3] : 0.0;

  /// Named route where this text was found, or null for anonymous routes.
  final String? route;

  /// Optional widget element reference (e.g. for scrolling into view).
  /// Not serialized.
  final Object? element;

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'text': text,
    'fontFamily': fontFamily,
    'fontFamilyFallback': fontFamilyFallback,
    'fontSize': fontSize,
    'fontWeight': fontWeight,
    'italic': italic,
    'color': color,
    'height': height,
    'rect': rectLTWH,
    'route': route,
  };

  /// Deserialises from a JSON map.
  factory FoundText.fromJson(Map<String, dynamic> json) => FoundText(
    text: json['text'] as String,
    fontFamily: json['fontFamily'] as String?,
    fontFamilyFallback: (json['fontFamilyFallback'] as List<dynamic>? ?? [])
        .cast<String>(),
    fontSize: (json['fontSize'] as num?)?.toDouble(),
    fontWeight: json['fontWeight'] as int?,
    italic: json['italic'] as bool? ?? false,
    color: json['color'] as int?,
    height: (json['height'] as num?)?.toDouble(),
    rectLTWH: _rectListFromJson(json['rect'] as List<dynamic>),
    route: json['route'] as String?,
  );

  static List<double> _rectListFromJson(List<dynamic> r) => [
    (r[0] as num).toDouble(),
    (r[1] as num).toDouble(),
    (r[2] as num).toDouble(),
    (r[3] as num).toDouble(),
  ];
}
