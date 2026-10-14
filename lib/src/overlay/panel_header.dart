import 'package:flutter/material.dart';

import 'font_lens_controller.dart';
import 'strings.dart';
import 'tokens.dart';

/// Top header of the inspector panel across all snap states.
///
/// Designed to be fully responsive across screen widths (from 320dp phones
/// to foldables, tablets, and desktop), adapting its padding, typography,
/// and buttons dynamically.
class PanelHeader extends StatelessWidget {
  const PanelHeader({
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
    final fonts = controller.distinctFontsCount;
    final sizes = controller.distinctSizesCount;
    final warnings = controller.totalWarningsCount;
    final isCollapsed = controller.snap == PanelSnap.collapsed;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 360;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle - scales with compact screens
          Center(
            child: Container(
              width: isCompact ? 28 : 36,
              height: 4,
              margin: const EdgeInsets.only(top: 6, bottom: 4),
              decoration: BoxDecoration(
                color: tokens.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header content row
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              isCompact ? 10 : 14,
              0,
              isCompact ? 8 : 10,
              4,
            ),
            child: Row(
              children: [
                // Scalable vector logo
                FontLensLogo(size: isCompact ? 22 : 24),
                SizedBox(width: isCompact ? 6 : 8),

                // Typography summary
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text:
                          '${strings.fontsCount(fonts)} · ${strings.sizesCount(sizes)}',
                      style: TextStyle(
                        fontSize: isCompact ? 11 : 12,
                        fontWeight: FontWeight.w600,
                        color: tokens.ink,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      children: [
                        if (warnings > 0)
                          TextSpan(
                            text: strings.isArabic
                                ? ' · $warnings ⚠'
                                : ' · ⚠ $warnings',
                            style: TextStyle(
                              fontSize: isCompact ? 11 : 12,
                              fontWeight: FontWeight.w700,
                              color: tokens.warn,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 4),

                // Responsive Pick button
                Semantics(
                  button: true,
                  label: strings.pickMode,
                  child: InkWell(
                    onTap: controller.startPick,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 7 : 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.accent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.accent.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app_outlined,
                            size: 13,
                            color: Colors.white,
                          ),
                          if (!isCompact || screenWidth > 300) ...[
                            const SizedBox(width: 4),
                            Text(
                              strings.pick,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                if (isCollapsed) ...[
                  // Expand button
                  Semantics(
                    button: true,
                    label: strings.show,
                    child: InkWell(
                      onTap: () {
                        controller.stopPick();
                        controller.setSnap(PanelSnap.half);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 20,
                          color: tokens.inkMuted,
                        ),
                      ),
                    ),
                  ),

                  // Close button
                  Semantics(
                    button: true,
                    label: strings.hide,
                    child: InkWell(
                      onTap: controller.hide,
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: tokens.inkMuted,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Settings toggle button (opens in-panel settings, zero external dependencies)
                  Semantics(
                    button: true,
                    label: strings.settings,
                    child: InkWell(
                      onTap: controller.toggleSettings,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: controller.isSettingsOpen
                              ? tokens.accent.withValues(alpha: 0.12)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          controller.isSettingsOpen
                              ? Icons.tune_rounded
                              : Icons.settings_outlined,
                          size: 18,
                          color: controller.isSettingsOpen
                              ? tokens.accent
                              : tokens.inkMuted,
                        ),
                      ),
                    ),
                  ),

                  // Close button
                  Semantics(
                    button: true,
                    label: strings.hide,
                    child: InkWell(
                      onTap: controller.hide,
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: tokens.inkMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Scalable, responsive vector icon for font_lens.
class FontLensLogo extends StatelessWidget {
  const FontLensLogo({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD6006B),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD6006B).withValues(alpha: 0.35),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'F',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.55,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          height: 1.0,
        ),
      ),
    );
  }
}
