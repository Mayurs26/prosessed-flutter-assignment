import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/features/cart/presentation/pages/checkout_success_page.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/checkout-success',
      routes: [
        GoRoute(
          path: '/checkout-success',
          builder: (context, state) => const CheckoutSuccessPage(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Products Screen'))),
        ),
      ],
    );
  });

  tearDown(() {
    router.dispose();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    // Provide enough vertical space for the confirmation page and buttons.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    // Start the page animation without waiting for it to settle.
    await tester.pump(const Duration(milliseconds: 100));
  }

  void resetView(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('shows order confirmation content', (tester) async {
    addTearDown(() => resetView(tester));

    await pumpPage(tester);

    expect(find.text('Order Confirmation'), findsOneWidget);
    expect(find.text('ORDER CONFIRMED'), findsOneWidget);
    expect(find.text('Order placed\nsuccessfully!'), findsOneWidget);
    expect(find.text('Continue Shopping'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);

    // The success icon appears in both the illustration and confirmation badge.
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
  });

  testWidgets('Continue Shopping navigates to products', (tester) async {
    addTearDown(() => resetView(tester));

    await pumpPage(tester);

    final button = find.widgetWithText(FilledButton, 'Continue Shopping');

    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Products Screen'), findsOneWidget);
  });

  testWidgets('Back to Home navigates to products', (tester) async {
    addTearDown(() => resetView(tester));

    await pumpPage(tester);

    final button = find.widgetWithText(TextButton, 'Back to Home');

    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Products Screen'), findsOneWidget);
  });
}
