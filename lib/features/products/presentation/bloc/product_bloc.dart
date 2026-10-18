import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_categories_use_case.dart';
import '../../domain/usecases/get_products_by_category_use_case.dart';
import '../../domain/usecases/get_products_use_case.dart';
import '../../domain/usecases/search_products_use_case.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({
    required this._getProductsUseCase,
    required this._getProductCategoriesUseCase,
    required this._getProductsByCategoryUseCase,
    required this._searchProductsUseCase,
  }) : super(const ProductState()) {
    on<ProductsRequested>(_onProductsRequested);
    on<ProductsRefreshed>(_onProductsRefreshed);
    on<MoreProductsRequested>(_onMoreProductsRequested);

    // Retained for compatibility with existing events.
    on<NextProductsPageRequested>(_onNextPageRequested);
    on<PreviousProductsPageRequested>(_onPreviousPageRequested);

    on<ProductCategoriesRequested>(_onProductCategoriesRequested);
    on<ProductCategorySelected>(_onProductCategorySelected);

    on<ProductSearchChanged>(
      _onProductSearchChanged,
      transformer: (events, mapper) =>
          events.debounce(const Duration(milliseconds: 400)).switchMap(mapper),
    );

    on<ProductSortChanged>(_onProductSortChanged);
    on<ProductFiltersChanged>(_onProductFiltersChanged);
    on<ProductFiltersCleared>(_onProductFiltersCleared);
  }

  final GetProductsUseCase _getProductsUseCase;
  final GetProductCategoriesUseCase _getProductCategoriesUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  final SearchProductsUseCase _searchProductsUseCase;

  static const int _pageSize = ProductState.pageSize;

  Future<List<Product>> _fetchProducts({
    required String? categorySlug,
    required String query,
    required int skip,
  }) async {
    if (query.isNotEmpty) {
      return _searchProductsUseCase(query: query, limit: _pageSize, skip: skip);
    }

    if (categorySlug != null) {
      return _getProductsByCategoryUseCase(
        categorySlug: categorySlug,
        limit: _pageSize,
        skip: skip,
      );
    }

    return _getProductsUseCase(limit: _pageSize, skip: skip);
  }

  List<Product> _applyLocalFiltersAndSort(List<Product> products) {
    final minPrice = state.minPrice;
    final maxPrice = state.maxPrice;
    final minRating = state.minRating;

    final filtered = products.where((product) {
      if (minPrice != null && product.price < minPrice) return false;
      if (maxPrice != null && product.price > maxPrice) return false;
      if (minRating != null && product.rating < minRating) return false;
      return true;
    }).toList();

    switch (state.sortOption) {
      case ProductSortOption.defaultOrder:
        break;
      case ProductSortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case ProductSortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
      case ProductSortOption.ratingHighToLow:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
      case ProductSortOption.titleAToZ:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }

    return filtered;
  }

  Future<void> _loadPage(
    Emitter<ProductState> emit, {
    required int page,
    bool resetOnFailure = false,
  }) async {
    emit(
      state.copyWith(
        status: ProductStatus.loading,
        currentPage: page,
        clearErrorMessage: true,
        isLoadingMore: false,
      ),
    );

    try {
      final products = await _fetchProducts(
        categorySlug: state.selectedCategorySlug,
        query: state.searchQuery,
        skip: (page - 1) * _pageSize,
      );

      debugPrint(
        'PAGE LOADED: page=$page, products=${products.length}, '
        'skip=${(page - 1) * _pageSize}',
      );

      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: _applyLocalFiltersAndSort(products),
          currentPage: page,
          hasReachedMax: products.length < _pageSize,
          isLoadingMore: false,
          clearErrorMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Product loading failed: $error\n$stackTrace');

      emit(
        state.copyWith(
          status: ProductStatus.failure,
          currentPage: resetOnFailure ? 1 : state.currentPage,
          errorMessage: error.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onProductsRequested(
    ProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state.status == ProductStatus.loading) return;
    await _loadPage(emit, page: 1, resetOnFailure: true);
  }

  Future<void> _onProductsRefreshed(
    ProductsRefreshed event,
    Emitter<ProductState> emit,
  ) async {
    await _loadPage(emit, page: 1, resetOnFailure: true);
  }

  Future<void> _onMoreProductsRequested(
    MoreProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state.status != ProductStatus.success ||
        state.isLoadingMore ||
        state.hasReachedMax) {
      return;
    }

    final nextPage = state.currentPage + 1;

    emit(state.copyWith(isLoadingMore: true, clearErrorMessage: true));

    try {
      final newProducts = await _fetchProducts(
        categorySlug: state.selectedCategorySlug,
        query: state.searchQuery,
        skip: (nextPage - 1) * _pageSize,
      );

      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: _applyLocalFiltersAndSort([
            ...state.products,
            ...newProducts,
          ]),
          currentPage: nextPage,
          hasReachedMax: newProducts.length < _pageSize,
          isLoadingMore: false,
          clearErrorMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Loading more products failed: $error\n$stackTrace');

      emit(
        state.copyWith(
          status: ProductStatus.success,
          isLoadingMore: false,
          errorMessage: 'Could not load more products. Please try again.',
        ),
      );
    }
  }

  Future<void> _onNextPageRequested(
    NextProductsPageRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state.status != ProductStatus.success ||
        state.isLoadingMore ||
        state.hasReachedMax) {
      return;
    }

    await _loadPage(emit, page: state.currentPage + 1);
  }

  Future<void> _onPreviousPageRequested(
    PreviousProductsPageRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state.status != ProductStatus.success || state.currentPage <= 1) {
      return;
    }

    await _loadPage(emit, page: state.currentPage - 1);
  }

  Future<void> _onProductCategoriesRequested(
    ProductCategoriesRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state.isLoadingCategories || state.categories.isNotEmpty) return;

    emit(
      state.copyWith(
        isLoadingCategories: true,
        clearCategoryErrorMessage: true,
      ),
    );

    try {
      final categories = await _getProductCategoriesUseCase();

      emit(
        state.copyWith(
          categories: categories,
          isLoadingCategories: false,
          clearCategoryErrorMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Loading categories failed: $error\n$stackTrace');

      emit(
        state.copyWith(
          isLoadingCategories: false,
          categoryErrorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onProductCategorySelected(
    ProductCategorySelected event,
    Emitter<ProductState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProductStatus.loading,
        selectedCategorySlug: event.categorySlug,
        clearSelectedCategory: event.categorySlug == null,
        searchQuery: '',
        products: [],
        currentPage: 1,
        hasReachedMax: false,
        isLoadingMore: false,
        clearErrorMessage: true,
      ),
    );

    await _loadPage(emit, page: 1, resetOnFailure: true);
  }

  Future<void> _onProductSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) async {
    final query = event.query.trim();

    emit(
      state.copyWith(
        status: ProductStatus.loading,
        searchQuery: query,
        products: [],
        currentPage: 1,
        hasReachedMax: false,
        isLoadingMore: false,
        clearErrorMessage: true,
      ),
    );

    await _loadPage(emit, page: 1, resetOnFailure: true);
  }

  void _onProductSortChanged(
    ProductSortChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        sortOption: event.sortOption,
        products: _sortProducts(state.products, event.sortOption),
      ),
    );
  }

  List<Product> _sortProducts(
    List<Product> products,
    ProductSortOption option,
  ) {
    final sorted = List<Product>.of(products);

    switch (option) {
      case ProductSortOption.defaultOrder:
        break;
      case ProductSortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case ProductSortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case ProductSortOption.ratingHighToLow:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case ProductSortOption.titleAToZ:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }

    return sorted;
  }

  void _onProductFiltersChanged(
    ProductFiltersChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        minRating: event.minRating,
        products: _applyLocalFiltersAndSort(state.products),
      ),
    );
  }

  void _onProductFiltersCleared(
    ProductFiltersCleared event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        minPrice: null,
        maxPrice: null,
        minRating: null,
        products: _sortProducts(state.products, state.sortOption),
      ),
    );
  }
}
