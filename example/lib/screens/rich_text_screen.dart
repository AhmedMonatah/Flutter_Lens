import 'package:flutter/material.dart';

/// Screen with nested [TextSpan]s at multiple weights and colours.
class RichTextScreen extends StatelessWidget {
  const RichTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nested TextSpan Screen')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: 'This sentence has ',
                style: const TextStyle(fontSize: 18, color: Colors.white),
                children: [
                  const TextSpan(
                    text: 'bold',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'italic',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.purple.shade200,
                    ),
                  ),
                  const TextSpan(text: ', and '),
                  const TextSpan(text: 'large', style: TextStyle(fontSize: 28)),
                  const TextSpan(text: ' spans.'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'A second paragraph with an explicit fontFamily.',
              style: TextStyle(fontFamily: 'serif', fontSize: 16),
            ),
            const SizedBox(height: 32),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.white70),
                children: [
                  TextSpan(text: 'RichText at root · '),
                  TextSpan(
                    text: 'child with weight 600',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' · another child'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
