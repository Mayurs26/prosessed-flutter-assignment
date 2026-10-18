import '../../domain/entities/product_category.dart';

class ProductCategoryModel extends ProductCategory {
  const ProductCategoryModel({required super.slug, required super.name});

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
