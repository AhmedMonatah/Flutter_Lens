import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_lens/font_lens.dart';

import 'screens/theme_screen.dart';
import 'screens/rich_text_screen.dart';
import 'screens/arabic_screen.dart';
import 'screens/painter_screen.dart';

void main() {
  runApp(const FontLensExampleApp());
}

class FontLensExampleApp extends StatelessWidget {
  const FontLensExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'font_lens Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C3FF5),
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Roboto', fontSize: 57),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14),
        ),
      ),
      builder: (context, child) =>
          FontLensWidget(enabled: kDebugMode, child: child!),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const HomeScreen(),
        '/theme': (ctx) => const ThemeScreen(),
        '/rich': (ctx) => const RichTextScreen(),
        '/arabic': (ctx) => const ArabicScreen(),
        '/painter': (ctx) => const PainterScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('font_lens Demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'font_lens',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Flutter typography inspector',
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 40),
            _NavButton(label: '1. Theme font screen', route: '/theme'),
            _NavButton(label: '2. Nested TextSpan screen', route: '/rich'),
            _NavButton(label: '3. Arabic text screen', route: '/arabic'),
            _NavButton(
              label: '4. CustomPainter track screen',
              route: '/painter',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.route});
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(label),
      ),
    );
  }
}
