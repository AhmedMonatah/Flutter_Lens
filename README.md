# font_lens

> **Debug-only Flutter typography inspector.** Tap one button to see every
> font family, size, weight, and colour your screen is actually using — not
> what the theme defines, but what the render tree contains.

---

## Why font_lens?

| Tool | What it shows |
|---|---|
| `font_preview` | Fonts you list by hand |
| `theme_inspector` | What the theme *defines* |
| **font_lens** | What this screen *actually uses right now* |

font_lens also explains `fontFamily == null` as **"System default (Roboto on
Android)"** instead of leaving you guessing, and warns when Arabic text has no
fallback font configured.

---

## Install

Add to `dev_dependencies` (recommended — zero cost in release):

```yaml
dev_dependencies:
  font_lens: ^0.1.0
```

---

## Quick start (3 lines)

```dart
import 'package:flutter/foundation.dart';
import 'package:font_lens/font_lens.dart';

MaterialApp(
  builder: (context, child) => FontLens(
    enabled: kDebugMode,   // zero overhead in release
    child: child!,
  ),
)
```

A floating button appears in debug mode. Tap it to inspect every typography
style on the current screen, highlight text items, and tap to inspect in Pick mode.

---

## CustomPainter opt-in

Text drawn inside `CustomPainter` is invisible to the scanner.
Register painters explicitly:

```dart
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tp = FontLens.track(
      TextPainter(
        text: const TextSpan(text: 'Custom', style: TextStyle(fontSize: 18)),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
    tp.paint(canvas, Offset.zero);
  }
}
```

---

## Known limits

1. Text drawn with `TextPainter` inside a `CustomPainter` is invisible to the
   tree. Use `FontLens.track(painter)` as an opt-in.
2. The exact system font chosen for `fontFamily == null` is unknowable from
   Dart. The platform default name is shown as an approximation.
3. Text inside platform views (maps, webviews) cannot be scanned.

---

## Warnings font_lens produces

| Warning | Condition |
|---|---|
| Arabic without fallback | Arabic text with no `fontFamilyFallback` |
| Too many font families | > 3 distinct families on one screen |
| Too many font sizes | > 8 distinct sizes on one screen |
| Possible faux-bold | Weight ≥ 600 but only one weight variant seen |

---

## Contributing

Issues and PRs welcome. Run the test suite locally:

```sh
flutter analyze
flutter test
dart format --set-exit-if-changed .
```
"# Flutter_Lens" 
