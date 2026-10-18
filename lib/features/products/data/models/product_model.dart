import '../../domain/entities/product.dart';
import '../../domain/entities/product_review.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.brand,
    required super.thumbnail,
    required super.images,
    super.reviews = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['reviews'] as List<dynamic>? ?? const [];

    return ProductModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String? ?? 'Unknown',
      thumbnail: json['thumbnail'] as String? ?? '',
      images:
          (json['images'] as List<dynamic>?)?.whereType<String>().toList() ??
          const [],
      reviews: rawReviews
          .whereType<Map<String, dynamic>>()
          .map(
            (review) => ProductReview(
              rating: (review['rating'] as num?)?.toInt() ?? 0,
              comment: review['comment'] as String? ?? '',
              date: review['date'] as String? ?? '',
              reviewerName: review['reviewerName'] as String? ?? 'Anonymous',
              reviewerEmail: review['reviewerEmail'] as String? ?? '',
            ),
          )
          .toList(),
    );
  }
}
