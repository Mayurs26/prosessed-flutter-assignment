import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_event.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

Product makeProduct({
  int id = 1,
  double price = 100,
  double discount = 10,
  int stock = 10,
}) {
  return Product(
    id: id,
    title: 'Test Product $id',
    description: 'Description',
    category: 'test-category',
    price: price,
    discountPercentage: discount,
    rating: 4.5,
    stock: stock,
    brand: 'Test Brand',
    thumbnail: 'https://example.com/image.png',
    images: const [],
  );
}

void main() {
  late MockCartLocalDataSource dataSource;
  late CartBloc bloc;

  setUp(() {
    dataSource = MockCartLocalDataSource();

    when(() => dataSource.getCart()).thenReturn([]);
    when(() => dataSource.saveCart(any())).thenAnswer((_) async {});
    when(() => dataSource.clearCart()).thenAnswer((_) async {});

    bloc = CartBloc(dataSource);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is an empty cart', () {
    expect(bloc.state.isEmpty, isTrue);
    expect(bloc.state.totalItems, 0);
    expect(bloc.state.grandTotal, 0);
  });

  test('loads saved cart items', () async {
    final item = CartItem(product: makeProduct(), quantity: 2);
    when(() => dataSource.getCart()).thenReturn([item]);

    bloc.add(const CartLoaded());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.items, [item]);
    expect(bloc.state.totalItems, 2);
  });

  test('adds a product and persists the cart', () async {
    final item = CartItem(product: makeProduct(), quantity: 1);

    bloc.add(CartItemAdded(item));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.items, [item]);
    verify(() => dataSource.saveCart([item])).called(1);
  });

  test('increases quantity when the same product is added again', () async {
    final product = makeProduct();
    bloc.add(CartItemAdded(CartItem(product: product, quantity: 1)));
    await Future<void>.delayed(Duration.zero);

    bloc.add(CartItemAdded(CartItem(product: product, quantity: 2)));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.items.single.quantity, 3);
    expect(bloc.state.totalItems, 3);
  });

  test('does not exceed available stock', () async {
    final product = makeProduct(stock: 3);

    bloc.add(CartItemAdded(CartItem(product: product, quantity: 5)));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.items.single.quantity, 3);
  });

  test('does not add an out-of-stock product', () async {
    final product = makeProduct(stock: 0);

    bloc.add(CartItemAdded(CartItem(product: product, quantity: 1)));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.isEmpty, isTrue);
  });

  test(
    'updates quantity and removes item when quantity becomes zero',
    () async {
      final product = makeProduct();

      bloc.add(CartItemAdded(CartItem(product: product, quantity: 2)));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const CartQuantityUpdated(productId: 1, quantity: 0));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isEmpty, isTrue);
    },
  );

  test('removes selected product', () async {
    bloc.add(CartItemAdded(CartItem(product: makeProduct(id: 1), quantity: 1)));
    await Future<void>.delayed(Duration.zero);

    bloc.add(CartItemAdded(CartItem(product: makeProduct(id: 2), quantity: 1)));
    await Future<void>.delayed(Duration.zero);

    bloc.add(const CartItemRemoved(1));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.items.map((item) => item.product.id), [2]);
  });

  test('calculates subtotal, discount and grand total correctly', () async {
    bloc.add(
      CartItemAdded(
        CartItem(product: makeProduct(price: 100, discount: 10), quantity: 2),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.subtotal, 200);
    expect(bloc.state.totalDiscount, closeTo(20, 0.001));
    expect(bloc.state.grandTotal, closeTo(180, 0.001));
  });

  test('clears cart and local persistence', () async {
    bloc.add(CartItemAdded(CartItem(product: makeProduct(), quantity: 1)));
    await Future<void>.delayed(Duration.zero);

    bloc.add(const CartCleared());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.isEmpty, isTrue);
    verify(() => dataSource.clearCart()).called(1);
  });
}
