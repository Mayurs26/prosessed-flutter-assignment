import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_category.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_categories_use_case.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_by_category_use_case.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_use_case.dart';
import 'package:shopsphere/features/products/domain/usecases/search_products_use_case.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_bloc.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_event.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockGetCategoriesUseCase extends Mock
    implements GetProductCategoriesUseCase {}

class MockGetProductsByCategoryUseCase extends Mock
    implements GetProductsByCategoryUseCase {}

class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

Product makeProduct({
  int id = 1,
  String title = 'Product',
  double price = 100,
  double rating = 4,
}) {
  return Product(
    id: id,
    title: title,
    description: 'Test description',
    category: 'test-category',
    price: price,
    discountPercentage: 0,
    rating: rating,
    stock: 10,
    brand: 'Test brand',
    thumbnail: 'https://example.com/image.png',
    images: const [],
  );
}

void main() {
  late MockGetProductsUseCase getProducts;
  late MockGetCategoriesUseCase getCategories;
  late MockGetProductsByCategoryUseCase getByCategory;
  late MockSearchProductsUseCase searchProducts;

  setUp(() {
    getProducts = MockGetProductsUseCase();
    getCategories = MockGetCategoriesUseCase();
    getByCategory = MockGetProductsByCategoryUseCase();
    searchProducts = MockSearchProductsUseCase();

    when(
      () => getProducts(
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) async => [makeProduct()]);

    when(() => getCategories()).thenAnswer(
      (_) async => const [
        ProductCategory(slug: 'test-category', name: 'Test Category'),
      ],
    );

    when(
      () => getByCategory(
        categorySlug: any(named: 'categorySlug'),
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) async => [makeProduct()]);

    when(
      () => searchProducts(
        query: any(named: 'query'),
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) async => [makeProduct()]);
  });

  ProductBloc buildBloc() => ProductBloc(
    getProductsUseCase: getProducts,
    getProductCategoriesUseCase: getCategories,
    getProductsByCategoryUseCase: getByCategory,
    searchProductsUseCase: searchProducts,
  );

  blocTest<ProductBloc, ProductState>(
    'loads products successfully',
    build: buildBloc,
    act: (bloc) => bloc.add(const ProductsRequested()),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.status,
        'loading status',
        ProductStatus.loading,
      ),
      isA<ProductState>()
          .having((s) => s.status, 'success status', ProductStatus.success)
          .having((s) => s.products.length, 'product count', 1),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'loads products for selected category',
    build: buildBloc,
    act: (bloc) => bloc.add(const ProductCategorySelected('test-category')),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.selectedCategorySlug,
        'category',
        'test-category',
      ),
      isA<ProductState>().having(
        (s) => s.status,
        'success status',
        ProductStatus.success,
      ),
    ],
    verify: (_) {
      verify(
        () => getByCategory(categorySlug: 'test-category', limit: 20, skip: 0),
      ).called(1);
    },
  );

  blocTest<ProductBloc, ProductState>(
    'sorts products by price low to high',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      products: [
        makeProduct(id: 1, price: 300),
        makeProduct(id: 2, price: 100),
        makeProduct(id: 3, price: 200),
      ],
    ),
    act: (bloc) =>
        bloc.add(const ProductSortChanged(ProductSortOption.priceLowToHigh)),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.products.map((p) => p.price).toList(),
        'sorted prices',
        [100.0, 200.0, 300.0],
      ),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'filters products by minimum rating',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      products: [
        makeProduct(id: 1, rating: 3),
        makeProduct(id: 2, rating: 4.5),
      ],
    ),
    act: (bloc) => bloc.add(const ProductFiltersChanged(minRating: 4)),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.products.map((p) => p.id).toList(),
        'filtered product ids',
        [2],
      ),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'clears active filters',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      products: [
        makeProduct(id: 1, rating: 3),
        makeProduct(id: 2, rating: 4.5),
      ],
      minRating: 4,
    ),
    act: (bloc) => bloc.add(const ProductFiltersCleared()),
    expect: () => [
      isA<ProductState>()
          .having((s) => s.minRating, 'minimum rating', isNull)
          .having((s) => s.products.length, 'product count', 2),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'refresh reloads the first page',
    build: buildBloc,
    act: (bloc) => bloc.add(const ProductsRefreshed()),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.status,
        'loading status',
        ProductStatus.loading,
      ),
      isA<ProductState>().having(
        (s) => s.status,
        'success status',
        ProductStatus.success,
      ),
    ],
    verify: (_) {
      verify(() => getProducts(limit: 20, skip: 0)).called(1);
    },
  );

  blocTest<ProductBloc, ProductState>(
    'loads product categories successfully',
    build: buildBloc,
    act: (bloc) => bloc.add(const ProductCategoriesRequested()),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.isLoadingCategories,
        'loading categories',
        true,
      ),
      isA<ProductState>()
          .having((s) => s.isLoadingCategories, 'loading complete', false)
          .having((s) => s.categories.length, 'category count', 1),
    ],
    verify: (_) {
      verify(() => getCategories()).called(1);
    },
  );

  blocTest<ProductBloc, ProductState>(
    'sorts products by price high to low',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      products: [
        makeProduct(id: 1, price: 100),
        makeProduct(id: 2, price: 300),
        makeProduct(id: 3, price: 200),
      ],
    ),
    act: (bloc) =>
        bloc.add(const ProductSortChanged(ProductSortOption.priceHighToLow)),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.products.map((p) => p.price).toList(),
        'descending prices',
        [300.0, 200.0, 100.0],
      ),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'sorts products by highest rating',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      products: [
        makeProduct(id: 1, rating: 3),
        makeProduct(id: 2, rating: 4.8),
        makeProduct(id: 3, rating: 4.1),
      ],
    ),
    act: (bloc) =>
        bloc.add(const ProductSortChanged(ProductSortOption.ratingHighToLow)),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.products.map((p) => p.rating).toList(),
        'descending ratings',
        [4.8, 4.1, 3.0],
      ),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'filters products by minimum price',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      products: [
        makeProduct(id: 1, price: 50),
        makeProduct(id: 2, price: 150),
        makeProduct(id: 3, price: 300),
      ],
    ),
    act: (bloc) => bloc.add(const ProductFiltersChanged(minPrice: 100)),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.products.map((p) => p.id).toList(),
        'products at or above minimum price',
        [2, 3],
      ),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'filters products by maximum price',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      products: [
        makeProduct(id: 1, price: 50),
        makeProduct(id: 2, price: 150),
        makeProduct(id: 3, price: 300),
      ],
    ),
    act: (bloc) => bloc.add(const ProductFiltersChanged(maxPrice: 200)),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.products.map((p) => p.id).toList(),
        'products at or below maximum price',
        [1, 2],
      ),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'sorts products alphabetically by title',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      products: [
        makeProduct(id: 1, title: 'Zebra'),
        makeProduct(id: 2, title: 'Apple'),
        makeProduct(id: 3, title: 'Mango'),
      ],
    ),
    act: (bloc) =>
        bloc.add(const ProductSortChanged(ProductSortOption.titleAToZ)),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.products.map((p) => p.title).toList(),
        'alphabetical titles',
        ['Apple', 'Mango', 'Zebra'],
      ),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'searches products using the search use case',
    build: buildBloc,
    act: (bloc) {
      bloc.add(const ProductSearchChanged('phone'));
    },
    wait: const Duration(milliseconds: 600),
    expect: () => [
      isA<ProductState>().having((s) => s.searchQuery, 'search query', 'phone'),
      isA<ProductState>().having(
        (s) => s.status,
        'search success status',
        ProductStatus.success,
      ),
    ],
    verify: (_) {
      verify(() => searchProducts(query: 'phone', limit: 20, skip: 0))
          .called(1);
    },
  );

  blocTest<ProductBloc, ProductState>(
    'clears selected category',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      selectedCategorySlug: 'test-category',
      products: [makeProduct()],
    ),
    act: (bloc) => bloc.add(const ProductCategorySelected(null)),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.selectedCategorySlug,
        'cleared category',
        isNull,
      ),
      isA<ProductState>().having(
        (s) => s.status,
        'success status',
        ProductStatus.success,
      ),
    ],
    verify: (_) {
      verify(() => getProducts(limit: 20, skip: 0)).called(1);
    },
  );

  blocTest<ProductBloc, ProductState>(
    'handles product loading failure',
    setUp: () {
      when(
        () => getProducts(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
        ),
      ).thenThrow(Exception('Network error'));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const ProductsRequested()),
    expect: () => [
      isA<ProductState>().having(
        (s) => s.status,
        'loading status',
        ProductStatus.loading,
      ),
      isA<ProductState>()
          .having((s) => s.status, 'failure status', ProductStatus.failure)
          .having((s) => s.errorMessage, 'error message', isNotNull),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'loads the next page and appends products',
    build: buildBloc,
    setUp: () {
      when(() => getProducts(limit: 20, skip: 20)).thenAnswer(
        (_) async => List.generate(20, (index) => makeProduct(id: index + 21)),
      );
    },
    seed: () => ProductState(
      status: ProductStatus.success,
      products: List.generate(20, (index) => makeProduct(id: index + 1)),
      currentPage: 1,
    ),
    act: (bloc) => bloc.add(const MoreProductsRequested()),
    expect: () => [
      isA<ProductState>().having(
        (state) => state.isLoadingMore,
        'loading more',
        true,
      ),
      isA<ProductState>()
          .having((state) => state.products.length, 'product count', 40)
          .having((state) => state.currentPage, 'current page', 2)
          .having((state) => state.isLoadingMore, 'loading complete', false),
    ],
    verify: (_) {
      verify(() => getProducts(limit: 20, skip: 20)).called(1);
    },
  );

  blocTest<ProductBloc, ProductState>(
    'does not request another page when maximum is reached',
    build: buildBloc,
    seed: () => ProductState(
      status: ProductStatus.success,
      products: [makeProduct()],
      currentPage: 1,
      hasReachedMax: true,
    ),
    act: (bloc) => bloc.add(const MoreProductsRequested()),
    expect: () => <ProductState>[],
    verify: (_) {
      verifyNever(() => getProducts(limit: 20, skip: 20));
    },
  );
}
