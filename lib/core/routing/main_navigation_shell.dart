import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/presentation/bloc/cart_state.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({required this.child, super.key});

  final Widget child;

  int _selectedIndex(String location) {
    if (location.startsWith('/cart')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/products');
        return;
      case 1:
        context.go('/cart');
        return;
      case 2:
        context.go('/profile');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    final selectedIndex = _selectedIndex(location);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront),
        label: 'Products',
      ),
      NavigationDestination(
        icon: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) => _CartIcon(count: state.totalItems),
        ),
        selectedIcon: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) =>
              _CartIcon(count: state.totalItems, selected: true),
        ),
        label: 'Cart',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => _navigate(context, index),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.storefront_outlined),
                      selectedIcon: Icon(Icons.storefront),
                      label: Text('Products'),
                    ),
                    NavigationRailDestination(
                      icon: BlocBuilder<CartBloc, CartState>(
                        builder: (context, state) =>
                            _CartIcon(count: state.totalItems),
                      ),
                      selectedIcon: BlocBuilder<CartBloc, CartState>(
                        builder: (context, state) =>
                            _CartIcon(count: state.totalItems, selected: true),
                      ),
                      label: const Text('Cart'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _navigate(context, index),
              destinations: destinations,
            ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count, this.selected = false});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      selected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
    );

    if (count <= 0) return icon;

    return Badge(label: Text(count > 99 ? '99+' : '$count'), child: icon);
  }
}
