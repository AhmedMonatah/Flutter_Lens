import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_lens/font_lens.dart';

void main() {
  group('FontLens Panel & Overlay Tests', () {
    testWidgets('enabled: false renders only child with zero overlay widgets', (
      tester,
    ) async {
      const key = Key('app_root');
      await tester.pumpWidget(
        const MaterialApp(
          home: FontLens(
            enabled: false,
            child: SizedBox(key: key),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
      expect(find.byType(LauncherButton), findsNothing);
      expect(find.byType(PanelSheet), findsNothing);
      expect(find.byType(PickLayer), findsNothing);
    });

    testWidgets(
      'non-modal: touches outside the panel reach the app (button fires while panel is open)',
      (tester) async {
        bool buttonTapped = false;
        final controller = FontLensController();

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => FontLens(
              enabled: true,
              controller: controller,
              child: child!,
            ),
            home: Scaffold(
              body: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ElevatedButton(
                    key: const Key('host_app_button'),
                    onPressed: () {
                      buttonTapped = true;
                    },
                    child: const Text('Interactive App Button'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open the panel to half height
        controller.show(startInPick: false);
        await tester.pumpAndSettle();

        expect(find.byType(PanelSheet), findsOneWidget);

        // Tap the host app button at the top of the screen
        await tester.tap(find.byKey(const Key('host_app_button')));
        await tester.pumpAndSettle();

        // The button behind/above the panel must have received the tap
        expect(buttonTapped, isTrue);
      },
    );

    testWidgets('scan isolation: panel texts never appear in scan results', (
      tester,
    ) async {
      final controller = FontLensController();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => FontLens(
            enabled: true,
            controller: controller,
            child: child!,
          ),
          home: const Scaffold(
            body: Text('Only Host App Text'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open panel
      controller.show();
      await tester.pumpAndSettle();

      // Trigger scan via controller (which scans isolated app element)
      controller.scan(
        rootElement: FontLens.activeAppKey?.currentContext as Element?,
      );
      await tester.pumpAndSettle();

      final scannedTexts = controller.scanResult?.texts.map((t) => t.source.text).toList() ?? [];

      // Host app text must be present
      expect(scannedTexts, contains('Only Host App Text'));

      // None of the panel internal strings should pollute the scan
      expect(scannedTexts, isNot(contains('font_lens')));
      expect(scannedTexts, isNot(contains('Pick')));
      expect(scannedTexts, isNot(contains('Settings')));
      expect(scannedTexts, isNot(contains('Close')));
    });

    testWidgets(
      'pick mode maps tap to the correct FoundText and shows DetailCard',
      (tester) async {
        final controller = FontLensController();

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => FontLens(
              enabled: true,
              controller: controller,
              child: child!,
            ),
            home: const Scaffold(
              body: Center(
                child: Text('Inspectable Text Item'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Scan first so geometries are known
        controller.scan(
          rootElement: FontLens.activeAppKey?.currentContext as Element?,
        );
        await tester.pumpAndSettle();

        // Enter pick mode
        controller.startPick();
        await tester.pumpAndSettle();

        expect(find.byType(PickLayer), findsOneWidget);
        expect(controller.isPickMode, isTrue);

        // Tap the text item
        await tester.tap(find.text('Inspectable Text Item'));
        await tester.pumpAndSettle();

        // DetailCard should be displayed
        expect(find.byType(DetailCard), findsOneWidget);
        expect(controller.pickedText?.text, equals('Inspectable Text Item'));

        // Tap 'Show in list' button in DetailCard
        await tester.tap(find.byType(OutlinedButton));
        await tester.pumpAndSettle();

        // Exits pick mode and opens panel to Half
        expect(controller.isPickMode, isFalse);
        expect(controller.snap, equals(PanelSnap.half));
      },
    );

    testWidgets('snapping to collapsed, half, and full states', (tester) async {
      final controller = FontLensController();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => FontLens(
            enabled: true,
            controller: controller,
            child: child!,
          ),
          home: const Scaffold(
            body: Text('Typography Test'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.show();
      await tester.pumpAndSettle();
      expect(controller.snap, equals(PanelSnap.collapsed));
      expect(controller.isPickMode, isTrue);

      controller.setSnap(PanelSnap.half);
      await tester.pumpAndSettle();
      expect(controller.snap, equals(PanelSnap.half));
      expect(controller.isPickMode, isFalse);

      controller.setSnap(PanelSnap.full);
      await tester.pumpAndSettle();
      expect(controller.snap, equals(PanelSnap.full));
    });

    testWidgets('Arabic locale and narrow 320dp screen render without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = FontLensController(locale: const Locale('ar'));

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => FontLens(
            enabled: true,
            locale: const Locale('ar'),
            controller: controller,
            child: child!,
          ),
          home: const Scaffold(
            body: Text('نص تجريبي عربي'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.show();
      await tester.pumpAndSettle();

      // No Flutter layout overflow exceptions thrown
      expect(tester.takeException(), isNull);
      expect(find.text('تحديد'), findsOneWidget);
    });

    testWidgets(
      'Pick mode enables vertical scrolling of underlying ListView',
      (tester) async {
        final scrollController = ScrollController();
        final controller = FontLensController();

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => FontLens(
              enabled: true,
              controller: controller,
              child: child!,
            ),
            home: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (context, index) => SizedBox(
                  height: 60,
                  child: Text('Item $index'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter pick mode
        controller.startPick();
        await tester.pumpAndSettle();
        expect(controller.isPickMode, isTrue);

        expect(scrollController.offset, equals(0.0));

        // Drag vertically in Pick mode
        await tester.drag(find.byType(PickLayer), const Offset(0, -200));
        await tester.pumpAndSettle();

        // The list must have scrolled!
        expect(scrollController.offset, greaterThan(0.0));
      },
    );

    testWidgets(
      'Pick mode dynamically detects text added after initial build (simulating API response)',
      (tester) async {
        final controller = FontLensController();
        bool apiDataLoaded = false;

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => FontLens(
              enabled: true,
              controller: controller,
              child: child!,
            ),
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      const SizedBox(height: 80),
                      const Text('Initial App Bar'),
                      if (apiDataLoaded)
                        const Center(child: Text('Match: Real Betis vs Osasuna'))
                      else
                        ElevatedButton(
                          onPressed: () => setState(() => apiDataLoaded = true),
                          child: const Text('Load API'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate API returning data 1 second later
        await tester.tap(find.text('Load API'));
        await tester.pumpAndSettle();

        // Start pick mode
        controller.startPick();
        await tester.pumpAndSettle();

        // Tap on the newly loaded API text
        await tester.tap(find.text('Match: Real Betis vs Osasuna'));
        await tester.pumpAndSettle();

        // Must successfully pick and inspect the API text
        expect(controller.pickedText?.text, equals('Match: Real Betis vs Osasuna'));
        expect(find.byType(DetailCard), findsOneWidget);
      },
    );

    test('FontLensStrings.ar localized counts and warning translation', () {
      const ar = FontLensStrings.ar;

      expect(ar.fontsCount(1), equals('خط واحد'));
      expect(ar.fontsCount(2), equals('خطان'));
      expect(ar.fontsCount(4), equals('4 خطوط'));
      expect(ar.fontsCount(12), equals('12 خطاً'));

      expect(ar.sizesCount(1), equals('حجم واحد'));
      expect(ar.sizesCount(2), equals('حجمان'));
      expect(ar.sizesCount(10), equals('10 أحجام'));

      expect(ar.warningsCount(2), equals('تحذيران'));
      expect(ar.warningsCount(5), equals('5 تحذيرات'));

      expect(
        ar.translateWarning('Too many font families on one screen (4). Consider consolidating to 3 or fewer for visual consistency.'),
        contains('عدد عائلات الخطوط كبير'),
      );
      expect(
        ar.translateWarning('Too many distinct font sizes on one screen (10). A consistent type scale improves readability.'),
        contains('عدد أحجام الخطوط كبير'),
      );
      expect(
        ar.translateWarning('Arabic text relies on the system fallback font. Appearance will differ across devices. Set an Arabic-capable font such as Cairo or Tajawal.'),
        contains('النص العربي يعتمد على خط النظام الاحتياطي'),
      );
    });
  });
}
