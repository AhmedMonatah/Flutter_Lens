import 'package:flutter/material.dart';

import 'font_lens_controller.dart';
import 'panel_header.dart';
import 'tokens.dart';

/// Floating, draggable 40 dp launcher button with a warning badge.
class LauncherButton extends StatelessWidget {
  const LauncherButton({
    super.key,
    required this.controller,
    required this.tokens,
  });

  final FontLensController controller;
  final FontLensTokens tokens;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final size = MediaQuery.sizeOf(context);
    final warnings = controller.totalWarningsCount;

    // Constrain position within safe screen area
    final pos = controller.launcherPosition;
    final clampedX = pos.dx.clamp(
      viewPadding.left + 8.0,
      size.width - viewPadding.right - 48.0,
    );
    final clampedY = pos.dy.clamp(
      viewPadding.top + 8.0,
      size.height - viewPadding.bottom - 48.0,
    );

    return Positioned(
      left: clampedX,
      top: clampedY,
      child: GestureDetector(
        onPanUpdate: (details) {
          controller.setLauncherPosition(
            Offset(clampedX + details.delta.dx, clampedY + details.delta.dy),
          );
        },
        child: Semantics(
          button: true,
          label: 'Open font_lens inspector',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.show,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Main 40 dp circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tokens.raised,
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.hairline, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(7),
                      child: const FontLensLogo(size: 26),
                    ),

                    // Warning badge
                    if (warnings > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.warn,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: tokens.raised, width: 1.5),
                          ),
                          child: Text(
                            '$warnings',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
