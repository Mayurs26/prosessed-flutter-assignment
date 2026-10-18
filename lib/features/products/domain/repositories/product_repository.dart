import '../entities/product.dart';
import '../entities/product_category.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({required int limit, required int skip});

  Future<List<ProductCategory>> getCategories();

  Future<List<Product>> getProductsByCategory({
    required String categorySlug,
    required int limit,
    required int skip,
  });

  Future<List<Product>> searchProducts({
    required String query,
    required int limit,
    required int skip,
  });
}
