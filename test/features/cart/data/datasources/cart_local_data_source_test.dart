import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

void main() {
  late SharedPreferences preferences;
  late CartLocalDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    dataSource = CartLocalDataSource(preferences);
  });

  test('returns empty cart when nothing is saved', () {
    expect(dataSource.getCart(), isEmpty);
  });

  test('saves and restores cart items', () async {
    final product = Product(
      id: 1,
      title: 'Test Phone',
      description: 'A test phone',
      category: 'smartphones',
      price: 100,
      discountPercentage: 5,
      rating: 4.5,
      stock: 10,
      brand: 'Test',
      thumbnail: 'https://example.com/phone.png',
      images: const [],
      reviews: const [],
    );

    await dataSource.saveCart([CartItem(product: product, quantity: 2)]);

    final restored = dataSource.getCart();

    expect(restored, hasLength(1));
    expect(restored.first.product.id, 1);
    expect(restored.first.product.title, 'Test Phone');
    expect(restored.first.quantity, 2);
  });

  test('clears saved cart', () async {
    await preferences.setString('shopsphere_cart_items', '[]');

    await dataSource.clearCart();

    expect(dataSource.getCart(), isEmpty);
    expect(preferences.getString('shopsphere_cart_items'), isNull);
  });

  test('returns empty cart for malformed JSON', () async {
    await preferences.setString('shopsphere_cart_items', '{invalid json');

    expect(dataSource.getCart(), isEmpty);
  });

  test('returns empty cart when saved structure has invalid types', () async {
    await preferences.setString(
      'shopsphere_cart_items',
      '[{"product": "invalid", "quantity": 2}]',
    );

    expect(dataSource.getCart(), isEmpty);
  });
}
