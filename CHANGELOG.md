## 0.1.2

* Added Author profile and professional links (GitHub, LinkedIn) to documentation.

## 0.1.1


* Added full WebAssembly (WASM) runtime compatibility by removing `dart:io` platform shims in favor of Flutter foundation shims.
* Updated image URLs to absolute raw GitHub URLs for reliable display on pub.dev.
* Optimized package description length for search engine indexing and full Pana score (160/160).
* Formatted all Dart source files to ensure CI passes cleanly.

## 0.1.0


* Initial public release.
* Phase 1: `FoundText`, `ScanResult`, `ResolvedText` models.
* Phase 2: Element-tree scanner covering `Text`, `RichText`, `Text.rich`,
  `TextField`, and `Offstage` exclusion.
* Phase 3: Resolver with system-default explanation, package-prefix stripping,
  google_fonts name cleanup, Arabic-without-fallback warning, too-many-fonts,
  too-many-sizes, and faux-bold detection.
* Phase 4: `FontLensWidget` draggable overlay panel with highlight rects,
  family/warning filters, and JSON copy.
* Phase 5: `ext.fontlens.scan` and `ext.fontlens.history` VM service
  extensions; `FontLensObserver` navigator observer.
* Phase 6: `dart run font_lens report` CLI that connects to a running app,
  fetches history, and writes a self-contained HTML + JSON report.
* `FontLens.track(painter)` opt-in for `CustomPainter` TextPainters.
