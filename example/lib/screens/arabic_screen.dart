import 'package:flutter/material.dart';

/// Screen with Arabic text that has no font fallback configured.
/// This deliberately triggers the font_lens Arabic warning.
class ArabicScreen extends StatelessWidget {
  const ArabicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arabic Text Screen')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // No fontFamily → triggers Arabic warning in font_lens.
            const Text(
              'مرحبا بالعالم',
              style: TextStyle(fontSize: 28),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            const Text(
              '(Arabic — no fontFamilyFallback set; font_lens will warn)',
              style: TextStyle(fontSize: 11, color: Colors.white38),
            ),
            const Divider(height: 40),
            // With explicit Arabic fallback — no warning.
            const Text(
              'مرحبا بالعالم — مع Cairo',
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Roboto',
                fontFamilyFallback: ['Cairo'],
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            const Text(
              '(Arabic — Cairo in fontFamilyFallback; no warning)',
              style: TextStyle(fontSize: 11, color: Colors.white38),
            ),
            const Divider(height: 40),
            // Mixed Arabic+English.
            const Text('Hello مرحبا World', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
