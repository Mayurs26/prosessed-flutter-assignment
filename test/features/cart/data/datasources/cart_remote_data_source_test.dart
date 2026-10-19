import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

void main() {
  late Dio dio;
  late CartRemoteDataSourceImpl dataSource;
  late Map<String, dynamic>? responseBody;
  late RequestOptions? capturedRequest;

  setUp(() {
    responseBody = {'id': 123, 'userId': 7, 'products': []};
    capturedRequest = null;

    dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedRequest = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              data: responseBody,
              statusCode: 200,
            ),
          );
        },
      ),
    );

    dataSource = CartRemoteDataSourceImpl(dio: dio);
  });

  Product createProduct() {
    return Product(
      id: 5,
      title: 'Test Product',
      description: 'Description',
      category: 'smartphones',
      price: 100,
      discountPercentage: 5,
      rating: 4.5,
      stock: 10,
      brand: 'Test',
      thumbnail: 'https://example.com/product.png',
      images: const [],
      reviews: const [],
    );
  }

  test('checkout sends user ID and product quantities', () async {
    final items = [CartItem(product: createProduct(), quantity: 2)];

    final result = await dataSource.checkout(userId: 7, items: items);

    expect(result['id'], 123);
    expect(capturedRequest?.path, '/carts/add');
    expect(capturedRequest?.data, {
      'userId': 7,
      'products': [
        {'id': 5, 'quantity': 2},
      ],
    });
  });

  test('checkout throws FormatException when response is null', () async {
    responseBody = null;

    await expectLater(
      dataSource.checkout(userId: 7, items: []),
      throwsA(isA<FormatException>()),
    );
  });

  test('checkout throws FormatException when response has no ID', () async {
    responseBody = {'userId': 7, 'products': []};

    await expectLater(
      dataSource.checkout(userId: 7, items: []),
      throwsA(isA<FormatException>()),
    );
  });
}
