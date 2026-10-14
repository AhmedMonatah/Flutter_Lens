import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_lens/src/overlay/font_lens_widget.dart';
import 'package:font_lens/src/scanner/scanner.dart';

void main() {
  group('scanScreen()', () {
    testWidgets('finds a plain Text widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Hello scanner'))),
      );
      await tester.pumpAndSettle();

      final results = scanScreen();
      expect(results.map((r) => r.text), contains('Hello scanner'));
    });

    testWidgets('finds nested TextSpan children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text.rich(
              TextSpan(
                text: 'Bold',
                style: TextStyle(fontWeight: FontWeight.bold),
                children: [TextSpan(text: ' and normal')],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final results = scanScreen();
      final texts = results.map((r) => r.text).toList();
      expect(texts, containsAll(['Bold', ' and normal']));
    });

    testWidgets('finds text inside a TextField', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(decoration: InputDecoration(labelText: 'Name')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Type something so there is visible text in the RenderEditable.
      await tester.enterText(find.byType(TextField), 'typed text');
      await tester.pump();

      final results = scanScreen();
      expect(results.map((r) => r.text), contains('typed text'));
    });

    testWidgets('skips Offstage text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Visible'),
                Offstage(offstage: true, child: Text('Hidden')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final results = scanScreen();
      final texts = results.map((r) => r.text).toList();
      expect(texts, contains('Visible'));
      expect(texts, isNot(contains('Hidden')));
    });

    testWidgets('reports theme fontSize when TextStyle is inherited', (
      tester,
    ) async {
      const testSize = 22.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontSize: testSize),
            ),
          ),
          home: const Scaffold(body: Text('Themed')),
        ),
      );
      await tester.pumpAndSettle();

      final results = scanScreen();
      final themed = results.firstWhere(
        (r) => r.text == 'Themed',
        orElse: () {
          fail('Could not find "Themed" text');
        },
      );
      // The resolved RenderParagraph text should carry the theme size.
      expect(themed.fontSize, testSize);
    });
  });

  group('FontLensWidget – release safety', () {
    testWidgets('enabled:false returns child unchanged', (tester) async {
      const key = Key('inner');
      await tester.pumpWidget(
        const MaterialApp(
          home: FontLensWidget(
            enabled: false,
            child: Scaffold(body: SizedBox(key: key)),
          ),
        ),
      );
      // The scan button must NOT be present.
      expect(find.byKey(key), findsOneWidget);
      expect(find.byIcon(Icons.text_fields), findsNothing);
    });

    testWidgets('enabled:true shows scan button and opens panel on tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              FontLensWidget(enabled: true, child: child!),
          home: const Scaffold(body: Text('Hello FontLens')),
        ),
      );
      await tester.pumpAndSettle();

      // The launcher button is present
      final launcher = find.byType(LauncherButton);
      expect(launcher, findsOneWidget);

      // Tap launcher button
      await tester.tap(launcher);
      await tester.pumpAndSettle();

      // Panel opened with logo and Pick button
      expect(find.byType(FontLensLogo), findsOneWidget);
      expect(find.text('Pick'), findsOneWidget);

      // Close button in panel header
      await tester.tap(
        find.descendant(
          of: find.byType(PanelHeader),
          matching: find.byIcon(Icons.close_rounded),
        ),
      );
      await tester.pumpAndSettle();

      // Panel closed, launcher visible again
      expect(find.text('Pick'), findsNothing);
      expect(find.byType(LauncherButton), findsOneWidget);
    });

    testWidgets(
      'FontLens opens in Arabic RTL when configured and displays group rows',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => FontLensWidget(
              enabled: true,
              locale: const Locale('ar'),
              child: child!,
            ),
            home: const Scaffold(
              body: Column(children: [Text('كرة القدم'), Text('كرة اليد')]),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap launcher -> opens in collapsed pick mode
        await tester.tap(find.byType(LauncherButton));
        await tester.pumpAndSettle();

        // Arabic labels exist
        expect(find.text('تحديد'), findsOneWidget);

        // Tap expand arrow to see full panel with group rows
        await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
        await tester.pumpAndSettle();

        expect(find.textContaining('الكل'), findsOneWidget);

        // Close panel
        await tester.tap(
          find.descendant(
            of: find.byType(PanelHeader),
            matching: find.byIcon(Icons.close_rounded),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(LauncherButton), findsOneWidget);
      },
    );
  });
}
