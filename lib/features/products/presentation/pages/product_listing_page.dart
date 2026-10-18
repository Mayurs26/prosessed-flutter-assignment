import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

import 'package:go_router/go_router.dart';

import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_state.dart';

class ProductListingPage extends StatelessWidget {
  const ProductListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()
        ..add(const ProductsRequested())
        ..add(const ProductCategoriesRequested()),
      child: const _ProductListingView(),
    );
  }
}

class _ProductListingView extends StatefulWidget {
  const _ProductListingView();

  @override
  State<_ProductListingView> createState() => _ProductListingViewState();
}

class _ProductListingViewState extends State<_ProductListingView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDFF),
      appBar: AppBar(
        title: const Text(
          'ShopSphere',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),

        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              return IconButton(
                tooltip: 'Shopping cart (${cartState.totalItems} items)',
                onPressed: () => context.push('/cart'),
                icon: Badge(
                  isLabelVisible: cartState.totalItems > 0,
                  label: Text('${cartState.totalItems}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());

                context.read<ProductBloc>().add(
                  ProductSearchChanged(value.trim()),
                );
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();

                          setState(() => _searchQuery = '');

                          context.read<ProductBloc>().add(
                            const ProductSearchChanged(''),
                          );
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: const Color(0xFFF3F1FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state.isLoadingCategories && state.categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                );
              }

              if (state.categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                height: 54,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  children: [
                    ChoiceChip(
                      label: const Text('All Products'),
                      selected: state.selectedCategorySlug == null,
                      onSelected: (_) {
                        _searchController.clear();
                        setState(() => _searchQuery = '');

                        context.read<ProductBloc>().add(
                          const ProductCategorySelected(null),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    ...state.categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category.name),
                          selected: state.selectedCategorySlug == category.slug,
                          onSelected: (_) {
                            _searchController.clear();
                            setState(() => _searchQuery = '');

                            context.read<ProductBloc>().add(
                              ProductCategorySelected(category.slug),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state.status == ProductStatus.loading &&
                    state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ProductStatus.failure &&
                    state.products.isEmpty) {
                  return _ErrorView(
                    message: state.errorMessage ?? 'Unable to load products.',
                    onRetry: () => context.read<ProductBloc>().add(
                      const ProductsRequested(),
                    ),
                  );
                }

                final products = state.products;

                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductBloc>().add(const ProductsRefreshed());
                    await Future<void>.delayed(
                      const Duration(milliseconds: 500),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final columns = width < 600
                                ? 2
                                : width < 1024
                                ? 3
                                : 4;

                            return GridView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: products.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: width < 600 ? 0.62 : 0.78,
                                  ),
                              itemBuilder: (context, index) {
                                return _ProductCard(product: products[index]);
                              },
                            );
                          },
                        ),
                      ),

                      // Pagination controls
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed:
                                  state.currentPage > 1 &&
                                      state.status != ProductStatus.loading
                                  ? () {
                                      context.read<ProductBloc>().add(
                                        const PreviousProductsPageRequested(),
                                      );
                                      if (_scrollController.hasClients) {
                                        _scrollController.jumpTo(0);
                                      }
                                    }
                                  : null,
                              child: const Text('Previous'),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Page ${state.currentPage}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed:
                                  !state.hasReachedMax &&
                                      state.status != ProductStatus.loading
                                  ? () {
                                      context.read<ProductBloc>().add(
                                        const NextProductsPageRequested(),
                                      );
                                      if (_scrollController.hasClients) {
                                        _scrollController.jumpTo(0);
                                      }
                                    }
                                  : null,
                              child: const Text('Next'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFEAE8F5)),
      ),
      child: InkWell(
        onTap: () {
          context.push('/product-details', extra: product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF6F4FF),
                padding: const EdgeInsets.all(10),
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 15, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF5035FF),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
