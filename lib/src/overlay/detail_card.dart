import 'package:flutter/material.dart';

import '../models/found_text.dart';
import '../resolver/resolver.dart' show containsArabic;
import 'font_lens_controller.dart';
import 'found_text_rect_ext.dart';
import 'strings.dart';
import 'tokens.dart';

/// Detail inspection card for a single tapped text item in Pick mode.
///
/// Responsive anchored card that automatically stays within screen bounds,
/// wraps typography attributes dynamically, and never overflows.
class DetailCard extends StatelessWidget {
  const DetailCard({
    super.key,
    required this.text,
    required this.controller,
    required this.tokens,
    required this.strings,
    required this.onClose,
  });

  final FoundText text;
  final FontLensController controller;
  final FontLensTokens tokens;
  final FontLensStrings strings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final rect = text.rect;

    final isRtl = containsArabic(text.text);
    final resolvedGroup = controller.groups
        .where((g) => g.rawFamily == text.fontFamily)
        .firstOrNull;
    final count = resolvedGroup?.count ?? 1;

    // Color hex string
    final colorVal = text.color;
    final hexString = colorVal != null
        ? '#${(colorVal & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}'
        : null;

    // Fluid responsive card dimensions adapted to screen size
    final cardWidth = (screenSize.width - 24.0).clamp(240.0, 400.0);
    final approxCardHeight = (screenSize.height * 0.35).clamp(180.0, 320.0);

    double topPos = rect.bottom + 8.0;
    if (topPos + approxCardHeight >
        screenSize.height - viewPadding.bottom - 16.0) {
      topPos = (rect.top - approxCardHeight - 8.0)
          .clamp(viewPadding.top + 8.0, screenSize.height - approxCardHeight);
    }

    final leftPos = rect.left.clamp(
      viewPadding.left + 8.0,
      (screenSize.width - cardWidth - viewPadding.right - 8.0)
          .clamp(viewPadding.left + 8.0, double.infinity),
    );

    return Positioned(
      left: leftPos,
      top: topPos,
      width: cardWidth,
      child: Material(
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        color: tokens.raised,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.hairline, width: 1.2),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 16,
                        color: tokens.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        strings.selectedText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tokens.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: tokens.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Large specimen
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  text.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: text.fontFamily,
                    fontSize: (text.fontSize ?? 14.0).clamp(13.0, 22.0),
                    fontWeight: text.fontWeight != null
                        ? FontWeight.values.firstWhere(
                            (w) => w.value == text.fontWeight,
                            orElse: () => FontWeight.normal,
                          )
                        : FontWeight.normal,
                    color: tokens.ink,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Typography metadata row - with Expanded to avoid horizontal overflow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${text.fontFamily ?? 'System'} · ${text.fontSize?.toStringAsFixed(0) ?? '—'}sp · w${text.fontWeight ?? 400}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tokens.ink,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '×$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tokens.accent,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Swatch + attributes in responsive Wrap
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (colorVal != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(colorVal),
                            shape: BoxShape.circle,
                            border: Border.all(color: tokens.hairline),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          hexString ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: tokens.inkMuted,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (text.height != null)
                    Text(
                      'Line height: ${text.height!.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: tokens.inkMuted,
                      ),
                    ),
                ],
              ),

              if (text.fontFamilyFallback.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Fallback: ${text.fontFamilyFallback.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: tokens.inkMuted),
                ),
              ],

              const SizedBox(height: 12),

              // Action button: Show in list
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: Text(strings.showInList),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.accent,
                    side: BorderSide(color: tokens.accent),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final key = StyleGroup.makeKey(
                      displayFamily: text.fontFamily ?? 'System',
                      fontSize: text.fontSize,
                      fontWeight: text.fontWeight,
                      italic: text.italic,
                    );
                    controller.selectGroup(key);
                    controller.stopPick();
                    controller.setSnap(PanelSnap.half);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
