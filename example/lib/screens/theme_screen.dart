import 'package:flutter/material.dart';

/// Screen using only the MaterialApp theme font — no explicit fontFamily.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Font Screen')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display Large', style: theme.displayLarge),
            const SizedBox(height: 12),
            Text('Headline Medium', style: theme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Body Medium — the default body text style.',
              style: theme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text('Label Small', style: theme.labelSmall),
          ],
        ),
      ),
    );
  }
}
