import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategorySlug,
    this.errorMessage,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isLoadingCategories = false,
    this.categoryErrorMessage,
    this.searchQuery = '',
    this.currentPage = 1,
  });

  final ProductStatus status;
  final List<Product> products;
  final List<ProductCategory> categories;
  final String? selectedCategorySlug;
  final String? errorMessage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isLoadingCategories;
  final String? categoryErrorMessage;
  final String searchQuery;
  final int currentPage;

  static const int pageSize = 20;

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    List<ProductCategory>? categories,
    String? selectedCategorySlug,
    bool clearSelectedCategory = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isLoadingCategories,
    String? categoryErrorMessage,
    bool clearCategoryErrorMessage = false,
    String? searchQuery,
    int? currentPage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategorySlug: clearSelectedCategory
          ? null
          : selectedCategorySlug ?? this.selectedCategorySlug,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      categoryErrorMessage: clearCategoryErrorMessage
          ? null
          : categoryErrorMessage ?? this.categoryErrorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    categories,
    selectedCategorySlug,
    errorMessage,
    hasReachedMax,
    isLoadingMore,
    isLoadingCategories,
    categoryErrorMessage,
    searchQuery,
    currentPage,
  ];
}
