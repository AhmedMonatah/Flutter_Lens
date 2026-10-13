import 'package:flutter_test/flutter_test.dart';
import 'package:font_lens/src/models/found_text.dart';
import 'package:font_lens/src/resolver/resolver.dart';

// Helper to build a minimal FoundText for testing resolver rules.
FoundText _ft({
  String text = 'Hello',
  String? fontFamily,
  List<String> fallback = const [],
  double? fontSize = 14,
  int? fontWeight = 400,
}) => FoundText(
  text: text,
  fontFamily: fontFamily,
  fontFamilyFallback: fallback,
  fontSize: fontSize,
  fontWeight: fontWeight,
  italic: false,
  color: null,
  height: null,
  rectLTWH: const [0, 0, 0, 0],
  route: null,
);

void main() {
  group('displayFamily()', () {
    test('null → system default string (contains "System default")', () {
      final d = displayFamily(null);
      expect(d, contains('System default'));
    });

    test('packages/<pkg>/<Name> → "Name (from <pkg>)"', () {
      expect(
        displayFamily('packages/my_pkg/Cairo'),
        equals('Cairo (from my_pkg)'),
      );
    });

    test('nested packages prefix', () {
      expect(
        displayFamily('packages/google_fonts/Poppins'),
        equals('Poppins (from google_fonts)'),
      );
    });

    test('google_fonts style "Poppins_regular" → "Poppins"', () {
      expect(displayFamily('Poppins_regular'), equals('Poppins'));
    });

    test('google_fonts style "Poppins_700italic" → "Poppins"', () {
      expect(displayFamily('Poppins_700italic'), equals('Poppins'));
    });

    test('dot-prefixed → "System (SF)"', () {
      expect(displayFamily('.SF UI Text'), equals('System (SF)'));
    });

    test('arbitrary family → returned as-is', () {
      expect(displayFamily('Roboto'), equals('Roboto'));
    });
  });

  group('resolveOne() – Arabic warning', () {
    test('Arabic text with null fontFamily and empty fallback → warning', () {
      final ft = _ft(text: 'مرحبا', fontFamily: null, fallback: []);
      final resolved = resolveOne(ft);
      expect(resolved.warnings, isNotEmpty);
      expect(resolved.warnings.first, contains('Arabic'));
    });

    test(
      'Arabic text with explicit fontFamily but empty fallback → warning',
      () {
        final ft = _ft(text: 'مرحبا', fontFamily: 'Roboto', fallback: []);
        final resolved = resolveOne(ft);
        expect(resolved.warnings, isNotEmpty);
      },
    );

    test('Arabic text with non-empty fallback → no Arabic warning', () {
      final ft = _ft(text: 'مرحبا', fontFamily: 'Roboto', fallback: ['Cairo']);
      final resolved = resolveOne(ft);
      expect(resolved.warnings.where((w) => w.contains('Arabic')), isEmpty);
    });

    test('Non-Arabic text → no warning', () {
      final ft = _ft(text: 'Hello world', fontFamily: null);
      final resolved = resolveOne(ft);
      expect(resolved.warnings.where((w) => w.contains('Arabic')), isEmpty);
    });

    test('Mixed Arabic and English text → warning', () {
      final ft = _ft(text: 'Hello مرحبا', fontFamily: null, fallback: []);
      final resolved = resolveOne(ft);
      expect(resolved.warnings, isNotEmpty);
    });
  });

  group('containsArabic()', () {
    test('Basic Arabic block U+0600–U+06FF', () {
      expect(containsArabic('مرحبا'), isTrue);
    });

    test('Arabic Supplement U+0750–U+077F', () {
      expect(containsArabic('\u0750'), isTrue);
    });

    test('Arabic Presentation Forms-B U+FE70–U+FEFF', () {
      expect(containsArabic('\uFE70'), isTrue);
    });

    test('Latin text → false', () {
      expect(containsArabic('Hello World'), isFalse);
    });

    test('Empty string → false', () {
      expect(containsArabic(''), isFalse);
    });
  });

  group('resolveAll() – screen warnings', () {
    test('More than 3 distinct font families → screen warning', () {
      final items = [
        _ft(fontFamily: 'Roboto'),
        _ft(fontFamily: 'Poppins'),
        _ft(fontFamily: 'Cairo'),
        _ft(fontFamily: 'Merriweather'),
      ];
      final result = resolveAll(
        items,
        route: '/test',
        timestamp: DateTime.now(),
        platform: 'android',
      );
      expect(result.screenWarnings, isNotEmpty);
      expect(result.screenWarnings.first, contains('Too many font families'));
    });

    test('3 or fewer families → no "too many" warning', () {
      final items = [
        _ft(fontFamily: 'Roboto'),
        _ft(fontFamily: 'Poppins'),
        _ft(fontFamily: 'Cairo'),
      ];
      final result = resolveAll(
        items,
        route: '/test',
        timestamp: DateTime.now(),
        platform: 'android',
      );
      expect(
        result.screenWarnings.where(
          (w) => w.contains('Too many font families'),
        ),
        isEmpty,
      );
    });

    test('More than 8 distinct sizes → screen warning', () {
      final items = List.generate(9, (i) => _ft(fontSize: (10 + i).toDouble()));
      final result = resolveAll(
        items,
        route: '/test',
        timestamp: DateTime.now(),
        platform: 'android',
      );
      expect(
        result.screenWarnings.where(
          (w) => w.contains('Too many distinct font sizes'),
        ),
        isNotEmpty,
      );
    });

    test('Faux-bold: weight 700 with only one variant → screen warning', () {
      final items = [
        _ft(fontFamily: 'Roboto', fontWeight: 700),
        _ft(fontFamily: 'Roboto', fontWeight: 700),
      ];
      final result = resolveAll(
        items,
        route: '/test',
        timestamp: DateTime.now(),
        platform: 'android',
      );
      expect(
        result.screenWarnings.where((w) => w.contains('faux-bold')),
        isNotEmpty,
      );
    });

    test('Two weight variants of same family → no faux-bold warning', () {
      final items = [
        _ft(fontFamily: 'Roboto', fontWeight: 400),
        _ft(fontFamily: 'Roboto', fontWeight: 700),
      ];
      final result = resolveAll(
        items,
        route: '/test',
        timestamp: DateTime.now(),
        platform: 'android',
      );
      expect(
        result.screenWarnings.where((w) => w.contains('faux-bold')),
        isEmpty,
      );
    });
  });

  group('resolveFontFile()', () {
    test('null or empty -> system fallback', () {
      expect(resolveFontFile(null), contains('System'));
      expect(resolveFontFile(''), contains('System'));
    });

    test('packages prefix -> package font path', () {
      expect(
        resolveFontFile('packages/my_pkg/Cairo', weight: 700),
        equals('packages/my_pkg/fonts/Cairo-Bold.ttf'),
      );
    });

    test('google_fonts style -> google_fonts/<Family>-<Weight>.ttf', () {
      expect(
        resolveFontFile('Cairo_regular', weight: 400),
        equals('google_fonts/Cairo-Regular.ttf'),
      );
    });

    test('custom asset family -> assets/fonts/<Family>-<Weight>.ttf', () {
      expect(
        resolveFontFile('Cairo', weight: 700),
        equals('assets/fonts/Cairo-Bold.ttf'),
      );
      expect(
        resolveFontFile('Cairo', weight: 400, italic: true),
        equals('assets/fonts/Cairo-Italic.ttf'),
      );
    });

    test('already a file path -> returns as-is', () {
      expect(
        resolveFontFile('assets/fonts/Custom.ttf'),
        equals('assets/fonts/Custom.ttf'),
      );
    });
  });
}
