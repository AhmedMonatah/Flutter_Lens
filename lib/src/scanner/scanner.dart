import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../models/found_text.dart';

/// Walks the current widget / render tree and collects every visible piece of
/// text with its resolved [TextStyle].
///
/// This is an **on-demand** operation.  Never call it from `build` or on every
/// frame; it is designed to be called from a button handler or a service-
/// extension callback.
///
/// Returns an empty list when called in release mode.
List<FoundText> scanScreen({Element? rootElement}) {
  if (!kDebugMode) return const [];

  final out = <FoundText>[];
  final root = rootElement ?? WidgetsBinding.instance.rootElement;
  if (root == null) return out;

  // Recursively collect spans from an InlineSpan tree.
  void collect(InlineSpan span, TextStyle? parent, Element el, RenderBox box) {
    if (span is TextSpan) {
      final style = (parent != null)
          ? parent.merge(span.style)
          : (span.style ?? const TextStyle());
      final t = span.text;
      if (t != null && t.trim().isNotEmpty) {
        out.add(_toFound(t, style, el, box));
      }
      for (final child in span.children ?? const <InlineSpan>[]) {
        collect(child, style, el, box);
      }
    }
    // WidgetSpan children are visited by the element-tree walk below.
  }

  // Walk every element in the tree.
  void walk(Element el) {
    if (el is RenderObjectElement) {
      final ro = el.renderObject;
      if (ro is RenderParagraph && _isVisible(ro)) {
        collect(ro.text, null, el, ro);
      } else if (ro is RenderEditable && _isVisible(ro)) {
        final text = ro.text;
        if (text != null) {
          collect(text, null, el, ro);
        }
      }
    }
    el.visitChildren(walk);
  }

  walk(root);
  return out;
}

/// Returns `true` when [ro] is attached, has a non-empty layout box, and does
/// not have an [RenderOffstage] (offstage=true) ancestor.
bool _isVisible(RenderBox ro) {
  if (!ro.attached) return false;
  if (!ro.hasSize) return false;
  if (ro.size.isEmpty) return false;

  RenderObject? parent = ro.parent;
  while (parent != null) {
    if (parent is RenderOffstage && parent.offstage) return false;
    parent = parent.parent;
  }
  return true;
}

/// Converts raw data into a [FoundText] value object.
FoundText _toFound(String text, TextStyle? style, Element el, RenderBox box) {
  // Global bounding rect as [left, top, width, height] for highlight overlays.
  late final List<double> rectLTWH;
  try {
    final offset = box.localToGlobal(Offset.zero);
    final sz = box.size;
    rectLTWH = [offset.dx, offset.dy, sz.width, sz.height];
  } catch (_) {
    rectLTWH = const [0, 0, 0, 0];
  }

  // Route is omitted during element scanning to avoid registering invalid
  // InheritedWidget dependencies outside the widget build phase.
  const String? route = null;

  final fw = style?.fontWeight;
  return FoundText(
    text: text,
    fontFamily: style?.fontFamily,
    fontFamilyFallback: style?.fontFamilyFallback ?? const [],
    fontSize: style?.fontSize,
    fontWeight: fw?.value,
    italic: style?.fontStyle == FontStyle.italic,
    color: style?.color?.toARGB32(),
    height: style?.height,
    rectLTWH: rectLTWH,
    route: route,
    element: el,
  );
}
