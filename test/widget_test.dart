import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_harness.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('launches into the splash sequence and reaches Welcome', (
    WidgetTester tester,
  ) async {
    // Reduced motion stops the Welcome screen's ambient drift, which is
    // continuous and would otherwise keep the tree from ever settling.
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );

    await tester.pumpWidget(buildTestApp());

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // The call to action carries its stressed word in a Text.rich span.
    expect(
      find.text('Start your Journey within.', findRichText: true),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
