import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';

void main() {
  late Dio dio;
  late ProductRemoteDataSourceImpl dataSource;

  final productJson = <String, dynamic>{
    'id': 1,
    'title': 'Test Phone',
    'description': 'Test description',
    'category': 'smartphones',
    'price': 999,
    'discountPercentage': 10,
    'rating': 4.5,
    'stock': 20,
    'brand': 'Test Brand',
    'thumbnail': 'https://example.com/phone.png',
    'images': ['https://example.com/phone.png'],
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));
    dataSource = ProductRemoteDataSourceImpl(dio: dio);
  });

  tearDown(() {
    dio.close(force: true);
  });

  void respondWith(Map<String, dynamic> body) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: body,
            ),
          );
        },
      ),
    );
  }

  group('getProducts', () {
    test('parses products and sends pagination parameters', () async {
      respondWith({
        'products': [productJson],
        'total': 1,
        'skip': 0,
        'limit': 20,
      });

      final result = await dataSource.getProducts(limit: 20, skip: 0);

      expect(result, hasLength(1));
      expect(result.first, isA<ProductModel>());
      expect(result.first.title, 'Test Phone');
      expect(result.first.id, 1);
    });

    test('throws FormatException for a missing products list', () async {
      respondWith({'total': 0});

      expect(
        () => dataSource.getProducts(limit: 20, skip: 0),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('searchProducts', () {
    test('parses search results', () async {
      respondWith({
        'products': [productJson],
      });

      final result = await dataSource.searchProducts(
        query: 'phone',
        limit: 10,
        skip: 0,
      );

      expect(result, hasLength(1));
      expect(result.first.title, 'Test Phone');
    });

    test('throws FormatException for an invalid search response', () async {
      respondWith({'results': []});

      expect(
        () => dataSource.searchProducts(query: 'phone', limit: 10, skip: 0),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('getCategories', () {
    test('parses categories and excludes empty slugs', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {'slug': 'smartphones', 'name': 'Smartphones'},
                  {'slug': '', 'name': 'Invalid category'},
                  {'slug': 'laptops', 'name': 'Laptops'},
                ],
              ),
            );
          },
        ),
      );

      final result = await dataSource.getCategories();

      expect(result, hasLength(2));
      expect(result.map((category) => category.slug).toList(), [
        'smartphones',
        'laptops',
      ]);
    });

    test('throws FormatException when categories response is null', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: null,
              ),
            );
          },
        ),
      );

      expect(() => dataSource.getCategories(), throwsA(isA<FormatException>()));
    });
  });

  group('getProductsByCategory', () {
    test('parses products for the requested category', () async {
      respondWith({
        'products': [productJson],
      });

      final result = await dataSource.getProductsByCategory(
        categorySlug: 'smartphones',
        limit: 20,
        skip: 0,
      );

      expect(result, hasLength(1));
      expect(result.first.category, 'smartphones');
    });

    test('throws FormatException for an invalid category response', () async {
      respondWith({'items': []});

      expect(
        () => dataSource.getProductsByCategory(
          categorySlug: 'smartphones',
          limit: 20,
          skip: 0,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('getProductById', () {
    test('parses a product by ID', () async {
      respondWith(productJson);

      final result = await dataSource.getProductById(1);

      expect(result.id, 1);
      expect(result.title, 'Test Phone');
    });

    test('throws FormatException when product response is null', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: null,
              ),
            );
          },
        ),
      );

      expect(
        () => dataSource.getProductById(1),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
