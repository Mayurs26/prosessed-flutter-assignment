import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failure.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_review.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_by_id_use_case.dart';
import 'package:shopsphere/features/products/presentation/pages/product_details_page.dart';

class MockGetProductByIdUseCase extends Mock implements GetProductByIdUseCase {}

class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

void main() {
  final locator = GetIt.instance;

  late MockGetProductByIdUseCase getProductById;
  late MockCartLocalDataSource localDataSource;
  late CartBloc cartBloc;

  const product = Product(
    id: 1,
    title: 'Test Headphones',
    description: 'Comfortable wireless headphones.',
    category: 'mens-watches',
    price: 100,
    discountPercentage: 20,
    rating: 4.5,
    stock: 5,
    brand: 'Test Brand',
    thumbnail: 'https://example.com/image.jpg',
    images: ['https://example.com/image.jpg', 'https://example.com/image2.jpg'],
    reviews: [
      ProductReview(
        rating: 5,
        comment: 'Excellent product!',
        date: '2026-01-01',
        reviewerName: 'Alex',
        reviewerEmail: 'alex@example.com',
      ),
    ],
  );

  const unavailableProduct = Product(
    id: 2,
    title: 'Unavailable Product',
    description: 'Currently unavailable.',
    category: 'accessories',
    price: 25,
    discountPercentage: 0,
    rating: 3.5,
    stock: 0,
    brand: '',
    thumbnail: 'https://example.com/unavailable.jpg',
    images: [],
  );

  setUp(() async {
    await locator.reset();

    getProductById = MockGetProductByIdUseCase();
    localDataSource = MockCartLocalDataSource();

    locator.registerSingleton<GetProductByIdUseCase>(getProductById);

    when(() => localDataSource.getCart()).thenReturn([]);
    when(() => localDataSource.saveCart(any())).thenAnswer((_) async {});
    when(() => localDataSource.clearCart()).thenAnswer((_) async {});

    cartBloc = CartBloc(localDataSource);
  });

  tearDown(() async {
    await cartBloc.close();
    await locator.reset();
  });

  Future<void> pumpPage(WidgetTester tester, {Product item = product}) async {
    when(() => getProductById(item.id)).thenAnswer((_) async => item);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartBloc>.value(
          value: cartBloc,
          child: ProductDetailsPage(product: item),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('shows product details and discounted price', (tester) async {
    await pumpPage(tester);

    expect(find.text('THE EDIT'), findsOneWidget);
    expect(find.text('Test Headphones'), findsOneWidget);
    expect(find.text('MENS WATCHES'), findsOneWidget);
    expect(find.text('20% OFF'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('\$80.00'), findsWidgets);
    expect(find.text('\$100.00'), findsOneWidget);
    expect(find.text('Test Brand'), findsOneWidget);
    expect(find.text('Comfortable wireless headphones.'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Excellent product!'), findsOneWidget);
    expect(find.textContaining('5'), findsWidgets);
  });

  testWidgets('shows loading indicator while product is loading', (
    tester,
  ) async {
    final completer = Completer<Product>();

    when(() => getProductById(product.id)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartBloc>.value(
          value: cartBloc,
          child: const ProductDetailsPage(product: product),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(product);
    await tester.pumpAndSettle();
  });

  testWidgets('shows retry UI when product request fails', (tester) async {
    when(() => getProductById(product.id))
        .thenAnswer((_) async => throw Exception('Network error'));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartBloc>.value(
          value: cartBloc,
          child: const ProductDetailsPage(product: product),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lost the connection?'), findsOneWidget);
    expect(find.text('Check your connection and try again.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows not-found message for NotFoundFailure', (tester) async {
    when(
      () => getProductById(product.id),
    ).thenAnswer((_) async => throw const NotFoundFailure('Product not found'));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartBloc>.value(
          value: cartBloc,
          child: const ProductDetailsPage(product: product),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('A little hard to find'), findsOneWidget);
    expect(
      find.text('This product may no longer be available.'),
      findsOneWidget,
    );
  });

  testWidgets('retry calls product use case again', (tester) async {
    var attempts = 0;

    when(() => getProductById(product.id)).thenAnswer((_) async {
      attempts++;

      if (attempts == 1) {
        throw Exception('Network error');
      }

      return product;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartBloc>.value(
          value: cartBloc,
          child: const ProductDetailsPage(product: product),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(attempts, 1);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('Test Headphones'), findsOneWidget);
  });

  testWidgets('quantity controls update displayed quantity', (tester) async {
    await pumpPage(tester);

    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('cannot decrease quantity below one', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('out-of-stock product disables purchase controls', (
    tester,
  ) async {
    await pumpPage(tester, item: unavailableProduct);

    expect(find.text('Out of stock'), findsNWidgets(2));

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Not available'), findsOneWidget);

    final addButtonFinder = find.widgetWithText(FilledButton, 'Out of stock');

    expect(addButtonFinder, findsOneWidget);

    final addButton = tester.widget<FilledButton>(addButtonFinder);
    expect(addButton.onPressed, isNull);

    final increaseButtonFinder = find.ancestor(
      of: find.byTooltip('Increase quantity'),
      matching: find.byType(IconButton),
    );

    expect(increaseButtonFinder, findsOneWidget);

    final increaseButton = tester.widget<IconButton>(increaseButtonFinder);
    expect(increaseButton.onPressed, isNull);
  });

  testWidgets('adding product dispatches CartItemAdded event', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to bag'));
    await tester.pump();

    await untilCalled(() => localDataSource.saveCart(any()));

    verify(
      () => localDataSource.saveCart(
        any(
          that: predicate<List<CartItem>>(
            (items) =>
                items.length == 1 &&
                items.first.product.id == product.id &&
                items.first.quantity == 2,
          ),
        ),
      ),
    ).called(1);

    expect(find.text('Test Headphones added to cart'), findsOneWidget);
  });

  testWidgets('cart icon displays cart tab message', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Shopping cart'));
    await tester.pump();

    expect(
      find.text('Your cart is available from the cart tab.'),
      findsOneWidget,
    );
  });
}
