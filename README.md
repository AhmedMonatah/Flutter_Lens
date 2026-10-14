<p align="center">
  <img src="https://raw.githubusercontent.com/AhmedMonatah/Flutter_Lens/main/assets/images/logo.png" alt="Font Lens logo" width="120" />
</p>

<h1 align="center">Font Lens</h1>

<p align="center">
  A live typography inspector for Flutter.<br>
  See the fonts your screen actually renders, not just what your theme defines.
</p>

<p align="center">
  <a href="https://pub.dev/packages/font_lens"><img src="https://img.shields.io/pub/v/font_lens.svg?color=blue&style=flat-square" alt="Pub version"></a>
  <a href="https://pub.dev/packages/font_lens/score"><img src="https://img.shields.io/pub/points/font_lens?color=blue&style=flat-square" alt="Pub points"></a>
  <a href="https://pub.dev/packages/font_lens"><img src="https://img.shields.io/pub/likes/font_lens?style=flat-square" alt="Pub likes"></a>
  <a href="https://github.com/AhmedMonatah/Flutter_Lens/actions"><img src="https://github.com/AhmedMonatah/Flutter_Lens/actions/workflows/ci.yml/badge.svg?style=flat-square" alt="CI status"></a>
  <a href="https://github.com/AhmedMonatah/Flutter_Lens/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square" alt="License: MIT"></a>
</p>

<p align="center">
  <a href="#installation">Installation</a> &middot;
  <a href="#usage">Usage</a> &middot;
  <a href="#features">Features</a> &middot;
  <a href="#configuration">Configuration</a> &middot;
  <a href="#warning-rules">Warning rules</a> &middot;
  <a href="#limitations">Limitations</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/AhmedMonatah/Flutter_Lens/main/assets/images/hero.png" alt="Font Lens inspecting a Flutter screen" width="100%" />
</p>

---

## Overview

A Flutter theme describes which text styles are available. It does not tell you which styles are actually on screen. Hardcoded `TextStyle`s, third-party widgets, nested spans, and missing fallback fonts cause typography bugs that are easy to miss in code review.

Font Lens scans the live widget tree in debug mode, groups the text styles it finds, explains what `fontFamily == null` means on the current platform, highlights where each piece of text is drawn, and warns about common problems such as Arabic text without a fallback font.

|  | Shows | Reads the live screen | Checks Arabic fallback |
|:---|:---|:---:|:---:|
| `font_preview` | Fonts you list by hand | No | No |
| `theme_inspector` | What `ThemeData` defines | No | No |
| **Font Lens** | Styles rendered in the active widget tree | Yes | Yes |

## Features

- **Live widget-tree scanner.** Finds `Text`, `RichText`, `Text.rich` and `TextField` content on the current screen and skips offstage widgets.
- **Pick mode.** Tap any text on screen to see its font family, resolved size, weight, line height, color, and position in the widget tree.
- **Highlight overlay.** Draws bounding boxes around every detected text element, which helps spot clipped or overflowing text.
- **System default resolution.** Shows `fontFamily: null` as the platform default (for example Roboto on Android, SF Pro on iOS) instead of an empty value.
- **Design health warnings.** Flags Arabic text without a fallback font, too many font families or sizes on one screen, and possible faux-bold rendering.
- **Debug-only by default.** When `enabled` is `false`, `FontLens` returns its child unchanged.
- **English and Arabic interface**, including right-to-left layout.
- **Text redaction.** `redactText: true` replaces text content in the inspector with placeholder dots, so personal data is not shown during screen sharing or audits.
- **JSON export.** Copy the typography audit of the current screen to the clipboard for QA notes or bug reports.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  font_lens: ^0.1.0
```

Or from the command line:

```bash
flutter pub add font_lens
```

The package is a regular dependency because you wrap your app with it in `lib/`. Setting `enabled: kDebugMode` keeps the inspector out of release builds.

## Usage

Wrap your app in `MaterialApp.builder` (or `WidgetsApp.builder`):

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_lens/font_lens.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      builder: (context, child) => FontLens(
        enabled: kDebugMode,
        child: child!,
      ),
      home: const HomeScreen(),
    );
  }
}
```

Run the app in debug mode. A Font Lens button appears on screen. Tap it to open the inspector.

### The inspector panel

The panel has three heights: a collapsed bar with a summary (distinct fonts, sizes, and warnings), a half-height view, and a full view. Results are grouped by font family, size, or warning, and filter chips let you narrow the list to one family or to warnings only.

### Pick mode

1. Tap **Pick** in the panel header.
2. Tap any text on the screen.
3. A card shows the text snippet, font family, size, weight, letter spacing, line height, color with hex value and opacity, and the widget's place in the hierarchy.

### Highlight

Turn on **Highlight** to draw a box around every detected text element on the screen.

### Text drawn with `CustomPainter`

Text drawn by a `TextPainter` inside a `CustomPainter` is not part of the widget tree, so it cannot be detected automatically. To include it, wrap the painter with `FontLens.track`:

```dart
class BadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tp = FontLens.track(
      TextPainter(
        text: const TextSpan(
          text: 'PRO',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );

    tp.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## Configuration

```dart
FontLens(
  enabled: kDebugMode,
  themeMode: FontLensThemeMode.device,
  locale: const Locale('ar'),
  redactText: false,
  child: child!,
)
```

| Parameter | Type | Default | Description |
|:---|:---|:---|:---|
| `enabled` | `bool` | `kDebugMode` | Turns the inspector on. When `false`, the child is returned unchanged. |
| `themeMode` | `FontLensThemeMode` | `device` | Inspector brightness: `device`, `light`, or `dark`. |
| `locale` | `Locale?` | `null` | Interface language, `Locale('en')` or `Locale('ar')`. Follows the device when `null`. |
| `redactText` | `bool` | `false` | Replaces text content with placeholder dots in the inspector and exports. |
| `controller` | `FontLensController?` | `null` | Opens and closes the panel from code. |

## Warning rules

| Warning | Triggered when | Why it matters |
|:---|:---|:---|
| Arabic without fallback | Arabic text has no `fontFamilyFallback` | The system picks the font, so glyphs and letter shaping can differ between devices. |
| Too many font families | More than 3 distinct families on one screen | Inconsistent branding and visual clutter. |
| Too many font sizes | More than 8 distinct sizes on one screen | Weak typographic hierarchy. |
| Possible faux-bold | Weight 600 or higher, but only one weight of the family is available | The renderer may synthesize bold, which can look blurry. |

## Limitations

- Text drawn with `TextPainter` in a `CustomPainter` is only detected when you wrap it with `FontLens.track`.
- When a style has no font family, Font Lens reports the platform default. It cannot tell which font the operating system picks for characters the default font does not cover, such as Arabic.
- Text inside platform views (maps, web views) is not scanned.
- Lazy lists such as `ListView.builder` only include the items that are currently built.
- The faux-bold warning is a heuristic. Treat it as a hint to check your font assets.

## Development

```bash
dart analyze
flutter test
dart format --set-exit-if-changed .
```

## Contributing

Bug reports and feature requests are welcome on the [issue tracker](https://github.com/AhmedMonatah/Flutter_Lens/issues). For larger changes, please open an issue first to discuss the approach.

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.
