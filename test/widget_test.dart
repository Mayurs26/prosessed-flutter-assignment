import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopsphere/app.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/theme/theme_controller.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  tearDownAll(() async {
    await getIt.reset();
  });

  testWidgets('ShopSphere app launches successfully', (tester) async {
    final themeController = await ThemeController.create();

    await tester.pumpWidget(ShopSphereApp(themeController: themeController));
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == 'ShopSphere',
      ),
      findsOneWidget,
    );

    // Removing the app disposes its ThemeController through ShopSphereApp.
    // Do not call themeController.dispose() a second time.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
