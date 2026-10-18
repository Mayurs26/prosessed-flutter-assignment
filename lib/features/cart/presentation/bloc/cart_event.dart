import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartItemAdded extends CartEvent {
  const CartItemAdded(this.item);

  final CartItem item;

  @override
  List<Object?> get props => [item];
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

class CartQuantityUpdated extends CartEvent {
  const CartQuantityUpdated({required this.productId, required this.quantity});

  final int productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartLoaded extends CartEvent {
  const CartLoaded();
}
