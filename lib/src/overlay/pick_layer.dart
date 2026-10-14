import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/found_text.dart';
import '../models/scan_result.dart';
import 'detail_card.dart';
import 'font_lens.dart';
import 'font_lens_controller.dart';
import 'found_text_rect_ext.dart';
import 'strings.dart';
import 'tokens.dart';

/// Fullscreen tap capture and live scroll layer for Pick mode.
///
/// Supports:
/// 1. Tapping on any text (static, dynamic, or API-loaded) to inspect its typography.
/// 2. Dragging vertically to scroll the underlying app page without leaving Pick mode.
/// 3. Direct hit-testing and live re-scanning ensuring 100% of on-screen texts are detected.
class PickLayer extends StatefulWidget {
  const PickLayer({
    super.key,
    required this.controller,
    required this.tokens,
    required this.strings,
  });

  final FontLensController controller;
  final FontLensTokens tokens;
  final FontLensStrings strings;

  @override
  State<PickLayer> createState() => _PickLayerState();
}

class _PickLayerState extends State<PickLayer> {
  String? _hintText;
  ScrollPosition? _activeScrollPos;

  // ---------------------------------------------------------------------------
  // Scrolling support in Pick mode
  // ---------------------------------------------------------------------------

  void _handleDragStart(DragStartDetails details) {
    _activeScrollPos =
        _findScrollPosition(details.globalPosition, Axis.vertical) ??
        _findFallbackScrollPosition();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_activeScrollPos != null) {
      final pos = _activeScrollPos!;
      if (pos.hasPixels && pos.hasContentDimensions) {
        final delta = -details.primaryDelta!;
        final newPixels = (pos.pixels + delta).clamp(
          pos.minScrollExtent,
          pos.maxScrollExtent,
        );
        pos.jumpTo(newPixels);
      }
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _activeScrollPos = null;
    // Re-scan current view to refresh on-screen coordinates after scrolling
    widget.controller.scan(
      rootElement: FontLens.activeAppKey?.currentContext as Element?,
    );
  }

  ScrollPosition? _findScrollPosition(Offset globalPos, Axis axis) {
    final appBox =
        FontLens.activeAppKey?.currentContext?.findRenderObject() as RenderBox?;
    if (appBox != null && appBox.hasSize) {
      final hitResult = BoxHitTestResult();
      final localPos = appBox.globalToLocal(globalPos);
      if (appBox.hitTest(hitResult, position: localPos)) {
        for (final entry in hitResult.path) {
          final target = entry.target;
          if (target is RenderViewportBase && target.axis == axis) {
            if (target.offset is ScrollPosition) {
              return target.offset as ScrollPosition;
            }
          }
          try {
            final dynamic dyn = target;
            final dynamic off = dyn.offset;
            if (off is ScrollPosition) {
              return off;
            }
          } catch (_) {}
        }
      }
    }
    return null;
  }

  ScrollPosition? _findFallbackScrollPosition() {
    ScrollPosition? fallback;
    void search(Element el) {
      if (fallback != null) return;
      if (el is StatefulElement && el.state is ScrollableState) {
        final state = el.state as ScrollableState;
        if (axisDirectionToAxis(state.axisDirection) == Axis.vertical &&
            state.position.hasPixels) {
          fallback = state.position;
          return;
        }
      }
      el.visitChildren(search);
    }

    final root = FontLens.activeAppKey?.currentContext as Element?;
    if (root != null) search(root);
    return fallback;
  }

  // ---------------------------------------------------------------------------
  // Tap-to-inspect matching (Live scan + RenderParagraph Hit-testing)
  // ---------------------------------------------------------------------------

  void _handleTap(TapUpDetails details) {
    final pos = details.globalPosition;

    // 1. Live scan of the current screen (captures newly arrived API data and scrolled texts)
    widget.controller.scan(
      rootElement: FontLens.activeAppKey?.currentContext as Element?,
    );

    final texts = widget.controller.scanResult?.texts ?? <ResolvedText>[];
    FoundText? bestMatch;

    // 2. Direct RenderParagraph hit-test on the host app render tree
    final appBox =
        FontLens.activeAppKey?.currentContext?.findRenderObject() as RenderBox?;
    RenderParagraph? hitParagraph;

    if (appBox != null && appBox.hasSize) {
      final hitResult = BoxHitTestResult();
      final localPos = appBox.globalToLocal(pos);
      if (appBox.hitTest(hitResult, position: localPos)) {
        for (final entry in hitResult.path) {
          if (entry.target is RenderParagraph) {
            hitParagraph = entry.target as RenderParagraph;
            break;
          }
        }
      }
    }

    if (hitParagraph != null) {
      final plainText = hitParagraph.text.toPlainText().trim();
      final pOffset = hitParagraph.localToGlobal(Offset.zero);
      final pRect = pOffset & hitParagraph.size;

      // Find in scanned texts matching the hit paragraph
      for (final t in texts) {
        if (t.source.text.trim() == plainText &&
            (t.source.rect.overlaps(pRect) ||
                t.source.rect.inflate(8.0).contains(pos))) {
          bestMatch = t.source;
          break;
        }
      }

      if (bestMatch == null) {
        for (final t in texts) {
          if (t.source.rect.overlaps(pRect)) {
            bestMatch = t.source;
            break;
          }
        }
      }
    }

    // 3. Geometric rect matching fallback (smallest area wins)
    if (bestMatch == null) {
      double minArea = double.infinity;
      for (final t in texts) {
        final r = t.source.rect;
        if (r.contains(pos)) {
          final area = r.width * r.height;
          if (area < minArea) {
            minArea = area;
            bestMatch = t.source;
          }
        }
      }
    }

    // 4. Touch tolerance matching (16dp inflate)
    if (bestMatch == null) {
      double minArea = double.infinity;
      for (final t in texts) {
        final r = t.source.rect.inflate(16.0);
        if (r.contains(pos)) {
          final area = r.width * r.height;
          if (area < minArea) {
            minArea = area;
            bestMatch = t.source;
          }
        }
      }
    }

    // 5. Direct synthesis from hitParagraph if not present in scan result
    if (bestMatch == null && hitParagraph != null) {
      final pOffset = hitParagraph.localToGlobal(Offset.zero);
      final pRect = pOffset & hitParagraph.size;
      final span = hitParagraph.text;
      final style = span.style;
      bestMatch = FoundText(
        text: span.toPlainText(),
        fontFamily: style?.fontFamily,
        fontFamilyFallback: style?.fontFamilyFallback ?? const [],
        fontSize: style?.fontSize,
        fontWeight: style?.fontWeight?.value,
        italic: style?.fontStyle == FontStyle.italic,
        color: style?.color?.toARGB32(),
        height: style?.height,
        rectLTWH: [pRect.left, pRect.top, pRect.width, pRect.height],
        route: null,
      );
    }

    if (bestMatch != null) {
      setState(() => _hintText = null);
      widget.controller.setPickedText(bestMatch);
    } else {
      setState(() => _hintText = widget.strings.noTextHere);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _hintText = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isPickMode) return const SizedBox.shrink();

    final viewPadding = MediaQuery.viewPaddingOf(context);

    return Stack(
      children: [
        // Fullscreen touch and vertical scroll capture
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: _handleTap,
            onVerticalDragStart: _handleDragStart,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),

        // Top banner: [Pick mode] Tap any text on screen [✕]
        Positioned(
          top: viewPadding.top + 8,
          left: 16,
          right: 16,
          child: Material(
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            color: widget.tokens.raised,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: widget.tokens.hairline),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.tokens.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.strings.pickMode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _hintText ?? widget.strings.tapAnyText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _hintText != null
                            ? widget.tokens.warn
                            : widget.tokens.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: widget.tokens.inkMuted,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: widget.controller.stopPick,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Anchored detail card
        if (widget.controller.pickedText != null)
          DetailCard(
            text: widget.controller.pickedText!,
            controller: widget.controller,
            tokens: widget.tokens,
            strings: widget.strings,
            onClose: () => widget.controller.setPickedText(null),
          ),
      ],
    );
  }
}
