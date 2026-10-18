import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/checkout_use_case.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc(this._checkoutUseCase) : super(const CheckoutInitial()) {
    on<CheckoutRequested>(_onCheckoutRequested);
  }

  final CheckoutUseCase _checkoutUseCase;

  Future<void> _onCheckoutRequested(
    CheckoutRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(const CheckoutLoading());

    try {
      final order = await _checkoutUseCase(
        userId: event.userId,
        items: event.items,
      );

      emit(CheckoutSuccess(order));
    } catch (error) {
      emit(CheckoutFailure('Checkout failed. Please try again.'));
    }
  }
}
