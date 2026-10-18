import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutRequested extends CheckoutEvent {
  const CheckoutRequested({required this.userId, required this.items});

  final int userId;
  final List<CartItem> items;

  @override
  List<Object?> get props => [userId, items];
}
