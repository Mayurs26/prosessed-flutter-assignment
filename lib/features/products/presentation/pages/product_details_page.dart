import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_by_id_use_case.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  static const Color _purple = Color(0xFF7957F5);
  static const Color _lavender = Color(0xFFF2EEFF);
  static const Color _background = Color(0xFFFAF9FD);
  static const Color _text = Color(0xFF302B3D);
  static const Color _muted = Color(0xFF858091);
  static const Color _border = Color(0xFFECE8F4);

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
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: _text,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Shopping cart',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your cart is available from the cart tab.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _purple),
            );
          }

          if (snapshot.hasError) {
            final isNotFound = snapshot.error is NotFoundFailure;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: _lavender,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isNotFound
                            ? Icons.search_off_rounded
                            : Icons.wifi_off_rounded,
                        color: _purple,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isNotFound
                          ? 'Product not found'
                          : 'Couldn’t load product',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isNotFound
                          ? 'This product may no longer be available.'
                          : 'Check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _retryLoading,
                      style: FilledButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 13,
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
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

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  children: [
                    _buildImageGallery(images),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.category.replaceAll('-', ' ').toUpperCase(),
                            style: const TextStyle(
                              color: _purple,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        if (product.discountPercentage > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0E8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                              style: const TextStyle(
                                color: Color(0xFFD96A35),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 25,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: _text,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: Color(0xFFFFB547),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toString(),
                          style: const TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${product.reviews.length} reviews)',
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                        const Spacer(),
                        Icon(
                          product.stock > 0
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 15,
                          color: product.stock > 0
                              ? const Color(0xFF27966B)
                              : const Color(0xFFE05252),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          product.stock > 0
                              ? '${product.stock} in stock'
                              : 'Out of stock',
                          style: TextStyle(
                            color: product.stock > 0
                                ? const Color(0xFF27966B)
                                : const Color(0xFFE05252),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PRICE',
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '\$${discountPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: _purple,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (product.discountPercentage > 0)
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: _muted,
                                      fontSize: 13,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(height: 48, width: 1, color: _border),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'BRAND',
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  product.brand.trim().isEmpty
                                      ? 'Not available'
                                      : product.brand,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    _sectionTitle('About this product'),
                    const SizedBox(height: 10),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 26),

                    _sectionTitle('Customer Reviews'),
                    const SizedBox(height: 12),
                    if (product.reviews.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: const Text(
                          'No reviews available yet.',
                          style: TextStyle(color: _muted),
                        ),
                      )
                    else
                      ...product.reviews.map(_buildReviewCard),
                  ],
                ),
              ),
              _buildBottomBar(product, discountPrice),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return Column(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _lavender,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_outlined, color: _purple, size: 15),
                      SizedBox(width: 5),
                      Text(
                        'Quality pick',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => _selectedImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(28),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: _muted,
                      ),
                    ),
                  );
                },
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedImageIndex + 1} / ${images.length}',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final selected = index == _selectedImageIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: selected ? 22 : 6,
                decoration: BoxDecoration(
                  color: selected ? _purple : const Color(0xFFDCD5F1),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _text,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: _lavender,
            child: Text(
              review.reviewerName.isNotEmpty
                  ? review.reviewerName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: _purple,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.reviewerName,
                  style: const TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  review.comment,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB547),
                size: 17,
              ),
              const SizedBox(width: 3),
              Text(
                '${review.rating}',
                style: const TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Product product, double discountPrice) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF30204D).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Decrease quantity',
                    visualDensity: VisualDensity.compact,
                    onPressed: _quantity > 1 && product.stock > 0
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove_rounded, size: 19),
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Increase quantity',
                    visualDensity: VisualDensity.compact,
                    onPressed: _quantity < product.stock
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: const Icon(Icons.add_rounded, size: 19),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: product.stock > 0 ? () => _addToCart(product) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  disabledBackgroundColor: const Color(0xFFE7E3EF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.shopping_bag_outlined, size: 19),
                label: Text(
                  product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    context.read<CartBloc>().add(
      CartItemAdded(CartItem(product: product, quantity: _quantity)),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.title} added to cart'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF373344),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }
}
