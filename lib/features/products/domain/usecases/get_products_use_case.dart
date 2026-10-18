import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call({int limit = 20, int skip = 0}) {
    return _repository.getProducts(limit: limit, skip: skip);
  }
}
