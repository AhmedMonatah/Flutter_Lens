# font_lens Example App

A complete demonstration app showcasing **font_lens** in action across different scenarios.

## Features demonstrated

- **Theme Screen:** Standard Material 3 typography with theme-defined fonts and styles.
- **Arabic Screen:** Arabic RTL typography testing missing fallback detection and Cairo font rendering.
- **RichText Screen:** Mixed inline spans, multiple font weights, colors, and sizes within a single widget.
- **CustomPainter Screen:** Demonstration of `FontLens.track(painter)` for inspecting canvas-rendered text.

## Running the example

```bash
cd example
flutter run
```

Tap the floating **Font Lens** button in the bottom-right corner to open the inspector, try **Pick Mode**, and toggle **Highlight Overlays**.
