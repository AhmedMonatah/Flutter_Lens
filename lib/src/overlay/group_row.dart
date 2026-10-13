import 'package:flutter/material.dart';

import '../resolver/resolver.dart' show containsArabic;
import 'font_lens_controller.dart';
import 'strings.dart';
import 'tokens.dart';

/// Renders a single typography style group with live rendered text specimen.
///
/// Designed to be fluidly responsive across small phones to large displays,
/// supporting Arabic RTL layout, directional chevrons, and flexible metadata wrapping.
class GroupRow extends StatelessWidget {
  const GroupRow({
    super.key,
    required this.group,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
    required this.strings,
  });

  final StyleGroup group;
  final bool isSelected;
  final VoidCallback onTap;
  final FontLensTokens tokens;
  final FontLensStrings strings;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;
    final isRtlText = containsArabic(group.specimenText);
    final isRtlLayout = Directionality.of(context) == TextDirection.rtl;

    final clampedSize = (group.fontSize ?? 14.0).clamp(11.0, 20.0);
    final fw = group.fontWeight != null
        ? FontWeight.values.firstWhere(
            (w) => w.value == group.fontWeight,
            orElse: () => FontWeight.normal,
          )
        : FontWeight.normal;

    final specimenStyle = TextStyle(
      fontFamily: group.rawFamily,
      fontSize: clampedSize,
      fontWeight: fw,
      fontStyle: group.italic ? FontStyle.italic : FontStyle.normal,
      color: tokens.ink,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.accent.withValues(alpha: 0.08)
              : tokens.raised,
          border: Border(
            bottom: BorderSide(color: tokens.hairline, width: 0.8),
            left: (isSelected && !isRtlLayout)
                ? BorderSide(color: tokens.accent, width: 4)
                : BorderSide.none,
            right: (isSelected && isRtlLayout)
                ? BorderSide(color: tokens.accent, width: 4)
                : BorderSide.none,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left/leading content: Metadata + Specimen
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Line 1: Family · Size · Weight · Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          group.displayFamily,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: tokens.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '· ${group.fontSize?.toStringAsFixed(0) ?? '—'} · w${group.fontWeight ?? 400}${group.italic ? ' italic' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.inkMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: tokens.hairline, width: 0.8),
                        ),
                        child: Text(
                          '×${group.count}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: tokens.inkMuted,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      if (group.hasWarnings) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 13,
                          color: tokens.warn,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Line 2: Live specimen text
                  Text(
                    group.specimenText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection:
                        isRtlText ? TextDirection.rtl : TextDirection.ltr,
                    style: specimenStyle,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Trailing info & directional chevron
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCompact && screenWidth > 420) ...[
                  Text(
                    strings.usedInCount(group.count),
                    style: TextStyle(
                      fontSize: 11,
                      color: tokens.inkMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                // Expand/collapse arrow (up when seeing details, down when closed)
                Icon(
                  isSelected
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 19,
                  color: isSelected ? tokens.accent : tokens.inkMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
