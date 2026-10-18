import 'package:equatable/equatable.dart';

enum ProductSortOption {
  defaultOrder,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
  titleAToZ,
}

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductsRequested extends ProductEvent {
  const ProductsRequested();
}

class ProductsRefreshed extends ProductEvent {
  const ProductsRefreshed();
}

class MoreProductsRequested extends ProductEvent {
  const MoreProductsRequested();
}

class ProductCategoriesRequested extends ProductEvent {
  const ProductCategoriesRequested();
}

class ProductCategorySelected extends ProductEvent {
  const ProductCategorySelected(this.categorySlug);

  final String? categorySlug;

  @override
  List<Object?> get props => [categorySlug];
}

class ProductSearchChanged extends ProductEvent {
  const ProductSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class NextProductsPageRequested extends ProductEvent {
  const NextProductsPageRequested();
}

class PreviousProductsPageRequested extends ProductEvent {
  const PreviousProductsPageRequested();
}

class ProductSortChanged extends ProductEvent {
  const ProductSortChanged(this.sortOption);

  final ProductSortOption sortOption;

  @override
  List<Object?> get props => [sortOption];
}

class ProductFiltersChanged extends ProductEvent {
  const ProductFiltersChanged({this.minPrice, this.maxPrice, this.minRating});

  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  @override
  List<Object?> get props => [minPrice, maxPrice, minRating];
}

class ProductFiltersCleared extends ProductEvent {
  const ProductFiltersCleared();
}
