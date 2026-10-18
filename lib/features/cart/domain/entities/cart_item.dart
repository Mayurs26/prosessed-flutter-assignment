import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get originalTotal => product.price * quantity;

  double get discountedTotal =>
      product.price * (1 - product.discountPercentage / 100) * quantity;

  double get discountAmount => originalTotal - discountedTotal;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  @override
  List<Object?> get props => [product, quantity];
}
