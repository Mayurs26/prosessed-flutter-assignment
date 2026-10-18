import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategoryUseCase {
  const GetProductsByCategoryUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
  }) {
    return _repository.getProductsByCategory(
      categorySlug: categorySlug,
      limit: limit,
      skip: skip,
    );
  }
}
