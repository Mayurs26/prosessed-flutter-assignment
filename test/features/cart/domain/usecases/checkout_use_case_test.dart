import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/usecases/checkout_use_case.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository repository;
  late CheckoutUseCase useCase;

  setUp(() {
    repository = MockCartRepository();
    useCase = CheckoutUseCase(repository);
  });

  Product createProduct() {
    return Product(
      id: 1,
      title: 'Test Phone',
      description: 'Test description',
      category: 'smartphones',
      price: 100,
      discountPercentage: 10,
      rating: 4.5,
      stock: 5,
      brand: 'Test Brand',
      thumbnail: 'https://example.com/phone.png',
      images: const [],
      reviews: const [],
    );
  }

  test('rejects checkout when cart is empty', () async {
    expect(
      () => useCase.call(userId: 7, items: <CartItem>[]),
      throwsArgumentError,
    );

    verifyNever(
      () => repository.checkout(
        userId: any(named: 'userId'),
        items: any(named: 'items'),
      ),
    );
  });

  test('forwards non-empty cart to repository', () async {
    final items = [CartItem(product: createProduct(), quantity: 2)];

    final response = <String, dynamic>{'id': 123, 'userId': 7};

    when(() => repository.checkout(userId: 7, items: items))
        .thenAnswer((_) async => response);

    final result = await useCase.call(userId: 7, items: items);

    expect(result, response);

    verify(() => repository.checkout(userId: 7, items: items)).called(1);
  });
}
