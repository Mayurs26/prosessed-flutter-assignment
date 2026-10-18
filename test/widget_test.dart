import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/app.dart';

void main() {
  testWidgets('ShopSphere app launches successfully', (tester) async {
    await tester.pumpWidget(const ShopSphereApp());

    expect(find.text('ShopSphere'), findsOneWidget);
    expect(find.text('Welcome to ShopSphere'), findsOneWidget);
  });
}
