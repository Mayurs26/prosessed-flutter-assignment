import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_by_id_use_case.dart';
import '../../../../core/error/failure.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProduct();
  }

  Future<Product> _fetchProduct() {
    return getIt<GetProductByIdUseCase>()(widget.product.id);
  }

  void _retryLoading() {
    setState(() {
      _productFuture = _fetchProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final isNotFound = error is NotFoundFailure;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNotFound ? Icons.search_off : Icons.wifi_off,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isNotFound
                          ? 'Product not found'
                          : 'Unable to load product details.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _retryLoading,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Product details unavailable.'));
          }

          final product = snapshot.data!;
          final images = product.images.isNotEmpty
              ? product.images
              : [product.thumbnail];

          final discountPrice =
              product.price * (1 - product.discountPercentage / 100);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _selectedImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (images.length > 1) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      '${_selectedImageIndex + 1} / ${images.length}',
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.brand.trim().isEmpty
                      ? 'Brand not available'
                      : 'Brand: ${product.brand}',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${product.rating}'),
                    const SizedBox(width: 12),
                    Text(
                      product.stock > 0
                          ? 'In Stock (${product.stock} available)'
                          : 'Out of Stock',
                      style: TextStyle(
                        color: product.stock > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '\$${discountPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5035FF),
                      ),
                    ),
                    if (product.discountPercentage > 0) ...[
                      const SizedBox(width: 10),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(product.description),
                const SizedBox(height: 20),
                Text(
                  'Customer Reviews (${product.reviews.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (product.reviews.isEmpty)
                  const Text('No reviews available.')
                else
                  ...product.reviews.map(
                    (review) => Card(
                      child: ListTile(
                        title: Text(review.reviewerName),
                        subtitle: Text(review.comment),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text('${review.rating}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Decrease quantity',
                      onPressed: _quantity > 1 && product.stock > 0
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      tooltip: 'Increase quantity',
                      onPressed: _quantity < product.stock
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: product.stock > 0
                          ? () {
                              context.read<CartBloc>().add(
                                CartItemAdded(
                                  CartItem(
                                    product: product,
                                    quantity: _quantity,
                                  ),
                                ),
                              );

                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.title} added to cart',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'OK',
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                            }
                          : null,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
