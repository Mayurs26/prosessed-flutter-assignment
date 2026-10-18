import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CheckoutBloc>(
      create: (_) => getIt<CheckoutBloc>(),
      child: BlocListener<CheckoutBloc, CheckoutState>(
        listener: (context, checkoutState) {
          if (checkoutState is CheckoutSuccess) {
            context.read<CartBloc>().add(const CartCleared());
            context.go('/checkout-success');
          } else if (checkoutState is CheckoutFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(checkoutState.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('My Cart')),
          body: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 72,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('Add some products to get started.'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Continue Shopping'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        final product = item.product;

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.thumbnail,
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const SizedBox(
                                      width: 84,
                                      height: 84,
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '\$${item.discountedTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5035FF),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 4,
                                        children: [
                                          IconButton(
                                            tooltip: 'Decrease quantity',
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () {
                                              context.read<CartBloc>().add(
                                                CartQuantityUpdated(
                                                  productId: product.id,
                                                  quantity: item.quantity - 1,
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                          ),
                                          Text('${item.quantity}'),
                                          IconButton(
                                            tooltip: 'Increase quantity',
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed:
                                                item.quantity < product.stock
                                                ? () {
                                                    context
                                                        .read<CartBloc>()
                                                        .add(
                                                          CartQuantityUpdated(
                                                            productId:
                                                                product.id,
                                                            quantity:
                                                                item.quantity +
                                                                1,
                                                          ),
                                                        );
                                                  }
                                                : null,
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Remove item',
                                            onPressed: () {
                                              context.read<CartBloc>().add(
                                                CartItemRemoved(product.id),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  _CartSummary(
                    subtotal: state.subtotal,
                    discount: state.totalDiscount,
                    total: state.grandTotal,
                    onCheckout: () {
                      final authState = context.read<AuthBloc>().state;

                      if (authState is! AuthSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in again to checkout.'),
                          ),
                        );
                        return;
                      }

                      context.read<CheckoutBloc>().add(
                        CheckoutRequested(
                          userId: authState.session.id,
                          items: state.items,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.onCheckout,
  });

  final double subtotal;
  final double discount;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SummaryRow(label: 'Subtotal', value: subtotal),
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Discount',
                value: -discount,
                valueColor: Colors.green,
              ),
              const Divider(height: 24),
              _SummaryRow(label: 'Grand Total', value: total, isTotal: true),
              const SizedBox(height: 16),

              BlocBuilder<CheckoutBloc, CheckoutState>(
                builder: (context, checkoutState) {
                  final isLoading = checkoutState is CheckoutLoading;

                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : onCheckout,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Proceed to Checkout'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? Theme.of(context).textTheme.titleMedium : null,
        ),
        Text(
          '${value < 0 ? '-\$' : '\$'}${value.abs().toStringAsFixed(2)}',
          style:
              (isTotal
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.bodyLarge)
                  ?.copyWith(
                    color: valueColor,
                    fontWeight: isTotal ? FontWeight.bold : null,
                  ),
        ),
      ],
    );
  }
}
