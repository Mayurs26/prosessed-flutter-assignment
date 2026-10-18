import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/cart_local_data_source.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._localDataSource) : super(const CartState()) {
    on<CartLoaded>(_onCartLoaded);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartQuantityUpdated>(_onQuantityUpdated);
    on<CartCleared>(_onCartCleared);
  }

  final CartLocalDataSource _localDataSource;

  Future<void> _onCartLoaded(CartLoaded event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final items = _localDataSource.getCart();
      emit(state.copyWith(items: items, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere(
      (item) => item.product.id == event.item.product.id,
    );

    if (index >= 0) {
      final existing = items[index];
      final newQuantity = existing.quantity + event.item.quantity;

      items[index] = existing.copyWith(
        quantity: newQuantity > existing.product.stock
            ? existing.product.stock
            : newQuantity,
      );
    } else if (event.item.product.stock > 0) {
      final quantity = event.item.quantity > event.item.product.stock
          ? event.item.product.stock
          : event.item.quantity;

      if (quantity > 0) {
        items.add(event.item.copyWith(quantity: quantity));
      }
    }

    await _saveAndEmit(items, emit);
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final items = state.items
        .where((item) => item.product.id != event.productId)
        .toList();

    await _saveAndEmit(items, emit);
  }

  Future<void> _onQuantityUpdated(
    CartQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    final items = state.items
        .map((item) {
          if (item.product.id != event.productId) return item;

          final quantity = event.quantity.clamp(0, item.product.stock).toInt();

          return item.copyWith(quantity: quantity);
        })
        .where((item) => item.quantity > 0)
        .toList();

    await _saveAndEmit(items, emit);
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    await _localDataSource.clearCart();
    emit(const CartState());
  }

  Future<void> _saveAndEmit(
    List<CartItem> items,
    Emitter<CartState> emit,
  ) async {
    await _localDataSource.saveCart(items);
    emit(state.copyWith(items: items));
  }
}
