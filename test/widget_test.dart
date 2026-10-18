import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/app.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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
    await tester.pumpWidget(const ShopSphereApp());
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == 'ShopSphere',
      ),
      findsOneWidget,
    );
  });
}
