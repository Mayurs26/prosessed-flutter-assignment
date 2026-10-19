import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_use_case.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_by_category_use_case.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_by_id_use_case.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_categories_use_case.dart';
import 'package:shopsphere/features/products/domain/usecases/search_products_use_case.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;

  setUp(() => repository = MockProductRepository());

  test('GetProductByIdUseCase forwards product ID', () async {
    when(() => repository.getProductById(42))
        .thenAnswer((_) async => throw StateError('test'));

    await expectLater(
      GetProductByIdUseCase(repository).call(42),
      throwsA(isA<StateError>()),
    );

    verify(() => repository.getProductById(42)).called(1);
  });

  test('GetProductsUseCase forwards custom pagination', () async {
    when(() => repository.getProducts(limit: 10, skip: 15))
        .thenAnswer((_) async => []);

    await GetProductsUseCase(repository).call(limit: 10, skip: 15);

    verify(() => repository.getProducts(limit: 10, skip: 15)).called(1);
  });

  test(
    'GetProductsByCategoryUseCase forwards category and pagination',
    () async {
      when(
        () => repository.getProductsByCategory(
          categorySlug: 'smartphones',
          limit: 5,
          skip: 10,
        ),
      ).thenAnswer((_) async => []);

      final result = await GetProductsByCategoryUseCase(repository)
          .call(categorySlug: 'smartphones', limit: 5, skip: 10);

      expect(result, isEmpty);
      verify(
        () => repository.getProductsByCategory(
          categorySlug: 'smartphones',
          limit: 5,
          skip: 10,
        ),
      ).called(1);
    },
  );

  test('GetProductCategoriesUseCase returns repository categories', () async {
    when(() => repository.getCategories()).thenAnswer((_) async => []);

    final result = await GetProductCategoriesUseCase(repository).call();

    expect(result, isEmpty);
    verify(() => repository.getCategories()).called(1);
  });

  test('SearchProductsUseCase forwards query and pagination', () async {
    when(() => repository.searchProducts(query: 'phone', limit: 10, skip: 5))
        .thenAnswer((_) async => []);

    final result = await SearchProductsUseCase(repository)
        .call(query: 'phone', limit: 10, skip: 5);

    expect(result, isEmpty);
    verify(() => repository.searchProducts(query: 'phone', limit: 10, skip: 5))
        .called(1);
  });
}
