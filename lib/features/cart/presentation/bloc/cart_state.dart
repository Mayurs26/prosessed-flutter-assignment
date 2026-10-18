import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';

class CartState extends Equatable {
  const CartState({this.items = const [], this.isLoading = false});

  final List<CartItem> items;
  final bool isLoading;

  int get totalItems => items.fold(0, (total, item) => total + item.quantity);

  double get subtotal =>
      items.fold(0, (total, item) => total + item.originalTotal);

  double get totalDiscount =>
      items.fold(0, (total, item) => total + item.discountAmount);

  double get grandTotal =>
      items.fold(0, (total, item) => total + item.discountedTotal);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items, bool? isLoading}) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [items, isLoading];
}
