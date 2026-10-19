import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failure.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/product_category_model.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

ProductModel makeProduct({int id = 1, String title = 'Test Phone'}) {
  return ProductModel(
    id: id,
    title: title,
    description: 'Test description',
    category: 'smartphones',
    price: 999,
    discountPercentage: 10,
    rating: 4.5,
    stock: 20,
    brand: 'Test Brand',
    thumbnail: 'https://example.com/phone.png',
    images: const ['https://example.com/phone.png'],
  );
}

void main() {
  late MockProductRemoteDataSource remoteDataSource;
  late ProductRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('getProducts', () {
    test('returns products from remote data source', () async {
      final products = [makeProduct()];

      when(() => remoteDataSource.getProducts(limit: 20, skip: 0))
          .thenAnswer((_) async => products);

      final result = await repository.getProducts(limit: 20, skip: 0);

      expect(result, products);
      expect(result.single.title, 'Test Phone');
      verify(() => remoteDataSource.getProducts(limit: 20, skip: 0)).called(1);
    });

    test('maps connection errors to NetworkFailure', () async {
      when(() => remoteDataSource.getProducts(limit: 20, skip: 0)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/products'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => repository.getProducts(limit: 20, skip: 0),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('searchProducts', () {
    test('passes query and pagination to remote data source', () async {
      final products = [makeProduct(title: 'Search Phone')];

      when(
        () =>
            remoteDataSource.searchProducts(query: 'phone', limit: 10, skip: 5),
      ).thenAnswer((_) async => products);

      final result = await repository.searchProducts(
        query: 'phone',
        limit: 10,
        skip: 5,
      );

      expect(result.single.title, 'Search Phone');
      verify(
        () =>
            remoteDataSource.searchProducts(query: 'phone', limit: 10, skip: 5),
      ).called(1);
    });

    test('maps invalid response format to ParsingFailure', () async {
      when(
        () =>
            remoteDataSource.searchProducts(query: 'phone', limit: 10, skip: 0),
      ).thenThrow(const FormatException('Invalid search response'));

      expect(
        () => repository.searchProducts(query: 'phone', limit: 10, skip: 0),
        throwsA(isA<ParsingFailure>()),
      );
    });
  });

  group('getCategories', () {
    test('converts category models to domain entities', () async {
      when(() => remoteDataSource.getCategories()).thenAnswer(
        (_) async => [
          const ProductCategoryModel(slug: 'smartphones', name: 'Smartphones'),
        ],
      );

      final result = await repository.getCategories();

      expect(result, hasLength(1));
      expect(result.single.slug, 'smartphones');
      expect(result.single.name, 'Smartphones');
    });

    test('maps invalid response format to ParsingFailure', () async {
      when(() => remoteDataSource.getCategories())
          .thenThrow(const FormatException('Invalid categories response'));

      expect(() => repository.getCategories(), throwsA(isA<ParsingFailure>()));
    });
  });

  group('getProductsByCategory', () {
    test('passes category and pagination to remote data source', () async {
      when(
        () => remoteDataSource.getProductsByCategory(
          categorySlug: 'smartphones',
          limit: 20,
          skip: 0,
        ),
      ).thenAnswer((_) async => [makeProduct()]);

      final result = await repository.getProductsByCategory(
        categorySlug: 'smartphones',
        limit: 20,
        skip: 0,
      );

      expect(result, hasLength(1));
      verify(
        () => remoteDataSource.getProductsByCategory(
          categorySlug: 'smartphones',
          limit: 20,
          skip: 0,
        ),
      ).called(1);
    });

    test('maps invalid response format to ParsingFailure', () async {
      when(
        () => remoteDataSource.getProductsByCategory(
          categorySlug: 'smartphones',
          limit: 20,
          skip: 0,
        ),
      ).thenThrow(const FormatException('Invalid category response'));

      expect(
        () => repository.getProductsByCategory(
          categorySlug: 'smartphones',
          limit: 20,
          skip: 0,
        ),
        throwsA(isA<ParsingFailure>()),
      );
    });
  });

  group('getProductById', () {
    test('returns the requested product', () async {
      when(() => remoteDataSource.getProductById(1))
          .thenAnswer((_) async => makeProduct());

      final result = await repository.getProductById(1);

      expect(result.id, 1);
      expect(result.title, 'Test Phone');
    });

    test('maps product parsing errors to ParsingFailure', () async {
      when(() => remoteDataSource.getProductById(9999))
          .thenThrow(const FormatException('Invalid product details response'));

      expect(
        () => repository.getProductById(9999),
        throwsA(isA<ParsingFailure>()),
      );
    });

    test('maps server errors to ServerFailure', () async {
      when(() => remoteDataSource.getProductById(1)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/products/1'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/products/1'),
            statusCode: 500,
          ),
        ),
      );

      expect(() => repository.getProductById(1), throwsA(isA<ServerFailure>()));
    });
  });
}
