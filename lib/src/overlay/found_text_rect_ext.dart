import 'dart:ui' show Rect;

import '../models/found_text.dart';

/// Flutter-specific extension on [FoundText] providing a [Rect] representation.
/// Kept out of the core data model so that CLI utilities remain 100% pure Dart.
extension FoundTextRectExt on FoundText {
  /// Global bounding [Rect] for Flutter overlay layout and collision checks.
  Rect get rect => Rect.fromLTWH(left, top, width, heightPx);
}
