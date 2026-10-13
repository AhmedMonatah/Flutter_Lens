/// font_lens — debug-only Flutter typography inspector.
///
/// Add to your [MaterialApp]:
/// ```dart
/// import 'package:font_lens/font_lens.dart';
///
/// MaterialApp(
///   builder: (context, child) => FontLens(
///     enabled: kDebugMode,
///     child: child!,
///   ),
/// )
/// ```
library;

export 'src/models/found_text.dart';
export 'src/models/scan_result.dart';
export 'src/models/style_stat.dart' show StyleStat;
export 'src/overlay/detail_card.dart' show DetailCard;
export 'src/overlay/filter_chips.dart' show FilterChips;
export 'src/overlay/font_lens.dart' show FontLens;
export 'src/overlay/font_lens_controller.dart'
    show FontLensController, FontLensThemeMode, PanelSnap, StyleGroup;
export 'src/overlay/font_lens_screen.dart' show FontLensScreen;
export 'src/overlay/font_lens_widget.dart' show FontLensWidget;
export 'src/overlay/group_row.dart' show GroupRow;
export 'src/overlay/highlight_layer.dart' show HighlightLayer;
export 'src/overlay/launcher_button.dart' show LauncherButton;
export 'src/overlay/panel_header.dart' show PanelHeader;
export 'src/overlay/panel_sheet.dart' show PanelSheet;
export 'src/overlay/pick_layer.dart' show PickLayer;
export 'src/overlay/strings.dart' show FontLensStrings;
export 'src/overlay/tokens.dart' show FontLensTokens;
export 'src/overlay/warning_strip.dart' show WarningStrip;
export 'src/resolver/resolver.dart'
    show resolveAll, resolveOne, resolveFontFile, displayFamily, containsArabic;
export 'src/scanner/scanner.dart' show scanScreen;

import 'package:flutter/widgets.dart';

/// Kept for backward compatibility.
///
/// Multi-screen report snapshot tracking is no longer used. You can safely
/// remove [FontLensObserver] from your `navigatorObservers`.
@Deprecated(
  'FontLensObserver is no longer needed after removing HTML reports and can be safely removed from navigatorObservers.',
)
class FontLensObserver extends NavigatorObserver {}
