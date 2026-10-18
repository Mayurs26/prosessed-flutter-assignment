import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class CheckoutUseCase {
  CheckoutUseCase(this._repository);

  final CartRepository _repository;

  Future<Map<String, dynamic>> call({
    required int userId,
    required List<CartItem> items,
  }) {
    if (items.isEmpty) {
      throw ArgumentError('Cannot checkout with an empty cart.');
    }

    return _repository.checkout(userId: userId, items: items);
  }
}
