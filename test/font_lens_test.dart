import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_lens/font_lens.dart';

void main() {
  group('FontLens CustomPainter tracking', () {
    tearDown(() {
      FontLens.clearTracked();
    });

    test('track registers a TextPainter and returns it transparently', () {
      FontLens.clearTracked();
      expect(FontLens.trackedPainters, isEmpty);

      final painter = TextPainter(
        text: const TextSpan(text: 'Canvas text'),
        textDirection: TextDirection.ltr,
      );

      final returned = FontLens.track(painter);
      expect(identical(returned, painter), isTrue);
      expect(FontLens.trackedPainters, contains(painter));
    });

    test('clearTracked empties tracked list', () {
      final painter = TextPainter(
        text: const TextSpan(text: 'Another text'),
        textDirection: TextDirection.ltr,
      );
      FontLens.track(painter);
      expect(FontLens.trackedPainters.length, 1);

      FontLens.clearTracked();
      expect(FontLens.trackedPainters, isEmpty);
    });
  });
}
