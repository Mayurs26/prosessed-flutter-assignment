import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/usecases/checkout_use_case.dart';
import 'package:shopsphere/features/cart/presentation/bloc/checkout_bloc.dart';
import 'package:shopsphere/features/cart/presentation/bloc/checkout_event.dart';
import 'package:shopsphere/features/cart/presentation/bloc/checkout_state.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockCheckoutUseCase extends Mock implements CheckoutUseCase {}

Product makeProduct() {
  return Product(
    id: 1,
    title: 'Test Product',
    description: 'Test description',
    category: 'test-category',
    price: 100,
    discountPercentage: 10,
    rating: 4.5,
    stock: 10,
    brand: 'Test Brand',
    thumbnail: 'https://example.com/image.png',
    images: const [],
  );
}

void main() {
  late MockCheckoutUseCase checkoutUseCase;
  late CheckoutBloc bloc;

  final cartItems = [CartItem(product: makeProduct(), quantity: 2)];

  const userId = 123;
  final order = <String, dynamic>{
    'id': 1,
    'userId': userId,
    'products': [
      {'id': 1, 'quantity': 2},
    ],
  };

  setUp(() {
    checkoutUseCase = MockCheckoutUseCase();
    bloc = CheckoutBloc(checkoutUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is CheckoutInitial', () {
    expect(bloc.state, isA<CheckoutInitial>());
  });

  test('emits loading then success when checkout succeeds', () async {
    when(() => checkoutUseCase(userId: userId, items: cartItems))
        .thenAnswer((_) async => order);

    final states = <CheckoutState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(CheckoutRequested(userId: userId, items: cartItems));

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await subscription.cancel();

    expect(states, [const CheckoutLoading(), CheckoutSuccess(order)]);

    verify(() => checkoutUseCase(userId: userId, items: cartItems)).called(1);
  });

  test('emits loading then failure when checkout throws', () async {
    when(() => checkoutUseCase(userId: userId, items: cartItems))
        .thenThrow(Exception('Network error'));

    final states = <CheckoutState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(CheckoutRequested(userId: userId, items: cartItems));

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    await subscription.cancel();

    expect(states, [
      const CheckoutLoading(),
      const CheckoutFailure('Checkout failed. Please try again.'),
    ]);
  });

  test('passes the requested user ID and cart items to the use case', () async {
    when(() => checkoutUseCase(userId: userId, items: cartItems))
        .thenAnswer((_) async => order);

    bloc.add(CheckoutRequested(userId: userId, items: cartItems));

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    verify(() => checkoutUseCase(userId: userId, items: cartItems)).called(1);
  });
}
