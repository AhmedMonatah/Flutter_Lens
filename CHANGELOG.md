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
