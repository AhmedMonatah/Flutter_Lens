import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'font_lens_controller.dart';
import 'highlight_layer.dart';
import 'launcher_button.dart';
import 'panel_sheet.dart';
import 'pick_layer.dart';
import 'strings.dart';
import 'tokens.dart';

/// In-app typography inspector overlay for Flutter applications.
///
/// Wraps your application and displays an interactive, non-modal typography
/// inspector panel in debug mode.
class FontLens extends StatefulWidget {
  const FontLens({
    super.key,
    this.enabled = kDebugMode,
    this.themeMode = FontLensThemeMode.device,
    this.locale,
    this.controller,
    this.redactText = false,
    this.routeLabel,
    required this.child,
  });

  /// Whether the inspector is enabled. When `false`, returns [child] unchanged
  /// with zero performance or widget tree overhead.
  final bool enabled;

  /// Theme mode of the inspector panel. Defaults to [FontLensThemeMode.device].
  final FontLensThemeMode themeMode;

  /// Locale override for the inspector panel. When `null`, follows device locale.
  final Locale? locale;

  /// Optional external controller to programmatically drive the inspector.
  final FontLensController? controller;

  /// Whether to redact real text content into placeholders in reports and snapshots.
  final bool redactText;

  /// Optional custom route label resolver for unnamed or complex routes.
  final String? Function(Route<dynamic> route)? routeLabel;

  /// The host application widget subtree.
  final Widget child;

  // ---------------------------------------------------------------------------
  // Static tracking & configuration API
  // ---------------------------------------------------------------------------

  /// Whether text redaction is globally enabled in the active FontLens widget.
  static bool redactTextEnabled = false;

  /// Active custom route label resolver.
  static String? Function(Route<dynamic> route)? activeRouteLabel;

  static final List<TextPainter> _tracked = [];

  /// Global key pointing to the host app subtree, excluding the inspector.
  static GlobalKey? activeAppKey;

  /// Returns the tracked [TextPainter]s. Debug only.
  static List<TextPainter> get trackedPainters {
    List<TextPainter> result = const [];
    assert(() {
      result = List.unmodifiable(_tracked);
      return true;
    }());
    return result;
  }

  /// Registers [painter] for inclusion in font_lens reports and returns it.
  static TextPainter track(TextPainter painter) {
    assert(() {
      _tracked.add(painter);
      return true;
    }());
    return painter;
  }

  /// Clears the tracked painter list.
  static void clearTracked() {
    assert(() {
      _tracked.clear();
      return true;
    }());
  }

  @override
  State<FontLens> createState() => _FontLensState();
}

class _FontLensState extends State<FontLens> with WidgetsBindingObserver {
  late FontLensController _controller;
  bool _internalController = false;
  final GlobalKey _appKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) return;

    WidgetsBinding.instance.addObserver(this);
    FontLens.activeAppKey = _appKey;
    FontLens.redactTextEnabled = widget.redactText;
    FontLens.activeRouteLabel = widget.routeLabel;
    FontLensController.activeRootElementProvider =
        () => _appKey.currentContext as Element?;

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = FontLensController(
        themeMode: widget.themeMode,
        locale: widget.locale,
      );
      _internalController = true;
    }

    _controller.addListener(_onControllerChange);

    // Initial deferred scan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enabled) {
        _controller.scan(rootElement: _appKey.currentContext as Element?);
      }
    });
  }

  @override
  void didUpdateWidget(covariant FontLens oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) return;

    FontLens.redactTextEnabled = widget.redactText;
    FontLens.activeRouteLabel = widget.routeLabel;

    if (widget.controller != oldWidget.controller && widget.controller != null) {
      if (_internalController) {
        _controller.removeListener(_onControllerChange);
        _controller.dispose();
        _internalController = false;
      }
      _controller = widget.controller!;
      _controller.addListener(_onControllerChange);
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted && widget.enabled) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (widget.enabled) {
      WidgetsBinding.instance.removeObserver(this);
      _controller.removeListener(_onControllerChange);
      if (_internalController) {
        _controller.dispose();
      }
      if (FontLens.activeAppKey == _appKey) {
        FontLens.activeAppKey = null;
      }
      FontLens.redactTextEnabled = false;
      FontLens.activeRouteLabel = null;
      FontLensController.activeRootElementProvider = null;
    }
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final appBrightness = Theme.of(context).brightness;
    final brightness = _controller.resolveBrightness(context, appBrightness);
    final tokens = FontLensTokens.of(brightness);
    final lang = _controller.resolveLanguageCode();
    final dir = (lang == 'ar') ? TextDirection.rtl : TextDirection.ltr;
    final strings = FontLensStrings.of(lang);

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        // Host app subtree wrapped in KeyedSubtree to isolate scans
        KeyedSubtree(
          key: _appKey,
          child: widget.child,
        ),

        // Inspector UI isolated with its own Directionality and Theme
        Positioned.fill(
          child: Directionality(
            textDirection: dir,
            child: Theme(
              data: ThemeData(
                brightness: brightness,
                useMaterial3: true,
                scaffoldBackgroundColor: tokens.surface,
                fontFamilyFallback: const ['Roboto', 'Segoe UI', 'Cairo', 'Arial'],
              ),
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  // On-screen highlight layer (IgnorePointer)
                  HighlightLayer(
                    selectedTexts: _controller.selectedTexts,
                    tokens: tokens,
                  ),

                  // Pick layer (tap capture + top banner)
                  PickLayer(
                    controller: _controller,
                    tokens: tokens,
                    strings: strings,
                  ),

                  // Panel sheet or floating launcher button
                  if (_controller.isVisible)
                    PanelSheet(
                      controller: _controller,
                      tokens: tokens,
                      strings: strings,
                    )
                  else if (!_controller.isPickMode)
                    LauncherButton(
                      controller: _controller,
                      tokens: tokens,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
