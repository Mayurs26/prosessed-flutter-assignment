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

import 'package:shimmer/shimmer.dart';

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
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<ProductBloc>().add(const MoreProductsRequested());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    _searchController.dispose();

    super.dispose();
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
          // Profile avatar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Profile',
              onPressed: () => context.push('/profile'),
              icon: const CircleAvatar(
                radius: 17,
                child: Icon(Icons.person_outline, size: 22),
              ),
            ),
          ),
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

          // Sorting and filtering toolbar
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              final activeFilterCount = [
                state.minPrice != null,
                state.maxPrice != null,
                state.minRating != null,
              ].where((active) => active).length;

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F1FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E0FF)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ProductSortOption>(
                            isExpanded: true,
                            value: state.sortOption,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            borderRadius: BorderRadius.circular(14),
                            hint: const Text('Sort by'),
                            items: const [
                              DropdownMenuItem(
                                value: ProductSortOption.defaultOrder,
                                child: Text('Recommended'),
                              ),
                              DropdownMenuItem(
                                value: ProductSortOption.priceLowToHigh,
                                child: Text('Price: Low to High'),
                              ),
                              DropdownMenuItem(
                                value: ProductSortOption.priceHighToLow,
                                child: Text('Price: High to Low'),
                              ),
                              DropdownMenuItem(
                                value: ProductSortOption.ratingHighToLow,
                                child: Text('Top Rated'),
                              ),
                              DropdownMenuItem(
                                value: ProductSortOption.titleAToZ,
                                child: Text('Name: A to Z'),
                              ),
                            ],
                            onChanged: (option) {
                              if (option == null) return;

                              context.read<ProductBloc>().add(
                                ProductSortChanged(option),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5035FF),
                        side: const BorderSide(color: Color(0xFF5035FF)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final result =
                            await showModalBottomSheet<_ProductFilterValues>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => _ProductFilterSheet(
                                minPrice: state.minPrice,
                                maxPrice: state.maxPrice,
                                minRating: state.minRating,
                              ),
                            );

                        if (!context.mounted || result == null) return;

                        context.read<ProductBloc>().add(
                          ProductFiltersChanged(
                            minPrice: result.minPrice,
                            maxPrice: result.maxPrice,
                            minRating: result.minRating,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tune_rounded, size: 19),
                          const SizedBox(width: 6),
                          const Text('Filter'),
                          if (activeFilterCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF5035FF),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$activeFilterCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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
                  return const _ProductGridSkeleton();
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
                    final bloc = context.read<ProductBloc>();

                    final refreshCompleted = bloc.stream.firstWhere(
                      (state) => state.status != ProductStatus.loading,
                    );

                    bloc.add(const ProductsRefreshed());

                    await refreshCompleted;
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
                              itemCount:
                                  products.length +
                                  (state.isLoadingMore ? 1 : 0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: width < 600 ? 0.62 : 0.78,
                                  ),

                              itemBuilder: (context, index) {
                                if (index >= products.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                return _ProductCard(product: products[index]);
                              },
                            );
                          },
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

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '\$${(product.price * (1 - product.discountPercentage / 100)).toStringAsFixed(2)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF5035FF),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (product.discountPercentage > 0) ...[
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (product.discountPercentage > 0) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F7EC),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                              style: const TextStyle(
                                color: Color(0xFF18743A),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
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

class _ProductFilterValues {
  const _ProductFilterValues({this.minPrice, this.maxPrice, this.minRating});

  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
}

class _ProductFilterSheet extends StatefulWidget {
  const _ProductFilterSheet({this.minPrice, this.maxPrice, this.minRating});

  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  @override
  State<_ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<_ProductFilterSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  double? _selectedRating;
  String? _validationError;

  @override
  void initState() {
    super.initState();

    _minPriceController = TextEditingController(
      text: widget.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.maxPrice?.toString() ?? '',
    );
    _selectedRating = widget.minRating;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  double? _parsePrice(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = double.tryParse(value.trim());

    if (parsed == null || !parsed.isFinite) {
      return 'Enter a valid price';
    }

    if (parsed < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  void _applyFilters() {
    if (!_formKey.currentState!.validate()) return;

    final minPrice = _parsePrice(_minPriceController.text);
    final maxPrice = _parsePrice(_maxPriceController.text);

    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      setState(() {
        _validationError = 'Minimum price cannot exceed maximum price.';
      });
      return;
    }

    Navigator.of(context).pop(
      _ProductFilterValues(
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: _selectedRating,
      ),
    );
  }

  void _resetFilters() {
    Navigator.of(context).pop(const _ProductFilterValues());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFDFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8D4E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE8FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF5035FF),
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF211B35),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Find products that fit your needs',
                            style: TextStyle(
                              color: Color(0xFF777287),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close filters',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                const Text(
                  'Price range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your preferred minimum and maximum price.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF777287)),
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _priceField(
                        controller: _minPriceController,
                        label: 'Minimum price',
                        validator: _validatePrice,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _priceField(
                        controller: _maxPriceController,
                        label: 'Maximum price',
                        validator: _validatePrice,
                      ),
                    ),
                  ],
                ),

                if (_validationError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _validationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 26),

                const Text(
                  'Minimum rating',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose the minimum customer rating.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF777287)),
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ratingChip('Any', null),
                    _ratingChip('3+ ★', 3.0),
                    _ratingChip('4+ ★', 4.0),
                    _ratingChip('4.5+ ★', 4.5),
                  ],
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          foregroundColor: const Color(0xFF5035FF),
                          side: const BorderSide(color: Color(0xFFDCD5FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Reset all',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _applyFilters,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5035FF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text(
                          'Apply filters',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      onChanged: (_) {
        if (_validationError != null) {
          setState(() => _validationError = null);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixText: '\$ ',
        filled: true,
        fillColor: const Color(0xFFF6F4FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorMaxLines: 2,
      ),
    );
  }

  Widget _ratingChip(String label, double? rating) {
    final selected = _selectedRating == rating;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF514A66),
        fontWeight: FontWeight.w600,
      ),
      selectedColor: const Color(0xFF5035FF),
      backgroundColor: const Color(0xFFF3F1FF),
      side: BorderSide(
        color: selected ? const Color(0xFF5035FF) : const Color(0xFFE5E0F0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (_) {
        setState(() => _selectedRating = rating);
      },
    );
  }
}

class _ProductGridSkeleton extends StatelessWidget {
  const _ProductGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 600
            ? 2
            : width < 1024
            ? 3
            : 4;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: columns * 3,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: width < 600 ? 0.62 : 0.78,
          ),
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade50,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 70, color: Colors.white),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
