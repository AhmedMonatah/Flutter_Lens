import 'package:flutter/widgets.dart';

/// Labels a specific subtree (such as a Tab or PageView item) for FontLens screen snapshots.
///
/// Use when multiple logical screens share a single route:
/// ```dart
/// TabBarView(
///   children: [
///     FontLensScreen(
///       name: 'Home / Featured',
///       child: FeaturedTab(),
///     ),
///     FontLensScreen(
///       name: 'Home / Settings',
///       child: SettingsTab(),
///     ),
///   ],
/// )
/// ```
class FontLensScreen extends InheritedWidget {
  const FontLensScreen({super.key, required this.name, required super.child});

  /// The human-readable screen name assigned to this subtree.
  final String name;

  /// Retrieves the closest [FontLensScreen] name in the widget tree, if any.
  static String? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FontLensScreen>()?.name;
  }

  @override
  bool updateShouldNotify(FontLensScreen oldWidget) => name != oldWidget.name;
}
