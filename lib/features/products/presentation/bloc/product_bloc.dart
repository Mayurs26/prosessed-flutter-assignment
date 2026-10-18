import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_use_case.dart';
import '../../domain/usecases/get_product_categories_use_case.dart';
import '../../domain/usecases/get_products_by_category_use_case.dart';
import '../../domain/usecases/search_products_use_case.dart';
import 'product_event.dart';
import 'product_state.dart';

import 'package:flutter/foundation.dart';

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
    on<NextProductsPageRequested>(_onNextPageRequested);
    on<PreviousProductsPageRequested>(_onPreviousPageRequested);
    on<ProductCategoriesRequested>(_onProductCategoriesRequested);
    on<ProductCategorySelected>(_onProductCategorySelected);

    on<ProductSearchChanged>(
      _onProductSearchChanged,
      transformer: (events, mapper) =>
          events.debounce(const Duration(milliseconds: 400)).switchMap(mapper),
    );
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
        'PAGE LOADED: page=$page, '
        'products=${products.length}, '
        'skip=${(page - 1) * _pageSize}',
      );

      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: products,
          currentPage: page,
          hasReachedMax: products.length < _pageSize,
          isLoadingMore: false,
          clearErrorMessage: true,
        ),
      );
      debugPrint(
        'STATE UPDATED: page=${state.currentPage}, '
        'status=${state.status}, '
        'products=${state.products.length}',
      );
    } catch (error) {
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

  Future<void> _onNextPageRequested(
    NextProductsPageRequested event,
    Emitter<ProductState> emit,
  ) async {
    debugPrint(
      'NEXT CLICK: page=${state.currentPage}, '
      'status=${state.status}, '
      'hasReachedMax=${state.hasReachedMax}, '
      'products=${state.products.length}',
    );

    if (state.status != ProductStatus.success || state.hasReachedMax) {
      debugPrint('NEXT BLOCKED');
      return;
    }

    debugPrint('Loading page ${state.currentPage + 1}');
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

  // Kept temporarily for compatibility; the listing UI should no longer
  // dispatch this event when numbered pagination is enabled.
  Future<void> _onMoreProductsRequested(
    MoreProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    // Intentionally empty: numbered pagination replaces infinite scrolling.
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
    } catch (error) {
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
}
