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
  static const Color _ink = Color(0xFF172B2A);
  static const Color _muted = Color(0xFF71817D);
  static const Color _canvas = Color(0xFFF5F7F2);
  static const Color _mint = Color(0xFFDDF36A);
  static const Color _green = Color(0xFF245D50);
  static const Color _line = Color(0xFFE3E9E1);
  static const Color _coral = Color(0xFFDF7657);

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
    setState(() => _productFuture = _fetchProduct());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton.filledTonal(
            tooltip: 'Go back',
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: const Column(
          children: [
            Text(
              'THE EDIT',
              style: TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.1,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'PRODUCT STORY',
              style: TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: 'Shopping cart',
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Your cart is available from the cart tab.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _green),
            );
          }

          if (snapshot.hasError) {
            final isNotFound = snapshot.error is NotFoundFailure;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 76,
                        width: 76,
                        decoration: const BoxDecoration(
                          color: _canvas,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isNotFound
                              ? Icons.search_off_rounded
                              : Icons.wifi_off_rounded,
                          color: _green,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isNotFound
                            ? 'A little hard to find'
                            : 'Lost the connection?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isNotFound
                            ? 'This product may no longer be available.'
                            : 'Check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _muted,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _retryLoading,
                        style: FilledButton.styleFrom(
                          backgroundColor: _ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
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
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                  children: [
                    _buildImageGallery(images, product),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.category.replaceAll('-', ' ').toUpperCase(),
                            style: const TextStyle(
                              color: _green,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ),
                        if (product.discountPercentage > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE7DE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                              style: const TextStyle(
                                color: _coral,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      product.title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 29,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _metaPill(
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFE7A72D),
                          label:
                              '${product.rating}  ·  ${product.reviews.length} reviews',
                        ),
                        _metaPill(
                          icon: product.stock > 0
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          iconColor: product.stock > 0
                              ? _green
                              : const Color(0xFFD84D4D),
                          label: product.stock > 0
                              ? '${product.stock} in stock'
                              : 'Out of stock',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _buildPriceBrandCard(product, discountPrice),
                    const SizedBox(height: 29),
                    _sectionTitle('A closer look', 'ABOUT THE PRODUCT'),
                    const SizedBox(height: 11),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 14,
                        height: 1.75,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _sectionTitle('Kind words', 'CUSTOMER NOTES'),
                    const SizedBox(height: 13),
                    if (product.reviews.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _line),
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

  Widget _buildImageGallery(List<String> images, Product product) {
    return Container(
      height: 310,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDE3),
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -52,
            top: -65,
            child: Container(
              height: 190,
              width: 190,
              decoration: const BoxDecoration(
                color: Color(0xFFD8E5CE),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -45,
            bottom: -76,
            child: Container(
              height: 170,
              width: 170,
              decoration: const BoxDecoration(
                color: Color(0xFFDDE5D7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _selectedImageIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(26, 45, 26, 34),
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
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: _green, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'CURATED PICK',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#${product.id.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  color: _mint,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 15,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '${_selectedImageIndex + 1} / ${images.length}',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              left: 17,
              bottom: 19,
              child: Row(
                children: List.generate(images.length, (index) {
                  final selected = index == _selectedImageIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(right: 4),
                    height: 6,
                    width: selected ? 20 : 6,
                    decoration: BoxDecoration(
                      color: selected ? _green : const Color(0xFFB7C4B2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metaPill({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBrandCard(Product product, double discountPrice) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR PRICE',
                  style: TextStyle(
                    color: Color(0xFFB7C7C0),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 7),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\$${discountPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: _mint,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                if (product.discountPercentage > 0)
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFB7C7C0),
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
          Container(height: 56, width: 1, color: Colors.white24),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THE MAKER',
                  style: TextStyle(
                    color: Color(0xFFB7C7C0),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
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
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String eyebrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _green,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: _canvas,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              review.reviewerName.isNotEmpty
                  ? review.reviewerName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: _green,
                fontWeight: FontWeight.w900,
                fontSize: 17,
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
                    color: _ink,
                    fontWeight: FontWeight.w900,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFE7A72D),
                  size: 14,
                ),
                const SizedBox(width: 3),
                Text(
                  '${review.rating}',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Product product, double discountPrice) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: _line)),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _canvas,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _line),
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
                    icon: const Icon(Icons.remove_rounded, size: 18),
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Increase quantity',
                    visualDensity: VisualDensity.compact,
                    onPressed: _quantity < product.stock
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: const Icon(Icons.add_rounded, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: FilledButton(
                onPressed: product.stock > 0 ? () => _addToCart(product) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  disabledBackgroundColor: const Color(0xFFE3E8E1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 19),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        product.stock > 0 ? 'Add to bag' : 'Out of stock',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (product.stock > 0) ...[
                      const SizedBox(width: 9),
                      const Icon(Icons.arrow_forward_rounded, size: 17),
                    ],
                  ],
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
          backgroundColor: _ink,
          action: SnackBarAction(
            label: 'OK',
            textColor: _mint,
            onPressed: () {},
          ),
        ),
      );
  }
}
