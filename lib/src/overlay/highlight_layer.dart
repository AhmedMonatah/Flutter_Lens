import 'package:flutter/material.dart';

import '../models/scan_result.dart';
import 'found_text_rect_ext.dart';
import 'tokens.dart';

/// Renders double-stroke highlight rectangles around inspected texts on screen.
class HighlightLayer extends StatelessWidget {
  const HighlightLayer({
    super.key,
    required this.selectedTexts,
    required this.tokens,
  });

  final List<ResolvedText> selectedTexts;
  final FontLensTokens tokens;

  @override
  Widget build(BuildContext context) {
    if (selectedTexts.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _HighlightPainter(
          texts: selectedTexts,
          tokens: tokens,
        ),
      ),
    );
  }
}

class _HighlightPainter extends CustomPainter {
  _HighlightPainter({
    required this.texts,
    required this.tokens,
  });

  final List<ResolvedText> texts;
  final FontLensTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final outerPaint = Paint()
      ..color = tokens.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bgTintPaint = Paint()
      ..color = tokens.accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < texts.length; i++) {
      final t = texts[i];
      final r = t.source.rect;
      if (r.isEmpty) continue;

      final rounded = RRect.fromRectAndRadius(r, const Radius.circular(4));

      // Tinted interior
      canvas.drawRRect(rounded, bgTintPaint);

      // 2px outer accent outline
      canvas.drawRRect(rounded, outerPaint);

      // 1px inner contrasting stroke
      final inner = RRect.fromRectAndRadius(
        r.deflate(1.0),
        const Radius.circular(3),
      );
      canvas.drawRRect(inner, innerPaint);

      // Draw label chip above the first text item
      if (i == 0) {
        final label =
            '${t.displayFamily} ${t.source.fontSize?.toStringAsFixed(0) ?? ''} · w${t.source.fontWeight ?? 400}';
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final chipRect = Rect.fromLTWH(
          r.left.clamp(4.0, size.width - textPainter.width - 12.0),
          (r.top - 18.0).clamp(4.0, size.height - 20.0),
          textPainter.width + 8.0,
          16.0,
        );

        final chipPaint = Paint()..color = tokens.accent;
        canvas.drawRRect(
          RRect.fromRectAndRadius(chipRect, const Radius.circular(4)),
          chipPaint,
        );
        textPainter.paint(
          canvas,
          Offset(chipRect.left + 4.0, chipRect.top + 1.0),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HighlightPainter oldDelegate) =>
      oldDelegate.texts != texts || oldDelegate.tokens != tokens;
}
