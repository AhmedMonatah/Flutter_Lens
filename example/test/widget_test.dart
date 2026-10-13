import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FontLensExampleApp());
    expect(find.text('font_lens'), findsOneWidget);
  });
}
