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
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton.filledTonal(
            tooltip: 'Go back',
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: colors.surfaceContainerLow,
              foregroundColor: colors.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: Column(
          children: [
            Text(
              'THE EDIT',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.1,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'PRODUCT STORY',
              style: TextStyle(
                color: colors.onSurfaceVariant,
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
            padding: EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: 'Shopping cart',
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        'Your cart is available from the cart tab.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerLow,
                foregroundColor: colors.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          if (snapshot.hasError) {
            final isNotFound = snapshot.error is NotFoundFailure;

            return Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 76,
                        width: 76,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isNotFound
                              ? Icons.search_off_rounded
                              : Icons.wifi_off_rounded,
                          color: colors.primary,
                          size: 34,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        isNotFound
                            ? 'A little hard to find'
                            : 'Lost the connection?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        isNotFound
                            ? 'This product may no longer be available.'
                            : 'Check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _retryLoading,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(Icons.refresh_rounded),
                        label: Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Product details unavailable.'));
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
                  padding: EdgeInsets.fromLTRB(18, 8, 18, 28),
                  children: [
                    _buildImageGallery(images, product),
                    SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.category.replaceAll('-', ' ').toUpperCase(),
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ),
                        if (product.discountPercentage > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 9),
                    Text(
                      product.title,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 29,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.1,
                      ),
                    ),
                    SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _metaPill(
                          context: context,
                          icon: Icons.star_rounded,
                          iconColor: Color(0xFFE7A72D),
                          label:
                              '${product.rating}  ·  ${product.reviews.length} reviews',
                        ),
                        _metaPill(
                          context: context,
                          icon: product.stock > 0
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          iconColor: product.stock > 0
                              ? colors.primary
                              : colors.error,
                          label: product.stock > 0
                              ? '${product.stock} in stock'
                              : 'Out of stock',
                        ),
                      ],
                    ),
                    SizedBox(height: 22),
                    _buildPriceBrandCard(product, discountPrice),
                    SizedBox(height: 29),
                    _sectionTitle('A closer look', 'ABOUT THE PRODUCT'),
                    SizedBox(height: 11),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.75,
                      ),
                    ),
                    SizedBox(height: 30),
                    _sectionTitle('Kind words', 'CUSTOMER NOTES'),
                    SizedBox(height: 13),
                    if (product.reviews.isEmpty)
                      Container(
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Text(
                          'No reviews available yet.',
                          style: TextStyle(color: colors.onSurfaceVariant),
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
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 310,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
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
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
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
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
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
                  padding: EdgeInsets.fromLTRB(26, 45, 26, 34),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: colors.onSurfaceVariant,
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
              padding: EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: colors.primary,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'CURATED PICK',
                    style: TextStyle(
                      color: colors.onSurface,
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
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colors.onSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#${product.id.toString().padLeft(3, '0')}',
                style: TextStyle(
                  color: colors.primary,
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
                padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '${_selectedImageIndex + 1} / ${images.length}',
                  style: TextStyle(
                    color: colors.onSurface,
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
                    duration: Duration(milliseconds: 220),
                    margin: EdgeInsets.only(right: 4),
                    height: 6,
                    width: selected ? 20 : 6,
                    decoration: BoxDecoration(
                      color: selected ? colors.primary : colors.outline,
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
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBrandCard(Product product, double discountPrice) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR PRICE',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 7),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\$${discountPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                if (product.discountPercentage > 0)
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colors.onInverseSurface.withValues(alpha: 0.75),
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 56,
            width: 1,
            color: colors.onSurface.withValues(alpha: 0.24),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE MAKER',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  product.brand.trim().isEmpty
                      ? 'Not available'
                      : product.brand,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
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
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            color: colors.primary,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(dynamic review) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 11),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              review.reviewerName.isNotEmpty
                  ? review.reviewerName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.reviewerName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  review.comment,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: colors.tertiaryContainer,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFE7A72D), size: 14),
                SizedBox(width: 3),
                Text(
                  '${review.rating}',
                  style: TextStyle(
                    color: colors.onSurface,
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
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 13, 18, 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: Offset(0, -7),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant),
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
                    icon: Icon(Icons.remove_rounded, size: 18),
                  ),
                  Text(
                    '$_quantity',
                    style: TextStyle(
                      color: colors.onSurface,
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
                    icon: Icon(Icons.add_rounded, size: 18),
                  ),
                ],
              ),
            ),
            SizedBox(width: 11),
            Expanded(
              child: FilledButton(
                onPressed: product.stock > 0 ? () => _addToCart(product) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  disabledBackgroundColor: colors.surfaceContainerHigh,
                  foregroundColor: colors.onPrimary,
                  minimumSize: Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 19),
                    SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        product.stock > 0 ? 'Add to bag' : 'Out of stock',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (product.stock > 0) ...[
                      SizedBox(width: 9),
                      Icon(Icons.arrow_forward_rounded, size: 17),
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
    final colors = Theme.of(context).colorScheme;
    context.read<CartBloc>().add(
      CartItemAdded(CartItem(product: product, quantity: _quantity)),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.title} added to cart'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.primary,
          action: SnackBarAction(
            label: 'OK',
            textColor: colors.onPrimary,
            onPressed: () {},
          ),
        ),
      );
  }
}
