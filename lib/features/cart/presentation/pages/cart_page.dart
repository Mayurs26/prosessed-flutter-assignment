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

  static const Color _purple = Color(0xFF7957F5);
  static const Color _deepPurple = Color(0xFF7957F5);
  static const Color _background = Color(0xFFFAFAFD);

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
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(checkoutState.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        child: Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            surfaceTintColor: Colors.transparent,
            title: const Text(
              'My Cart',
              style: TextStyle(fontWeight: FontWeight.w900, color: _deepPurple),
            ),
            centerTitle: false,
          ),
          body: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: _purple),
                );
              }

              if (state.isEmpty) {
                return _EmptyCart(
                  onContinueShopping: () => context.go('/products'),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8B6CF6),
                                Color(0xFF7957F5),
                                Color(0xFFA58BFF),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your shopping bag',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${state.totalItems} ${state.totalItems == 1 ? 'item' : 'items'} ready for checkout',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.78,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Cart items',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _deepPurple,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...state.items.map((item) {
                          final product = item.product;

                          return _CartItemCard(
                            imageUrl: product.thumbnail,
                            title: product.title,
                            price: item.discountedTotal,
                            quantity: item.quantity,
                            stock: product.stock,
                            onDecrease: () {
                              context.read<CartBloc>().add(
                                CartQuantityUpdated(
                                  productId: product.id,
                                  quantity: item.quantity - 1,
                                ),
                              );
                            },
                            onIncrease: item.quantity < product.stock
                                ? () {
                                    context.read<CartBloc>().add(
                                      CartQuantityUpdated(
                                        productId: product.id,
                                        quantity: item.quantity + 1,
                                      ),
                                    );
                                  }
                                : null,
                            onRemove: () {
                              context.read<CartBloc>().add(
                                CartItemRemoved(product.id),
                              );
                            },
                          );
                        }),
                      ],
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
                            behavior: SnackBarBehavior.floating,
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

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onContinueShopping});

  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFECE8FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDCD4FF)),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 68,
                color: Color(0xFF5035FF),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Your cart is waiting',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF21165C),
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Looks like you haven’t added anything yet. '
              'Explore our collection and find something you love.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF858197),
                height: 1.6,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: onContinueShopping,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Continue Shopping'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8B6CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.quantity,
    required this.stock,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final String imageUrl;
  final String title;
  final double price;
  final int quantity;
  final int stock;
  final VoidCallback onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECE9F7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF21165C).withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 112,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(17),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 34,
                  color: Color(0xFF9B93B9),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF292442),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove item',
                      onPressed: onRemove,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 21,
                        color: Color(0xFFE25564),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF5035FF),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove_rounded,
                      onPressed: onDecrease,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF21165C),
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add_rounded,
                      onPressed: onIncrease,
                    ),
                    const Spacer(),
                    if (quantity >= stock && stock > 0)
                      const Tooltip(
                        message: 'Maximum available stock reached',
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 17,
                          color: Color(0xFF858197),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: icon == Icons.add_rounded
            ? 'Increase quantity'
            : 'Decrease quantity',
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFECE8FF),
          foregroundColor: const Color(0xFF5035FF),
          disabledBackgroundColor: const Color(0xFFF0EEF5),
          disabledForegroundColor: const Color(0xFFB8B4C7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, size: 19),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF21165C).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 19, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 42,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E3F2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _SummaryRow(label: 'Subtotal', value: subtotal),
              const SizedBox(height: 12),
              _SummaryRow(
                label: 'You save',
                value: -discount,
                valueColor: const Color(0xFF198754),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: Color(0xFFECE9F7), height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grand total',
                        style: TextStyle(
                          color: Color(0xFF858197),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Total to pay',
                        style: TextStyle(
                          color: Color(0xFF21165C),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF5035FF),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<CheckoutBloc, CheckoutState>(
                builder: (context, checkoutState) {
                  final isLoading = checkoutState is CheckoutLoading;

                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: isLoading ? null : onCheckout,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8B6CF6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFBDB3FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline_rounded, size: 19),
                                SizedBox(width: 10),
                                Text('Proceed to Checkout'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 19),
                              ],
                            ),
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
  });

  final String label;
  final double value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF858197),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value < 0 ? '-\$' : '\$'}${value.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: valueColor ?? const Color(0xFF292442),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
