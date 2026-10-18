import '../../domain/entities/cart_item.dart';

abstract class CartRepository {
  Future<Map<String, dynamic>> checkout({
    required int userId,
    required List<CartItem> items,
  });
}
