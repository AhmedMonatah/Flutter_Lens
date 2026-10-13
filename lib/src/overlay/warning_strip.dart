import 'package:flutter/material.dart';

import 'font_lens_controller.dart';
import 'strings.dart';
import 'tokens.dart';

/// Single-line collapsible warning bar that expands into the full list of warnings.
class WarningStrip extends StatelessWidget {
  const WarningStrip({
    super.key,
    required this.controller,
    required this.tokens,
    required this.strings,
  });

  final FontLensController controller;
  final FontLensTokens tokens;
  final FontLensStrings strings;

  @override
  Widget build(BuildContext context) {
    final result = controller.scanResult;
    if (result == null) return const SizedBox.shrink();

    // Collect all warnings
    final allWarnings = <String>[];
    allWarnings.addAll(result.screenWarnings);
    for (final t in result.texts) {
      allWarnings.addAll(t.warnings);
    }
    if (allWarnings.isEmpty) return const SizedBox.shrink();

    final isExpanded = controller.warningsExpanded;
    final firstWarning = allWarnings.first;
    final extraCount = allWarnings.length - 1;

    // Deduplicate warnings with counts for expanded view
    final grouped = <String, int>{};
    for (final w in allWarnings) {
      grouped[w] = (grouped[w] ?? 0) + 1;
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final hMargin = screenWidth < 360 ? 10.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hMargin, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.warn.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.warn.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Collapsed single-line row
          InkWell(
            onTap: controller.toggleWarnings,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: tokens.warn,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      extraCount > 0
                          ? '${strings.translateWarning(firstWarning)} (+$extraCount)'
                          : strings.translateWarning(firstWarning),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: tokens.warn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isExpanded ? strings.hide : strings.show,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tokens.warn,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: tokens.warn,
                  ),
                ],
              ),
            ),
          ),

          // Expanded warnings list
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: tokens.warn.withValues(alpha: 0.15)),
                ),
              ),
              padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: grouped.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: tokens.warn)),
                        Expanded(
                          child: Text(
                            strings.translateWarning(e.key),
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: tokens.ink,
                            ),
                          ),
                        ),
                        if (e.value > 1)
                          Container(
                            margin: const EdgeInsetsDirectional.only(start: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.warn.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '×${e.value}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: tokens.warn,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
