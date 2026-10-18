import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

class GetProductCategoriesUseCase {
  const GetProductCategoriesUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<ProductCategory>> call() {
    return _repository.getCategories();
  }
}
