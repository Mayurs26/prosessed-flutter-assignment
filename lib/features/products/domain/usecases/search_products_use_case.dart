import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  const SearchProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call({
    required String query,
    int limit = 20,
    int skip = 0,
  }) {
    return _repository.searchProducts(query: query, limit: limit, skip: skip);
  }
}
