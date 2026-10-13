import 'package:flutter/material.dart';
import 'package:font_lens/font_lens.dart';

/// Screen demonstrating [FontLens.track] for [TextPainter] inside a
/// [CustomPainter] — text that is otherwise invisible to the tree scanner.
class PainterScreen extends StatelessWidget {
  const PainterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Track Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 300,
              height: 200,
              child: CustomPaint(painter: _TrackedTextPainter()),
            ),
            const SizedBox(height: 16),
            const Text(
              'The text above is drawn with TextPainter.\n'
              'font_lens.track() registers it so it appears in reports.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackedTextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tp = FontLens.track(
      TextPainter(
        text: const TextSpan(
          text: 'Painted with TextPainter',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6C3FF5),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width),
    );
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, size.height / 2 - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
