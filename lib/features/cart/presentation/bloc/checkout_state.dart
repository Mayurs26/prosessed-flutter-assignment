import 'package:equatable/equatable.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.order);

  final Map<String, dynamic> order;

  @override
  List<Object?> get props => [order];
}

class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
