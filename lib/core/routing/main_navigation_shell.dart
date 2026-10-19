import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/presentation/bloc/cart_state.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({required this.child, super.key});

  static const Color _purple = Color(0xFF294B45);
  static const Color _lavender = Color(0xFFE8EDE3);
  static const Color _background = Color(0xFFF5F7F2);
  static const Color _border = Color(0xFFDCE3D8);

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
      case 1:
        context.go('/cart');
      case 2:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(location);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      backgroundColor: _background,
      body: isWide
          ? Row(
              children: [
                Container(
                  width: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCFDF9),
                    border: Border(right: BorderSide(color: _border)),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _lavender,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_rounded,
                            color: _purple,
                            size: 25,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _RailItem(
                          icon: Icons.storefront_outlined,
                          selectedIcon: Icons.storefront_rounded,
                          label: 'Products',
                          selected: selectedIndex == 0,
                          onTap: () => _navigate(context, 0),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<CartBloc, CartState>(
                          builder: (context, state) {
                            return _RailItem(
                              icon: Icons.shopping_cart_outlined,
                              selectedIcon: Icons.shopping_cart_rounded,
                              label: 'Cart',
                              selected: selectedIndex == 1,
                              badgeCount: state.totalItems,
                              onTap: () => _navigate(context, 1),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _RailItem(
                          icon: Icons.person_outline_rounded,
                          selectedIcon: Icons.person_rounded,
                          label: 'Profile',
                          selected: selectedIndex == 2,
                          onTap: () => _navigate(context, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: isWide
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFCFDF9),
                border: Border(top: BorderSide(color: _border)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A30204D),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BottomNavItem(
                          icon: Icons.storefront_outlined,
                          selectedIcon: Icons.storefront_rounded,
                          label: 'Products',
                          selected: selectedIndex == 0,
                          onTap: () => _navigate(context, 0),
                        ),
                      ),
                      Expanded(
                        child: BlocBuilder<CartBloc, CartState>(
                          builder: (context, state) {
                            return _BottomNavItem(
                              icon: Icons.shopping_cart_outlined,
                              selectedIcon: Icons.shopping_cart_rounded,
                              label: 'Cart',
                              selected: selectedIndex == 1,
                              badgeCount: state.totalItems,
                              onTap: () => _navigate(context, 1),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: _BottomNavItem(
                          icon: Icons.person_outline_rounded,
                          selectedIcon: Icons.person_rounded,
                          label: 'Profile',
                          selected: selectedIndex == 2,
                          onTap: () => _navigate(context, 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  static const Color _purple = Color(0xFF294B45);
  static const Color _lavender = Color(0xFFE8EDE3);
  static const Color _muted = Color(0xFF77827A);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: 36,
                  width: selected ? 66 : 52,
                  decoration: BoxDecoration(
                    color: selected ? _lavender : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Badge(
                      isLabelVisible: badgeCount > 0,
                      label: Text(badgeCount > 99 ? '99+' : '$badgeCount'),
                      backgroundColor: const Color(0xFFB9D96B),
                      textColor: Colors.white,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          selected ? selectedIcon : icon,
                          key: ValueKey(selected),
                          size: 23,
                          color: selected ? _purple : _muted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    color: selected ? _purple : _muted,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  static const Color _purple = Color(0xFF294B45);
  static const Color _lavender = Color(0xFFE8EDE3);
  static const Color _muted = Color(0xFF77827A);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _lavender : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text(badgeCount > 99 ? '99+' : '$badgeCount'),
                backgroundColor: const Color(0xFFB9D96B),
                textColor: Colors.white,
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: selected ? _purple : _muted,
                  size: 24,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? _purple : _muted,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
